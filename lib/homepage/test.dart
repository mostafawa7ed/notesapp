import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class testpage extends StatefulWidget
{
  //const Login({Key? key}) : super(key: key);
  const testpage({Key? key}) : super (key: key);
  @override
  _testpagestate createState()=> _testpagestate();

}

class _testpagestate extends State<testpage> {

  List users = [];
  get_user() async
  {
    var firebase_user =await FirebaseFirestore.instance.collection("user");
    await firebase_user.get().then((value) {
      value.docs.forEach((element) {
        users.add(element.data());
      });
    });
    print(users);
  }
  @override
  void initState() {
    get_user();
    super.initState();
  }
  var firebase_user = FirebaseFirestore.instance.collection("notes");
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(),
      body:StreamBuilder(builder:(context, snapshot) {
        if(snapshot.hasData)
          {
            return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context,i)
            {
              return Text("${snapshot.data?.docs[i].data()['title']}");
            });
          }
        if(snapshot.hasError)
          {
            return Text("hasError");
          }
        if (snapshot.connectionState == ConnectionState.waiting)
          {
            return Text("loading ....");
          }
        return Text("loading ");
      },stream:firebase_user.snapshots() ,)
    );
  }

    }




