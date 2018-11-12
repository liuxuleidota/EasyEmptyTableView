//
//  CustomTableViewController.m
//  EasyEmptyTableViewDemo
//
//  Created by levi on 2018/11/11.
//  Copyright © 2018 levi. All rights reserved.
//

#import "CustomTableViewController.h"
#import <LYEmptyView/LYEmptyViewHeader.h>
#import <objc/runtime.h>

@implementation CustomTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    //add empty view
    [self.tableView setUpEmptyView];
}

@end


@implementation CustomTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self setUpEmptyView];
    }

    return self;
}

@end

@implementation UITableView (Custom)

- (void)setUpEmptyView{
    LYEmptyView *emptyV = [LYEmptyView emptyViewWithImage:[UIImage imageNamed:@"EasyEmptyTableView.bundle/empty_page"] titleStr:@"暂无数据，点击重试" detailStr:nil];
    emptyV.autoShowEmptyView = NO;
    self.ly_emptyView = emptyV;
}

@end

