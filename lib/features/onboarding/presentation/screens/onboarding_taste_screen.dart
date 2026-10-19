import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/recommendations/providers/recommendation_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/aura_artwork.dart';

/// Spotify-style visual onboarding quiz allowing users to select preferred languages and top artists.
class OnboardingTasteScreen extends ConsumerStatefulWidget {
  const OnboardingTasteScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const OnboardingTasteScreen(),
      ),
    );
  }

  @override
  ConsumerState<OnboardingTasteScreen> createState() => _OnboardingTasteScreenState();
}

class _OnboardingTasteScreenState extends ConsumerState<OnboardingTasteScreen> {
  int _currentStep = 0; // 0: Languages & Genres, 1: Artists

  final Set<String> _selectedLanguages = {
    'Hindi',
    'Punjabi',
    'English Pop',
  };

  final Set<String> _selectedArtists = {
    'Arijit Singh',
    'Yo Yo Honey Singh',
    'Sidhu Moose Wala',
  };

  String _artistSearchQuery = '';

  static const List<Map<String, String>> _availableLanguages = [
    {'name': 'Hindi', 'native': 'हिंदी / बॉलीवुड', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ / ਭੰਗੜਾ', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Bhojpuri', 'native': 'भोजपुरी', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Haryanvi', 'native': 'हरियाणवी', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Bengali', 'native': 'বাংলা', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Marathi', 'native': 'मराठी', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Rajasthani', 'native': 'राजस्थानी', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'Odia', 'native': 'ଓଡ଼ିଆ', 'icon': '🇮🇳', 'category': 'Indian'},
    {'name': 'English Pop', 'native': 'Global Pop Hits', 'icon': '🌐', 'category': 'Global'},
    {'name': 'English Hip-Hop', 'native': 'Rap & Beats', 'icon': '🎤', 'category': 'Global'},
    {'name': 'Desi Hip-Hop', 'native': 'DHH / Gully Rap', 'icon': '🔥', 'category': 'Urban'},
    {'name': 'Retro Bollywood', 'native': '70s-90s Classics', 'icon': '📻', 'category': 'Retro'},
    {'name': 'Lo-Fi Chill', 'native': 'Relaxing Beats', 'icon': '☕', 'category': 'Chill'},
    {'name': 'EDM & Dance', 'native': 'Electronic Party', 'icon': '⚡', 'category': 'Electronic'},
  ];

