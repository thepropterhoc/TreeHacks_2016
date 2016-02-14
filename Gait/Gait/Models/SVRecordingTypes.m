//
//  SVRecordingTypes.m
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#import "SVRecordingTypes.h"


@implementation SVSample

@end

@implementation SVClassifiedRecording

@end

@implementation SVClassifiedFeature

-(instancetype) initClassifiedFeatureWithBulkFeatures:(double *) features validFeatures:(NSArray<NSNumber*>*)validFeatures classLabel:(int) classLabel
{
  self = [super init];
  NSMutableArray *extractedFeatures = [[NSMutableArray alloc] init];
  for (int featureIndex = 0; featureIndex < validFeatures.count; featureIndex++){
    int validFeatureIndex = validFeatures[featureIndex].intValue;
    extractedFeatures[featureIndex] = [NSNumber numberWithDouble:features[validFeatureIndex]];
  }
  self.features = (RLMArray<RLMDouble> *) extractedFeatures;
  
  self.featureClass = (NSNumber<RLMInt> *) [NSNumber numberWithInt:classLabel];
  
  return self;
}

@end