//
//  DetailViewController.h
//  iTune
//
//  Created by Luke Madronal on 10/6/15.
//  Copyright © 2015 Luke Madronal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property(nonatomic,weak)IBOutlet UILabel *trackName;
@property(nonatomic,weak)IBOutlet UILabel *artistName;
@property(nonatomic,weak)IBOutlet UILabel *trackLength;
@property(nonatomic,weak)IBOutlet UILabel *trackPrice;
@property(nonatomic,weak)IBOutlet UILabel *trackReleaseDate;
@property(nonatomic,weak)IBOutlet UILabel *albumName;

@end
