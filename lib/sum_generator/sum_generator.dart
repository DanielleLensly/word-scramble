import 'sum_generator_base.dart';
import 'grade_1.dart';
import 'grade_2.dart';
import 'grade_3.dart';
import 'grade_4.dart';
import 'grade_5.dart';
import 'grade_6.dart';
import 'grade_7.dart';

export 'sum_generator_base.dart';
export 'grade_1.dart';
export 'grade_2.dart';
export 'grade_3.dart';
export 'grade_4.dart';
export 'grade_5.dart';
export 'grade_6.dart';
export 'grade_7.dart';

class SumGeneratorFactory {
  static SumGenerator getGenerator(int grade) {
    switch (grade) {
      case 1:
        return Grade1Generator();
      case 2:
        return Grade2Generator();
      case 3:
        return Grade3Generator();
      case 4:
        return Grade4Generator();
      case 5:
        return Grade5Generator();
      case 6:
        return Grade6Generator();
      case 7:
        return Grade7Generator();
      default:
        throw Exception('Unsupported grade: $grade');
    }
  }
}
