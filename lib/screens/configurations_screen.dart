import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:grafico_iot/components/switch_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late SharedPreferences prefs;
  late int maxSafeTemp = 0;
  late int minCriticalTemp = 0;
  late int currentACTemp = 0;
  late SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    supabase = Supabase.instance.client;
    dynamic data = await supabase
        .from('configuration')
        .select('temperature_lower, temperature_upper, temperature_air_conditioning')
        .single();

    setState(() {
      maxSafeTemp = data['temperature_lower'] ?? 0;
      minCriticalTemp = data['temperature_upper'] ?? 5;
      currentACTemp = data['temperature_air_conditioning'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SwitchCheck(
                label: 'Dados mocados',
                onSwitchChanged: _onMockDataSwitchChange,
              ),
              const SizedBox(height: 20),
              _buildNumericalInput(
                label: 'Temperatura crítica mínima',
                defaultValue: maxSafeTemp,
                dbFieldName: 'temperature_lower',
              ),
              const SizedBox(height: 20),
              _buildNumericalInput(
                label: 'Temperatura crítica máxima',
                defaultValue: minCriticalTemp,
                dbFieldName: 'temperature_upper',
              ),
              const SizedBox(height: 20),
              _buildNumericalInput(
                label: 'Temperatura atual do ar condicionado',
                defaultValue: currentACTemp,
                dbFieldName: 'temperature_air_conditioning',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericalInput({
    required String label,
    required int defaultValue,
    required String dbFieldName,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: 175,
          height: 50,
          child: SpinBox(
            min: -273,
            max: 100,
            value: defaultValue.toDouble(),
            onChanged: (value) async =>
                {
                  await supabase
                      .from('configuration')
                      .update({ dbFieldName: value })
                      .match({'id': 1})
                },
          ),
        ),
      ],
    );
  }

  void _onMockDataSwitchChange(bool value) async {
    await prefs.setBool('isMockDataSource', value);
  }
}
