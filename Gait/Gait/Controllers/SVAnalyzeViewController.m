//
//  SVAnalyzeViewController.m
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#import "SVAnalyzeViewController.h"

@interface SVAnalyzeViewController ()

@property (strong, nonatomic) RLMRealm *defaultRealm;
@property (strong, nonatomic) NSArray *selectedFeatures;


@end

@implementation SVAnalyzeViewController

static int sampleLength = 2000;

-(void) viewDidLoad
{
  self.defaultRealm = [RLMRealm defaultRealm];
    //[0, 18, 53, 67, 1000, 1018, 1053, 2037, 2051, 2052, 2069]
  self.selectedFeatures = @[[NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:18],
                            [NSNumber numberWithInt:53],
                            [NSNumber numberWithInt:67],
                            [NSNumber numberWithInt:1000],
                            [NSNumber numberWithInt:1018],
                            [NSNumber numberWithInt:1053],
                            [NSNumber numberWithInt:2037],
                            [NSNumber numberWithInt:2051],
                            [NSNumber numberWithInt:2052],
                            [NSNumber numberWithInt:2069]];
}

-(void) didReceiveMemoryWarning
{
  
}

-(void) transferDatabaseAndExtractFeatures
{
  RLMResults *allRecordings = [SVClassifiedRecording allObjects];
  [self.defaultRealm beginWriteTransaction];
  NSMutableArray *addingObjects = [[NSMutableArray alloc] initWithCapacity:allRecordings.count];
  for (SVClassifiedRecording *classifiedRecording in allRecordings){
    [addingObjects addObject:[self featureForRecording:classifiedRecording]];
  }
  [self.defaultRealm addObjects:addingObjects];
  [self.defaultRealm commitWriteTransaction];
}

-(SVClassifiedFeature *) featureForRecording:(SVClassifiedRecording *) recording
{
  NSArray<NSNumber *> *fullSpectrum = [self extractFullSpectrum:recording];
  double * castedFullspectrum = calloc(sizeof(double), fullSpectrum.count);
  for (int index = 0; index < fullSpectrum.count; index++){
    castedFullspectrum[index] = fullSpectrum[index].doubleValue;
  }
  int classNumber = 0;
  if([recording.sampleClassification isEqualToString:@"Good"]){
    classNumber = 0;
  } else {
    classNumber = 1;
  }
  
  SVClassifiedFeature *classifiedFeature = [[SVClassifiedFeature alloc] initClassifiedFeatureWithBulkFeatures:castedFullspectrum validFeatures:self.selectedFeatures classLabel:classNumber];
  return classifiedFeature;
}

-(NSArray<NSNumber *> *) extractFullSpectrum:(SVClassifiedRecording *) recording
{
 
  int seekForward = (int) floor((recording.samples.count - 2000) / 2.0);
  NSMutableArray *timeSlice = [[NSMutableArray alloc] initWithCapacity:sampleLength];
  for(int at = 0; at < sampleLength; at++){
    timeSlice[at] = recording.samples[at + seekForward];
  }
                    
  
  int ln = log2f(timeSlice.count);
  int n = 1 << ln;
  int fullPadN = n * 2;
  
  double *xSamples = calloc(sizeof(double), fullPadN);
  double *xZeros = calloc(sizeof(double), fullPadN);
  
  double *ySamples = calloc(sizeof(double), fullPadN);
  double *yZeros = calloc(sizeof(double), fullPadN);
  
  double *zSamples = calloc(sizeof(double), fullPadN);
  double *zZeros = calloc(sizeof(double), fullPadN);
  
  
  
  DSPDoubleSplitComplex *xCombined = calloc(sizeof(DSPDoubleSplitComplex), fullPadN);
  DSPDoubleSplitComplex *yCombined = calloc(sizeof(DSPDoubleSplitComplex), fullPadN);
  DSPDoubleSplitComplex *zCombined = calloc(sizeof(DSPDoubleSplitComplex), fullPadN);
  
  
  for (int index = 0; index < fullPadN; index++){
    SVSample *currentSample = timeSlice[index];
    xSamples[index] = currentSample.xSample;
    ySamples[index] = currentSample.ySample;
    zSamples[index] = currentSample.zSample;
  }
  
  xCombined->realp = xSamples;
  xCombined->imagp = xZeros;
  
  yCombined->realp = ySamples;
  yCombined->imagp = yZeros;
  
  zCombined->realp = zSamples;
  zCombined->imagp = zZeros;
  
  ln = log2f(fullPadN);
  n = 1 << ln;
  
  int nOver2 = n/2;
  
  DSPDoubleSplitComplex A;
  A.realp = (double *)malloc(sizeof(double) * nOver2);
  A.imagp = (double *)malloc(sizeof(double) * nOver2);
  
  
  
  
  FFTSetupD setup = vDSP_create_fftsetupD(ln, FFT_RADIX2);
  
  
  
  
    double *xSpectrum = vDSP_fft_zriptD(setup, <#const DSPDoubleSplitComplex * _Nonnull __C#>, <#vDSP_Stride __IC#>, <#const DSPDoubleSplitComplex * _Nonnull __Buffer#>, <#vDSP_Length __Log2N#>, <#FFTDirection __Direction#>)
  
}



@end
