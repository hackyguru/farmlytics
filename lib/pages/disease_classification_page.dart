import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uia_hackathon_app/constants/text_styles.dart';

import '../constants/color_constants.dart';
import '../custom_widgets/custom_button.dart';
import 'main_page.dart';

class DiseaseClassification extends StatefulWidget {
  const DiseaseClassification({super.key});

  @override
  State<DiseaseClassification> createState() => _DiseaseClassificationState();
}

class _DiseaseClassificationState extends State<DiseaseClassification> {
  late File image;
  late List results;
  bool imageSelected = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String? res;
    res = await Tflite.loadModel(
        model: 'assets/tflite_model_another.tflite',
        labels: 'assets/labels.txt');
    print(res);
  }

  Future classifyDisease(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path, // required
      imageMean: 127.5, // defaults to 117.0
      imageStd: 127.5, // defaults to 1.0
      numResults: 2, // defaults to 5
      threshold: 0.2, // defaults to 0.1
    );

    setState(() {
      results = recognitions!;
      image = image;
      imageSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select an image of the plant',
                  style: kHeaderStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'We will predict the disease of your plant and suggest some measures to prevent it',
                  textAlign: TextAlign.center,
                  style: kSubtitleStyle,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () => pickImageFromCamera(),
                  child: CustomButton(
                    icon: Icon(Icons.camera),
                    title: 'Capture Image with Camera',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: () => pickImageFromGallery(),
                  child: CustomButton(
                    icon: Icon(Icons.file_open_rounded),
                    title: 'Pick Image From Gallery',
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              imageSelected
                  ? Center(child: Text(results.toString()))
                  : const Text('')
            ],
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
          child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: kprimaryGreenColor,
              ),
              child: Center(child: Text('Next', style: kButtonStyle))),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const MainPage();
            }));
          }),
    );
  }

  Future pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    File image = File(pickedFile!.path);
    print('done');
    classifyDisease(image);
  }

  Future pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    File image = File(pickedFile!.path);
    print('done');
    classifyDisease(image);
  }
}
