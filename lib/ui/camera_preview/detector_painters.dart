// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum Detector { barcode, face, label, cloudLabel, text, cloudText }

// class BarcodeDetectorPainter extends CustomPainter {
//   BarcodeDetectorPainter(this.absoluteImageSize, this.barcodeLocations);

//   final Size absoluteImageSize;
//   final List<Barcode> barcodeLocations;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;

//     Rect scaleRect(Barcode barcode) {
//       return Rect.fromLTRB(
//         barcode.boundingBox.left * scaleX,
//         barcode.boundingBox.top * scaleY,
//         barcode.boundingBox.right * scaleX,
//         barcode.boundingBox.bottom * scaleY,
//       );
//     }

//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     for (Barcode barcode in barcodeLocations) {
//       paint.color = Colors.green;
//       canvas.drawRect(scaleRect(barcode), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(BarcodeDetectorPainter oldDelegate) {
//     return oldDelegate.absoluteImageSize != absoluteImageSize ||
//         oldDelegate.barcodeLocations != barcodeLocations;
//   }
// }


class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces);

  final Size absoluteImageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.lightGreen;

    // print('paint scaleX $scaleX');
    // print('paint scaleY $scaleY');
    // print('paint size.width ${size.width}');
    // print('paint size.height ${size.height}');
    // print('paint absoluteImageSize.width ${absoluteImageSize.width}');
    // print('paint absoluteImageSize.height ${absoluteImageSize.height}');


    for (Face face in faces) {
      canvas.drawRect(
        Rect.fromLTRB(
          face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
        ),
        paint,
      );


      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: ((face.boundingBox.right - face.boundingBox.left) * scaleX) *.2,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5)
      );
      final textSpan = TextSpan(
        text: '${face.trackingId}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final offset = Offset(face.boundingBox.left * scaleX, face.boundingBox.top * scaleY);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}


class FrontFaceDetectorPainter extends CustomPainter {
  FrontFaceDetectorPainter(this.absoluteImageSize, this.faces);

  final Size absoluteImageSize;
  final List<Face> faces;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.lightGreen;

    // print('paint scaleX $scaleX');
    // print('paint scaleY $scaleY');
    // print('paint size.width ${size.width}');
    // print('paint size.height ${size.height}');
    // print('paint absoluteImageSize.width ${absoluteImageSize.width}');
    // print('paint absoluteImageSize.height ${absoluteImageSize.height}');




    for (Face face in faces) {
      var left = absoluteImageSize.width - face.boundingBox.right;
      var top = face.boundingBox.top;
      var width = face.boundingBox.right - face.boundingBox.left;
      var height = face.boundingBox.bottom - face.boundingBox.top;
      canvas.drawRect(
        Rect.fromLTWH(
          // face.boundingBox.right * scaleX,
          // face.boundingBox.bottom * scaleY,
          // face.boundingBox.left * scaleX,
          // face.boundingBox.top * scaleY,


          left * scaleX,
          top * scaleY,
          width * scaleX,
          height * scaleY,
        ),
        paint,
      );

      final dynamic angleY = face.headEulerAngleY.round();

      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: ((face.boundingBox.right - face.boundingBox.left) * scaleX) *.05,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5)
      );
      final textSpan = TextSpan(
        text: '#${face.trackingId}, angleY = $angleY',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      final offset = Offset(left * scaleX, face.boundingBox.top * scaleY);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(FrontFaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}




class FaceDetectorPainterCircle extends CustomPainter {
  FaceDetectorPainterCircle(this.absoluteImageSize, this.faces, this.insideFaces);

  final Size absoluteImageSize;
  final List<Face> faces;
  Function insideFaces;

  faceIsInsideCircle(x1, y1, x2, y2, r1, r2){
    var d = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));

    if (r1 > ( d + r2 )) {
      return true;
    }
    else{
      // print('Face not in position');
      return false;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paintFace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white;

      final Paint paintCorrect = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.greenAccent;


      final Paint paintWrong = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.redAccent;

    // print('paint scaleX $scaleX');
    // print('paint scaleY $scaleY');
    // print('paint size.width ${size.width}');
    // print('paint size.height ${size.height}');
    // print('paint absoluteImageSize.width ${absoluteImageSize.width}');
    // print('paint absoluteImageSize.height ${absoluteImageSize.height}');
    double  d1 = (size.width/1.1),
            x1 = (size.width-d1)/2,
            y1 = (size.height-d1)/2;

    var centerOvalRect = Rect.fromLTWH(x1, y1, d1, d1);

    if(faces != null && faces.length > 0){
      List<Face> facesInsideCircle = <Face>[];

      for (Face face in faces) {
        double left = face.boundingBox.left * scaleX,
               top  = face.boundingBox.top * scaleY,
               right = face.boundingBox.right * scaleX,
               bottom = face.boundingBox.bottom * scaleY;

        double x2 = left,
               y2 = top,
               d2 = (right-left);

        canvas.drawOval(Rect.fromLTWH(x2,y2,d2,d2),paintFace);

        var checkFaceInsideCircle = faceIsInsideCircle((x1+(d1/2)),(y1+(d1/2)),(x2+(d2/2)),(y2+(d2/2)),d1/2,d2/2);

        if(checkFaceInsideCircle == true){
          facesInsideCircle.add(face);
          // if(faces.length == 1){
          //   canvas.drawOval(centerOvalRect, paintCorrect);
          //   captureIsTrue(true);
          // }else{
          //   canvas.drawOval(centerOvalRect, paintWrong);
          //   captureIsTrue(false);
          // }
          // if(facesInsideCircleCounter > 1){
          //   print('more than 1 face');
          //   canvas.drawOval(centerOvalRect, paintWrong);
          // }else{
          //   canvas.drawOval(centerOvalRect, paintCorrect);
          // }
          // captureIsTrue(true);
        }else{
          // canvas.drawOval(centerOvalRect, paintWrong);
          // captureIsTrue(false);
          facesInsideCircle.remove(face);
        }
        // print('from FaceDetectorPainterCircle faceIsInsideCircle ==> $checkFace');
      }

      if(facesInsideCircle.length == 1){
        canvas.drawOval(centerOvalRect, paintCorrect);
        insideFaces(facesInsideCircle);

        print('facesInsideCircle.length => ${facesInsideCircle.length}');
      }else{
        canvas.drawOval(centerOvalRect, paintWrong);

        if(facesInsideCircle.length > 1){
          facesInsideCircle.clear();
        }
      }

    }

    // for (Face face in faces) {
    //   // Size size = Size((face.boundingBox.right - face.boundingBox.left) * scaleX, (face.boundingBox.bottom - face.boundingBox.top) * scaleY);
    //   Offset center = Offset(size.width / 2, size.height / 2);
    //   double radius = size.width * 0.3;
    //   canvas.drawCircle(center, radius, paint);
    //   // canvas.drawRect(
    //   //   Rect.fromLTRB(
    //   //     face.boundingBox.left * scaleX,
    //   //     face.boundingBox.top * scaleY,
    //   //     face.boundingBox.right * scaleX,
    //   //     face.boundingBox.bottom * scaleY,
    //   //   ),
    //   //   paint,
    //   // );
    // }
  }

  @override
  bool shouldRepaint(FaceDetectorPainterCircle oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}

// class FaceDetectorPainter2 extends StatelessWidget {
//   FaceDetectorPainter2(this.absoluteImageSize, this.faces);

//   final Size absoluteImageSize;
//   final List<Face> faces;

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> _renderBoxes() {
//       return faces.map((face) {
//         var _x = face.boundingBox.left;
//         var _w = face.boundingBox.right-face.boundingBox.left;
//         var _y = face.boundingBox.top;
//         var _h = face.boundingBox.bottom-face.boundingBox.top;
//         var scaleW, scaleH, x, y, w, h;

//         if (screenH / screenW > previewH / previewW) {
//           scaleW = screenH / previewH * previewW;
//           scaleH = screenH;
//           var difW = (scaleW - screenW) / scaleW;
//           x = (_x - difW / 2) * scaleW;
//           w = _w * scaleW;
//           if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
//           y = _y * scaleH;
//           h = _h * scaleH;
//         } else {
//           scaleH = screenW / previewW * previewH;
//           scaleW = screenW;
//           var difH = (scaleH - screenH) / scaleH;
//           x = _x * scaleW;
//           w = _w * scaleW;
//           y = (_y - difH / 2) * scaleH;
//           h = _h * scaleH;
//           if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
//         }

//         return Positioned(
//           left: math.max(0, x),
//           top: math.max(0, y),
//           width: w,
//           height: h,
//           child: Container(
//             padding: EdgeInsets.only(top: 5.0, left: 5.0),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Color.fromRGBO(37, 213, 253, 1.0),
//                 width: 3.0,
//               ),
//             ),
//             child: Text(
//               "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
//               style: TextStyle(
//                 color: Color.fromRGBO(37, 213, 253, 1.0),
//                 fontSize: 14.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       }).toList();
//     }

//     List<Widget> _renderStrings() {
//       double offset = -10;
//       return results.map((re) {
//         offset = offset + 14;
//         return Positioned(
//           left: 10,
//           top: offset,
//           width: screenW,
//           height: screenH,
//           child: Text(
//             "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
//             style: TextStyle(
//               color: Color.fromRGBO(37, 213, 253, 1.0),
//               fontSize: 14.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       }).toList();
//     }

//     List<Widget> _renderKeypoints() {
//       var lists = <Widget>[];
//       results.forEach((re) {
//         var list = re["keypoints"].values.map<Widget>((k) {
//           var _x = k["x"];
//           var _y = k["y"];
//           var scaleW, scaleH, x, y;

//           if (screenH / screenW > previewH / previewW) {
//             scaleW = screenH / previewH * previewW;
//             scaleH = screenH;
//             var difW = (scaleW - screenW) / scaleW;
//             x = (_x - difW / 2) * scaleW;
//             y = _y * scaleH;
//           } else {
//             scaleH = screenW / previewW * previewH;
//             scaleW = screenW;
//             var difH = (scaleH - screenH) / scaleH;
//             x = _x * scaleW;
//             y = (_y - difH / 2) * scaleH;
//           }
//           return Positioned(
//             left: x - 6,
//             top: y - 6,
//             width: 100,
//             height: 12,
//             child: Container(
//               child: Text(
//                 "● ${k["part"]}",
//                 style: TextStyle(
//                   color: Color.fromRGBO(37, 213, 253, 1.0),
//                   fontSize: 12.0,
//                 ),
//               ),
//             ),
//           );
//         }).toList();

//         lists..addAll(list);
//       });

//       return lists;
//     }

//     return Stack(
//       children: model == mobilenet
//           ? _renderStrings()
//           : model == posenet ? _renderKeypoints() : _renderBoxes(),
//     );
//   }
// }
// class LabelDetectorPainter extends CustomPainter {
//   LabelDetectorPainter(this.absoluteImageSize, this.labels);

//   final Size absoluteImageSize;
//   final List<ImageLabel> labels;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
//       ui.ParagraphStyle(
//           textAlign: TextAlign.left,
//           fontSize: 23.0,
//           textDirection: TextDirection.ltr),
//     );

//     builder.pushStyle(ui.TextStyle(color: Colors.green));
//     for (ImageLabel label in labels) {
//       builder.addText('Label: ${label.text}, '
//           'Confidence: ${label.confidence.toStringAsFixed(2)}\n');
//     }
//     builder.pop();

//     canvas.drawParagraph(
//       builder.build()
//         ..layout(ui.ParagraphConstraints(
//           width: size.width,
//         )),
//       const Offset(0.0, 0.0),
//     );
//   }

//   @override
//   bool shouldRepaint(LabelDetectorPainter oldDelegate) {
//     return oldDelegate.absoluteImageSize != absoluteImageSize ||
//         oldDelegate.labels != labels;
//   }
// }

// // Paints rectangles around all the text in the image.
// class TextDetectorPainter extends CustomPainter {
//   TextDetectorPainter(this.absoluteImageSize, this.visionText);

//   final Size absoluteImageSize;
//   final VisionText visionText;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;

//     Rect scaleRect(TextContainer container) {
//       return Rect.fromLTRB(
//         container.boundingBox.left * scaleX,
//         container.boundingBox.top * scaleY,
//         container.boundingBox.right * scaleX,
//         container.boundingBox.bottom * scaleY,
//       );
//     }

//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;

//     for (TextBlock block in visionText.blocks) {
//       for (TextLine line in block.lines) {
//         for (TextElement element in line.elements) {
//           paint.color = Colors.green;
//           canvas.drawRect(scaleRect(element), paint);
//         }

//         paint.color = Colors.yellow;
//         canvas.drawRect(scaleRect(line), paint);
//       }

//       paint.color = Colors.red;
//       canvas.drawRect(scaleRect(block), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(TextDetectorPainter oldDelegate) {
//     return oldDelegate.absoluteImageSize != absoluteImageSize ||
//         oldDelegate.visionText != visionText;
//   }
// }
