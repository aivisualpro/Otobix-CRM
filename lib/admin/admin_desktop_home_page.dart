import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_approved_users_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_approved_users_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_rejected_users_list_page.dart';
import 'package:otobix_crm/admin/admin_rejected_users_list_page.dart';
import 'package:otobix_crm/admin/controller/admin_desktop_pending_users_list_page.dart';
import 'package:otobix_crm/admin/controller/admin_home_controller.dart';
import 'package:otobix_crm/admin/controller/admin_pending_users_list_page.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminDesktopHomePage extends StatelessWidget {
  AdminDesktopHomePage({super.key});

  final AdminHomeController getxController =
      Get.isRegistered<AdminHomeController>()
          ? Get.find<AdminHomeController>()
          : Get.put(AdminHomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Obx(
        () => IndexedStack(
          index: getxController.currentTabIndex.value,
          children: [
            ResponsiveLayout(
              mobile: AdminPendingUsersListPage(
                searchQuery: getxController.searchQuery,
                selectedRoles: getxController.selectedRoles,
              ),
              desktop: AdminDesktopPendingUsersListPage(
                searchQuery: getxController.searchQuery,
                selectedRoles: getxController.selectedRoles,
              ),
            ),
            ResponsiveLayout(
              mobile: AdminApprovedUsersListPage(
                searchQuery: getxController.searchQuery,
                selectedRoles: getxController.selectedRoles,
              ),
              desktop: AdminDesktopApprovedUsersListPage(
                searchQuery: getxController.searchQuery,
                selectedRoles: getxController.selectedRoles,
              ),
            ),
            ResponsiveLayout(
              mobile: AdminRejectedUsersListPage(
                searchQuery: getxController.searchQuery,
                selectedRoles: getxController.selectedRoles,
              ),
              desktop: AdminDesktopRejectedUsersListPage(
                searchQuery: getxController.searchQuery,
                selectedRoles: getxController.selectedRoles,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
