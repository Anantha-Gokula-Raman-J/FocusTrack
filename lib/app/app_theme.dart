import 'package:flutter/material.dart';

const ink = Color(0xFF202D29);
const green = Color(0xFF28634C);
const muted = Color(0xFF78837C);
const paper = Color(0xFFF6F7F3);

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Segoe UI',
  scaffoldBackgroundColor: paper,
  colorScheme: ColorScheme.fromSeed(
    seedColor: green,
    primary: green,
    surface: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: ink, fontSize: 14),
    headlineMedium: TextStyle(
      color: ink,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: paper,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      side: const BorderSide(color: Color(0xFFBAC9BD)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(minimumSize: const Size(0, 44)),
  ),
  chipTheme: ChipThemeData(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    side: const BorderSide(color: Color(0xFFCFD8CD)),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFE9ECE6), thickness: 1),
);
