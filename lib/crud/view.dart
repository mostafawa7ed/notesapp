import 'package:flutter/material.dart';
class Viewpage extends StatefulWidget {
  final docid,note;
  const Viewpage({Key? key,this.docid,this.note}) :super (key: key);

  @override
  _Viewpagestate createState() => _Viewpagestate();
}

class _Viewpagestate extends State<Viewpage>
{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Page"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text("${widget.note['note']}"),
              Text("${widget.note['title']}"),
              Image.network("${widget.note['image_url']}",height: 200),

            ],
          ),
        ),
      ),
    );
  }
}
