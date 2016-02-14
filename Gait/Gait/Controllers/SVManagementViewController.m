//
//  SVManagementViewController.m
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#import "SVManagementViewController.h"

@interface SVManagementViewController ()

@property (strong, nonatomic) RLMRealm *defaultRealm;

@end

@implementation SVManagementViewController

-(void) viewDidLoad
{
  [super viewDidLoad];
  self.defaultRealm = [RLMRealm defaultRealm];
}

-(void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(IBAction) exportDatabase:(id)sender
{
  NSString *defaultPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
  for (SVClassifiedRecording *recording in [SVClassifiedRecording allObjects]){
    NSString *savePath = [defaultPath stringByAppendingString:[NSString stringWithFormat:@"%@.plist", [NSUUID UUID].UUIDString]];
    
    NSDictionary *saveDictionary = @{@"class" : recording.sampleClassification,
                                     @"interval" : recording.samplingInterval,
                                     @"distance" : recording.sampleDistance,
                                     @"xSamples" : [self xSamplesFromRLMArray:recording.samples],
                                     @"ySamples" : [self ySamplesFromRLMArray:recording.samples],
                                     @"zSamples" : [self zSamplesFromRLMArray:recording.samples]};
    [saveDictionary writeToFile:savePath atomically:NO];
  }
  NSLog(@"Saved database");
}


-(NSArray *) xSamplesFromRLMArray:(RLMArray<SVSample> *)ary
{
  NSMutableArray *retval = [[NSMutableArray alloc] initWithCapacity:ary.count];
  int at = 0;
  for(SVSample* s in ary){
    retval[at] = [NSNumber numberWithDouble:s.xSample];
  }
  return (NSArray *) retval;
}

-(NSArray *) ySamplesFromRLMArray:(RLMArray<SVSample> *) ary
{
  NSMutableArray *retval = [[NSMutableArray alloc] initWithCapacity:ary.count];
  int at = 0;
  for(SVSample* s in ary){
    retval[at] = [NSNumber numberWithDouble:s.ySample];
  }
  return (NSArray *) retval;
}

-(NSArray *) zSamplesFromRLMArray:(RLMArray<SVSample> *) ary
{
  NSMutableArray *retval = [[NSMutableArray alloc] initWithCapacity:ary.count];
  int at = 0;
  for(SVSample* s in ary){
    retval[at] = [NSNumber numberWithDouble:s.zSample];
  }
  return (NSArray *) retval;
}



-(IBAction) nukeDatabase:(id)sender
{
  [self.defaultRealm beginWriteTransaction];
  [self.defaultRealm deleteAllObjects];
  [self.defaultRealm commitWriteTransaction];
  
}

@end
