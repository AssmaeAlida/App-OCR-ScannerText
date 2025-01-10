import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultScreen extends StatefulWidget {
  final String text;
  const ResultScreen({super.key, required this.text});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _isTranslating = false;
  bool _isSpeaking = false;
  String _originalText = '';
  String _selectedLanguage = 'fr';
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> _languages = {
    'fr': 'French',
    'es': 'Spanish',
    'de': 'German',
    'it': 'Italian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ru': 'Russian',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'en': 'English',
    'pt': 'Portuguese',
  };

  @override
  void initState() {
    super.initState();
    _originalText = widget.text;
    _textController = TextEditingController(text: widget.text);
    _initTts();
  }

 Future<void> _initTts() async {
    try {
      // Initialize TTS engine
      await flutterTts.setLanguage(_selectedLanguage);
      
      // Set speech parameters
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      
      // Set completion handler
      flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });

      // Set error handler
      flutterTts.setErrorHandler((msg) {
        setState(() => _isSpeaking = false);
        _showSnackBar('TTS Error: $msg');
      });

    } catch (e) {
      _showSnackBar('TTS Initialization failed: ${e.toString()}');
    }
  }


  @override
  void dispose() {
    _textController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('No text to translate');
      return;
    }

    setState(() => _isTranslating = true);
    try {
      final translation = await translator.translate(
        _textController.text,
        to: _selectedLanguage,
      );

      setState(() {
        _textController.text = translation.text;
        _isTranslating = false;
      });
      _showSnackBar('Translation completed');
    } catch (e) {
      setState(() => _isTranslating = false);
      _showSnackBar('Translation failed. Please try again.');
    }
  }

 Future<void> _speakText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('No text to speak');
      return;
    }

    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    try {
      // Update language before speaking
      await flutterTts.setLanguage(_selectedLanguage);
      
      // Check if language is supported
      final available = await flutterTts.isLanguageAvailable(_selectedLanguage);
      if (available) {
        await flutterTts.speak(_textController.text);
        setState(() => _isSpeaking = true);
      } else {
        _showSnackBar('Selected language not supported for TTS');
      }
    } catch (e) {
      _showSnackBar('TTS Error: ${e.toString()}');
    }
  }


  void _resetToOriginal() {
    setState(() {
      _textController.text = _originalText;
    });
    _showSnackBar('Original text restored');
  }

  Future<void> _shareText() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('No text to share');
      return;
    }

    try {
      final box = context.findRenderObject() as RenderBox?;
      final sharePosition = box != null 
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
          
      await Share.share(
        _textController.text,
        subject: 'Scanned Text',
        sharePositionOrigin: sharePosition,
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar('Unable to share. Please try again.');
      }
    }
  }

  Future<void> _createAndDownloadPDF() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('No text to convert to PDF');
      return;
    }

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          _showSnackBar('Storage permission denied');
        }
        return;
      }

      final pdf = await _createStyledPDF();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'scanned_text_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = '${dir.path}/$fileName';

      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        _showSnackBar('PDF saved successfully', action: SnackBarAction(
          label: 'Open',
          onPressed: () => _openPDF(path),
        ));
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create PDF');
      }
    }
  }

  Future<pw.Document> _createStyledPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Scanned Text', style: pw.TextStyle(fontSize: 24)),
                pw.Text(DateTime.now().toString()),
              ],
            ),
          ),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),
          pw.Text(_textController.text, style: pw.TextStyle(fontSize: 14, lineSpacing: 2)),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Footer(
            title: pw.Text('Generated by Text Scanner App'),
          ),
        ],
      ),
    );
    return pdf;
  }

  Future<void> _openPDF(String path) async {
    try {
      await Share.shareFiles([path], text: 'Scanned Text PDF');
    } catch (e) {
      if (mounted) {
        _showSnackBar('Unable to open PDF');
      }
    }
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: action,
      ),
    );
  }

  Widget _buildStatCard() {
    final words = _textController.text.split(' ').length;
    final chars = _textController.text.length;
    final lines = _textController.text.split('\n').length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Words', words),
            _buildStatItem('Characters', chars),
            _buildStatItem('Lines', lines),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTranslationControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: _selectedLanguage,
          items: _languages.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(e.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedLanguage = value!);
          },
        ),
        if (!_isTranslating)
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _translateText,
          )
        else
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        IconButton(
          icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
          onPressed: _speakText,
        ),
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: _resetToOriginal,
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Scan Result'),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      actions: [
        if (!_isEditing) _buildTranslationControls(),
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          onPressed: () {
            setState(() => _isEditing = !_isEditing);
            if (!_isEditing) {
              _showSnackBar('Changes saved');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _textController.text));
            _showSnackBar('Text copied to clipboard');
          },
        ),
      ],
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          _buildStatCard(),
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isEditing
                    ? TextField(
                        controller: _textController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Edit scanned text...',
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          _textController.text,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Save as PDF'),
                  onPressed: _createAndDownloadPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share Text'),
                  onPressed: _shareText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}