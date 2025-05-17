import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tomourapp/screens/save.dart';
import 'package:tomourapp/utils/colos.dart';
import 'package:tomourapp/utils/widget.dart';
import 'package:path/path.dart' as path;

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  String ip = "";
  TextEditingController ipController = TextEditingController();
  File? _selectedImage;
  Uint8List? _responseBytes;
  bool _isLoading = false;
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String> _saveResponseBytes(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = path.join(
      directory.path,
      '${DateTime.now().millisecondsSinceEpoch}.png',
    );
    final file = File(imagePath);
    await file.writeAsBytes(bytes);
    return imagePath;
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    setState(() => _isLoading = true);

    final uri = Uri.parse('http://$ip:8080/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

    try {
      final streamed = await request.send();
      if (streamed.statusCode == 200) {
        final bytes = await streamed.stream.toBytes();
        setState(() {
          _responseBytes = bytes;
        });
        final savedPath = await _saveResponseBytes(bytes);
        await Hive.box('images').add(savedPath);
      } else {
        // خطای
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${streamed.statusCode}")));
        print('Server error: ${streamed.statusCode}');
      }
    } catch (e) {
      print('Upload failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${e}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder:
            (context) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Dialog(
                insetAnimationDuration: Duration(seconds: 1),
                insetAnimationCurve: Curves.easeIn,
                backgroundColor: Colors.white,
                child: Container(
                  alignment: Alignment.center,
                  height: 300,
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width - 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          labelText: 'Enter IP Address',
                          hintStyle: TextStyle(color: Colors.grey),
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.amberAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              ip = ipController.text;
                            });
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.black,
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.amberAccent,
                            ),
                          ),
                          child: Text("Set"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => SaveScreen()),
            );
          },
          icon: Icon(Icons.bookmark_border, size: 66.w),
        ),
        backgroundColor: background,
        centerTitle: true,
        title: Text(
          "Detect",
          style: TextStyle(fontSize: 60.w, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onDoubleTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Dialog(
                          insetAnimationDuration: Duration(seconds: 1),
                          insetAnimationCurve: Curves.easeIn,
                          backgroundColor: Colors.white,
                          child: Container(
                            alignment: Alignment.center,
                            height: 300,
                            padding: EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width - 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: ipController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    labelText: 'Enter IP Address',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.amberAccent,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 2.0,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2.0,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: 200,
                                  height: 35,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        ip = ipController.text;
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                      foregroundColor: WidgetStatePropertyAll(
                                        Colors.black,
                                      ),
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.amberAccent,
                                      ),
                                    ),
                                    child: Text("Set"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                );
              },
              child: Text(
                ip,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            SizedBox(height: 20),

            Container(
              width: 1148.w,
              height: 1148.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _selectedImage != null ? background : Color(0xffD9D9D9),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _responseBytes != null
                        ? Image.memory(_responseBytes!, fit: BoxFit.contain)
                        : _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.contain)
                        : SizedBox(),
              ),
            ),
            SizedBox(height: 60),
            Container(
              width: 900.w,
              height: 130.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(32, 32),
                    blurRadius: 40,
                    color: Color(0xffA7a7a7),
                  ),
                  BoxShadow(
                    offset: Offset(-32, -32),
                    blurRadius: 40,
                    color: Color(0xffe1e1e1),
                  ),
                ],
              ),
              child: ButtonsApp(
                title: "Send",
                func: _selectedImage == null ? _pickImage : _uploadImage,
              ),
            ),
            SizedBox(height: 30),
            _selectedImage != null
                ? Container(
                  width: 900.w,
                  height: 130.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(32, 32),
                        blurRadius: 40,
                        color: Color(0xffA7a7a7),
                      ),
                      BoxShadow(
                        offset: Offset(-32, -32),
                        blurRadius: 40,
                        color: Color(0xffe1e1e1).withOpacity(.5),
                      ),
                    ],
                  ),
                  child: ButtonsApp(
                    title: "Delete",
                    func: () {
                      setState(() {
                        _selectedImage = null;
                        _responseBytes = null;
                      });
                    },
                  ),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
