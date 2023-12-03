import 'package:flutter/material.dart';

ThemeData oceanicTheme = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF002633),
        titleTextStyle: TextStyle(
            color: Color(0xFF88bfff),
            fontSize: 24,
            fontWeight: FontWeight.bold)),
    colorScheme: const ColorScheme(
        background: Color(0x99004c66),
        brightness: Brightness.dark,
        primary: Color(0xFF99DDff),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        error: Color(0xFFFF0000),
        onError: Color(0xFFFF0000),
        onBackground: Color(0xFFFFFFFF),
        surface: Color(0xBB006080),
        onSurface: Color(0xFF00ace6)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shadowColor: MaterialStateProperty.all(Colors.black38),
            textStyle: MaterialStateProperty.all(const TextStyle(
              fontSize: 17,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(2.5, 2.5),
                  blurRadius: 5.0,
                  color: Color.fromARGB(255, 35, 47, 58),
                ),
              ],
            )),
            fixedSize: MaterialStateProperty.all(const Size(270, 25)))));
