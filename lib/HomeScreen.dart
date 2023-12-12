

import 'package:chatter/Auth/sign_in.dart';
import 'package:chatter/Chat.dart';
import 'package:chatter/RoomChat.dart';
import 'package:chatter/Usefull/Buttons.dart';
import 'package:chatter/Usefull/Colors.dart';
import 'package:chatter/Usefull/Functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_database/firebase_database.dart';




class homeScreen extends StatefulWidget {
  Map data;
  homeScreen({super.key,required this.data});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  bool isHide = false;
  List<Widget> allUsers = [];
  List<Widget> allRooms = [];
  FirebaseAuth auth = FirebaseAuth.instance;


  getAllUsers() async {
    setState((){
      isHide = true;
    });
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore
        .collection('user')
        .get();

    if (querySnapshot != null) {
      final allData = querySnapshot.docs.map((e) => e.data()).toList();
      if (allData.length != 0) {

          for(var i in allData){
            Map m = i as Map;
            if(m['uid'] != auth.currentUser!.uid) {
              var a = oneItem(data: i as Map);
              setState(() {
                allUsers.add(a);
              });
            }

          }
      }
    }
    setState(() {
      isHide = false;
    });
  }

  getRooms() async {
    try {
      final ref = await FirebaseDatabase.instance.ref('rooms');
      final snapshot = await ref.once(); // Use once() to retrieve data only once
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        if (data != null) {
          setState(() {
            allRooms = [];
          });
          List<String> roomKeys = data.keys.cast<String>().toList()..sort();
          for (String roomKey in roomKeys) {
            getOneRoom(roomKey);
          }
        }
      } else {
        // Handle the case where there is no data
      }
    } catch (error) {
      // Handle any errors that occur during the data retrieval
      print('Error fetching rooms: $error');
    }
  }

  Future<void> getOneRoom(String roomId) async {
    try {
      final ref = await FirebaseDatabase.instance.ref('chats').child(roomId);
      final snapshot = await ref.once(); // Use once() to retrieve data only once

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        if (data != null) {
          var a = oneItem(data: data, room: true);
          setState(() {
            allRooms.add(a);
          });
        }
      }
    } catch (error) {
      // Handle any errors that occur during the data retrieval
      print('Error fetching room $roomId: $error');
    }
  }


  @override
  void initState() {
    getAllUsers();
    getRooms();
  }

  String roomName = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: mainTextFAQS("  Chatter", textColor,15.0, FontWeight.bold, 1),
        actions: [
          TextButton(onPressed: (){
            FirebaseAuth.instance.signOut();
            navScreen(logIn(), context, true);
          }, child: mainText("LOGOUT", textDark, 10.0, FontWeight.bold,1))
        ],
        ),
        
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Column(
                    children: allUsers,
                  ),
                  Column(
                    children: allRooms,
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 20.0),
              child: FloatingActionButton(
                mini:false,
                backgroundColor: mainColor,
                onPressed: (){
                  newbottoms(context, Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.name,
                        maxLength: 50,
                        style: TextStyle(
                            color: textDark,
                            fontSize: 13.0,
                            fontFamily: 'mons'),
                        decoration: InputDecoration(
                          filled: true,
                          counterText: "",
                          fillColor: lightGrey,
                          hintText: "Room Name",
                          hintStyle: TextStyle(
                            fontFamily: 'mons',
                            fontSize: 13.0,
                            color: Colors.grey[500],
                          ),
                          errorStyle: TextStyle(
                            color: errorColor,
                            fontFamily: 'mons',
                            fontSize: 10.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: textColor,width: 0),
                            borderRadius: BorderRadius.circular(20.0),

                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: textColor,
                                width: 0
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: errorColor,
                                width: 0
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onChanged: (text) {
                          roomName = text;
                        },
                        validator: (value) {
                          if(value!.isEmpty){
                            return("Please Room Name");
                          }
                        },
                      ),

                      SizedBox(height: 20.0,),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: btnsss("CREATE ROOM", () {
                          createRoom(context,roomName);
                        }, mainColor, Colors.white),
                      ),

                    ],
                  ));
                },
                child: Icon(Iconsax.add,color: Colors.white,),
              ),
            ),
            loaderss(isHide, context)
          ],
        ),
      ),
    );
  }

  createRoom(BuildContext context,String name) async{
    final ref = FirebaseDatabase.instance.reference();
    String aa = generateRandomString(10);
    var sendMsg = {
      'room': true ,
      'index':aa,
      'name':name,
    };
    var rooms = {
      aa:aa,
    };
    ref.child('chats').child(aa).update(sendMsg).then((value) => {
      Navigator.of(context).pop(false),
      ref.child('rooms').update(rooms).then((value) => {
        getRooms()

      }),
    });

  }
}



class oneItem extends StatelessWidget {
  Map data;
  bool room;
  oneItem({super.key,required this.data,this.room = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(room){
          navScreen(roomChat(roomId: data['index'], roomName:data['name']), context, false);
        }
        else {
          navScreen(chat(data: data), context, false);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 3.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          elevation: 0.0,
          color: bgLight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Avatar(data['index'], 30.0),
                SizedBox(width: 10.0,),
                mainTextFAQS(data['name'], (room)?mainColor:Colors.white, 15.0, FontWeight.normal, 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

