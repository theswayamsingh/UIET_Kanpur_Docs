import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uiet_docs/globals.dart' as globals;

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key, required this.gotoDocsScreen});
  final void Function() gotoDocsScreen;

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
// ignore: must_be_immutable
  static const branchNames = ['CSE', 'CSE-AI', 'IT', 'ECE', 'MEE', 'CHE'];

  Future<File> loadFile() async {
    final storageRef = FirebaseStorage.instance.ref();
    final filePath = '/syllabus/${branchNames[globals.branchIndex]}.pdf';
    var fileRef = storageRef.child(filePath);
    var url = await fileRef.getDownloadURL();
    var file = await DefaultCacheManager().getSingleFile(url);
    return file;
  }

  downloadFile() async {
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
      Reference fileRef = FirebaseStorage.instance
          .ref()
          .child('/syllabus/${branchNames[globals.branchIndex]}.pdf');
      var url = await fileRef.getDownloadURL();
      await FlutterDownloader.enqueue(
          url: url, savedDir: '/storage/emulated/0/Download/');
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

  onBackPressed(didPop) {
    if (didPop) {
      return;
    }
    widget.gotoDocsScreen();
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
            child: SizedBox(
                height: screenHeight * .8,
                width: screenWidth,
                child: FutureBuilder(
                    //It is called continuously till Future value is get.
                    future: loadFile(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SfPdfViewer.file(snapshot.data as File);
                      }
                      // Initially throws error because snapshot has no data.
                      return const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ),
                      );
                    })),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      onPressed: downloadFile,
                      icon: const Icon(
                        Icons.download_for_offline_rounded,
                        size: 70,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
