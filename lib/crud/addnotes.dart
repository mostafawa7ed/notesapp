import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddNotes extends StatefulWidget {
  AddNotes({Key? key}) : super(key: key);
  @override
  _AddNotesstate createState() => _AddNotesstate();
}

class _AddNotesstate extends State<AddNotes> {
  String? title, note, image_url;
  CollectionReference Notes_ref =
      FirebaseFirestore.instance.collection("Notes");
  GlobalKey<FormState> form_state = new GlobalKey<FormState>();
  Reference? refstorage;
  File? file;
  var imagepicer = ImagePicker();
  upload_image(context) async {
    var image_pict =
        await imagepicer.getImage(source: ImageSource.camera, imageQuality: 1);
    if (imagepicer != null) {
      var random_num = Random().nextInt(1000000);
      String? nameImage = basename(image_pict!.path);
      nameImage = "$random_num$nameImage";
      file = File(image_pict!.path);
      print("===============");
      print(image_pict.path);
      print(nameImage);
      refstorage = FirebaseStorage.instance.ref("images").child("$nameImage");
    } else {
      print("plz choose image");
    }
  }

  add_Notes(context) async {
    var form_data = form_state.currentState;
    if (form_data!.validate()) {
      print(file?.path);
      print('ddddddddddddddd');
      if (file == null) {
        return AwesomeDialog(
            context: context,
            body: Text("you Must load Image"),
            dialogType: DialogType.warning)
          ..show();
      }
      await refstorage?.putFile(file!);
      var image_url = await refstorage?.getDownloadURL();
      print(image_url);
      form_data.save();
      print(FirebaseAuth.instance.currentUser?.uid);
      await Notes_ref.add({
        "title": title,
        "note": note,
        "image_url": image_url,
        "user": FirebaseAuth.instance.currentUser?.uid
      }).then((value) {
        Navigator.of(context).pushNamed("homepage");
        setState(() {});
      });
      print(FirebaseAuth.instance.currentUser?.uid);
    }
  }

  @override
  void initState() {
    //get_Iamges_name();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add sNotes"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Form(
              autovalidateMode: AutovalidateMode.always,
              key: form_state,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) =>
                        value != '' ? null : "Please enter a TITLE NOTE",
                    maxLength: 50,
                    onSaved: (text) {
                      title = text;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Title Note",
                        prefixIcon: Icon(Icons.note)),
                  ),
                  TextFormField(
                    maxLength: 300,
                    validator: (value) =>
                        value != '' ? null : "Please enter a NOTE",
                    minLines: 1,
                    maxLines: 3,
                    onSaved: (text) {
                      note = text;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Note",
                        prefixIcon: Icon(Icons.note)),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        showButtonsheet(context);
                      },
                      child: Text("Add Image")),
                  ElevatedButton(
                      onPressed: () {
                        add_Notes(context);
                      },
                      child: Text(
                        "Add Notes",
                        style: Theme.of(context).textTheme.headline2,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  showButtonsheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 170,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "please chose a image",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo,
                          size: 50,
                        ),
                        Container(
                            padding: EdgeInsets.all(5),
                            child: Text("from phone")),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await upload_image(context);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera,
                          size: 50,
                        ),
                        Container(
                            padding: EdgeInsets.all(5),
                            child: Text("from Camera")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
