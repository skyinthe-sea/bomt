import 'package:flutter/material.dart';
import 'package:bomt/src/l10n/app_localizations.dart';
import '../../../../presentation/providers/localization_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final LocalizationProvider localizationProvider;
  
  const LanguageSelectionScreen({
    Key? key,
    required this.localizationProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSelection),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 현재 언어 표시
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentLanguage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizationProvider.getLanguageName(
                    localizationProvider.currentLocale.languageCode,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // 선택 안내
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.selectLanguage,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 언어 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: localizationProvider.supportedLocales.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final locale = localizationProvider.supportedLocales[index];
                final isSelected = localizationProvider.currentLocale.languageCode == locale.languageCode;
                final isDarkMode = theme.brightness == Brightness.dark;
                
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected 
                        ? (isDarkMode 
                            ? theme.primaryColor.withOpacity(0.2)
                            : theme.primaryColor.withOpacity(0.1))
                        : (isDarkMode 
                            ? theme.colorScheme.surface.withOpacity(0.5)
                            : Colors.white),
                    border: Border.all(
                      color: isSelected
                          ? (isDarkMode 
                              ? theme.primaryColor.withOpacity(0.6)
                              : theme.primaryColor.withOpacity(0.3))
                          : (isDarkMode 
                              ? theme.colorScheme.outline.withOpacity(0.3)
                              : theme.colorScheme.outline.withOpacity(0.2)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      localizationProvider.getLanguageName(locale.languageCode),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected 
                            ? (isDarkMode 
                                ? Colors.white
                                : theme.primaryColor)
                            : (isDarkMode 
                                ? Colors.white.withOpacity(0.9)
                                : theme.colorScheme.onSurface),
                        fontSize: 16,
                      ),
                    ),
                    value: locale.languageCode,
                    groupValue: localizationProvider.currentLocale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        localizationProvider.changeLanguage(Locale(value));
                        Navigator.of(context).pop();
                      }
                    },
                    activeColor: isDarkMode 
                        ? Colors.white
                        : theme.primaryColor,
                    fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return isDarkMode 
                            ? Colors.white
                            : theme.primaryColor;
                      }
                      return isDarkMode 
                          ? Colors.white.withOpacity(0.4)
                          : theme.colorScheme.onSurface.withOpacity(0.4);
                    }),
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return isDarkMode 
                            ? Colors.white.withOpacity(0.2)
                            : theme.primaryColor.withOpacity(0.2);
                      }
                      if (states.contains(MaterialState.hovered)) {
                        return isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : theme.primaryColor.withOpacity(0.1);
                      }
                      return null;
                    }),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.comfortable,
                    selected: isSelected,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}