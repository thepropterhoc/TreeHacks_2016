import numpy as np
import sklearn as sk
import os
import plistlib
import math

"""
@"class" : recording.sampleClassification,
                                     @"interval" : recording.samplingInterval,
                                     @"distance" : recording.sampleDistance,
                                     @"xSamples" : [self xSamplesFromRLMArray:recording.samples],
                                     @"ySamples" : [self ySamplesFromRLMArray:recording.samples],
                                     @"zSamples" : [self zSamplesFromRLMArray:recording.samples]
"""

validSamplingInterval = 0.01  			#Sampling interval we want to consider
validSamplingTime = 10.0 						#Seconds of time we want to slice out of the middle
dataPath = '/Users/shelbyvanhooser/Documents/Programming/TreeHacks_2016/Collected_Data/'
numValidSamples = 0
minSampleLength = 1E5

def collectValidSample(sample):
	global numValidSamples
	global minSampleLength

	sampleLength = len(sample['xSamples'])
	trimSamples = math.floor((sampleLength - 2000) / 2.0)
	exractedXSamples = sample['xSamples'][trimSamples:sampleLength - trimSamples]
	extractedYSamples = sample['ySamples'][trimSamples:sampleLength - trimSamples]
	extractedZSamples = sample['zSamples'][trimSamples:sampleLength - trimSamples]
	

def main():
	global minSampleLength
	for plistfile in [x for x in os.listdir(dataPath) if 'plist' in x]:
		readInPlist = plistlib.readPlist(plistfile)
		if readInPlist["interval"] == 0.01 and not readInPlist["class"] == "Unknown":
			collectValidSample(readInPlist)
	print numValidSamples
	print minSampleLength


if __name__ == '__main__':
	main()