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
import 'dart:convert';

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
  final approvalStatus =
      await SharedPrefsHelper.getString(SharedPrefsHelper.approvalStatusKey);
  final permissionsJson =
      await SharedPrefsHelper.getString(SharedPrefsHelper.permissionsKey);

  print("🔐 Initial Load Check:");
  print("  Token: ${token != null ? 'EXISTS' : 'NULL'}");
  print("  User Role: $userRole");
  print("  Approval Status: $approvalStatus");
  print("  Permissions: $permissionsJson");

  Widget firstScreen;

  // ✅ Check if user is logged in and approved
  if (token != null && token.isNotEmpty && approvalStatus == 'Approved') {
    // ✅ Check if user has any permissions
    bool hasPermissions = false;
    if (permissionsJson != null && permissionsJson.isNotEmpty) {
      try {
        final List<dynamic> permissionsList = jsonDecode(permissionsJson);
        hasPermissions = permissionsList.isNotEmpty;
        print("  ✅ User has ${permissionsList.length} permission(s)");
      } catch (e) {
        print("  ❌ Error parsing permissions: $e");
      }
    }

    // ✅ Route based on user type
    if (userRole == AppConstants.roles.admin) {
      // Admin user → Admin Dashboard
      print("  🎯 Routing to: Admin Dashboard");
      firstScreen = ResponsiveLayout(
        mobile: AdminDashboard(),
        desktop: AdminDesktopDashboard(),
      );
    } else if (userRole == AppConstants.roles.salesManager) {
      // Sales Manager → Desktop Homepage
      print("  🎯 Routing to: Sales Manager Dashboard");
      firstScreen = ResponsiveLayout(
        mobile: DesktopHomepage(),
        desktop: DesktopHomepage(),
      );
    } else if (hasPermissions) {
      // ✅ ANY OTHER USER WITH VALID PERMISSIONS → Admin Dashboard
      // They will see their permitted sections only (Inspection, Leads, etc.)
      print("  🎯 Routing to: Dashboard (Permission-based access)");
      firstScreen = ResponsiveLayout(
        mobile: AdminDashboard(),
        desktop: AdminDesktopDashboard(),
      );
    } else {
      // No permissions → Login
      print("  ❌ No permissions, redirecting to Login");
      firstScreen = LoginPage();
    }
  } else {
    // Not logged in or not approved → Login
    print("  ❌ Not logged in or not approved, redirecting to Login");
    firstScreen = LoginPage();
  }

  return firstScreen;
}
