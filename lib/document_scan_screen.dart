import 'dart:io';
import 'package:flutter/material.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  final List<File> _scannedCards = [];
  bool _isProcessing = false;
  String? _lastPdfPath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _scanCard() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/card_${DateTime.now().millisecondsSinceEpoch}.jpg';

      bool success = await EdgeDetection.detectEdge(
        path,
        canUseGallery: false,
        androidScanTitle: 'Scanning Card',
        androidCropTitle: 'Crop Card',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );

      if (success) {
        setState(() {
          _scannedCards.add(File(path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning card: $e')),
      );
    }
  }

  Future<void> _createPDF() async {
    if (_scannedCards.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final pdf = pw.Document();

      for (var card in _scannedCards) {
        final image = pw.MemoryImage(card.readAsBytesSync());
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              final cardWidth = PdfPageFormat.a4.width * 0.8;
              final cardHeight = cardWidth * (53.98 / 85.60);

              return pw.Center(
                child: pw.Container(
                  width: cardWidth,
                  height: cardHeight,
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
              );
            },
          ),
        );
      }

      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/scanned_cards_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      _lastPdfPath = file.path;

      if (!mounted) return;
      
      _showPDFOptions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating PDF: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showPDFOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share PDF'),
            onTap: () {
              Navigator.pop(context);
              _sharePDF();
            },
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open PDF'),
            onTap: () {
              Navigator.pop(context);
              _openPDF();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sharePDF() async {
    if (_lastPdfPath == null) return;
    
    try {
      await Share.shareXFiles(
        [XFile(_lastPdfPath!)],
        subject: 'Scanned Cards PDF',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

Future<void> _openPDF() async {
  if (_lastPdfPath == null) return;
  
  try {
    final result = await OpenFile.open(_lastPdfPath!);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cannot open PDF: $e')),
    );
  }
}

  void _removeCard(int index) {
    setState(() {
      _scannedCards.removeAt(index);
      if (_scannedCards.isEmpty) {
        _lastPdfPath = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner'),
        actions: [
          if (_scannedCards.isNotEmpty) ...[
            IconButton(
              icon: _isProcessing 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.picture_as_pdf),
              onPressed: _isProcessing ? null : _createPDF,
            ),
            if (_lastPdfPath != null)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _showPDFOptions(),
              ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _scannedCards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.credit_card, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No cards scanned\nTap the camera button to start',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _scannedCards.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _scannedCards[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                color: Colors.white,
                                onPressed: () => _removeCard(index),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanCard,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Card'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}