import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // flutter pub add animate_do
import 'package:google_fonts/google_fonts.dart';
import 'package:uiet_docs/globals.dart' as globals;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen(
      {super.key, required this.gotoSignIn, required this.gotoProfileScreen});
  final void Function() gotoSignIn;
  final void Function() gotoProfileScreen;
  @override
  State<StatefulWidget> createState() {
    return _SignUpScreen();
  }
}

class _SignUpScreen extends State<SignUpScreen> {
  final auth = FirebaseAuth.instance;
  User? user;
  late Timer timer;

  emailVerfy() async {
    user = auth.currentUser;
    await user!.reload();
    if (user!.emailVerified) {
      globals.emailSent = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Color.fromARGB(255, 107, 107, 107),
          content: Text(
            'Email Address has been successfully verified!',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
      timer.cancel();
      setState(() {
        // build function is again called with profile set-up screen.
        globals.isEmailVerified = true;
      });
    }
  }

  sendVerificationLink() async {
    if (globals.email.text != '' &&
        globals.password.text != '' &&
        globals.confirmPassword.text != '') {
      if (globals.password.text != globals.confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Color.fromARGB(255, 107, 107, 107),
            content: Text(
              'Password and Confirm Password should be same.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      } else {
        //When both passwords are same.
        try {
          await auth
              .createUserWithEmailAndPassword(
                  email: globals.email.text, password: globals.password.text)
              .then((_) {
            auth.currentUser!.sendEmailVerification();
            globals.emailSent = true;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Color.fromARGB(255, 107, 107, 107),
                content: Text(
                  'Verification Email sent successfully. Please check your mail.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
            timer = Timer.periodic(const Duration(seconds: 3), (timer) {
              emailVerfy();
            });
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Color.fromARGB(255, 107, 107, 107),
                content: Text(
                  'Password is too weak. Please Provide a strong password.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
          } else if (e.code == 'email-already-in-use') {
            // user = auth.currentUser;
            // if (user!.emailVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Color.fromARGB(255, 107, 107, 107),
                content: Text(
                  'This email is already registered to an account. Sign in instead.',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
            // } else {
            //   user!.sendEmailVerification();
            //   user!.updatePassword(globals.password.text);
            //   globals.emailSent = true;
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //       duration: Duration(seconds: 3),
            //       backgroundColor: Color.fromARGB(255, 107, 107, 107),
            //       content: Text(
            //         'Verification Email sent successfully. Please check your mail.',
            //         style: TextStyle(
            //           fontSize: 18,
            //         ),
            //       ),
            //     ),
            //   );
            //   timer = Timer.periodic(const Duration(seconds: 3), (timer) {
            //     emailVerfy();
            //   });
            // }
          } else if (e.code == 'invalid-email') {
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
          }
        }
      }
    }
  }

  var photo = const CircleAvatar(
    backgroundImage: AssetImage('assets/images/user.png'),
    backgroundColor: Colors.white,
    radius: 90,
  );
  FilePickerResult? result;
  selectPhoto() async {
    result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png']);
    if (result != null) {
      setState(() {
        photo = CircleAvatar(
          backgroundImage: FileImage(File(result!.files.first.path!)),
          backgroundColor: Colors.white,
          radius: 90,
        );
      });
    }
  }

  void signUp() async {
    if (globals.userName.text != '') {
      widget.gotoProfileScreen();
      globals.isSignedIn = true;

      //Updating database.
      var databaseRef = FirebaseDatabase.instanceFor(
              app: Firebase.app(),
              databaseURL:
                  <databaseURL>)
          .ref();
      var usersRef = databaseRef.child('Users');
      await usersRef.update({
        auth.currentUser!.uid.toString(): [
          globals.userName.text,
          globals.userBranch,
          globals.userBatch,
          0
        ]
      });

      // Uploading userPhoto to cloud.
      if (result != null) {
        final storageRef = FirebaseStorage.instance.ref();
        var pathOfStorage = '/photos/${auth.currentUser!.uid}/';
        final uploadRef =
            storageRef.child(pathOfStorage).child(result!.files.first.name);
        await uploadRef.putFile(File(result!.files.first.path!));
        globals.userPhoto = CircleAvatar(
          radius: 110,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(File(result!.files.first.path!)),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Color.fromARGB(255, 107, 107, 107),
          content: Text(
            'Account registration successful!',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Color.fromARGB(255, 107, 107, 107),
          content: Text(
            'Please enter your username.',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }
  }

  onBackPressed(didPop) {
    if (globals.isEmailVerified == false) {
      if (didPop) {
        return;
      }
      if (globals.emailSent) {
        auth.currentUser!.reload();
        auth.currentUser!.delete();
      }
      globals.emailSent = false;
      globals.email.text = '';
      globals.userName.text = '';
      globals.password.text = '';
      globals.confirmPassword.text = '';
      widget.gotoSignIn();
    } else {
      if (didPop) {
        return;
      }
      auth.currentUser!.reload();
      auth.currentUser!.delete();
      globals.emailSent = false;
      globals.isEmailVerified = false;
      globals.email.text = '';
      globals.userName.text = '';
      globals.password.text = '';
      globals.confirmPassword.text = '';
      widget.gotoSignIn();
    }
  }

  bool passwordVisible = true;
  bool confirmPasswordVisible = true;

  @override
  Widget build(context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return globals.isEmailVerified == false
        ? Stack(children: [
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
                onBackPressed(didPop);
              },
              child: SingleChildScrollView(
                // When keyboard is open the screen shifts upwards.
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: screenHeight * .15,
                      ),
                      FadeInDown(
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          "Create Account",
                          style: GoogleFonts.lato(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 10),
                        child: Container(
                          height: 3,
                          color: Colors.red,
                        ),
                      ),
                      FadeInUp(
                        // Email Text Field.
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: 60,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 2,
                          width: 320,
                          color: Colors.red,
                        ),
                      ),
                      FadeInUp(
                        // Password
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: 60,
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
                                contentPadding:
                                    const EdgeInsets.only(left: 45, top: 8),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 2,
                          width: 320,
                          color: Colors.red,
                        ),
                      ),
                      FadeInUp(
                        // Confirm Password
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: TextField(
                              obscureText: confirmPasswordVisible,
                              controller: globals.confirmPassword,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(left: 45, top: 8),
                                suffixIcon: IconButton(
                                  icon: Icon(confirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      confirmPasswordVisible =
                                          !confirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                hintText: "Confirm Password",
                                hintStyle: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      FadeInUp(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(colors: [
                                  Color.fromRGBO(255, 159, 159, 1),
                                  Color.fromRGBO(255, 99, 99, 1),
                                ])),
                            child: TextButton(
                              onPressed: sendVerificationLink,
                              child: const Center(
                                child: Text(
                                  "Send Verification Link",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInLeft(
                            duration: const Duration(milliseconds: 1000),
                            child: const Text(
                              "Already have an account?",
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
                                globals.isEmailVerified = false;
                                if (globals.emailSent) {
                                  auth.currentUser!.reload();
                                  auth.currentUser!.delete();
                                }
                                globals.emailSent = false;
                                widget.gotoSignIn();
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ])
        : // isEmailVerified==true

        Stack(children: [
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
                onBackPressed(didPop);
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * .07,
                      ),
                      FadeInDown(
                        // Prifile Photo.
                        child: Center(
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 204, 203, 203),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                )),
                            child: Stack(
                              children: [
                                photo,
                                Column(
                                  // Plus Button.
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Center(
                                      child: IconButton(
                                        onPressed: selectPhoto,
                                        icon: Image.asset(
                                          'assets/images/plus-button.png',
                                          width: 50,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: SizedBox(
                          // height: 400,
                          width: 380,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 2,
                                  width: 320,
                                  color: Colors.red,
                                ),
                              ),
                              FadeInUp(
                                // Username
                                child: Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: globals.userName,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Username",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 2,
                                  width: 320,
                                  color: Colors.red,
                                ),
                              ),
                              FadeInUp(
                                // Branch
                                child: Container(
                                  height: 70,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 100,
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            enabled: false,
                                            labelText: 'Branch'),
                                        // alignment: Alignment.center,
                                        value: globals.userBranch,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        onChanged: (newvalue) {
                                          setState(() {
                                            globals.userBranch =
                                                newvalue as String;
                                          });
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'CSE',
                                              child:
                                                  Center(child: Text('CSE'))),
                                          DropdownMenuItem(
                                              value: 'CSE-AI',
                                              child: Center(
                                                  child: Text('CSE-AI'))),
                                          DropdownMenuItem(
                                              value: 'IT',
                                              child: Center(child: Text('IT'))),
                                          DropdownMenuItem(
                                              value: 'ECE',
                                              child:
                                                  Center(child: Text('ECE'))),
                                          DropdownMenuItem(
                                              value: 'MEE',
                                              child:
                                                  Center(child: Text('MEE'))),
                                          DropdownMenuItem(
                                              value: 'CHE',
                                              child:
                                                  Center(child: Text('CHE'))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  height: 2,
                                  width: 320,
                                  color: Colors.red,
                                ),
                              ),
                              FadeInUp(
                                // Batch
                                child: Container(
                                  height: 70,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 110,
                                      child: DropdownButtonFormField(
                                        decoration: const InputDecoration(
                                            enabled: false, labelText: 'Batch'),
                                        // alignment: Alignment.center,
                                        value: globals.userBatch,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        onChanged: (newvalue) {
                                          setState(() {
                                            globals.userBatch =
                                                newvalue as String;
                                          });
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                              value: '2021-2025',
                                              child: Center(
                                                  child: Text('2021-2025'))),
                                          DropdownMenuItem(
                                              value: '2022-2026',
                                              child: Center(
                                                  child: Text('2022-2026'))),
                                          DropdownMenuItem(
                                              value: '2023-2027',
                                              child: Center(
                                                  child: Text('2023-2027'))),
                                          DropdownMenuItem(
                                              value: '2024-2028',
                                              child: Center(
                                                  child: Text('2024-2028'))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                child: Container(
                                  height: 2,
                                  width: 320,
                                  color: Colors.red,
                                ),
                              ),
                              FadeInDown(
                                // Sign Up Button.
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
                                    onPressed: signUp,
                                    child: const Center(
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FadeInLeft(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: const Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                  FadeInRight(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: TextButton(
                                      onPressed: () {
                                        globals.email.text = '';
                                        globals.password.text = '';
                                        globals.confirmPassword.text = '';
                                        globals.userName.text = '';
                                        globals.isEmailVerified = false;
                                        auth.currentUser!.reload();
                                        auth.currentUser!.delete();
                                        widget.gotoSignIn();
                                      },
                                      child: const Text(
                                        "Sign In",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]);
  }
}
