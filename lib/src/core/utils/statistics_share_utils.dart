import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/statistics.dart';
import '../../domain/models/baby.dart';

class StatisticsShareUtils {
  static GlobalKey? _repaintBoundaryKey;
  
  /// RepaintBoundary 키 설정
  static void setRepaintBoundaryKey(GlobalKey key) {
    _repaintBoundaryKey = key;
  }

  /// 통계 데이터를 텍스트로 변환하고 클립보드에 복사
  static Future<void> shareAsText({
    required BuildContext context,
    required Statistics statistics,
    required Baby baby,
  }) async {
    try {
      final text = _generateStatisticsText(statistics, baby);
      
      // 클립보드에 복사
      await Clipboard.setData(ClipboardData(text: text));
      
      // 성공 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('통계가 클립보드에 복사되었습니다'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing as text: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('텍스트 복사 중 오류가 발생했습니다'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// 통계 화면을 이미지로 캡처하고 저장/공유
  static Future<void> shareAsImage({
    required BuildContext context,
    required Baby baby,
    required Statistics statistics,
  }) async {
    if (_repaintBoundaryKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지 캡처 준비가 되지 않았습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 로딩 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('이미지를 생성하는 중...'),
                ],
              ),
            ),
          ),
        ),
      );

      // RepaintBoundary를 사용하여 이미지 캡처
      final RenderRepaintBoundary boundary = _repaintBoundaryKey!.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageBytes = byteData!.buffer.asUint8List();

      if (context.mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      }

      // 임시 디렉토리에 이미지 저장
      final directory = await getTemporaryDirectory();
      final fileName = 'statistics_${baby.name}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Android에서는 갤러리에 저장, iOS에서는 Photos에 저장 옵션 제공
      if (context.mounted) {
        await _showImageShareOptions(context, file, baby, statistics);
      }

    } catch (e) {
      debugPrint('Error sharing as image: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그가 열려있다면 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('이미지 저장 중 오류가 발생했습니다: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// 이미지 공유 옵션 다이얼로그 표시
  static Future<void> _showImageShareOptions(
    BuildContext context,
    File imageFile,
    Baby baby,
    Statistics statistics,
  ) async {
    final theme = Theme.of(context);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 공유'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${baby.name}의 통계 이미지가 생성되었습니다.'),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                imageFile,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _shareImageFile(context, imageFile, baby);
            },
            icon: const Icon(Icons.share),
            label: const Text('공유하기'),
          ),
        ],
      ),
    );
  }

  /// 이미지 파일 공유
  static Future<void> _shareImageFile(
    BuildContext context,
    File imageFile,
    Baby baby,
  ) async {
    try {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: '${baby.name}의 육아 통계입니다 📊',
        subject: '${baby.name} 육아 통계',
      );
    } catch (e) {
      debugPrint('Error sharing image file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 공유 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 통계 데이터를 텍스트로 변환
  static String _generateStatisticsText(Statistics statistics, Baby baby) {
    final buffer = StringBuffer();
    
    // 헤더
    buffer.writeln('📊 ${baby.name}의 육아 통계');
    buffer.writeln('📅 기간: ${statistics.dateRange.label}');
    buffer.writeln('📈 총 활동: ${statistics.totalActivities}회');
    buffer.writeln('');

    // 카드별 통계
    for (final cardStats in statistics.cardsWithData) {
      buffer.writeln('🔹 ${cardStats.cardName}');
      buffer.writeln('   총 횟수: ${cardStats.totalCount}회');
      
      for (final metric in cardStats.metrics) {
        String value = metric.formattedValue;
        if (metric.unit.isNotEmpty) {
          value += metric.unit;
        }
        buffer.writeln('   ${metric.label}: $value');
      }
      buffer.writeln('');
    }

    // 푸터
    buffer.writeln('───────────────────');
    buffer.writeln('📱 BabyMom 앱으로 생성');
    buffer.writeln('📅 생성일: ${_formatDateTime(DateTime.now())}');

    return buffer.toString();
  }

  /// 날짜 시간 포맷팅
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// RepaintBoundary로 위젯 래핑
  static Widget wrapWithRepaintBoundary(Widget child, GlobalKey key) {
    return RepaintBoundary(
      key: key,
      child: child,
    );
  }
}