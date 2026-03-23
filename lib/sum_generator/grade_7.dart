import 'dart:math';
import 'sum_generator_base.dart';

class Grade7Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final int choice = random.nextInt(4); 
    if (choice == 0) {
      // Negative numbers
      final a = (random.nextInt(101) - 50); // -50 to 50
      final b = (random.nextInt(101) - 50); // -50 to 50
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else if (choice == 1) {
      final a = (random.nextInt(51) - 25); // -25 to 25
      final b = random.nextInt(21) + 2; // 2-22
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 2) {
      final a = random.nextInt(9000) + 1000; // 1000-9999
      final b = random.nextInt(100) + 10; // 10-109
      return MathSum(operand1: a * b, operand2: b, operation: Operation.division, answer: a);
    } else {
      final a = (random.nextInt(101) - 50); // -50 to 50
      final b = (random.nextInt(101) - 50); // -50 to 50
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
