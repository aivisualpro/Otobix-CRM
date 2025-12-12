import 'package:get/get.dart';
import 'package:otobix_crm/utils/url_helper.dart';

class AdminDesktopShellController extends GetxController {
  final RxBool inAdminPanel = false.obs;
  final RxInt hubIndex = 0.obs;
  final RxInt adminIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    _applyPath(UrlHelper.getPath());
    UrlHelper.onPop(_applyPath);
  }

  // -------- actions --------
  void selectHub(int i) {
    inAdminPanel.value = false;
    hubIndex.value = i;
    UrlHelper.setPath(_hubToPath(i));
  }

  void openAdminPanel() {
    inAdminPanel.value = true;
    adminIndex.value = 0;
    UrlHelper.setPath(_adminToPath(0));
  }

  void closeAdminPanel() {
    inAdminPanel.value = false;
    hubIndex.value = 0;
    UrlHelper.setPath(_hubToPath(0));
  }

  void selectAdmin(int i) {
    inAdminPanel.value = true;
    adminIndex.value = i;
    UrlHelper.setPath(_adminToPath(i));
  }

  // -------- url mapping --------
  String _hubToPath(int i) {
    switch (i) {
      case 0:
        return '/admin';
      case 1:
        return '/admin/leads';
      case 2:
        return '/admin/inspection';
      case 3:
        return '/admin/watti';
      case 4:
        return '/admin/price-discovery';
      case 5:
        return '/admin/auction';
      default:
        return '/admin';
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
      default:
        return '/admin/dashboard';
    }
  }

  void _applyPath(String rawPath) {
    // ✅ normalize: remove query & trailing slash
    var path = rawPath.split('?').first;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    // ---------------- Hub routes ----------------
    if (path == '/admin') {
      inAdminPanel.value = false;
      hubIndex.value = 0;
      return;
    }
    if (path == '/admin/leads') {
      inAdminPanel.value = false;
      hubIndex.value = 1;
      return;
    }
    if (path == '/admin/inspection') {
      inAdminPanel.value = false;
      hubIndex.value = 2;
      return;
    }
    if (path == '/admin/watti') {
      inAdminPanel.value = false;
      hubIndex.value = 3;
      return;
    }
    if (path == '/admin/price-discovery') {
      inAdminPanel.value = false;
      hubIndex.value = 4;
      return;
    }
    if (path == '/admin/auction') {
      inAdminPanel.value = false;
      hubIndex.value = 5;
      return;
    }

    // ---------------- Admin Panel routes ----------------
    if (path == '/admin/dashboard') {
      inAdminPanel.value = true;
      adminIndex.value = 0;
      return;
    }
    if (path == '/admin/users') {
      inAdminPanel.value = true;
      adminIndex.value = 1;
      return;
    }
    if (path == '/admin/customers') {
      inAdminPanel.value = true;
      adminIndex.value = 2;
      return;
    }
    if (path == '/admin/cars') {
      inAdminPanel.value = true;
      adminIndex.value = 3;
      return;
    }
    if (path == '/admin/profile') {
      inAdminPanel.value = true;
      adminIndex.value = 4;
      return;
    }
    if (path == '/admin/kam-management') {
      inAdminPanel.value = true;
      adminIndex.value = 5;
      return;
    }

    // ✅ fallback => always go to modules hub
    inAdminPanel.value = false;
    hubIndex.value = 0;
  }
}
