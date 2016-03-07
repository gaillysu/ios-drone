//
//  NevoDBHelper.h
//  Nevo
//
//  Created by leiyuncun on 15/8/6.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface NevoDBHelper : NSObject

@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;

+ (NevoDBHelper *)shareInstance;

+ (NSString *)dbPath;

@end
