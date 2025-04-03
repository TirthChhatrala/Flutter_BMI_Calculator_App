import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bmi_record.dart';
import '../utils/constants.dart';

class BmiService {
  // Calculate BMI
  double calculateBmi(double weight, double height) {
    // Convert height from cm to m
    final heightInMeters = height / 100;
    // BMI formula: weight (kg) / (height (m) * height (m))
    return weight / (heightInMeters * heightInMeters);
  }
  
  // Get BMI category
  String getBmiCategory(double bmi) {
    if (bmi < Constants.underweightSevere) {
      return "Severely Underweight";
    } else if (bmi < Constants.underweightModerate) {
      return "Moderately Underweight";
    } else if (bmi < Constants.underweightMild) {
      return "Mildly Underweight";
    } else if (bmi < Constants.normal) {
      return "Normal";
    } else if (bmi < Constants.overweight) {
      return "Overweight";
    } else if (bmi < Constants.obeseClass1) {
      return "Obese Class I";
    } else if (bmi < Constants.obeseClass2) {
      return "Obese Class II";
    } else {
      return "Obese Class III";
    }
  }
  
  // Save BMI record
  Future<bool> saveBmiRecord(BmiRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing records
      final String? recordsJson = prefs.getString('bmiRecords');
      List<BmiRecord> records = [];
      
      if (recordsJson != null) {
        final List<dynamic> decodedRecords = jsonDecode(recordsJson);
        records = decodedRecords.map((record) => BmiRecord.fromMap(record)).toList();
      }
      
      // Add new record
      records.add(record);
      
      // Save updated records
      await prefs.setString('bmiRecords', jsonEncode(records.map((record) => record.toMap()).toList()));
      
      return true;
    } catch (e) {
      print('Save BMI record error: $e');
      return false;
    }
  }
  
  // Get all BMI records
  Future<List<BmiRecord>> getAllBmiRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordsJson = prefs.getString('bmiRecords');
      
      if (recordsJson != null) {
        final List<dynamic> decodedRecords = jsonDecode(recordsJson);
        return decodedRecords.map((record) => BmiRecord.fromMap(record)).toList();
      }
      
      return [];
    } catch (e) {
      print('Get BMI records error: $e');
      return [];
    }
  }
  
  // Get BMI records for a specific user
  Future<List<BmiRecord>> getUserBmiRecords(String username) async {
    try {
      final records = await getAllBmiRecords();
      return records.where((record) => record.username == username).toList();
    } catch (e) {
      print('Get user BMI records error: $e');
      return [];
    }
  }
}