import numpy as np
import os
import plistlib
import math
import matplotlib.pyplot as plt
import scipy
from sklearn import svm, datasets, feature_selection, cross_validation
from sklearn.pipeline import Pipeline

validSamplingInterval = 0.01  			#Sampling interval we want to consider
validSamplingTime = 10.0 						#Seconds of time we want to slice out of the middle
dataPath = '/Users/shelbyvanhooser/Documents/Programming/TreeHacks_2016/Collected_Data/'
numValidSamples = 0
minSampleLength = 1E5
fftWindowLength = 500
fftWindowDelta = 1000
numfftWindows = 2
imageIndex = 0
X = []
Y = []

def collectValidSample(sample):
	global numValidSamples
	global minSampleLength

	sampleLength = len(sample['xSamples'])
	trimSamples = int(math.floor((sampleLength - 2000) / 2.0))
	extractedXSamples = sample['xSamples'][trimSamples:sampleLength - trimSamples]
	extractedYSamples = sample['ySamples'][trimSamples:sampleLength - trimSamples]
	extractedZSamples = sample['zSamples'][trimSamples:sampleLength - trimSamples]
	
	plt.plot(extractedXSamples)
	plt.title(sample['class'])
	plt.show()

def main():
	global minSampleLength
	global X
	global Y
	for plistfile in [x for x in os.listdir(dataPath) if 'plist' in x]:
		readInPlist = plistlib.readPlist(plistfile)
		if readInPlist["interval"] == 0.01 and not readInPlist["class"] == "Unknown":
			collectValidSample(readInPlist)

if __name__ == '__main__':
	main()