import 'dart:io';
import 'package:animate_do/animate_do.dart'; // flutter pub add animate_do
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uiet_docs/globals.dart' as globals;

// ignore: must_be_immutable
class DocsScreen extends StatefulWidget {
  DocsScreen({
    super.key,
    required this.homeScreenTitle,
    required this.gotoSemScreen,
    required this.gotoSyllabusScreen,
  });
  String homeScreenTitle;
  void Function()? gotoSemScreen;
  void Function()? gotoSyllabusScreen;
  @override
  State<StatefulWidget> createState() {
    return _DocsScreen();
  }
}

class _DocsScreen extends State<DocsScreen> {
  var branchIcons = ['cse', 'ai', 'it', 'ece', 'mee', 'che'];
  var branchNames = ['CSE', 'CSE-AI', 'IT', 'ECE', 'MEE', 'CHE'];

  void onTapFunction(index) {
    globals.branchIndex = index;
    if (globals.navigationIndex == 2) {
      widget.gotoSyllabusScreen!();
    } else {
      widget.gotoSemScreen!();
    }
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
                Image.asset('assets/images/profile_bg2.jpg')
              ],
            ),
          ),
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.white.withOpacity(.75),
          ),
          Column(
            children: [
              SizedBox(
                height: screenHeight * .015,
              ),
              FadeInDown(
                child: Center(
                  child: Text(
                    widget.homeScreenTitle,
                    style: TextStyle(
                      fontSize: screenHeight*.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              FadeInDown(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      onTapFunction(index);
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 255, 116, 116),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FadeInDown(
                            child: Image.asset(
                              'assets/${branchIcons[index]}.png',
                              width: screenWidth * .32,
                            ),
                          ),
                          FadeInLeft(
                            child: Text(
                              branchNames[index],
                              style: GoogleFonts.lato(
                                fontSize: screenHeight*.025,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
