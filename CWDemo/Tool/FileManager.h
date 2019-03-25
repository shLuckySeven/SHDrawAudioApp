//
//  AppDelegate.h
//  CWDemo
//
//  Created by gaoshuhuan on 2019/3/6.
//  Copyright © 2019年 gsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (FileManager*)manager;

+ (NSString*)getFilePathWithPathComponent: (NSString*)pathComponent;

- (NSInteger)getFileSizeWithFilePath: (NSString*)filePath;

- (BOOL)createAudiosFolder;

- (void)deleteFileWithPath: (NSString*)filePath;

- (BOOL)isFileExistsAtPath: (NSString*)filePath;

- (NSMutableArray*)getAllSubFilePathFromDirectory: (NSString*)dirPath;

@end
