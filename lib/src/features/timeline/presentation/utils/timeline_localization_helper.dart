import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../domain/models/timeline_item.dart';

class TimelineLocalizationHelper {
  // Helper method to get localized color
  static String _getLocalizedColor(BuildContext context, String color) {
    final l10n = AppLocalizations.of(context)!;
    switch (color) {
      case '노란색':
        return l10n.diaperColorYellow;
      case '갈색':
        return l10n.diaperColorBrown;
      case '초록색':
        return l10n.diaperColorGreen;
      case '검은색':
        return l10n.diaperColorBlack;
      case '주황색':
        return l10n.diaperColorOrange;
      default:
        return color;
    }
  }
  
  // Helper method to get localized consistency
  static String _getLocalizedConsistency(BuildContext context, String consistency) {
    final l10n = AppLocalizations.of(context)!;
    switch (consistency) {
      case '보통':
        return l10n.diaperConsistencyNormal;
      case '묽은':
        return l10n.diaperConsistencyLoose;
      case '딱딱한':
        return l10n.diaperConsistencyHard;
      case '물같은':
        return l10n.diaperConsistencyWatery;
      default:
        return consistency;
    }
  }
  
  // Helper method to get localized food name
  static String _getLocalizedFood(BuildContext context, String food) {
    final l10n = AppLocalizations.of(context)!;
    switch (food) {
      case '미음':
        return l10n.foodRicePorridge;
      case '쌌죽':
        return l10n.foodBabyRiceCereal;
      case '바나나':
        return l10n.foodBanana;
      case '사과':
        return l10n.foodApple;
      case '당근':
        return l10n.foodCarrot;
      case '호박':
        return l10n.foodPumpkin;
      case '고구마':
        return l10n.foodSweetPotato;
      default:
        return food;
    }
  }
  
  // Helper method to get localized medication name
  static String _getLocalizedMedication(BuildContext context, String medication) {
    final l10n = AppLocalizations.of(context)!;
    switch (medication) {
      case '해열제':
        return l10n.medicationFeverReducer;
      case '감기약':
        return l10n.medicationColdMedicine;
      case '소화제':
        return l10n.medicationDigestiveAid;
      case '진통제':
        return l10n.medicationPainReliever;
      case '항생제':
        return l10n.medicationAntibiotics;
      case '비타민':
        return l10n.medicationVitamins;
      default:
        return medication;
    }
  }

  // Helper method to get localized title
  static String getLocalizedTitle(BuildContext context, TimelineItem item) {
    final l10n = AppLocalizations.of(context)!;
    switch (item.title) {
      case 'feeding':
        return l10n.feeding;
      case 'sleep':
        return l10n.sleep;
      case 'sleepInProgress':
        return l10n.sleepInProgress;
      case 'diaperChange':
        return l10n.diaperChange;
      case 'medication':
        return l10n.medication;
      case 'milkPumping':
        return l10n.milkPumping;
      case 'milkPumpingInProgress':
        return l10n.milkPumpingInProgress;
      case 'solidFood':
        return l10n.solidFood;
      case 'temperatureMeasurement':
        return l10n.temperatureMeasurement;
      default:
        return item.title;
    }
  }
  
