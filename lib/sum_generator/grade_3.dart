import 'sum_generator_base.dart';

class Grade3Generator extends SumGenerator {
  @override
  List<MathSum> generateBatch(int count) {
    return List.generate(count, (_) => generateSum());
  }

  @override
  MathSum generateSum() {
    final int choice = random.nextInt(4); 
    if (choice == 0) {
      final a = random.nextInt(901) + 100; // 100-1000
      final b = random.nextInt(901) + 100; // 100-1000
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else if (choice == 1) {
      final a = random.nextInt(500) + 500; // 500-1000
      final b = random.nextInt(490) + 10; // 10-500
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    } else if (choice == 2) {
      final a = random.nextInt(11) + 2; // 2-12
      final b = random.nextInt(11) + 2; // 2-12
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else {
      final a = random.nextInt(11) + 2; // 2-12 divisor
      final b = random.nextInt(11) + 1; // 1-11 quotient
      return MathSum(operand1: a * b, operand2: a, operation: Operation.division, answer: b);
    }
  }
}
