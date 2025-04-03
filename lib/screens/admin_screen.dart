import 'package:flutter/material.dart';
import '../models/bmi_record.dart';
import '../services/auth_service.dart';
import '../services/bmi_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final BmiService _bmiService = BmiService();
  List<BmiRecord> _allRecords = [];
  Map<String, List<BmiRecord>> _userRecords = {};
  bool _isLoading = true;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final records = await _bmiService.getAllBmiRecords();
      
      // Group records by username
      final Map<String, List<BmiRecord>> userRecords = {};
      
      for (final record in records) {
        if (userRecords.containsKey(record.username)) {
          userRecords[record.username]!.add(record);
        } else {
          userRecords[record.username] = [record];
        }
      }
      
      setState(() {
        _allRecords = records;
        _allRecords.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
        
        _userRecords = userRecords;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Color _getBmiColor(double bmi) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Records'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // All Records Tab
                _allRecords.isEmpty
                    ? _buildEmptyState('No BMI records found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _allRecords.length,
                        itemBuilder: (context, index) {
                          final record = _allRecords[index];
                          final bmiColor = _getBmiColor(record.bmiValue);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'User: ${record.username}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${record.date.day}/${record.date.month}/${record.date.year}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'BMI',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              record.bmiValue.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: bmiColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Category',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: bmiColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                record.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: bmiColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Gender',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              record.gender,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Weight',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${record.weight} kg',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Height',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${record.height} cm',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Age',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${record.age} years',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                
                // Users Tab
                _userRecords.isEmpty
                    ? _buildEmptyState('No users found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _userRecords.keys.length,
                        itemBuilder: (context, index) {
                          final username = _userRecords.keys.elementAt(index);
                          final records = _userRecords[username]!;
                          final recordCount = records.length;
                          
                          // Calculate average BMI
                          double totalBmi = 0;
                          for (final record in records) {
                            totalBmi += record.bmiValue;
                          }
                          final averageBmi = totalBmi / recordCount;
                          final bmiColor = _getBmiColor(averageBmi);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$recordCount records',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Average BMI',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              averageBmi.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: bmiColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Latest Record',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              records.isNotEmpty
                                                  ? '${records.first.date.day}/${records.first.date.month}/${records.first.date.year}'
                                                  : 'N/A',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ExpansionTile(
                                    title: const Text('View Records'),
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: records.length,
                                        itemBuilder: (context, recordIndex) {
                                          final record = records[recordIndex];
                                          final recordBmiColor = _getBmiColor(record.bmiValue);
                                          
                                          return ListTile(
                                            title: Text(
                                              'BMI: ${record.bmiValue.toStringAsFixed(1)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: recordBmiColor,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${record.date.day}/${record.date.month}/${record.date.year} - ${record.category}',
                                            ),
                                            trailing: Text(
                                              '${record.weight} kg, ${record.height} cm',
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}