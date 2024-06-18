import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uiet_docs/docs_items/items_list_screen.dart';
import 'package:uiet_docs/docs_items/syllabus_screen.dart';
import 'package:uiet_docs/docs_items/view_item.dart';
import 'package:uiet_docs/drawer_items/about_screen.dart';
import 'package:uiet_docs/drawer_items/contributors_screen.dart';
import 'package:uiet_docs/drawer_items/feedback_screen.dart';
import 'package:uiet_docs/home_screen_items/docs_screen.dart';
import 'package:uiet_docs/home_screen_items/drawer_screen.dart';
import 'package:uiet_docs/docs_items/semesters_screen.dart';
import 'package:uiet_docs/home_screen_items/upload_screen.dart';
import 'package:uiet_docs/profile_items/profile_screen.dart';
import 'package:uiet_docs/profile_items/sign_in_screen.dart';
import 'package:uiet_docs/profile_items/sign_up_screen.dart';
import 'globals.dart' as globals;

class Logic extends StatefulWidget {
  const Logic({super.key});

  @override
  State<Logic> createState() {
    return _Logic();
  }
}

class _Logic extends State<Logic> {
  @override
  initState() {
    isSignedIn();
    super.initState();
  }

  isSignedIn() async {
    final auth = FirebaseAuth.instance;
    try {
      if (auth.currentUser != null) {
        await auth.currentUser!.reload();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        auth.signOut();
      }
    }
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          globals.isSignedIn = true;
        });
      }
    });
  }

  int currentPageIndex = 0;
  String homeScreenHeading = 'PQYs';
  var bottomIcons = ['question', 'notes', 'syllabus', 'books'];
  var bottomLabels = ['PYQs', 'Notes', 'Syllabus', 'Books', 'Profile'];

  var activeScreen = 'home-screen';
  void switchtoSignInScreen() {
    setState(() {
      activeScreen = 'sign-in-screen';
    });
  }

  void switchtoSignUpScreen() {
    setState(() {
      activeScreen = 'sign-up-screen';
    });
  }

  void switchtoProfileScreen() {
    setState(() {
      activeScreen = 'profile-screen';
    });
  }

  void switchtoSemestersScreen() {
    setState(() {
      activeScreen = 'semesters-screen';
    });
  }

  void switchtoFeedbackScreen() {
    setState(() {
      activeScreen = 'feedback-screen';
    });
  }

  void switchtoContributorsScreen() {
    setState(() {
      activeScreen = 'contributors-screen';
    });
  }

  void switchtoAboutScreen() {
    setState(() {
      activeScreen = 'about-screen';
    });
  }

  void switchtoSyllabusScreen() {
    setState(() {
      activeScreen = 'syllabus-screen';
    });
  }

  void switchtoItemsListScreen() {
    setState(() {
      activeScreen = 'items-list-screen';
    });
  }

  void switchtoViewItem() {
    setState(() {
      activeScreen = 'view-item';
    });
  }

  void switchtoDocsScreen() {
    setState(() {
      activeScreen = 'docs-screen';
    });
  }

  void switchtoUploadScreen() {
    setState(() {
      activeScreen = 'upload-screen';
    });
  }

  @override
  Widget build(context) {
    if (globals.isSignedIn == false) {
      globals.email.text = '';
      globals.userName.text = '';
      globals.password.text = '';
      globals.confirmPassword.text = '';
    }
    Widget screenWidget = DocsScreen(
      homeScreenTitle: homeScreenHeading,
      gotoSemScreen: switchtoSemestersScreen,
      gotoSyllabusScreen: switchtoSyllabusScreen,
    );
    if (activeScreen == 'docs-screen') {
      screenWidget = DocsScreen(
        homeScreenTitle: homeScreenHeading,
        gotoSemScreen: switchtoSemestersScreen,
        gotoSyllabusScreen: switchtoSyllabusScreen,
      );
    }
    if (activeScreen == 'sign-in-screen') {
      screenWidget = SignInScreen(
        gotoSignUp: switchtoSignUpScreen,
        gotoProfileScreen: switchtoProfileScreen,
      );
    }
    if (activeScreen == 'sign-up-screen') {
      screenWidget = SignUpScreen(
        gotoSignIn: switchtoSignInScreen,
        gotoProfileScreen: switchtoProfileScreen,
      );
    }
    if (activeScreen == 'semesters-screen') {
      screenWidget = SemestersScreen(
        gotoDocsScreen: switchtoDocsScreen,
        gotoSemScreen: switchtoSemestersScreen,
        gotoItemsListScreen: switchtoItemsListScreen,
      );
    }

    if (activeScreen == 'feedback-screen') {
      screenWidget = FeedbackScreen(gotoDocsScreen: switchtoDocsScreen);
    }

    if (activeScreen == 'contributors-screen') {
      screenWidget = ContributorsScreen(
        gotoDocsScreen: switchtoDocsScreen,
      );
    }

    if (activeScreen == 'about-screen') {
      screenWidget = AboutScreen(
        gotoDocsScreen: switchtoDocsScreen,
      );
    }

    if (activeScreen == 'syllabus-screen') {
      screenWidget = SyllabusScreen(
        gotoDocsScreen: switchtoDocsScreen,
      );
    }

    if (activeScreen == 'items-list-screen') {
      screenWidget = ItemsListScreen(
        gotoViewItem: switchtoViewItem,
        gotoSemScreen: switchtoSemestersScreen,
      );
    }

    if (activeScreen == 'profile-screen') {
      screenWidget = ProfileScreen(
        gotoSignInScreen: switchtoSignInScreen,
      );
    }

    if (activeScreen == 'view-item') {
      screenWidget = ViewItem(
        gotoItemsListScreen: switchtoItemsListScreen,
      );
    }

    if (activeScreen == 'upload-screen') {
      screenWidget = UploadScreen(
        gotoDocsScreen: switchtoDocsScreen,
        gotoBooksScreen: switchtoItemsListScreen,
        gotoProfileScreen: switchtoProfileScreen,
        gotoSignInScreen: switchtoSignInScreen,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: screenWidget,
          drawer: Builder(
            // Creating a context that include a Navigator (Previous context MaterialApp).
            builder: (context) => Drawer(
              child: DrawerScreen(
                gotoFeedback: switchtoFeedbackScreen,
                gotoContributors: switchtoContributorsScreen,
                gotoAbout: switchtoAboutScreen,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            title: const Text(
              'UIET Kanpur',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color.fromARGB(255, 255, 95, 95),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Builder(builder: (context) {
                  return IconButton(
                      onPressed: () async {
                        if (globals.isSignedIn) {
                          switchtoUploadScreen();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 3),
                              backgroundColor:
                                  Color.fromARGB(255, 107, 107, 107),
                              content: Text(
                                'For contribution, Sign In is required.',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 30,
                      ));
                }),
              )
            ],
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: const Color.fromARGB(255, 255, 196, 204),
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
                homeScreenHeading = bottomLabels[index];
                if (currentPageIndex == 4) {
                  globals.navigationIndex = 4;
                  globals.isSignedIn
                      ? activeScreen = 'profile-screen'
                      : activeScreen = 'sign-in-screen';
                } else if (currentPageIndex == 3) {
                  globals.navigationIndex = 3;
                  globals.ItemsListTitle = 'Books';
                  globals.folder = 'books';
                  activeScreen = 'items-list-screen';
                } else if (currentPageIndex == 2) {
                  globals.navigationIndex = 2;
                  activeScreen = 'docs-screen';
                } else if (currentPageIndex == 1) {
                  globals.navigationIndex = 1;
                  globals.ItemsListTitle = 'Notes';
                  globals.folder = 'notes';
                  activeScreen = 'docs-screen';
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
                  globals.years = [
                    '2024-2025',
                    '2023-2024',
                    '2022-2023',
                    '2021-2022'
                  ];
                  globals.exams = ['Mid Semester', 'End Semester'];
                  globals.semScreenHeading = 'SEMESTERS';
                  globals.count = 8;
                } else {
                  globals.navigationIndex = 0;
                  globals.ItemsListTitle = 'PYQs';
                  globals.folder = 'pyqs';
                  activeScreen = 'docs-screen';
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
                  globals.years = [
                    '2024-2025',
                    '2023-2024',
                    '2022-2023',
                    '2021-2022'
                  ];
                  globals.exams = ['Mid Semester', 'End Semester'];
                  globals.semScreenHeading = 'SEMESTERS';
                  globals.count = 8;
                }
              });
            },
            selectedIndex: currentPageIndex,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(
                  icon: Image.asset(
                    'assets/bottom_icons/${bottomIcons[0]}.png',
                    width: 30,
                  ),
                  label: bottomLabels[0]),
              NavigationDestination(
                  icon: Image.asset(
                    'assets/bottom_icons/${bottomIcons[1]}.png',
                    width: 30,
                  ),
                  label: bottomLabels[1]),
              NavigationDestination(
                  icon: Image.asset(
                    'assets/bottom_icons/${bottomIcons[2]}.png',
                    width: 30,
                  ),
                  label: bottomLabels[2]),
              NavigationDestination(
                  icon: Image.asset(
                    'assets/bottom_icons/${bottomIcons[3]}.png',
                    width: 30,
                  ),
                  label: bottomLabels[3]),
              const NavigationDestination(
                  icon: Icon(
                    Icons.person,
                    size: 35,
                  ),
                  label: 'Profile')
            ],
          ),
        ),
      ),
    );
  }
}
