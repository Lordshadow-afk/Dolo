/// Metadata and catalog for all available Dolo app icons.
class AppIconOption {
  final String id;
  final String name;
  final String assetPath;
  final String description;
  final bool isDefault;

  const AppIconOption({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.description,
    this.isDefault = false,
  });
}

class AppIconsConfig {
  AppIconsConfig._();

  /// Default application icon (Dolo 01 - Interlocking Coins)
  static const String defaultIconId = 'interlocking_coins';

  static const List<AppIconOption> availableIcons = [
    AppIconOption(
      id: 'interlocking_coins',
      name: 'Interlocking Coins',
      assetPath: 'assets/icons/app_icons/dolo-01-interlocking-coins.svg',
      description: 'Official default icon: Two interlocking Mint & Indigo coins on Obsidian Navy.',
      isDefault: true,
    ),
    AppIconOption(
      id: 'aurora_gradient',
      name: 'Aurora Glow',
      assetPath: 'assets/icons/app_icons/dolo-13-aurora-gradient.svg',
      description: 'Vibrant neon teal & purple gradient glow.',
    ),
    AppIconOption(
      id: 'premium_gold',
      name: 'Premium Gold',
      assetPath: 'assets/icons/app_icons/dolo-15-premium-gold.svg',
      description: 'Matte obsidian with luxury gold coin emblem.',
    ),
    AppIconOption(
      id: 'neon',
      name: 'Cyber Neon',
      assetPath: 'assets/icons/app_icons/dolo-09-neon.svg',
      description: 'Electrified neon wireframe aesthetic.',
    ),
    AppIconOption(
      id: 'clay_3d',
      name: '3D Clay',
      assetPath: 'assets/icons/app_icons/dolo-10-3d-clay.svg',
      description: 'Tactile, soft claymorphic depth.',
    ),
    AppIconOption(
      id: 'pixel',
      name: 'Retro 8-Bit Pixel',
      assetPath: 'assets/icons/app_icons/dolo-11-pixel.svg',
      description: 'Nostalgic arcade coin styling.',
    ),
    AppIconOption(
      id: 'hand_drawn',
      name: 'Hand Drawn Khata',
      assetPath: 'assets/icons/app_icons/dolo-07-hand-drawn.svg',
      description: 'Student notebook scribble illustration.',
    ),
    AppIconOption(
      id: 'cute_coin',
      name: 'Cute Coin',
      assetPath: 'assets/icons/app_icons/dolo-08-cute-coin.svg',
      description: 'Friendly mascot with kawaii expressions.',
    ),
    AppIconOption(
      id: 'split_d',
      name: 'Split D',
      assetPath: 'assets/icons/app_icons/dolo-04-split-d.svg',
      description: 'Geometric split emblem representing 50/50 division.',
    ),
    AppIconOption(
      id: 'monogram_d',
      name: 'Monogram D',
      assetPath: 'assets/icons/app_icons/dolo-03-monogram-d.svg',
      description: 'Minimalist typography monogram on obsidian.',
    ),
    AppIconOption(
      id: 'friendly_bubble',
      name: 'Friendly Bubble',
      assetPath: 'assets/icons/app_icons/dolo-05-friendly-bubble.svg',
      description: 'Soft speech bubble highlighting zero-social-friction.',
    ),
    AppIconOption(
      id: 'minimal_line',
      name: 'Minimal Line',
      assetPath: 'assets/icons/app_icons/dolo-12-line.svg',
      description: 'Clean architectural hairline glyph.',
    ),
    AppIconOption(
      id: 'sticker',
      name: 'Hostel Sticker',
      assetPath: 'assets/icons/app_icons/dolo-14-sticker.svg',
      description: 'Laptop vinyl sticker aesthetic with white border.',
    ),
    AppIconOption(
      id: 'wordmark',
      name: 'Dolo Wordmark',
      assetPath: 'assets/icons/app_icons/dolo-02-wordmark.svg',
      description: 'Full brand typographic identity.',
    ),
  ];

  static AppIconOption get defaultIcon => availableIcons.firstWhere((i) => i.isDefault);

  static AppIconOption getById(String id) {
    return availableIcons.firstWhere(
      (i) => i.id == id,
      orElse: () => defaultIcon,
    );
  }
}
