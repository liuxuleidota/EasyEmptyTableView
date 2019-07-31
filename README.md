# EasyEmptyTableView
## 关键字：代码无侵入 优雅<br/>
结合MJRefresh与LYEmptyView，优雅地显示emptyView。<br/>
Display emptyView easily with MJRefresh and LYEmptyView.<br/>
LYEmptyView实现了在tableView刷新时自动切换emptyView的显示隐藏,本文结合MJRefresh与LYEmptyView,实现了在MJRefresh刷新后,自动显示/隐藏emptyView的需求,同时,针对部分同学第一次进入页面时需要隐藏emptyView的需求也做了适配。
<br/>
<img src="https://github.com/liuxuleidota/EasyEmptyTableView/blob/master/demo.gif" width = "300" align="center" alt="效果展示"/>

# 使用方法/Usage
#### 1.CocoaPods:pod 'EasyEmptyTableView', '~> 1.0'
或者直接使用源码：[MJRefresh](https://github.com/CoderMJLee/MJRefresh)，[LYEmptyView](https://github.com/dev-liyang/LYEmptyView)，[EasyEmptyTableView](https://github.com/liuxuleidota/EasyEmptyTableView)
#### 2.引入相关文件
```
#import <MJRefresh/MJRefresh.h>
#import <LYEmptyView/LYEmptyViewHeader.h>
#import "EasyEmptyTableView.h"
```
#### 3.初始化EmptyView相关：
```
注意请在tableView初始化之后调用
- (void)setUpEasyEmptyView{
    /**
     分以下情况:
     一:
     自动显示emptyView,直接引用本库,并初始化即可
     解释:因为LYEmptyView默认配置就是自动显示/隐藏
     二:
     第一次不显示emptyView,之后自动显示/隐藏,设置ly_emptyView.autoShowEmptyView = NO,并初始化即可
     解释:第一次刷新数据之后,在MJRefreshComponent+Switch.h中,依据haveBeenInBefore属性更新了autoShowEmptyView=yes,之后就是ly_emptyView控制自动显示/隐藏
     */
    [self.tableView setUpEmptyView];
    
    //如果第一次需要隐藏,请加上以下三行代码
    if (_showEmptyViewAtFirstIn == NO) {
        self.tableView.ly_emptyView.autoShowEmptyView = NO;
    }
    
    //add header
    __weak typeof(self) wlf = self;
    
    //mj_header开始刷新时会调用beginRefreshing
    //beginRefreshing通过方法交换，调用ly_startLoading
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wlf setUpData];
    }];
    
    self.tableView.ly_emptyView.tapContentViewBlock = ^{
        [wlf headerRefresh];
    };
}
```

# 实现原理
#### 1.利用MJRefreshComponent的开始、结束刷新事件控制emptyView的显示
#### 2.新建MJRefreshComponent分类，交换beginRefreshing与endRefreshing方法
```
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
```
#### 3.在tableView的分类中添加属性,以满足第一次需要隐藏emptyView的产品需求,如无此需求,此步骤可略过不看
```
static NSString* const haveBeenInBeforeKey = @"haveBeenInBeforeKey";

@implementation UIView (FirstIn)

- (void)setHaveBeenInBefore:(BOOL)haveBeenInBefore{
    objc_setAssociatedObject(self, &haveBeenInBeforeKey, @(haveBeenInBefore), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)haveBeenInBefore{
    return [objc_getAssociatedObject(self, &haveBeenInBeforeKey) boolValue];
}
```
#### 4.为tableView添加emptyView
```
- (void)setUpEmptyView{
    LYEmptyView *emptyV = [LYEmptyView emptyViewWithImage:[UIImage imageNamed:@"EasyEmptyTableView.bundle/empty_page"] titleStr:@"暂无数据，点击重试" detailStr:nil];
    self.ly_emptyView = emptyV;
}
```
#### 5.数据请求开始，注意，如果不是通过mj_header的beginRefreshing方法发起请求，
#### 将不会调用ly_startLoading，导致emptyView不显示，如果有此种情况，请自行处理
```
    //mj_header开始刷新时会调用beginRefreshing
    //beginRefreshing通过方法交换，调用ly_startLoading
    [self.tableView.mj_header beginRefreshing];
```
#### 6.数据请求完成后调用reloadData，再调用mj_header endRefreshing
```
    [self.tableView reloadData];
    //注意要在reloadData之后调用endRefreshing
    //endRefreshing通过方法交换，调用ly_endLoading
    [self.tableView.mj_header endRefreshing];
```
#### 7.注意在MJRefresh与LYEmptyView的触发事件block中使用weakSelf，因为两者都是对block进行的强持有
#### 8.未来展望，网络请求的loading能不能也采用类似思路解决？
    
