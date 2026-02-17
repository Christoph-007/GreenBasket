import 'package:flutter/material.dart';
import 'package:greenbasket/bootstrap.dart';
import 'package:greenbasket/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const GreenBasketApp());
}
