import 'dart:math';
import 'sum_generator_base.dart';

class Grade4Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final int choice = random.nextInt(4); 
    if (choice == 0) {
      final a = random.nextInt(900000) + 10000; // 10k-1M
      final b = random.nextInt(900000) + 10000; // 10k-1M
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else if (choice == 1) {
      final a = random.nextInt(90) + 10; // 10-99
      final b = random.nextInt(90) + 10; // 10-99
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 2) {
      final a = random.nextInt(900) + 100; // 100-999
      final b = random.nextInt(90) + 2; // 2-91 divisor
      return MathSum(operand1: a * b, operand2: b, operation: Operation.division, answer: a);
    } else {
      final a = random.nextInt(9000) + 1000; // 1000-9999
      final b = random.nextInt(9000) + 1000; // 1000-9999
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
