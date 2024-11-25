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
  final ImagePicker _imagePicker =
      ImagePicker(); //will be used to pick image from gallery
  //XFile? _image;
  List<XFile> images = [];
  Map<String, String> _labels = {}; //to store multiple images
  String text = '';
  bool scanning = false;

  /*@override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }*/

//Method to retrieve images from a source; either camera or gallery
  _getImage(ImageSource source) async {
    List<XFile>? results =
        await _imagePicker.pickMultiImage(); //putting them in a list

    setState(() {
      images = results;
      _labels.clear();
    });
    labeltext();
  }

//Method to label the image
  labeltext() async {
    if (!mounted) return;
    setState(() {
      text = " ";
      scanning = true;
    });

    try {
      for (XFile image in images) {
        final inputimage = InputImage.fromFilePath(image.path);
        final ImageLabelerOptions options =
            ImageLabelerOptions(confidenceThreshold: 0.5);
        final imageLabeler = ImageLabeler(options: options);

        final List<ImageLabel> labels =
            await imageLabeler.processImage(inputimage);

        String labelText = labels.map((label) {
          return '${label.label} (${(label.confidence * 100).toStringAsFixed(2)}%)';
        }).join("\n");

        /*for (ImageLabel label in labels) {
        text +=
            'Label: ${label.label} , CS: (${(label.confidence * 100).toStringAsFixed(2)}%)\n';
      }*/
        setState(() {
          //scanning = false;
          _labels[image.path] = labelText; //saving labels for images
        });
      }
      //imageLabeler.close();
    } catch (e) {
      print('Error during text recognition: $e');
    } finally {
      //imageLabeler.close();
      setState(() {
        scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Labeling")),
      body: scanning
          ? Center(
              child: CircularProgressIndicator()) // Show loader while scanning
          : images.isEmpty
              ? Center(
                  child: Text(
                    "Select images to label",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.file(File(image.path),
                              height: 200, fit: BoxFit.cover),
                          SizedBox(height: 10),
                          Text(
                            _labels[image.path] ?? "Processing...",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text("From Gallery"),
            onPressed: () =>
                _getImage(ImageSource.gallery), // image from gallery
          ),
          SizedBox(height: 10, width: 30),
          ElevatedButton(
            child: Text("From Camera"),
            onPressed: () => _getImage(ImageSource.camera), //image from camera
          ),
        ],
      ),
    );
  }
}
