import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class TemperatureChart extends StatefulWidget {
  const TemperatureChart(
      {this.maxVisibleDataPoints = 60,
      this.dataFetchingPeriod = const Duration(seconds: 1),
      super.key});

  final int maxVisibleDataPoints;
  final Duration dataFetchingPeriod;

  @override
  State<TemperatureChart> createState() => _TemperatureChartState();
}

class _TemperatureChartState extends State<TemperatureChart> {
  late SharedPreferences prefs;
  late TooltipBehavior _tooltipBehavior;
  late List<TemperatureData> _data;
  late Timer _timer;
  late StreamSubscription<List<Map<String, dynamic>>> stream;
  ChartSeriesController? _chartSeriesController;
  late bool _isMockData = false;
  late bool _hasActiveConnection = false;
  late SupabaseClient supabase;

  @override
  void initState() {
    _initTooltipBehavior();
    _connectToDataSource();
    super.initState();
  }

  void _connectToDataSource() async {
    prefs = await SharedPreferences.getInstance();
    bool? mockDataSource = prefs.getBool('isMockDataSource');

    if (mockDataSource ?? false) {
      return setState(() {
        _isMockData = true;
        _data = _getInitialMockData();
        _timer =
            Timer.periodic(widget.dataFetchingPeriod, _updateMockDataSource);
      });
    } else {
      supabase = Supabase.instance.client;
      _data = await _getInitialSupabaseData();
      stream = supabase
          .from('registered_temperatures')
          .stream(primaryKey: ['id'])
          .order('id', ascending: false)
          .limit(1)
          .listen((List<Map<String, dynamic>> data) {
            _updateSupabaseDataSource(data.first);
          });
      setState(() {
        _hasActiveConnection = true;
      });
    }
  }

  List<TemperatureData> _getInitialMockData() {
    return [
      TemperatureData(
          DateTime.now().subtract(const Duration(seconds: 1)), 20.0),
      TemperatureData(DateTime.now(), 20.0),
    ];
  }

  Future<List<TemperatureData>> _getInitialSupabaseData() async {
    dynamic res = await supabase
        .from('registered_temperatures')
        .select('created_at, temperature')
        .order('id', ascending: false)
        .limit(widget.maxVisibleDataPoints);

    List<TemperatureData> data = [];
    for (var dataPoint in res) {
      data.add(TemperatureData(DateTime.parse(dataPoint['created_at']),
          double.parse(dataPoint['temperature'].toString())));
    }
    data = data.take(data.length - 1).toList().reversed.toList();
    return data;
  }

  void _updateMockDataSource(Timer timer) {
    if (_chartSeriesController == null) {
      return;
    }

    double newTemperature = RandomNumberGenerator.generateRandomNumber();
    final newDataPoint = TemperatureData(DateTime.now(), newTemperature);

    _data.add(newDataPoint);

    if (_data.length >= widget.maxVisibleDataPoints) {
      _data.removeAt(0);
      _chartSeriesController!.updateDataSource(
          addedDataIndexes: <int>[_data.length - 1],
          removedDataIndexes: <int>[0]);
    } else {
      _chartSeriesController!.updateDataSource(
        addedDataIndexes: <int>[_data.length - 1],
      );
    }
  }

  void _updateSupabaseDataSource(Map<String, dynamic> data) async {
    try {
      if (_chartSeriesController == null) {
        return;
      }

      final newDataPoint = TemperatureData(DateTime.parse(data['created_at']),
          double.parse(data['temperature'].toString()));
      _data.add(newDataPoint);

      if (_data.length > widget.maxVisibleDataPoints) {
        _data.removeAt(0);
        _chartSeriesController!.updateDataSource(
            addedDataIndexes: <int>[_data.length - 1],
            removedDataIndexes: <int>[0]);
      } else {
        _chartSeriesController!.updateDataSource(
          addedDataIndexes: <int>[_data.length - 1],
        );
      }
    } catch (e) {}
  }

  List<TemperatureData> getSupabaseData(AsyncSnapshot<Object?> snapshot) {
    List<Map<String, dynamic>> supabaseData =
        snapshot.data as List<Map<String, dynamic>>;
    List<TemperatureData> chartData = [];

    for (var dataPoint in supabaseData) {
      DateTime time = DateTime.parse(dataPoint['created_at']);
      double temperature = dataPoint['temperature']?.toDouble() ?? 0.0;

      chartData.add(TemperatureData(time, temperature));
    }
    return chartData;
  }

  void _initTooltipBehavior() {
    _tooltipBehavior = TooltipBehavior(
        enable: true,
        header: 'Horário (Temperatura)',
        opacity: 0.5,
        color: Colors.lightBlue,
        textStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        format: 'point.x (point.y)');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (_isMockData || _hasActiveConnection)
          ? renderSfCartesianChart(dataSource: _data, hasController: true)
          : const Text(
              'Não foi possível conectar ao servidor.'
              '\nVerifique suas configurações de conexão.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
    );
  }

  Padding renderSfCartesianChart(
      {required List<TemperatureData> dataSource, bool hasController = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        tooltipBehavior: _tooltipBehavior,
        primaryXAxis: DateTimeAxis(
          desiredIntervals: 4,
          dateFormat: DateFormat('H:m:s'),
        ),
        primaryYAxis: NumericAxis(
          labelFormat: '{value} ºC',
          desiredIntervals: 5,
        ),
        series: <LineSeries<TemperatureData, DateTime>>[
          LineSeries(
            onRendererCreated: hasController
                ? (ChartSeriesController controller) {
                    _chartSeriesController = controller;
                  }
                : null,
            enableTooltip: true,
            dataSource: dataSource,
            xValueMapper: (TemperatureData tmpData, _) => tmpData.time,
            yValueMapper: (TemperatureData tmpData, _) => tmpData.temperature,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _timer.cancel();
      stream.cancel();
      if (_hasActiveConnection) {
        supabase.dispose();
      }
    } catch (e) {}
  }
}

class TemperatureData {
  TemperatureData(this.time, this.temperature);

  final DateTime time;
  final double temperature;
}

class RandomNumberGenerator {
  static double _lastNumber = 20.0;

  static double generateRandomNumber() {
    Random random = Random();
    double minRange =
        max(_lastNumber - 1.2, 10); // Ensure the minimum range is not negative
    double maxRange = min(
        _lastNumber + 1.2, 40.0); // Ensure the maximum range is within limits

    double randomNumber =
        minRange + random.nextDouble() * (maxRange - minRange);
    _lastNumber = randomNumber; // Save the generated number for the next call
    return randomNumber;
  }
}
