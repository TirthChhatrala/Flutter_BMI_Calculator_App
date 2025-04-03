import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../services/auth_service.dart';
import '../services/bmi_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_slider.dart';
import '../widgets/gender_selector.dart';
import 'bmi_result_screen.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final AuthService _authService = AuthService();
  final BmiService _bmiService = BmiService();
  
  String _selectedGender = 'Male';
  double _weight = 70.0;
  double _height = 170.0;
  int _age = 25;
  bool _isCalculating = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _weightController.text = _weight.toString();
    _heightController.text = _height.toString();
    _ageController.text = _age.toString();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _calculateBmi() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      try {
        final username = await _authService.getCurrentUsername();
        final bmiValue = _bmiService.calculateBmi(_weight, _height);
        final bmiCategory = _bmiService.getBmiCategory(bmiValue);
        
        final bmiRecord = BmiRecord(
          username: username,
          weight: _weight,
          height: _height,
          age: _age,
          gender: _selectedGender,
          bmiValue: bmiValue,
          category: bmiCategory,
          date: DateTime.now(),
        );
        
        await _bmiService.saveBmiRecord(bmiRecord);
        
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BmiResultScreen(bmiRecord: bmiRecord),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error calculating BMI: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate BMI'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Gender',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GenderSelector(
                    selectedGender: _selectedGender,
                    onGenderSelected: (gender) {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomSlider(
                    title: 'Weight',
                    unit: 'kg',
                    value: _weight,
                    min: 30,
                    max: 150,
                    divisions: 120,
                    controller: _weightController,
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomSlider(
                    title: 'Height',
                    unit: 'cm',
                    value: _height,
                    min: 100,
                    max: 220,
                    divisions: 120,
                    controller: _heightController,
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
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
                          'Age',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_age > 1) {
                                  setState(() {
                                    _age--;
                                    _ageController.text = _age.toString();
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove_circle),
                              iconSize: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    final newAge = int.tryParse(value);
                                    if (newAge != null && newAge > 0 && newAge < 120) {
                                      setState(() {
                                        _age = newAge;
                                      });
                                    }
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age <= 0 || age >= 120) {
                                    return 'Invalid age';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {
                                if (_age < 120) {
                                  setState(() {
                                    _age++;
                                    _ageController.text = _age.toString();
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_circle),
                              iconSize: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Calculate BMI',
                    onPressed: _calculateBmi,
                    isLoading: _isCalculating,
                    icon: Icons.calculate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}