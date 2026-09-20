import 'package:flutter/material.dart';
import 'calculator_button.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {

  String display = "0";

  double firstNumber = 0;

  String operation = "";

  bool shouldClear = false;

  void press(String value) {

    if ("0123456789".contains(value)) {

      setState(() {

        if (display == "0" || shouldClear) {
          display = value;
          shouldClear = false;
        } else {
          display += value;
        }

      });

      return;
    }

    if (value == "C") {

      setState(() {

        display = "0";
        firstNumber = 0;
        operation = "";
        shouldClear = false;

      });

      return;
    }

    if (value == "=") {

      double secondNumber = double.parse(display);

      double result = 0;

      switch (operation) {

        case "+":
          result = firstNumber + secondNumber;
          break;

        case "-":
          result = firstNumber - secondNumber;
          break;

        case "×":
          result = firstNumber * secondNumber;
          break;

        case "÷":
          result = secondNumber == 0
              ? 0
              : firstNumber / secondNumber;
          break;

      }

      setState(() {

        display = result.toStringAsFixed(
          result % 1 == 0 ? 0 : 2,
        );

        operation = "";

      });

      return;
    }

    firstNumber = double.parse(display);

    operation = value;

    shouldClear = true;
  }

  @override
  Widget build(BuildContext context) {

    final buttons = [

      "7","8","9","÷",
      "4","5","6","×",
      "1","2","3","-",
      "C","0","=","+",

    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Calculator"),
      ),

      body: Column(

        children: [

          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: GridView.builder(

              padding: const EdgeInsets.all(12),

              itemCount: buttons.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),

              itemBuilder: (context, index) {

                final text = buttons[index];

                return CalculatorButton(

                  text: text,

                  color: "+-×÷=".contains(text)
                      ? Colors.orange
                      : text == "C"
                          ? Colors.red
                          : Colors.grey.shade800,

                  onPressed: () => press(text),

                );

              },

            ),
          ),

        ],

      ),

    );
  }
}