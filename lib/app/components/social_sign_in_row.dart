import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/app_config.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

// Social sign-in row — outlined pill buttons with icon + label. Shared by
// LoginView and SignUpView so both tabs of AuthTabsView offer the same
// providers. Facebook shows only when the build has a FACEBOOK_APP_ID
// (`--dart-define`); without it the button is hidden.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({
    super.key,
    required this.onGoogle,
    this.onFacebook,
    required this.isBusy,
    required this.activeProvider,
    this.facebookEnabled,
  });
  final VoidCallback onGoogle;
  final VoidCallback? onFacebook;
  final bool isBusy;
  final String activeProvider;

  /// Overrides [AppConfig.facebookLoginEnabled] (tests).
  final bool? facebookEnabled;

  bool get _showFacebook => onFacebook != null && (facebookEnabled ?? AppConfig.facebookLoginEnabled);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialButton(
          key: const Key('socialGoogle'),
          icon: AppIcons.googleIcon,
          label: 'Google',
          onTap: onGoogle,
          disabled: isBusy,
          isLoading: activeProvider == 'google',
        ),
        if (_showFacebook) ...[
          SizedBox(width: BaseSpacing.sm),
          _SocialButton(
            key: const Key('socialFacebook'),
            icon: AppIcons.facebookIcon,
            label: 'Facebook',
            onTap: onFacebook!,
            disabled: isBusy,
            isLoading: activeProvider == 'facebook',
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
    this.isLoading = false,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Opacity(
          opacity: disabled && !isLoading ? 0.5 : 1,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey2),
              borderRadius: BorderRadius.circular(BaseRadius.md),
              color: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isLoading
                  ? [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ]
                  : [
                      SvgIcon(assetName: icon, size: 18),
                      SizedBox(width: BaseSpacing.xxs + 1),
                      Flexible(
                        child: CustomText(
                          text: label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.black2,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
