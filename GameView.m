//
//  GameView.m
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "GameView.h"


@implementation GameView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tipArray = [[NSMutableArray alloc]init];
        [self creatView];
    }
    return self;
}
//创建表格视图 横16 竖20
-(void)creatView{
    self.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 0.5;
    CGFloat width = self.frame.size.width/12;
    CGFloat height = self.frame.size.height/20;
    //排列布局
    for (int i=0; i<240; i++) {
        TipButton * btn = [[TipButton alloc]initWithFrame:CGRectMake(width*(i%12), height*(i/12), width, height)];
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        btn.isWhite = NO;
        btn.index=i;
        [self addSubview:btn];
        [_tipArray addObject:btn];
    }
}
-(void)click:(TipButton *)btn{
    if (btn.hasChess==0) {
        //下子
        [btn dropChess:YES];
        //进行胜负判定
        [self cheak];
        [self.delegate gameViewClick:[NSString stringWithFormat:@"%d",btn.index]];
    }
}
//进行胜负判定
-(void)cheak{
    //判定己方是否胜利
    if ([self cheakMine]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"您胜利啦" message:@"" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }
    if ([self cheakOther]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"您失败了" message:@"" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)setTipIndex:(int)index{
    //下子
    for (TipButton * btn in _tipArray) {
        if (btn.index==index) {
            [btn dropChess:NO];
            [self cheak];
        }
    }
}
-(BOOL)cheakOther{
    //遍历所有棋子
    for (int i=0; i<_tipArray.count; i++) {
        TipButton * tip = _tipArray[i];
        //获取是否是己方棋子
        if (tip.hasChess==2) {
            //进行五子判定逻辑
            //横向
            if ( [self cheak1HasMineOrOther:NO index:i]) {
                return YES;
            }
            //左上到右下的对角线
            if ( [self cheak2HasMineOrOther:NO index:i]) {
                return YES;
            }
            //纵向
            if ( [self cheak3HasMineOrOther:NO index:i]) {
                return YES;
            }
            //右上到左下的对角线
            if ( [self cheak4HasMineOrOther:NO index:i]) {
                return YES;
            }
        }
    }
    return NO;

}

-(BOOL)cheakMine{
    //遍历所有棋子
    for (int i=0; i<_tipArray.count; i++) {
        TipButton * tip = _tipArray[i];
        //获取是否是己方棋子
        if (tip.hasChess==1) {
            //进行五子判定逻辑
            //横向
            if ( [self cheak1HasMineOrOther:YES index:i]) {
                return YES;
            }
            //左上到右下的对角线
            if ( [self cheak2HasMineOrOther:YES index:i]) {
                return YES;
            }
            //纵向
            if ( [self cheak3HasMineOrOther:YES index:i]) {
                return YES;
            }
            //右上到左下的对角线
            if ( [self cheak4HasMineOrOther:YES index:i]) {
                return YES;
            }
        }
    }
    return NO;
}


-(BOOL)cheak1HasMineOrOther:(BOOL)mine index:(int)index{
    int mineOrOther = 0;
    if (mine) {
        mineOrOther = 1;
    }else{
        mineOrOther = 2;
    }
    int count=1;
    //左侧右侧同时进行可以增加效率
    //左侧
    count = count +[self algorithmic1:index param:mineOrOther num:4];
    //右侧
    count = count +[self algorithmic2:index param:mineOrOther num:4];
    if (count>=5) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)cheak2HasMineOrOther:(BOOL)mine index:(int)index{
    int mineOrOther = 0;
    if (mine) {
        mineOrOther = 1;
    }else{
        mineOrOther = 2;
    }
    int count=1;
    //左上右下同时进行可以增加效率
    //左上
    count = count +[self algorithmic3:index param:mineOrOther num:4];
    //右下
    count = count +[self algorithmic4:index param:mineOrOther num:4];
    if (count>=5) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)cheak3HasMineOrOther:(BOOL)mine index:(int)index{
    int mineOrOther = 0;
    if (mine) {
        mineOrOther = 1;
    }else{
        mineOrOther = 2;
    }
    int count=1;
    //纵向
    //向上
    count = count +[self algorithmic5:index param:mineOrOther num:4];
    //向下
    count = count +[self algorithmic6:index param:mineOrOther num:4];
    if (count>=5) {
        return YES;
    }else{
        return NO;
    }
}
-(BOOL)cheak4HasMineOrOther:(BOOL)mine index:(int)index{
    int mineOrOther = 0;
    if (mine) {
        mineOrOther = 1;
    }else{
        mineOrOther = 2;
    }
    int count=1;
    //纵向
    //向上
    count = count +[self algorithmic7:index param:mineOrOther num:4];
    //向下
    count = count +[self algorithmic8:index param:mineOrOther num:4];
    
    NSLog(@"%d",count);
    if (count>=5) {
        return YES;
    }else{
        return NO;
    }
}

/*
 左侧递归进行查找 index 棋子编号 param 对比值 num 递归次数
 */
-(int)algorithmic1:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
            //左侧有子
        if (index-tem>=0) {
            //左侧无换行
            if(((index-tem)%12)!=11){
                if (_tipArray[index-tem].hasChess==param) {
                   return  [self algorithmic1:index param:param num:num-1];
                }else{
                    return 4-num;
                }
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}
/*
 右侧递归进行查找 index 棋子编号 param 对比值 num 递归次数
 */
-(int)algorithmic2:(int)index param:(int)param num:(int)num{
    
    if (num>0) {
        int tem = 4-(num-1);
        //右侧有子
        if (index+tem<240) {
            //右侧无换行
            if(((index+tem)%12)!=11){
                if (_tipArray[index+tem].hasChess==param) {
                    return  [self algorithmic2:index param:param num:num-1];
                }else{
                    return 4-num;
                }
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}

/*
 左上递归进行查找 index 棋子编号 param 对比值 num 递归次数
 */
-(int)algorithmic3:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
        //左上有子
        if ((index-(tem*12)-tem)>=0) {
            //右侧无换行
            if(((index-(tem*12)-tem)%12)!=11){
                if (_tipArray[(index-(tem*12)-tem)].hasChess==param) {
                    return  [self algorithmic3:index param:param num:num-1];
                }else{
                    return 4-num;
                }
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}

-(int)algorithmic4:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
        //左上有子
        if ((index+(tem*12)+tem)<240) {
            //右侧无换行
            if(((index+(tem*12)+tem)%12)!=0){
                if (_tipArray[(index+(tem*12)+tem)].hasChess==param) {
                    return  [self algorithmic4:index param:param num:num-1];
                }else{
                    return 4-num;
                }
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}

-(int)algorithmic5:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
        //上有子
        if ((index-(tem*12))>=0) {
            if (_tipArray[(index-(tem*12))].hasChess==param) {
                return  [self algorithmic5:index param:param num:num-1];
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}

-(int)algorithmic6:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
        //上有子
        if ((index+(tem*12))<240) {
            if (_tipArray[(index+(tem*12))].hasChess==param) {
                return  [self algorithmic6:index param:param num:num-1];
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}
-(int)algorithmic7:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
        //左上有子
        if ((index-(tem*12)+tem)>=0) {
            //右侧无换行
            if(((index-(tem*12)+tem)%12)!=0){
                if (_tipArray[(index-(tem*12)+tem)].hasChess==param) {
                    return  [self algorithmic7:index param:param num:num-1];
                }else{
                    return 4-num;
                }
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}

-(int)algorithmic8:(int)index param:(int)param num:(int)num{
    if (num>0) {
        int tem = 4-(num-1);
        //左上有子
        if ((index+(tem*12)-tem)<240) {
            //右侧无换行
            if(((index+(tem*12)-tem)%12)!=11){
                if (_tipArray[(index+(tem*12)-tem)].hasChess==param) {
                    return  [self algorithmic8:index param:param num:num-1];
                }else{
                    return 4-num;
                }
            }else{
                return 4-num;
            }
        }else{
            return 4-num;
        }
    }else{
        //递归了四次
        return 4-num;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [[BlueToothTool sharedManager]disConnect];
    [(UIViewController *)[self.superview nextResponder] dismissViewControllerAnimated:YES completion:nil];
}
@end







