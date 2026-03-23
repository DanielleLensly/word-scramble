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
      final a = random.nextInt(900) + 100; // 100-999
      final b = random.nextInt(900) + 100; // 100-999
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 1) {
      final a = random.nextInt(1001) + 500; // 500-1500
      final b = random.nextInt(90) + 10; // 10-99 divisor
      return MathSum(operand1: a * b, operand2: b, operation: Operation.division, answer: a);
    } else if (choice == 2) {
      final a = random.nextInt(9000000) + 1000000; // 1M-10M
      final b = random.nextInt(9000000) + 1000000; // 1M-10M
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else {
      final a = random.nextInt(9000000) + 5000000; // 5M-10M
      final b = random.nextInt(4000000) + 1000000; // 1M-5M
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
