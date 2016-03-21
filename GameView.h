//
//  GameView.h
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TipButton.h"
#import "BlueToothTool.h"
@protocol GameViewDelegate<NSObject>
-(void)gameViewClick:(NSString *)index;
@end

@interface GameView : UIView<UIAlertViewDelegate>
//存放所有棋格
@property(nonatomic,strong)NSMutableArray<TipButton *> * tipArray;
@property(nonatomic,weak)id<GameViewDelegate>delegate;
//进行下子
-(void)setTipIndex:(int)index;
@end
