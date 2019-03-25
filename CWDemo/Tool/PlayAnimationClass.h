//
//  PlayAnimationClass.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayAnimationClass : NSObject

/**
 * 提供外部调用
 * paths: 保存的path路径对象数组
 * superLayer : 要添加的layer
 */
- (void)playBezierPath:(NSArray *)paths superLayer:(CALayer *)superLayer;
@end

NS_ASSUME_NONNULL_END
