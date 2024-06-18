import 'dart:async';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uiet_docs/globals.dart' as globals;

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen(
      {super.key, required this.gotoViewItem, required this.gotoSemScreen});
  final void Function() gotoViewItem;
  final void Function() gotoSemScreen;

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  var branchNames = ['CSE', 'CSE-AI', 'IT', 'ECE', 'MEE', 'CHE'];
  var semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
  var years = ['2024-2025', '2023-2024', '2022-2023', '2021-2022'];
  var exams = ['Mid Semester', 'End Semester'];

  int? noOfItems;
  loadFiles() async {
    var storageRef = FirebaseStorage.instance.ref();
    if (globals.navigationIndex == 0) {
      globals.filesRef = await storageRef
          .child(
              '/pyqs/${branchNames[globals.branchIndex]}/${semesters[globals.semesterIndex]} Semester/${years[globals.yearIndex]}/${exams[globals.examIndex]}/')
          .listAll();
    } else if (globals.navigationIndex == 1) {
      globals.filesRef = await storageRef
          .child(
              '/notes/${branchNames[globals.branchIndex]}/${semesters[globals.semesterIndex]} Semester/${years[globals.yearIndex]}/')
          .listAll();
    } else {
      globals.filesRef = await storageRef.child('/books/').listAll();
    }
    return true;
  }

  loadUsersDetails() async {
    var usersDetailsList = [];
    var databaseRef = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL:
                <databaseURL>)
        .ref();
    var contributionsRef = databaseRef.child('Contributions/${globals.folder}');
    var contributionsDataSnapshot = await contributionsRef.get();
    var contriDataDict = contributionsDataSnapshot.value as Map;
    //dataDict.keys contains list of uids, and data.values contains list of files.
    var uidList = [];
    for (var item in globals.filesRef.items) {
      for (var uid in contriDataDict.keys) {
        for (int i = 0; i < (contriDataDict[uid] as List).length; i++) {
          if (item.name == contriDataDict[uid][i]) {
            uidList.add(uid); // Contains uid in same sequence with filesRef.
          }
        }
      }
    }
    var usersRef = databaseRef.child('Users');
    var usersDataSnapshot = await usersRef.get();
    var usersDict = usersDataSnapshot.value as Map;
    for (var uid in uidList) {
      for (var key in usersDict.keys) {
        if (uid == key) {
          usersDetailsList.add(usersDict.values.first);
        }
      }
    }
    return [globals.filesRef, usersDetailsList];
  }

  downloadFile(index) async {
    await Permission.manageExternalStorage.onGrantedCallback(() async {
      Timer.run(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 107, 107, 107),
            content: Text(
              'Downloading...',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      });
      if (globals.ItemsListTitle == 'PYQs') {
        var storageRef = FirebaseStorage.instance.ref();
        globals.filesRef = await storageRef
            .child(
                '/pyqs/${branchNames[globals.branchIndex]}/${semesters[globals.semesterIndex]} Semester/${years[globals.yearIndex]}/${exams[globals.examIndex]}/')
            .listAll();
        var url = await globals.filesRef.items[index].getDownloadURL();
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: '/storage/emulated/0/Download/',
        );
      } else if (globals.ItemsListTitle == 'Notes') {
        var storageRef = FirebaseStorage.instance.ref();
        globals.filesRef = await storageRef
            .child(
                '/notes/${branchNames[globals.branchIndex]}/${semesters[globals.semesterIndex]} Semester/${years[globals.yearIndex]}/')
            .listAll();
        var url = await globals.filesRef.items[index].getDownloadURL();
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: '/storage/emulated/0/Download/',
        );
      } else {
        var storageRef = FirebaseStorage.instance.ref();
        globals.filesRef = await storageRef.child('/books/').listAll();
        var url = await globals.filesRef.items[index].getDownloadURL();
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: '/storage/emulated/0/Download/',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Color.fromARGB(255, 107, 107, 107),
          content: Text(
            'File downloaded successfully!',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      );
    }).request();
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

  onBackPressed(didPop) {
    if (didPop) {
      return;
    } else {
      widget.gotoSemScreen();
    }
  }

  @override
  Widget build(context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: globals.ItemsListTitle == 'Books'
          ? (didPop) {
              onDoubleBackPressed(didPop);
            }
          : (didPop) {
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
                FadeInDown(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        globals.ItemsListTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                  child: Container(
                    height: 3,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: screenHeight * .75,
                  child: FutureBuilder(
                      future: loadFiles(),
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
                        return FutureBuilder(
                            future: loadUsersDetails(),
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
                              var filesRef = objectList[0];
                              noOfItems = filesRef.items.length;
                              var usersDetailsList = objectList[1];

                              return ListView.builder(
                                  itemCount: noOfItems,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return FadeInDown(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, left: 20, right: 20),
                                              child: Container(
                                                height: screenHeight * .065,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color.fromRGBO(
                                                          255, 122, 122, 1),
                                                      Color.fromRGBO(
                                                          255, 208, 208, 1)
                                                    ],
                                                  ),
                                                  border: Border.all(
                                                      color: Colors.red),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(30),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Image.asset(
                                                        globals.ItemsListTitle ==
                                                                'PYQs'
                                                            ? 'assets/images/photo.png'
                                                            : 'assets/images/pdf.png',
                                                        width: 35,
                                                      ),
                                                      Expanded(
                                                        child: Center(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: TextButton(
                                                              onPressed: () {
                                                                globals.itemIndex =
                                                                    index;
                                                                widget
                                                                    .gotoViewItem();
                                                              },
                                                              child: Text(
                                                                filesRef
                                                                    .items[
                                                                        index]
                                                                    .name,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        22,),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            downloadFile(index);
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .download_for_offline_rounded,
                                                            size: 40,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Container(
                                                height: screenHeight * .03,
                                                width: screenWidth * .75,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10),
                                                        child: Center(
                                                          child:
                                                              SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Text(
                                                              '${usersDetailsList[index][0]}, B-Tech ${usersDetailsList[index][1]}, ${usersDetailsList[index][0]}',
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            });
                      }),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
