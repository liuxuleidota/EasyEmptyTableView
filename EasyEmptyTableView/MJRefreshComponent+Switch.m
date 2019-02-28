//
//  MJRefreshComponent+Switch.m
//  EasyEmptyTableViewDemo
//
//  Created by levi on 2018/11/9.
//  Copyright © 2018 levi. All rights reserved.
//

#import "MJRefreshComponent+Switch.h"
#import <MJRefresh/MJRefresh.h>
#import <LYEmptyView/LYEmptyViewHeader.h>

@implementation MJRefreshComponent (Switch)

//交换MJRefreshComponent的方法是因为，footer与header都是继承于此类
//所以不论是footer还是header，都会在结束刷新后正确的显示/隐藏emptyView
+ (void)load{
    Method m1, m2;
    
    m1 = class_getInstanceMethod(self, @selector(beginRefreshing));
    m2 = class_getInstanceMethod(self, @selector(customBeginRefreshing));
    method_exchangeImplementations(m1, m2);
    
    m1 = class_getInstanceMethod(self, @selector(endRefreshing));
    m2 = class_getInstanceMethod(self, @selector(customEndRefreshing));
    method_exchangeImplementations(m1, m2);
}

- (void)customBeginRefreshing{
    [self customBeginRefreshing];
    
    //如果是第一次进入，执行ly_startLoading
    if (self.scrollView.haveBeenInBefore==NO) {
        [self.scrollView ly_startLoading];
        
        //将view的haveBeenInBefore属性设置为YES
        self.scrollView.haveBeenInBefore = YES;
    } else {    //如果不是第一次进入，打开emptyView的autoShowEmptyView
        self.scrollView.ly_emptyView.autoShowEmptyView = YES;
    }
}

- (void)customEndRefreshing{
    [self customEndRefreshing];
    
    [self.scrollView ly_endLoading];
}

@end

static NSString* const haveBeenInBeforeKey = @"haveBeenInBeforeKey";

@implementation UIView (FirstIn)

- (void)setHaveBeenInBefore:(BOOL)haveBeenInBefore{
    objc_setAssociatedObject(self, &haveBeenInBeforeKey, @(haveBeenInBefore), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)haveBeenInBefore{
    return [objc_getAssociatedObject(self, &haveBeenInBeforeKey) boolValue];
}

@end
