//
//  UITableView+Empty.m
//  EasyEmptyTableViewDemo
//
//  Created by levi on 2019/2/28.
//  Copyright © 2019 levi. All rights reserved.
//

#import "UITableView+Empty.h"
#import <LYEmptyView/LYEmptyViewHeader.h>

@implementation UITableView (Empty)

- (void)setUpEmptyView{
    LYEmptyView *emptyV = [LYEmptyView emptyViewWithImageStr:@"EasyEmptyTableView.bundle/empty_page" titleStr:@"暂无数据，点击重试" detailStr:nil];
    self.ly_emptyView = emptyV;
}

@end
