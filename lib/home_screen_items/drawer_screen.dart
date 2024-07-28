import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uiet_docs/globals.dart' as globals;

// ignore: must_be_immutable
class DrawerScreen extends StatefulWidget {
  const DrawerScreen(
      {super.key,
      required this.gotoFeedback,
      required this.gotoContributors,
      required this.gotoAbout});
  final void Function() gotoFeedback;
  final void Function() gotoContributors;
  final void Function() gotoAbout;
  @override
  State<StatefulWidget> createState() {
    return _DrawerScreen();
  }
}

class _DrawerScreen extends State<DrawerScreen> {
  deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Color.fromRGBO(255, 159, 159, 1),
          Color.fromRGBO(255, 99, 99, 1),
        ],
      )),
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * .06,
          ),
          FadeInDown(
              child: Image.asset(
            'assets/images/logo.png',
            width: screenWidth * .45,
          )),
          SizedBox(
            height: screenHeight * .03,
          ),
          FadeInRight(
            child: Container(
              height: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: screenHeight * .01,
          ),
          Container(
            height: screenHeight * .055,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(255, 99, 99, 1),
                Color.fromRGBO(255, 159, 159, 1),
              ],
            )),
            child: FadeInLeft(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (globals.isEmailVerified==true && globals.signUpPressed==false){
                      globals.isEmailVerified=false;
                      globals.isSignedIn=false;
                      deleteUser();
                    }
                    if (globals.isSignedIn == false) {
                      globals.email.text = '';
                      globals.userName.text = '';
                      globals.password.text = '';
                      globals.confirmPassword.text = '';
                    }
                    globals.isContriScreenOpen = false;
                    Navigator.pop(context);
                    // Flutter adds Drawer in Navigation stack.
                    widget.gotoFeedback();
                  });
                },
                child: Center(
                  child: Text(
                    "Feedback",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight*.022,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * .01,
          ),
          FadeInRight(
            child: Container(
              height: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: screenHeight * .01,
          ),
          Container(
            height: screenHeight * .055,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(255, 99, 99, 1),
                Color.fromRGBO(255, 159, 159, 1),
              ],
            )),
            child: FadeInLeft(
              child: TextButton(
                onPressed: () {
                  if (globals.isEmailVerified==true && globals.signUpPressed==false){
                    globals.isEmailVerified=false;
                    globals.isSignedIn=false;
                    deleteUser();
                  }
                  if (globals.isSignedIn == false) {
                    globals.email.text = '';
                    globals.userName.text = '';
                    globals.password.text = '';
                    globals.confirmPassword.text = '';
                  }
                  Navigator.pop(context);
                  if (globals.isContriScreenOpen == false) {
                    setState(() {
                      globals.isContriScreenOpen = true;
                      widget.gotoContributors();
                    });
                  }
                },
                child: Center(
                  child: Text(
                    "Contributors",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight*.022,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * .01,
          ),
          FadeInRight(
            child: Container(
              height: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: screenHeight * .01,
          ),
          Container(
            height: screenHeight * .055,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(255, 99, 99, 1),
                Color.fromRGBO(255, 159, 159, 1),
              ],
            )),
            child: FadeInLeft(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (globals.isEmailVerified==true && globals.signUpPressed==false){
                      globals.isEmailVerified=false;
                      globals.isSignedIn=false;
                      deleteUser();
                    }
                    if (globals.isSignedIn == false) {
                      globals.email.text = '';
                      globals.userName.text = '';
                      globals.password.text = '';
                      globals.confirmPassword.text = '';
                    }
                    globals.isContriScreenOpen = false;
                    Navigator.pop(context);
                    widget.gotoAbout();
                  });
                },
                child: Center(
                  child: Text(
                    "About",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight*.022,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * .01,
          ),
          FadeInRight(
            child: Container(
              height: 2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
