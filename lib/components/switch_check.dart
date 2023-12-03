import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwitchCheck extends StatefulWidget {
  final String label;
  final ValueChanged<bool>? onSwitchChanged;

  const SwitchCheck(
      {super.key, required this.label, required this.onSwitchChanged});

  @override
  State<SwitchCheck> createState() => _SwitchCheckState();
}

class _SwitchCheckState extends State<SwitchCheck> {
  bool isChecked = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isChecked = prefs.getBool('isMockDataSource') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value;
              if (widget.onSwitchChanged != null) {
                widget.onSwitchChanged!(isChecked);
              }
            });
          },
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          widget.label,
          style: const TextStyle(fontSize: 22.0),
        ),
      ],
    );
  }
}
