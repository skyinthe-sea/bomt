import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../domain/models/growth_record.dart';
import '../../../../domain/models/baby.dart';
import '../../../../services/growth/growth_service.dart';
import '../widgets/growth_chart_widget.dart';

class GrowthChartScreen extends StatefulWidget {
  final Baby baby;
  
  const GrowthChartScreen({
    super.key,
    required this.baby,
  });

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  List<GrowthRecord> _growthRecords = [];
  bool _isLoading = true;
  bool _showWeight = true; // true: 체중, false: 키

  @override
  void initState() {
    super.initState();
    _loadGrowthData();
  }

  Future<void> _loadGrowthData() async {
    try {
      final records = await GrowthService.instance
          .getAllGrowthRecords(widget.baby.id);
      
      if (mounted) {
        setState(() {
          _growthRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baby = widget.baby;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${baby?.name ?? '아기'}의 성장곡선',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _growthRecords.isEmpty
              ? _buildEmptyState()
              : _buildChartContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '성장 기록이 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '홈 화면에서 체중과 키를 입력해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent() {
    return Column(
      children: [
        // 차트 타입 선택
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  '체중',
                  Icons.monitor_weight_outlined,
                  _showWeight,
                  () => setState(() => _showWeight = true),
                  Colors.blue[100]!,
                  Colors.blue[600]!,
                ),
              ),
              Expanded(
                child: _buildToggleButton(
                  '키',
                  Icons.height,
                  !_showWeight,
                  () => setState(() => _showWeight = false),
                  Colors.green[100]!,
                  Colors.green[600]!,
                ),
              ),
            ],
          ),
        ),
        
        // 차트
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GrowthChartWidget(
                records: _growthRecords,
                showWeight: _showWeight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Color backgroundColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? iconColor : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? iconColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}