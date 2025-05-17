import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tomourapp/utils/colos.dart';

class ButtonsApp extends StatefulWidget {
  final String title;
  final void Function() func;
  const ButtonsApp({super.key, required this.title, required this.func});

  @override
  State<ButtonsApp> createState() => _ButtonsAppState();
}

class _ButtonsAppState extends State<ButtonsApp> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.func,
      style: ButtonStyle(
        elevation: WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
          widget.title == "Send" ? background : foreground,
        ),
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 50.sp,
          fontWeight: FontWeight.bold,
          color: widget.title == "Send" ? foreground : background,
        ),
      ),
    );
  }
}
