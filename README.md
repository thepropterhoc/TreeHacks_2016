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

___
### Data

First, let us observe the time-domain samples recorded: 

![Raw signal recorded](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/Time_Domain.png)

It is immediately possible to see where my steps were! Very nice. Let's look at what the spectrums are though after we take the FFT...

_Frequency Spectrums of good walking behavior_
![Good walking behavior frequency spectrum](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/images/good_animated.gif)

_Frequency spectrums of bad walking behavior_
![Bad walking behavior frequency spectrum](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/images/bad_animated.gif)

19 'correct' walking samples and 5 'incorrect' samples were collected around the grounds of Stanford across reasonably flat ground with no obstacle interference.

Additionally, I ran numerous simulations to see what kernel in SVM would give the best output prediction accuracy: 

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

___
### Results

From analysis of the data, its structure seems to be well-defined at several key points in the spectrum.  That is, after feature selection was run on the collected samples, 11 frequencies were identified as dominating its behavior: 

**[0, 18, 53, 67, 1000, 1018, 1053, 2037, 2051, 2052, 2069]**



**_Note_** : it is curious that index 0 has been selected here, implying that the overall angle of an accelerometer on the body while walking has influence over the observed 'correctness' of gait 





