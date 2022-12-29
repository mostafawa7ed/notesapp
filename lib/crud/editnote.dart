import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditNotes extends StatefulWidget {
  final docid, note;
  EditNotes({Key? key, this.docid, this.note}) : super(key: key);
  @override
  _EditNotesstate createState() => _EditNotesstate();
}

class _EditNotesstate extends State<EditNotes> {
  String? title, note, image_url;
  CollectionReference Notes_ref =
      FirebaseFirestore.instance.collection("Notes");
  GlobalKey<FormState> form_state = new GlobalKey<FormState>();
  Reference? refstorage;
  File? file, file_comp;
  var imagepicer = ImagePicker();

  upload_image(context) async {
    var image_pict =
        await imagepicer.getImage(source: ImageSource.camera, imageQuality: 20);
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

  Edit_Notes(context) async {
    var form_data = form_state.currentState;
    if (form_data!.validate()) {
      print(file?.path);
      print('ddddddddddddddd');
      if (file == null) {
        form_data.save();
        print(FirebaseAuth.instance.currentUser?.uid);
        await Notes_ref.doc(widget.docid)
            .update({
              "title": title,
              "note": note,
            })
            .then((value) => () {
                  print("note updated");
                })
            .catchError((e) {
              print(e.toString());
            });
        print(FirebaseAuth.instance.currentUser?.uid);
      } else {
        await refstorage?.putFile(file!);
        var image_url = await refstorage?.getDownloadURL();
        print(image_url);
        form_data.save();
        print(FirebaseAuth.instance.currentUser?.uid);
        await Notes_ref.doc(widget.docid)
            .update({
              "title": title,
              "note": note,
              "image_url": image_url,
            })
            .then((value) => () {
                  print("update success");
                })
            .catchError((e) {
              print(e.toString());
            });
        print(FirebaseAuth.instance.currentUser?.uid);
      }
    }
  }

  get_Iamges_name() async {
    var ref = await FirebaseStorage.instance.ref().list(); //root/images
    ref.items.forEach((element) {
      print(element.name);
    });

    ref.prefixes.forEach((element) {
      print(element.name);
      //print(element.fullPath); //get path
    });
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
        leading: IconButton(
            icon: Icon(Icons.arrow_back_outlined),
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            }),
        title: Text("Edit Note"),
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
                    initialValue: widget.note['title'],
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
                    initialValue: widget.note['note'],
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
                      child: Text("Add New Image")),
                  ElevatedButton(
                      onPressed: () {
                        Edit_Notes(context);
                        Navigator.of(context).pushNamed("homepage");
                        setState(() {});
                      },
                      child: Text(
                        "Edit Notes",
                        style: Theme.of(context).textTheme.headline2,
                      )),
                  file == null
                      ? Text("")
                      : Image.file(
                          file!,
                          height: 400,
                        ),
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
