//
//  FirstViewController.m
//  EasyEmptyTableViewDemo
//
//  Created by levi on 2018/11/9.
//  Copyright © 2018 levi. All rights reserved.
//

#import "FirstViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <LYEmptyView/LYEmptyViewHeader.h>
#import "MJRefreshComponent+Switch.h"

@interface FirstViewController ()

@property(nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self setUpData];
    self.dataArr = [NSMutableArray array];
    [self setUpViews];
    [self headerRefresh];
}

- (void)setUpData{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        
        if (_dataArr.count > 0) {
            [_dataArr removeAllObjects];
        } else {
            _dataArr = [NSMutableArray array];
            
            for (int i=0; i<10; i++) {
                [_dataArr addObject:[NSString stringWithFormat:@"第%ld行", i]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            //注意要在reloadData之后调用endRefreshing
            //endRefreshing通过方法交换，调用ly_endLoading
            [self.tableView.mj_header endRefreshing];
        });
    });
}

- (void)headerRefresh{
    [self.tableView.mj_header beginRefreshing];
}

- (void)setUpViews{
    self.title = [NSString stringWithFormat:@"首次%@显示", _showEmptyViewAtFirstIn ? @"":@"不"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换显示" style:(UIBarButtonItemStylePlain) target:self action:@selector(headerRefresh)];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:[self cellIder]];
    self.tableView.tableFooterView = [UIView new];
    [self setUpEasyEmptyView];
}

- (void)setUpEasyEmptyView{
    //分以下情况:
    //自动显示emptyView,直接引用本库,并初始化即可
    //第一次不显示emptyView,之后自动显示/隐藏,设置ly_emptyView.autoShowEmptyView = NO,并初始化即可
    //如果需要在首次进入时就显示emptyView,即自动显示emptyView,则将emptyView的autoShowEmptyView设置为yes即可
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

- (NSString*)cellIder{
    return [NSString stringWithFormat:@"%@CellIder", self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIder] forIndexPath:indexPath];
    cell.textLabel.text = _dataArr[indexPath.row];
    return cell;
}

- (void)dealloc{
    NSLog(@"%@ is dealloc", self);
}


@end
