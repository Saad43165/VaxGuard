import 'package:flutter/material.dart';
import '../core/theme.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({Key? key}) : super(key: key);

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen>
    with SingleTickerProviderStateMixin {
  late Duration remainingTime;
  bool isTimerRunning = false;
  late AnimationController _animationController;
  final timerDuration = const Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    remainingTime = timerDuration;
    _animationController = AnimationController(
      duration: timerDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!isTimerRunning) {
      setState(() {
        isTimerRunning = true;
      });
      _tick();
    }
  }

  void _tick() {
    if (isTimerRunning && remainingTime.inSeconds > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            remainingTime = Duration(seconds: remainingTime.inSeconds - 1);
          });
          _tick();
        }
      });
    } else if (remainingTime.inSeconds == 0 && isTimerRunning) {
      setState(() {
        isTimerRunning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Wound washing complete! You\'re doing great.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '\$minutes:\$seconds.toString().padLeft(2, '0')';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Guide'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Warning Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  border: Border.all(color: AppTheme.accentOrange),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🧼 Wash Your Wound',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'This is the MOST IMPORTANT step. Wash with soap and clean water for 15 minutes.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: remainingTime.inSeconds / timerDuration.inSeconds,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _formatTime(remainingTime),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTimerRunning ? 'Timer Running' : 'Ready to Start',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Instructions
              const Text(
                'Step-by-Step Instructions:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStep(
                number: '1',
                title: 'Use Clean Water',
                description: 'Rinse the wound with clean, running water.',
              ),
              _buildStep(
                number: '2',
                title: 'Apply Soap',
                description: 'Use mild soap (antibacterial if available).',
              ),
              _buildStep(
                number: '3',
                title: 'Scrub Gently',
                description: 'Gently scrub the wound area.',
              ),
              _buildStep(
                number: '4',
                title: 'Rinse Again',
                description: 'Rinse thoroughly with clean water.',
              ),
              _buildStep(
                number: '5',
                title: 'Pat Dry',
                description: 'Dry with a clean cloth or sterile gauze.',
              ),
              const SizedBox(height: 40),

              // Start Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isTimerRunning ? null : _startTimer,
                  child: Text(
                    isTimerRunning ? 'Timer Running...' : 'Start 15-Minute Timer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}