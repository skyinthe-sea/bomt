import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../domain/models/content_report.dart';
import '../../core/events/app_event_bus.dart';
import '../../core/events/data_sync_events.dart';

/// 콘텐츠 신고 관리 서비스
/// App Store Guideline 1.2 준수를 위한 신고 시스템
class ContentReportService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final AppEventBus _eventBus = AppEventBus.instance;

  /// 콘텐츠 신고하기
  Future<ContentReport> reportContent({
    required String reporterUserId,
    required String reportedUserId,
    required ContentType contentType,
    required String contentId,
    required ReportReason reportReason,
    String? reportDescription,
  }) async {
    try {
      // 자기 자신의 콘텐츠를 신고하려는 경우 방지
      if (reporterUserId == reportedUserId) {
        throw Exception('자신의 콘텐츠는 신고할 수 없습니다');
      }

      print('DEBUG: 콘텐츠 신고 - reporter: $reporterUserId, reported: $reportedUserId, type: ${contentType.value}, id: $contentId');
      
      final reportData = {
        'reporter_user_id': reporterUserId,
        'reported_user_id': reportedUserId,
        'content_type': contentType.value,
        'content_id': contentId,
        'report_reason': reportReason.value,
        'report_description': reportDescription,
        'status': ReportStatus.pending.value,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('content_reports')
          .insert(reportData)
          .select('''
            *,
            reporter:user_profiles!content_reports_reporter_user_id_fkey(*),
            reported_user:user_profiles!content_reports_reported_user_id_fkey(*)
          ''')
          .single();

      final contentReport = ContentReport.fromJson(response);

      // 신고 이벤트 발생
      _eventBus.emitDataSync(ContentReportedEvent(
        reporterUserId: reporterUserId,
        reportedUserId: reportedUserId,
        contentReport: contentReport,
      ));

      // 자동 처리 로직 (특정 조건 만족 시)
      await _checkAutoProcessing(contentReport);

      print('DEBUG: 콘텐츠 신고 완료');
      return contentReport;
    } catch (e) {
      if (e.toString().contains('duplicate key value')) {
        print('WARNING: 이미 신고한 콘텐츠입니다');
        throw Exception('이미 신고한 콘텐츠입니다');
      }
      
      print('ERROR: 콘텐츠 신고 실패: $e');
      throw Exception('콘텐츠 신고 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자가 신고한 내역 조회
  Future<List<ContentReport>> getUserReports(String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      print('DEBUG: 사용자 신고 내역 조회 - userId: $userId');
      
      final response = await _supabase
          .from('content_reports')
          .select('''
            *,
            reporter:user_profiles!content_reports_reporter_user_id_fkey(*),
            reported_user:user_profiles!content_reports_reported_user_id_fkey(*)
          ''')
          .eq('reporter_user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final reports = (response as List)
          .map((item) => ContentReport.fromJson(item))
          .toList();

      print('DEBUG: 신고 내역 ${reports.length}개 조회 완료');
      return reports;
    } catch (e) {
      print('ERROR: 사용자 신고 내역 조회 실패: $e');
      throw Exception('신고 내역을 가져오는데 실패했습니다: $e');
    }
  }

  /// 특정 콘텐츠에 대한 신고 내역 조회 (관리자용)
  Future<List<ContentReport>> getContentReports({
    required ContentType contentType,
    required String contentId,
  }) async {
    try {
      print('DEBUG: 콘텐츠 신고 내역 조회 - type: ${contentType.value}, id: $contentId');
      
      final response = await _supabase
          .from('content_reports')
          .select('''
            *,
            reporter:user_profiles!content_reports_reporter_user_id_fkey(*),
            reported_user:user_profiles!content_reports_reported_user_id_fkey(*)
          ''')
          .eq('content_type', contentType.value)
          .eq('content_id', contentId)
          .order('created_at', ascending: false);

      final reports = (response as List)
          .map((item) => ContentReport.fromJson(item))
          .toList();

      print('DEBUG: 콘텐츠 신고 내역 ${reports.length}개 조회 완료');
      return reports;
    } catch (e) {
      print('ERROR: 콘텐츠 신고 내역 조회 실패: $e');
      throw Exception('신고 내역을 가져오는데 실패했습니다: $e');
    }
  }

  /// 미처리 신고 내역 조회 (관리자용)
  Future<List<ContentReport>> getPendingReports({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      print('DEBUG: 미처리 신고 내역 조회');
      
      final response = await _supabase
          .from('content_reports')
          .select('''
            *,
            reporter:user_profiles!content_reports_reporter_user_id_fkey(*),
            reported_user:user_profiles!content_reports_reported_user_id_fkey(*)
          ''')
          .eq('status', ReportStatus.pending.value)
          .order('created_at', ascending: true) // 오래된 순서대로
          .range(offset, offset + limit - 1);

      final reports = (response as List)
          .map((item) => ContentReport.fromJson(item))
          .toList();

      print('DEBUG: 미처리 신고 ${reports.length}개 조회 완료');
      return reports;
    } catch (e) {
      print('ERROR: 미처리 신고 조회 실패: $e');
      throw Exception('미처리 신고를 가져오는데 실패했습니다: $e');
    }
  }

  /// 신고 상태 업데이트 (관리자용)
  Future<ContentReport> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNotes,
    String? resolvedBy,
  }) async {
    try {
      print('DEBUG: 신고 상태 업데이트 - reportId: $reportId, status: ${status.value}');
      
      final updateData = {
        'status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (adminNotes != null) {
        updateData['admin_notes'] = adminNotes;
      }

      if (status == ReportStatus.resolved || status == ReportStatus.dismissed) {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
        if (resolvedBy != null) {
          updateData['resolved_by'] = resolvedBy;
        }
      }

      final response = await _supabase
          .from('content_reports')
          .update(updateData)
          .eq('id', reportId)
          .select('''
            *,
            reporter:user_profiles!content_reports_reporter_user_id_fkey(*),
            reported_user:user_profiles!content_reports_reported_user_id_fkey(*)
          ''')
          .single();

      final updatedReport = ContentReport.fromJson(response);

      // 신고 처리 완료 이벤트 발생
      if (updatedReport.isResolved) {
        _eventBus.emitDataSync(ContentReportResolvedEvent(
          reportId: reportId,
          status: status,
          contentReport: updatedReport,
        ));
      }

      print('DEBUG: 신고 상태 업데이트 완료');
      return updatedReport;
    } catch (e) {
      print('ERROR: 신고 상태 업데이트 실패: $e');
      throw Exception('신고 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 특정 사용자가 특정 콘텐츠를 신고했는지 확인
  Future<bool> hasUserReportedContent({
    required String userId,
    required ContentType contentType,
    required String contentId,
  }) async {
    try {
      final response = await _supabase
          .from('content_reports')
          .select('id')
          .eq('reporter_user_id', userId)
          .eq('content_type', contentType.value)
          .eq('content_id', contentId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('ERROR: 신고 여부 확인 실패: $e');
      return false;
    }
  }

  /// 특정 사용자가 받은 신고 횟수 조회
  Future<int> getUserReportCount(String userId) async {
    try {
      final response = await _supabase
          .from('content_reports')
          .select('id')
          .eq('reported_user_id', userId)
          .count();

      return response.count;
    } catch (e) {
      print('ERROR: 사용자 신고 횟수 조회 실패: $e');
      return 0;
    }
  }

  /// 신고 통계 조회 (관리자용)
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      // 전체 신고 수
      final totalResponse = await _supabase
          .from('content_reports')
          .select('id')
          .count();

      // 상태별 신고 수
      final pendingResponse = await _supabase
          .from('content_reports')
          .select('id')
          .eq('status', ReportStatus.pending.value)
          .count();

      final reviewingResponse = await _supabase
          .from('content_reports')
          .select('id')
          .eq('status', ReportStatus.reviewing.value)
          .count();

      final resolvedResponse = await _supabase
          .from('content_reports')
          .select('id')
          .eq('status', ReportStatus.resolved.value)
          .count();

      // 최근 24시간 내 신고 수
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final recentResponse = await _supabase
          .from('content_reports')
          .select('id')
          .gte('created_at', yesterday.toIso8601String())
          .count();

      return {
        'total_reports': totalResponse.count,
        'pending_reports': pendingResponse.count,
        'reviewing_reports': reviewingResponse.count,
        'resolved_reports': resolvedResponse.count,
        'recent_reports': recentResponse.count,
      };
    } catch (e) {
      print('ERROR: 신고 통계 조회 실패: $e');
      return {
        'total_reports': 0,
        'pending_reports': 0,
        'reviewing_reports': 0,
        'resolved_reports': 0,
        'recent_reports': 0,
      };
    }
  }

  /// 자동 처리 로직 확인 (내부 메서드)
  Future<void> _checkAutoProcessing(ContentReport report) async {
    try {
      // 같은 콘텐츠에 대한 신고 수 확인
      final reportCount = await _getContentReportCount(
        report.contentType,
        report.contentId,
      );

      // 신고가 5건 이상이면 자동으로 검토 상태로 변경
      if (reportCount >= 5) {
        await updateReportStatus(
          reportId: report.id,
          status: ReportStatus.reviewing,
          adminNotes: '자동 검토: 신고 임계치 도달 (${reportCount}건)',
        );
      }

      // 특정 키워드가 포함된 심각한 신고는 즉시 검토 상태로 변경
      final seriousReasons = [
        ReportReason.hateSpeech,
        ReportReason.violence,
        ReportReason.sexualContent,
      ];

      if (seriousReasons.contains(report.reportReason)) {
        await updateReportStatus(
          reportId: report.id,
          status: ReportStatus.reviewing,
          adminNotes: '자동 검토: 심각한 신고 내용',
        );
      }
    } catch (e) {
      print('ERROR: 자동 처리 로직 실패: $e');
      // 자동 처리 실패는 치명적이지 않으므로 에러를 던지지 않음
    }
  }

  /// 특정 콘텐츠의 신고 수 조회 (내부 메서드)
  Future<int> _getContentReportCount(ContentType contentType, String contentId) async {
    try {
      final response = await _supabase
          .from('content_reports')
          .select('id')
          .eq('content_type', contentType.value)
          .eq('content_id', contentId)
          .count();

      return response.count;
    } catch (e) {
      print('ERROR: 콘텐츠 신고 수 조회 실패: $e');
      return 0;
    }
  }
}

/// 신고 관련 이벤트들
class ContentReportedEvent extends DataSyncEvent {
  final String reporterUserId;
  final String reportedUserId;
  final ContentReport contentReport;

  ContentReportedEvent({
    required this.reporterUserId,
    required this.reportedUserId,
    required this.contentReport,
  }) : super(
      type: DataSyncEventType.contentReported,
      babyId: reporterUserId,
      affectedDate: DateTime.now(),
      action: DataSyncAction.created,
      metadata: {
        'reportedUserId': reportedUserId,
        'contentReportId': contentReport.id,
        'contentType': contentReport.contentType.toString(),
      },
    );
}

class ContentReportResolvedEvent extends DataSyncEvent {
  final String reportId;
  final ReportStatus status;
  final ContentReport contentReport;

  ContentReportResolvedEvent({
    required this.reportId,
    required this.status,
    required this.contentReport,
  }) : super(
      type: DataSyncEventType.contentReportResolved,
      babyId: contentReport.reporterUserId,
      affectedDate: DateTime.now(),
      action: DataSyncAction.updated,
      recordId: reportId,
      metadata: {
        'reportStatus': status.toString(),
        'reportedUserId': contentReport.reportedUserId,
      },
    );
}