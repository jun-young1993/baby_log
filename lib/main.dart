import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'baby_photo_vault_app.dart';
import 'core/models/photo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PhotoModelAdapter());

  // Initialize date formatting for Korean locale
  await initializeDateFormatting('ko_KR', null);

  runApp(const ProviderScope(child: BabyPhotoVaultApp()));
}
