import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/utils/url_helper_web.dart';

class AdminDesktopShellController extends GetxController {
  final RxBool inAdminPanel = false.obs;
  final RxInt hubIndex = 0.obs;

  final RxInt adminIndex = (-1).obs;
  final RxString adminOrigin = "".obs;

  final RxBool inLeadsPanel = false.obs;
  final RxInt leadsIndex = (-1).obs;

  final RxInt dashboardTab = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final p = UrlHelper.getPath();

    // ✅ If URL is empty or '/', force Home
    if (p == '/' || p.isEmpty) {
      _applyPath('/home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UrlHelper.replacePath('/home');
      });
    } else {
      // ✅ Restore state from URL
      _applyPath(p);

      // ✅ After first frame, force URL back to /#/... (prevents reset to '/')
      WidgetsBinding.instance.addPostFrameCallback((_) {
        UrlHelper.replacePath(p);
      });
    }

    // ✅ Handle browser back/forward
    UrlHelper.onPop(_applyPath);
  }

  /* ---------------- HUB ---------------- */

  void selectHub(int i) {
    inAdminPanel.value = false;
    inLeadsPanel.value = false;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "";
    hubIndex.value = i;

    UrlHelper.setPath(_hubToPath(i));
  }

  void backToHome() => selectHub(0);

  /* ---------------- ADMIN ---------------- */

  void openAdminPanel() {
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "admin";

    UrlHelper.setPath('/admin');
  }

  void openAdminFromHome(int pageIndex) {
    hubIndex.value = 0; // ✅ keep Home active
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = pageIndex;
    leadsIndex.value = -1;
    adminOrigin.value = "home";

    UrlHelper.setPath('${_adminToPath(pageIndex)}?origin=home');
  }

  void selectAdmin(int i, {String? origin}) {
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = i;
    leadsIndex.value = -1;

    adminOrigin.value = origin ?? adminOrigin.value;
    if (adminOrigin.value.isEmpty) adminOrigin.value = "admin";

    if (i == -1) {
      UrlHelper.setPath('/admin');
      return;
    }

    UrlHelper.setPath('${_adminToPath(i)}?origin=${adminOrigin.value}');
  }

  /* ---------------- LEADS ---------------- */

  void openLeadsPanel() {
    inLeadsPanel.value = true;
    inAdminPanel.value = false;
    leadsIndex.value = -1;
    adminIndex.value = -1;
    adminOrigin.value = "";

    UrlHelper.setPath('/leads');
  }

  void selectLeads(int i) {
    inLeadsPanel.value = true;
    inAdminPanel.value = false;
    leadsIndex.value = i;
    adminIndex.value = -1;
    adminOrigin.value = "";

    if (i == -1) {
      UrlHelper.setPath('/leads');
      return;
    }

    UrlHelper.setPath(_leadsToPath(i));
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

    // reset
    inAdminPanel.value = false;
    inLeadsPanel.value = false;
    hubIndex.value = 0;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "";

    // ADMIN
    if (path.startsWith('/admin')) {
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
      };

      if (adminRoutes.containsKey(path)) {
        adminIndex.value = adminRoutes[path]!;
        adminOrigin.value = query['origin'] ?? 'admin';

        // ✅ if opened from home, keep hub as Home
        if (adminOrigin.value == 'home') hubIndex.value = 0;
      } else {
        adminIndex.value = -1;
        adminOrigin.value = 'admin';
      }
      return;
    }

    // LEADS
    if (path.startsWith('/leads')) {
      inLeadsPanel.value = true;

      final leadsRoutes = <String, int>{
        '/leads/telecalling': 0,
        '/leads/customer-request': 1,
        '/leads/allocation': 2,
      };

      leadsIndex.value = leadsRoutes[path] ?? -1;
      return;
    }

    // HUB
    final hubRoutes = <String, int>{
      '/home': 0,
      '/leads': 1,
      '/inspection': 2,
      '/price-discovery': 3,
      '/auction': 4,
    };

    if (hubRoutes.containsKey(path)) {
      hubIndex.value = hubRoutes[path]!;
    } else {
      // fallback
      hubIndex.value = 0;
    }
  }
}
