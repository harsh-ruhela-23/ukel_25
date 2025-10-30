import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerScreen extends StatelessWidget {
  final String path;
  const PdfViewerScreen({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _downloadPdf() async {
      if (!Platform.isAndroid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download only supported on Android')),
        );
        return;
      }

      if (await Permission.manageExternalStorage.request().isDenied) {
        await openAppSettings();
        return;
      }

      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }
        final fileName = path.split('/').last;
        final newPath = '${downloadsDir.path}/$fileName';
        await File(path).copy(newPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to Download/$fileName')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }

    void _sharePdf() {
      Share.shareXFiles(
        [XFile(path)],
        text: 'Here is your invoice PDF 📄',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice PDF'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SfPdfViewer.file(File(path)),
      ),
    );
  }
}
