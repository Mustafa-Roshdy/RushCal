import 'dart:collection';
import 'dart:math';
import 'package:calapp/constant/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _display = '';
  String _result = '';

  void _onPressed(String value) {

    setState(() {
      if(_display=='Error'){
        _display='';
      }
      if (value == 'C') {
        _display = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = evaluateExpression(_display).toString();
        } catch (e) {
          _result = 'Error';
        }
      } else if (value == 'R') {
        if (_display.isNotEmpty) {
          _display = _display.substring(0, _display.length - 1);
        }
      } else if (value == 'Con.') {
        try {
          _display = evaluateExpression(_display).toString();
          _result = '';
        } catch (e) {
          _display = 'Error';
          _result = '';
        }
      }
       else {
        _display += value;
      }
    });
  }

  double evaluateExpression(String expression) {
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/');

    List<String> outputQueue = [];
    List<String> operatorStack = [];

    Map<String, int> precedence = {
      '+': 1,
      '-': 1,
      '*': 2,
      '/': 2,
      '^': 3,
    };

    Map<String, bool> rightAssociative = {
      '^': true,
    };

    final tokens = tokenize(expression);

    for (String token in tokens) {
      if (double.tryParse(token) != null) {
        outputQueue.add(token);
      } else if ("^*/+-".contains(token)) {
        while (operatorStack.isNotEmpty) {
          String top = operatorStack.last;
          if ("^*/+-".contains(top) &&
              ((rightAssociative[token] != true &&
                      precedence[token]! <= precedence[top]!) ||
                  (rightAssociative[token] == true &&
                      precedence[token]! < precedence[top]!))) {
            outputQueue.add(operatorStack.removeLast());
          } else {
            break;
          }
        }
        operatorStack.add(token);
      } else if (token == "(") {
        operatorStack.add(token);
      } else if (token == ")") {
        while (operatorStack.isNotEmpty && operatorStack.last != "(") {
          outputQueue.add(operatorStack.removeLast());
        }
        if (operatorStack.isEmpty) throw Exception("Mismatched parentheses");
        operatorStack.removeLast();
      }
    }

    while (operatorStack.isNotEmpty) {
      String op = operatorStack.removeLast();
      if (op == "(" || op == ")") throw Exception("Mismatched parentheses");
      outputQueue.add(op);
    }

    return evaluatePostfix(outputQueue);
  }

  double evaluatePostfix(List<String> postfix) {
    Queue<double> stack = Queue();

    for (String token in postfix) {
      if (double.tryParse(token) != null) {
        stack.addLast(double.parse(token));
      } else {
        double b = stack.removeLast();
        double a = stack.removeLast();
        switch (token) {
          case '+':
            stack.addLast(a + b);
            break;
          case '-':
            stack.addLast(a - b);
            break;
          case '*':
            stack.addLast(a * b);
            break;
          case '/':
            stack.addLast(a / b);
            break;
          case '^':
            stack.addLast(pow(a, b).toDouble());
            break;
        }
      }
    }

    return stack.single;
  }

  List<String> tokenize(String expr) {
    List<String> tokens = [];
    String number = "";

    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];
      if ("0123456789.".contains(char)) {
        number += char;
      } else {
        if (number.isNotEmpty) {
          tokens.add(number);
          number = "";
        }
        if ("()+-*/^".contains(char)) {
          tokens.add(char);
        }
      }
    }

    if (number.isNotEmpty) tokens.add(number);
    return tokens;
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? grayButton,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onPressed: () => _onPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, color: whiteButton),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String text,{Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:color??  const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: () => _onPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, color: whiteButton),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "#RushCal",
          style: TextStyle(
            fontFamily: "PlaywriteVN",
            color: headTitle,
            fontWeight: FontWeight.bold,fontSize: 25,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Text(
                _display,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.centerRight,
            child: Text(
              _result,
              style: const TextStyle(fontSize: 24, color: Colors.green),
            ),
          ),
          const Divider(),
          Column(
            children: [
              Row(children: [
                _buildSmallButton('('),
                _buildSmallButton('^'),
                _buildSmallButton(')'),
                _buildSmallButton('R'),
                _buildSmallButton('Con.'),
              ]),
              Row(children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('÷', color: yellowButton),
              ]),
              Row(children: [
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('×', color:yellowButton),
              ]),
              Row(children: [
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('-', color: yellowButton),
              ]),
              Row(children: [
                _buildButton('0'),
                _buildButton('.'),
                _buildButton('C', color:redButton),
                _buildButton('+', color: yellowButton),
              ]),
              Row(children: [
                _buildButton('=', color:equalButton),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
