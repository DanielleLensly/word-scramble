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
      // Integer Addition: -100 to 100
      final a = random.nextInt(201) - 100;
      final b = random.nextInt(201) - 100;
      return MathSum(operand1: a, operand2: b, operation: Operation.addition, answer: a + b);
    } else if (choice == 1) {
      // Integer Multiplication: -20 to 20
      final a = random.nextInt(41) - 20;
      final b = random.nextInt(41) - 20;
      return MathSum(operand1: a, operand2: b, operation: Operation.multiplication, answer: a * b);
    } else if (choice == 2) {
      // Integer Division
      final quotient = random.nextInt(41) - 20; // result -20 to 20
      int divisor;
      do {
        divisor = random.nextInt(25) - 12; // divisor -12 to 12
      } while (divisor == 0);
      
      return MathSum(operand1: quotient * divisor, operand2: divisor, operation: Operation.division, answer: quotient);
    } else {
      // Integer Subtraction: -100 to 100
      final a = random.nextInt(201) - 100;
      final b = random.nextInt(201) - 100;
      return MathSum(operand1: a, operand2: b, operation: Operation.subtraction, answer: a - b);
    }
  }
}
