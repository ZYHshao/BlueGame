//
//  BlueToothTool.h
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BlueToothToolDelegate <NSObject>
//获取对方数据
-(void)getData:(NSString *)data;

@end

@interface BlueToothTool : NSObject<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate>
//代理
@property(nonatomic,weak)id<BlueToothToolDelegate>delegate;
//标记是否是房主
@property(nonatomic,assign)BOOL isCentral;
/**
 *获取单例对象的方法
 */
+(instancetype)sharedManager;
/*
 *作为游戏的房主建立游戏房间
 */
-(void)setUpGame:(NSString *)name block:(void(^)(BOOL first))finish;
/*
 *作为游戏的加入者查找附近的游戏
 */
-(void)searchGame;
/**
 *断块连接
 */
-(void)disConnect;
/*
 *进行写数据操作
 */
-(void)writeData:(NSString *)data;
@end
