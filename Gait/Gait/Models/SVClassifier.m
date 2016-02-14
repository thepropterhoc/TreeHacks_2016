//
//  SVClassifier.m
//  Gait
//
//  Created by Shelby Vanhooser on 2/13/16.
//  Copyright © 2016 Shelby Vanhooser. All rights reserved.
//

#import "SVClassifier.h"

@interface SVClassifier ()

@property (strong, nonatomic) RLMRealm *defaultRealm;
@property struct svm_model *trainedWalkingModel;

@property struct svm_problem *baseWalkingProblem;

@end

@implementation SVClassifier

static double cache_size = 50.0;

+(instancetype) sharedInstance
{
  static SVClassifier *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[SVClassifier alloc] init];
    sharedInstance.defaultRealm = [RLMRealm defaultRealm];
  });
  return sharedInstance;
}


#pragma mark - Training Methods

-(struct svm_parameter*) paramsWithKernelType:(int)kernelType{
  struct svm_parameter* params;
  RLMResults *samples = [SVClassifiedFeature allObjects];
  SVClassifiedFeature *result = samples.firstObject;
  switch (kernelType) {
    case 0:
      params = [self linearParameterWithNumFeatures:result.features.count];
      break;
    case 1:
      params = [self quadraticParameterWithNumFeatures:result.features.count];
      break;
    case 2:
      params = [self gaussianParameterWithNumFeatures:result.features.count];
      break;
    default:
      break;
  }
  return params;
}

-(struct svm_model*) trainWithParams:(struct svm_parameter*)params baseProblem:(struct svm_problem*) baseProblem
{
  
  
  const char *msg = svm_check_parameter(baseProblem, params);
  if (!msg){
    NSLog(@"Problem is ready");
  } else {
    NSData *message = [NSData dataWithBytes:msg length:sizeof(msg)];
    NSLog(@"Problem is not ready : %@", message);
  }
  return svm_train(baseProblem, params);
}

-(void) trainWalkingWithKernelType:(int)kernelType
{
  self.baseWalkingProblem = [self baseProblemWithClassKey:@"featureClass"];
  struct svm_parameter *params = [self paramsWithKernelType:kernelType];
  self.trainedWalkingModel = [self trainWithParams:params baseProblem:self.baseWalkingProblem];
  free(params);
}


#pragma mark - Prediction Methods


-(double) predictWalkingOnSample:(SVClassifiedFeature*) sample
{
  if (!self.trainedWalkingModel){
    [self trainWalkingWithKernelType:0];
  }
  struct svm_node * nodeArray = [self sampleToNodeArray:sample];
  double predicted = svm_predict(self.trainedWalkingModel, nodeArray);
  free(nodeArray);
  return predicted;
  
}

#pragma mark - Parameter Creation Methods

-(struct svm_parameter*) linearParameterWithNumFeatures:(int)numFeatures
{
  struct svm_parameter *linearParameters = [self basePolynomialParameterWithNumFeatures:numFeatures];
  linearParameters->degree = 1;
  return linearParameters;
}

-(struct svm_parameter*) quadraticParameterWithNumFeatures:(int)numFeatures
{
  struct svm_parameter *quadParameters = [self basePolynomialParameterWithNumFeatures:(int)numFeatures];
  quadParameters->degree = 2;
  return quadParameters;
}

-(struct svm_parameter*) basePolynomialParameterWithNumFeatures:(int)numFeatures
{
  struct svm_parameter *baseParameters = [self bareParameterWithNumFeatures:numFeatures];
  baseParameters->kernel_type = 1;
  baseParameters->coef0 = 1.0;
  return baseParameters;
}

-(struct svm_parameter*) gaussianParameterWithNumFeatures:(int)numFeatures
{
  struct svm_parameter *baseParameters = [self bareParameterWithNumFeatures:numFeatures];
  baseParameters->gamma = 0.01;
  baseParameters->kernel_type = 2;
  return baseParameters;
}

-(struct svm_parameter *) bareParameterWithNumFeatures:(int)numFeatures
{
  struct svm_parameter *bareParameter = malloc(sizeof(struct svm_parameter));
  int binaryWeightLabels[6] = {1, 1, 1, 1, 1, 1};
  bareParameter->cache_size = cache_size;
  bareParameter->gamma = 1.0 / (double) numFeatures;
  bareParameter->kernel_type = 2;
  bareParameter->C = 1.0;
  bareParameter->nu = 0.5;
  bareParameter->degree = 3;
  bareParameter->coef0 = 0.0;
  bareParameter->svm_type = 0;
  bareParameter->eps = 0.00001;
  bareParameter->p = 0.1;
  bareParameter->shrinking = 1;
  bareParameter->probability = 0;
  bareParameter->nr_weight = 0;
  bareParameter->weight_label = binaryWeightLabels;
  return bareParameter;
}


#pragma mark - Problem Creation Methods

-(struct svm_problem*) baseProblemWithClassKey:(NSString*)key
{
  struct svm_problem *base = malloc(sizeof(struct svm_problem));
  RLMResults *results = [SVClassifiedFeature allObjectsInRealm:self.defaultRealm];
  int numSamples = (int) results.count;
  
  struct svm_node ** nodes;
  nodes = (struct svm_node **) malloc(sizeof(struct svm_node*) * numSamples);
  double * labels = malloc(sizeof(double) * numSamples);
  for (int markedSampleIndex = 0; markedSampleIndex < numSamples; markedSampleIndex++){
    SVClassifiedFeature *classifiedFeature = results[markedSampleIndex];
    struct svm_node *sample = [self markedSampleToNodeArray:classifiedFeature];
    nodes[markedSampleIndex] = sample;
    double extractedLabel = ((NSNumber *) [classifiedFeature valueForKey:key]).doubleValue;
    labels[markedSampleIndex] = extractedLabel;
  }
  base->x = nodes;
  base->y = (double *) labels;
  base->l = numSamples;
  return base;
}


#pragma mark - Sample to SVM Node

-(struct svm_node*) markedSampleToNodeArray:(SVClassifiedFeature *)classifiedFeature
{
  return [self sampleToNodeArray:classifiedFeature];
}



-(struct svm_node*) sampleToNodeArray:(SVClassifiedFeature *)classifiedFeature
{
  RLMArray<RLMDouble> *features = classifiedFeature.features;
  struct svm_node * sample = malloc(sizeof(struct svm_node) * (features.count + 1));
  
  for (int featureIndex = 0; featureIndex < features.count; featureIndex++){
    struct svm_node *newNode = malloc(sizeof(struct svm_node));
    newNode->index = featureIndex;
    
    newNode->value = ((NSNumber *) features[featureIndex]).doubleValue;
    sample[featureIndex] = *newNode;
  }
  struct svm_node * endingNode = malloc(sizeof(struct svm_node));
  endingNode->index = -1;
  sample[features.count] = *endingNode;
  return sample;
}


#pragma mark - Model Clobbering Methods

-(void) freeTrainedModels
{
  free(self.trainedWalkingModel);
  
  free(self.baseWalkingProblem);
  
  self.trainedWalkingModel = NULL;
}


@end
