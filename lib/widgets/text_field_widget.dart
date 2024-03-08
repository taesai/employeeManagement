// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, must_be_immutable

import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  final String text;
  final bool obscureText;
  final Widget? prefixIcon;
  String? Function(String?)? validator;
  final TextEditingController? controller;
  TextFieldWidget(
      {super.key,
      required this.text,
      required this.obscureText,
      required this.prefixIcon,
      required this.validator,
      required this.controller});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        style: TextStyle(
          color: Colors.white),
        controller: widget.controller,
        cursorColor: Colors.cyan,
        cursorHeight: 22,
        obscureText: widget.obscureText,
        validator: widget.validator,
        decoration: InputDecoration(
            
            prefixIcon: widget.prefixIcon,
            prefixIconColor: Colors.orange,
            hintText: widget.text,
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan, width: 2)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan, width: 2))),
      ),
    );
  }
}
