import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/database_service.dart';
import '../widgets/animated_counter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    final total = db.totalVaccines;
    final completed = db.completedVaccines;
    final pending = db.pendingVaccines;
    final progress = db.completionPercentage;
    final monthlyData = db.getVaccinesByMonth();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHealthScoreCard(progress),
              const SizedBox(height: 16),
              _buildStatsRow(total, completed, pending),
              const SizedBox(height: 16),
              _buildVaccineProgressChart(completed, pending),
              const SizedBox(height: 16),
              if (monthlyData.isNotEmpty) _buildMonthlyChart(monthlyData),
              if (monthlyData.isNotEmpty) const SizedBox(height: 16),
              _buildHealthInsightsCard(progress, total, completed),
              const SizedBox(height: 16),
              _buildVaccineRecommendations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(double progress) {
    final score = progress.round();
    final scoreColor = score >= 75
        ? AppTheme.accentGreen
        : score >= 50
            ? AppTheme.accentOrange
            : AppTheme.accentRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlueDark, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Health Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCounter(
                  value: score,
                  suffix: '%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedProgressBar(
                    progress: progress / 100,
                    progressColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    height: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  score >= 75
                      ? '🌟 Excellent vaccination coverage!'
                      : score >= 50
                          ? '⚠️ Good progress, keep it up!'
                          : '💡 Consider updating your vaccines',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score >= 75
                    ? '🏆'
                    : score >= 50
                        ? '💪'
                        : '💉',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int completed, int pending) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '💉',
            'Total',
            total,
            AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '✅',
            'Completed',
            completed,
            AppTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '⏰',
            'Pending',
            pending,
            AppTheme.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          AnimatedCounter(
            value: value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineProgressChart(int completed, int pending) {
    if (completed == 0 && pending == 0) {
      return _buildEmptyChartCard(
        'Vaccine Progress',
        'Add vaccine records to see your progress chart',
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vaccine Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (completed > 0)
                          PieChartSectionData(
                            value: completed.toDouble(),
                            color: AppTheme.accentGreen,
                            title: '$completed',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            radius: 60,
                          ),
                        if (pending > 0)
                          PieChartSectionData(
                            value: pending.toDouble(),
                            color: AppTheme.accentOrange,
                            title: '$pending',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            radius: 60,
                          ),
                      ],
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartLegend(AppTheme.accentGreen, 'Completed'),
                  const SizedBox(height: 12),
                  _buildChartLegend(AppTheme.accentOrange, 'Pending'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(Map<String, int> monthlyData) {
    final sortedKeys = monthlyData.keys.toList()..sort();
    final recentKeys = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    final spots = recentKeys.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (monthlyData[entry.value] ?? 0).toDouble(),
      );
    }).toList();

    final labels = recentKeys.map((key) {
      final parts = key.split('-');
      if (parts.length == 2) {
        final month = int.tryParse(parts[1]) ?? 1;
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return months[month - 1];
      }
      return key;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              labels[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textGray,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == value.roundToDouble()) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textGray,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsightsCard(
      double progress, int total, int completed) {
    final insights = _generateInsights(progress, total, completed);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight['emoji']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight['text']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _generateInsights(
      double progress, int total, int completed) {
    final insights = <Map<String, String>>[];

    if (total == 0) {
      insights.add({
        'emoji': '💡',
        'text': 'Start tracking your vaccines by adding your first record.',
      });
    } else if (progress >= 75) {
      insights.add({
        'emoji': '🌟',
        'text': 'Excellent! You have great vaccination coverage.',
      });
    } else if (progress >= 50) {
      insights.add({
        'emoji': '📈',
        'text': 'Good progress! Consider completing your pending vaccines.',
      });
    } else {
      insights.add({
        'emoji': '⚠️',
        'text':
            'You have several pending vaccines. Consult your doctor to update them.',
      });
    }

    insights.add({
      'emoji': '💉',
      'text':
          'WHO recommends staying up-to-date with all recommended vaccines for your age group.',
    });
    insights.add({
      'emoji': '📅',
      'text':
          'Annual flu vaccines are recommended for everyone 6 months and older.',
    });
    insights.add({
      'emoji': '🏥',
      'text':
          'Regular health check-ups help identify vaccine needs based on your health profile.',
    });

    return insights;
  }

  Widget _buildVaccineRecommendations() {
    final recommendations = [
      {
        'vaccine': 'COVID-19',
        'description': 'Stay up-to-date with boosters',
        'emoji': '🦠',
      },
      {
        'vaccine': 'Influenza',
        'description': 'Annual vaccination recommended',
        'emoji': '🤧',
      },
      {
        'vaccine': 'Tdap',
        'description': 'Every 10 years for adults',
        'emoji': '💉',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHO Recommendations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (rec) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Text(rec['emoji']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec['vaccine']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          rec['description']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textGray,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartCard(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text('📊', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
