import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/controller/admin_customers_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'dart:ui' as ui;

class AdminDesktopCustomersPage extends StatelessWidget {
  AdminDesktopCustomersPage({super.key});

  final AdminCustomersController controller =
      Get.find<AdminCustomersController>();

  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/images/dashboard_bg.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen Title
                  _buildScreenTitle(),
                  const SizedBox(height: 40),

                  // Statistics Overview
                  _buildStatisticsOverview(),
                  const SizedBox(height: 40),

                  // Cards Grid
                  Expanded(
                    child: _buildCardsGrid(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Title
  Widget _buildScreenTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Management",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Manage your customer base",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
         color: const Color(0xFF1E2430).withOpacity(0.6),
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.white.withOpacity(0.1)),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.2),
             blurRadius: 10, 
             offset: const Offset(0, 5)
           )
         ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: _buildDesktopStatCard(
              'Total Customers',
              controller.totalCustomersLength,
              Icons.people_alt,
              AppColors.blue)),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 24)),
          Expanded(child: _buildDesktopStatCard(
              'Active Customers',
              controller.activeCustomersLength,
              Icons.verified_user,
              AppColors.neonGreen)),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 24)),
          Expanded(child: _buildDesktopStatCard(
              'New This Month',
              controller.thisMonthCustomersLength,
              Icons.person_add,
              Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildDesktopStatCard(
      String title, RxInt count, IconData icon, Color color) {
    return Obx(() => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                     BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)
                  ]
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.value.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ));
  }

  Widget _buildCardsGrid() {
    return Obx(() => GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.1,
          ),
          itemCount: controller.customerCards.length,
          itemBuilder: (context, index) {
            final card = controller.customerCards[index];
            return _buildDesktopCustomerCard(card);
          },
        ));
  }

  Widget _buildDesktopCustomerCard(CustomerCard card) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => card.route),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.2),
                   blurRadius: 15,
                   offset: const Offset(0, 8),
                 )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: card.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: card.color.withOpacity(0.2), blurRadius: 10)
                        ]
                      ),
                      child: Icon(card.icon, color: card.color, size: 28),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white38, size: 18),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    card.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (card.count != 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: card.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: card.color.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${card.count} ${card.countLable}',
                      style: TextStyle(
                        fontSize: 12,
                        color: card.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                   Text(
                    'Explore →',
                    style: TextStyle(
                      fontSize: 14,
                      color: card.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
