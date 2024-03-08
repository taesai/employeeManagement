// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String text;
  final void Function()? onPressed;
  const MyButton({super.key, required this.text, required this.onPressed});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor),
            onPressed: widget.onPressed,
            child: Text(
              widget.text,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )),
      ),
    );
  }
}
