// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'detector_painters.dart';
import 'scanner_utils.dart';
import '../../common/face_cropper.dart';

class CameraPreviewScanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraPreviewScannerState();
}

class _CameraPreviewScannerState extends State<CameraPreviewScanner> {
  dynamic _scanResults;
  CameraController _camera;
  Detector _currentDetector = Detector.face;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  int imageRotationAngle = 90;
  Size imageSize;
  CustomPainter painter;
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(enableTracking: true, mode: FaceDetectorMode.accurate));


  List listOfUint8List = [];
  List<int> faceIds = <int>[];
  List<String> croppedFacesPath = [];
  List<int> croppedFacesAngle = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera(_direction);
  }

  void _initializeCamera(CameraLensDirection direction) async {
    final CameraDescription description =
        await ScannerUtils.getCamera(direction);

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();

    imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;

      ScannerUtils.detect(
        image: image,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
        (dynamic results) {
          if (_currentDetector == null) return;
          setState(() {
            _scanResults = results;
          });

          if(direction == CameraLensDirection.back){
            setState(() {
              painter = FaceDetectorPainter(imageSize, results);
            });
          } else{
            setState(() {
              painter = FrontFaceDetectorPainter(imageSize, results);
            });
          }

          if(results.length > 0){
            scanFaces(image, results);
          }
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  Future<dynamic> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _faceDetector.processImage;
  }

  Future scanFaces(CameraImage image, List<Face> faces) async {

    List<Face> newFaces = <Face>[];

    // faceIds.clear();
    int faceId;
    for (Face face in faces) {
      faceId = face.trackingId;

      if(!faceIds.contains(faceId)){
        faceIds.add(faceId);
        newFaces.add(face);
        croppedFacesAngle.add(face.headEulerAngleY.round());
      }
    }

    if(faceIds.length == 0){
      faceIds.clear();
    }

    if(newFaces.length > 0){
      // print('start convertYUV420toRGBAJpegUnit8List');
      int startTime = new DateTime.now().millisecondsSinceEpoch;
      // var memoryImage = convertYUV420toRGBAJpegUnit8List(image);
      final ReceivePort receivePort = ReceivePort();
      final double cameraPreviewWidth = _camera.value.previewSize.width;
      final double cameraPreviewHeight = _camera.value.previewSize.height;
      await Isolate.spawn(convertYUV420toRGBAJpegUnit8List, DecodeParam(image, newFaces, cameraPreviewWidth, cameraPreviewHeight, imageRotationAngle, receivePort.sendPort));

      List currentAllFaceslistOfUint8List = await receivePort.first;
      
      listOfUint8List = new List.from(currentAllFaceslistOfUint8List)..addAll(listOfUint8List);
      // print('memoryImage listOfUint8List $listOfUint8List');

      // List<UploadFileInfo> uploadImgFiles = [];
      // for(List<int> uint8list in listOfUint8List){
      //   // memoryImages.add(Image.memory(uint8list, fit: BoxFit.fill));

      //   final String croppedFacePath = join(
      //         (await getTemporaryDirectory()).path,
      //         'Test6_croppedFace_${DateTime.now().microsecondsSinceEpoch}.jpg',
      //         ).toString();
              
      //   File(croppedFacePath).writeAsBytesSync(uint8list);

      //   croppedFacesPath.add(croppedFacePath);

      //   uploadImgFiles.add(UploadFileInfo(File(croppedFacePath), croppedFacePath));
      // }

      print('converting took: ${(new DateTime.now().millisecondsSinceEpoch)-startTime} ms');

      // FormData formData = new FormData.from({
      //     // Pass multiple files within an Array
      //     "files": uploadImgFiles
      // });
      
      // double sendStartTime = new DateTime.now().millisecondsSinceEpoch/1000;
      // Dio dio = new Dio();
      // try{
      //   await dio.post("http://192.168.1.209:5002/api/process/mobile_cropped_face/2001/cam_id_5cd28d37eb3f375f8b3b5ce9/$sendStartTime/1.0", data: formData);
      //   print('croppedFacesPath.length ${croppedFacesPath.length}');
      //   // deleteFiles(croppedFacesPath);
      //   await deleteFiles(croppedFacesPath);
      //   croppedFacesPath.clear();
      // }catch(e){
      //   print('DioError $e');
      // }

      // print('--------------------image:  Image.memory(memoryImage) width, height = ${Image.memory(memoryImage).width}, ${Image.memory(memoryImage).height}');
      
      // print('end convertYUV420toRGBAJpegUnit8List');

      // print('send to server took: ${(new DateTime.now().millisecondsSinceEpoch)-((sendStartTime*1000).round())} ms');

      // print('faceIds $faceIds');
    }
  }

  Widget _buildResults() {
    const Text noResultsText = Text('No results!');

    // print('_scanResults => $_scanResults');

    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    // imageSize = Size(
    //   _camera.value.previewSize.height,
    //   _camera.value.previewSize.width,
    // );

    if (_scanResults is! List<Face>) return noResultsText;
    // painter = FaceDetectorPainter(imageSize, _scanResults);

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });


    if (_direction == CameraLensDirection.back) {
      setState(() {
        _direction = CameraLensDirection.front;
        imageRotationAngle = 270;
        painter = FrontFaceDetectorPainter(imageSize, _scanResults);
      });
    } else {
      setState(() {
        _direction = CameraLensDirection.back;
        imageRotationAngle = 90;
        painter = FaceDetectorPainter(imageSize, _scanResults);
      });
    }
    
    _initializeCamera(_direction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('ML Vision Example'),
      //   actions: <Widget>[
      //     // PopupMenuButton<Detector>(
      //     //   onSelected: (Detector result) {
      //     //     _currentDetector = result;
      //     //   },
      //     //   itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
      //     //     const PopupMenuItem<Detector>(
      //     //       child: Text('Detect Face'),
      //     //       value: Detector.face,
      //     //     ),
      //     //   ],
      //     // ),
      //   ],
      // ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              // alignment: Alignment(0.0, 0.0),
              child:Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _buildImage()
              )
            )

          ),
