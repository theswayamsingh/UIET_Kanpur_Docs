import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

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
                    Navigator.pop(context);
                    // Flutter adds Drawer in Navigation stack.
                    widget.gotoFeedback();
                  });
                },
                child: const Center(
                  child: Text(
                    "Feedback",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                    Navigator.pop(context);
                    widget.gotoContributors();
                  });
                },
                child: const Center(
                  child: Text(
                    "Contributors",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                    Navigator.pop(context);
                    widget.gotoAbout();
                  });
                },
                child: const Center(
                  child: Text(
                    "About",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
