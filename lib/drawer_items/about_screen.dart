import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uiet_docs/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({
    super.key,
    required this.gotoDocsScreen,
    required this.gotoProfileScreen,
    required this.gotoSignInScreen,
    required this.gotoBooksScreen,
  });
  final void Function() gotoDocsScreen;
  final void Function() gotoProfileScreen;
  final void Function() gotoSignInScreen;
  final void Function() gotoBooksScreen;

  onBackPressed(didPop) {
    if (didPop) {
      return;
    }
    if (globals.navigationIndex == 4) {
      if (globals.isSignedIn) {
        gotoProfileScreen();
      } else {
        gotoSignInScreen();
      }
    } else if (globals.navigationIndex == 3) {
      gotoBooksScreen();
    } else {
      gotoDocsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        onBackPressed(didPop);
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 122, 122, 1),
                      Color.fromRGBO(255, 208, 208, 1)
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FadeInDown(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(screenHeight * .01),
                          child: Text(
                            'Developer',
                            style: TextStyle(
                              fontSize: screenHeight * .025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * .08, right: screenWidth * .08),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenHeight * .01),
                          child: Column(
                            children: [
                              FadeInDown(
                                child: Center(
                                  child: Container(
                                    height: screenHeight * .25,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    )),
                                    child: Image.asset(
                                      'assets/images/myphoto.png',
                                    ),
                                  ),
                                ),
                              ),
                              FadeInDown(
                                child: Center(
                                  child: Text(
                                    'Swayam Singh',
                                    style: GoogleFonts.lato(
                                      fontSize: screenHeight * .025,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              FadeInDown(
                                child: Center(
                                  child: Text(
                                    'B-Tech CSE',
                                    style: GoogleFonts.lato(
                                      fontSize: screenHeight * .02,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              FadeInDown(
                                child: Center(
                                  child: Text(
                                    '2023-27"',
                                    style: GoogleFonts.lato(
                                      fontSize: screenHeight * .017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeInRight(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(screenHeight * .01),
                          child: Text(
                            'About App',
                            style: TextStyle(
                              fontSize: screenHeight * .024,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: screenHeight * .01, right: screenHeight * .01),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenHeight * .01),
                          child: Column(
                            children: [
                              FadeInLeft(
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    '''UIET Kanpur Docs mobile app is entirely developed using Flutter and Firebase (as backend). The App aims to provide resources to each and every student of UIET who are pursuing B-Tech in any branch. The resources include PYQs, Notes, Syllabus and Books, that will help the students throughout their academic journey.''',
                                    style: GoogleFonts.lato(
                                      fontSize: screenHeight * .017,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeInRight(
                      child: Padding(
                        padding: EdgeInsets.only(top: screenHeight * .01),
                        child: Text(
                          "For any query, contact on:",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * .024),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenHeight * .01),
                      child: Container(
                        height: screenHeight * .08,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: FadeInUp(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                      'https://www.linkedin.com/in/theswayamsingh');
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                },
                                icon: Image.asset(
                                  'assets/contact_icons/linkedin.png',
                                  width: screenWidth * .075,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                      'https://www.github.com/theswayamsingh');
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                },
                                icon: Image.asset(
                                  'assets/contact_icons/github.png',
                                  width: screenWidth * .075,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final Uri url =
                                      Uri.parse('mailto:theswayamsingh@gmail.com');
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                },
                                icon: Image.asset(
                                  'assets/contact_icons/gmail.png',
                                  width: screenWidth * .075,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
