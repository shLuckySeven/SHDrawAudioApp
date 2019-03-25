//
//  PlayViewController.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/7.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayViewController : UIViewController

/**path 数组 用于存储使用*/
@property (nonatomic, strong) NSArray * paths;

/**音频文件路径*/
@property (nonatomic, copy) NSString * filePath;
@end

NS_ASSUME_NONNULL_END
