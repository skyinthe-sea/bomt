import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../presentation/providers/localization_provider.dart';

class SettingsScreen extends StatelessWidget {
  final LocalizationProvider localizationProvider;
  
  const SettingsScreen({
    Key? key,
    required this.localizationProvider,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings ?? 'Settings'),
      ),
      body: ListView(
        children: [
          _buildLanguageSection(context, l10n),
        ],
      ),
    );
  }
  
  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language ?? 'Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...localizationProvider.supportedLocales.map((locale) {
              final isSelected = localizationProvider.currentLocale.languageCode == locale.languageCode;
              return RadioListTile<String>(
                title: Text(
                  localizationProvider.getLanguageName(locale.languageCode),
                ),
                value: locale.languageCode,
                groupValue: localizationProvider.currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    localizationProvider.changeLanguage(Locale(value));
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}