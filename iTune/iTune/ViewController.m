//
//  ViewController.m
//  iTune
//
//  Created by Luke Madronal on 10/5/15.
//  Copyright © 2015 Luke Madronal. All rights reserved.
//

#import "ViewController.h"
#import "TableViewSearchCell.h"
#import "DetailViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic,weak) NSString *hostName;

@property (nonatomic,weak) IBOutlet UITableView *searchTableView;
@property (nonatomic,weak) IBOutlet UITextField *searchTextField;
@property (nonatomic,strong) NSMutableArray     *albumMutableArray;
@property (nonatomic,strong) NSMutableArray     *trackMutableArray;
@property (nonatomic,strong) NSURL              *currentURL;
@property (nonatomic,strong) NSString           *currentURLString;


@end

@implementation ViewController

Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;
bool internetAvailable;
bool serverAvailable;

#pragma mark - Network Methods

-(void)updateReachablityStatus: (Reachability *)currReach {
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currReach currentReachabilityStatus];
    if (currReach == hostReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"server not reachable");
                serverAvailable = false;
                break;
            case ReachableViaWiFi:
                NSLog(@"server reachable via wifi");
                serverAvailable=true;
                break;
            case ReachableViaWWAN:
                NSLog(@"server reachable via wan");
                serverAvailable = true;
                break;
            default:
                break;
        }
    }
    if (currReach == internetReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"interent not reachable");
                internetAvailable = false;
                break;
            case ReachableViaWiFi:
                NSLog(@"internet reachable via wifi");
                internetAvailable=true;
                break;
            case ReachableViaWWAN:
                NSLog(@"internet reachable via wan");
                internetAvailable= true;
                break;
            default:
                break;
        }
    }
}

-(void)reachabilityChanged: (NSNotification *)note {
    Reachability *currReach = [note object];
    [self updateReachablityStatus:currReach];
}

-(NSString *) getDocumentsDirectory {
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSLog(@"DocPath:%@",paths[0]);
    return paths[0];
}

-(BOOL)fileIsLocal:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self getDocumentsDirectory] stringByAppendingPathComponent:fileName];
    return [fileManager fileExistsAtPath:filePath];
}

# pragma mark - Interactivty Methods

-(IBAction)getFilePressed:(id)sender {
    if (serverAvailable) {
        NSLog(@"server not available");
        //      NSURL *fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/classfiles/iOS_URL_Class_Get_File.txt",_hostName]];
        //        NSURL *fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/classfiles/flavors.json",_hostName]];
        NSString *searchName = _searchTextField.text;
        _currentURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=m%@",searchName]];
        _currentURLString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=m%@",searchName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:_currentURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (([data length] >0) && (error == nil)) {
                NSLog(@"Got Data %@", data);
                //                                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                //                                NSLog(@"Got String %@", dataString);
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"json: %@", json);
                _trackMutableArray = [(NSDictionary *) json objectForKey:@"results"];
                for (NSDictionary *trackDict in _trackMutableArray ) {
                    //add this to the track array and make it a subtitle
                    NSLog(@"track name:%@",[trackDict objectForKey:@"trackName"]);
                    NSLog(@"album name:%@",[trackDict objectForKey:@"collectionName"]);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //MAIN THREAD CODE GOES HERE
                    [_searchTableView reloadData];
                    NSLog(@"size is: %li",_trackMutableArray.count);
                });
            } else {
                NSLog(@"DONT Got Data");
            }
        }] resume];
    } else {
        NSLog(@"server not available");
    }
}

-(void)getImageFromServer:(NSString *)localFileName fromUrl:(NSString *)fullFileName atIndexPath:(NSIndexPath *)indexPath {
    if(serverAvailable) {
        NSURL *fileURL = [NSURL URLWithString:fullFileName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if ([data length] > 0 && error==nil) {
                NSString *savedFilePath = [[self getDocumentsDirectory] stringByAppendingPathComponent:localFileName];
                UIImage *imageTemp = [UIImage imageWithData:data];
                if (imageTemp != nil) {
                    [data writeToFile:savedFilePath atomically:true];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_searchTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }
            } else {
                NSLog(@"no data");
            }
        }]resume];
    } else {
        NSLog(@"server not available");
    }
}


#pragma mark - TableView Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _trackMutableArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UITableViewCell *contactCell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"resultCell"];
    NSDictionary *trackDict = _trackMutableArray[indexPath.row];
    contactCell.textLabel.text = [trackDict objectForKey:@"trackName"];
    contactCell.detailTextLabel.text = [trackDict objectForKey:@"collectionName"];
    NSLog(@"this is the last thing that i printed");
    NSString *url = [trackDict objectForKey:@"artworkUrl60"];
    NSString *fileName = [url stringByReplacingOccurrencesOfString:@":" withString:@""];
    fileName = [url stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([self fileIsLocal:fileName] ) {
        NSLog(@"LOCAAALLLLLLLLLŁLLLLLLLLLLLLLLLLLLLLLLL %@",fileName);
        contactCell.imageView.image = [UIImage imageNamed:[[self getDocumentsDirectory] stringByAppendingPathComponent:fileName]];
    } else {
        NSLog(@"not local %@",fileName);

        [self getImageFromServer:fileName fromUrl:url atIndexPath:indexPath];
    }
    return contactCell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DetailViewController *destController = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"segueToDetail"]) {
        NSIndexPath *indexPath = [_searchTableView indexPathForSelectedRow];
        NSDictionary *trackDict = _trackMutableArray[indexPath.row];
        destController.currentTrack = trackDict;
    }
}


#pragma mark -Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"www.moveablebytes.com";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:_hostName];
    [hostReach startNotifier];
    [self updateReachablityStatus:hostReach];
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateReachablityStatus:internetReach];
    _trackMutableArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
