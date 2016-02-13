//
//  SVRecordingTypes.h
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#ifndef SVRecordingTypes_h
#define SVRecordingTypes_h


#endif /* SVRecordingTypes_h */

#import <Realm/Realm.h>

@interface SVSample : RLMObject
@property double xSample;
@property double ySample;
@property double zSample;
@end

@implementation SVSample

@end

RLM_ARRAY_TYPE(SVSample);


@interface SVClassifiedRecording : RLMObject
@property RLMArray<SVSample> *samples;
@property NSNumber<RLMDouble> *samplingInterval;
@property NSString *sampleClassification;
@property NSNumber<RLMDouble> *sampleDistance;
@end


@implementation SVClassifiedRecording

@end


RLM_ARRAY_TYPE(SVClassifiedRecording);

