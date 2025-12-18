// admin/controller/admin_shell_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/utils/url_helper_web.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDesktopShellController extends GetxController {
  final RxBool inAdminPanel = false.obs;
  final RxInt hubIndex = 0.obs;
  final RxInt adminIndex = (-1).obs;
  final RxString adminOrigin = "".obs;
  final RxBool inLeadsPanel = false.obs;
  final RxInt leadsIndex = (-1).obs;
  final RxInt dashboardTab = 0.obs;

  // Permissions list
  final RxList<String> permissions = <String>[].obs;

  // Permission check methods
  bool get isAdmin => permissions.contains('view_admin');
  bool get hasLeads => permissions.contains('view_leads') || isAdmin;
  bool get hasInspection => permissions.contains('view_inspection') || isAdmin;
  bool get hasPriceDiscovery =>
      permissions.contains('view_price_discovery') || isAdmin;
  bool get hasAuction => permissions.contains('view_auction') || isAdmin;

  @override
  void onInit() {
    super.onInit();

    // ✅ Initialize app properly
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // ✅ CRITICAL FIX: Load permissions FIRST before any URL handling
    await _loadPermissions();

    final p = UrlHelper.getPath();
    print("🔗 Initial URL path: $p");
    print("📋 Loaded permissions: ${permissions.toList()}");

    // ✅ If URL is empty or '/', force Home
    if (p == '/' || p.isEmpty) {
      print("🚀 Setting default path to /home");
      _applyPath('/home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UrlHelper.replacePath('/home');
      });
    } else {
      // ✅ Now permissions are loaded, so applyPath will work correctly
      print("🔄 Restoring path from URL: $p");
      _applyPath(p);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        UrlHelper.replacePath(p);
      });
    }

    // ✅ Handle browser back/forward
    UrlHelper.onPop((path) {
      print("🔙 Browser navigation to: $path");
      _applyPath(path);
    });
  }

  // Load permissions from SharedPreferences
  Future<void> _loadPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString('permissions');

      if (permissionsJson != null && permissionsJson.isNotEmpty) {
        final List<dynamic> permissionsList = jsonDecode(permissionsJson);
        permissions.assignAll(permissionsList.cast<String>());
        print("✅ Permissions loaded successfully: ${permissions.toList()}");
      } else {
        print("⚠️ No permissions found in SharedPreferences");
      }
    } catch (e) {
      print('❌ Error loading permissions: $e');
    }
  }

  // Get available tabs based on permissions
  List<String> getAvailableTabs() {
    final List<String> tabs = ['Home']; // Home always available

    if (isAdmin || hasLeads) {
      tabs.add('Leads');
    }

    if (isAdmin || hasInspection) {
      tabs.add('Inspection');
    }

    if (isAdmin || hasPriceDiscovery) {
      tabs.add('Price Discovery');
    }

    if (isAdmin || hasAuction) {
      tabs.add('Auction');
    }

    if (isAdmin) {
      tabs.add('Admin');
    }

    print("📋 Available tabs for user: $tabs");
    return tabs;
  }

  /* ---------------- HUB ---------------- */

  void selectHub(int i) {
    print("🎯 Selecting hub: $i");
    // ✅ Permission check for hub selection
    if (i == 1 && !hasLeads && !isAdmin) {
      print("❌ No permission for Leads hub");
      return;
    }
    if (i == 2 && !hasInspection && !isAdmin) {
      print("❌ No permission for Inspection hub");
      return;
    }
    if (i == 3 && !hasPriceDiscovery && !isAdmin) {
      print("❌ No permission for Price Discovery hub");
      return;
    }
    if (i == 4 && !hasAuction && !isAdmin) {
      print("❌ No permission for Auction hub");
      return;
    }

    inAdminPanel.value = false;
    inLeadsPanel.value = false;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "";
    hubIndex.value = i;

    final path = _hubToPath(i);
    print("🔄 Setting path to: $path");
    UrlHelper.setPath(path);
  }

  void backToHome() => selectHub(0);

  /* ---------------- ADMIN ---------------- */

  void openAdminPanel() {
    print("👑 Opening admin panel");
    // ✅ Only admin can open admin panel
    if (!isAdmin) {
      print("❌ Non-admin user trying to access admin panel");
      return;
    }

    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "admin";

    print("🔄 Setting path to: /admin");
    UrlHelper.setPath('/admin');
  }

  void openAdminFromHome(int pageIndex) {
    print("🏠 Opening admin from home: $pageIndex");
    // ✅ Only admin can open admin from home
    if (!isAdmin) {
      print("❌ Non-admin user trying to access admin from home");
      return;
    }

    hubIndex.value = 0; // ✅ keep Home active
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = pageIndex;
    leadsIndex.value = -1;
    adminOrigin.value = "home";

    final path = '${_adminToPath(pageIndex)}?origin=home';
    print("🔄 Setting path to: $path");
    UrlHelper.setPath(path);
  }

  void selectAdmin(int i, {String? origin}) {
    print("📁 Selecting admin page: $i");
    // ✅ Only admin can select admin pages
    if (!isAdmin) {
      print("❌ Non-admin user trying to select admin page");
      return;
    }

    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = i;
    leadsIndex.value = -1;

    adminOrigin.value = origin ?? adminOrigin.value;
    if (adminOrigin.value.isEmpty) adminOrigin.value = "admin";

    if (i == -1) {
      print("🔄 Setting path to: /admin");
      UrlHelper.setPath('/admin');
      return;
    }

    final path = '${_adminToPath(i)}?origin=${adminOrigin.value}';
    print("🔄 Setting path to: $path");
    UrlHelper.setPath(path);
  }

  /* ---------------- LEADS ---------------- */

  void openLeadsPanel() {
    print("📞 Opening leads panel");
    // ✅ Permission check for leads panel
    if (!hasLeads && !isAdmin) {
      print("❌ User doesn't have leads permission");
      return;
    }

    inLeadsPanel.value = true;
    inAdminPanel.value = false;
    leadsIndex.value = -1;
    adminIndex.value = -1;
    adminOrigin.value = "";

    print("🔄 Setting path to: /leads");
    UrlHelper.setPath('/leads');
  }

  void selectLeads(int i) {
    print("📞 Selecting leads page: $i");
    // ✅ Permission check for leads panel
    if (!hasLeads && !isAdmin) {
      print("❌ User doesn't have leads permission");
      return;
    }

    inLeadsPanel.value = true;
    inAdminPanel.value = false;
    leadsIndex.value = i;
    adminIndex.value = -1;
    adminOrigin.value = "";

    if (i == -1) {
      print("🔄 Setting path to: /leads");
      UrlHelper.setPath('/leads');
      return;
    }

    final path = _leadsToPath(i);
    print("🔄 Setting path to: $path");
    UrlHelper.setPath(path);
  }

  /* ---------------- PATHS ---------------- */

  String _hubToPath(int i) {
    switch (i) {
      case 0:
        return '/home';
      case 1:
        return '/leads';
      case 2:
        return '/inspection';
      case 3:
        return '/price-discovery';
      case 4:
        return '/auction';
      default:
        return '/home';
    }
  }

  String _adminToPath(int i) {
    switch (i) {
      case 0:
        return '/admin/dashboard';
      case 1:
        return '/admin/users';
      case 2:
        return '/admin/customers';
      case 3:
        return '/admin/cars';
      case 4:
        return '/admin/profile';
      case 5:
        return '/admin/kam-management';
      case 6:
        return '/admin/dropdowns';
      case 7:
        return '/admin/banners';
      case 8:
        return '/admin/settings';
      case 9:
        return '/admin/staff';
      default:
        return '/admin';
    }
  }

  String _leadsToPath(int i) {
    switch (i) {
      case 0:
        return '/leads/telecalling';
      case 1:
        return '/leads/customer-request';
      case 2:
        return '/leads/allocation';
      default:
        return '/leads';
    }
  }

  /* ---------------- URL RESTORE ---------------- */

  void _applyPath(String rawPath) {
    final parts = rawPath.split('?');
    final path = parts.first;
    final query =
        parts.length > 1 ? Uri.splitQueryString(parts[1]) : <String, String>{};

    print("🔄 Applying path: $path");
    print("🔐 Current permissions: ${permissions.toList()}");
    print("👑 Is Admin: $isAdmin");
    print("📞 Has Leads: $hasLeads");
    print("🔍 Has Inspection: $hasInspection");
    print("💰 Has Price Discovery: $hasPriceDiscovery");
    print("🔨 Has Auction: $hasAuction");

    // reset
    inAdminPanel.value = false;
    inLeadsPanel.value = false;
    hubIndex.value = 0;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "";

    // ADMIN
    if (path.startsWith('/admin')) {
      // ✅ Check admin permission
      if (!isAdmin) {
        print("❌ Non-admin user trying to access admin path: $path");
        print("🚀 Redirecting to /home");
        hubIndex.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          UrlHelper.replacePath('/home');
        });
        return;
      }

      print("✅ User has admin permission, proceeding...");
      inAdminPanel.value = true;

      final adminRoutes = <String, int>{
        '/admin/dashboard': 0,
        '/admin/users': 1,
        '/admin/customers': 2,
        '/admin/cars': 3,
        '/admin/profile': 4,
        '/admin/kam-management': 5,
        '/admin/dropdowns': 6,
        '/admin/banners': 7,
        '/admin/settings': 8,
        '/admin/staff': 9,
      };

      if (adminRoutes.containsKey(path)) {
        adminIndex.value = adminRoutes[path]!;
        adminOrigin.value = query['origin'] ?? 'admin';

        // ✅ if opened from home, keep hub as Home
        if (adminOrigin.value == 'home') hubIndex.value = 0;

        print("✅ Admin route found: ${path} -> index: ${adminIndex.value}");
      } else {
        adminIndex.value = -1;
        adminOrigin.value = 'admin';
        print("ℹ️ Admin route not found, setting to admin home");
      }
      return;
    }

    // LEADS
    if (path.startsWith('/leads')) {
      // ✅ Check leads permission
      if (!hasLeads && !isAdmin) {
        print("❌ User doesn't have leads permission for path: $path");
        print("🚀 Redirecting to /home");
        hubIndex.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          UrlHelper.replacePath('/home');
        });
        return;
      }

      print("✅ User has leads permission, proceeding...");
      inLeadsPanel.value = true;

      final leadsRoutes = <String, int>{
        '/leads/telecalling': 0,
        '/leads/customer-request': 1,
        '/leads/allocation': 2,
      };

      leadsIndex.value = leadsRoutes[path] ?? -1;
      print("✅ Leads route: ${path} -> index: ${leadsIndex.value}");
      return;
    }

    // HUB - with permission checks
    if (path == '/home') {
      hubIndex.value = 0;
      print("✅ Setting hub to Home");
    } else if (path == '/leads') {
      if (!hasLeads && !isAdmin) {
        print("❌ No permission for Leads, redirecting to Home");
        hubIndex.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          UrlHelper.replacePath('/home');
        });
      } else {
        hubIndex.value = 1;
        print("✅ Setting hub to Leads");
      }
    } else if (path == '/inspection') {
      if (!hasInspection && !isAdmin) {
        print("❌ No permission for Inspection, redirecting to Home");
        hubIndex.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          UrlHelper.replacePath('/home');
        });
      } else {
        hubIndex.value = 2;
        print("✅ Setting hub to Inspection");
      }
    } else if (path == '/price-discovery') {
      if (!hasPriceDiscovery && !isAdmin) {
        print("❌ No permission for Price Discovery, redirecting to Home");
        hubIndex.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          UrlHelper.replacePath('/home');
        });
      } else {
        hubIndex.value = 3;
        print("✅ Setting hub to Price Discovery");
      }
    } else if (path == '/auction') {
      if (!hasAuction && !isAdmin) {
        print("❌ No permission for Auction, redirecting to Home");
        hubIndex.value = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          UrlHelper.replacePath('/home');
        });
      } else {
        hubIndex.value = 4;
        print("✅ Setting hub to Auction");
      }
    } else {
      // fallback to home
      print("⚠️ Unknown path: $path, falling back to home");
      hubIndex.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UrlHelper.replacePath('/home');
      });
    }

    print("🎯 Final hubIndex set to: ${hubIndex.value}");
  }
}
