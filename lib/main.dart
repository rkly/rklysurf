import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rklysurf/classifier.dart';
import 'package:logger/logger.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var logger = Logger();

  late Classifier classifier;

  File? imageFile;
  final picker = ImagePicker();
  late Image imageWidget;

  List? results;
  late int imageHeight;
  late int imageWidth;

  @override
  void initState() {
    super.initState();
    classifier = Classifier(numThreads: 4);
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);
    imageWidget = Image.file(imageFile!);

    var res = await _predict();

    setState(() {
      results = res[0];
      imageHeight = res[1];
      imageWidth = res[2];
    });
  }

  Future<dynamic> _predict() async {
    img.Image imageInput = img.decodeImage(imageFile!.readAsBytesSync())!;
    return classifier.predict(imageInput);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('rklysurf',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: imageFile == null
                ? const Text('No image selected.')
                : Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 2),
                      decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: CustomPaint(
                      foregroundPainter:
                        RenderLines(results!, imageHeight, imageWidth),
                      child:
                        Container(
                            child: imageWidget,
                        ),
                    )
                ),
          ),
          Text(
            results != null ? '[x, y, probability]:' : '',
            style: const TextStyle(fontSize: 16),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: results != null ? results!.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(results != null ? results![index].toString() : '')
                  );
                }
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class RenderLines extends CustomPainter {
  late List inferenceList;
  late int _height;
  late int _width;

  // CORRECT POSTURE COLOR PROFILE
  var point_green = Paint()
    ..color = Colors.green
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 8;
  var edge_green = Paint()
    ..color = Colors.lightGreen
    ..strokeWidth = 5;

  // INCORRECT POSTURE COLOR PROFILE
  var point_red = Paint()
    ..color = Colors.red
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 8;
  var edge_red = Paint()
    ..color = Colors.orange
    ..strokeWidth = 5;

  List<Offset> points_green = [];
  List<Offset> points_red = [];

  List<dynamic> edges = [
    [0, 1], // nose to left_eye
    [0, 2], // nose to right_eye
    [1, 3], // left_eye to left_ear
    [2, 4], // right_eye to right_ear
    [0, 5], // nose to left_shoulder
    [0, 6], // nose to right_shoulder
    [5, 7], // left_shoulder to left_elbow
    [7, 9], // left_elbow to left_wrist
    [6, 8], // right_shoulder to right_elbow
    [8, 10], // right_elbow to right_wrist
    [5, 6], // left_shoulder to right_shoulder
    [5, 11], // left_shoulder to left_hip
    [6, 12], // right_shoulder to right_hip
    [11, 12], // left_hip to right_hip
    [11, 13], // left_hip to left_knee
    [13, 15], // left_knee to left_ankle
    [12, 14], // right_hip to right_knee
    [14, 16] // right_knee to right_ankle
  ];

  RenderLines(List inferences, int height, int width) {
    inferenceList = inferences;
    _height = height;
    _width = width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    renderEdge(canvas, size);
    canvas.drawPoints(PointMode.points, points_green, point_green);
    canvas.drawPoints(PointMode.points, points_red, point_red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void renderEdge(Canvas canvas, Size size) {
    if (size.isEmpty) { return; }
    double ratioH = _height / _width;
    double ratioW = _width / _height;
    double shiftH;
    double shiftW;
    if (kDebugMode) {
      print("ratioH $ratioH");
      print("ratioW $ratioW");
      print("height $_height $size.height");
      print("width $_width $size.width");
    }

    if (_height > _width && ratioH > 1) {
      shiftH = (size.height - size.width) * ratioW - 10;
      shiftW = 0.0;
      ratioH = 1 * ratioW;
      ratioW = size.height / size.width * ratioW;
    } else if (_height < _width && ratioW > 1) {
      shiftH = 0.0;
      shiftW = (size.width - size.height) * ratioH - 10;
      ratioW = 1 * ratioH;
      ratioH = size.width / size.height * ratioH;
    } else {
      shiftH = 0.0;
      shiftW = 0.0;
      ratioW = 1;
      ratioH = 1;
    }

    for (List<int> edge in edges) {
      double vertex1X = inferenceList[edge[0]][0].toDouble() * size.height * ratioH + shiftW;
      double vertex1Y = inferenceList[edge[0]][1].toDouble() * size.height * ratioH + shiftH;
      double vertex2X = inferenceList[edge[1]][0].toDouble() * size.width * ratioW + shiftW;
      double vertex2Y = inferenceList[edge[1]][1].toDouble() * size.width * ratioW + shiftH;
      canvas.drawLine(Offset(vertex1X, vertex1Y), Offset(vertex2X, vertex2Y),
          inferenceList[edge[0]][2] > 0.4 && inferenceList[edge[1]][2] > 0.4 ?
          edge_green : edge_red);
    }

    for (List<dynamic> point in inferenceList) {
      if (point[2] > 0.40) {
        print(point[0].toDouble() * size.width * ratioW);
        points_green.add(
            Offset(point[0].toDouble() * size.width * ratioW + shiftW,
                point[1].toDouble() * size.height * ratioH + shiftH)
        );
      } else {
        points_red.add(
            Offset(point[0].toDouble() * size.height * ratioH + shiftW,
                point[1].toDouble() * size.width * ratioW + shiftH)
        );
      }
    }
  }
}
