//
//  BlueToothTool.m
//  BlueGame
//
//  Created by apple on 16/3/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "BlueToothTool.h"
@implementation BlueToothTool
{
    //外设管理中心
    CBPeripheralManager * _peripheralManager;
    //外设提供的服务
    CBMutableService * _ser;
    //服务提供的读特征值
    CBMutableCharacteristic * _readChara;
    //服务提供的写特征值
    CBMutableCharacteristic * _writeChara;
    //等待对方加入的提示视图
    UIView * _waitOtherView;
    //正在扫描附近游戏的提示视图
    UIView * _searchGameView;
    //设备中心管理对象
    CBCentralManager * _centerManger;
    //要连接的外设
    CBPeripheral * _peripheral;
    //要交互的外设属性
    CBCharacteristic * _centerReadChara;
    CBCharacteristic * _centerWriteChara;
    void(^block)(BOOL first);
}
//实现单例方法
+(instancetype)sharedManager{
    static BlueToothTool *tool = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        tool = [[self alloc] init];
    });
    return tool;
}
//实现创建游戏的方法
-(void)setUpGame:(NSString *)name block:(void (^)(BOOL))finish{
    block = [finish copy];
    if (_peripheralManager==nil) {
        //初始化服务
         _ser= [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"] primary:YES];
        //初始化特征
        _readChara = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        _writeChara = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00068"] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
        //向服务中添加特征
        _ser.characteristics = @[_readChara,_writeChara];
        _peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    }
    //设置为房主
    _isCentral=YES;
    //开始广播广告
    [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:@"WUZIGame"}];
}
//外设检测蓝牙状态
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    //判断是否可用
    if (peripheral.state==CBPeripheralManagerStatePoweredOn) {
        //添加服务
        [_peripheralManager addService:_ser];
        //开始广播广告
        [_peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey:@"WUZIGame"}];
    }else{
        //弹提示框
        dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert];
        });
    }
}
//开始放广告的回调
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (_waitOtherView==nil) {
        _waitOtherView = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, 240, 200, 100)];
        dispatch_async(dispatch_get_main_queue(), ^{
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"等待附近玩家加入";
        [_waitOtherView addSubview:label];
        _waitOtherView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            [[[UIApplication sharedApplication].delegate window]addSubview:_waitOtherView];
        });

    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_waitOtherView removeFromSuperview];
            [[[UIApplication sharedApplication].delegate window]addSubview:_waitOtherView];
        });
    }
}


//添加服务后回调的方法
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"添加服务失败");
    }
    NSLog(@"添加服务成功");
}

//中心设备订阅特征值时回调
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    [_peripheralManager stopAdvertising];
    if (_isCentral) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请选择先手后手" delegate:self cancelButtonTitle:@"我先手" otherButtonTitles:@"我后手", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_waitOtherView removeFromSuperview];
            [alert show];
        });
    }
}
//收到写消息后的回调
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate getData:[[NSString alloc]initWithData:requests.firstObject.value encoding:NSUTF8StringEncoding]];
    });
}
//弹提示框的方法
-(void)showAlert{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请确保您的蓝牙可用" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    [alert show];
}
//===============================================================
-(void)searchGame{
    if (_centerManger==nil) {
        _centerManger = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    }else{
        [_centerManger scanForPeripheralsWithServices:nil options:nil];
        if (_searchGameView==nil) {
            _searchGameView = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, 240, 200, 100)];
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"正在扫加入描附近游戏";
            _searchGameView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            [_searchGameView addSubview:label];
            [[[UIApplication sharedApplication].delegate window]addSubview:_searchGameView];
        }else{
            [_searchGameView removeFromSuperview];
            [[[UIApplication sharedApplication].delegate window]addSubview:_searchGameView];
        }
    }
    //设置为游戏加入方
    _isCentral = NO;
}
//设备硬件检测状态回调的方法 可用后开始扫描设备
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (_centerManger.state==CBCentralManagerStatePoweredOn) {
        [_centerManger scanForPeripheralsWithServices:nil options:nil];
        if (_searchGameView==nil) {
             dispatch_async(dispatch_get_main_queue(), ^{
            _searchGameView = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, 240, 200, 100)];
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"正在扫加入描附近游戏";
            _searchGameView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            [_searchGameView addSubview:label];
                 [[[UIApplication sharedApplication].delegate window]addSubview:_searchGameView];
             });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_searchGameView removeFromSuperview];
                [[[UIApplication sharedApplication].delegate window]addSubview:_searchGameView];
            });
        }
    }else{
         dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert];
         });
    }
}
//发现外设后调用的方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //获取设备的名称 或者广告中的相应字段来配对
    NSString * name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ([name isEqualToString:@"WUZIGame"]) {
        //保存此设备
        _peripheral = peripheral;
        //进行连接
        [_centerManger connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
    }
}
//连接外设成功的回调
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接成功");
    //设置代理与搜索外设中的服务
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
     dispatch_async(dispatch_get_main_queue(), ^{
         [_searchGameView removeFromSuperview];
     });
}
//连接断开
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接断开");
    [_centerManger connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
}
//发现服务后回调的方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services)
    {
        //发现服务 比较服务的UUID
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"]])
        {
            NSLog(@"Service found with UUID: %@", service.UUID);
            //查找服务中的特征值
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
        
    }
}
//开发服务中的特征值后回调的方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //发现特征 比较特征值得UUID 来获取所需要的
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00067"]]) {
            //保存特征值
            _centerReadChara = characteristic;
            //监听特征值
            [_peripheral setNotifyValue:YES forCharacteristic:_centerReadChara];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"68753A44-4D6F-1226-9C60-0050E4C00068"]]) {
            //保存特征值
            _centerWriteChara = characteristic;
        }
    }
}
//所监听的特征值更新时回调的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //更新接收到的数据
    NSLog(@"%@",[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    //要在主线程中刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate getData:[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]];
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //告诉开发者先后手信息
    if (buttonIndex==0) {
        if (_isCentral) {
            block(1);
        }else{
            block(0);
        }
    }else{
        if (_isCentral) {
            block(0);
        }else{
            block(1);
        }
    }
}
//断开连接
-(void)disConnect{
    if (!_isCentral) {
        [_centerManger cancelPeripheralConnection:_peripheral];
      [_peripheral setNotifyValue:NO forCharacteristic:_centerReadChara];
    }
}
//写数据
-(void)writeData:(NSString *)data{
    if (_isCentral) {
        [_peripheralManager updateValue:[data dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_readChara onSubscribedCentrals:nil];
    }else{
        [_peripheral writeValue:[data dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_centerWriteChara type:CBCharacteristicWriteWithoutResponse];
    }
}

@end
