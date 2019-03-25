//
//  DrawView.m
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "DrawView.h"
#import "MyBezierPath.h"
#import "UIToast.H"

@interface DrawView ()

/**路径颜色*/
@property (nonatomic, strong) UIColor * pColor;
/**路径宽度*/
@property (nonatomic, assign)CGFloat pWidth;
/**path*/
@property (nonatomic, strong) MyBezierPath * myPath;
/**path 数组 用于实时绘制使用*/
@property (nonatomic, strong) NSMutableArray * paths;
/**path 数组 用于存储使用*/
@property (nonatomic, strong) NSMutableArray * savePaths;
///**path 数组*/
//@property (nonatomic, strong) NSArray * pathArr;
/**count*/
@property (nonatomic, assign)int count;
/**开始触摸的时间*/
@property (nonatomic, assign) CFTimeInterval begin;
/**开始录制的时间*/
@property (nonatomic, assign) CFTimeInterval beginRecordingTime;
/**每段path录制的时长*/
@property (nonatomic, assign) CFTimeInterval pathDrawTime;

@end
@implementation DrawView

#pragma mark - lazyLoad
- (NSMutableArray *)paths{
    if (!_paths) {
        _paths =[NSMutableArray array];
    }
    return _paths;
}
- (NSMutableArray *)savePaths{
    if (!_savePaths) {
        _savePaths =[NSMutableArray array];
    }
    return _savePaths;
}

#pragma mark - init
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setUp];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.count =0;
        self.pathDrawTime =0.0;
    }
    return self;
}
- (void)setUp{
    //添加拖拽pan手势用于绘图
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    //设置路径宽度和颜色
    self.pWidth = 1;
    self.pColor = [UIColor blackColor];
}
#pragma mark - set Method
-(void)setImage:(UIImage *)image {
    _image = image;
    
    //添加图片添加到数组当中
    [self.paths addObject:image];
    //重绘
    [self setNeedsDisplay];
}
/**
 *开始录制：画板view开始一些初始化、清0 等开始操作
 */
- (void)startDrawing{
    [self setUp];
    self.beginRecordingTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"进入录制时候的时间：%f",self.beginRecordingTime);
}

/**
 *清屏:清屏就是要移除所有的路径，此时删除大数组中的所有的路径就可以，在调用setNeedsDisplay，进行重绘，此时数组中没有了任何一条路径，所以就会清空上下文
 */
//清屏
- (void)clear {
    //撤销操作，等于是一个特殊的path，其他参数都不设置，把type设置成对应值，播放的时候，只需要判断到是该类型type的时候，把上一个shapelayer移除掉即可，清屏操作一样
    //获取点击撤销动作的时间
    self.begin = CFAbsoluteTimeGetCurrent();
    MyBezierPath *path = [[MyBezierPath alloc] init];
    path.pathType =4;//清楚全部
    path.startDrawTime =(self.begin - self.beginRecordingTime);//每段path的开始绘制时间（相对于从最开始），从第几秒开始
    path.intervalTime =path.startDrawTime - self.myPath.endDrawTime;
    self.myPath = path;
    [self.savePaths addObject:path];
    //清空所有的路径
    [self.paths removeAllObjects];
    //重绘
    [self setNeedsDisplay];
    CFTimeInterval end = CFAbsoluteTimeGetCurrent()+0.02;
    self.pathDrawTime =(end - _begin);
    self.myPath.bDuration =self.pathDrawTime;
    self.myPath.endDrawTime =self.pathDrawTime + self.myPath.startDrawTime;
    NSLog(@"该段path绘制的时长为：%.2f",(end - _begin));
}
/**
 *撤销：即是取出路径数组中的最后一个路径删除，并调用setNeedsDisplay
 */
