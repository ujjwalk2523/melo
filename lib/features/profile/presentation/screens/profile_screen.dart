import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:melo/core/constants/app_constants.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/downloads/download_providers.dart';
import 'package:melo/core/recommendations/providers/recommendation_providers.dart';
import 'package:melo/core/router/app_routes.dart';
import 'package:melo/core/sync/sync_providers.dart';
import 'package:melo/core/sync/sync_state.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/auth/providers/auth_provider.dart';

/// Primary Profile and Settings screen displaying persistent user preferences, listening stats, and audio settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesNotifierProvider);
    final notifier = ref.read(userPreferencesNotifierProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authStateProvider);
    final syncState = ref.watch(syncStateProvider);
    final isAuthenticated = user != null;
    final storageBytes = ref.watch(downloadStorageSizeProvider).valueOrNull ?? 0;
    final mbUsed = (storageBytes / (1024 * 1024)).toStringAsFixed(1);

    final displayName = user?.displayName ?? 'Ujjwal';
    final email = user?.email ?? 'ujjwal@melo.stream';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space16,
          ),
          children: [
            // User Header Profile Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                borderRadius: AppDimensions.borderRadiusLg,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E1065), AppColors.surfaceElevated],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                isAuthenticated
                                    ? 'MELO HI-FI CLOUD'
                                    : 'MELO HI-FI UNLIMITED',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: AppDimensions.space8),
                  // Sync Status Row & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            syncState.status == SyncStatus.syncing
                                ? Icons.sync_rounded
                                : syncState.status == SyncStatus.offline
                                    ? Icons.cloud_off_rounded
                                    : syncState.status == SyncStatus.error
                                        ? Icons.sync_problem_rounded
                                        : Icons.cloud_done_rounded,
                            size: 16,
                            color: syncState.status == SyncStatus.error
                                ? Colors.redAccent
                                : syncState.status == SyncStatus.offline
                                    ? Colors.orangeAccent
                                    : AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            syncState.humanReadableStatus,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (isAuthenticated)
                        TextButton.icon(
                          onPressed: syncState.status == SyncStatus.syncing
                              ? null
                              : () => ref
                                  .read(syncStateProvider.notifier)
                                  .syncNow(authState.accessToken, user.id),
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Sync Now', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.login),
                          icon: const Icon(Icons.login_rounded, size: 16),
                          label: const Text('Sign In', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                    ],
                  ),
                  if (isAuthenticated) ...[
                    const SizedBox(height: AppDimensions.space8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => ref.read(authStateProvider.notifier).logout(),
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: const Text('Log Out', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.surfaceBorder),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _confirmAccountDeletion(context, ref),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                          label: const Text('Delete Account',
                              style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Listening Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Listening Time',
                    value: '148h',
                    icon: Icons.headphones_rounded,
                    accentColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    title: 'Top Genre',
                    value: 'Synthwave',
                    icon: Icons.flash_on_rounded,
                    accentColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    title: 'Artists',
                    value: '86',
                    icon: Icons.people_alt_rounded,
                    accentColor: AppColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space24),

            // Playback & Audio Preferences
            _buildSectionHeader('Playback & Audio Quality'),
            _buildSettingTile(
              icon: Icons.high_quality_rounded,
              title: 'Streaming Quality',
              subtitle: prefs.audioQuality,
              onTap: () =>
                  _showAudioQualityDialog(context, ref, prefs.audioQuality),
            ),
            _buildSettingSwitch(
              icon: Icons.all_inclusive_rounded,
              title: 'Gapless Playback',
              subtitle: 'Seamless transitions between continuous tracks',
              value: prefs.gaplessPlayback,
              onChanged: (val) => notifier.setGaplessPlayback(val),
            ),
            _buildSettingSwitch(
              icon: Icons.graphic_eq_rounded,
              title: 'Normalize Volume',
              subtitle:
                  'Balance equal loudness across different music providers',
              value: prefs.normalizeVolume,
              onChanged: (val) => notifier.setNormalizeVolume(val),
            ),
            // Crossfade Slider
            Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.space8),
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppDimensions.borderRadiusLg,
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Crossfade Duration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${prefs.crossfadeDuration.toInt()}s',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: prefs.crossfadeDuration,
                    min: 0.0,
                    max: 12.0,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.progressTrack,
                    onChanged: (val) => notifier.setCrossfadeDuration(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Storage & Offline Mode
            _buildSectionHeader('Storage & Offline Mode'),
            _buildSettingSwitch(
              icon: Icons.cloud_off_rounded,
              title: 'Offline Mode Only',
              subtitle: 'Only stream tracks cached or downloaded locally',
              value: prefs.offlineOnly,
              onChanged: (val) => notifier.setOfflineOnly(val),
            ),
            _buildSettingSwitch(
              icon: Icons.wifi_rounded,
              title: 'Download via Wi-Fi Only',
              subtitle: 'Prevent consuming cellular data for downloads',
              value: prefs.downloadOnWifiOnly,
              onChanged: (val) => notifier.setDownloadOnWifiOnly(val),
            ),
            _buildSettingTile(
              icon: Icons.cleaning_services_rounded,
              title: 'Clear Audio Cache',
              subtitle: 'Currently using 142 MB of temporary audio storage',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Audio cache cleared successfully (0 MB)'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.surfaceHighlight,
                  ),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.download_done_rounded,
              title: 'Clear All Downloads',
              subtitle: 'Currently using $mbUsed MB of offline music storage',
              onTap: () => _confirmClearDownloads(context, ref),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Music Intelligence & Personalization
            _buildSectionHeader('Music Intelligence & Recommendations'),
            _buildSettingSwitch(
              icon: Icons.auto_awesome_rounded,
              title: 'Personalized Recommendations',
              subtitle: 'Tailor Home and Discovery sections to your taste',
              value: prefs.personalizedRecommendations,
              onChanged: (val) => notifier.setPersonalizedRecommendations(val),
            ),
            _buildSettingSwitch(
              icon: Icons.history_rounded,
              title: 'Use Listening History',
              subtitle: 'Factor recently played tracks into music scoring',
              value: prefs.useListeningHistoryForRecs,
              onChanged: (val) => notifier.setUseListeningHistoryForRecs(val),
            ),
            _buildSettingTile(
              icon: Icons.explore_rounded,
              title: 'Discovery Level',
              subtitle: 'Current mode: ${prefs.discoveryLevel.toUpperCase()}',
              onTap: () => _showDiscoveryLevelDialog(context, ref, prefs.discoveryLevel),
            ),
            _buildSettingTile(
              icon: Icons.restart_alt_rounded,
              title: 'Reset Recommendation Profile',
              subtitle: 'Clear all taste signals, feedback, and cached recommendations',
              onTap: () => _confirmResetRecommendations(context, ref),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Theme & Appearance
            _buildSectionHeader('Appearance & Aesthetics'),
            _buildSettingTile(
              icon: Icons.palette_rounded,
              title: 'Active Aura',
              subtitle: 'Melo Dark Aura (Obsidian / Electric Violet)',
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space20),

            // About & Legal
            _buildSectionHeader('About Melo'),
            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              subtitle:
                  '${AppConstants.appName} v${AppConstants.appVersion} (Build 2026.09)',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.shield_outlined,
              title: 'Licensing & Attributions',
              subtitle: 'Compliant with Audius & Jamendo open API specs',
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.space4,
        bottom: AppDimensions.space8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: Material(
        color: AppColors.surfaceElevated,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space4,
          ),
          secondary: Icon(icon, color: AppColors.textSecondary, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          activeTrackColor: AppColors.primary,
          activeThumbColor: Colors.white,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space8),
      child: Material(
        color: AppColors.surfaceElevated,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space4,
          ),
          leading: Icon(icon, color: AppColors.textSecondary, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showAudioQualityDialog(
    BuildContext context,
    WidgetRef ref,
    String currentQuality,
  ) {
    final options = [
      'Normal (160 kbps MP3)',
      'High (320 kbps AAC)',
      'Hi-Res Lossless (FLAC 24-bit)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Select Streaming Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(color: AppColors.surfaceBorder),
              ...options.map((opt) {
                final isSelected = opt == currentQuality;
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.secondary,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(userPreferencesNotifierProvider.notifier)
                        .setAudioQuality(opt);
                    Navigator.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmAccountDeletion(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text(
          'Delete Cloud Account?',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This action permanently deletes your cloud account and all synchronized cloud records. Your local library and music on this device will be preserved.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(authStateProvider.notifier).deleteAccount();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Account deleted successfully'
                        : 'Failed to delete account. Please try again.'),
                    backgroundColor: AppColors.surfaceHighlight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearDownloads(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text(
          'Clear All Downloads?',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will delete all offline downloaded tracks from your device. You can re-download authorized tracks at any time.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(downloadManagerProvider).clearAllDownloads();
              ref.invalidate(downloadStorageSizeProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All downloaded tracks have been cleared'),
                    backgroundColor: AppColors.surfaceHighlight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDiscoveryLevelDialog(BuildContext context, WidgetRef ref, String currentLevel) {
    const levels = [
      ('familiar', 'Familiar (85% familiar, 15% discovery)'),
      ('balanced', 'Balanced (70% familiar, 30% discovery)'),
      ('explore', 'Explore (50% familiar, 50% discovery)'),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text(
          'Select Discovery Level',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: levels.map((lvl) {
            final isSelected = currentLevel.toLowerCase() == lvl.$1;
            return ListTile(
              title: Text(
                lvl.$2,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                ref.read(userPreferencesNotifierProvider.notifier).setDiscoveryLevel(lvl.$1);
                ref.read(recommendationStateProvider.notifier).refresh();
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmResetRecommendations(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text(
          'Reset Recommendation Profile?',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will reset your local music intelligence preferences, unhide previously hidden songs, and wipe cached recommendations. Your favorites, playlists, and listening history will remain completely untouched.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(userPreferencesNotifierProvider.notifier).resetPersonalizationPreferences();
              await ref.read(recommendationStateProvider.notifier).resetPersonalization();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recommendation profile has been reset'),
                    backgroundColor: AppColors.surfaceHighlight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
