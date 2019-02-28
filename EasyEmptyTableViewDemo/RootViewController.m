//
//  RootViewController.m
//  EasyEmptyTableViewDemo
//
//  Created by levi on 2019/2/27.
//  Copyright © 2019 levi. All rights reserved.
//

#import "RootViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showEmptyViewAtFirstIn;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *ctr = [segue destinationViewController];
    [ctr setValue:@(_showEmptyViewAtFirstIn.on) forKey:@"showEmptyViewAtFirstIn"];
}

@end
