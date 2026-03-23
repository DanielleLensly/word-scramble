import 'dart:math';
import 'sum_generator_base.dart';

class Grade6Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final int choice = random.nextInt(4); 
    if (choice == 0) {
      final a = random.nextInt(9000) + 1000; // 1000-9999
      final b = random.nextInt(900) + 100; // 100-999
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 1) {
      final a = random.nextInt(1001) + 1000; // 1000-2000
      final b = random.nextInt(900) + 100; // 100-999 divisor
      return MathSum(operand1: a * b, operand2: b, operation: Operation.division, answer: a);
    } else if (choice == 2) {
      final a = random.nextInt(9000000) + 10000000; // 10M-19M
      final b = random.nextInt(9000000) + 10000000; // 10M-19M
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else {
      final a = random.nextInt(9000000) + 10000000; // 10M-19M
      final b = random.nextInt(9000000) + 1000000; // 1M-10M
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
