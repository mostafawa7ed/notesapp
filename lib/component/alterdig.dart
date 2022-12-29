import 'package:flutter/material.dart';
show_loading(context){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("plase wait .... "),
      content: Container(
          height: 50,
          child: Center( child: CircularProgressIndicator(),)),
    );
  });
}