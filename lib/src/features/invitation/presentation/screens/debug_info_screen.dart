import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/baby_provider.dart';

class DebugInfoScreen extends StatefulWidget {
  const DebugInfoScreen({Key? key}) : super(key: key);

  @override
  State<DebugInfoScreen> createState() => _DebugInfoScreenState();
}

class _DebugInfoScreenState extends State<DebugInfoScreen> {
  Map<String, dynamic> _debugInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      
      // BabyProvider 새로고침
      await babyProvider.loadBabyData();
      
      setState(() {
        _debugInfo = {
          'SharedPreferences': {
            'user_id': prefs.getString('user_id'),
            'kakao_user_id': prefs.getString('kakao_user_id'),
            'cached_baby_data': prefs.getString('cached_baby_data'),
            'all_keys': prefs.getKeys().toList(),
          },
          'BabyProvider': {
            'currentUserId': babyProvider.currentUserId,
            'currentBaby': babyProvider.currentBaby?.toJson(),
            'isLoading': babyProvider.isLoading,
            'hasBaby': babyProvider.hasBaby,
          },
        };
      });
    } catch (e) {
      setState(() {
        _debugInfo = {'error': e.toString()};
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('디버그 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Debug Information', _debugInfo),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatJson(data),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatJson(dynamic data) {
    try {
      return data.toString().replaceAllMapped(
        RegExp(r'(\{|\}|\[|\]|,)'),
        (match) => '${match.group(0)}\n',
      );
    } catch (e) {
      return data.toString();
    }
  }
}