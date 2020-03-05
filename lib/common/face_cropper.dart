import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image/image.dart' as img;

class DecodeParam {
  DecodeParam(this.image, this.faces, this.cameraPreviewWidth, this.cameraPreviewHeight, this.imageRotationAngle, this.sendPort);
  final CameraImage image;
  final List<Face> faces;
  final double cameraPreviewWidth;
  final double cameraPreviewHeight;
  final int imageRotationAngle;
  final SendPort sendPort;
}

Map<String,double> previewSizes = {'width': 200.0, 'height': 240.0};

convertYUV420toRGBAJpegUnit8List(DecodeParam param) {
  try {
    final int width = param.image.width;
    final int height = param.image.height;
    final int uvRowStride = param.image.planes[1].bytesPerRow;
    final int uvPixelStride = param.image.planes[1].bytesPerPixel;
      final int imageRotationAngle = param.imageRotationAngle;


    // print("uvRowStride: " + uvRowStride.toString());
    // print("uvPixelStride: " + uvPixelStride.toString());

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var pic = img.Image(width, height);
    
    for(int x=0; x < width; x++) {
      for(int y=0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x/2).floor() + uvRowStride*(y/2).floor();
        final int index = y * width + x;

        final yp = param.image.planes[0].bytes[index];
        final up = param.image.planes[1].bytes[uvIndex];
        final vp = param.image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 -vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);     
        // color: 0x FF  FF  FF  FF 
        //           A   B   G   R
        pic.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }
    //rotate the image
    var rotateImage = img.copyRotate(pic,imageRotationAngle);

    cropAllFacesInAnImageFrame(rotateImage, param);

  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}


cropAllFacesInAnImageFrame(rotateImage, param){

    List<List> listOfUint8List = [];

    for(Face face in param.faces){
      final double scaleX =  previewSizes['width'] / param.cameraPreviewHeight;
      final double scaleY = previewSizes['height'] / param.cameraPreviewWidth;

      final double left = (face.boundingBox.left * scaleX) *100,
            top = (face.boundingBox.top * scaleY) *100,
            right = (face.boundingBox.right * scaleX) *100,
            bottom = (face.boundingBox.bottom * scaleY) *100;


      final double xd = left, yd = top, wd = right - left, hd = bottom - top;
      int x = xd.round(), y = yd.round(), w = wd.round(), h = hd.round();
      final dynamic angleY = face.headEulerAngleY.round();

      if(angleY >= -40 && angleY <= 40){
        img.Image croppedFace = cropFace(rotateImage, x, y, w, h);

        img.JpegEncoder jpegEncoder = new img.JpegEncoder(quality: 100);
        List<int> uint8list = jpegEncoder.encodeImage(croppedFace);

        listOfUint8List.add(uint8list);
      }
    }

    param.sendPort.send(listOfUint8List);
}

cropFace(img.Image image, int x, int y, int w, int h) {
    int xn = (((x/100)/previewSizes['width']) * image.width).round(),
    yn = (((y/100)/previewSizes['height']) * image.height).round(),
    wn = (((w/100)/previewSizes['width']) * image.width).round(),
    hn = (((h/100)/previewSizes['height']) * image.height).round();


    try{
      if(xn < 0){
        xn = 0;
      }else{
        if((xn+wn) > image.width){
          // print('else before xn+wn = ${xn+wn}');
          xn =  (image.width - wn).abs();
          // print('else after xn+hn = ${xn+wn}');
        }
      }
      if(yn < 0){
        yn = 0;
      }else{
        if((yn+hn) > image.height){
          // print('else before yn+hn = ${yn+hn}');
          yn =  (image.height - hn).abs();
          // print('else after yn+hn = ${yn+hn}');
        }
      }

      final img.Image croppedFace = img.copyCrop(image, xn, yn, wn, hn);
      // print('try xn,yn,wn,hn = $xn, $yn, $wn, $hn');
      return croppedFace;
      
    }
    catch(e){
      print('<<><>>>> cropface Error: $e');
      print('catch xn,yn,wn,hn = $xn, $yn, $wn, $hn');
    }
}