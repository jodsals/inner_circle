import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom SVG icon widget for app icons
class AppIcon extends StatelessWidget {
  final String iconName;
  final double? size;
  final Color? color;

  const AppIcon({
    super.key,
    required this.iconName,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$iconName.svg',
      width: size ?? 24,
      height: size ?? 24,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// Navigation bar icon names
class AppIconNames {
  static const String home = 'home';
  static const String homeHighlighted = 'home_highlighted';
  static const String search = 'search';
  static const String searchHighlighted = 'search_highlighted';
  static const String community = 'community';
  static const String communityHighlighted = 'community_highlighted';
  static const String news = 'news';
  static const String newsHighlighted = 'news_highlighted';
  static const String account = 'account';
  static const String accountHighlighted = 'account_highlighted';

  // Other icons
  static const String arrowBack = 'arrow_back';
  static const String morePoints = 'morePoints';
  static const String morePointsHighlighted = 'morePoints_highlighted';
  static const String trash = 'trash';
  static const String favorite = 'favorite';
  static const String favoriteActive = 'favorite_active';
  static const String chat = 'chat';
  static const String verified = 'verified';
}
