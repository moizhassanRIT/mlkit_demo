import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final textDetector = GoogleMlKit.vision.textDetector();

  CameraDescription? cameraDesc;
  CameraController? _camera;
  late Future<void> _initializeControllerFuture;
  bool stopLoop = false;
  bool cameraFutureInitialized = false;
  XFile? result;
  int count = 0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    final cameras = await availableCameras();
    cameraDesc = cameras.first;
    _camera = CameraController(
      cameraDesc!,
      ResolutionPreset.high,
    );
    _camera!.setFocusMode(FocusMode.auto);
    _initializeControllerFuture = _camera!.initialize();
    cameraFutureInitialized = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera 2"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            cameraFutureInitialized
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: FutureBuilder(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(_camera!);
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                  )
                : Container(),
            Container(
              child: ElevatedButton(
                child: Text("Scan"),
                onPressed: () async {
                  await _initializeControllerFuture;
                  DateTime tick = DateTime.now();
                  // while(true){
                  //   if(stopLoop == true){
                  //     break;
                  //   }
                  //   try{
                  //     tick = DateTime.now();
                  //
                  //     result = await _camera!.takePicture();
                  //     var inputImage =
                  //     InputImage.fromFilePath(result!.path);
                  //
                  //
                  //     final RecognisedText recognisedText =
                  //     await textDetector.processImage(inputImage);
                  //     String text = recognisedText.text;
                  //     final duration = DateTime.now().difference(tick).inMilliseconds;
                  //     print("Duration(ms): " + duration.toString());
                  //     print("Processed Text:" + text);
                  //     count = count + 1;
                  //     print("Count: " + count.toString());
                  //
                  //
                  //   }catch(e){
                  //     print(e);
                  //   }
                  //
                  // }
                  _camera!.startImageStream((cameraImage) async{
                    final WriteBuffer allBytes = WriteBuffer();
                    for (Plane plane in cameraImage.planes) {
                      allBytes.putUint8List(plane.bytes);
                    }
                    final bytes = allBytes.done().buffer.asUint8List();

                    final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

                    final InputImageRotation imageRotation =
                        // InputImageRotationMethods.fromRawValue(_camera!.sensorOrientation) ??
                            InputImageRotation.Rotation_0deg;

                    final InputImageFormat inputImageFormat =
                        InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
                            InputImageFormat.NV21;

                    final planeData = cameraImage.planes.map(
                          (Plane plane) {
                        return InputImagePlaneMetadata(
                          bytesPerRow: plane.bytesPerRow,
                          height: plane.height,
                          width: plane.width,
                        );
                      },
                    ).toList();

                    final inputImageData = InputImageData(
                      size: imageSize,
                      imageRotation: imageRotation,
                      inputImageFormat: inputImageFormat,
                      planeData: planeData,
                    );

                    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
                    // var inputImage = InputImage.fromFilePath(result!.path);

                    final RecognisedText recognisedText =
                        await textDetector.processImage(inputImage);
                    String text = recognisedText.text;
                    final duration =
                        DateTime.now().difference(tick).inMilliseconds;
                    print("Duration(ms): " + duration.toString());
                    print("Processed Text:" + text);
                    count = count + 1;
                    print("Count: " + count.toString());
                  });
                  // final tick = DateTime.now();
                  // final result = await _camera!.takePicture();
                  // var inputImage =
                  // InputImage.fromFilePath(result.path);
                  //
                  // final textDetector = GoogleMlKit.vision.textDetector();
                  // final RecognisedText recognisedText =
                  // await textDetector.processImage(inputImage);
                  // String text = recognisedText.text;
                  // final duration = DateTime.now().difference(tick).inMilliseconds;
                  // print("Duration(ms): " + duration.toString());
                  // print("Processed Text:" + text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stopLoop = false;
    _camera!.dispose();
    super.dispose();
  }
}
