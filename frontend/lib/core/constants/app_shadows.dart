import 'package:flutter/material.dart';

/// 5 shadow/elevation tokens from the Design System (Section 3.5).
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> low = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color(0x14000000), // rgba(0,0,0,0.08)
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x1F000000), // rgba(0,0,0,0.12)
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x29000000), // rgba(0,0,0,0.16)
    ),
  ];

  static const List<BoxShadow> highest = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x33000000), // rgba(0,0,0,0.20)
    ),
  ];

  // Material elevation mapping.
  static const double elevationNone = 0;
  static const double elevationLow = 2;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;
  static const double elevationHighest = 16;
}
