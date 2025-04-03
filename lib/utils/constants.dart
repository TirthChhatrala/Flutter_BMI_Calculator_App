class Constants {
  // BMI Categories
  static const double underweightSevere = 16.0;
  static const double underweightModerate = 17.0;
  static const double underweightMild = 18.5;
  static const double normal = 25.0;
  static const double overweight = 30.0;
  static const double obeseClass1 = 35.0;
  static const double obeseClass2 = 40.0;
  
  // BMI Messages
  static String getBmiMessage(double bmi) {
    if (bmi < underweightSevere) {
      return "You are severely underweight, please consult a doctor ⚠️";
    } else if (bmi < underweightModerate) {
      return "You are moderately underweight, consider improving your body mass 💪";
    } else if (bmi < underweightMild) {
      return "You are mildly underweight, consider improving your body mass 💪";
    } else if (bmi < normal) {
      return "Your body is fit 👍";
    } else if (bmi < overweight) {
      return "You are overweight, consider reducing your body mass ⚠️";
    } else if (bmi < obeseClass1) {
      return "You are obese (Class I), please consider a weight loss program ⚠️";
    } else if (bmi < obeseClass2) {
      return "You are obese (Class II), please consult a doctor ⚠️";
    } else {
      return "You are severely obese, please consult a doctor immediately ⚠️";
    }
  }
  
  // BMI Health Advice
  static String getBmiAdvice(double bmi) {
    if (bmi < underweightMild) {
      return "Try to increase your calorie intake with nutrient-rich foods. Consider consulting a nutritionist for a personalized diet plan.";
    } else if (bmi < normal) {
      return "Maintain your healthy lifestyle with a balanced diet and regular exercise.";
    } else {
      return "Focus on a balanced diet with reduced calorie intake and increased physical activity. Consider consulting a healthcare professional for guidance.";
    }
  }
  
  // Shared Preferences Keys
  static const String keyIsLoggedIn = "isLoggedIn";
  static const String keyUsername = "username";
  static const String keyIsAdmin = "isAdmin";
  static const String keyUserData = "userData";
  
  // Admin Credentials
  static const String adminUsername = "abc";
  static const String adminPassword = "123";
}