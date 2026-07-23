import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_down_detector/screen_down_detector.dart';

class ScreenDownView extends StatefulWidget {
  const ScreenDownView({super.key});

  @override
  State<ScreenDownView> createState() => _ScreenDownViewState();
}

class _ScreenDownViewState extends State<ScreenDownView> {
  bool _showBalance = true;

  Future<void> _handleScreenDown() async {
    if (!_showBalance) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _showBalance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenDownDetector(
      onScreenDown: _handleScreenDown,
      child: Scaffold(
        appBar: AppBar(title: const Text('Bank')),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Text(
                '\$2500',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_showBalance) return;
                HapticFeedback.heavyImpact();
                setState(() {
                  _showBalance = true;
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _showBalance ? 0 : 8,
                  sigmaY: _showBalance ? 0 : 8,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
