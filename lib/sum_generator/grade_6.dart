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
      // Multiplication: 3-digit by 2-digit (Standard algorithm practice)
      final a = random.nextInt(900) + 100; // 100-999
      final b = random.nextInt(90) + 10;   // 10-99
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 1) {
      // Division: 4 or 5-digit by 2-digit (Long division practice)
      final q = random.nextInt(900) + 100; // Quotient 100-999
      final d = random.nextInt(89) + 11;   // Divisor 11-99
      return MathSum(operand1: q * d, operand2: d, operation: Operation.division, answer: q);
    } else if (choice == 2) {
      // Addition within 1,000,000
      final a = random.nextInt(900000) + 10000;
      final b = random.nextInt(900000) + 10000;
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else {
      // Subtraction within 1,000,000
      final a = random.nextInt(900000) + 100000;
      final b = random.nextInt(a - 10000) + 5000;
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
