import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/result_card.dart';

class BmiResultScreen extends StatefulWidget {
  final BmiRecord bmiRecord;

  const BmiResultScreen({
    Key? key,
    required this.bmiRecord,
  }) : super(key: key);

  @override
  State<BmiResultScreen> createState() => _BmiResultScreenState();
}

class _BmiResultScreenState extends State<BmiResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBmiColor() {
    final bmi = widget.bmiRecord.bmiValue;
    
    if (bmi < Constants.underweightMild) {
      return Colors.blue;
    } else if (bmi < Constants.normal) {
      return Colors.green;
    } else if (bmi < Constants.overweight) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getBmiIcon() {
    final bmi = widget.bmiRecord.bmiValue;
    
    if (bmi < Constants.underweightMild) {
      return Icons.arrow_downward;
    } else if (bmi < Constants.normal) {
      return Icons.check_circle;
    } else if (bmi < Constants.overweight) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmiColor = _getBmiColor();
    final bmiIcon = _getBmiIcon();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            bmiIcon,
                            size: 80,
                            color: bmiColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your BMI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.bmiRecord.bmiValue.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: bmiColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.bmiRecord.category,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: bmiColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            Constants.getBmiMessage(widget.bmiRecord.bmiValue),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Advice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Constants.getBmiAdvice(widget.bmiRecord.bmiValue),
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ResultCard(
                    title: 'Gender',
                    value: widget.bmiRecord.gender,
                    color: theme.colorScheme.primary,
                    icon: widget.bmiRecord.gender == 'Male'
                        ? Icons.male
                        : widget.bmiRecord.gender == 'Female'
                            ? Icons.female
                            : Icons.person,
                  ),
                  ResultCard(
                    title: 'Age',
                    value: '${widget.bmiRecord.age} years',
                    color: theme.colorScheme.primary,
                    icon: Icons.calendar_today,
                  ),
                  ResultCard(
                    title: 'Weight',
                    value: '${widget.bmiRecord.weight} kg',
                    color: theme.colorScheme.primary,
                    icon: Icons.monitor_weight,
                  ),
                  ResultCard(
                    title: 'Height',
                    value: '${widget.bmiRecord.height} cm',
                    color: theme.colorScheme.primary,
                    icon: Icons.height,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Back to Calculator',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                isOutlined: true,
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      ),
    );
  }
}