import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  var logger = Logger();

  late Interpreter interpreter;
  late InterpreterOptions interpreterOptions;

  late List<int> inputShape;
  late List<int> outputShape;
  late TfLiteType inputType;
  late TfLiteType outputType;

  late TensorImage inputImage;
  late TensorBuffer probabilityBuffer;
  late int origHeight;
  late int origWidth;

  String get modelName => 'lite-model_movenet_singlepose_thunder_3.tflite';

  Classifier({int? numThreads}) {
    interpreterOptions = InterpreterOptions();
    if (numThreads != null) {
      interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset(modelName, options: interpreterOptions);
      if (kDebugMode) {
        print('Interpreter Created Successfully');
      }

      inputShape = interpreter.getInputTensor(0).shape;
      outputShape = interpreter.getOutputTensor(0).shape;
      inputType = interpreter.getInputTensor(0).type;
      outputType = interpreter.getOutputTensor(0).type;

      probabilityBuffer = TensorBuffer.createFixedSize(outputShape, outputType);

    } catch (e) {
      if (kDebugMode) {
        print('Unable to create interpreter, Caught Exception: ${e.toString()}');
      }
    }
  }

  TensorImage preProcess() {
    int cropSize = math.min(inputImage.height, inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(inputShape[1], inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .build()
        .process(inputImage);
  }

  List predict(Image image) {
    final pres = DateTime.now().millisecondsSinceEpoch;
    inputImage = TensorImage(inputType);
    inputImage.loadImage(image);
    origHeight = inputImage.height;
    origWidth = inputImage.width;
    inputImage = preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;

    if (kDebugMode) {
      print('Time to load image: $pre ms');
    }

    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(inputImage.buffer, probabilityBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;

    if (kDebugMode) {
      print('Time to run inference: $run ms');
    }

    List outputParsed = [];
    List<double> probList = probabilityBuffer.getDoubleList();

    double x, y, c;
    for (var i = 0; i < 51; i += 3) {
      y = (probList[0 + i]);
      x = (probList[1 + i]);
      c = (probList[2 + i]);
      outputParsed.add([x, y, c]);
    }

    if (kDebugMode) {
      for (var result in outputParsed) {
        print(result);
      }
    }
    return [outputParsed, origHeight, origWidth];
  }

  void close() {
    interpreter.close();
  }
}
