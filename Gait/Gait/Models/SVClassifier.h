//
//  SVClassifier.h
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libsvm/libsvm.h>
#import <Realm/Realm.h>
#import "SVRecordingTypes.h"

@interface SVClassifier : NSObject

+(instancetype) sharedInstance;

-(void) trainClassifierWithKernelType:(int) kernelType;

@end
