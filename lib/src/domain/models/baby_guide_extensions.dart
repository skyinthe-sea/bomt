import 'package:bomt/src/l10n/app_localizations.dart';
import 'baby_guide.dart';

extension BabyGuideLocalizations on BabyGuide {
  /// 주차 표시 텍스트 (다국어)
  String getWeekText(AppLocalizations l10n) {
    if (weekNumber == 0) {
      return l10n.newbornWeek0;
    } else {
      return l10n.weekNumber(weekNumber);
    }
  }

  /// 수유 횟수 범위 텍스트 반환 (다국어)
  String? getFrequencyRange(AppLocalizations l10n) {
    if (frequencyMin != null && frequencyMax != null) {
      return l10n.dailyFrequencyRange(frequencyMin!, frequencyMax!);
    } else if (frequencyMin != null) {
      return l10n.dailyFrequencyMin(frequencyMin!);
    } else if (frequencyMax != null) {
      return l10n.dailyFrequencyMax(frequencyMax!);
    }
    return null;
  }

  /// 수유량 범위 텍스트 반환 (다국어)
  String? getFeedingAmountRange(AppLocalizations l10n) {
    if (feedingAmountMin != null && feedingAmountMax != null) {
      return l10n.amountRangeML(feedingAmountMin!, feedingAmountMax!);
    } else if (feedingAmountMin != null) {
      return l10n.amountMinML(feedingAmountMin!);
    } else if (feedingAmountMax != null) {
      return l10n.amountMaxML(feedingAmountMax!);
    }
    return null;
  }

  /// 1회 수유량 범위 텍스트 반환 (다국어)
  String? getSingleFeedingRange(AppLocalizations l10n) {
    if (singleFeedingMin != null && singleFeedingMax != null) {
      return l10n.amountRangeML(singleFeedingMin!, singleFeedingMax!);
    } else if (singleFeedingMin != null) {
      return l10n.amountMinML(singleFeedingMin!);
    } else if (singleFeedingMax != null) {
      return l10n.amountMaxML(singleFeedingMax!);
    }
    return null;
  }
}