import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/triage_service.dart';

class StatusBadge extends StatelessWidget {
  final RiskLevel level;
  final bool large;

  const StatusBadge({
    Key? key,
    required this.level,
    this.large = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.12),
        borderRadius: BorderRadius.circular(large ? 12 : 20),
        border: Border.all(
          color: config['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config['emoji'],
            style: TextStyle(fontSize: large ? 16 : 12),
          ),
          const SizedBox(width: 4),
          Text(
            config['label'],
            style: TextStyle(
              color: config['color'],
              fontSize: large ? 14 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getConfig() {
    switch (level) {
      case RiskLevel.low:
        return {
          'color': AppTheme.riskLow,
          'emoji': '✅',
          'label': 'Low Risk',
        };
      case RiskLevel.medium:
        return {
          'color': AppTheme.riskMedium,
          'emoji': '⚠️',
          'label': 'Medium Risk',
        };
      case RiskLevel.high:
        return {
          'color': AppTheme.riskHigh,
          'emoji': '🔴',
          'label': 'High Risk',
        };
      case RiskLevel.critical:
        return {
          'color': AppTheme.riskCritical,
          'emoji': '🚨',
          'label': 'Critical Risk',
        };
    }
  }
}

class VaccineStatusBadge extends StatelessWidget {
  final bool isCompleted;

  const VaccineStatusBadge({Key? key, required this.isCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppTheme.accentGreen : AppTheme.accentOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? 'Completed' : 'Pending',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
