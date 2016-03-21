//
//  TipButton.h
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipButton : UIButton
//标记此瓦片是否已经落子 0 空 1 己方落子 2 敌方落子
@property(nonatomic,assign)int hasChess;
//落子 BOOL类型的参数 决定是己方还是敌方
-(void)dropChess:(BOOL)isMine;
//设置白子或者黑子
@property(nonatomic,assign)BOOL isWhite;
//瓦片编号
@property(nonatomic,assign)int index;
@end
