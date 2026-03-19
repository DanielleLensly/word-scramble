import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:docx_to_text/docx_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


void main() {
  runApp(const WordScramblerApp());
}

class WordScramblerApp extends StatelessWidget {
  const WordScramblerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Scramble Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          primary: Colors.pink,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ScrambleMainPage(),
    );
  }
}

class WordPair {
  final String original;
  final String scrambled;

  WordPair({required this.original, required this.scrambled});
}

class ScrambleMainPage extends StatefulWidget {
  const ScrambleMainPage({super.key});

  @override
  State<ScrambleMainPage> createState() => _ScrambleMainPageState();
}

class _ScrambleMainPageState extends State<ScrambleMainPage> {
  final List<WordPair> _wordPairs = [];
  bool _isLoading = false;
  bool _isUppercase = true;
  final ImagePicker _picker = ImagePicker();
  DateTime? _lastBackPressTime;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _scrambleWord(String word) {
    if (word.length <= 1) return word;
    List<String> letters = word.split('')..shuffle();
    String scrambled = letters.join('');
    if (scrambled == word && word.length > 1) {
      return _scrambleWord(word);
    }
    return scrambled;
  }

  String _formatScrambled(String word) {
    return _isUppercase ? word.toUpperCase() : word.toLowerCase();
  }

