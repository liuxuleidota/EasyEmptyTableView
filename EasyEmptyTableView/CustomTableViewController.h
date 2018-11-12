//
//  CustomTableViewController.h
//  EasyEmptyTableViewDemo
//
//  Created by levi on 2018/11/11.
//  Copyright © 2018 levi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewController : UITableViewController

@end

@interface CustomTableView : UITableView

@end

@interface UITableView (Custom)

- (void)setUpEmptyView;

@end

NS_ASSUME_NONNULL_END
