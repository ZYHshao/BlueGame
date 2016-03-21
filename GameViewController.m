//
//  GameViewController.m
//  BlueGame
//
//  Created by apple on 16/3/17.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "GameViewController.h"
#import "GameView.h"
#import "BlueToothTool.h"
@interface GameViewController ()<BlueToothToolDelegate,GameViewDelegate>
{
    UIView * _bgView;
    UILabel * _tipLabel;
    GameView * _view;
}
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    //创建游戏视图
    _view = [[GameView alloc]initWithFrame:CGRectMake(20, 40, (self.view.frame.size.width-40), (self.view.frame.size.width-40)/12*20)];
    _view.delegate=self;
    [self.view addSubview:_view];
    //创建背景视图
    _bgView = [[UIView alloc]initWithFrame:self.view.frame];
    _bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(self.view.frame.size.width/2-50, 150, 100, 30);
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(self.view.frame.size.width/2-50, 250, 100, 30);
    [btn setTitle:@"创建游戏" forState:UIControlStateNormal];
    [btn2 setTitle:@"扫描附近游戏" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    btn2.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(creatGame) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(searchGame) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:btn];
    [_bgView addSubview:btn2];
    
    [self.view addSubview:_bgView];
    //设置蓝牙通讯类代理
    [BlueToothTool sharedManager].delegate=self;
    //创建提示标签
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,40)];
    [self.view addSubview:_tipLabel];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
}
-(void)creatGame{
    [[BlueToothTool sharedManager]setUpGame:@"" block:^(BOOL first) {
        [_bgView removeFromSuperview];
        if (first) {
            _tipLabel.text = @"请您下子";
            //进行发送下子信息
        }else{
            _tipLabel.text = @"请等待对方下子";
            self.view.userInteractionEnabled = NO;
            [self gameViewClick:@"-1"];
        }
    }];
}
-(void)searchGame{
    [[BlueToothTool sharedManager]searchGame];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getData:(NSString *)data{
    if (_bgView.superview) {
        [_bgView removeFromSuperview];
    }
    if ([data integerValue]==-1) {
        _tipLabel.text = @"请您下子";
         self.view.userInteractionEnabled = YES;
        return;
    }
    _tipLabel.text = @"请您下子";
    [_view setTipIndex:[data intValue]];
    self.view.userInteractionEnabled = YES;
}

-(void)gameViewClick:(NSString *)index{
    _tipLabel.text = @"请等待对方下子";
    [[BlueToothTool sharedManager]writeData:index];
    self.view.userInteractionEnabled = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