  // Helper method to get localized subtitle
  static String getLocalizedSubtitle(BuildContext context, TimelineItem item) {
    final l10n = AppLocalizations.of(context)!;
    if (item.subtitle == null || item.subtitle!.isEmpty) return '';
    
    final parts = item.subtitle!.split('|');
    final baseType = parts[0];
    
    String result = '';
    
    // Handle different activity types
    switch (baseType) {
      // Feeding types
      case 'formula':
        result = l10n.formula;
        break;
      case 'breastMilk':
        result = l10n.breastMilk;
        break;
      case 'solidFood':
        result = l10n.solidFood;
        break;
        
      // Sleep types
      case 'sleepDuration':
        if (parts.length >= 3) {
          final hours = int.tryParse(parts[1]) ?? 0;
          final minutes = int.tryParse(parts[2]) ?? 0;
          result = l10n.hoursMinutesFormat(hours, minutes);
        }
        break;
      case 'sleepInProgressDuration':
        if (parts.length >= 2) {
          final minutes = parts[1];
          result = l10n.sleepInProgressDuration(minutes);
        }
        break;
      case 'sleepQuality':
        if (parts.length >= 3) {
          final hours = int.tryParse(parts[1]) ?? 0;
          final minutes = int.tryParse(parts[2]) ?? 0;
          final quality = parts.length > 3 ? parts[3] : '';
          result = l10n.hoursMinutesFormat(hours, minutes);
          if (quality.isNotEmpty) {
            String qualityText = '';
            switch (quality) {
              case 'good':
                qualityText = l10n.sleepQualityGood;
                break;
              case 'fair':
                qualityText = l10n.sleepQualityFair;
                break;
              case 'poor':
                qualityText = l10n.sleepQualityPoor;
                break;
            }
            if (qualityText.isNotEmpty) {
              result += ' (${l10n.sleepQuality}: $qualityText)';
            }
          }
        }
        break;
        
      // Diaper types
      case 'wetOnly':
        result = l10n.wetOnly;
        break;
      case 'dirtyOnly':
        result = l10n.dirtyOnly;
        break;
      case 'wetAndDirty':
        result = l10n.wetAndDirty;
        break;
        
      // Medication types
      case 'oralMedication':
        result = l10n.oralMedication;
        break;
      case 'topicalMedication':
        result = l10n.topicalMedication;
        break;
      case 'inhaledMedication':
        result = l10n.inhaledMedication;
        break;
      case 'medication':
        result = l10n.medication;
        break;
        
      // Milk pumping types
      case 'pumpingInProgressDuration':
        if (parts.length >= 2) {
          final minutes = parts[1];
          result = l10n.pumpingInProgressDuration(minutes);
        }
        break;
        
      // Temperature types
      case 'fever':
        result = '${parts.length > 1 ? parts[1] : ''}°C (${l10n.fever})';
        break;
      case 'lowGradeFever':
        result = '${parts.length > 1 ? parts[1] : ''}°C (${l10n.lowGradeFever})';
        break;
      case 'hypothermia':
        result = '${parts.length > 1 ? parts[1] : ''}°C (${l10n.hypothermia})';
        break;
      case 'normalTemperature':
        result = '${parts.length > 1 ? parts[1] : ''}°C (${l10n.normalTemperature})';
        break;
        
      default:
        result = baseType;
    }
    
    // Handle cases where result is still empty (for multi-part subtitles)
    if (result.isEmpty && parts.isNotEmpty) {
      // Check if it's a simple multi-part subtitle (e.g., "120ml|15min|left")
      List<String> processedParts = [];
      
      for (final part in parts) {
        if (part.endsWith('ml')) {
          processedParts.add(part);
        } else if (part.endsWith('min')) {
          processedParts.add(part.replaceAll('min', '분'));
        } else if (part.endsWith('g')) {
          processedParts.add(part);
        } else if (part == 'left') {
          processedParts.add('(${l10n.left})');
        } else if (part == 'right') {
          processedParts.add('(${l10n.right})');
        } else if (part == 'both') {
          processedParts.add('(${l10n.both})');
        } else if (part.startsWith('color:')) {
          final color = part.substring(6);
          final localizedColor = _getLocalizedColor(context, color);
          processedParts.add('(${l10n.colorLabel}: $localizedColor)');
        } else if (part.startsWith('consistency:')) {
          final consistency = part.substring(12);
          final localizedConsistency = _getLocalizedConsistency(context, consistency);
          processedParts.add('(${l10n.consistencyLabel}: $localizedConsistency)');
        } else if (part.isNotEmpty) {
          // If it's a food name or medication name, localize it
          final localizedFood = _getLocalizedFood(context, part);
          final localizedMedication = _getLocalizedMedication(context, part);
          // Use localized version if different from original, otherwise use original
          final localizedPart = localizedFood != part ? localizedFood : 
                               localizedMedication != part ? localizedMedication : part;
          processedParts.add(localizedPart);
        }
      }
      
      result = processedParts.join(' ');
    } else {
      // Add additional info (amount, duration, side) for other parts
      for (int i = 1; i < parts.length; i++) {
        final part = parts[i];
        if (part.endsWith('ml')) {
          result += ' $part';
        } else if (part.endsWith('min')) {
          result += ' ${part.replaceAll('min', '분')}';
        } else if (part.endsWith('g')) {
          result += ' $part';
        } else if (part == 'left') {
          result += ' (${l10n.left})';
        } else if (part == 'right') {
          result += ' (${l10n.right})';
        } else if (part == 'both') {
          result += ' (${l10n.both})';
        } else if (part.startsWith('color:')) {
          final color = part.substring(6);
          final localizedColor = _getLocalizedColor(context, color);
          result += ' (${l10n.colorLabel}: $localizedColor)';
        } else if (part.startsWith('consistency:')) {
          final consistency = part.substring(12);
          final localizedConsistency = _getLocalizedConsistency(context, consistency);
          result += ' (${l10n.consistencyLabel}: $localizedConsistency)';
        }
      }
    }
    
    return result;
  }
  
  // Helper method to get localized filter type name
  static String getLocalizedFilterName(BuildContext context, TimelineFilterType filterType) {
    final l10n = AppLocalizations.of(context)!;
    switch (filterType) {
      case TimelineFilterType.all:
        return l10n.allActivities;
      case TimelineFilterType.feeding:
        return l10n.feeding;
      case TimelineFilterType.sleep:
        return l10n.sleep;
      case TimelineFilterType.diaper:
        return l10n.diaperChange;
      case TimelineFilterType.medication:
        return l10n.medication;
      case TimelineFilterType.milkPumping:
        return l10n.milkPumping;
      case TimelineFilterType.solidFood:
        return l10n.solidFood;
      case TimelineFilterType.temperature:
        return l10n.temperatureFilter;
    }
  }
}