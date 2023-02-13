import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_me/common/widgets/error.dart';
import 'package:you_me/common/widgets/loader.dart';
import 'package:you_me/features/auth/controller/auth_controller.dart';
import 'package:you_me/firebase_options.dart';
import 'package:you_me/router.dart';
import 'package:you_me/screens/mobile_layout_screen.dart';

import 'colors.dart';
import 'features/landing/screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(data: (user){
        if(user == null){
          return const LandingScreen();
        }
        return const MobileLayoutScreen();
      }, error: (err, StackTrace){
        return ErrorScreen(error: err.toString());
      }, loading: () => const Loader()),
    );
  }
}
