import 'package:flutter/material.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/widgets/glass_container.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:get/get.dart';

class AdminNewDashboardPage extends StatefulWidget {
  // ✅ controlled by breadcrumb pill tabs (0=Inspection,1=Customer,2=Auction)
  final RxInt dashboardTab;

  const AdminNewDashboardPage({
    super.key,
    required this.dashboardTab,
  });

  @override
  State<AdminNewDashboardPage> createState() => _AdminNewDashboardPageState();
}

class _AdminNewDashboardPageState extends State<AdminNewDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            // ✅ Header removed (as per your existing)
            // ✅ Tabs removed from here (now in Breadcrumb container)

            // Content Switcher (Controlled by shell.dashboardTab)
            Obx(() {
              final idx = widget.dashboardTab.value;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: idx == 0
                    ? _buildInspectionTab()
                    : idx == 1
                        ? _buildCustomerTab()
                        : _buildAuctionTab(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const SizedBox.shrink(); // Title removed as per user request
  }

  // ==================== INSPECTION TAB (REDESIGNED - REFERENCE UI) ====================
  Widget _buildInspectionTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row - Gauge Cards (3)
              _buildGaugeCardsRow(isWide),
              const SizedBox(height: 24),

              // Second Row - Stats Card + Latest Inspected
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildInspectionStatsCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildLatestInspectedCard()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildInspectionStatsCard(),
                    const SizedBox(height: 20),
                    _buildLatestInspectedCard(),
                  ],
                ),
              const SizedBox(height: 24),

              // Third Row - Recent Inspections + Top Inspectors
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentInspectionsCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildTopInspectorsCardNew()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRecentInspectionsCard(),
                    const SizedBox(height: 20),
                    _buildTopInspectorsCardNew(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Top Gauge Cards Row ---
  Widget _buildGaugeCardsRow(bool isWide) {
    if (!isWide) {
      return Column(
        children: [
          _buildGaugeCardNew(
              "Pending Inspections", "24", 0.3, AppColors.neonGreen),
          const SizedBox(height: 16),
          _buildGaugeCardNew("Pass Rate", "87%", 0.87, AppColors.neonGreen),
          const SizedBox(height: 16),
          _buildGaugeCardNew(
              "Completed This Week", "156", 0.78, AppColors.neonGreen),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
            child: _buildGaugeCardNew(
                "Pending Inspections", "24", 0.3, AppColors.neonGreen)),
        const SizedBox(width: 20),
        Expanded(
            child: _buildGaugeCardNew(
                "Pass Rate", "87%", 0.87, AppColors.neonGreen)),
        const SizedBox(width: 20),
        Expanded(
            child: _buildGaugeCardNew(
                "Completed This Week", "156", 0.78, AppColors.neonGreen)),
      ],
    );
  }

  Widget _buildGaugeCardNew(
      String title, String value, double progress, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            children: [
              // Header with title and arrow button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_outward,
                        color: Colors.black, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Semi-circular gauge
              SizedBox(
                width: 160,
                height: 90,
                child: CustomPaint(
                  painter: SemiCircleGaugePainter(
                      progress: progress, color: accentColor),
                ),
              ),
              const SizedBox(height: 20),
              // Value
              Text(
                value,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Inspection Stats Card (Car Image + Bar Chart) ---
  Widget _buildInspectionStatsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.insights,
                            color: AppColors.neonGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text("Inspection Stats",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Text("Weekly",
                            style: TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            color: AppColors.neonGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Inspections completed and pending this week across all locations",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const SizedBox(height: 8),
              // View All link
              Row(
                children: [
                  Text("View All Reports",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                        color: AppColors.neonGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.black, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Car Image + Bar Chart Row
              Row(
                children: [
                  // Car Image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "lib/assets/images/car_silver.png",
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                              child: Icon(Icons.directions_car,
                                  color: Colors.white24, size: 50)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Bar Chart
                  Expanded(
                    child: ClipRect(
                      child: SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildChartBar("Mon", 0.5, false),
                            _buildChartBar("Wed", 0.85, true, "45"),
                            _buildChartBar("Fri", 0.6, false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double height, bool isHighlighted,
      [String? value]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isHighlighted && value != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value,
                style: const TextStyle(
                    fontSize: 8,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
        Container(
          width: 22,
          height: 55 * height,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.neonGreen
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: isHighlighted
                    ? AppColors.neonGreen
                    : Colors.white.withOpacity(0.15)),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.neonGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(
                  color: isHighlighted ? Colors.black : Colors.white54,
                  fontSize: 8,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // --- Latest Inspected Card (Car Carousel Style) ---
  Widget _buildLatestInspectedCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Latest Inspected",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text("View All",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Recently completed vehicle inspections with full reports available",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
              const SizedBox(height: 20),
              // Car Carousel
              Row(
                children: [
                  // Left Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: Colors.white.withOpacity(0.4), size: 14),
                  ),
                  // Car Image
                  Expanded(
                    child: Image.asset(
                      "lib/assets/images/car_silver.png",
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => SizedBox(
                        height: 120,
                        child: const Center(
                            child: Icon(Icons.directions_car,
                                color: Colors.white24, size: 50)),
                      ),
                    ),
                  ),
                  // Right Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Car Details Chips
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: [
                  _buildCarInfoChip(Icons.directions_car, "Toyota Camry"),
                  _buildCarInfoChip(Icons.calendar_today, "2022"),
                  _buildCarInfoChip(Icons.confirmation_number, "WB 14 AB 1234"),
                  _buildCarInfoChip(Icons.check_circle, "Passed"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.neonGreen, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // --- Recent Inspections Card (Table Style) ---
  Widget _buildRecentInspectionsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fact_check,
                            color: Colors.blueAccent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text("Recent Inspections",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Text("View All",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Inspection Rows
              _buildInspectionRowNew(
                  "Toyota Camry", "INS-2024-001", "42", "14-12-2024", "Passed"),
              const Divider(color: Colors.white10, height: 24),
              _buildInspectionRowNew(
                  "Honda City", "INS-2024-002", "38", "14-12-2024", "Pending"),
              const Divider(color: Colors.white10, height: 24),
              _buildInspectionRowNew("Hyundai Creta", "INS-2024-003", "45",
                  "13-12-2024", "Passed"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionRowNew(
      String car, String code, String minutes, String date, String status) {
    Color statusColor = status == "Passed"
        ? AppColors.neonGreen
        : (status == "Failed" ? Colors.redAccent : Colors.orangeAccent);
    return Row(
      children: [
        // Car Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_car,
              color: Colors.redAccent, size: 22),
        ),
        const SizedBox(width: 14),
        // Car Name
        Expanded(
          flex: 2,
          child: Text(car,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
        // Code
        Expanded(
          child: Text(code,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ),
        // Minutes
        Expanded(
          child: Text("${minutes}m",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ),
        // Date
        Expanded(
          child: Text(date,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
        ),
        // Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- Top Inspectors Card (Avatar Circle Layout) ---
  Widget _buildTopInspectorsCardNew() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Top 3 Inspectors",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text("View All",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Avatar Circles Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInspectorAvatar("P", 50, Colors.grey.shade600),
                  const SizedBox(width: 20),
                  _buildInspectorAvatar("R", 70, AppColors.neonGreen,
                      isMain: true),
                  const SizedBox(width: 20),
                  _buildInspectorAvatar("A", 50, Colors.grey.shade600),
                ],
              ),
              const SizedBox(height: 32),
              // Stats Box
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Text("12+",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Inspectors",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectorAvatar(String initial, double size, Color borderColor,
      {bool isMain = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2A3040),
        border: Border.all(color: borderColor, width: isMain ? 3 : 2),
        boxShadow: isMain
            ? [
                BoxShadow(
                    color: borderColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: isMain ? AppColors.neonGreen : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  // ==================== CUSTOMER TAB ====================
  Widget _buildCustomerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Gauge Cards Row
        Row(
          children: [
            Expanded(
                child: _buildGaugeCard(
                    "Total Sales", "₹3,000,000", 0.75, AppColors.neonGreen)),
            const SizedBox(width: 20),
            Expanded(
                child: _buildGaugeCard(
                    "Profit", "₹600,000", 0.6, AppColors.neonGreen)),
            const SizedBox(width: 20),
            Expanded(
                child: _buildGaugeCard(
                    "Current Fleet", "50", 0.5, AppColors.neonGreen)),
          ],
        ),
        const SizedBox(height: 24),

        // Second Row: Total Sales Chart + Latest Inventory
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Sales with Chart
            Expanded(
              flex: 1,
              child: _buildTotalSalesCard(),
            ),
            const SizedBox(width: 20),
            // Latest Inventory
            Expanded(
              flex: 1,
              child: _buildLatestInventoryCard(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Third Row: Maintenance + Top Sales Agent
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildMaintenanceCard(),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildTopSalesAgentCard(),
            ),
          ],
        ),
      ],
    );
  }

  // --- GAUGE CARD (Semi-circular progress with arrow button) ---
  Widget _buildGaugeCard(
      String title, String value, double progress, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_outward,
                        color: Colors.black, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 140,
                  height: 80,
                  child: CustomPaint(
                    painter: SemiCircleGaugePainter(
                        progress: progress, color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TOTAL SALES CARD (with bar chart and car image) ---
  Widget _buildTotalSalesCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.attach_money,
                            color: AppColors.neonGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text("Total Sales",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.neonGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Text("Monthly",
                            style: TextStyle(
                                color: AppColors.neonGreen, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            color: AppColors.neonGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Lorem ipsum dolor sit amet consectetur mauris vitae leo dignissim lectus mi amet elementum",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("View All Inventory",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: AppColors.neonGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.black, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      "lib/assets/images/car_silver.png",
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => Container(
                          height: 120,
                          color: Colors.grey[800],
                          child: const Center(
                              child: Icon(Icons.directions_car,
                                  color: Colors.white30, size: 50))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar("May", 0.4, false),
                        _buildBar("Apr", 0.5, false),
                        _buildBar("Mar", 0.7, true),
                        _buildBar("Jun", 0.6, false),
                        _buildBar("July", 0.55, false),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height, bool isHighlighted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isHighlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text("₹200,000",
                style: TextStyle(
                    fontSize: 8,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
        Container(
          width: 24,
          height: 100 * height,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.neonGreen
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: isHighlighted
                    ? AppColors.neonGreen
                    : Colors.white.withOpacity(0.2)),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.neonGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: isHighlighted ? Colors.black : Colors.white54,
                  fontSize: 10)),
        ),
      ],
    );
  }

  // --- LATEST INVENTORY CARD ---
  Widget _buildLatestInventoryCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Latest Inventory",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("View All Inventory",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Lorem ipsum dolor sit amet consectetur vitae leo dignissim lectus mi amet elementum",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white38, size: 16),
                  ),
                  Expanded(
                    child: Image.asset(
                      "lib/assets/images/car_red.png",
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => Container(
                          height: 100,
                          color: Colors.grey[800],
                          child: const Center(
                              child: Icon(Icons.directions_car,
                                  color: Colors.white30, size: 50))),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: AppColors.neonGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios,
                          color: Colors.black, size: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _carInfoChip(Icons.directions_car, "Toyota Corolla"),
                  _carInfoChip(Icons.calendar_today, "2018-2020"),
                  _carInfoChip(Icons.confirmation_number, "2018-2020"),
                  _carInfoChip(Icons.attach_money, "₹80,00,000"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.neonGreen, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // --- MAINTENANCE CARD ---
  Widget _buildMaintenanceCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.build,
                            color: Colors.blueAccent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text("Maintenance",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("View All",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMaintenanceRow("Toyota Corolla", "Est12323", "20000",
                  "14-05-2024", "₹20,000"),
              const Divider(color: Colors.white10, height: 24),
              _buildMaintenanceRow("Toyota Corolla", "Est12323", "20000",
                  "14-05-2024", "₹20,000"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceRow(
      String car, String code, String km, String date, String cost) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_car,
              color: Colors.redAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(car,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Text(code, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 16),
        Text(km, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 16),
        Text(date, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 16),
        Text(cost,
            style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- TOP SALES AGENT CARD ---
  Widget _buildTopSalesAgentCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Top 3 Sales Agent",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("View All",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAgentAvatar(50, Colors.grey),
                  const SizedBox(width: 16),
                  _buildAgentAvatar(70, AppColors.neonGreen, isMain: true),
                  const SizedBox(width: 16),
                  _buildAgentAvatar(50, Colors.grey),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: const [
                      Text("80+",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Sales Agent",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentAvatar(double size, Color borderColor,
      {bool isMain = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800],
        border: Border.all(color: borderColor, width: isMain ? 3 : 2),
        boxShadow: isMain
            ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 15)]
            : [],
      ),
      child: Icon(Icons.person, color: Colors.white54, size: size * 0.5),
    );
  }

  // ==================== AUCTION TAB ====================
  Widget _buildAuctionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Live Auctions Stats + Bidding Overview
        Row(
          children: [
            Expanded(
                child: _buildAuctionStatCard(
                    "Live Auctions", "12", Icons.gavel, Colors.orangeAccent)),
            const SizedBox(width: 20),
            Expanded(
                child: _buildAuctionStatCard("Active Bids", "847",
                    Icons.trending_up, Colors.blueAccent)),
            const SizedBox(width: 20),
            Expanded(
                child: _buildAuctionStatCard("Won Today", "23",
                    Icons.emoji_events, AppColors.neonGreen)),
            const SizedBox(width: 20),
            Expanded(
                child: _buildAuctionStatCard("Total Revenue", "₹45L",
                    Icons.account_balance_wallet, Colors.purpleAccent)),
          ],
        ),
        const SizedBox(height: 24),

        // Second Row: Featured Auction Cars + Live Timer
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildFeaturedAuctionCard(),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildLiveAuctionTimerCard(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Third Row: Recent Bids Table + Top Bidders
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildRecentBidsCard(),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildTopBiddersCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuctionStatCard(
      String title, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedAuctionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_fire_department,
                            color: Colors.orangeAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text("Featured Auctions",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.circle, color: Colors.redAccent, size: 8),
                        SizedBox(width: 6),
                        Text("LIVE",
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Featured Cars Grid
              Row(
                children: [
                  Expanded(
                      child: _buildAuctionCarCard("Toyota Corolla", "2021",
                          "₹12,50,000", "23 bids", Colors.blueAccent)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildAuctionCarCard("Honda City", "2022",
                          "₹15,80,000", "31 bids", Colors.orangeAccent)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildAuctionCarCard("Hyundai Creta", "2023",
                          "₹18,20,000", "45 bids", AppColors.neonGreen)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionCarCard(String name, String year, String currentBid,
      String bids, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child:
                    Icon(Icons.directions_car, color: accentColor, size: 40)),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          Text(year,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 8),
          Text(currentBid,
              style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(bids,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLiveAuctionTimerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ending Soon",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildCountdownItem("BMW 3 Series", "02:34:15", Colors.redAccent),
              const Divider(color: Colors.white10, height: 24),
              _buildCountdownItem(
                  "Mercedes C-Class", "04:12:45", Colors.orangeAccent),
              const Divider(color: Colors.white10, height: 24),
              _buildCountdownItem("Audi A4", "06:45:30", AppColors.neonGreen),
              const Divider(color: Colors.white10, height: 24),
              _buildCountdownItem(
                  "Volkswagen Passat", "08:20:00", Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownItem(String car, String time, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(car,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(time,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildRecentBidsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Recent Bids",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("View All",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBidRow("Rahul Sharma", "Toyota Corolla", "₹12,45,000",
                  "2 mins ago", true),
              const Divider(color: Colors.white10, height: 20),
              _buildBidRow("Priya Patel", "Honda City", "₹15,75,000",
                  "5 mins ago", true),
              const Divider(color: Colors.white10, height: 20),
              _buildBidRow("Amit Kumar", "Hyundai Creta", "₹18,10,000",
                  "8 mins ago", false),
              const Divider(color: Colors.white10, height: 20),
              _buildBidRow("Sneha Gupta", "BMW 3 Series", "₹35,00,000",
                  "12 mins ago", true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidRow(
      String bidder, String car, String amount, String time, bool isHighest) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(bidder[0],
                style: const TextStyle(
                    color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bidder,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Text(car,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount,
                style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (isHighest) ...[
                  const Icon(Icons.arrow_upward,
                      color: AppColors.neonGreen, size: 10),
                  const SizedBox(width: 2),
                ],
                Text(time,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 10)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopBiddersCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Top Bidders",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTopBidderRow(
                  "1", "Vikram Singh", "₹2.5Cr", AppColors.neonGreen),
              const SizedBox(height: 12),
              _buildTopBidderRow(
                  "2", "Neha Kapoor", "₹1.8Cr", Colors.orangeAccent),
              const SizedBox(height: 12),
              _buildTopBidderRow(
                  "3", "Arjun Reddy", "₹1.2Cr", Colors.blueAccent),
              const SizedBox(height: 12),
              _buildTopBidderRow(
                  "4", "Meera Joshi", "₹95L", Colors.purpleAccent),
              const SizedBox(height: 12),
              _buildTopBidderRow(
                  "5", "Karan Malhotra", "₹78L", Colors.pinkAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBidderRow(
      String rank, String name, String totalBids, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(rank,
                style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(name,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        Text(totalBids,
            style: TextStyle(
                color: accentColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Custom Painter for Smooth Gradient Line Chart
class SmoothLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [Colors.blueAccent, AppColors.neonGreen],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    final points = [
      const Offset(0, 0.8),
      const Offset(0.1, 0.7),
      const Offset(0.2, 0.75),
      const Offset(0.3, 0.5),
      const Offset(0.4, 0.55),
      const Offset(0.5, 0.3),
      const Offset(0.6, 0.35),
      const Offset(0.7, 0.2),
      const Offset(0.8, 0.25),
      const Offset(0.9, 0.1),
      const Offset(1.0, 0.05),
    ];

    path.moveTo(0, size.height);

    final gridPaint = Paint()
      ..color = AppColors.glassBorder.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    path.moveTo(0, size.height * points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final x1 = p1.dx * size.width;
      final y1 = p1.dy * size.height;
      final x2 = p2.dx * size.width;
      final y2 = p2.dy * size.height;

      path.cubicTo(x1 + (x2 - x1) / 2, y1, x1 + (x2 - x1) / 2, y2, x2, y2);
    }

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.neonGreen.withOpacity(0.2),
          AppColors.neonGreen.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) continue;
      final p = points[i];
      final cx = p.dx * size.width;
      final cy = p.dy * size.height;

      canvas.drawCircle(
          Offset(cx, cy), 5, Paint()..color = AppColors.neonGreen);
      canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Semi-Circle Gauge Painter
class SemiCircleGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  SemiCircleGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start angle
      math.pi, // Sweep angle (half circle)
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.5)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Inspection Stat Data Class
class _InspectionStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtext;

  _InspectionStat(this.label, this.value, this.icon, this.color, this.subtext);
}

// Inspection Chart Painter
class InspectionChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Completed inspections line (green)
    final completedPoints = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.55),
      Offset(size.width * 0.3, size.height * 0.35),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.15),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.1),
      Offset(size.width, size.height * 0.18),
    ];

    // Failed inspections line (red)
    final failedPoints = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.82),
      Offset(size.width * 0.3, size.height * 0.75),
      Offset(size.width * 0.4, size.height * 0.78),
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.72),
      Offset(size.width * 0.7, size.height * 0.68),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.65),
      Offset(size.width, size.height * 0.68),
    ];

    // Draw completed line
    paint.shader = LinearGradient(
      colors: [AppColors.neonGreen, AppColors.neonGreen.withOpacity(0.5)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final completedPath = Path();
    completedPath.moveTo(completedPoints[0].dx, completedPoints[0].dy);
    for (int i = 0; i < completedPoints.length - 1; i++) {
      final p0 = completedPoints[i];
      final p1 = completedPoints[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      completedPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(completedPath, paint);

    // Fill under completed line
    final fillPath = Path.from(completedPath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.neonGreen.withOpacity(0.2),
          AppColors.neonGreen.withOpacity(0.0)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw failed line
    paint.shader = LinearGradient(
      colors: [Colors.redAccent, Colors.redAccent.withOpacity(0.5)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final failedPath = Path();
    failedPath.moveTo(failedPoints[0].dx, failedPoints[0].dy);
    for (int i = 0; i < failedPoints.length - 1; i++) {
      final p0 = failedPoints[i];
      final p1 = failedPoints[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      failedPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(failedPath, paint);

    // Draw dots on completed line
    for (int i = 0; i < completedPoints.length; i += 2) {
      canvas.drawCircle(
          completedPoints[i], 4, Paint()..color = AppColors.neonGreen);
      canvas.drawCircle(completedPoints[i], 2, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
