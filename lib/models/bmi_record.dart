class BmiRecord {
  final String username;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final double bmiValue;
  final String category;
  final DateTime date;
  
  BmiRecord({
    required this.username,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.bmiValue,
    required this.category,
    required this.date,
  });
  
  // Convert BmiRecord object to a Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'bmiValue': bmiValue,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
  
  // Create a BmiRecord object from a Map
  factory BmiRecord.fromMap(Map<String, dynamic> map) {
    return BmiRecord(
      username: map['username'],
      weight: map['weight'],
      height: map['height'],
      age: map['age'],
      gender: map['gender'],
      bmiValue: map['bmiValue'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}