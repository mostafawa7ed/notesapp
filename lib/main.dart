import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/auth/login.dart';
import 'package:notes/auth/Signin.dart';
import 'package:notes/crud/addnotes.dart';
import 'package:notes/homepage/homepage.dart';
import 'crud/editnote.dart';
import 'homepage/test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future backgroundMessage(RemoteMessage message) async {
  print("==========");
  print(message.notification?.body);
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); //used when using async and await in main dart
  await Firebase.initializeApp(); // make firebase is ready
  FirebaseMessaging.onBackgroundMessage(backgroundMessage);
  runApp(Main_app());
}
class Main_app extends StatelessWidget
{


  @override
  Widget build(BuildContext context) {
    late bool islogin;
    var user = FirebaseAuth.instance.currentUser;
    if (user == null)
    {
      islogin = false;
    }
    else
    {
      islogin = true ;
    }
    // TODO: implement build
    return  MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.blueAccent,
          textTheme: TextTheme(
              headline2: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )
          )
      ),
      debugShowCheckedModeBanner: false,
      home: islogin == false ?  Login() : Homepage(),
      routes: {
        "login" :(context) => Login(),
        "homepage" :(context)=>Homepage(),
        "addnotes":(context)=>AddNotes(),
        "sginin" :(context) => Signin(),
        "test" :(context) => testpage(),
        "editnote" :(context) => EditNotes(),
      },
    );
  }
}

