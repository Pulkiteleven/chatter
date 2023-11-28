

import 'package:chatter/Auth/sign_in.dart';
import 'package:chatter/Chat.dart';
import 'package:chatter/Usefull/Colors.dart';
import 'package:chatter/Usefull/Functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class homeScreen extends StatefulWidget {
  Map data;
  homeScreen({super.key,required this.data});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  bool isHide = false;
  List<Widget> allUsers = [];
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


  @override
  void initState() {
    getAllUsers();
  }

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
                children: allUsers,
              ),
            ),
            loaderss(isHide, context)
          ],
        ),
      ),
    );
  }
}

class oneItem extends StatelessWidget {
  Map data;
  oneItem({super.key,required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        navScreen(chat(data: data), context, false);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 3.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          elevation: 0.0,
          color: bgLight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Avatar(data['index'], 30.0),
                SizedBox(width: 10.0,),
                mainTextFAQS(data['name'], Colors.white, 15.0, FontWeight.normal, 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

