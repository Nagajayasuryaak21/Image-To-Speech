import 'package:firebase_ml_vision_raw_bytes/firebase_ml_vision_raw_bytes.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = '';
  File? image;
  ImagePicker? imagePicker;
  FlutterTts flutterTts = FlutterTts();
  pickImageFromGalary() async {
    PickedFile? pickedFile =
        await imagePicker?.getImage(source: ImageSource.gallery);
    image = File(pickedFile!.path);

    setState(() {
      image;
      performImageLabeling();
    });
  }

  pickImageFromCamera() async {
    PickedFile? pickedFile =
        await imagePicker?.getImage(source: ImageSource.camera);
    image = File(pickedFile!.path);

    setState(() {
      image;
      performImageLabeling();
    });
  }

  performImageLabeling() async {
    final FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(image);
    final TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await recognizer.processImage(firebaseVisionImage);

    result = "";
    setState(() {
      for (TextBlock block in visionText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            result += element.text + " ";
          }
        }
        result += "\n";
      }
    });
    print(result);
    print(image);
    // if (image != null) {
    //   String text = await FlutterTesseractOcr.extractText(image!.path,
    //       language: 'eng+tam',
    //       args: {
    //         "preserve_interword_spaces": "1",
    //       });
    //   print(text);
    // }
    final translator = GoogleTranslator();
    translator.translateAndPrint(result, to: 'ta');
  }

  void playAudio() async {
    await flutterTts.speak(result);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 8,
              child: image != null
                  ? Image.file(image!, fit: BoxFit.fill)
                  : Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          "Select Photo",
                        ),
                      ),
                    ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        playAudio();
                      },
                      child: Container(
                        child: image != null
                            ? Icon(
                                Icons.play_arrow,
                                size: 30.0,
                              )
                            : Container(),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        pickImageFromCamera();
                      },
                      child: Material(
                        child: Icon(
                          Icons.camera,
                          size: 50.0,
                        ),
                      ),
                    ),
                  )),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        pickImageFromGalary();
                      },
                      child: Material(
                        child: Icon(
                          Icons.browse_gallery,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
