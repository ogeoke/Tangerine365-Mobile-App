import 'package:flutter/material.dart';
import 'package:sevenup_mobile/constants/app_assets.dart';

/// Application environment variables
abstract class Env {
  /// API base url
  String get baseUrl;

  String get scormApiKey => 'q2Zvs7IWwVHZ0kgcAM8758x';

  String get appTitle => 'Tangerine365';

  // Approved Tangerine365 brand colors (Figma). Replaces legacy
  // accent #FB562A / primary #48B401. See constants/app_tokens.dart.
  Color get accentColor => const Color(0xffE83312);
  Color get primaryColor => const Color(0xff397B27);
  String get logo => AppAssets.logo;
}

class Production extends Env {
  @override
  String get baseUrl => 'https://tangerinelms.com/';
  // Previous tenants:
  // 'https://wema-mssql.tangerine365.com/';
  // 'https://learning.sevenup.org/';
  // 'https://learningmanagement.premiumtrustbank.com/';
  // 'https://learningzone.fcmb.com/www'; // 'https://onlinerefinery.hbng.com/www';
  // 'https://mlearn.firstbanknigeria.com/firstacademy_lms/www';
}
// class Test extends Env {
//   @override
//   String get baseUrl => 'https://mlearn.firstbanknigeria.com/firstacademy_lms';
// }

class Development extends Env {
  @override
  String get baseUrl => 'https://tangerinelms.com/';
  // 'https://tangerine365.com/';
  // 'https://wema-mssql.tangerine365.com/';
  // 'https://learning.sevenup.org/';
}
