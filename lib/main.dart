import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/equipment.dart';
import 'screens/add_item_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/owner_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/language_controller.dart';
import 'services/supabase_service.dart';
import 'widgets/sidebar.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      // Valeurs lues depuis env.json : flutter run --dart-define-from-file=env.json
      url: const String.fromEnvironment('SUPABASE_URL'),
      publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    );
  } catch (_) {}
  final languageController = LanguageController.instance;
  await languageController.load();
  runApp(MyApp(languageController: languageController));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.languageController, super.key});

  final LanguageController languageController;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: languageController,
    builder: (context, child) => MaterialApp(
      title: 'Rento Marketplace',
      debugShowCheckedModeBanner: false,
      locale: Locale(languageController.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6200EE)),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGate(),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) return const AuthScreen();
        return const MarketplaceScreen();
      },
    );
  }
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int selectedNavIndex = 0;
  bool isOwnerMode = false;

  Future<void> _openAddItem() async {
    if (SupabaseService.instance.client?.auth.currentUser == null) return;
    final result = await showDialog<EquipmentItem>(
      context: context,
      builder: (_) => const AddItemScreen(),
    );
    if (result != null && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: isDesktop ? _desktopAppBar() : _mobileAppBar(),
        body: _buildContent(),
        bottomNavigationBar: isDesktop ? null : _mobileNavigation(),
      ),
    );
  }

  PreferredSizeWidget _desktopAppBar() => PreferredSize(
    preferredSize: const Size.fromHeight(72),
    child: Material(
      color: Colors.white,
      elevation: 1,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.agriculture_rounded,
                      color: Color(0xFF6200EE),
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Rento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 28),
                    _navButton(0, context.l10n.explore),
                    _navButton(1, context.l10n.favorites),
                    _navButton(2, context.l10n.account),
                    _modeSwitcher(compact: true),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _openAddItem,
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.addEquipmentShort),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'settings') {
                          setState(() => selectedNavIndex = 2);
                        } else if (value == 'logout') {
                          AuthService.instance.signOut();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'settings',
                          child: Text(context.l10n.settings),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Text(context.l10n.logout),
                        ),
                      ],
                      child: const CircleAvatar(
                        radius: 19,
                        backgroundColor: Color(0xFF6200EE),
                        child: Icon(Icons.person_outline, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  PreferredSizeWidget _mobileAppBar() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleSize = screenWidth < 360 ? 18.0 : 22.0;
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.agriculture_rounded, color: Color(0xFF6200EE), size: 24),
          const SizedBox(width: 8),
          Text(
            'Rento',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: titleSize,
            ),
          ),
        ],
      ),
      actions: const [SizedBox(width: 8)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _modeSwitcher(),
        ),
      ),
    );
  }

  Widget _modeSwitcher({bool compact = false}) => SegmentedButton<bool>(
    segments: [
      ButtonSegment(
        value: false,
        icon: Icon(Icons.explore_outlined),
        label: Text(context.l10n.explore),
      ),
      ButtonSegment(
        value: true,
        icon: Icon(Icons.inventory_2_outlined),
        label: Text(context.l10n.owner),
      ),
    ],
    selected: {isOwnerMode},
    showSelectedIcon: false,
    style: ButtonStyle(
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
      ),
    ),
    onSelectionChanged: (selection) {
      setState(() {
        isOwnerMode = selection.first;
        selectedNavIndex = 0;
      });
    },
  );

  Widget _navButton(int index, String label) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = screenWidth < 360 ? 0.82 : 1.0;
    return TextButton(
      onPressed: () => setState(() => selectedNavIndex = index),
      style: TextButton.styleFrom(
        foregroundColor: selectedNavIndex == index
            ? const Color(0xFF6200EE)
            : Colors.black87,
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14 * textScale,
        ),
      ),
      child: Text(label),
    );
  }

  Widget _mobileNavigation() => NavigationBar(
    height: 68,
    surfaceTintColor: Colors.white,
    selectedIndex: selectedNavIndex > 2 ? 2 : selectedNavIndex,
    onDestinationSelected: (index) => setState(() => selectedNavIndex = index),
    destinations: [
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: context.l10n.explore,
      ),
      NavigationDestination(
        icon: Icon(Icons.bookmark_outline),
        selectedIcon: Icon(Icons.bookmark),
        label: context.l10n.favorites,
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: context.l10n.account,
      ),
    ],
  );

  Widget _buildContent() {
    if (isOwnerMode) {
      switch (selectedNavIndex) {
        case 0:
          return const OwnerDashboardScreen();
        case 1:
          return const FavoritesScreen();
        case 2:
          return const SettingsScreen();
        default:
          return const OwnerDashboardScreen();
      }
    }

    switch (selectedNavIndex) {
      case 0:
        return const ExploreScreen();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const ExploreScreen();
    }
  }
}

class LegacyMarketplaceScreen extends StatefulWidget {
  const LegacyMarketplaceScreen({super.key});

  @override
  State<LegacyMarketplaceScreen> createState() =>
      _LegacyMarketplaceScreenState();
}

class _LegacyMarketplaceScreenState extends State<LegacyMarketplaceScreen> {
  String currentMode = 'renter'; // 'renter' or 'owner'
  int selectedNavIndex = 0;
  bool sidebarOpen = true;

  Future<void> _openAddItem() async {
    if (SupabaseService.instance.client?.auth.currentUser == null) {
      return;
    }
    final result = await showDialog<EquipmentItem>(
      context: context,
      builder: (_) => const AddItemScreen(),
    );
    if (result != null && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 850;

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 1,
          titleSpacing: 20,
          leading: isMobile
              ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => setState(() => sidebarOpen = !sidebarOpen),
                )
              : null,
          title: const Row(
            children: [
              Icon(
                Icons.agriculture_rounded,
                color: Color(0xFF6200EE),
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Rento',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: '\u0627\u0644\u062D\u0633\u0627\u0628',
              onSelected: (value) {
                if (value == 'logout') AuthService.instance.signOut();
                if (value == 'settings') {
                  setState(() => selectedNavIndex = 4);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      SizedBox(width: 8),
                      Text('\u0627\u0644\u0625\u0639\u062F\u0627\u062F\u0627\u062A'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const CircleAvatar(
                backgroundColor: Color(0xFF6200EE),
                radius: 16,
                child: Text(
                  '\u0645',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Row(
          children: [
            // Sidebar
            if (!isMobile || sidebarOpen)
              AppSidebar(
                selected: selectedNavIndex,
                onSelect: (value) => setState(() => selectedNavIndex = value),
                onAdd: _openAddItem,
                currentMode: currentMode,
                onModeChanged: (mode) {
                  setState(() {
                    currentMode = mode;
                    selectedNavIndex = 0;
                  });
                },
              ),
            // Main content area
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (currentMode == 'renter') {
      switch (selectedNavIndex) {
        case 0:
          return const ExploreScreen();
        case 1:
          return const FavoritesScreen();
        case 2:
          return const MessagesScreen();
        case 3:
          return const SettingsScreen();
        default:
          return const ExploreScreen();
      }
    } else {
      switch (selectedNavIndex) {
        case 0:
          return const OwnerDashboardScreen();
        case 1:
          return const AnalyticsScreen();
        case 2:
          return const MessagesScreen();
        case 3:
          return const SettingsScreen();
        default:
          return const OwnerDashboardScreen();
      }
    }
  }
}
