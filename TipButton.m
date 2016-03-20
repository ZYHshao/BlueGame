//
//  TipButton.m
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "TipButton.h"

@implementation TipButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatView];
    }
    return self;
}
-(void)creatView{
    //创建横竖两条线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-0.25, 0, 0.5, self.frame.size.height)];
    line1.backgroundColor = [UIColor grayColor];
    [self addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2-0.25, self.frame.size.width, 0.5)];
    line2.backgroundColor = [UIColor grayColor];
    [self addSubview:line2];
}

-(void)dropChess:(BOOL)isMine{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-5, self.frame.size.height/2-5, 10, 10)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 5;
    UIColor * myColor;
    UIColor * otherColor;
    if (_isWhite) {
        myColor = [UIColor whiteColor];
        otherColor = [UIColor blackColor];
    }else{
        myColor = [UIColor blackColor];
        otherColor = [UIColor whiteColor];
    }
    if (isMine) {
        view.backgroundColor = myColor;
        self.hasChess = 1;
    }else{
        view.backgroundColor = otherColor;
        self.hasChess = 2;
    }
    [self addSubview:view];
   
}

@end
