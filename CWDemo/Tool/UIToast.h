//
//  UIToast.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/6.
//  Copyright © 2019年 gsh. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIToast : UILabel


// 显示在当前window 3/4处
+ (void)showMessage:(NSString *)message;

// 显示在当前window 3/4处 offset偏移量
+ (void)showMessage:(NSString *)message offset:(CGFloat)offset;

// 显示在当前window中心
+ (void)showMessageToCenter:(NSString *)message;

// 显示在当前window中心 offset偏移量
+ (void)showMessageToCenter:(NSString *)message offset:(CGFloat)offset;

@end
