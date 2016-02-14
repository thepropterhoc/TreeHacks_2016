//
//  SVRecordingViewController.m
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#import "SVRecordingViewController.h"
#import <AudioToolbox/AudioToolbox.h>


@interface SVRecordingViewController ()

@property (strong, nonatomic) RLMRealm *defaultRealm;

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) CMMotionManager *motMan;
@property (strong, nonatomic) JPSVolumeButtonHandler *handler;

@property BOOL recordingAvailable;

@property double * xSamples;
@property double * ySamples;
@property double * zSamples;

@property int sampleIndex;

@property (strong, nonatomic) NSArray * intervalOptions;
@property (strong, nonatomic) NSArray * walkingLengthOptions;
@property (weak, nonatomic) IBOutlet UIPickerView *samplingIntervalPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *recordingDistancePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gaitQualitySegmentedControl;

@property (strong, nonatomic) NSNumber *selectedInterval;
@property (strong, nonatomic) NSString *selectedClass;
@property (strong, nonatomic) NSNumber *selectedRecordingDistance;

@property (strong, nonatomic) UIView * grayOverlay;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation SVRecordingViewController

static int MAX_RECORDING_SAMPLES = (int) ((1.0 / 0.01) * 200.0);

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  
  self.defaultRealm = [RLMRealm defaultRealm];
  NSLog(@"%@", self.defaultRealm.path);
  
  [self doPickerSetup];
  
  self.recordingAvailable = NO;
  
  
  self.handler = [JPSVolumeButtonHandler volumeButtonHandlerWithUpBlock:^{
    
    int selectedIntervalRowIndex = (int) [self.samplingIntervalPicker selectedRowInComponent:0];
    double selectedInterval = ((NSNumber *) self.intervalOptions[selectedIntervalRowIndex]).doubleValue;
    
    self.selectedInterval = [NSNumber numberWithDouble:selectedInterval];
    
    int selectedDistanceRowIndex = (int) [self.recordingDistancePicker selectedRowInComponent:0];
    double selectedDistance = ((NSNumber *) self.walkingLengthOptions[selectedDistanceRowIndex]).doubleValue;
    self.selectedRecordingDistance = [NSNumber numberWithDouble:selectedDistance];
    
    self.selectedClass = [self.gaitQualitySegmentedControl titleForSegmentAtIndex:self.gaitQualitySegmentedControl.selectedSegmentIndex];
    
    [self beginLoggingWithInterval:selectedInterval];
    
    
    
    
    [self.view setUserInteractionEnabled:NO];
    
    if (!self.grayOverlay){
      self.grayOverlay = [[UIView alloc] initWithFrame:self.view.frame];
      [self.grayOverlay setBackgroundColor:[UIColor grayColor]];
      [self.grayOverlay setAlpha:0.5];
      self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.grayOverlay.frame];
    }
    
    [self.view.superview addSubview:self.grayOverlay];
    [self.view.superview addSubview:self.activityIndicator];
    [self.view.superview bringSubviewToFront:self.grayOverlay];
    [self.view.superview bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.navigationController setNavigationBarHidden:YES];
    
    
    
    NSLog(@"Beginning new recording");
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
  } downBlock:^{
    [self.motMan stopAccelerometerUpdates];
    
     // Create realm pointing to default file
    
      // Save your object
    
    if(self.recordingAvailable){
      
      [self.defaultRealm beginWriteTransaction];
      SVClassifiedRecording *newRecording = [[SVClassifiedRecording alloc] init];
      
      
  
      newRecording.samples = [self createSampleArray];
        //@property NSNumber *samplingInterval;
        //@property NSString *sampleClassification;
        //@property NSNumber *sampleDistance;
      
      newRecording.samplingInterval = self.selectedInterval;
      newRecording.sampleClassification = self.selectedClass;
      newRecording.sampleDistance = self.selectedRecordingDistance;
      
      
      
      [self.defaultRealm addObject:newRecording];
      [self.defaultRealm commitWriteTransaction];
      
      
      [self clearSamples];
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
      
      NSLog(@"Added new recording");
      NSLog(@"Now have %d recordings", (int) [SVClassifiedRecording allObjects].count);
      [self.grayOverlay removeFromSuperview];
      [self.activityIndicator removeFromSuperview];
      [self.view setUserInteractionEnabled:YES];
      [self.activityIndicator stopAnimating];
      [self.navigationController setNavigationBarHidden:NO];
    }
    
  }];
  
  
}

