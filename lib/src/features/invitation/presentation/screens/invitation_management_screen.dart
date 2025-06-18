import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/models/invitation.dart';
import '../../../../services/invitation/invitation_service.dart';
import '../../../../core/providers/baby_provider.dart';
import 'create_invitation_screen.dart';

class InvitationManagementScreen extends StatefulWidget {
  const InvitationManagementScreen({Key? key}) : super(key: key);

  @override
  State<InvitationManagementScreen> createState() => _InvitationManagementScreenState();
}

class _InvitationManagementScreenState extends State<InvitationManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InvitationService _invitationService = InvitationService.instance;
  
  List<Invitation> _sentInvitations = [];
  List<Invitation> _receivedInvitations = [];
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize invitation service
      await _invitationService.initialize();
      
      // Get current user ID from BabyProvider
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      _currentUserId = babyProvider.currentUserId;
      
      if (_currentUserId == null) {
        _showErrorSnackBar('로그인이 필요합니다');
        return;
      }
      
      await _loadInvitations();
    } catch (e) {
      _showErrorSnackBar('데이터 로딩 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInvitations() async {
    if (_currentUserId == null) return;
    
    try {
      final sent = await _invitationService.getUserSentInvitations(_currentUserId!);
      final received = await _invitationService.getUserAcceptedInvitations(_currentUserId!);
      
      setState(() {
        _sentInvitations = sent;
        _receivedInvitations = received;
      });
    } catch (e) {
      _showErrorSnackBar('초대 목록을 불러오는데 실패했습니다: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _cancelInvitation(Invitation invitation) async {
    if (_currentUserId == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('초대 취소'),
        content: const Text('이 초대를 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final result = await _invitationService.cancelInvitation(
          invitation.id, 
          _currentUserId!,
          reason: '사용자 요청',
        );
        
        if (result.isSuccess) {
          _showSuccessSnackBar('초대가 취소되었습니다');
          await _loadInvitations(); // 목록 새로고침
        } else {
          _showErrorSnackBar(result.message);
        }
      } catch (e) {
        _showErrorSnackBar('초대 취소 중 오류가 발생했습니다: $e');
      }
    }
  }

  Future<void> _shareInvitation(Invitation invitation) async {
    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      final babyName = babyProvider.currentBaby?.name ?? '우리 아기';
      
      final success = await _invitationService.shareInvitation(invitation, babyName);
      
      if (success) {
        _showSuccessSnackBar('초대 링크가 공유되었습니다');
      } else {
        _showErrorSnackBar('공유에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('공유 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('초대 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.send),
              text: '보낸 초대',
            ),
            Tab(
              icon: Icon(Icons.inbox),
              text: '받은 초대',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadInvitations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSentInvitationsTab(),
                _buildReceivedInvitationsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateInvitationScreen(),
            ),
          ).then((_) => _loadInvitations()); // 새 초대 생성 후 목록 새로고침
        },
        child: const Icon(Icons.add),
        tooltip: '새 초대 만들기',
      ),
    );
  }

  Widget _buildSentInvitationsTab() {
    if (_sentInvitations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '보낸 초대가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '가족 구성원을 초대해보세요',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sentInvitations.length,
        itemBuilder: (context, index) {
          final invitation = _sentInvitations[index];
          return _buildSentInvitationCard(invitation);
        },
      ),
    );
  }

  Widget _buildReceivedInvitationsTab() {
    if (_receivedInvitations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '받은 초대가 없습니다',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _receivedInvitations.length,
        itemBuilder: (context, index) {
          final invitation = _receivedInvitations[index];
          return _buildReceivedInvitationCard(invitation);
        },
      ),
    );
  }

  Widget _buildSentInvitationCard(Invitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(invitation.status),
                  child: Icon(
                    _getStatusIcon(invitation.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${invitation.role.displayName} 초대',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        invitation.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(invitation.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (invitation.status == InvitationStatus.pending) ...[
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareInvitation(invitation),
                    tooltip: '공유',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _cancelInvitation(invitation),
                    tooltip: '취소',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildInvitationDetails(invitation),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedInvitationCard(Invitation invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${invitation.role.displayName}로 참여',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        '수락됨',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInvitationDetails(invitation),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationDetails(Invitation invitation) {
    return Column(
      children: [
        _buildDetailRow('생성일', _formatDate(invitation.createdAt)),
        if (invitation.status == InvitationStatus.pending)
          _buildDetailRow('만료', invitation.remainingTimeString),
        if (invitation.acceptedAt != null)
          _buildDetailRow('수락일', _formatDate(invitation.acceptedAt!)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return Colors.orange;
      case InvitationStatus.accepted:
        return Colors.green;
      case InvitationStatus.expired:
        return Colors.grey;
      case InvitationStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.pending:
        return Icons.schedule;
      case InvitationStatus.accepted:
        return Icons.check;
      case InvitationStatus.expired:
        return Icons.schedule;
      case InvitationStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}