import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';


import '../Usefull/colors.dart';
import 'package:iconsax/iconsax.dart';



class chat extends StatefulWidget {
  Map data;

  chat({Key? key,required this.data}) : super(key: key);

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isHide = false;
  final fieldText = TextEditingController();
  List<Widget> sendButton = [];
  String msg = "";
  int _sendIndex = 0;
  bool _showSend = false;

  final ScrollController _scrollController = ScrollController();

  String chatID = "";

  String id_one = "";
  String id_two = "";

  Map<dynamic, dynamic> chatData = {};
  List<Widget> allChats = [];
  List<String> chatIds = [];

  bool noChats = false;


  @override
  void initState() {
    getChatId();
  }

  getChatId() async {
    var x = widget.data['uid'].toString();
    var userId = user!.uid;
    List l = [x, userId];
    l.sort();
    var p = l[0];
    var q = l[1];
    id_one = p;
    id_two = q;
    setState(() {
      chatID = "$p&$q";
    });

    final ref = await FirebaseDatabase.instance.ref('chats').child(chatID);
    await ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (data != null) {
          chatData = data;

          List a = chatData.keys.toList()..sort();

          print(chatData);
          // for(var x in chatData.keys) {
          for (var x in a) {
            print("batman $x");
            Future.delayed(Duration(seconds: 1), () {
              scroolDown();
            });
            var sender = x.toString().split("&")[1].toString();
            String mainMsg = chatData[x]['msg'];
            var item = chatbox(id: sender, msg: mainMsg);
            if (!chatIds.contains(x)) {
              setState(() {
                allChats.add(item);
                chatIds.add(x);
              });
            }
          }
        }
      } else {
        // toaster(context,'null');
        setState(() {
          noChats = true;
        });

      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: bgColor,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leadingWidth: 100,
          elevation: 0.0,
          leading: Row(
            children: [
              IconButton(
                icon: Icon(Iconsax.arrow_left_2,color: Colors.white,),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              Avatar(
                  widget.data['index'], 20.0)
            ],
          ),
          title: mainText(widget.data['name'], Colors.white, 15.0, FontWeight.normal,1),
        ),
        body: Stack(

          children: [
            Container(
              decoration: BoxDecoration(),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              margin: EdgeInsets.only(bottom: 70.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                controller: _scrollController,
                child: Column(
                  children: allChats,
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 3.0),
              child: Row(
                children: [
                  Flexible(
                      child: TextFormField(
                        controller: fieldText,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontFamily: 'mon'
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          filled: true,
                          hintText: "Message...",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'mon',
                            fontSize: 13.0,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'mon',
                            fontSize: 13.0,
                          ),
                          errorStyle: TextStyle(
                            color: errorColor,
                            fontFamily: 'mon',
                            fontSize: 12.0,
                          ),


                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(width: 3.0,color: mainColor)
                          ),
                        ),
                        onChanged: (text) {
                          msg = text;
                          if (text.isNotEmpty) {
                            setState(() {
                              _sendIndex = 1;
                              _showSend = true;
                            });
                          } else {
                            setState(() {
                              _sendIndex = 0;
                              _showSend = false;
                            });
                          }
                        },
                      )
                  ),
                  SizedBox(width: 2.0,),
                  Visibility(
                    visible: msg.isNotEmpty,
                    child: FloatingActionButton(onPressed: (){
                      Send();
                    },
                      backgroundColor:mainColor,
                      child: Icon(Iconsax.send_1,color: Colors.white,),),
                  )
                ],
              ),
            ),
            Visibility(
              visible: noChats,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.glass,color: mainColor,size: 40.0,),
                    mainText("START A CONVERSATION", mainColor, 20.0, FontWeight.normal, 1),

                  ],
                ),
              ),
            ),
            loaderss(isHide, context)

          ],
        ),
      ),
    );
  }
  Send() async {
    setState(() {
      noChats = false;
    });
    var id = user!.uid;
    String dates = DateTime.now().toIso8601String().split(".")[0].toString();
    String disId = dates + "&" + id;
    String datekey = DateTime.now().toString();
    var sendMsg = {
      disId: {
        'msg': msg,
        'date': datekey,
      }
    };

    var lastmsg = {
      'dt': {
        'id_one': id_one,
        'id_two': id_two,
        "lastmsg": msg,
        "date": DateTime.now().toString()
      }
    };
    final ref = FirebaseDatabase.instance.reference();
    ref.child('chats').child(chatID).update(sendMsg).then((value) => {
      setState(() {
        msg = "";
        fieldText.clear();
        scroolDown();
        ref.child('chats').child(chatID).update(lastmsg);
      })
    });
  }

  scroolDown() async {
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut);
  }

}


class chatbox extends StatefulWidget {
  String id;
  String msg;
  chatbox({Key? key, required this.id, required this.msg}) : super(key: key);

  @override
  State<chatbox> createState() => _chatboxState();
}

class _chatboxState extends State<chatbox> {
  User? user = FirebaseAuth.instance.currentUser;
  Color boxColor = bgLight;
  bool isUser = false;
  MainAxisAlignment alignment = MainAxisAlignment.start;
  double topleft = 0.0;
  double topright = 20.0;

  @override
  void initState() {
    var x = user!.uid;
    if (x == widget.id) {
      setState(() {
        boxColor = mainColor;
        isUser = true;
        alignment = MainAxisAlignment.end;
        topright = 0.0;
        topleft = 20.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: transparent_overlay,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          // Visibility(
          //     visible: isUser,
          //     child: SizedBox(
          //   width: MediaQuery.of(context).size.width * 0.30,
          // )),

          GestureDetector(
            child: Container(
              constraints: BoxConstraints(
                  minWidth: 20,
                  maxWidth: MediaQuery.of(context).size.width * 0.68),
              color: transparent_overlay,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(topleft),
                    topRight: Radius.circular(topright),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),

                  ),
                ),
                color: boxColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: mainTextFAQS(
                      widget.msg, Colors.white, 15.0, FontWeight.normal, 100),
                ),
              ),
            ),
          ),
          // Visibility(
          //     visible: !isUser,
          //     child: SizedBox(
          //       width: MediaQuery.of(context).size.width * 0.30,
          //     )),
        ],
      ),
    );
  }
}
