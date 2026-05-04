import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MatchScoreWidget extends StatelessWidget {
  final int score;

  const MatchScoreWidget({super.key, required this.score});

  Color get _scoreColor {
    if (score < 50) return Colors.red;
    if (score <= 75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 60.0,
      lineWidth: 10.0,
      percent: score / 100,
      center: Text(
        "$score%",
        style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
      progressColor: _scoreColor,
      backgroundColor: Colors.grey.shade200,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
