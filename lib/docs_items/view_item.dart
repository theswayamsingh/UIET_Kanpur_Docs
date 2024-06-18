import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uiet_docs/globals.dart' as globals;

class ViewItem extends StatefulWidget {
  const ViewItem({super.key, required this.gotoItemsListScreen});
  final void Function() gotoItemsListScreen;

  @override
  State<ViewItem> createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
  cachedFile() async {
    String url =
        await globals.filesRef.items[globals.itemIndex].getDownloadURL();
    File file = await DefaultCacheManager().getSingleFile(url);
    return file;
  }

  onBackPressed(didPop) {
    if (didPop) {
      return;
    }
    widget.gotoItemsListScreen();
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
      child: FutureBuilder(
          future: cachedFile(),
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
            } else if (globals.navigationIndex!=0) {
              return SizedBox(
                  height: screenHeight * .804,
                  width: screenWidth,
                  child: SfPdfViewer.file(snapshot.data as File));
            } else {
              return Stack(
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
                  Center(child: Image.file(snapshot.data as File)),
                ],
              );
            }
          }),
    );
  }
}
