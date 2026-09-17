import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_firebase/data_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'core/logging/app_log.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Offline-first: doimiy kesh + 100 MB. Aviarejimda ham yozuv ishlaydi,
  // bir marta o'qilgan oy qayta o'qilmaydi (§5.4).
  FirestoreSetup.configure(FirebaseFirestore.instance);

  FlutterError.onError = (details) => AppLog.error(
        'Flutter xatosi',
        details.exception,
        details.stack ?? StackTrace.current,
      );

  runApp(const ProviderScope(child: BudgetApp()));
}
