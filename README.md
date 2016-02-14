# Gait @ TreeHacks 2016

[![Join the chat at https://gitter.im/thepropterhoc/TreeHacks_2016](https://badges.gitter.im/thepropterhoc/TreeHacks_2016.svg)](https://gitter.im/thepropterhoc/TreeHacks_2016?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)  

Diagnosing walking disorders with accelerometers and machine learning

**Based on the original work of Dr. Matt Smuck**

![Walking correctly](https://d30y9cdsu7xlg0.cloudfront.net/png/79275-200.png)

Author : _Shelby Vanhooser_  
Mentor : _Dr. Matt Smuck_

___
### Goals

***Can we diagnose patient walking disorders?***

  - Log data of walking behavior for a known distance through a smartphone
  - Using nothing but an accelerometer on the smartphone, characterize walking behaviors as _good_ or _bad_ (classification)
  - Collect enough meaningful data to distinguish between these two classes, and draw inferences about them 

___
### Technologies

  - Wireless headphone triggering of sampling
  - Signal processing of collected data
  - Internal database for storing collection
  - Support Vector Machine (machine learning classification)

  -> Over the course of the weekend, I was able to test the logging abilities of the app by taking my own phone outside, placing it in my pocket after selecting the desired sampling frequency and distance I would be walking (verified by Google Maps), and triggering its logging using my wireless headphones.  This way, I made sure I was not influencing any data collected by having abnormal movements be recorded as I placed it in my pocket. 
  
  ***_Main screen of app I designed_***
  ![Landing screen](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Screenshots/Screenshot_2.png)
  
  ***_The logging in action_***
  ![The logging app in action](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Screenshots/Screenshot_1.png)
  
  
  -> This way, we can go into the field, collect data from walking, and log if this behavior is 'good' or 'bad' so we can tell the difference on new data!

___
### Data

First, let us observe the time-domain samples recorded from the accelerometer: 

![Raw signal recorded](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/Time_Domain.png)

It is immediately possible to see where my steps were! Very nice. Let's look at what the spectrums are like after we take the FFT...

_Frequency Spectrums of good walking behavior_
![Good walking behavior frequency spectrum](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/images/good_animated.gif)

_Frequency spectrums of bad walking behavior_
![Bad walking behavior frequency spectrum](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/images/bad_animated.gif)

19 'correct' walking samples and 5 'incorrect' samples were collected around the grounds of Stanford across reasonably flat ground with no obstacle interference.

***Let's now take these spectrums and use them as features for a machine learning classification problem***

-> Additionally, I ran numerous simulations to see what kernel in SVM would give the best output prediction accuracy: 

**How many features do we need to get good prediction ability?**

_Linear kernel_
![ROC-like characterization](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/Linear_SVM_2000_Sample_FFT.png)

**Look at that characterization for so few features!**

Moving right along...

_Quadratic kernel_
![ROC-like characterization](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/Quadratic_SVM_2000_Sample_FFT.png)

Not as good as linear.  What about cubic? 

_Cubic kernel_
![ROC-like characterization](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/Cubic_SVM_2000_Sample_FFT.png)

Conclusion: We can get 100% cross-validated accuracy with...
***A linear kernel***

Good to know.  We can therefore predict on incoming patient data if their gait is problematic!

___
### Results

  - From analysis of the data, its structure seems to be well-defined at several key points in the spectrum.  That is, after feature selection was run on the collected samples, 11 frequencies were identified as dominating its behavior: 

  **[0, 18, 53, 67, 1000, 1018, 1053, 2037, 2051, 2052, 2069]**



**_Note_** : it is curious that index 0 has been selected here, implying that the overall angle of an accelerometer on the body while walking has influence over the observed 'correctness' of gait 

  - From these initial results it is clear we _can_ characterize 'correctness' of walking behavior using a smartphone application! 
  - In the future, it would seem very reasonable to have a patient download an application such as this, and, using a set of known walking types from measurements taken in the field, be able to diagnose and report to an unknown patient if they have a disorder in gait.


___
### Acknowledgments 

  - __Special thanks to Dr. Matt Smuck for his original work and aid in pushing this project in the correct direction__

  - __Special thanks to [Realm](https://realm.io) for their amazing database software__

  - __Special thanks to [JP Simard](https://cocoapods.org/?q=volume%20button) for his amazing code to detect volume changes for triggering this application__

  - __Special thanks to everyone who developed [Libsvm](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) and for writing it in C so I could compile it in iOS__


