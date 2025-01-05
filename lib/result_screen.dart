import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  Future<void> _shareText(BuildContext context) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to share')),
      );
      return;
    }

    try {
      final box = context.findRenderObject() as RenderBox?;
      final sharePosition = box != null 
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
          
      await Share.share(
        text,
        subject: 'Scanned Text',
        sharePositionOrigin: sharePosition,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _createAndDownloadPDF(BuildContext context) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text to convert to PDF')),
      );
      return;
    }

    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

      // Create PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Center(
                child: pw.Text(text),
              ),
            );
          },
        ),
      );

      // Get directory for saving PDF
      final dir = await getApplicationDocumentsDirectory();
      final String fileName = 'scanned_text_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String path = '${dir.path}/$fileName';

      // Save PDF
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $path'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                try {
                  await Share.shareFiles([path], text: 'Scanned Text PDF');
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to open PDF')),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scanned Text'),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text copied to clipboard')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _createAndDownloadPDF(context),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareText(context),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(30.0),
          child: text.isEmpty 
            ? const Center(
                child: Text('No text detected', 
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              )
            : SingleChildScrollView(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
        ),
      );
}