//
//  SVRecordingTypes.h
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#ifndef SVRecordingTypes_h
#define SVRecordingTypes_h


#import <Realm/Realm.h>

@interface SVSample : RLMObject
@property double xSample;
@property double ySample;
@property double zSample;
@end

RLM_ARRAY_TYPE(SVSample);

@interface SVClassifiedRecording : RLMObject
@property RLMArray<SVSample> *samples;
@property NSNumber<RLMDouble> *samplingInterval;
@property NSString *sampleClassification;
@property NSNumber<RLMDouble> *sampleDistance;
@end


RLM_ARRAY_TYPE(SVClassifiedRecording);

@interface SVClassifiedFeature : RLMObject
@property RLMArray<RLMDouble> *features;
@property NSNumber<RLMInt> *featureClass;

-(instancetype) initClassifiedFeatureWithBulkFeatures:(double *) features validFeatures:(NSArray<NSNumber*>*)validFeatures classLabel:(int) classLabel;

@end

RLM_ARRAY_TYPE(SVClassifiedFeature);

#endif /* SVRecordingTypes_h */