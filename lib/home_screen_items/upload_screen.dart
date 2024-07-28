import 'dart:async';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uiet_docs/globals.dart' as globals;

class UploadScreen extends StatefulWidget {
  const UploadScreen(
      {super.key,
      required this.gotoDocsScreen,
      required this.gotoBooksScreen,
      required this.gotoProfileScreen,
      required this.gotoSignInScreen});
  final void Function() gotoDocsScreen;
  final void Function() gotoBooksScreen;
  final void Function() gotoProfileScreen;
  final void Function() gotoSignInScreen;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
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

  FilePickerResult? result;
  //file_picker.
  void selectFiles() async {
    if (fileType == 'PYQs') {
      result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png']);
      setState(() {}); //To create ListView.
    } else {
      result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: true);
      setState(() {}); //To create ListView.
    }
  }

  List controllers = [];
  Widget buildFile(index) {
    String fileSize =
        (result!.files[index].size / (1024 * 1024)).toStringAsFixed(2);
    var fileNameController = TextEditingController(text: result!.files[index].name);
    controllers.add(fileNameController);
    return Column(
      children: [
        ListTile(
          leading: fileType == 'PYQs'
            ? Image.asset(
                'assets/images/photo.png',
                width: 30,
              )
            : Image.asset(
                'assets/images/pdf.png',
                width: 30,
              ),
          title: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controllers[index],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                result!.files.remove(result!.files[index]);
              });
            },
            icon: Image.asset(
              'assets/images/recycle-bin.png',
              width: 30,
            ),
          ),
        ),
        Text('($fileSize MB)')
      ],
    );
  }

  bool listView = false;
  String? pathOfStorage;
  uploadFiles() async {
    if (result != null) {
      final storageRef = FirebaseStorage.instance.ref();
      int len =
          result!.files.length; //Exact path in storage including filename.
      try {
        if (fileType == 'PYQs') {
          pathOfStorage = '/pyqs/$branch/$semester/$year/$exam/';
          for (int i = 1; i <= len; i++) {
            
            final uploadRef =
                storageRef.child("$pathOfStorage").child(controllers[i-1].text);
            try {
              await uploadRef.getDownloadURL();
              return ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 107, 107, 107),
                  content: Text(
                    'File already exists.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            } catch (e) {
              Timer.run(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color.fromARGB(255, 107, 107, 107),
                    content: Text(
                      'Uploading...',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              });
              await uploadRef.putFile(File(result!.files[0].path!));

              //Updating Database.
              String uid = FirebaseAuth.instance.currentUser!.uid;
              var databaseRef = FirebaseDatabase.instanceFor(
                      app: Firebase.app(),
                      databaseURL:
                          'https://uiet-kanpur-docs-app-default-rtdb.asia-southeast1.firebasedatabase.app/')
                  .ref();
              var usersRef = databaseRef.child('Users/$uid/3');
              var dataSnapshotOfUsers = await usersRef.get();
              int noOfContri = dataSnapshotOfUsers.value as int;
              noOfContri += 1;
              await usersRef.set(noOfContri);

              var key = 0;
              var contributionsRef = databaseRef.child('Contributions/pyqs/$uid');
              var dataSnapshotOfContributions = await contributionsRef.get();
              if (dataSnapshotOfContributions.value == null) {
                key = 0;
              } else {
                key = (dataSnapshotOfContributions.value as List).length;
              }
              await contributionsRef
                  .update({key.toString(): controllers[i-1].text});

              setState(() {
                result!.files.remove(result!.files[0]);
              });
            }
          }
        } else if (fileType == 'Notes') {
          pathOfStorage = '/notes/$branch/$semester/$year/';
          for (int i = 1; i <= len; i++) {

            final uploadRef =
                storageRef.child("$pathOfStorage").child(controllers[i-1].text);
            try {
              await uploadRef.getDownloadURL();
              return ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 107, 107, 107),
                  content: Text(
                    'File already exists.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            } catch (e) {
              Timer.run(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color.fromARGB(255, 107, 107, 107),
                    content: Text(
                      'Uploading...',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              });

              await uploadRef.putFile(File(result!.files[0].path!));

              String uid = FirebaseAuth.instance.currentUser!.uid;
              var databaseRef = FirebaseDatabase.instanceFor(
                      app: Firebase.app(),
                      databaseURL:
                          'https://uiet-kanpur-docs-app-default-rtdb.asia-southeast1.firebasedatabase.app/')
                  .ref();
              var usersRef = databaseRef.child('Users/$uid/3');
              var dataSnapshotOfUsers = await usersRef.get();
              int noOfContri = dataSnapshotOfUsers.value as int;
              noOfContri += 1;
              await usersRef.set(noOfContri);

              var key = 0;
              var contributionsRef =
                  databaseRef.child('Contributions/notes/$uid');
              var dataSnapshotOfContributions = await contributionsRef.get();
              if (dataSnapshotOfContributions.value == null) {
                key = 0;
              } else {
                key = (dataSnapshotOfContributions.value as List).length;
              }
              await contributionsRef
                  .update({key.toString(): controllers[i-1].text});

              setState(() {
                result!.files.remove(result!.files[0]);
              });
            }
          }
        } else if (fileType == 'Books') {
          pathOfStorage = '/books/';
          for (int i = 1; i <= len; i++) {
            final uploadRef =
                storageRef.child("$pathOfStorage").child(controllers[i-1].text);
            try {
              await uploadRef.getDownloadURL();
              return ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 107, 107, 107),
                  content: Text(
                    'File already exists.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            } catch (e) {

              Timer.run(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color.fromARGB(255, 107, 107, 107),
                    content: Text(
                      'Uploading...',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              });

              await uploadRef.putFile(File(result!.files[0].path!));

              String uid = FirebaseAuth.instance.currentUser!.uid;
              var databaseRef = FirebaseDatabase.instanceFor(
                      app: Firebase.app(),
                      databaseURL:
                          'https://uiet-kanpur-docs-app-default-rtdb.asia-southeast1.firebasedatabase.app/')
                  .ref();
              var usersRef = databaseRef.child('Users/$uid/3');
              var dataSnapshotOfUsers = await usersRef.get();
              int noOfContri = dataSnapshotOfUsers.value as int;
              noOfContri += 1;
              await usersRef.set(noOfContri);

              var key = 0;
              var contributionsRef =
                  databaseRef.child('Contributions/books/$uid');
              var dataSnapshotOfContributions = await contributionsRef.get();
              if (dataSnapshotOfContributions.value == null) {
                key = 0;
              } else {
                key = (dataSnapshotOfContributions.value as List).length;
              }
              await contributionsRef
                  .update({key.toString(): controllers[i-1].text});

              setState(() {
                result!.files.remove(result!.files[0]);
              });
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            backgroundColor: const Color.fromARGB(255, 107, 107, 107),
            content: Text(
              len == 1
                  ? '$len File uploaded successfully!'
                  : '$len Files uploaded successfully!',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 1),
            backgroundColor: const Color.fromARGB(255, 107, 107, 107),
            content: Text(
              '$e.toString()',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      }
    }
  }

  String fileType = 'PYQs';
  String year = '2021-2022';
  String semester = '1st Semester';
  String branch = 'CSE';
  String exam = 'Mid Semester';
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
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * .012,
                  ),
                  FadeInDown(
                    child: Text(
                      'Contribute',
                      style: TextStyle(
                        fontSize: screenHeight * .025,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FadeInDown(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth * .02, right: screenWidth * .02),
                      child: Container(
                        height: 3,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  FadeInDown(
                    child: Image.asset(
                      'assets/images/uploadBG.jpg',
                      width: screenWidth * .7,
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: screenWidth * .85,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              height: 2,
                              width: screenWidth * .73,
                              color: Colors.red,
                            ),
                          ),
                          FadeInLeft(
                            // File Type
                            child: Container(
                              height: screenHeight * .075,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: screenWidth * .5,
                                  child: DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                        enabled: false, labelText: 'File Type'),
                                    value: fileType,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onChanged: (newvalue) {
                                      setState(() {
                                        fileType = newvalue as String;
                                        if (result != null) {
                                          result!.files.clear();
                                        }
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'PYQs',
                                          child: Center(
                                              child: Text(
                                                  'PYQs (.jpg/.jpeg/.png)'))),
                                      DropdownMenuItem(
                                          value: 'Notes',
                                          child: Center(
                                              child: Text('Notes (.pdf)'))),
                                      DropdownMenuItem(
                                          value: 'Books',
                                          child: Center(
                                              child: Text('Books (.pdf)'))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              height: 2,
                              width: screenWidth * .73,
                              color: Colors.red,
                            ),
                          ),
                          fileType == 'Books'
                              ? const SizedBox()
                              : Column(
                                  children: [
                                    FadeInRight(
                                      // Branch
                                      child: Container(
                                        height: screenHeight * .075,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: screenWidth * .5,
                                            child: DropdownButtonFormField(
                                              decoration: const InputDecoration(
                                                  enabled: false,
                                                  labelText: 'Branch'),
                                              value: branch,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                              onChanged: (newvalue) {
                                                setState(() {
                                                  branch = newvalue as String;
                                                  if (result != null) {
                                                    result!.files.clear();
                                                  }
                                                });
                                              },
                                              items: const [
                                                DropdownMenuItem(
                                                    value: 'CSE',
                                                    child: Center(
                                                        child: Text('CSE'))),
                                                DropdownMenuItem(
                                                    value: 'CSE-AI',
                                                    child: Center(
                                                        child: Text('CSE-AI'))),
                                                DropdownMenuItem(
                                                    value: 'IT',
                                                    child: Center(
                                                        child: Text('IT'))),
                                                DropdownMenuItem(
                                                    value: 'ECE',
                                                    child: Center(
                                                        child: Text('ECE'))),
                                                DropdownMenuItem(
                                                    value: 'MEE',
                                                    child: Center(
                                                        child: Text('MEE'))),
                                                DropdownMenuItem(
                                                    value: 'CHE',
                                                    child: Center(
                                                        child: Text('CHE'))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        height: 2,
                                        width: screenWidth * .73,
                                        color: Colors.red,
                                      ),
                                    ),
                                    FadeInLeft(
                                      // Semester
                                      child: Container(
                                        height: screenHeight * .075,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: screenWidth * .5,
                                            child: DropdownButtonFormField(
                                              decoration: const InputDecoration(
                                                  enabled: false,
                                                  labelText: 'Semester'),
                                              value: semester,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                              onChanged: (newvalue) {
                                                setState(() {
                                                  semester = newvalue as String;
                                                  if (result != null) {
                                                    result!.files.clear();
                                                  }
                                                });
                                              },
                                              items: const [
                                                DropdownMenuItem(
                                                    value: '1st Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '1st Semester'))),
                                                DropdownMenuItem(
                                                    value: '2nd Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '2nd Semester'))),
                                                DropdownMenuItem(
                                                    value: '3rd Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '3rd Semester'))),
                                                DropdownMenuItem(
                                                    value: '4th Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '4th Semester'))),
                                                DropdownMenuItem(
                                                    value: '5th Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '5th Semester'))),
                                                DropdownMenuItem(
                                                    value: '6th Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '6th Semester'))),
                                                DropdownMenuItem(
                                                    value: '7th Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '7th Semester'))),
                                                DropdownMenuItem(
                                                    value: '8th Semester',
                                                    child: Center(
                                                        child: Text(
                                                            '8th Semester'))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        height: 2,
                                        width: screenWidth * .73,
                                        color: Colors.red,
                                      ),
                                    ),
                                    FadeInRight(
                                      // Year
                                      child: Container(
                                        height: screenHeight * .075,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(30),
                                          ),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: screenWidth * .5,
                                            child: DropdownButtonFormField(
                                              decoration: const InputDecoration(
                                                  enabled: false,
                                                  labelText: 'Year'),
                                              value: year,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                              onChanged: (newvalue) {
                                                setState(() {
                                                  year = newvalue as String;
                                                  if (result != null) {
                                                    result!.files.clear();
                                                  }
                                                });
                                              },
                                              items: const [
                                                DropdownMenuItem(
                                                    value: '2021-2022',
                                                    child: Center(
                                                        child:
                                                            Text('2021-2022'))),
                                                DropdownMenuItem(
                                                    value: '2022-2023',
                                                    child: Center(
                                                        child:
                                                            Text('2022-2023'))),
                                                DropdownMenuItem(
                                                    value: '2023-2024',
                                                    child: Center(
                                                        child:
                                                            Text('2023-2024'))),
                                                DropdownMenuItem(
                                                    value: '2024-2025',
                                                    child: Center(
                                                        child:
                                                            Text('2024-2025'))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        height: 2,
                                        width: screenWidth * .73,
                                        color: Colors.red,
                                      ),
                                    ),
                                    fileType == 'Notes'
                                        ? const SizedBox()
                                        : Column(
                                            children: [
                                              FadeInLeft(
                                                // Exam
                                                child: Container(
                                                  height: screenHeight * .075,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(30),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: SizedBox(
                                                      width: screenWidth * .5,
                                                      child:
                                                          DropdownButtonFormField(
                                                        decoration:
                                                            const InputDecoration(
                                                                enabled: false,
                                                                labelText:
                                                                    'Exam'),
                                                        value: exam,
                                                        icon: const Icon(Icons
                                                            .arrow_drop_down),
                                                        onChanged: (newvalue) {
                                                          setState(() {
                                                            exam = newvalue
                                                                as String;
                                                            if (result !=
                                                                null) {
                                                              result!.files
                                                                  .clear();
                                                            }
                                                          });
                                                        },
                                                        items: const [
                                                          DropdownMenuItem(
                                                              value:
                                                                  'Mid Semester',
                                                              child: Center(
                                                                  child: Text(
                                                                      'Mid Semester'))),
                                                          DropdownMenuItem(
                                                              value:
                                                                  'End Semester',
                                                              child: Center(
                                                                  child: Text(
                                                                      'End Semester'))),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Container(
                                                  height: 2,
                                                  width: screenWidth * .73,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                          FadeInRight(
                            // Select Files
                            child: Container(
                              width: screenWidth * .85,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: Column(
                                children: [
                                  result == null
                                      ? const SizedBox()
                                      : ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: result!.files.length,
                                          itemBuilder: (context, index) {
                                            return buildFile(index);
                                          },
                                        ),
                                  TextButton(
                                    onPressed: selectFiles,
                                    child: const Text(
                                      "Select Files",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: Container(
                              height: 2,
                              width: screenWidth * .73,
                              color: Colors.red,
                            ),
                          ),
                          FadeInUp(
                            // Upload Button.
                            duration: const Duration(milliseconds: 800),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                height: screenHeight * .06,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(colors: [
                                      Color.fromRGBO(255, 159, 159, 1),
                                      Color.fromRGBO(255, 99, 99, 1),
                                    ])),
                                child: TextButton(
                                  onPressed: uploadFiles,
                                  child: const Center(
                                    child: Text(
                                      "Upload",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}
