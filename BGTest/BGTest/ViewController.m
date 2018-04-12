//
//  ViewController.m
//  BGTest
//
//  Created by 梅YL on 2018/1/31.
//  Copyright © 2018年 梅YL. All rights reserved.
//

#import "ViewController.h"
#import "BGFMDB.h"
#import "PersonModel.h"
#import "EditViewController.h"
#import "SWTableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) SWTableViewCell *selectedCell;
@end

@implementation ViewController{
    NSInteger number;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    number = 5;
    //设置操作过程中不可关闭数据库(即closeDB函数无效),防止数据更新的时候频繁关闭开启数据库.
    bg_setDisableCloseDB(YES);
    //注册数据变化监听.
    [self registerChange];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:@"插入" style:UIBarButtonItemStylePlain target:self action:@selector(insertData)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deletetData)];
    
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
    
    NSArray *modelArray = [PersonModel bg_find:@"PersonModel" limit:0 orderBy:@"bg_id" desc:NO];
    number = modelArray.count;
    [self.dataArray addObjectsFromArray:modelArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateModel:) name:@"UpDateModel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellChangeState:) name:@"CellChangeState" object:nil];
}
- (void)upDateModel:(NSNotification *)notifiCation{
    
}

- (void)cellChangeState:(NSNotification *)notifiCation{
    if (_selectedCell) {
        [self swipeableTableViewCell:_selectedCell scrollingToState:kCellStateCenter];
//        [_selectedCell isUtilityButtonsHidden];
    }
}

- (void)insertData{
    number +=1;
    PersonModel *model = [PersonModel new];
    model.id = [NSString stringWithFormat:@"%ld",number];
    model.name = [NSString stringWithFormat:@"翠花_%ld",number];
    model.age = number;
    model.sex = @"sex";
    /**
     同步存储或更新.
     当"唯一约束"或"主键"存在时，此接口会更新旧数据,没有则存储新数据.
     提示：“唯一约束”优先级高于"主键".
     */
    [model bg_saveOrUpdate];
    
    NSString *homeDir = NSHomeDirectory();
    
    NSLog(@"%@",homeDir);
    
    /**
     获取该类的数据库版本号;
     */
    NSInteger version = [PersonModel bg_version:nil];
    NSLog(@"version000_____%ld",version);
    
//    [PersonModel bg_update:nil version:number];
    
//    NSInteger version1 = [PersonModel bg_version:nil];
//    NSLog(@"version1111_____%ld",version1);
    
    NSDictionary *dic = [model bg_keyValuesIgnoredKeys:nil];
    
    NSLog(@"%@",dic);
}
- (void)deletetData{
    if (self.dataArray.count <= 0) {
        return;
    }
    //删除self.dataArray 的最后一条数据
    PersonModel *model = self.dataArray.lastObject;
    NSString *value = [NSString stringWithFormat:@"%@",model.name];
    //根据条件删除
    [PersonModel bg_delete:nil where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"name"),bg_sqlValue(value)]];
    [self.dataArray removeLastObject];
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataArray.count inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld",[PersonModel bg_count:nil where:nil]];
}

//注册数据变化监听.
-(void)registerChange{
    //注册数据变化监听.
//    __weak typeof(self) BGSelf = self;
    [PersonModel bg_registerChangeForTableName:nil identify:@"PersonModel" block:^(bg_changeState result) {
//        NSLog(@"当前线程 = %@",[NSThread currentThread]);
        if ((result==bg_insert) || (result==bg_update)){
            //降序查询
            NSArray *modelArray = [PersonModel bg_find:@"PersonModel" limit:0 orderBy:@"bg_id" desc:NO];
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:modelArray];
            [_tableView reloadData];
            
            self.navigationItem.title = [NSString stringWithFormat:@"%ld",[PersonModel bg_count:nil where:nil]];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
    cell.leftUtilityButtons = [self leftButtons];
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    PersonModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@" id : %@ %@    age : %ld  sex : %@",model.bg_id, model.name,model.age,model.sex];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];

    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];

    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"心副本.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"心副本.png"]];

    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor whiteColor] normalIcon:[UIImage imageNamed:@"心副本"] selectedIcon:[UIImage imageNamed:@"心副本"]  title:@"咱门"];

    return leftUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{
 
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellChangeState" object:nil];
    
    switch (state) {
        case kCellStateCenter:
            NSLog(@"kCellStateCenter");
            break;
        case kCellStateLeft:
            NSLog(@"kCellStateLeft");
            break;
        case kCellStateRight:
            NSLog(@"kCellStateRight");
            break;
        default:
            break;
    }
    _selectedCell = cell;
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell{
    //滑动时关掉之前的
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state{
    
    return YES;
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    NSLog(@"left----%ld",index);
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    NSLog(@"right----%ld",index);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EditViewController *edit = [[EditViewController alloc]initWithNibName:@"EditViewController" bundle:[NSBundle mainBundle]];
    edit.model = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:edit animated:YES];
}

////让tableView可编辑
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    //删除
//    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        NSLog(@"点击了删除");
//    }];
//    deleteRowAction.backgroundColor = [UIColor greenColor];
//    //置顶
//    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        NSLog(@"点击了删除置顶");
//    }];
//
//    //标记为已读
//    UITableViewRowAction *readedRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"标记为已读" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        NSLog(@"点击了标记为已读");
//    }];
//
//    if(indexPath.section == 0 && indexPath.row == 0)
//    {
//        return @[deleteRowAction];
//    }
//    else if(indexPath.section == 0 && indexPath.row == 1)
//    {
//        return @[deleteRowAction, readedRowAction];
//    }
//    else if (indexPath.section == 1 && indexPath.row == 0)
//    {
//        return @[topRowAction];
//    }
//    else
//    {
//        return @[deleteRowAction, topRowAction, readedRowAction];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"右滑" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//         NSLog(@"右滑");
//    }];
//    deleteAction.image = [UIImage imageNamed:@"定位-5"];
//    UIContextualAction *deleteAction1 = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"右滑1" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        NSLog(@"右滑1");
//    }];
//    deleteAction1.image = [UIImage imageNamed:@"心副本"];
//    deleteAction1.title = @"9999";
//    UIContextualAction *deleteAction2 = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"右滑2" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        NSLog(@"右滑2");
//    }];
//    deleteAction2.image = [UIImage imageNamed:@"弹出"];
//    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction2,deleteAction1,deleteAction]];
//    configuration.performsFirstActionWithFullSwipe = NO;//禁止cell 一直滑动调用
//    return  configuration;
//}
//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"左滑" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        NSLog(@"左滑");
//    }];
//    deleteAction.backgroundColor = [UIColor orangeColor];
//    deleteAction.image = [UIImage imageNamed:@"定位-5"];
//    UIContextualAction *deleteAction1 = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"左滑1" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        NSLog(@"左滑1");
//    }];
//    deleteAction1.image = [UIImage imageNamed:@"心副本"];
//    UIContextualAction *deleteAction2 = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"左滑2" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        NSLog(@"左滑2");
//    }];
//    deleteAction2.title = @"111111";
//    deleteAction2.image = [UIImage imageNamed:@"弹出"];
//    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction2,deleteAction1,deleteAction]];
//    return  configuration;
//}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[SWTableViewCell class] forCellReuseIdentifier:@"cell"];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 1)];
        view.backgroundColor = [UIColor redColor];
        _tableView.tableFooterView = view;
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}


@end
