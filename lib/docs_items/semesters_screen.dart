import 'package:animate_do/animate_do.dart'; // flutter pub add animate_do
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uiet_docs/globals.dart' as globals;

// ignore: must_be_immutable
class SemestersScreen extends StatefulWidget {
  const SemestersScreen(
      {super.key,
      required this.gotoDocsScreen,
      required this.gotoSemScreen,
      required this.gotoItemsListScreen});
  final void Function() gotoDocsScreen;
  final void Function() gotoSemScreen;
  final void Function() gotoItemsListScreen;
  @override
  State<StatefulWidget> createState() {
    return _SemestersScreen();
  }
}

class _SemestersScreen extends State<SemestersScreen> {
  onBackPressed(didPop) {
    if (didPop) {
      return;
    } else if (globals.count == 8) {
      widget.gotoDocsScreen();
    } else if (globals.count == 4) {
      globals.count = 8;
      globals.semScreenHeading = 'SEMESTERS';
      globals.semesters = [
        '1st',
        '2nd',
        '3rd',
        '4th',
        '5th',
        '6th',
        '7th',
        '8th'
      ];
      widget.gotoSemScreen();
    } else if (globals.count == 2) {
      globals.count = 4;
      globals.semScreenHeading = 'YEAR';
      globals.semesters = ['2024-2025', '2023-2024', '2022-2023', '2021-2022'];
      widget.gotoSemScreen();
    }
  }

  @override
  Widget build(context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onBackPressed(didPop);
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
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                FadeInDown(
                  child: Center(
                    child: Text(
                      globals.semScreenHeading,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FadeInUp(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: globals.count,
                    itemBuilder: (context, index) => SizedBox(
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (globals.count == 8) {
                              globals.semesterIndex = index;
                              globals.count = 4;
                              globals.semesters = globals.years;
                              globals.semScreenHeading = 'YEAR';
                            } else if (globals.count == 4) {
                              globals.yearIndex = index;
                              if (globals.navigationIndex == 1) {
                                widget.gotoItemsListScreen();
                              } else {
                                globals.count = 2;
                                globals.semesters = globals.exams;
                                globals.semScreenHeading = 'EXAM';
                              }
                            } else if (globals.count == 2) {
                              globals.examIndex = index;
                              widget.gotoItemsListScreen();
                            }
                          });
                        },
                        child: Card(
                          color: const Color.fromARGB(255, 255, 174, 174),
                          child: Center(
                            child: Text(
                              globals.count == 8
                                  ? '${globals.semesters[index]} Semester'
                                  : globals.semesters[index],
                              style: GoogleFonts.oswald(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
