import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uiet_docs/globals.dart' as globals;

// ignore: must_be_immutable
class ContributorsScreen extends StatelessWidget {
  ContributorsScreen({
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

  List contributor = [];
  List contributorsList = [];
  List photos = [];

  gettingDetails() async {
    var databaseRef = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL:
                '<DATABASE URL>')
        .ref('Users');
    var dataSnapshot = await databaseRef.get();
    var usersDict = dataSnapshot.value as Map;
    List<int> unOrderedContriNumList = [];
    usersDict.forEach((key, value) {
      if (value[3] != 0) {
        unOrderedContriNumList.add(value[3]);
      }
    });
    unOrderedContriNumList.sort();
    List<int> orderedContriNumList = unOrderedContriNumList.reversed.toList();
    for (int val in orderedContriNumList) {
      usersDict.forEach((key, value) {
        if (value[3] == val) {
          contributor.add([key, value]);
          contributorsList.add(contributor[0]);
          contributor.clear();
        }
      });
    }
    final storageRef = FirebaseStorage.instance.ref();
    for (var user in contributorsList) {
      var fileRef = await storageRef.child('/photos/${user[0]}/').listAll();
      if (fileRef.items.isNotEmpty) {
        String url = await fileRef.items[0].getDownloadURL();
        File file = await DefaultCacheManager().getSingleFile(url);
        var photo = CircleAvatar(
          radius: screenHeight * .053,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(file),
        );
        photos.add(photo);
      } else {
        var photo = CircleAvatar(
          radius: screenHeight * .053,
          backgroundColor: Colors.white,
          backgroundImage: const AssetImage('assets/images/user.png'),
        );
        photos.add(photo);
      }
    }
    return [contributorsList, photos];
  }

  onBackPressed(didPop) {
    if (didPop) {
      return;
    }
    globals.isContriScreenOpen = false;
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

  double screenHeight = 1;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
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
            color: Colors.white.withOpacity(.9),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FadeInDown(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenHeight*.008),
                      child: Text(
                        'Contributors',
                        style: TextStyle(
                          fontSize: screenHeight*.023,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth*.02, right: screenWidth*.02, bottom: screenHeight*.02),
                  child: Container(
                    height: 3,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  width: screenWidth * .9,
                  height: screenHeight * .75,
                  child: FutureBuilder(
                      future: gettingDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return const Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            ),
                          );
                        }
                        var objectList = snapshot.data as List;
                        contributorsList = objectList[0];
                        photos = objectList[1];
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: contributorsList.length,
                          itemBuilder: (context, index) => FadeInDown(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: screenHeight*.02),
                              child: Container(
                                height: screenHeight * .145,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(screenHeight*.008),
                                      child: photos[index],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: screenHeight*.01, bottom: screenHeight*.01),
                                      child: Container(
                                        height: screenHeight * .15,
                                        width: 2,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(screenHeight*.008),
                                      child: Container(
                                          height: screenHeight * .2,
                                          width: screenWidth * .58,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(22),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * .03,
                                                top: screenHeight * .008),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Name : ',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Text(
                                                          contributorsList[
                                                              index][1][0],
                                                          style: TextStyle(
                                                            fontSize:
                                                                screenHeight *
                                                                    .019,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Branch : ',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                          [1],
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Batch : ',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                          [2],
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Contributions : ',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                              [3]
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenHeight * .019,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
