import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../component/alterdig.dart';
import 'Signin.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

showLoading(context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("plz wait ..."),
          content: Container(
              height: 50, child: Center(child: CircularProgressIndicator())),
        );
      });
}

class LoginState extends State<Login> {
  GlobalKey<FormState> sginin_form = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    UserCredential usercreaential;
    // TODO: implement build
    var Email, Password;

    return Scaffold(
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
                  child: Column(
                    children: [
                      Text('log in page'),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        onSaved: (text) {
                          Email = text!;
                        },
                        validator: (value) => EmailValidator.validate(value!)
                            ? null
                            : "Please enter a valid email",
                        decoration: InputDecoration(
                            prefix: Icon(
                              Icons.person,
                            ),
                            hintText: "UserName",
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
                            hintText: "UserName",
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
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("if you do not have account     "),
                            InkWell(
                              child: Text(
                                "click here",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed("sginin");
                              },
                            )
                          ],
                        ),
                      ),
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
                                  .signInWithEmailAndPassword(
                                email: Email,
                                password: Password,
                              )
                                  .then((value) {
                                print("google account inserted");
                              }).catchError((e) {
                                print(e.toString());
                              });

                              Navigator.of(context)
                                  .pushReplacementNamed("homepage");
                              print('usercreated');
                            } on FirebaseAuthException catch (e) {
                              Navigator.of(context).pop();
                              if (e.code == 'weak-password') {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.NO_HEADER,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'weak-password',
                                  body: TextFormField(),
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () {},
                                )..show();
                                print('The password provided is too weak.');
                              } else if (e.code == 'email-already-in-use') {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.NO_HEADER,
                                  animType: AnimType.BOTTOMSLIDE,
                                  title: 'email-already-in-use',
                                  body: TextFormField(),
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () {},
                                )..show();

                                print(
                                    'The account already exists for that email.');
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          showLoading(context);
                          UserCredential usercredential =
                              await signInWithGoogle();
                          Navigator.of(context)
                              .pushReplacementNamed("homepage");
                        },
                        child: Ink(
                          color: Color(0xFF397AF3),
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Image.asset('images/googlr.png',
                                    width: 20, height: 20),
                                SizedBox(width: 12),
                                Text('Sign in with Google'),
                              ],
                            ),
                          ),
                        ),
                      )
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
    if (formdata!.validate()) {
      formdata.save();
      print("valid");
    } else {
      print("not valid");
    }
  }
}