-(void) doPickerSetup
{
  NSMutableArray *walkingLengthOptions = [[NSMutableArray alloc] init];
  for (int index = 1; index < 15; index ++) {
    NSNumber *currentWalkingLength = [NSNumber numberWithInt:index * 10];
    walkingLengthOptions[index - 1] = currentWalkingLength;
  }
  
  self.walkingLengthOptions = (NSArray *) walkingLengthOptions;
  
  NSMutableArray *intervalOptions = [[NSMutableArray alloc] init];
  
  intervalOptions[0] = [NSNumber numberWithDouble:0.01];
  intervalOptions[1] = [NSNumber numberWithDouble:0.05];
  intervalOptions[2] = [NSNumber numberWithDouble:0.1];
  
  self.intervalOptions = (NSArray *) intervalOptions;
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Logging Methods

-(void) beginLoggingWithInterval:(double) recordingInterval
{
  
  self.recordingAvailable = YES;
  
  self.xSamples = calloc(sizeof(double), MAX_RECORDING_SAMPLES);
  self.ySamples = calloc(sizeof(double), MAX_RECORDING_SAMPLES);
  self.zSamples = calloc(sizeof(double), MAX_RECORDING_SAMPLES);
  
  
  self.motMan = [[CMMotionManager alloc] init];
  self.operationQueue = [NSOperationQueue mainQueue];
  
  [self.motMan setAccelerometerUpdateInterval:0.01];
  
  [self.motMan startAccelerometerUpdatesToQueue:self.operationQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
    CMAcceleration acceleration = accelerometerData.acceleration;
    if(self.recordingAvailable) {
      self.xSamples[self.sampleIndex] = acceleration.x;
      self.ySamples[self.sampleIndex] = acceleration.y;
      self.zSamples[self.sampleIndex] = acceleration.z;
      
      self.sampleIndex++;
      if(self.sampleIndex > MAX_RECORDING_SAMPLES){
        [self.motMan stopAccelerometerUpdates];
        NSLog(@"Max recording length reached");
        [self clearSamples];
      }
    } else {
      [self.motMan stopAccelerometerUpdates];
    }
  }];
  
}

-(RLMArray<SVSample>* ) createSampleArray
{
  NSMutableArray *retval = [[NSMutableArray alloc] initWithCapacity:self.sampleIndex-1];
  for (int index = 0; index < self.sampleIndex-1; index++){
    SVSample *sample = [[SVSample alloc] init];
    sample.xSample = self.xSamples[index];
    sample.ySample = self.ySamples[index];
    sample.zSample = self.zSamples[index];
    retval[index] = sample;
  }
  return (RLMArray<SVSample> *) retval;
}

-(NSArray*) castToArrayOfNSNumber:(double*) samples sampleLength:(int) sampleLength
{
  NSMutableArray *retval = [[NSMutableArray alloc] initWithCapacity:sampleLength];
  for (int idx = 0; idx < sampleLength; idx++){
    retval[idx] = [[NSNumber alloc] initWithDouble:samples[idx]];
  }
  return (NSArray*) retval;
}

-(void) clearSamples
{
  self.recordingAvailable = NO;
  free(self.xSamples);
  free(self.ySamples);
  free(self.zSamples);
  self.sampleIndex = 0;
}



#pragma mark - PickerView Delegate Methods

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *) pickerView
{
  return 1;
}

-(NSInteger) pickerView:(UIPickerView *) pickerView numberOfRowsInComponent:(NSInteger) component
{
  switch (pickerView.tag) {
    case 0:
      return self.intervalOptions.count;
      break;
    case 1:
      return self.walkingLengthOptions.count;
      break;
    default:
      return 0;
      break;
  }
}


-(NSString*) pickerView:(UIPickerView *) pickerView titleForRow:(NSInteger) row forComponent:(NSInteger) component
{
  switch (pickerView.tag) {
    case 0:
      return [NSString stringWithFormat:@"%.f ms", ((NSNumber *) self.intervalOptions[row]).doubleValue * 1000];
      break;
    case 1:
      return [NSString stringWithFormat:@"%.f feet", ((NSNumber *) self.walkingLengthOptions[row]).doubleValue];
      break;
    default:
      return @"N/A";
      break;
  }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
