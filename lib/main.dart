import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'baby_photo_vault_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Korean locale
  await initializeDateFormatting('ko_KR', null);

  runApp(const BabyPhotoVaultApp());
}
