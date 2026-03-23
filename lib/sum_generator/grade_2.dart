import 'dart:math';
import 'sum_generator_base.dart';

class Grade2Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final int choice = random.nextInt(3); 
    if (choice == 0) {
      final a = random.nextInt(91) + 10; // 10-100
      final b = random.nextInt(91) + 10; // 10-100
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else if (choice == 1) {
      final a = random.nextInt(91) + 10; // 10-100
      final b = random.nextInt(a - 4) + 5; // 5-(a-1)
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    } else {
      final a = random.nextInt(6) + 1; // 1-6
      final b = random.nextInt(11); // 0-10
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    }
  }
}
