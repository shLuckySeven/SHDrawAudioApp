//
//  UIToast.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/6.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import "UIToast.h"

#define UIToastContentFont     [UIFont systemFontOfSize:16]
#define UIToastTextColor       [UIColor colorWithRed:255/255.0 green:254/255.0  blue:254/255.0 alpha:1]
#define UIToastBackgroundColor [UIColor colorWithRed:50./255.0 green:50./255.0  blue:50./255.0  alpha:1]
#define UIToastPadding          10   //吐司内四周间距padding
#define UIToastLeftMargin       15   //吐司距离屏幕左右间距 margin
#define UIToastLineSpacing      4   //行间距

//多久消失
#define UIToastDuration          1.7f
#define UIToastAnimationDuration 0.3f

// 屏幕尺寸
#define UIToastSCREEN_W    ([UIScreen mainScreen].bounds.size.width)
#define UIToastSCREEN_H    ([UIScreen mainScreen].bounds.size.height)

@interface UIToast ()

@property(nonatomic, assign) BOOL isAdd;
@property(nonatomic, assign) BOOL completed;
@property (nonatomic ,assign)BOOL isHaveOne;//标记当前是否已经有一个

@end
@implementation UIToast


+ (instancetype)shareInstance {
    return [[self alloc] init];
}

//+ (id)allocWithZone:(struct _NSZone *)zone {
//  static id instance;
//  static dispatch_once_t token;
//  dispatch_once(&token, ^{
//    instance = [super allocWithZone:zone];
//  });
//  return instance;
//}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.numberOfLines = 0;
        self.backgroundColor =UIToastBackgroundColor;
        self.font = UIToastContentFont;
        self.layer.cornerRadius = 7.0f;
        self.layer.masksToBounds = YES;
        self.textColor = UIToastTextColor;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (id)initWithMessage:(NSString *)message  withY:(CGFloat)y
{
    if (self) {
        CGSize msg_size = [UIToast stringSizeWith:message];
        CGFloat msg_x = (UIToastSCREEN_W - (msg_size.width + 2*UIToastPadding)) / 2;
        self.frame = CGRectMake(msg_x, y, msg_size.width + 2 * UIToastPadding,
                                msg_size.height + 2 * UIToastPadding);
        
        [self setText:message lineSpacing:UIToastLineSpacing];
    }
    return self;
}
- (void)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing
{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [text length])];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:self.lineBreakMode];
    [paragraphStyle setAlignment:self.textAlignment];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    [attributedString addAttribute:NSBaselineOffsetAttributeName value:@0 range:NSMakeRange(0, [text length])];
    self.attributedText = attributedString;
 
}

#pragma mark - message显示到3/4处
+ (void)showMessage:(NSString *)message
{
    [self showMessage:message offset:0];
}

+(void)showMessage:(NSString *)message offset:(CGFloat)offset
{
    CGFloat msg_y = UIToastSCREEN_H * 3 / 4+offset;
    [self showMessage:message withY:msg_y];
}

#pragma mark - 显示到中心
+(void)showMessageToCenter:(NSString *)message
{
    
    [self showMessageToCenter:message offset:0];
}

+(void)showMessageToCenter:(NSString *)message offset:(CGFloat)offset
{
    CGSize  msg_size = [self stringSizeWith:message];
    CGFloat height =msg_size.height+2*UIToastPadding;
    [self showMessage:message withY :([UIScreen mainScreen].bounds.size.height-height)/2+offset];
    
}
#pragma mark - 根据 Y 显示 message
+ (void)showMessage:(NSString *)message  withY:(CGFloat)y{
    
    if (message.length<=0) {
        return;
    }
    UIToast *toast = [[UIToast shareInstance] initWithMessage:message withY:y];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    
    [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIToast class]]) {
            [obj removeFromSuperview];
            obj.alpha=0;
            [obj.layer removeAllAnimations];
            *stop=YES;
        }
    }];
    
    [toast show];
}
- (void)show {
    if (self.isHaveOne) {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self];
    self.alpha = 0;
    [UIView animateWithDuration:UIToastAnimationDuration
                     animations:^{
                         
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.isHaveOne =YES;
                         [self addAnimation];
                     }];
}

- (void)addAnimation {
    //10个字显示1.7秒
    NSInteger length=self.text.length;
    CGFloat time= (length*0.17>1.7?length*0.17:1.7);
    [UIView animateWithDuration:UIToastAnimationDuration
                          delay:time
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         self.isHaveOne =NO;
                     }];
}

+ (CGSize)stringSizeWith:(NSString *)string
{
    
    if (string.length<=0) {
        return  CGSizeZero;
    }
    NSMutableAttributedString *attributedString =[[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle =
    [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:UIToastLineSpacing];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, string.length)];
    [attributedString addAttribute:NSFontAttributeName
                             value:UIToastContentFont
                             range:NSMakeRange(0, string.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:UIToastTextColor
                             range:NSMakeRange(0, string.length)];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary
                                       dictionaryWithObjectsAndKeys:UIToastContentFont, NSFontAttributeName, paragraphStyle,
                                       NSParagraphStyleAttributeName,@0, NSBaselineOffsetAttributeName,nil];
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(UIToastSCREEN_W - 2 * UIToastPadding-2*UIToastLeftMargin, 200)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:dictionary
                                     context:nil].size;
    
    
    // 如果只有一行文字则去掉行高
    if (size.height - UIToastContentFont.lineHeight <= paragraphStyle.lineSpacing) {
        if ([self containsChinese:string]) {
            size.height=size.height - paragraphStyle.lineSpacing;
            return  size;
        }
    }
    return size;
}
// 判断是否包含中文字符
+ (BOOL)containsChinese:(NSString *)string {
    for (int i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        if (c >0x4E00 && c <0x9FFF) {
            return YES;
        }
    }
    return NO;
}
/*   距离左几个单位，距离上几个单位*/
-(void)drawTextInRect:(CGRect)rect{
    CGRect frame = CGRectMake(rect.origin.x + UIToastPadding, rect.origin.y+UIToastPadding , rect.size.width -2*UIToastPadding, rect.size.height-2*UIToastPadding );
    [super drawTextInRect:frame];
}

@end