  static const List<Map<String, String>> _availableArtists = [
    {'name': 'Arijit Singh', 'genre': 'Bollywood Romantic', 'lang': 'Hindi'},
    {'name': 'Yo Yo Honey Singh', 'genre': 'Desi Hip Hop / Party', 'lang': 'Hindi, Punjabi'},
    {'name': 'Shubh', 'genre': 'Punjabi Wave / Trap', 'lang': 'Punjabi'},
    {'name': 'Sidhu Moose Wala', 'genre': 'Punjabi Gangsta Rap', 'lang': 'Punjabi'},
    {'name': 'Diljit Dosanjh', 'genre': 'Punjabi Pop / Folk', 'lang': 'Punjabi'},
    {'name': 'Karan Aujla', 'genre': 'Contemporary Punjabi', 'lang': 'Punjabi'},
    {'name': 'Badshah', 'genre': 'Commercial Hip-Hop', 'lang': 'Hindi'},
    {'name': 'AP Dhillon', 'genre': 'Indo-Canadian R&B', 'lang': 'Punjabi'},
    {'name': 'Pawan Singh', 'genre': 'Bhojpuri Superstar', 'lang': 'Bhojpuri'},
    {'name': 'Khesari Lal Yadav', 'genre': 'Bhojpuri Folk / Dance', 'lang': 'Bhojpuri'},
    {'name': 'Masoom Sharma', 'genre': 'Haryanvi Ragni / Beat', 'lang': 'Haryanvi'},
    {'name': 'Kishore Kumar', 'genre': 'Golden Era Retro', 'lang': 'Hindi'},
    {'name': 'Lata Mangeshkar', 'genre': 'Timeless Classics', 'lang': 'Hindi'},
    {'name': 'Anirudh Ravichander', 'genre': 'Tamil / Pan-India Rock', 'lang': 'Tamil'},
    {'name': 'A.R. Rahman', 'genre': 'Sufi / World Music', 'lang': 'Hindi, Tamil'},
    {'name': 'Sid Sriram', 'genre': 'South Indian Soul', 'lang': 'Tamil, Telugu'},
    {'name': 'MC Stan', 'genre': 'Pune Hip-Hop / Trap', 'lang': 'Hindi'},
    {'name': 'Divine', 'genre': 'Gully Gang Hip-Hop', 'lang': 'Hindi'},
    {'name': 'Seedhe Maut', 'genre': 'Delhi Underground Rap', 'lang': 'Hindi'},
    {'name': 'KR\$NA', 'genre': 'Desi Lyricist Rap', 'lang': 'Hindi'},
    {'name': 'Neha Kakkar', 'genre': 'Bollywood Party', 'lang': 'Hindi'},
    {'name': 'The Weeknd', 'genre': 'Synthpop / Dark R&B', 'lang': 'English'},
    {'name': 'Drake', 'genre': 'Hip-Hop / Melodic Rap', 'lang': 'English'},
    {'name': 'Eminem', 'genre': 'Classic Rap / Hip-Hop', 'lang': 'English'},
    {'name': 'Taylor Swift', 'genre': 'Pop / Acoustic', 'lang': 'English'},
    {'name': 'Billie Eilish', 'genre': 'Alt-Pop / Indie', 'lang': 'English'},
    {'name': 'Atif Aslam', 'genre': 'Pop Rock / Sufi', 'lang': 'Hindi, Punjabi'},
    {'name': 'Kumar Sanu', 'genre': '90s Romantic Melodies', 'lang': 'Hindi'},
    {'name': 'Alka Yagnik', 'genre': 'Evergreen Melodies', 'lang': 'Hindi'},
  ];

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userPreferencesNotifierProvider);
    if (prefs.preferredLanguages.isNotEmpty) {
      _selectedLanguages.addAll(prefs.preferredLanguages);
    }
    if (prefs.preferredArtists.isNotEmpty) {
      _selectedArtists.addAll(prefs.preferredArtists);
    }
  }

  Future<void> _saveAndFinish() async {
    final notifier = ref.read(userPreferencesNotifierProvider.notifier);
    await notifier.setPreferredLanguages(_selectedLanguages.toList());
    await notifier.setPreferredArtists(_selectedArtists.toList());
    await notifier.setHasCompletedOnboarding(true);

    // Trigger immediate refresh of recommendation engine
    try {
      await ref.read(recommendationStateProvider.notifier).refresh();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Preferences updated! Tailored ${_selectedArtists.length} artists & ${_selectedLanguages.length} languages for you.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _currentStep == 0 ? 'Step 1 of 2: Languages' : 'Step 2 of 2: Artists',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_currentStep == 0) {
                setState(() => _currentStep = 1);
              } else {
                _saveAndFinish();
              }
            },
            child: Text(
              _currentStep == 0 ? 'Skip' : 'Finish',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentStep == 1
                            ? AppColors.primary
                            : AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: _currentStep == 0
                  ? _buildLanguagesStep()
                  : _buildArtistsStep(),
            ),

            // Bottom Floating Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep == 1) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (_currentStep == 0) {
                          setState(() => _currentStep = 1);
                        } else {
                          _saveAndFinish();
                        }
                      },
                      child: Text(
                        _currentStep == 0
                            ? 'Next: Pick Artists (${_selectedLanguages.length} selected)'
                            : 'Save & Personalize Feed (${_selectedArtists.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesStep() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
      children: [
        const Text(
          'What languages & vibes do you listen to?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your favorite Indian regional languages and international genres to shape your Daily Mixes.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableLanguages.map((item) {
            final name = item['name']!;
            final native = item['native']!;
            final icon = item['icon']!;
            final isSelected = _selectedLanguages.contains(name);

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedLanguages.length > 1) {
                      _selectedLanguages.remove(name);
                    }
                  } else {
                    _selectedLanguages.add(name);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.18)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          native,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildArtistsStep() {
    final filtered = _availableArtists.where((artist) {
      if (_artistSearchQuery.isEmpty) return true;
      final q = _artistSearchQuery.toLowerCase();
      return artist['name']!.toLowerCase().contains(q) ||
          artist['genre']!.toLowerCase().contains(q) ||
          artist['lang']!.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your favorite artists',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Melo will customize Quick Picks, Mashups, and Made For You based on your selections.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Search Bar for Artists
              TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search Arijit, Honey Singh, Shubh, Diljit...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (val) {
                  setState(() => _artistSearchQuery = val.trim());
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Grid of Artists
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final artist = filtered[index];
              final name = artist['name']!;
              final genre = artist['genre']!;
              final isSelected = _selectedArtists.contains(name);

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedArtists.length > 1) {
                        _selectedArtists.remove(name);
                      }
                    } else {
                      _selectedArtists.add(name);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          AuraArtwork(
                            seed: name,
                            size: 74,
                            borderRadius: BorderRadius.circular(37),
                            fallbackIcon: Icons.person_rounded,
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
