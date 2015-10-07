//
//  DetailViewController.m
//  iTune
//
//  Created by Luke Madronal on 10/6/15.
//  Copyright © 2015 Luke Madronal. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property(nonatomic,weak)IBOutlet UILabel *trackName;
@property(nonatomic,weak)IBOutlet UILabel *artistName;
@property(nonatomic,weak)IBOutlet UILabel *trackLength;
@property(nonatomic,weak)IBOutlet UILabel *trackPrice;
@property(nonatomic,weak)IBOutlet UILabel *albumName;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _trackName.text = [_currentTrack objectForKey:@"trackName"];
    _albumName.text = [_currentTrack objectForKey:@"collectionName"];
    double time =[[_currentTrack objectForKey:@"trackTimeMillis"] doubleValue];
    NSString* timeString = [NSString stringWithFormat:@"%f", (time/1000)/60];
    _trackLength.text =timeString;
    _artistName.text = [_currentTrack objectForKey:@"artistName"];
    
    
     NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
     [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
     _trackPrice.text = [formatter stringFromNumber:[_currentTrack objectForKey:@"trackPrice"]];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
