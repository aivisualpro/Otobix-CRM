import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_desktop_completed_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_live_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_oto_buy_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_upcoming_cars_list_page.dart';
import 'package:otobix_crm/admin/controller/tab_bar_buttons_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/admin/admin_auction_completed_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_live_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_oto_buy_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_upcoming_cars_list_page.dart';
import 'package:otobix_crm/admin/controller/admin_auction_completed_cars_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_cars_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_live_cars_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_oto_buy_cars_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_upcoming_cars_list_controller.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'dart:ui' as ui;

class AdminDesktopCarsListPage extends StatelessWidget {
  AdminDesktopCarsListPage({super.key});

  final AdminCarsListController mainController = Get.put(
    AdminCarsListController(),
  );
  final AdminUpcomingCarsListController upcomingController = Get.put(
    AdminUpcomingCarsListController(),
  );
  final AdminLiveCarsListController liveController = Get.put(
    AdminLiveCarsListController(),
  );
  final AdminAuctionCompletedCarsListController auctionCompletedController =
      Get.put(AdminAuctionCompletedCarsListController());
  final AdminOtoBuyCarsListController otoBuyController = Get.put(
    AdminOtoBuyCarsListController(),
  );

  final tabBarController = Get.put(
    TabBarButtonsController(tabLength: 4, initialIndex: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          _buildBackground(),
          // Main Content - no padding on top to align with sidebar
          Padding(
            padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and tabs + search inline
                _buildHeader(),
                // Main content area
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1117),
            Color(0xFF161B22),
            Color(0xFF0D1117),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.neonGreen.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.teal.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Car Inventory',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage auctions, bids, and car listings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tabs row with search inline
          _buildTabsWithSearch(),
        ],
      ),
    );
  }

  Widget _buildTabsWithSearch() {
    return Obx(() => Row(
      children: [
        // Tabs with counts - wrapped in Expanded to flex
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabWithCount(
                  label: "Upcoming",
                  count: upcomingController.upcomingCarsCount.value,
                  icon: Icons.schedule,
                  color: Colors.orange,
                  index: 0,
                ),
                const SizedBox(width: 12),
                _buildTabWithCount(
                  label: "Live",
                  count: liveController.liveCarsCount.value,
                  icon: Icons.live_tv,
                  color: Colors.redAccent,
                  index: 1,
                ),
                const SizedBox(width: 12),
                _buildTabWithCount(
                  label: "Completed",
                  count: auctionCompletedController.auctionCompletedCarsCount.value,
                  icon: Icons.check_circle,
                  color: AppColors.neonGreen,
                  index: 2,
                ),
                const SizedBox(width: 12),
                _buildTabWithCount(
                  label: "OtoBuy",
                  count: otoBuyController.otoBuyCarsCount.value,
                  icon: Icons.shopping_cart,
                  color: Colors.blueAccent,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Search bar
        _buildSearchBar(),
      ],
    ));
  }

  Widget _buildTabWithCount({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    final isSelected = tabBarController.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => tabBarController.tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.4) : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.white54),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white54,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? color : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 280,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: mainController.searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search cars...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) {
              mainController.searchQuery.value = value.toLowerCase();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TabBarView(
            controller: tabBarController.tabController,
            children: [
              _buildTabContent(
                ResponsiveLayout(
                  mobile: AdminUpcomingCarsListPage(),
                  desktop: AdminDesktopUpcomingCarsListPage(),
                ),
              ),
              _buildTabContent(
                ResponsiveLayout(
                  mobile: AdminLiveCarsListPage(),
                  desktop: AdminDesktopLiveCarsListPage(),
                ),
              ),
              _buildTabContent(
                ResponsiveLayout(
                  mobile: AdminAuctionCompletedCarsListPage(),
                  desktop: AdminDesktopAuctionCompletedCarsListPage(),
                ),
              ),
              _buildTabContent(
                ResponsiveLayout(
                  mobile: AdminOtoBuyCarsListPage(),
                  desktop: AdminDesktopOtoBuyCarsListPage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget child) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
