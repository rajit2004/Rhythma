import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rhythma/l10n/app_localizations.dart';

import 'config/theme.dart';
import 'components/bottom_nav.dart';
import 'screens/home/home_screen.dart';
import 'screens/cycle/cycle_screen.dart';
import 'screens/assistant/assistant_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/local_storage_service.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env is in gitignore; .env.example is provided)
  await dotenv.load(fileName: '.env').catchError((_) {
    // .env may be absent in CI or during first clone — that's fine
    debugPrint('No .env file found. Using defaults / demo mode.');
  });

  // Initialise local offline storage
  await LocalStorageService.init();

  // Initialize notifications
  await NotificationService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const RhythmaApp(),
    ),
  );
}

class RhythmaApp extends StatelessWidget {
  const RhythmaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp(
      title: 'Rhythma',
      theme: RhythmaTheme.theme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      locale: context.watch<LocaleProvider>().locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
        Locale('te'),
        Locale('mr'),
      ],
      home: const RhythmaRoot(),
    );
  }
}

/// Root widget that decides whether to show onboarding or the main shell.
/// Uses a [ValueNotifier] so the onboarding screen can trigger a rebuild
/// without Navigator push/pop complexity.
class RhythmaRoot extends StatefulWidget {
  const RhythmaRoot({Key? key}) : super(key: key);

  @override
  State<RhythmaRoot> createState() => _RhythmaRootState();
}

class _RhythmaRootState extends State<RhythmaRoot> {
  late bool _onboardingDone;

  @override
  void initState() {
    super.initState();
    _onboardingDone = LocalStorageService.onboardingCompleted;
  }

  void _handleOnboardingComplete() {
    setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingDone) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }
    return const RhythmaShell();
  }
}

class RhythmaShell extends StatefulWidget {
  const RhythmaShell({Key? key}) : super(key: key);

  @override
  State<RhythmaShell> createState() => _RhythmaShellState();
}

class _RhythmaShellState extends State<RhythmaShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    CycleScreen(),
    AssistantScreen(),
    InsightsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        gradient: RhythmaGradients.bg,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: RhythmaBottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}
