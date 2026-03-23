import 'dart:math';
import 'sum_generator_base.dart';

class Grade1Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final bool isAddition = random.nextBool();
    if (isAddition) {
      final a = random.nextInt(11); // 0-10
      final b = random.nextInt(11); // 0-10
      return MathSum(
        operand1: a,
        operand2: b,
        operation: Operation.addition,
        answer: a + b,
      );
    } else {
      final a = random.nextInt(11) + 5; // 5-15
      final b = random.nextInt(a + 1); // 0-a
      return MathSum(
        operand1: a,
        operand2: b,
        operation: Operation.subtraction,
        answer: a - b,
      );
    }
  }
}
