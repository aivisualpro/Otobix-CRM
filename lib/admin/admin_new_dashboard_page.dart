
import 'package:flutter/material.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/widgets/glass_container.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class AdminNewDashboardPage extends StatefulWidget {
  const AdminNewDashboardPage({super.key});

  @override
  State<AdminNewDashboardPage> createState() => _AdminNewDashboardPageState();
}

class _AdminNewDashboardPageState extends State<AdminNewDashboardPage> {
  int _selectedIndex = 0; // 0 = Inspection, 1 = Customer, 2 = Auction

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildHeader(),
                _buildTabSelector(),
              ],
            ),
            const SizedBox(height: 32),

            // Content Switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 0 
                  ? _buildInspectionTab() 
                  : _selectedIndex == 1
                      ? _buildCustomerTab()
                      : _buildAuctionTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabBtn("Inspection", 0),
          const SizedBox(width: 4),
          _buildTabBtn("Customer", 1),
          const SizedBox(width: 4),
          _buildTabBtn("Auction", 2),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.neonGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const SizedBox.shrink(); // Title removed as per user request
  }

  // ==================== INSPECTION TAB ====================
  Widget _buildInspectionTab() {
    return Column(
      children: [
        // Top Stats Row
        _buildStatsRow(),
        const SizedBox(height: 32),

        // Main Content Area (Chart + Side Panel)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildMainChartSection(),
                  const SizedBox(height: 32),
                  _buildRecentOrdersTable(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 1,
              child: _buildRightSidePanel(),
            ),
          ],
        ),
      ],
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
             Expanded(child: _buildGaugeCard("Total Sales", "₹3,000,000", 0.75, AppColors.neonGreen)),
             const SizedBox(width: 20),
             Expanded(child: _buildGaugeCard("Profit", "₹600,000", 0.6, AppColors.neonGreen)),
             const SizedBox(width: 20),
             Expanded(child: _buildGaugeCard("Current Fleet", "50", 0.5, AppColors.neonGreen)),
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
  Widget _buildGaugeCard(String title, String value, double progress, Color accentColor) {
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
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_outward, color: Colors.black, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 140, height: 80,
                  child: CustomPaint(
                    painter: SemiCircleGaugePainter(progress: progress, color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                        child: const Icon(Icons.attach_money, color: AppColors.neonGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text("Total Sales", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Text("Monthly", style: TextStyle(color: AppColors.neonGreen, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: AppColors.neonGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Lorem ipsum dolor sit amet consectetur mauris vitae leo dignissim lectus mi amet elementum",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("View All Inventory", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 6),
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward, color: Colors.black, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Image.asset("lib/assets/images/car_silver.png", height: 120, fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => Container(height: 120, color: Colors.grey[800], child: const Center(child: Icon(Icons.directions_car, color: Colors.white30, size: 50))),
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
            child: const Text("₹200,000", style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        Container(
          width: 24,
          height: 100 * height,
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.neonGreen : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isHighlighted ? AppColors.neonGreen : Colors.white.withOpacity(0.2)),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.neonGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: TextStyle(color: isHighlighted ? Colors.black : Colors.white54, fontSize: 10)),
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
                  const Text("Latest Inventory", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("View All Inventory", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Lorem ipsum dolor sit amet consectetur vitae leo dignissim lectus mi amet elementum",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white38, size: 16),
                  ),
                  Expanded(
                    child: Image.asset("lib/assets/images/car_red.png", height: 100, fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => Container(height: 100, color: Colors.grey[800], child: const Center(child: Icon(Icons.directions_car, color: Colors.white30, size: 50))),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 12),
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
                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.build, color: Colors.blueAccent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text("Maintenance", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("View All", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMaintenanceRow("Toyota Corolla", "Est12323", "20000", "14-05-2024", "₹20,000"),
              const Divider(color: Colors.white10, height: 24),
              _buildMaintenanceRow("Toyota Corolla", "Est12323", "20000", "14-05-2024", "₹20,000"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceRow(String car, String code, String km, String date, String cost) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_car, color: Colors.redAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(car, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Text(code, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 16),
        Text(km, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 16),
        Text(date, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(width: 16),
        Text(cost, style: const TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  const Text("Top 3 Sales Agent", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("View All", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: Colors.black, size: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: const [
                      Text("80+", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Sales Agent", style: TextStyle(color: Colors.white54, fontSize: 12)),
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

  Widget _buildAgentAvatar(double size, Color borderColor, {bool isMain = false}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800],
        border: Border.all(color: borderColor, width: isMain ? 3 : 2),
        boxShadow: isMain ? [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 15)] : [],
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
            Expanded(child: _buildAuctionStatCard("Live Auctions", "12", Icons.gavel, Colors.orangeAccent)),
            const SizedBox(width: 20),
            Expanded(child: _buildAuctionStatCard("Active Bids", "847", Icons.trending_up, Colors.blueAccent)),
            const SizedBox(width: 20),
            Expanded(child: _buildAuctionStatCard("Won Today", "23", Icons.emoji_events, AppColors.neonGreen)),
            const SizedBox(width: 20),
            Expanded(child: _buildAuctionStatCard("Total Revenue", "₹45L", Icons.account_balance_wallet, Colors.purpleAccent)),
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

  Widget _buildAuctionStatCard(String title, String value, IconData icon, Color color) {
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
                width: 50, height: 50,
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
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
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
                        child: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text("Featured Auctions", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.circle, color: Colors.redAccent, size: 8),
                        SizedBox(width: 6),
                        Text("LIVE", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Featured Cars Grid
              Row(
                children: [
                  Expanded(child: _buildAuctionCarCard("Toyota Corolla", "2021", "₹12,50,000", "23 bids", Colors.blueAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAuctionCarCard("Honda City", "2022", "₹15,80,000", "31 bids", Colors.orangeAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAuctionCarCard("Hyundai Creta", "2023", "₹18,20,000", "45 bids", AppColors.neonGreen)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionCarCard(String name, String year, String currentBid, String bids, Color accentColor) {
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
            child: Center(child: Icon(Icons.directions_car, color: accentColor, size: 40)),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(year, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 8),
          Text(currentBid, style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(bids, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
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
              const Text("Ending Soon", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildCountdownItem("BMW 3 Series", "02:34:15", Colors.redAccent),
              const Divider(color: Colors.white10, height: 24),
              _buildCountdownItem("Mercedes C-Class", "04:12:45", Colors.orangeAccent),
              const Divider(color: Colors.white10, height: 24),
              _buildCountdownItem("Audi A4", "06:45:30", AppColors.neonGreen),
              const Divider(color: Colors.white10, height: 24),
              _buildCountdownItem("Volkswagen Passat", "08:20:00", Colors.blueAccent),
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
          child: Text(car, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(time, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  const Text("Recent Bids", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("View All", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 6),
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: Colors.black, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBidRow("Rahul Sharma", "Toyota Corolla", "₹12,45,000", "2 mins ago", true),
              const Divider(color: Colors.white10, height: 20),
              _buildBidRow("Priya Patel", "Honda City", "₹15,75,000", "5 mins ago", true),
              const Divider(color: Colors.white10, height: 20),
              _buildBidRow("Amit Kumar", "Hyundai Creta", "₹18,10,000", "8 mins ago", false),
              const Divider(color: Colors.white10, height: 20),
              _buildBidRow("Sneha Gupta", "BMW 3 Series", "₹35,00,000", "12 mins ago", true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidRow(String bidder, String car, String amount, String time, bool isHighest) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(bidder[0], style: const TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bidder, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(car, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(color: AppColors.neonGreen, fontSize: 13, fontWeight: FontWeight.bold)),
            Row(
              children: [
                if (isHighest) ...[
                  const Icon(Icons.arrow_upward, color: AppColors.neonGreen, size: 10),
                  const SizedBox(width: 2),
                ],
                Text(time, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
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
              const Text("Top Bidders", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTopBidderRow("1", "Vikram Singh", "₹2.5Cr", AppColors.neonGreen),
              const SizedBox(height: 12),
              _buildTopBidderRow("2", "Neha Kapoor", "₹1.8Cr", Colors.orangeAccent),
              const SizedBox(height: 12),
              _buildTopBidderRow("3", "Arjun Reddy", "₹1.2Cr", Colors.blueAccent),
              const SizedBox(height: 12),
              _buildTopBidderRow("4", "Meera Joshi", "₹95L", Colors.purpleAccent),
              const SizedBox(height: 12),
              _buildTopBidderRow("5", "Karan Malhotra", "₹78L", Colors.pinkAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBidderRow(String rank, String name, String totalBids, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(rank, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        Text(totalBids, style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }


  // ==================== INSPECTION TAB WIDGETS ====================

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Total Revenue", "₹128.5K", "+12.5%", Icons.attach_money, [Colors.blueAccent, Colors.purpleAccent])),
        const SizedBox(width: 20),
        Expanded(child: _buildStatCard("Active Users", "1,245", "+4.2%", Icons.people_outline, [Colors.orangeAccent, Colors.pinkAccent])),
        const SizedBox(width: 20),
        Expanded(child: _buildStatCard("New Orders", "345", "+8.1%", Icons.shopping_bag_outlined, [AppColors.neonGreen, Colors.tealAccent])),
        const SizedBox(width: 20),
        Expanded(child: _buildStatCard("Pending Issues", "12", "-2.4%", Icons.warning_amber_rounded, [Colors.redAccent, Colors.orange], isNegative: true)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String percentage, IconData icon, List<Color> gradientColors, {bool isNegative = false}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(16),
               gradient: LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [
                   Colors.white.withOpacity(0.05),
                   Colors.white.withOpacity(0.01),
                 ],
               )
             ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors.map((c) => c.withOpacity(0.2)).toList(), begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: gradientColors[0], size: 22),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isNegative 
                            ? Colors.red.withOpacity(0.1) 
                            : AppColors.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isNegative ? Colors.red.withOpacity(0.2) : AppColors.neonGreen.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 14,
                            color: isNegative ? Colors.redAccent : AppColors.neonGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            percentage,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isNegative ? Colors.redAccent : AppColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainChartSection() {
    return GlassContainer(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Revenue Analytics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Overview of profit this year",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: const [
                    Text("2024", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 13)),
                    SizedBox(width: 8),
                    Icon(Icons.calendar_today, color: AppColors.textGrey, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: SmoothLineChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable() {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Orders",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              TextButton(onPressed: (){}, child: const Text("View All", style: TextStyle(color: AppColors.neonGreen)))
            ],
          ),
          const SizedBox(height: 24),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.glassBorder, width: 1)),
                ),
                children: [
                  _textAlign("CUSTOMER", isHeader: true),
                  _textAlign("DATE", isHeader: true),
                  _textAlign("AMOUNT", isHeader: true),
                  _textAlign("STATUS", isHeader: true),
                ],
              ),
              TableRow(children: [SizedBox(height: 16), SizedBox(height: 16), SizedBox(height: 16), SizedBox(height: 16)]),
              _buildTableRow("Alice Johnson", "Oct 24, 2025", "₹1,200.00", "Completed", AppColors.neonGreen),
              _buildTableRow("Bob Williams", "Oct 23, 2025", "₹850.50", "Pending", Colors.orange),
              _buildTableRow("Charlie Brown", "Oct 22, 2025", "₹2,300.00", "Completed", AppColors.neonGreen),
              _buildTableRow("Diana Prince", "Oct 21, 2025", "₹150.00", "Cancelled", Colors.redAccent),
              _buildTableRow("Evan Wright", "Oct 20, 2025", "₹4,200.00", "Processing", Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String name, String date, String amount, String status, Color statusColor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                ),
                 alignment: Alignment.center,
                child: Text(name[0], style: const TextStyle(fontSize: 14, color: AppColors.textWhite, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Text(date, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        Text(amount, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 0.5),
              ),
              child: Text(
                status, 
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _textAlign(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? AppColors.textGrey : AppColors.textWhite,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          fontSize: isHeader ? 11 : 13,
          letterSpacing: isHeader ? 1.0 : 0.0,
        ),
      ),
    );
  }

  Widget _buildRightSidePanel() {
    return Column(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Performance by Region",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite),
              ),
              const SizedBox(height: 24),
              _buildRegionRow("Kolkata", 85, Colors.blueAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Siliguri", 78, Colors.purpleAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Krishnanagar", 72, Colors.orangeAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Bhubaneswar", 68, AppColors.neonGreen),
              const SizedBox(height: 16),
              _buildRegionRow("Patna", 65, Colors.pinkAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Gaya", 60, Colors.tealAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Cuttack", 55, Colors.cyanAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Durgapur", 48, Colors.amberAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Asansol", 42, Colors.indigoAccent),
              const SizedBox(height: 16),
              _buildRegionRow("Ranchi", 35, Colors.deepOrangeAccent),
            ],
          ),
        ),
        const SizedBox(height: 32),
        GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Notifications",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textWhite),
              ),
              const SizedBox(height: 24),
              _buildNotificationItem("New user registration", "5 mins ago", Icons.app_registration, Colors.blue),
              _buildNotificationItem("Server maintenance scheduled", "2 hours ago", Icons.dns, Colors.orange),
              _buildNotificationItem("Payment gateway update", "1 day ago", Icons.credit_card, Colors.green),
              _buildNotificationItem("System security check", "2 days ago", Icons.security, Colors.redAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegionRow(String name, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
            Text("$percentage%", style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 6, decoration: BoxDecoration(color: AppColors.glassBorder.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
            Container(
              height: 6, 
              width: 250 * (percentage / 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.5)]),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 1))]
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
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

      path.cubicTo(
        x1 + (x2 - x1) / 2, y1,
        x1 + (x2 - x1) / 2, y2,
        x2, y2
      );
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
         
         canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = AppColors.neonGreen);
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
