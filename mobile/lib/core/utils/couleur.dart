import 'package:flutter/material.dart';

Color couleurDepuisHex(String? hex) {
  final h = (hex ?? '#8B0000').replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}