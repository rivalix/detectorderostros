import 'package:appfacedetector/Utils/FaceDetectorPainter.dart';
import 'package:appfacedetector/Utils/UtilsScanner.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraController cameraController;
  CameraDescription cameraDescription;
  CameraLensDirection cameraLensDirection = CameraLensDirection.back;
  FaceDetector faceDetector;
  bool isWorking = false;
  Size size;
  List<Face> facesList;

  initCamera() async {
    cameraDescription = await UtilsScanner.getCamera(cameraLensDirection);

    cameraController =
        CameraController(cameraDescription, ResolutionPreset.medium);

    faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.1,
        mode: FaceDetectorMode.fast));

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      Future.delayed(Duration(milliseconds: 200));

      cameraController.startImageStream((imageFromStream) {
        if (!isWorking) {
          isWorking = true;

          //implementar FaceDetection
          performDetectionOnStreamFrame(imageFromStream);
        }
      });
    });
  }

  dynamic scannResult;

  performDetectionOnStreamFrame(CameraImage imageFromStream) {
    UtilsScanner.detect(
        image: imageFromStream,
        detectInImage: faceDetector.processImage,
        imageRotation: cameraDescription.sensorOrientation
    ).then((dynamic result) {
      setState(() {
        scannResult = result;
      });
    }).whenComplete(() {
      isWorking = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController?.dispose();
    faceDetector.close();
  }

  toggleCamera() async {
    if (cameraLensDirection == CameraLensDirection.back) {
      cameraLensDirection = CameraLensDirection.front;
    } else {
      cameraLensDirection = CameraLensDirection.back;
    }

    await cameraController.stopImageStream();
    await cameraController.dispose();

    setState(() {
      cameraController = null;
    });

    initCamera();
  }

  Widget buildResult() {
    if (scannResult == null || cameraController == null ||
        !cameraController.value.isInitialized) {
      return Container();
    }

    final Size imageSize = Size(
        cameraController.value.previewSize.height,
        cameraController.value.previewSize.width);

    // customPainter
    CustomPainter customPainter = FaceDetectorPainter(
        imageSize, scannResult, cameraLensDirection);

    return CustomPaint(
      painter: customPainter,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackWidgetChildren = [];
    size = MediaQuery
        .of(context)
        .size;

    // add streaming camera
    if (cameraController != null) {
      stackWidgetChildren.add(Positioned(
          top: 30,
          left: 0,
          width: size.width,
          height: size.height - 250,
          child: Container(
            child: (cameraController.value.isInitialized)
                ? AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController))
                : Container(),
          )));
    }

    // toogle camera
    stackWidgetChildren.add(Positioned(
        top: size.height - 250,
        left: 0,
        width: size.width,
        height: 250,
        child: Container(
          margin: EdgeInsets.only(bottom: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  icon: Icon(
                    Icons.switch_camera,
                    color: Colors.white,
                  ),
                  iconSize: 50,
                  color: Colors.black,
                  onPressed: () {
                    toggleCamera();
                  })
            ],
          ),
        )));

    stackWidgetChildren.add(
        Positioned(
            top: 30,
            left: 0.0,
            width: size.width,
            height: size.height - 250,
            child: buildResult())
    );

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(
          children: stackWidgetChildren,
        ),
      ),
    );
  }
}
