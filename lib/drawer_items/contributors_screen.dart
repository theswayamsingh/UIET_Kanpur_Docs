import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// ignore: must_be_immutable
class ContributorsScreen extends StatelessWidget {
  ContributorsScreen({super.key, required this.gotoDocsScreen});
  final void Function() gotoDocsScreen;

  List contributor = [];
  List contributorsList = [];
  List photos = [];

  gettingDetails() async {
    var databaseRef = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL:
                <databaseURL>)
        .ref('Users');
    var dataSnapshot = await databaseRef.get();
    var usersDict = dataSnapshot.value as Map;
    usersDict.forEach((key, value) {
      if (value[3] != 0) {
        contributor.add([key, value]);
        contributorsList.add(contributor[0]);
      }
      contributor.clear();
    });
    final storageRef = FirebaseStorage.instance.ref();
    for (var user in contributorsList) {
      var fileRef = await storageRef.child('/photos/${user[0]}/').listAll();
      if (fileRef.items.isNotEmpty) {
        String url = await fileRef.items[0].getDownloadURL();
        File file = await DefaultCacheManager().getSingleFile(url);
        var photo = CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(file),
        );
        photos.add(photo);
      } else {
        var photo = const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/user.png'),
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
    gotoDocsScreen();
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
            color: Colors.white.withOpacity(.9),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FadeInDown(
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Contributors',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                  child: Container(
                    height: 3,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
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
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 20),
                              child: Container(
                                height: screenHeight * .13,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: photos[index],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 8),
                                      child: Container(
                                        height: screenHeight * .2,
                                        width: 2,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: screenHeight * .2,
                                          width: screenWidth * .59,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.red),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(22),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, top: 4),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Name : ',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                          [0],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Branch : ',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                          [1],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Batch : ',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                          [2],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Contributions : ',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      contributorsList[index][1]
                                                              [3]
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 16,
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
