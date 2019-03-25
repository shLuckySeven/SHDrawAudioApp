//
//  DrawView.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SaveFinishDelegate <NSObject>
@optional
- (void)finish:(NSArray *)array;

@end
@interface DrawView : UIView

/**完成代理*/
@property (nonatomic,weak) id <SaveFinishDelegate> delegate;

//开始绘制
- (void)startDrawing;
//清屏
- (void)clear;
//撤销
- (void)undo;
//完成（停止）
- (void)finish;

//设置线的宽度
- (void)setLineWith:(CGFloat)lineWidth;
//设置线的颜色
- (void)setLineColor:(UIColor *)color;

/** 要绘制的图片 */
@property (nonatomic, strong) UIImage * image;
@end

NS_ASSUME_NONNULL_END
