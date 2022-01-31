import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraCapture extends StatefulWidget {
  const CameraCapture({Key? key}) : super(key: key);

  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {

  final textDetector = GoogleMlKit.vision.textDetector();

  CameraDescription? cameraDesc;
  CameraController? _camera;
  late Future<void> _initializeControllerFuture;
  bool stopLoop = false;
  bool cameraFutureInitialized = false;
  XFile? result;
  int count = 0;

  /// ML Variables
  InputImage? inputImage;
  RecognisedText? recognisedText;

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
      enableAudio: false,
    );
    // _camera!.setFocusMode(FocusMode.auto);
    _initializeControllerFuture = _camera!.initialize();
    cameraFutureInitialized = true;
    setState(() {

    });
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
            cameraFutureInitialized ?
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.85,
              child: FutureBuilder(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.done){
                      return Container(child: CameraPreview(_camera!));

                    }
                    else{
                      return const Center(child: CircularProgressIndicator(),);
                    }
                  }),
            ):Container(),
            Container(
              child: ElevatedButton(
                child: Text("Scan"),
                onPressed: () async {
                  await _initializeControllerFuture;
                  DateTime tick = DateTime.now();
                  while(true){
                    if(stopLoop == true){
                      break;
                    }
                    try{
                      tick = DateTime.now();
                      if(_camera!.value.isTakingPicture == false || _camera!.value.isInitialized == true || _camera!.value.hasError == false){
                        result = await _camera!.takePicture();
                      }
                      else{
                        print("WeeWoo: TakingPicture or not Initialized or Error");
                        if(_camera!.value.hasError == true){
                          _camera = CameraController(
                            cameraDesc!,
                            ResolutionPreset.high,
                          );
                          _camera!.initialize();
                          result = await _camera!.takePicture();
                        }
                      }

                      inputImage =
                      InputImage.fromFilePath(result!.path);


                      recognisedText =
                      await textDetector.processImage(inputImage!);
                      String text = recognisedText!.text;

                      final duration = DateTime.now().difference(tick).inMilliseconds;
                      print("Duration(ms): " + duration.toString());
                      print("Processed Text:" + text);
                      count = count + 1;
                      if(count > 20){
                        _camera!.dispose();
                        await _camera!.initialize();
                      }
                      print("Count: " + count.toString());

                      sleep(Duration(seconds: 1));


                    }catch(e){
                      print("WeeWoo: Errored on try statement");
                      _camera = CameraController(
                        cameraDesc!,
                        ResolutionPreset.high,
                      );
                      _camera!.initialize();
                      print(e);
                    }

                  }
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
