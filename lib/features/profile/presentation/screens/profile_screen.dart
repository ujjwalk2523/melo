import 'package:flutter/material.dart';

import 'package:melo/core/constants/app_constants.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';

/// Primary Profile and Settings screen displaying user preferences, account status, and app info.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _offlineOnly = false;
  bool _highQualityAudio = true;
  bool _normalizeVolume = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space16,
          ),
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppDimensions.borderRadiusMd,
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ujjwal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'user@melo.stream',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppDimensions.borderRadiusFull,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'MELO FREE PLAN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Playback & Audio Preferences
            _buildSectionHeader('Playback & Audio'),
            _buildSettingSwitch(
              icon: Icons.hd_rounded,
              title: 'High Fidelity Audio',
              subtitle: 'Stream in 320kbps when available',
              value: _highQualityAudio,
              onChanged: (val) => setState(() => _highQualityAudio = val),
            ),
            _buildSettingSwitch(
              icon: Icons.graphic_eq_rounded,
              title: 'Normalize Volume',
              subtitle: 'Set the same volume level for all tracks',
              value: _normalizeVolume,
              onChanged: (val) => setState(() => _normalizeVolume = val),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Offline & Storage
            _buildSectionHeader('Storage & Offline'),
            _buildSettingSwitch(
              icon: Icons.cloud_off_rounded,
              title: 'Offline Mode Only',
              subtitle: 'Only play downloaded music to save data',
              value: _offlineOnly,
              onChanged: (val) => setState(() => _offlineOnly = val),
            ),
            _buildSettingTile(
              icon: Icons.storage_rounded,
              title: 'Storage & Cache',
              subtitle: '124 MB used • 0 downloaded songs',
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space20),

            // About & Version
            _buildSectionHeader('About Melo'),
            _buildSettingTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              subtitle: '${AppConstants.appName} v${AppConstants.appVersion}',
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Terms & Privacy',
              subtitle: 'Read our open-provider terms & policies',
              onTap: () {},
            ),
            const SizedBox(height: AppDimensions.space40),
          ],
        ),
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
          fontSize: 14,
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppDimensions.borderRadiusMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space4,
        ),
        secondary: Icon(icon, color: AppColors.textSecondary, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        activeTrackColor: AppColors.primary,
        activeThumbColor: AppColors.onPrimary,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppDimensions.borderRadiusMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space4,
        ),
        leading: Icon(icon, color: AppColors.textSecondary, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
