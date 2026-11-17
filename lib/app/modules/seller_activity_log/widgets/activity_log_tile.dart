import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension _CategoryVisuals on String {
  IconData get _icon {
    switch (this) {
      case 'products':
        return Icons.inventory_2_outlined;
      case 'orders':
        return Icons.receipt_long_outlined;
      case 'finance':
        return Icons.attach_money_rounded;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'customers':
        return Icons.people_outline_rounded;
      case 'settings':
        return Icons.settings_outlined;
      case 'security':
        return Icons.shield_outlined;
      case 'loyalty':
        return Icons.card_giftcard_outlined;
      case 'subscriptions':
        return Icons.subscriptions_outlined;
      case 'platform_billing':
        return Icons.account_balance_wallet_outlined;
      case 'platform_plans':
        return Icons.workspace_premium_outlined;
      case 'seo':
        return Icons.search_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color get _color {
    switch (this) {
      case 'products':
        return const Color(0xFF2563EB);
      case 'orders':
        return const Color(0xFF00BFA5);
      case 'finance':
        return const Color(0xFF16A34A);
      case 'marketing':
        return const Color(0xFFF59E0B);
      case 'customers':
        return const Color(0xFF7C3AED);
      case 'settings':
        return const Color(0xFF636366);
      case 'security':
        return const Color(0xFFDC2626);
      case 'loyalty':
        return const Color(0xFFD97706);
      case 'subscriptions':
        return const Color(0xFF0062FF);
      case 'platform_billing':
        return const Color(0xFF007AFF);
      case 'platform_plans':
        return const Color(0xFF582B87);
      case 'seo':
        return const Color(0xFFFF6B6B);
      default:
        return AppColors.iosGrey;
    }
  }

  Color get _bgColor => _color.withOpacity(0.12);
}

class ActivityLogTile extends StatelessWidget {
  final ActivityLogModel log;
  const ActivityLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final color = log.isSecurityAlert ? const Color(0xFFDC2626) : log.category._color;
    final bgColor = log.isSecurityAlert ? const Color(0xFFFEE2E2) : log.category._bgColor;
    final icon = log.isSecurityAlert ? Icons.warning_amber_rounded : log.category._icon;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: log.isSecurityAlert ? const Color(0xFFFCA5A5) : AppColors.lightGrey11,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.black.withOpacity(0.025), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: log.actionLabel,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.description != null && log.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  CustomText(
                    text: log.description!,
                    fontSize: AppFontSize.tiny,
                    color: AppColors.lightGrey5,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Pill(text: log.categoryLabel, color: color, bgColor: bgColor),
                    if (log.actorName != null && log.actorName!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: CustomText(
                          text: log.actorName!,
                          fontSize: AppFontSize.tiny,
                          color: AppColors.lightGrey5,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CustomText(
            text: _relativeTime(log.createdAt),
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(local);
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;
  const _Pill({required this.text, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: CustomText(text: text, fontSize: 10, fontWeight: FontWeight.w600, color: color),
    );
  }
}
