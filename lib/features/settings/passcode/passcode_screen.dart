import 'package:flutter/material.dart';

import 'passcode_settings_page.dart';
import '../components/settings_grid.dart';
import '../../../theme/theme.dart';

enum PasscodeAction { create, authenticate, turnOff, change, unlock }

class PasscodeScreen extends StatefulWidget {
  final PasscodeAction action;
  final bool fromSettings;
  final VoidCallback? onUnlocked;

  const PasscodeScreen({
    super.key,
    required this.action,
    this.fromSettings = false,
    this.onUnlocked,
  });

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  String _enteredPin = "";
  String _firstPin = "";
  int _step = 0;
  bool _hasError = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    if (widget.action == PasscodeAction.change)
      _step = 0;
    else if (widget.action == PasscodeAction.create)
      _step = 1;
    else
      _step = 0;
  }

  void _triggerError(String msg) {
    setState(() {
      _hasError = true;
      _errorMessage = msg;
      _enteredPin = "";
    });
  }

  void _onNumPressed(String num) {
    if (_hasError) setState(() => _hasError = false);

    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += num;
      });

      if (_enteredPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (widget.action == PasscodeAction.unlock) {
            if (_enteredPin == passcodeNotifier.value) {
              widget.onUnlocked?.call();
            } else {
              _triggerError("Wrong Passcode\nPlease try again.");
            }
          } else if (widget.action == PasscodeAction.turnOff) {
            if (_enteredPin == passcodeNotifier.value) {
              passcodeNotifier.value = null;
              Navigator.pop(context);
            } else {
              _triggerError("Wrong Passcode\nPlease try again.");
            }
          } else if (widget.action == PasscodeAction.authenticate) {
            if (_enteredPin == passcodeNotifier.value) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PasscodeSettingsPage(),
                ),
              );
            } else {
              _triggerError("Wrong Passcode\nPlease try again.");
            }
          } else if (widget.action == PasscodeAction.create) {
            if (_step == 1) {
              _firstPin = _enteredPin;
              setState(() {
                _step = 2;
                _enteredPin = "";
              });
            } else if (_step == 2) {
              if (_enteredPin == _firstPin) {
                passcodeNotifier.value = _firstPin;
                if (widget.fromSettings) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasscodeSettingsPage(),
                    ),
                  );
                }
              } else {
                setState(() {
                  _step = 1;
                });
                _triggerError("Passcode does not match.\nPlease try again.");
              }
            }
          } else if (widget.action == PasscodeAction.change) {
            if (_step == 0) {
              if (_enteredPin == passcodeNotifier.value) {
                setState(() {
                  _step = 1;
                  _enteredPin = "";
                });
              } else {
                _triggerError("Wrong Passcode\nPlease try again.");
              }
            } else if (_step == 1) {
              _firstPin = _enteredPin;
              setState(() {
                _step = 2;
                _enteredPin = "";
              });
            } else if (_step == 2) {
              if (_enteredPin == _firstPin) {
                passcodeNotifier.value = _firstPin;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passcode changed successfully!'),
                  ),
                );
              } else {
                setState(() {
                  _step = 1;
                });
                _triggerError("Passcode does not match.\nPlease try again.");
              }
            }
          }
        });
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(
        () => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1),
      );
      if (_hasError) setState(() => _hasError = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.accentRed;
    const textColor = Colors.white;

    String appBarTitle = "";
    String mainTitle = "";

    if (widget.action == PasscodeAction.unlock) {
      appBarTitle = "Enter your passcode";
      mainTitle = "Enter your passcode";
    } else if (widget.action == PasscodeAction.turnOff) {
      appBarTitle = "Turn off Passcode";
      mainTitle = "Enter your passcode";
    } else if (widget.action == PasscodeAction.authenticate) {
      appBarTitle = "Enter your passcode";
      mainTitle = "Enter your passcode";
    } else if (widget.action == PasscodeAction.create) {
      appBarTitle = "Set Passcode";
      mainTitle = _step == 1 ? "Enter your passcode" : "Re-enter passcode";
    } else if (widget.action == PasscodeAction.change) {
      appBarTitle = "Set Passcode";
      if (_step == 0)
        mainTitle = "Enter your passcode";
      else if (_step == 1)
        mainTitle = "Change Passcode";
      else
        mainTitle = "Re-enter passcode";
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.action == PasscodeAction.unlock
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.savings, color: textColor, size: 48),
            const SizedBox(height: 24),

            Text(
              mainTitle,
              style: const TextStyle(color: textColor, fontSize: 20),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _hasError ? Colors.transparent : textColor,
                      width: 1.5,
                    ),
                    color: _hasError
                        ? (isDark ? Colors.red[400] : Colors.white70)
                        : (isFilled ? textColor : Colors.transparent),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),
            if (_hasError)
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.accentRed : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const SizedBox(height: 39),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  if (index == 9) return const SizedBox.shrink();
                  if (index == 11) {
                    return InkWell(
                      onTap: _onBackspace,
                      borderRadius: BorderRadius.circular(40),
                      child: const Center(
                        child: Icon(
                          Icons.backspace_outlined,
                          color: textColor,
                          size: 28,
                        ),
                      ),
                    );
                  }
                  String numText = index == 10 ? "0" : "${index + 1}";
                  return InkWell(
                    onTap: () => _onNumPressed(numText),
                    borderRadius: BorderRadius.circular(40),
                    child: Center(
                      child: Text(
                        numText,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
