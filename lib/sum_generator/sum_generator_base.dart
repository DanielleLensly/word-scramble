import 'dart:math';

enum Operation { addition, subtraction, multiplication, division }

class MathSum {
  final int operand1;
  final int operand2;
  final Operation operation;
  final int answer;

  MathSum({
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.answer,
  });

  @override
  String toString() {
    String op;
    switch (operation) {
      case Operation.addition:
        op = '+';
        break;
      case Operation.subtraction:
        op = '-';
        break;
      case Operation.multiplication:
        op = '×';
        break;
      case Operation.division:
        op = '÷';
        break;
    }
    return '$operand1 $op $operand2 = ';
  }
}

abstract class SumGenerator {
  final Random random = Random();

  List<MathSum> generateBatch(int count);
  MathSum generateSum();
}
