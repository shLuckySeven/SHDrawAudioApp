//
//  PlayAnimationClass.m
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "PlayAnimationClass.h"
#import "MyBezierPath.h"

@interface PlayAnimationClass ()<CAAnimationDelegate>

/**count*/
@property (nonatomic, assign)int count;
/**UIBezierPath*/
@property (nonatomic, strong) MyBezierPath * bzPath;
/**动画对象*/
@property (nonatomic, strong) CABasicAnimation *animation;
/**上一个path的结束时间*/
@property (nonatomic, assign)CFTimeInterval prevEndTime;
/**数组*/
@property (nonatomic, strong) NSArray * paths;
/**Layer*/
@property (nonatomic, weak) CALayer * sLayer;

/**用来保存上一个绘制的layer，为了处理撤销操作用*/
@property (nonatomic, weak) CAShapeLayer * lastLayer;
/**已添加的path*/
@property (nonatomic, strong) NSMutableArray * havePaths;

@end
@implementation PlayAnimationClass

#pragma mark - lazyLoad
- (NSMutableArray *)havePaths{
    if (!_havePaths) {
        _havePaths =[NSMutableArray array];
    }
    return _havePaths;
}
//创建贝塞尔曲线
- (MyBezierPath *)bzPath{
    if (!_bzPath) {
        _bzPath =[MyBezierPath bezierPath];
    }
    return _bzPath;
}
//创建动画对象
- (CABasicAnimation *)animation{
    if (!_animation) {
        _animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _animation.delegate =self;
        _animation.fromValue = @(0.0);
        _animation.toValue = @(1.0);
        _animation.removedOnCompletion =NO;
        _animation.fillMode = kCAFillModeBackwards;
    }
    return _animation;
}
//提供外部调用，相当于初始化
- (void)playBezierPath:(NSArray *)paths superLayer:(CALayer *)superLayer{
    if (self.sLayer) {
        [self.sLayer removeAllAnimations];
        [self.sLayer removeFromSuperlayer];
    }
    self.count =0;
    self.paths =paths;
    self.sLayer =superLayer;//把superLayer从外部传参进来
    // 创建贝塞尔路径~从保存的路径数组里取，第一次，只取第一条
    MyBezierPath * path =[paths objectAtIndex:0];
    [self animation:path];
}
//创建的内部调用动画绘制方法，会多次调用
- (void)animation:(MyBezierPath *)path{
    self.bzPath =path;

    CAShapeLayer *shapeLayer =[CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    // 关联layer和贝塞尔路径~以及color和lineWidth属性
    shapeLayer.lineWidth =self.bzPath.lineWidth;
    shapeLayer.strokeColor = self.bzPath.color.CGColor;
    shapeLayer.path = self.bzPath.CGPath;
    self.lastLayer =shapeLayer;
    [self.sLayer addSublayer:shapeLayer];
    [self.havePaths addObject:shapeLayer];

    //此处处理动画时间（上一个动画和下一个动画的间隔播放问题）
    CFTimeInterval bTime =CACurrentMediaTime() + self.bzPath.intervalTime ;
    self.animation.duration = self.bzPath.bDuration;//这个属性，要用外界传进来的，这是每条path执行的动画时长
    self.animation.beginTime =path.pathType ==1?bTime:0.0;//这个属性用来控制本次动画的开始时间，它的值
    NSLog(@"该段动画执行时长为：%f,path类型为：%d",path.bDuration,path.pathType);

    //因为有N多个path，也就有N多个动画要执行，每个都是单独的动画和对象，所以这里用下标存储成key，每次animation对象往layer层上添加之前，都先把之前的动画移除掉
    NSString * key =[NSString stringWithFormat:@"key%d",self.count];
    // 设置layer的animation
    [shapeLayer removeAnimationForKey:key];
    [shapeLayer addAnimation:self.animation forKey:nil];
}
#pragma mark --- Animation Delegate
//动画停止
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //此处判断动画是否正常执行完毕，若结束，则执行以下操作，调用下一个path开始绘制
    if (flag) {
        //如果一个动画（path）执行完毕，则count ++；
        self.count ++;
        //判断c所有path是否全部执行完毕，防止数组越界
        if (self.count >= self.paths.count) {
            NSLog(@"播放放完毕！！！！！");
            self.animation =nil;
            self.bzPath =nil;
            return;
        }
        MyBezierPath * path =[self.paths objectAtIndex:self.count];
        if (path.pathType ==3) {//如果是撤销操作
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(path.intervalTime *NSEC_PER_SEC)),dispatch_get_main_queue(),^{
                if (self.lastLayer) {
                    [self.lastLayer removeFromSuperlayer];
                    [self.lastLayer removeAllAnimations];
                }
                [self animation:path];
            });
        }else if (path.pathType ==4){//如果是清除全部的操作
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(path.intervalTime *NSEC_PER_SEC)),dispatch_get_main_queue(),^{
                if (self.sLayer && self.havePaths) {
                    for (CAShapeLayer * layer in self.havePaths) {
                        [layer removeFromSuperlayer];
                        [layer removeAllAnimations];
                    }
                    [self animation:path];
                }
            });
        }
        else{//否则才是普通绘制
            [self animation:path];
        }
    }
}
//- (void)removeHandle:(NSNumber *)number{
//    int ii = [number intValue];
//    if (ii ==3) {
//        if (self.lastLayer) {
//            [self.lastLayer removeFromSuperlayer];
//            [self.lastLayer removeAllAnimations];
//        }
//    }else if (ii ==4){
//        if (self.sLayer && self.havePaths) {
//            for (CAShapeLayer * layer in self.havePaths) {
//                [layer removeFromSuperlayer];
//                [layer removeAllAnimations];
//            }
//        }
//    }
//}
#pragma mark - dealloc
-(void)dealloc{
    NSLog(@"%s",__func__);
}

@end
