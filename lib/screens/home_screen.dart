import 'package:flutter/material.dart';
import 'package:grafico_iot/screens/chart_screen.dart';
import 'package:grafico_iot/screens/configurations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const Text(
                style: TextStyle(fontSize: 16),
                'Escolha uma opção no menu abaixo:',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChartScreen()));
              },
              child: const Text(
                'Temperatura do Servidor',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ConfigurationScreen()));
                },
                child: const Text('Configurações')),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                'Créditos',
              ),
            )
          ],
        ),
      ),
    );
  }
}
