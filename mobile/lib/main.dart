import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/audio_service.dart';
import 'app/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.instance.open();
  await AudioService.instance.initialize();
  runApp(const ProviderScope(child: LudoArenaApp()));
}
