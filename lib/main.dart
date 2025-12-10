import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otobix_crm/admin/admin_dashboard.dart';
import 'package:otobix_crm/admin/admin_desktop_dashboard.dart';
import 'package:otobix_crm/network/socket_service.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/utils/app_urls.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/utils/shared_prefs_helper.dart';
import 'package:otobix_crm/views/desktop_homepage.dart';
import 'package:otobix_crm/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firstScreen = await loadInitialData();

  runApp(MyApp(firstScreen: firstScreen));
}

class MyApp extends StatelessWidget {
  final Widget firstScreen;

  const MyApp({super.key, required this.firstScreen});

  @override
  Widget build(BuildContext context) {
    // Define Lato text themes
    final latoTextTheme = GoogleFonts.latoTextTheme();
    final latoDarkTextTheme = GoogleFonts.latoTextTheme(
      ThemeData.dark().textTheme,
    );
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: GoogleFonts.lato().fontFamily,
        textTheme: latoTextTheme,
        scaffoldBackgroundColor: AppColors.white,
        canvasColor: AppColors.white,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.white,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.lato().fontFamily,
        textTheme: latoDarkTextTheme,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        canvasColor: const Color(0xFF161B22),
      ),
      home: firstScreen,
    );
  }
}

// Load Initial Data
Future<Widget> loadInitialData() async {
  await SharedPrefsHelper.init();
  SocketService.instance.initSocket(AppUrls.socketBaseUrl);

  final token = await SharedPrefsHelper.getString(SharedPrefsHelper.tokenKey);
  final userRole =
      await SharedPrefsHelper.getString(SharedPrefsHelper.userRoleKey);

  Widget firstScreen;

  if (token != null && token.isNotEmpty) {
    if (userRole == AppConstants.roles.admin) {
      // Admin
      firstScreen = ResponsiveLayout(
        mobile: AdminDashboard(),
        desktop: AdminDesktopDashboard(),
      );
    } else if (userRole == AppConstants.roles.salesManager) {
      // Sales Manager
      firstScreen = ResponsiveLayout(
        mobile: DesktopHomepage(),
        desktop: DesktopHomepage(),
      );

      // Login
    } else {
      firstScreen = LoginPage();
    }
  } else {
    firstScreen = LoginPage();
  }

  return firstScreen;
}