//撤销
- (void)undo {
    //获取点击撤销动作的时间
    self.begin = CFAbsoluteTimeGetCurrent();
    //撤销操作，等于是一个特殊的path，其他参数都不设置，把type设置成对应值，播放的时候，只需要判断到是该类型type的时候，把上一个shapelayer移除掉即可，清屏操作一样
    MyBezierPath *path = [[MyBezierPath alloc] init];
    path.pathType =3;//撤销
    path.startDrawTime =(self.begin - self.beginRecordingTime);//每段path的开始绘制时间（相对于从最开始），从第几秒开始
    path.intervalTime =path.startDrawTime - self.myPath.endDrawTime;//该path 绘制的时间（间歇时间）=该path 在总的时间中的开始时间 - 上一段path绘制的结束时间；
    self.myPath = path;
    [self.savePaths addObject:path];
    //删除最后一个路径
    [self.paths removeLastObject];
    //重绘
    [self setNeedsDisplay];
    CFTimeInterval end = CFAbsoluteTimeGetCurrent()+0.02;
    self.pathDrawTime =(end - _begin);
    self.myPath.bDuration =self.pathDrawTime;
    self.myPath.endDrawTime =self.pathDrawTime + self.myPath.startDrawTime;
    NSLog(@"该段path绘制的时长为：%.2f",(end - _begin));
}

/**
 *    橡皮擦功能就是：又绘制了一条路径，只是设置路径的颜色为白色，将其他颜色的路径覆盖掉
 */
//保存、停止录制
- (void)finish {
    if (self.delegate && [self.delegate respondsToSelector:@selector(finish:)]) {
        [self.delegate finish:self.savePaths];
    }
//    [self setLineColor:[UIColor whiteColor]];
//    [self setLineWith:30];
}

/**
 *    设置线的宽度
 */
//设置线的宽度
- (void)setLineWith:(CGFloat)lineWidth {
    self.pWidth = lineWidth;
}

//设置线的颜色
/**
 *    设置线的颜色，应该考虑到当没有设置颜色的时候，或传入的参数为空值的时候，所以要考虑以上两点，所以要设置线的默认颜色，一次性设置，在init或是awakefromNib中去设置
 */
- (void)setLineColor:(UIColor *)color {
    self.pColor = color;
}

#pragma mark - Draw + Pan

//手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    
    //获取的当前手指的点
    CGPoint curP = [pan locationInView:self];
    
    if(pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"-- UIGestureRecognizerStateBegan");
        //判断手势的状态
        self.begin = CFAbsoluteTimeGetCurrent();
        //创建路径
        //UIBezierPath *path = [UIBezierPath bezierPath];
        MyBezierPath *path = [[MyBezierPath alloc] init];
        path.pathType =1;
        path.startDrawTime =(self.begin - self.beginRecordingTime);//每段path的开始绘制时间（相对于从最开始），从第几秒开始
        path.intervalTime =path.startDrawTime - self.myPath.endDrawTime;
        NSLog(@"该段path绘制从第：%.2f秒开始",path.startDrawTime);
        //设置起点
        [path moveToPoint:curP];
        //将当前path添加到数组，用于draw方法调用
        [self.paths addObject:path];
        //设置线的宽度
        [path setLineWidth:self.pWidth];
//        //设置线的颜色
        //什么情况下自定义类:当发现系统原始的功能,没有办法瞒足自己需求时,这个时候,要自定义类.继承系统原来的东西.再去添加属性自己的东西.
        path.color = self.pColor;
        path.width =self.pWidth;
        self.myPath = path;
    } else if(pan.state == UIGestureRecognizerStateChanged) {
        //绘制一根线到当前手指所在的点
        [self.myPath addLineToPoint:curP];
        //重绘
        [self setNeedsDisplay];
    } else if (pan.state == UIGestureRecognizerStateEnded){
        NSLog(@"-- UIGestureRecognizerStateEnded");
        CFTimeInterval end = CFAbsoluteTimeGetCurrent();
        self.pathDrawTime =(end - _begin);
        self.myPath.bDuration =self.pathDrawTime;
        self.myPath.endDrawTime =self.pathDrawTime + self.myPath.startDrawTime;
        NSLog(@"该段path绘制的时长为：%.2f",(end - _begin));
        [self.savePaths addObject:self.myPath];
    }
    
}

/**
 * 1：当遍历的时候，若是数组中含有的不只是同一种类型的对象，在遍历的时候可以每个对象指定同一个类型的对象，再根据iskindofclass来判断对象具体是那种类型。
 2：当画图片的时候：直接用image调用[image drawInRect:rect];或是drawpoint
 *
 */
-(void)drawRect:(CGRect)rect {
    
    //绘制保存的所有路径
    for (MyBezierPath *path in self.paths) {
        //判断取出的路径真实类型
        if([path isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)path;
            [image drawInRect:rect];
        }else {
            [path.color set];
            [path stroke];
        }
    }
}
-(void)dealloc{
    NSLog(@"%s",__func__);
}
@end