  void _addWordsToList(List<String> words) {
    final List<String> duplicates = [];
    setState(() {
      for (var word in words) {
        final cleaned = word.trim();
        if (cleaned.length >= 2) {
          if (_wordPairs.any((p) => p.original.toLowerCase() == cleaned.toLowerCase())) {
            duplicates.add(cleaned);
          } else {
            _wordPairs.add(
              WordPair(original: cleaned, scrambled: _scrambleWord(cleaned)),
            );
          }
        }
      }
    });
    if (duplicates.isNotEmpty && mounted) {
      final msg = duplicates.length == 1
          ? '"${duplicates.first}" is already in the list.'
          : '${duplicates.length} words are already in the list: ${duplicates.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _scrollToBottom();
  }

  Future<void> _saveUploadToHistory(List<String> words) async {
    if (words.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('upload_history') ?? [];

    final batch = {
      'date': DateTime.now().toIso8601String(),
      'words': words,
    };
    history.insert(0, jsonEncode(batch)); // newest first
    if (history.length > 20) history = history.sublist(0, 20); // Keep last 20 uploads

    await prefs.setStringList('upload_history', history);
  }

  Future<void> _showPastUploadsDialog() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('upload_history') ?? [];

    if (history.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Past Uploads'),
          content: const Text("You haven't imported any word lists yet!"),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Past Uploads'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final batch = jsonDecode(history[index]);
              final wordsList = List<String>.from(batch['words']);
              final date = DateTime.parse(batch['date']);
              final displayDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.indigo),
                  title: Text(displayDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("${wordsList.length} words: ${wordsList.take(4).join(', ')}..."),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _showHistoryDetailDialog(wordsList, displayDate);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDetailDialog(List<String> words, String dateLabel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Words from This Upload', style: TextStyle(fontSize: 18)),
            Text(dateLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.indigo.shade50,
                      child: Text("${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.indigo)),
                    ),
                    title: Text(words[index]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _addWordsToList(words);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Add All to List', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPastUploadsDialog(); // Go back to history list
            },
            child: const Text('Back to History'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      _processImage(photo.path);
    }
  }

  Future<void> _processImage(String path) async {
    setState(() => _isLoading = true);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      List<String> extractedWords = _extractWords(recognizedText.text);
      if (mounted) {
        _showReviewDialog(extractedWords);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error recognizing text: $e')));
      }
    } finally {
      textRecognizer.close();
      setState(() => _isLoading = false);
    }
  }

  void _showReviewDialog(List<String> words) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReviewWordsDialog(
        initialWords: words,
        onConfirmed: (confirmedWords) {
          _saveUploadToHistory(confirmedWords);
          _addWordsToList(confirmedWords);
        },
      ),
    );
  }

  Future<void> _pickFiles() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx', 'xlsx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          await _processFile(file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processFile(PlatformFile file) async {
    List<String> wordsFromFile = [];
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) return;

    final String extension = file.extension?.toLowerCase() ?? '';

    if (extension == 'txt') {
      final content = String.fromCharCodes(bytes);
      wordsFromFile = _extractWords(content);
    } else if (extension == 'pdf') {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: bytes);
      final String content = sf.PdfTextExtractor(document).extractText();
      wordsFromFile = _extractWords(content);
      document.dispose();
    } else if (extension == 'docx') {
      final content = docxToText(bytes);
      wordsFromFile = _extractWords(content);
    } else if (extension == 'xlsx') {
      final excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          for (var cell in row) {
            if (cell != null) {
              wordsFromFile.addAll(_extractWords(cell.value.toString()));
            }
          }
        }
      }
    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      if (file.path != null) {
        final textRecognizer = TextRecognizer(
          script: TextRecognitionScript.latin,
        );
        try {
          final inputImage = InputImage.fromFilePath(file.path!);
          final RecognizedText recognizedText = await textRecognizer
              .processImage(inputImage);
          wordsFromFile = _extractWords(recognizedText.text);
        } finally {
          textRecognizer.close();
        }
      }
    }
    _saveUploadToHistory(wordsFromFile);
    _addWordsToList(wordsFromFile);
  }

  List<String> _extractWords(String text) {
    // Only split on whitespace and common word-listing separators
    return text
        .split(RegExp(r'[\s\n\r,;:]+'))
        .map((s) => s.trim())
        // Trim common surrounding punctuation like dots, etc., but keep what's inside
        .map((s) => s.replaceAll(RegExp(r'^[.!?\(\)\[\]{}"]+|[.!?\(\)\[\]{}"]+$'), '')) 
        .where((s) => s.isNotEmpty && s.length >= 2)
        .toList();
  }

  void _removeWordPair(int index) {
    setState(() {
      _wordPairs.removeAt(index);
    });
  }

  void _clearWords() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear List?'),
        content: const Text('Are you sure you want to remove all words from the current list? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _wordPairs.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicyUrl() async {
    final Uri url = Uri.parse('https://docs.google.com/document/d/1bLDYvlPBiM_3pRkdquVxBZ-oa4kAyZH3lL53QEhghCc/edit?tab=t.0');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Privacy Policy link')),
        );
      }
    }
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.pink),
            SizedBox(width: 10),
            Text('Privacy Policy'),
          ],
        ),
        content: const Text(
          'Kids Scramble Quest does not collect, store, or share any personal data. '
          'All word lists stay on your device. Tap below to read the full policy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _launchPrivacyPolicyUrl();
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View Privacy Policy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _reshuffleScrambled(int index) {
    setState(() {
      _wordPairs[index] = WordPair(
        original: _wordPairs[index].original,
        scrambled: _scrambleWord(_wordPairs[index].original),
      );
    });
  }


  void _showAddManualWordDialog() {
    final controller = TextEditingController();
    String? errorText;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Word Manually'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter a spelling word',
                errorText: errorText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (val) {
                final text = val.trim();
                if (text.isEmpty) {
                  setDialogState(() => errorText = 'Please enter a word.');
                } else if (text.length < 2) {
                  setDialogState(() => errorText = 'Word must be at least 2 letters.');
                } else {
                  _addWordsToList([text]);
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) {
                    setDialogState(() => errorText = 'Please enter a word.');
                  } else if (text.length < 2) {
                    setDialogState(() => errorText = 'Word must be at least 2 letters.');
                  } else {
                    _addWordsToList([text]);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _generateAndPrintPDF() async {
    if (_wordPairs.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Spelling Scramble Challenge!',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.pink,
              ),
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(bottom: 20)),
          pw.TableHelper.fromTextArray(
            headers: ['Scrambled Letters', 'Your Answer'],
            data: _wordPairs
                .map(
                  (pair) => [
                    _formatScrambled(pair.scrambled),
                    '____________________',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.pink),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 40,
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 40)),
          pw.Divider(color: PdfColors.pink),
          pw.Text(
            'Teacher/Parent Key (Fold or cut here)',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _wordPairs
                .map(
                  (pair) => pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '${_formatScrambled(pair.scrambled)} = ',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.TextSpan(
                          text: pair.original.toLowerCase(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text(
          '✨ Kids Scramble Quest ✨',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.pink,
        actions: [
          Row(
            children: [
              Text(
                _isUppercase ? 'ABC' : 'abc',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Switch(
                value: _isUppercase,
                onChanged: (val) => setState(() => _isUppercase = val),
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.pinkAccent,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Colors.white),
            onPressed: _showPrivacyPolicyDialog,
            tooltip: 'Privacy Policy',
          ),
          if (_wordPairs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: _clearWords,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(color: Colors.pink),
            Expanded(
              child: _wordPairs.isEmpty
                  ? _buildEmptyState()
                  : _buildWordPreviewList(),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 80,
              color: Colors.pink.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome! How would you like to start your spelling list?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildBigButton(
              icon: Icons.camera_alt,
              label: 'Take a Photo',
              color: Colors.pinkAccent,
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _buildBigButton(
              icon: Icons.image,
              label: 'Upload Image (Gallery)',
              color: Colors.blueAccent,
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _buildBigButton(
              icon: Icons.file_upload,
              label: 'Import File (PDF, Docs, etc.)',
              color: Colors.orangeAccent,
              onPressed: _pickFiles,
            ),
            const SizedBox(height: 12),
            _buildBigButton(
              icon: Icons.edit,
              label: 'Type Words Manually',
              color: Colors.teal,
              onPressed: _showAddManualWordDialog,
            ),

            const SizedBox(height: 12),
            _buildBigButton(
              icon: Icons.history,
              label: 'Past Uploads (History)',
              color: Colors.indigo,
              onPressed: _showPastUploadsDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildWordPreviewList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _wordPairs.length,
      itemBuilder: (context, index) {
        final pair = _wordPairs[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Original',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pair.original.toLowerCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.pinkAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scrambled',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatScrambled(pair.scrambled),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
                  onPressed: () => _reshuffleScrambled(index),
                  tooltip: 'Reshuffle',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _removeWordPair(index),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    if (_wordPairs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                _buildSmallActionIcon(
                  Icons.camera_alt,
                  'Photo',
                  Colors.pinkAccent,
                  () => _pickImage(ImageSource.camera),
                ),
                _buildSmallActionIcon(
                  Icons.image,
                  'Image',
                  Colors.blueAccent,
                  () => _pickImage(ImageSource.gallery),
                ),
                _buildSmallActionIcon(
                  Icons.file_upload,
                  'File',
                  Colors.orangeAccent,
                  _pickFiles,
                ),
                _buildSmallActionIcon(
                  Icons.edit,
                  'Type',
                  Colors.teal,
                  _showAddManualWordDialog,
                ),
                _buildSmallActionIcon(
                  Icons.history,
                  'Past',
                  Colors.indigo,
                  _showPastUploadsDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _wordPairs.isEmpty || _isLoading
                    ? null
                    : _generateAndPrintPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Print PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionIcon(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: InkWell(
        onTap: _isLoading ? null : onPressed,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewWordsDialog extends StatefulWidget {
  final List<String> initialWords;
  final Function(List<String>) onConfirmed;

  const ReviewWordsDialog({
    super.key,
    required this.initialWords,
    required this.onConfirmed,
  });

  @override
  State<ReviewWordsDialog> createState() => _ReviewWordsDialogState();
}

class _ReviewWordsDialogState extends State<ReviewWordsDialog> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  final ScrollController _scrollController = ScrollController();

  bool _isWordSuspicious(String word) {
    // Flag words containing digits or non-letter characters (except hyphens/apostrophes)
    return word.isNotEmpty &&
        word.contains(RegExp(r"[^a-zA-Z\u00C0-\u024F\-\']"));
  }

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialWords
        .map((w) => TextEditingController(text: w))
        .toList();
    _focusNodes = List.generate(_controllers.length, (_) => FocusNode());
    for (var ctrl in _controllers) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  void _addWordAt(int index) {
    setState(() {
      final ctrl = TextEditingController();
      ctrl.addListener(() => setState(() {}));
      _controllers.insert(index, ctrl);
      _focusNodes.insert(index, FocusNode());
    });

    // Request focus for the newly added field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes[index].canRequestFocus) {
        _focusNodes[index].requestFocus();
      }
    });

    // Small delay to let the frame update before scrolling
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        // Approximate calculation: row height is around 68px (padding + TextField)
        double offset = index * 68.0;
        // Clamp the offset to avoid overscrolling
        if (offset > _scrollController.position.maxScrollExtent) {
          offset = _scrollController.position.maxScrollExtent;
        }
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var fn in _focusNodes) {
      fn.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSuspicious = _controllers.any((c) => _isWordSuspicious(c.text));
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.spellcheck, color: Colors.pink),
          SizedBox(width: 10),
          Text('Review Words'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            const Text('Are these words correct? You can edit or remove them.'),
            if (hasSuspicious) ...[  
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Some words look unusual (highlighted below). Please check if they are correct.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _controllers.isEmpty
                        ? const Center(
                            child: Text('No words found. Try a clearer photo.'),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _controllers.length,
                            itemBuilder: (context, index) {
                              final isSuspicious =
                                  _isWordSuspicious(_controllers[index].text);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Word ${index + 1}',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          filled: isSuspicious,
                                          fillColor: isSuspicious
                                              ? Colors.orange.shade50
                                              : null,
                                          enabledBorder: isSuspicious
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .orange.shade400,
                                                      width: 1.5),
                                                )
                                              : null,
                                          suffixIcon: isSuspicious
                                              ? Tooltip(
                                                  message:
                                                      'This word looks unusual — is it correct?',
                                                  child: Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors
                                                          .orange.shade700),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => _addWordAt(index + 1),
                                      tooltip: 'Add word after this one',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _controllers[index].dispose();
                                          _controllers.removeAt(index);
                                          _focusNodes[index].dispose();
                                          _focusNodes.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _addWordAt(_controllers.length),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Missing Word'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            List<String> finalWords = [];
            for (var c in _controllers) {
              String text = c.text.trim();
              if (text.isNotEmpty) {
                // Split by spaces or newlines in case user put 2 words in one box
                finalWords.addAll(text.split(RegExp(r"\s+")));
              }
            }
            // Pop first to avoid UI feeling 'stuck' or blocked by parent rebuilds
            Navigator.of(context).pop();
            widget.onConfirmed(finalWords);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add to List'),
        ),
      ],
    );
  }
}
