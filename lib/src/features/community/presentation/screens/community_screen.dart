import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.comingSoon ?? 'Coming Soon',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.communityUpdateMessage ?? 'Community feature will be updated soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}