import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:tomourapp/utils/colos.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  List<String> imagePaths = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadImages();
  }

  UniqueKey _key = UniqueKey();
  void update() {
    setState(() {
      _key = UniqueKey();
    });
  }

  void loadImages() {
    final box = Hive.box('images');
    setState(() {
      imagePaths = List<String>.from(box.values);
    });
  }

  Future<void> deleteAllSavedImages() async {
    final box = Hive.box('images');

    for (var path in box.values) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await box.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await deleteAllSavedImages();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("همه عکس‌ها پاک شدند")));
              update();
              imagePaths = [];
              setState(() {});
            },
            icon: Icon(Icons.delete),
          ),
        ],
        backgroundColor: background,
        centerTitle: true,
        title: Text(
          "Save",
          style: TextStyle(fontSize: 60.w, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        key: _key,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: Image.file(
              File(imagePaths[index]),
              height: 200,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
