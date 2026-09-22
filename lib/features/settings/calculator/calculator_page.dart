import 'package:flutter/material.dart';
import 'calculator_button.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String display = "0";
  String expression = "";

  double? firstNumber;
  String? operation;

  bool shouldClear = false;

  void press(String value) {
    // ================= Numbers =================

    if ("0123456789".contains(value) || value == "00") {
      setState(() {
        if (shouldClear) {
          display = value == "00" ? "0" : value;
          shouldClear = false;
        } else {
          if (display == "0") {
            display = value == "00" ? "0" : value;
          } else {
            display += value;
          }
        }
      });
      return;
    }

    // ================= Decimal =================

    if (value == ".") {
      setState(() {
        if (shouldClear) {
          display = "0.";
          shouldClear = false;
        } else if (!display.contains(".")) {
          display += ".";
        }
      });
      return;
    }

    // ================= Clear =================

    if (value == "AC") {
      setState(() {
        display = "0";
        expression = "";
        firstNumber = null;
        operation = null;
        shouldClear = false;
      });
      return;
    }

    // ================= Positive / Negative =================

    if (value == "+/-") {
      setState(() {
        if (display != "0") {
          if (display.startsWith("-")) {
            display = display.substring(1);
          } else {
            display = "-$display";
          }
        }
      });
      return;
    }

    // ================= Percent =================

    if (value == "%") {
      setState(() {
        double number = double.parse(display) / 100;

        display = number % 1 == 0
            ? number.toInt().toString()
            : number.toString();
      });
      return;
    }

    // ================= Equals =================

    if (value == "=") {
      if (operation == null || firstNumber == null) return;

      double secondNumber = double.parse(display);
      double result = firstNumber!;

      switch (operation) {
        case "+":
          result += secondNumber;
          break;

        case "-":
          result -= secondNumber;
          break;

        case "×":
          result *= secondNumber;
          break;

        case "÷":
          result = secondNumber == 0 ? 0 : result / secondNumber;
          break;
      }

      setState(() {
        expression =
            "${firstNumber!.toString()} $operation ${secondNumber.toString()} =";

        display = result % 1 == 0
            ? result.toInt().toString()
            : result.toString();

        firstNumber = result;
        operation = null;
        shouldClear = true;
      });

      return;
    }

    // ================= Operators =================

    double current = double.parse(display);

    if (firstNumber == null) {
      firstNumber = current;
    } else if (!shouldClear && operation != null) {
      switch (operation) {
        case "+":
          firstNumber = firstNumber! + current;
          break;

        case "-":
          firstNumber = firstNumber! - current;
          break;

        case "×":
          firstNumber = firstNumber! * current;
          break;

        case "÷":
          firstNumber = current == 0 ? 0 : firstNumber! / current;
          break;
      }

      display = firstNumber! % 1 == 0
          ? firstNumber!.toInt().toString()
          : firstNumber.toString();
    }

    setState(() {
      operation = value;
      expression = "${firstNumber!.toString()} $operation";
      shouldClear = true;
    });
  }

  Color buttonColor(String text) {
    if ("÷×-+=".contains(text)) {
      return Colors.orange;
    }

    if (text == "AC") {
      return Colors.red;
    }

    return Colors.grey.shade800;
  }

  Widget buildRow(List<Widget> children) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //================ Display =================

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 30,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          expression,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            display,
                            style: const TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //================ Buttons =================

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    buildRow([
                      CalculatorButton(
                        text: "AC",
                        color: buttonColor("AC"),
                        onPressed: () => press("AC"),
                      ),
                      CalculatorButton(
                        text: "+/-",
                        color: Colors.grey.shade700,
                        onPressed: () => press("+/-"),
                      ),
                      CalculatorButton(
                        text: "%",
                        color: Colors.grey.shade700,
                        onPressed: () => press("%"),
                      ),
                      CalculatorButton(
                        text: "÷",
                        color: buttonColor("÷"),
                        onPressed: () => press("÷"),
                      ),
                    ]),

                    buildRow([
                      CalculatorButton(
                        text: "7",
                        color: Colors.grey.shade800,
                        onPressed: () => press("7"),
                      ),
                      CalculatorButton(
                        text: "8",
                        color: Colors.grey.shade800,
                        onPressed: () => press("8"),
                      ),
                      CalculatorButton(
                        text: "9",
                        color: Colors.grey.shade800,
                        onPressed: () => press("9"),
                      ),
                      CalculatorButton(
                        text: "×",
                        color: buttonColor("×"),
                        onPressed: () => press("×"),
                      ),
                    ]),

                    buildRow([
                      CalculatorButton(
                        text: "4",
                        color: Colors.grey.shade800,
                        onPressed: () => press("4"),
                      ),
                      CalculatorButton(
                        text: "5",
                        color: Colors.grey.shade800,
                        onPressed: () => press("5"),
                      ),
                      CalculatorButton(
                        text: "6",
                        color: Colors.grey.shade800,
                        onPressed: () => press("6"),
                      ),
                      CalculatorButton(
                        text: "-",
                        color: buttonColor("-"),
                        onPressed: () => press("-"),
                      ),
                    ]),

                    buildRow([
                      CalculatorButton(
                        text: "1",
                        color: Colors.grey.shade800,
                        onPressed: () => press("1"),
                      ),
                      CalculatorButton(
                        text: "2",
                        color: Colors.grey.shade800,
                        onPressed: () => press("2"),
                      ),
                      CalculatorButton(
                        text: "3",
                        color: Colors.grey.shade800,
                        onPressed: () => press("3"),
                      ),
                      CalculatorButton(
                        text: "+",
                        color: buttonColor("+"),
                        onPressed: () => press("+"),
                      ),
                    ]),

                    buildRow([
                      CalculatorButton(
                        text: "0",
                        flex: 2,
                        color: Colors.grey.shade800,
                        onPressed: () => press("0"),
                      ),
                      CalculatorButton(
                        text: "00",
                        color: Colors.grey.shade800,
                        onPressed: () => press("00"),
                      ),
                      CalculatorButton(
                        text: ".",
                        color: Colors.grey.shade800,
                        onPressed: () => press("."),
                      ),
                      CalculatorButton(
                        text: "=",
                        color: buttonColor("="),
                        onPressed: () => press("="),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}