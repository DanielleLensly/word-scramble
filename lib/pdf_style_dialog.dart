import 'package:flutter/material.dart';

class PdfStyleSelectionDialog extends StatelessWidget {
  final Color themeColor;
  final Function(bool isFun) onStyleSelected;

  const PdfStyleSelectionDialog({
    super.key,
    required this.themeColor,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: themeColor),
          const SizedBox(width: 10),
          const Text('Choose PDF Style'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.auto_awesome, color: themeColor, size: 30),
              title: const Text('Fun Worksheet', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Colorful header, 2-column layout, styled cards.'),
              onTap: () {
                Navigator.pop(context);
                onStyleSelected(true);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.article_outlined, color: Colors.grey, size: 30),
              title: const Text('Minimal / Ink Saver', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Clean black & white, compact 2-column layout.'),
              onTap: () {
                Navigator.pop(context);
                onStyleSelected(false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
