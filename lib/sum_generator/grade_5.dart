import 'sum_generator_base.dart';

class Grade5Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final int choice = random.nextInt(4); 
    if (choice == 0) {
      // Multiplication: 3-digit by 2-digit
      final a = random.nextInt(900) + 100; 
      final b = random.nextInt(90) + 10; 
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 1) {
      // Division: 4-digit by 2-digit
      final a = random.nextInt(900) + 100; // Quotient
      final b = random.nextInt(90) + 10;  // Divisor 10-99
      return MathSum(operand1: a * b, operand2: b, operation: Operation.division, answer: a);
    } else if (choice == 2) {
      // Addition up to 1,000,000
      final a = random.nextInt(900000) + 100000;
      final b = random.nextInt(900000) + 100000;
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else {
      // Subtraction up to 1,000,000
      final a = random.nextInt(900000) + 100000;
      final b = random.nextInt(a - 10000) + 5000;
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
