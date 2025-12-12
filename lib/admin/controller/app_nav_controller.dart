import 'package:get/get.dart';
import 'package:otobix_crm/utils/app_routes.dart';

class AppNavController extends GetxController {
  final currentRoute = Routes.home.obs;

  void setRoute(String route) {
    currentRoute.value = route;
  }

  void go(String route) {
    if (Get.currentRoute == route) return;
    Get.offNamed(route); // URL change + back stack clean
  }

  bool isAdminRoute(String route) => route.startsWith('/admin');

  // Drawer selected index (route based)
  int get drawerIndex {
    final r = currentRoute.value;

    if (r == Routes.home) return 0;
    if (isAdminRoute(r)) return 1;
    if (r == Routes.leads) return 2;
    if (r == Routes.inspection) return 3;
    if (r == Routes.watti) return 4;
    if (r == Routes.priceDiscovery) return 5;
    if (r == Routes.auction) return 6;
    return 0;
  }

  // Breadcrumbs labels
  List<String> get breadcrumbs {
    final r = currentRoute.value;

    if (r == Routes.home) return ['Home'];

    if (isAdminRoute(r)) {
      // /admin or /admin/users
      final parts =
          r.split('/').where((e) => e.isNotEmpty).toList(); // ['admin','users']
      if (parts.length == 1) return ['Admin'];
      final child = parts[1];
      return ['Admin', _titleFromSlug(child)];
    }

    // other root pages
    return [_titleFromRoute(r)];
  }

  String _titleFromRoute(String r) {
    switch (r) {
      case Routes.leads:
        return 'Leads';
      case Routes.inspection:
        return 'Inspection';
      case Routes.watti:
        return 'Watti';
      case Routes.priceDiscovery:
        return 'Price Discovery';
      case Routes.auction:
        return 'Auction';
      default:
        return 'Home';
    }
  }

  String _titleFromSlug(String slug) {
    switch (slug) {
      case 'dashboard':
        return 'Dashboard';
      case 'users':
        return 'Users';
      case 'customers':
        return 'Customers';
      case 'cars':
        return 'Cars';
      case 'profile':
        return 'Profile';
      case 'kam':
        return 'KAM Management';
      default:
        return slug;
    }
  }
}
