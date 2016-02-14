import numpy as np
import os
import plistlib
import math
import matplotlib.pyplot as plt
import scipy
from sklearn import svm, datasets, feature_selection, cross_validation
from sklearn.cross_validation import StratifiedKFold
from sklearn.feature_selection import RFECV

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
fftWindowLength = 2000
fftWindowDelta = 0
numfftWindows = 1
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
	extractFeatures(extractedXSamples, extractedYSamples, extractedZSamples, sample['class'])

def extractFeatures(xSamples, ySamples, zSamples, label):
	global X
	global Y
	fftwindowBeginning = 0
	features = []
	for windowIndex in range(numfftWindows):
		xTimeSlice = xSamples[fftwindowBeginning: fftwindowBeginning + fftWindowLength]
		xspectrum = np.fft.fft(xTimeSlice, fftWindowLength)
		xspectrum = np.abs(xspectrum[:int(len(xspectrum) / 2.0)])

		yTimeSlice = ySamples[fftwindowBeginning: fftwindowBeginning + fftWindowLength]
		yspectrum = np.fft.fft(xTimeSlice, fftWindowLength)
		yspectrum = np.abs(yspectrum[:int(len(yspectrum) / 2.0)])

		zTimeSlice = zSamples[fftwindowBeginning: fftwindowBeginning + fftWindowLength]
		zspectrum = np.fft.fft(zTimeSlice, fftWindowLength)
		zspectrum = np.abs(zspectrum[:int(len(zspectrum) / 2.0)])

		retval = []
		retval.extend(xspectrum)
		retval.extend(yspectrum)
		retval.extend(zspectrum)
		
		features.extend(retval)

		"""
		plt.plot(np.absolute(spectrum))
		plt.axis([0, fftWindowLength, 0, 20])
		plt.savefig('./images/{0}/{1}/{2}.png'.format(label, fftwindowBeginning, imageIndex))
		plt.clf()
		imageIndex += 1
		"""

		fftwindowBeginning += fftWindowDelta
		#print len(features), len(features[0])
	X += [features]
	Y += [label]



def main():
	global minSampleLength
	global X
	global Y
	for plistfile in [x for x in os.listdir(dataPath) if 'plist' in x]:
		readInPlist = plistlib.readPlist(plistfile)
		if readInPlist["interval"] == 0.01 and not readInPlist["class"] == "Unknown":
			collectValidSample(readInPlist)

	"""
	###############################################################################
	# Create a feature-selection transform and an instance of SVM that we
	# combine together to have an full-blown estimator

	transform = feature_selection.SelectPercentile(feature_selection.f_classif)

	clf = Pipeline([('anova', transform), ('svc', svm.SVC(C=1.0, kernel='rbf', gamma=0.01))])

	###############################################################################
	# Plot the cross-validation score as a function of percentile of features
	score_means = list()
	score_stds = list()
	percentiles = (1, 3, 6, 10, 15, 20, 30, 40, 60, 80, 100)

	for percentile in percentiles:
	    clf.set_params(anova__percentile=percentile)
	    # Compute cross-validation score using all CPUs
	    this_scores = cross_validation.cross_val_score(clf, X, Y, n_jobs=4)
	    score_means.append(this_scores.mean())
	    score_stds.append(this_scores.std())

	plt.errorbar(percentiles, score_means, np.array(score_stds))

	plt.title(
	    'Performance of the SVC rbf kernel classifier (gamma = 0.01), varying the percentile of features selected')
	plt.xlabel('Percentile')
	plt.ylabel('Prediction rate')

	plt.axis('tight')
	plt.show()
	"""

	svc = svm.SVC(C=1.0, kernel="linear")
	# The "accuracy" scoring is proportional to the number of correct
	# classifications
	rfecv = RFECV(estimator=svc, step=1, cv=StratifiedKFold(Y, 2), scoring='accuracy')
	rfecv.fit(X, Y)

	print("Optimal number of features : %d" % rfecv.n_features_)
	print [x for x in xrange(len(rfecv.support_)) if rfecv.support_[x] == True]

	# Plot number of features VS. cross-validation scores
	plt.figure()
	plt.xlabel("Number of features selected")
	plt.ylabel("Cross validation score (nb of correct classifications)")
	plt.plot(range(1, len(rfecv.grid_scores_) + 1), rfecv.grid_scores_)
	plt.show()


if __name__ == '__main__':
	main()