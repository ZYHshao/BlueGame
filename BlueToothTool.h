//
//  BlueToothTool.h
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
@protocol BlueToothToolDelegate <NSObject>
//获取对方数据
-(void)getData:(NSString *)data;

@end

@interface BlueToothTool : NSObject<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate>
+(instancetype)sharedManager;
/**
 *断块连接
 */
-(void)disConnect;
/*
 *建立游戏房间
 */
-(void)setUpGame:(NSString *)name block:(void(^)(BOOL first))finish;
/*
 *查找附近的游戏
 */
-(void)searchGame;
@property(nonatomic,weak)id<BlueToothToolDelegate>delegate;
-(void)writeData:(NSString *)data;
//标记是否是房主
@property(nonatomic,assign)BOOL isCentral;
@end
