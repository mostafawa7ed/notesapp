import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:notes/component/alterdig.dart';
import 'login.dart';

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SigninState();
  }
}

class SigninState extends State<Signin> {
  var massage = ' ';
  GlobalKey<FormState> sginin_form = new GlobalKey<FormState>();
  late String Password, Email, Name;
  @override
  Widget build(BuildContext context) {
    UserCredential userCredential;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes App'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Login();
                }));
              }),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Container(
                    height: 200,
                    width: 200,
                    child: Image.asset(
                      "images/AAA.webp",
                      height: 200,
                      width: 200,
                    ))),
            Container(
              padding: EdgeInsets.all(20),
              child: Form(
                  key: sginin_form,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      Text('signin page'),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (val) {
                          if (RegExp(r'^[a-z]+$').hasMatch(val!) ||
                              RegExp(r'^[A-Z]+$').hasMatch(val!)) {
                            return null;
                          } else {
                            return 'must char only';
                          }
                        },
                        decoration: InputDecoration(
                            prefix: Icon(
                              Icons.person,
                            ),
                            hintText: "Name",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 1,
                                )),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 1,
                                ))),
                        onSaved: (text) {
                          Name = text!;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            prefix: Icon(
                              Icons.person,
                            ),
                            hintText: "Email",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 1,
                                )),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 1,
                                ))),
                        onSaved: (text) {
                          Email = text!;
                        },
                        validator: (value) => EmailValidator.validate(value!)
                            ? null
                            : "Please enter a valid email",
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        onSaved: (text) {
                          Password = text!;
                        },
                        validator: (text) {
                          if (text!.length < 8) {
                            //print(text!.length);
                            return "not valid password";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            prefix: Icon(
                              Icons.password_sharp,
                            ),
                            hintText: "PassWord",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 1,
                                )),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 1,
                                ))),
                      ),
                      Text('$massage'),
                      Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            shadowColor: Colors.black,
                            elevation: 20,
                          ),
                          onPressed: () async {
                            send();
                            try {
                              show_loading(context);
                              print('before try');
                              print(Email + Password);
                              final credential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: Email,
                                password: Password,
                              );
                              print(credential.user?.emailVerified);
                              /* if(credential.user?.emailVerified == false  )
                            {
                              var user = FirebaseAuth.instance.currentUser;
                              print('test 1');
                              await user?.sendEmailVerification();
                              print('test 2');
                            }*/
                              if (credential != null) {
                                await FirebaseFirestore.instance
                                    .collection("user")
                                    .add({
                                  "username": Name,
                                  "Email": Email,
                                  "password": Password
                                }).then((value) {
                                  print("new user inserted with svaed data");
                                }).catchError((e) {
                                  print("==================");
                                  print(e.toString());
                                });
                              }
                              Navigator.of(context)
                                  .pushReplacementNamed("homepage");
                              print('usercreated');
                            } on FirebaseAuthException catch (e) {
                              setState(() {});
                              if (e.code == 'weak-password') {
                                AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.scale,
                                    title: "weak oassword",
                                    desc: "must make password is complex",
                                    btnOkOnPress: () {})
                                  ..show();
                                print('The password provided is too weak.');
                                Navigator.of(context).pop();
                              } else if (e.code == 'email-already-in-use') {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.rightSlide,
                                  title: 'email is used',
                                  desc: 'you must change the Email',
                                  btnOkOnPress: () {},
                                )..show();
                                print(
                                    'The account already exists for that email.');
                                massage =
                                    'The account already exists for that email.';
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              print(e);
                            }
                            //usercreaential = await FirebaseAuth.instance.signInAnonymously();
                            //print(usercreaential.user?.uid);
                          },
                          child: Text(
                            "Create Acount",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  send() {
    print("send");
    var formdata = sginin_form.currentState;
    // print(formdata);
    if (formdata!.validate()) {
      formdata.save();
      print("valid");
      //print('$Email');
      //print("$Password");
    } else {
      print("not valid");
    }
  }
}
