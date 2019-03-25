//
//  MyBezierPath.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyBezierPath : UIBezierPath

/**颜色*/
@property (nonatomic, strong) UIColor * color;

/**画笔宽度*/
@property (nonatomic, assign) CGFloat width;

/**path 开始绘制时间*/
@property (nonatomic, assign) CFTimeInterval startDrawTime;

/**path 结束绘制时间*/
@property (nonatomic, assign) CFTimeInterval endDrawTime;

/**该段path持续的时长*/
@property (nonatomic, assign) CFTimeInterval bDuration;

/**该段path距离上一个path绘制结束的时长*/
@property (nonatomic, assign) CFTimeInterval intervalTime;

/**path类型,保留字段，暂无用，也可写成一个枚举值
 * type:  1:普通绘制线  2:擦除操作  3:撤销操作  4:全部清除动作  5:图片插入操作  ……
 * 可根据type类型，知道该段path是什么操作
 */
@property (nonatomic, assign) int pathType;

@end

NS_ASSUME_NONNULL_END
