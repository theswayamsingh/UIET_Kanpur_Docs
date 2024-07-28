import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uiet_docs/globals.dart' as globals;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.gotoSignInScreen});
  final void Function() gotoSignInScreen;
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreen();
  }
}

class _ProfileScreen extends State<ProfileScreen> {
  final auth = FirebaseAuth.instance;

  getUserDetail() async {
    if (globals.userPhoto == null) {
      var user = FirebaseAuth.instance.currentUser;
      var databaseRef = FirebaseDatabase.instanceFor(
              app: Firebase.app(),
              databaseURL:
                  '<DATABASE URL>')
          .ref('Users')
          .child(user!.uid);
      var dataSnapshot = await databaseRef.get();
      List userList =
          dataSnapshot.value as List; // Key is uid and value is list.
      globals.userName.text = userList[0];
      globals.userBranch = userList[1];
      globals.userBatch = userList[2];
      var storageRef = FirebaseStorage.instance.ref();
      var fileRef = await storageRef.child('/photos/${user.uid}/').listAll();
      if (fileRef.items.isNotEmpty) {
        String url = await fileRef.items[0].getDownloadURL();
        File file = await DefaultCacheManager().getSingleFile(url);
        globals.userPhoto = CircleAvatar(
          radius: 110,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(file),
        );
      } else {
        globals.userPhoto = const CircleAvatar(
          radius: 110,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(
            'assets/images/user.png',
          ),
        );
      }
    }
    return true;
  }

  signOutFun() {
    auth.signOut();
    globals.isSignedIn = false;
    globals.isEmailVerified = false;
    globals.email.text = '';
    globals.password.text = '';
    globals.confirmPassword.text = '';
    globals.userName.text = '';
    globals.userBranch = 'CSE';
    globals.userBatch = '2021-2025';
    widget.gotoSignInScreen();
  }

  DateTime preBackPress = DateTime.now();
  onDoubleBackPressed(didPop) {
    if (didPop) {
      return;
    }
    final timeGap = DateTime.now().difference(preBackPress);
    final cantExit = timeGap >= const Duration(seconds: 1);
    preBackPress = DateTime.now();
    if (cantExit == false) {
      SystemNavigator.pop().then((_) {
        exit(0);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Color.fromARGB(255, 107, 107, 107),
          content: Text(
            'Press back button again to exit the app.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onDoubleBackPressed(didPop);
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/images/profile_bg2.jpg'),
                Image.asset('assets/images/profile_bg2.jpg'),
              ],
            ),
          ),
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.white.withOpacity(.75),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FadeInDown(
                  child: Padding(
                    padding: EdgeInsets.all(screenHeight*.012),
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: screenHeight*.025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: getUserDetail(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData==false){
                      return Padding(
                        padding: EdgeInsets.only(top: screenHeight*.3),
                        child: const Center(
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth*.07, right: screenWidth*.07, top: screenHeight*.15),
                          child: Container(
                              padding: EdgeInsets.all(screenHeight*.012),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  FadeInDown(
                                    child: Center(child: globals.userPhoto),
                                  ),
                                  FadeInDown(
                                    child: Center(
                                      child: Text(
                                        globals.userName.text,
                                        style: GoogleFonts.lato(
                                          fontSize: screenHeight*.025,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  FadeInDown(
                                    child: Center(
                                      child: Text(
                                        'B-Tech ${globals.userBranch}',
                                        style: GoogleFonts.lato(
                                          fontSize: screenHeight*.02,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  FadeInDown(
                                    child: Center(
                                      child: Text(
                                        globals.userBatch,
                                        style: GoogleFonts.lato(
                                          fontSize: screenHeight*.015,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: screenWidth*.07, right: screenWidth*.07, top: screenHeight*.025),
                            child: Container(
                              height: screenHeight*.055,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(colors: [
                                    Color.fromRGBO(255, 159, 159, 1),
                                    Color.fromRGBO(255, 99, 99, 1),
                                  ])),
                              child: TextButton(
                                onPressed: signOutFun,
                                child: const Center(
                                  child: Text(
                                    "Sign Out",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
