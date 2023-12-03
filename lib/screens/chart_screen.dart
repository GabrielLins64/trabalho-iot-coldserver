import 'package:flutter/material.dart';
import 'package:grafico_iot/components/chart_temperature.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  final TemperatureChart _chart = const TemperatureChart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Temperatura do Servidor'),
      ),
      body: _chart,
    );
  }
}
