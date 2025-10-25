import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatelessWidget {
  final String pdfAsset;
  const PdfViewPage(this.pdfAsset, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
      body: SfPdfViewer.asset(pdfAsset),
    );
  }
}