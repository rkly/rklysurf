## rklysurf - Pose Classifier 🏄‍♂️📸

### About 📝
This project utilizes `TensorFlow Lite` along with the `tflite_flutter` package to classify surfing poses in a series of pictures.  
The classifier is based on the [MoveNet](https://www.tensorflow.org/hub/tutorials/movenet) model, renowned for its high speed and accuracy in detecting human body keypoints. By analyzing the keypoints extracted from surfing pictures, the app determines the specific position of the surfer.

### References 🔖
The goal of this project was to utilize TensorFlow Lite execution within the [Flutter](https://flutter.dev/) framework 🔧.  
For detailed information about the MoveNet model, please refer to the official [documentation](https://www.tensorflow.org/hub/tutorials/movenet)📚.

### Functionality 🛠️
Once the app is running on your device, it will prompt you to select a series of surfing pictures. The app will then utilize the embedded TensorFlow Lite model, along with `tflite_flutter`, to classify the surfing poses depicted in the pictures. Results will be displayed, indicating the position of the surfer in each image. Additionally, the app will show all the coordinates of keypoints along with their classification probabilities for further analysis.

### Home screen
<img src="https://github.com/rkly/rklysurf/assets/17988496/1b851016-6283-4ab2-8f65-48661b1ace35" height="500">

### Runned recognition
<img src="https://github.com/rkly/rklysurf/assets/17988496/730ba1c0-2c62-4d79-b531-76b004330f31" height="500">
<img src="https://github.com/rkly/rklysurf/assets/17988496/5cae048c-b4dc-43e4-a6aa-fdf30c9e3b8c" height="500">
