# TreeHacks 2016

[![Join the chat at https://gitter.im/thepropterhoc/TreeHacks_2016](https://badges.gitter.im/thepropterhoc/TreeHacks_2016.svg)](https://gitter.im/thepropterhoc/TreeHacks_2016?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)  

Diagnosing walking disorders with accelerometers and machine learning

Author : _Shelby Vanhooser_

___
### Goals

  - Log data of walking behavior for a known distance through a smartphone
  - Using nothing but an accelerometer on the smartphone, characterize walking behaviors as _good_ or _bad_ (classification)
  - Collect enough meaningful data to distinguish between these two classes, and draw inferences about them 

___
### Technologies

  - Wireless headphone triggering of sampling
  - Adjustable frequency for logging
  - Internal database for collection
  - Support Vector Machine (machine learning classification)

  Over the course of the weekend, I was able to test the logging abilities of the app by taking my own phone outside, placing it in my pocket after selecting the desired sampling frequency and distance I would be walking (verified by Google Maps), and triggering its logging using my wireless headphones.  This way, I made sure I was not influencing any data collected by having abnormal movements be recorded as I placed it in my pocket. 
  
  

___
### Data

*Good* 

![Good walking behavior frequency spectrum](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/images/good_animated.gif)

*Bad*

![Bad walking behavior frequency spectrum](https://raw.githubusercontent.com/thepropterhoc/TreeHacks_2016/master/Collected_Data/images/bad_animated.gif)





___
### Results