# ✨ Scramble Quest

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

**Scramble Quest** is a modern, cross-platform Flutter application designed for parents, teachers, and students. It allows users to quickly generate, customize, and print printable **Spelling Scramble Worksheets** and **Grade-Based Math Sum Worksheets**.

---

## 🚀 Features

- **🔤 Word Scramble Worksheets**:
  - **Age-Based Word Generator**: Curated spelling lists for ages 4-5, 6-7, 8-9, 10-11, and 12+ with customizable word counts (5, 10, or 20 words).
  - **Multi-Source Import**: Create lists by taking photos (OCR text recognition), uploading images from gallery, or importing `.pdf`, `.docx`, `.xlsx`, or `.txt` files.
  - **Manual Word Input & History**: Add words manually and automatically save lists to history for future reuse.
  - **Interactive View Controls**: Toggle letter case (`ABC` / `abc`) on tap and toggle "Hide Answers Mode" for classroom practice.

- **🔢 Math Sum Generator**:
  - **Grade-Based Algorithms**: Tailored math sum generators covering **Grades 1 through 7**.
  - **Supported Operations**: Addition, Subtraction, Multiplication, and Division with clean, age-appropriate division (no remainders).

- **📄 Printable PDF Export**:
  - **Dual PDF Styles**: Choose between **Fun Worksheet** (colorful accents, student name header line) and **Minimal / Ink Saver** (clean black & white).
  - **Efficient 2-Column Layout**: High-density side-by-side grid layout to maximize paper space.
  - **Teacher / Parent Answer Keys**: Includes an auto-generated answer key at the bottom of every PDF worksheet.

- **🌙 Dark Mode Support**: Smooth single-click light/dark theme switching persisted across app sessions.

---

## 📁 Project Architecture & File Locations

All application logic is structured cleanly within the `lib/` directory:

```text
lib/
├── main.dart                  # App Entry Point, Navigation & Word Scramble Feature
├── theme_manager.dart         # Global Light/Dark Theme Controller & Toggle Button
├── age_word_presets.dart      # Curated spelling word lists categorized by age
├── pdf_style_dialog.dart      # Shared dialog widget for choosing PDF styles ("Fun" vs "Minimal")
├── sum_generator_page.dart    # Math Sum Generator UI & PDF printer page
└── sum_generator/             # Strategy Pattern logic for math generation
    ├── sum_generator_base.dart  # Abstract base class & MathSum data model
    ├── sum_generator.dart       # Factory pattern returning the generator for a grade
    ├── grade_1.dart             # Addition & Subtraction up to 10
    ├── grade_2.dart             # Addition & Subtraction up to 20
    ├── grade_3.dart             # Addition, Subtraction & Multiplication (up to 5x5)
    ├── grade_4.dart             # Addition/Subtraction up to 1,000, Multiplication up to 10x10
    ├── grade_5.dart             # All 4 operations (+, -, ×, ÷ with clean division)
    ├── grade_6.dart             # Larger numbers & clean division
    └── grade_7.dart             # Pre-algebra style numbers & operations
```

---

## 🧩 Component & Code Architecture

### 1. State Management & Theme
- **Global Theme Switching**: Driven by `ValueNotifier<ThemeMode> themeNotifier` in [`lib/theme_manager.dart`](lib/theme_manager.dart). Listened to at the root widget level (`WordScrambleApp`) to ensure instantaneous UI updates without boilerplate.
- **Local Page State**: Managed using standard Flutter `StatefulWidget` instances (`setState`) and persisted locally using `SharedPreferences`.

### 2. Math Generator (Strategy & Factory Pattern)
- **Base Class (`lib/sum_generator/sum_generator_base.dart`)**: Defines the `MathSum` model and `SumGenerator` interface.
- **Factory (`lib/sum_generator/sum_generator.dart`)**: `SumGeneratorFactory.getGenerator(grade)` instantiates the appropriate grade strategy (`Grade1Generator` to `Grade7Generator`).

### 3. File & Image Processing
- **Text Recognition (OCR)**: Uses `google_mlkit_text_recognition` to extract printed spelling words directly from camera photos or uploaded images.
- **Document Parsing**: Utilizes `syncfusion_flutter_pdf` for PDFs, `docx_to_text` for Word documents, `excel` for spreadsheets, and plain text decoders.

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter extension

### Installation & Running

1. **Clone the repository**:
   ```bash
   git clone https://github.com/DanielleLensly/word-scramble.git
   cd word-scramble
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run static analysis**:
   ```bash
   flutter analyze lib
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).
