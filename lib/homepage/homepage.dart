import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/crud/view.dart';
import '../crud/editnote.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget
{
  //const Login({Key? key}) : super(key: key);
  const Homepage({Key? key}) : super (key: key);
  @override
  _Homepagestate createState()=> _Homepagestate();
}
class _Homepagestate extends State<Homepage>
{
  var fbm = FirebaseMessaging.instance;
  var user_data = FirebaseFirestore.instance.collection("Notes");
 List users = [];
  get_user() async
  {
    var firebase_user=null ;
     firebase_user =await FirebaseFirestore.instance.collection("user");
    await firebase_user.get().then((value) {
      value.docs.forEach((element) {
       users.add(element.data());
      });
    });
      print(users);
  }
  getUser()
  {
    var user = FirebaseAuth.instance.currentUser;
    print (user?.email);
  }
  get_permission() async
  {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  //////////////////////
insert_token() async
{
  print("start============");
  var user = await FirebaseAuth.instance.currentUser?.uid;
 // int i=0 ;
   // var exist_user = FirebaseFirestore.instance.collection("user_token").where("user",isEqualTo:user).get().then((value) {
  //   value.docs.forEach((element) {
  //     i++;
  //   });
  // });
    FirebaseFirestore.instance.collection("user_token").doc(user).set(
      {
        "Email": FirebaseAuth.instance.currentUser?.email,
        "token": await FirebaseMessaging.instance.getToken(),
        "user": user
      }
      ,).then((value) {
      print("token inserted ++++++++");
    }).catchError((e) {
      print(e.toString());
    });

}
  send_notification(String title) async
  {
    String serverToken = "AAAAzU13JXI:APA91bEiuSlzlfvgXElj59uHPegQ72dTmyZMnxZzPufTyjra-YEB_kz-y7G20qW-5C8SYkSoqq5YUaXdTDoZL1uHBFmaO3LaM7cn5P4xTb1r4cm3y5xiRBSSr_ZJmljIj64gACupKkcf";
    var firebaseMessaging = fbm;
    await http.post(
       Uri.parse( 'https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
        <String, dynamic>{
        'notification': <String, dynamic>{
        'body': 'this is a body1111',
        'title': '$title'
        },
        'priority': 'high',
        'data': <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done'
        },
        'to': await firebaseMessaging.getToken(),  //  "/topics/mostafa"
        },
    ));
  }

  /////////////////


  Future inital_Msessage() async {
    get_permission();
    var message = null;
    message = FirebaseMessaging.instance.getInitialMessage();
    if(message != null) //if click on notification
      {
        print(message);
        print("========================adddddd");
        Navigator.of(context).pushNamed("test");
    }
    else
      {
        Navigator.of(context).pushNamed("homepage");
      }
  }
  @override
  void initState()  {
    print(fbm.getToken().then((token) {
      print("==============token============");
      print("===========================");
      print( fbm.getToken().toString());
      FirebaseMessaging.onMessage.listen((event) {
        print(event.notification?.body);
        AwesomeDialog(
          title: "${event.notification?.title}",
          context: context,
          body: Text("${event.notification?.body}"),
          btnOkOnPress: (){}
        ).show();
      });
      inital_Msessage();
    }));
      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        Navigator.of(context).pushNamed("addnotes");
      });
    insert_token();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //double mdq = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: (){
          Navigator.of(context).pushNamed("addnotes");
        },
        backgroundColor: Theme.of(context).primaryColor,
        ),
        appBar: AppBar(
          leading: InkWell(
            onTap: (){
              setState(() {

              });
            },
            child:Icon(Icons.cached),
          ),
          title: Text("Home sPage"),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
       actions: [
         IconButton(onPressed: () async {
          await  FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacementNamed("login");
         }, icon: Icon(Icons.exit_to_app)),
         IconButton(onPressed: (){
           send_notification('titleeeeeeeeeeeeeeeee');
         },icon: Icon(Icons.add), )
       ],
        ),
body: FutureBuilder(future: user_data.where("user",isEqualTo: FirebaseAuth.instance.currentUser?.uid ).get(),builder:(context,snapshot)  {
  if(snapshot.hasData)
    {
      return ListView.builder(itemCount: snapshot.data?.docs.length ,itemBuilder: (context,i)
      {
        return 
          Dismissible(key: UniqueKey(),child: ListNotes(notes: snapshot.data?.docs[i],docid:snapshot.data?.docs[i].id ,),onDismissed: (diection) async {
           await user_data.doc(snapshot.data?.docs[i].id).delete().then((value){
             print("row deleted");
           } );
            await FirebaseStorage.instance.refFromURL(snapshot.data?.docs[i]['image_url']).delete().then((value) {
              print("==================");
              print("image deleted");
            }).catchError((e){
              print(e.toString());
            });
          },);

      }
      );
    }
  else
    {
      return Center( child: CircularProgressIndicator(),);
    }
            },)
      ),
    );
  }
}
class ListNotes extends StatelessWidget
{
  final  notes ;
  final docid;
  ListNotes ({this.notes,this.docid});
  @override
  Widget build(BuildContext context) {
    return Card(
      child:Row(
        children: [
          Expanded(
            child: Container(
              height: 100,
              child: ListTile(
                title: Center(child: Image.network(notes['image_url'],width: 80,height: 80,))   //Image.network("${notes['image_url']}",height: 20,width: 20,) //Text("${notes['note']}"),
              ),
            ),
            flex: 1,
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: ListTile(
                      title: Text("${notes['title']}"),
                      subtitle: Text("${notes['note']}"),
                      trailing: IconButton(icon :Icon(Icons.edit),onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return EditNotes(docid: docid,note:notes);
                      }));
                      },),
                    ),
                  ),
                  Expanded(child: IconButton(icon: Icon(Icons.send,color: Colors.red,),onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return Viewpage(docid: docid,note:notes);
                    }));
                  },),flex: 1,),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}