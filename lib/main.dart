// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:maouidi/auth/base_auth_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';
import 'backend/supabase/supabase.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'services/notification_service.dart';
import 'flutter_flow/nav/nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await SupaFlow.initialize();
  await FlutterFlowTheme.initialize();

  if (!kIsWeb) {
    await NotificationService().initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  late Stream<BaseAuthUser?> userStream;

  Future<String> _fetchUserRole(String userId) async {
    try {
      final partnerResponse = await Supabase.instance.client
          .from('medical_partners')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return partnerResponse != null ? 'Medical Partner' : 'Patient';
    } catch (e) {
      return 'Patient';
    }
  }

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    userStream = maouidiSupabaseUserStream()
      ..listen((user) async {
        _appStateNotifier.update(user);
        if (user != null) {
          final role = await _fetchUserRole(user.uid!);
          _appStateNotifier.updateUserRole(role);
        } else {
          _appStateNotifier.updateUserRole(null);
        }
      });

    

    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  String getRoute() =>
      _router.routerDelegate.currentConfiguration.uri.toString();

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((match) => match.matchedLocation)
          .toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'maouidi',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],
      theme: ThemeData(brightness: Brightness.light, useMaterial3: false),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: false),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
