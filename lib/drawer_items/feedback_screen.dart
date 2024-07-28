import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:uiet_docs/globals.dart' as globals;

// ignore: must_be_immutable
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, required this.gotoDocsScreen, required this.gotoProfileScreen, required this.gotoSignInScreen, required this.gotoBooksScreen,});
  final void Function() gotoDocsScreen;
  final void Function() gotoProfileScreen;
  final void Function() gotoSignInScreen;
  final void Function() gotoBooksScreen;
  @override
  State<StatefulWidget> createState() {
    return _FeedbackScreen();
  }
}

class _FeedbackScreen extends State<FeedbackScreen> {
  int selectedStar = -1;
  Color starColorFunction(index, selectedStar) {
    if (index <= selectedStar) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  String ratingTitle = '';
  var commentsController = TextEditingController();

  void openAppReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.openStoreListing(appStoreId: 'com.theswayamsingh.app');
    }
  }

  submitFeedback() async {
    if (commentsController.text == '' && selectedStar != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Color.fromARGB(255, 107, 107, 107),
          content: Text(
            'Please type something...',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    } else if (commentsController.text != '' && selectedStar != -1) {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        String key = '${selectedStar + 1} Star Rating ';
        String value = commentsController.text;
        //Updating database.
        var databaseRef = FirebaseDatabase.instanceFor(
                app: Firebase.app(),
                databaseURL:
                    'https://uiet-kanpur-docs-app-default-rtdb.asia-southeast1.firebasedatabase.app/')
            .ref('Feedback/${auth.currentUser!.uid}');
        await databaseRef.update({key: value});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Color.fromARGB(255, 107, 107, 107),
            content: Text(
              'Feedback submitted successfully!',
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
              'Please sign in first to give feedback.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      }
    }
  }

  onBackPressed(didPop) {
    if (didPop) {
      return;
    }
    if (globals.navigationIndex == 4) {
      if (globals.isSignedIn) {
        widget.gotoProfileScreen();
      } else {
        widget.gotoSignInScreen();
      }
    } else if (globals.navigationIndex == 3) {
      widget.gotoBooksScreen();
    } else {
      widget.gotoDocsScreen();
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
            color: Colors.white.withOpacity(.8),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FadeInDown(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenHeight*.008),
                      child: Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: screenHeight*.023,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth*.02, right: screenWidth*.02),
                  child: Container(
                    height: 3,
                    color: Colors.red,
                  ),
                ),
                FadeInDown(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth*.02),
                    child: Image.asset(
                      'assets/images/feedback.jpg',
                      width: screenWidth,
                    ),
                  ),
                ),
                FadeInRight(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth*.02),
                    child: Container(
                      width: screenWidth * .9,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: screenWidth * .7,
                            height: screenHeight * .06,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5),
                              itemCount: 5,
                              itemBuilder: (context, index) => IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedStar = index;
                                    if (index == 0) {
                                      ratingTitle = 'Hated it';
                                    } else if (index == 1) {
                                      ratingTitle = 'Disliked it';
                                    } else if (index == 2) {
                                      ratingTitle = "It's OK";
                                    } else if (index == 3) {
                                      ratingTitle = 'Liked it';
                                    } else if (index == 4) {
                                      ratingTitle = 'Loved it';
                                    }
                                  });
                                },
                                color: selectedStar == -1
                                    ? Colors.grey
                                    : starColorFunction(index, selectedStar),
                                icon: const Icon(
                                  Icons.star,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            ratingTitle,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenHeight*.018,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight*.01,
                ),
                FadeInUp(
                  child: Container(
                    width: screenWidth * .9,
                    height: screenHeight * .2,
                    padding: EdgeInsets.all(
                        screenHeight*.008), // Padding for internal items.
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      controller: commentsController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Comments",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight*.015, left: screenWidth*.045, right: screenWidth*.045),
                    child: Container(
                      height: screenHeight * .055,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(255, 159, 159, 1),
                            Color.fromRGBO(255, 99, 99, 1),
                          ])),
                      child: TextButton(
                        onPressed: submitFeedback,
                        child: const Center(
                          child: Text(
                            "Submit",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FadeInUp(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: openAppReview,
                        icon: Image.asset(
                          'assets/images/playstore.png',
                          width: screenWidth * .05,
                        ),
                      ),
                      Text(
                        'Not signed in? Click here to Rate the app on Play Store.',
                        style: TextStyle(
                            fontSize: screenHeight * .015,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
