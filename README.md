# EasyTableCtr
## 关键字：代码无侵入 优雅<br/>
结合MJRefresh与LYEmptyView，优雅地显示emptyView。<br/>
Display emptyView easily with MJRefresh and LYEmptyView.<br/>
LYEmptyView实现了在tableView刷新时自动切换emptyView的显示隐藏，但是第一次进入页面时肯定是空的，没有发出网络请求就显示个空的页面可能不符合产品要求，本文章旨在解决此问题。
<br/>
<img src="https://github.com/liuxuleidota/EasyTableCtr/blob/master/2.gif" width = "300" alt="效果展示"/>

# 使用方法
### 1.首先集成[MJRefresh](https://github.com/CoderMJLee/MJRefresh)，[LYEmptyView](https://github.com/dev-liyang/LYEmptyView)
### 1.首先集成[MJRefresh](https://github.com/CoderMJLee/MJRefresh)与[LYEmptyView](https://github.com/dev-liyang/LYEmptyView)
### 2.新建MJRefreshComponent分类，交换beginRefreshing与endRefreshing方法
```
//交换MJRefreshComponent的方法是因为，footer与header都是继承于此类，
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
    [self.scrollView ly_startLoading];
}

- (void)customEndRefreshing{
    [self customEndRefreshing];
    [self.scrollView ly_endLoading];
}
```
### 3.为tableView添加emptyView,此处可以通过定义BaseTableView/BaseTableViewController来简化使用
```
    //add empty view
    LYEmptyView *emptyV = [LYEmptyView emptyViewWithImage:[UIImage imageNamed:@"empty_page"] titleStr:@"暂无数据，点击重试" detailStr:nil];
    emptyV.autoShowEmptyView = NO;
    self.tableView.ly_emptyView = emptyV;
```
### 4.数据请求开始，注意，如果不是通过mj_header的beginRefreshing方法发起请求，
将不会调用ly_startLoading，导致emptyView不显示，如果有此种情况，请自行处理
```
    //mj_header开始刷新时会调用beginRefreshing
    //beginRefreshing通过方法交换，调用ly_startLoading
    [self.tableView.mj_header beginRefreshing];
```
### 5.数据请求完成后调用reloadData，再调用mj_header endRefreshing
```
    [self.tableView reloadData];
    //注意要在reloadData之后调用endRefreshing
    //endRefreshing通过方法交换，调用ly_endLoading
    [self.tableView.mj_header endRefreshing];
```
### 6.注意在MJRefresh与LYEmptyView的触发事件block中使用weakSelf，因为两者都是对block进行的强持有
### 7.更进一步，上面的解决方案，在点击emptyView触发header的beginRefreshing时，会再次隐藏emptyView，这时候产品又说了，只有在第一次进入界面且数据为空时不显示emptyView，换句话就是，只有在没有发出任何一次请求之前，才显示emptyView，要实现这个需求，需要：
### 再添加一个UIView的分类，为其添加一个firstIn属性，将之前MJRefreshComponent中的两个方法更新为以下内容
```
- (void)customBeginRefreshing{
    [self customBeginRefreshing];
    
    //如果是第一次进入，执行ly_startLoading
    if (self.scrollView.firstIn) {
        [self.scrollView ly_startLoading];
    } else {    //如果不是第一次进入，打开emptyView的autoShowEmptyView
        self.scrollView.ly_emptyView.autoShowEmptyView = YES;
    }
}

- (void)customEndRefreshing{
    [self customEndRefreshing];
    //结束网络请求后，将view的firstIn属性设置为NO
    self.scrollView.firstIn = NO;
    [self.scrollView ly_endLoading];
}
```
### 8.未来展望，网络请求的loading能不能也采用类似思路解决？
    