Positioned(
  bottom: 0,
  child: Container(
    width: MediaQuery.of(context).size.width,
    height: 220,
    child: ListView.builder
    (
      scrollDirection: Axis.horizontal,
      itemCount: listOfUint8List.length,
      itemBuilder: (BuildContext ctxt, int index) {
        // var timestamp = DateTime.fromMillisecondsSinceEpoch((matched_users[index]['Time'] * 1000).round());
        // var logStatusColor;
        // if(matched_users[index]["Log_Status"] == "Authorized"){
        //   logStatusColor = Color.fromRGBO(52, 132, 46, 1.0);
        // }
        // if(matched_users[index]["Log_Status"] == "Unauthorized"){
        //   logStatusColor = Color.fromRGBO(193, 162, 50, 1.0);
        // }
        // if(matched_users[index]["Log_Status"] == "Blocked"){
        //   logStatusColor = Colors.white;
        // }
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Color.fromRGBO(58, 66, 86, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child: Image.memory(
                  listOfUint8List[index],
                  fit: BoxFit.fill,
                  width: 160.0,
                  height: 160.0,
                ),
                // FadeInImage.assetNetwork(image: "$MAIN_URI:5011/static${matched_users[index]['Log_Image_Directory']}", placeholder: 'images/admin-avatar.png',
                //   width: 160.0,
                //   height: 160.0,
                //   fit: BoxFit.fill
                // ),
                // Image.network(
                //   "$MAIN_URI:5011/static${matched_users[index]['Log_Image_Directory']}",
                // )
              ),
              Container(
                width: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                      child: Text("tmp face id => ${faceIds[index]}")
                      // Text("angle ==> ${croppedFacesAngle[index]}", style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                    ),
                  ]
                )
              ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       // Padding(
              //       //   padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              //       //   child: Text(matched_users[index]['Log_User_Type'], style: TextStyle(color:Colors.blue)),
              //       // ),

              //       SizedBox(
              //         width: 155,
              //         child: RaisedButton(
              //           elevation: 0,
              //           padding: EdgeInsets.all(0),
              //           shape: RoundedRectangleBorder(borderRadius:  BorderRadius.only(bottomLeft: Radius.circular(30), topLeft: Radius.circular(30), topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
              //           onPressed: () async {
              //             // Get User data and show their profile

              //             // print('url=> $MAIN_URI:5004/api/query/registered_user/${matched_users[index]['User_ID']}');

              //             dynamic data = await Request(url: '$MAIN_URI:5004/api/query/registered_user/${matched_users[index]['User_ID']}').get;

              //             // print(data);
              //             Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx) => RecognizedProfileScreen(matched_face: matched_users[index]['Log_Image_Directory'], data: json.encode(data))));

              //           },
              //           color:  matched_users[index]["Log_Status"] == "Blocked" ? Color.fromRGBO(145, 0, 0, 1.0) : Color.fromRGBO(255,255,255, 1.0),
              //           child: Row(
              //             children: <Widget>[
              //               ClipRRect(
              //                 borderRadius: BorderRadius.all(Radius.circular(50)),
              //                 child: FadeInImage.assetNetwork(image: "$MAIN_URI:5011/static${matched_users[index]['Reg_Image_Directories'][0]}", placeholder: 'images/admin-avatar.png',
              //                   width: 60.0,
              //                   height: 60.0,
              //                   fit: BoxFit.fill)
              //                 // Image.network(
              //                 //   "$MAIN_URI:5011/static${matched_users[index]['Reg_Image_Directories'][0]}",
              //                 //   width: 60.0,
              //                 //   height: 60.0,
              //                 //   fit: BoxFit.fill
              //                 // )
              //               ),
              //               // Material(
              //               //   elevation: 4.0,
              //               //   shape: CircleBorder(),
              //               //   color: Colors.transparent,
              //               //   child: Ink.image(
              //               //     image: NetworkImage('$MAIN_URI:5004${matched_users[index]['Reg_Image_Directories'][0]}'),
              //               //     fit: BoxFit.cover,
              //               //     width: 60.0,
              //               //     height: 60.0,
              //               //     child: InkWell(
              //               //       onTap: () {},
              //               //       child: null,
              //               //     ),
              //               //   ),
              //               // )
              //               Container(
              //                 width: 95.0,
              //                 child: Column(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: <Widget>[
              //                     Container(
              //                       width: 80,
              //                       // color: Colors.green,
              //                       child: Text(matched_users[index]['Log_User_Type'], style: TextStyle(color: matched_users[index]["Log_Status"] == "Blocked" ? Color.fromRGBO(255,255,255, 1.0) : Colors.black, fontSize: 14))
              //                     ),
              //                     SizedBox(height: 5),
              //                     Container(
              //                       width: 80,
              //                       child: Text(matched_users[index]["Log_Status"], style: TextStyle(color: logStatusColor, fontSize: 12))
              //                     ),
              //                   ],
              //                 )

              //               )

              //             ]
              //           ),
              //         )
              //       ),
              //       Padding(
              //         padding: EdgeInsets.fromLTRB(10, 10, 10, 2),
              //         child: Text('${dateFormat.format(timestamp)} ${timeFormat.format(timestamp)}', style: TextStyle(fontSize: 11, color: Colors.white))
              //       ),
              //       // IconButton(
              //       //   color: Colors.white,
              //       //   icon: Icon(Icons.remove_red_eye),
              //       //   tooltip: 'View Profile',
              //       //   onPressed: () {

              //       //   },
              //       // )
              //       // Padding(
              //       //   padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              //       //   child: Text('${timeFormat.format(timestamp)}', style: TextStyle(color: Colors.white))
              //       // ),
              //     ],
              //   )
              // )
            ]
          )
        );
      }
    ),
  ),
)

        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }

  @override
  void dispose() {
    _camera.dispose().then((_) {
      _faceDetector.close();
    });

    _currentDetector = null;
    super.dispose();
  }
}
