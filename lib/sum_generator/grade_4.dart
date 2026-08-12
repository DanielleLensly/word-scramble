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
      // Addition up to 100,000
      final a = random.nextInt(90000) + 1000; 
      final b = random.nextInt(90000) + 1000; 
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else if (choice == 1) {
      // Multiplication: 2-digit by 2-digit
      final a = random.nextInt(90) + 10; 
      final b = random.nextInt(90) + 10; 
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 2) {
      // Division: 3 or 4 digit by 1-digit
      final a = random.nextInt(900) + 100; // Quotient
      final b = random.nextInt(8) + 2;     // Divisor 2-9
      return MathSum(operand1: a * b, operand2: b, operation: Operation.division, answer: a);
    } else {
      // Subtraction within 100,000
      final a = random.nextInt(90000) + 10000;
      final b = random.nextInt(a - 1000) + 500;
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
