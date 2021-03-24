import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class FaceDetectorPainter extends CustomPainter {
  final Size absulteImageSize;
  final List<Face> faces;
  CameraLensDirection cameraLensDirection;

  FaceDetectorPainter(
      this.absulteImageSize, this.faces, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absulteImageSize.width;
    final double scaleY = size.height / absulteImageSize.height;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.greenAccent;

    for (Face face in faces) {
      canvas.drawRect(
          Rect.fromLTRB(
              cameraLensDirection == CameraLensDirection.back
                  ? face.boundingBox.left * scaleX
                  : (absulteImageSize.width - face.boundingBox.right) * scaleX,
              face.boundingBox.top * scaleY,
              cameraLensDirection == CameraLensDirection.back
                  ? face.boundingBox.right * scaleX
                  : (absulteImageSize.width - face.boundingBox.left) * scaleX,
              face.boundingBox.bottom * scaleY),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceDetectorPainter oldDelegate) {
    return oldDelegate.absulteImageSize != absulteImageSize ||
        oldDelegate.faces != faces;
  }
}
