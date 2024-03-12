## rklysurf - Pose Classifier 🏄‍♂️📸

This project utilizes TensorFlow Lite along with the tflite_flutter package to classify surfing poses in a series of pictures. The classifier is based on the MoveNet model, renowned for its high speed and accuracy in detecting human body keypoints. By analyzing the keypoints extracted from surfing pictures, the app determines the specific position of the surfer.
The goal of this project was to utilize TensorFlow Lite execution within the Flutter framework.
📚 For detailed information about the MoveNet model, please refer to the official TensorFlow Hub tutorial.

Once the app is running on your device, it will prompt you to select a series of surfing pictures. The app will then utilize the embedded TensorFlow Lite model, along with tflite_flutter, to classify the surfing poses depicted in the pictures. Results will be displayed, indicating the position of the surfer in each image. Additionally, the app will show all the coordinates of keypoints along with their classification probabilities for further analysis.
