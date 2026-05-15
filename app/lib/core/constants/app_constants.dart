class AppConstants {
  static const String backendUrl = 'https://facerate-api-uc.a.run.app';
  static const String localBackendUrl = 'http://10.0.2.2:8000';

  // Use localBackendUrl during development; switch to backendUrl for production
  static const String apiBaseUrl = backendUrl;

  // AdMob test IDs — replace with real IDs from AdMob console before release
  static const String admobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // IAP product IDs (configure in Google Play Console)
  static const String creditsProduct10 = 'credits_10';
  static const String creditsProduct30 = 'credits_30';
  static const String creditsProduct100 = 'credits_100';
  static const String proMonthly = 'pro_monthly';

  static const List<String> dailyTips = [
    'Good lighting dramatically improves every facial feature.',
    'Hunter eyes are a genetic gift — frame them with clean brows.',
    'A strong jawline is often about body fat percentage, not just genetics.',
    'Skincare in your 20s pays dividends in your 40s.',
    'The right haircut can change your face shape visually.',
    'Sunscreen is the single best anti-aging investment.',
    'Niacinamide reduces pores and evens skin tone — use it nightly.',
    'Stand up straight. Posture defines how your face is perceived.',
    'Hydration affects skin texture more than most skincare products.',
    'Your beard line should be defined — a sharp shape-up costs little.',
    'Eyebrows frame the face. Keep them groomed, not over-tweezed.',
    'Confidence is perceived as physical attractiveness by observers.',
    'Sleep deprivation shows on your face within 24 hours.',
    'Cold water on the face reduces puffiness in minutes.',
    'The right glasses frame can add or subtract visual width from your face.',
    'A V-neck or open collar creates the illusion of a longer neck.',
    'Lip balm is not optional — dry lips undermine any look.',
    'The French crop works for most face shapes. Consider it.',
    'Resting face expression matters — neutral vs. tense reads differently.',
    'Facial symmetry improves with age for most people. Be patient.',
  ];

  static const Map<String, String> archetypeDescriptions = {
    'Dark Ethereal': 'Striking deep-set features with an otherworldly intensity.',
    'Bold Classic': 'Strong symmetrical features with timeless appeal.',
    'Soft Golden': 'Warm, approachable features with natural radiance.',
    'Wild Rugged': 'Rough-edged character with magnetic unpredictability.',
    'Sharp Defined': 'Angular, precise features built for high-contrast.',
    'Fresh Youthful': 'Clean, open features with an ageless energy.',
    'Delicate Refined': 'Finely balanced features with understated elegance.',
    'Rare Exotic': 'Unusual combination of features that defies categorization.',
  };
}
