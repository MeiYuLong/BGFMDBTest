//
//  PersonModel.h
//  BGTest
//
//  Created by 梅YL on 2018/2/5.
//  Copyright © 2018年 梅YL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGFMDB.h"
@interface PersonModel : NSObject

@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) NSInteger age;
@property (nonatomic,copy) NSString *sex;
@property (nonatomic,copy) NSString *sexxx;

@property (nonatomic,copy) NSString *desc;
//@property (nonatomic,assign) BOOL yesOrNO;
@end
