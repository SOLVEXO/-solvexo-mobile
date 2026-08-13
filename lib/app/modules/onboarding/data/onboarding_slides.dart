import 'package:book_store_app/config/resources/app_icons.dart';

/// Buyer value-prop slide shown once on first launch. Kept as a plain data
/// list — add/remove/reorder slides here without touching the carousel UI.
class OnboardingSlideData {
  final String icon;
  final String title;
  final String subtitle;

  const OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const List<OnboardingSlideData> kOnboardingSlides = [
  OnboardingSlideData(
    icon: AppIcons.shoppingBag,
    title: 'Shop from local sellers',
    subtitle: 'Thousands of products, all in one place.',
  ),
  OnboardingSlideData(
    icon: AppIcons.truckIcon,
    title: 'Track orders in real time',
    subtitle: 'Know exactly where your order is.',
  ),
  OnboardingSlideData(
    icon: AppIcons.verifiedIcon,
    title: 'Buy with confidence',
    subtitle: 'Every store on Solvexo is verified.',
  ),
];
