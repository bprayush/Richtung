import 'package:flutter/material.dart';
import 'package:richtung/compass.dart';

void main() => runApp(Richtung());

class Richtung extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Richtung',
      home: Compass(),
    );
  }
}
