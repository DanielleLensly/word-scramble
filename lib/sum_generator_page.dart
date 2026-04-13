import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'sum_generator/sum_generator.dart';
import 'theme_manager.dart';

class SumGeneratorPage extends StatefulWidget {
  const SumGeneratorPage({super.key});

  @override
  State<SumGeneratorPage> createState() => _SumGeneratorPageState();
}

class _SumGeneratorPageState extends State<SumGeneratorPage> {
  int _selectedGrade = 1;
  int _sumCount = 20;
  List<MathSum> _generatedSums = [];

  final List<int> _grades = [1, 2, 3, 4, 5, 6, 7];

  void _generateSums() {
    final generator = SumGeneratorFactory.getGenerator(_selectedGrade);
    setState(() {
      _generatedSums = generator.generateBatch(_sumCount);
    });
  }

  Future<void> _printSums() async {
    if (_generatedSums.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Math Challenge - Grade $_selectedGrade',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(bottom: 20)),
          pw.Wrap(
            spacing: 30,
            runSpacing: 25,
            children: _generatedSums.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final sum = entry.value;
              return pw.SizedBox(
                width: 240, // Increased width for larger sums
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('$index) $sum', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('________', style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }).toList(),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 40)),
          pw.Divider(color: PdfColors.blue),
          pw.Text(
            'Answer Key',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.Padding(padding: const pw.EdgeInsets.only(top: 10)),
          pw.Wrap(
            spacing: 20,
            runSpacing: 10,
            children: _generatedSums.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final sum = entry.value;
              return pw.Text(
                '$index) ${sum.answer}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              );
            }).toList(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Azure theme: Light Blue / Blue
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
          secondary: Colors.lightBlueAccent,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔢 Sum Generator', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade700,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: const [ThemeToggle(), SizedBox(width: 8)],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark 
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              _buildSettingsCard(),
              Expanded(
                child: _generatedSums.isEmpty
                    ? _buildEmptyState()
                    : _buildSumsList(),
              ),
              if (_generatedSums.isNotEmpty) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Grade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedGrade,
                        items: _grades.map((g) => DropdownMenuItem(
                          value: g,
                          child: Text('Grade $g'),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedGrade = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('How many sums?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _sumCount,
                        items: [10, 20, 30, 40, 50].map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('$c Sums'),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _sumCount = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateSums,
                icon: const Icon(Icons.refresh),
                label: const Text('Generate New Sums'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate_outlined, size: 80, color: Colors.blue.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Select a grade and generate some sums!',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSumsList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Single column to avoid overflow in UI
        childAspectRatio: 8,
        mainAxisSpacing: 10,
      ),
      itemCount: _generatedSums.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${index + 1}) ${_generatedSums[index]}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                '_______',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _printSums,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Print Math Worksheet (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.blue.shade400 : Colors.blue.shade700,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
