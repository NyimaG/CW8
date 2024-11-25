import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:google_ml_kit/google_ml_kit.dart';
//import 'package:google_mlkit_commons/google_mlkit_commons.dart' hide InputImage;

void main() {
  runApp(
    MaterialApp(home: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final ImagePicker imagePicker; //will be used to pick image from gallery
  XFile? _image;
  String text = '';
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();
  /*@override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }*/

//Method to retrieve image from a source; either camera or gallery
  _getImage(ImageSource source) async {
    XFile? result = await _imagePicker.pickImage(source: source);
    if (result != null) {
      setState(() {
        _image = result;
      });
      labeltext();
    }
  }

//Method to label the image
  labeltext() async {
    if (!mounted) return;
    setState(() {
      text = " ";
      scanning = true;
    });

    try {
      final inputimage = InputImage.fromFilePath(_image!.path);
      final ImageLabelerOptions options =
          ImageLabelerOptions(confidenceThreshold: 0.5);
      final imageLabeler = ImageLabeler(options: options);

      final List<ImageLabel> labels =
          await imageLabeler.processImage(inputimage);

      for (ImageLabel label in labels) {
        text +=
            'Label: ${label.label} , CS: (${(label.confidence * 100).toStringAsFixed(2)}%)\n';
      }
      setState(() {
        scanning = false;
      });

      imageLabeler.close();
    } catch (e) {
      print('Error during text recognition: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(File(_image!.path)),
                  //if (widget.customPaint != null) widget.customPaint!,
                ],
              ),
            )
          : Icon(
              Icons.image,
              size: 200,
            ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('From Gallery'),
          onPressed: () {
            _getImage(ImageSource.gallery);
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      SizedBox(
        height: 50,
        width: 50,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    ]);
  }
}
