import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_desktop_dashboard.dart';
import 'package:otobix_crm/admin/root_shell.dart';
import 'package:otobix_crm/admin/simple_page.dart';
import 'package:otobix_crm/utils/app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    // Root sections (Shell + body)
    GetPage(
        name: Routes.home,
        page: () => RootShell(child: const SimplePage(title: 'Home'))),
    GetPage(
        name: Routes.leads,
        page: () => RootShell(child: const SimplePage(title: 'Leads'))),
    GetPage(
        name: Routes.inspection,
        page: () => RootShell(child: const SimplePage(title: 'Inspection'))),
    GetPage(
        name: Routes.watti,
        page: () => RootShell(child: const SimplePage(title: 'Watti'))),
    GetPage(
        name: Routes.priceDiscovery,
        page: () =>
            RootShell(child: const SimplePage(title: 'Price Discovery'))),
    GetPage(
        name: Routes.auction,
        page: () => RootShell(child: const SimplePage(title: 'Auction'))),

    // Admin entry (grid)
    GetPage(
        name: Routes.admin,
        page: () => RootShell(child: const AdminDesktopDashboard())),

    // Admin sub pages
    GetPage(
        name: Routes.adminDashboard,
        page: () => RootShell(child: const AdminDesktopDashboard())),
    //   GetPage(name: Routes.adminUsers, page: () => RootShell(child: const AdminSubPage(title: 'Users'))),
    //   GetPage(name: Routes.adminCustomers, page: () => RootShell(child: const AdminSubPage(title: 'Customers'))),
    //   GetPage(name: Routes.adminCars, page: () => RootShell(child: const AdminSubPage(title: 'Cars'))),
    //   GetPage(name: Routes.adminProfile, page: () => RootShell(child: const AdminSubPage(title: 'Profile'))),
    //   GetPage(name: Routes.adminKam, page: () => RootShell(child: const AdminSubPage(title: 'KAM Management'))),
  ];
}
