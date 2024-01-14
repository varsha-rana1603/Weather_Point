import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_point/ui/home.dart';
import 'package:intl/intl.dart';

class ForecastWidget extends StatelessWidget {
  final Forecast forecast;
  final String Function(String) getImageAssetPath;
  final int index;

  const ForecastWidget({
    required this.forecast,
    required this.getImageAssetPath,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE').format(forecast.time),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Image.asset(
              getImageAssetPath(forecast.weatherState),
              width: 30,
            ),
            Text(
              '${forecast.temperature.toStringAsFixed(2)}°',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              forecast.weatherState,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}