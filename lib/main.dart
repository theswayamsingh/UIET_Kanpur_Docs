import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:uiet_docs/logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // i.e. works on any device.
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  return runApp(const Logic());
}