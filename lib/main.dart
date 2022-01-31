// import 'dart:html';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ml_kit_demo/CameraCapture.dart';
import 'package:ml_kit_demo/CameraScreen.dart';
// import 'package:image/image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String processedText = "Processed Text: ";
  Image? image;
  Rect? box;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("ML text recognition"),
          ),
          body: Container(
            // width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        processedText = "Processed Text: ";
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        File file = File(result!.files.single.path!);
                        image = Image.file(file);

                        var inputImage =
                            InputImage.fromFilePath(result.files.first.path!);

                        final textDetector = GoogleMlKit.vision.textDetector();
                        final faceDetector = GoogleMlKit.vision.faceDetector();

                        final RecognisedText recognisedText =
                            await textDetector.processImage(inputImage);
                        final List<Face> faces =
                            await faceDetector.processImage(inputImage);
                        print("FACE DONE!!!!!!!!!!!!");

                        /// Extracting Text
                        String text = recognisedText.text;
                        for (TextBlock block in recognisedText.blocks) {
                          final Rect rect = block.rect;
                          final List<Offset> cornerPoints = block.cornerPoints;
                          final String text = block.text;
                          final List<String> languages =
                              block.recognizedLanguages;

                          for (TextLine line in block.lines) {
                            // Same getters as TextBlock
                            processedText = processedText + line.text + " \n";
                            for (TextElement element in line.elements) {
                              // Same getters as TextBlock
                            }
                          }

                          /// Extracting Faces
                          for (Face face in faces) {
                            final Rect boundingBox = face.boundingBox;
                            box = boundingBox;
                            print(boundingBox);

                            //   final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
                            //   final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

                            // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
                            // eyes, cheeks, and nose available):
                            // final FaceLandmark? leftEar = face.getLandmark(FaceLandmarkType.leftEar);
                            // if (leftEar != null) {
                            //   final Point<double> leftEarPos = leftEar.position as Point<double>;
                            // }

                            // If classification was enabled with FaceDetectorOptions:
                            // if (face.smilingProbability != null) {
                            //   final double? smileProb = face.smilingProbability;
                            // }

                            // If face tracking was enabled with FaceDetectorOptions:
                            // if (face.trackingId != null) {
                            //   final int? id = face.trackingId;
                            // }
                          }
                          setState(() {});
                        }
                      },
                      child: Container(child: Text("Pick Image")),
                    ),
                    ElevatedButton(
                      child: Text('Camera'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen()),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: Text("Camera 2"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraCapture(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // width: MediaQuery.of(context).size.width,
                      child: Text(
                        "$processedText",
                        style: TextStyle(),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      child: image,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
