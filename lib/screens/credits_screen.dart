import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const textStyle = TextStyle(fontSize: 24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Créditos'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Danielle Dos Santos Silva', style: textStyle),
            SizedBox(height: 20,),
            Text('Gabriel Furtado Lins Melo', style: textStyle),
            SizedBox(height: 20,),
            Text('Michael Silva De Souza', style: textStyle),
          ],
        ),
      ),
    );
  }
}
