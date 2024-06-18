import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // flutter pub add animate_do
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uiet_docs/globals.dart' as globals;

class SignInScreen extends StatefulWidget {
  const SignInScreen(
      {super.key, required this.gotoSignUp, required this.gotoProfileScreen});
  final void Function() gotoSignUp;
  final void Function() gotoProfileScreen;
  @override
  State<StatefulWidget> createState() {
    return _SignInScreen();
  }
}

class _SignInScreen extends State<SignInScreen> {
  final auth = FirebaseAuth.instance;

  signInFun() async {
    if (globals.email.text != '' && globals.password.text != '') {
      try {
        await auth.signInWithEmailAndPassword(
            email: globals.email.text, password: globals.password.text);
        if (auth.currentUser!.emailVerified) {
          globals.isSignedIn = true;
          var databaseRef = FirebaseDatabase.instanceFor(
                  app: Firebase.app(),
                  databaseURL:
                      <databaseURL>)
              .ref('Users')
              .child(auth.currentUser!.uid);
          var dataSnapshot = await databaseRef.get();
          List userList =
              dataSnapshot.value as List; // Key is uid and value is list.
          globals.userName.text = userList[0];
          globals.userBranch = userList[1];
          globals.userBatch = userList[2];

          var storageRef = FirebaseStorage.instance.ref();
          var fileRef = await storageRef
              .child('/photos/${auth.currentUser!.uid}/')
              .listAll();
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

          widget.gotoProfileScreen();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 107, 107, 107),
              content: Text(
                'Signed in successfully!',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        } else {
          auth.currentUser!.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 107, 107, 107),
              content: Text(
                'There is no account linked with the given email. Click on Sign up to create account.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 107, 107, 107),
              content: Text(
                'Please enter valid email address.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        } else if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 107, 107, 107),
              content: Text(
                'There is no account linked with the given email. Click on Sign up to create account.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        } else if (e.code == 'wrong-password') {
          if (auth.currentUser!.emailVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Color.fromARGB(255, 107, 107, 107),
                content: Text(
                  'Incorrect Password!',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
          } else {
            auth.currentUser!.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Color.fromARGB(255, 107, 107, 107),
                content: Text(
                  'There is no account linked with the given email. Click on Sign up to create account.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
          }
        }
      }
    }
  }

  resetPassword() async {
    if (globals.email.text != '') {
      try {
        await auth.sendPasswordResetEmail(
            email: globals.email
                .text); // Disable enumeration protection in Firebase Auth Settings.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 107, 107, 107),
            content: Text(
              'Password reset link send to your email successfully. Please check your mail.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 107, 107, 107),
              content: Text(
                'Please enter a valid email address.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        } else if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 3),
              backgroundColor: Color.fromARGB(255, 107, 107, 107),
              content: Text(
                'There is no account linked with the given email. Click on Sign up to create account.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          );
        } 
      }
    }
  }

  DateTime preBackPress = DateTime.now();
  onDoubleBackPressed(didPop) {
    if (didPop) {
      return;
    }
    final timeGap = DateTime.now().difference(preBackPress);
    final cantExit = timeGap <= const Duration(seconds: 1);
    preBackPress = DateTime.now();
    if (cantExit) {
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

  bool passwordVisible = true;

  @override
  Widget build(context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(children: [
      SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/profile_bg2.jpg'),
            Image.asset('assets/images/profile_bg2.jpg')
          ],
        ),
      ),
      Container(
        height: screenHeight,
        width: screenWidth,
        color: Colors.white.withOpacity(.8),
      ),
      PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          onDoubleBackPressed(didPop);
        },
        child: SingleChildScrollView(
          // When keyboard is open the screen shifts upwards.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              FadeInDown(
                child: const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * .12,
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: const Text(
                  "Welcome",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  height: screenHeight * .45,
                  width: screenWidth * .9,
                  child: Column(
                    children: [
                      FadeInUp(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          child: TextField(
                            controller: globals.email,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email Address",
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 2,
                        width: screenWidth * .85,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FadeInUp(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          child: TextField(
                            obscureText: passwordVisible,
                            controller: globals.password,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: screenWidth * .12,
                                  top: screenHeight * .015),
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(colors: [
                                Color.fromRGBO(255, 159, 159, 1),
                                Color.fromRGBO(255, 99, 99, 1),
                              ])),
                          child: TextButton(
                            onPressed: signInFun,
                            child: const Center(
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: TextButton(
                          onPressed: resetPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInLeft(
                            duration: const Duration(milliseconds: 1000),
                            child: const Text(
                              "Don't have an account?",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          FadeInRight(
                            duration: const Duration(milliseconds: 1000),
                            child: TextButton(
                              onPressed: () {
                                globals.email.text = '';
                                globals.password.text = '';
                                globals.confirmPassword.text = '';
                                widget.gotoSignUp();
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInLeft(
                            duration: const Duration(milliseconds: 1000),
                            child: const Text(
                              "NOTE :",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          FadeInRight(
                            duration: const Duration(milliseconds: 1000),
                            child: const Text(
                              " For contribution, Sign In is required.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    ]);
  }
}
