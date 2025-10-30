import 'package:flutter/material.dart';

class FishesPosterPage extends StatelessWidget {
  const FishesPosterPage({super.key});

  static const String asset = 'assets/images/all_fishes.png';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish species'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          // Pinch-zoom + pan (känns som scroll när du drar upp/ner)
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Image.asset(
              FishesPosterPage.asset,
              width: screenWidth,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }
}
