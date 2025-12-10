import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_cars_list_controller.dart';
import 'package:otobix_crm/models/cars_list_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/global_functions.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';
import 'package:otobix_crm/admin/controller/admin_oto_buy_cars_list_controller.dart';
import 'dart:ui' as ui;

class AdminDesktopOtoBuyCarsListPage extends StatelessWidget {
  AdminDesktopOtoBuyCarsListPage({super.key});

  final AdminCarsListController carsListController = Get.find<AdminCarsListController>();
  final AdminOtoBuyCarsListController otoBuyController = Get.find<AdminOtoBuyCarsListController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1117), Color(0xFF161B22)],
        ),
      ),
      child: Obx(() {
        if (otoBuyController.isLoading.value) {
          return _buildLoadingGrid();
        }
        final carsList = carsListController.searchCar(
          carsList: otoBuyController.filteredOtoBuyCarsList,
        );
        if (carsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, size: 80, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No OtoBuy Cars', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
              ],
            ),
          );
        }
        return _buildCarsGrid(carsList);
      }),
    );
  }

  Widget _buildCarsGrid(List<CarsListModel> carsList) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemCount: carsList.length,
      itemBuilder: (context, index) => _buildCarCard(carsList[index]),
    );
  }

  Widget _buildCarCard(CarsListModel car) {
    final String yearOfManufacture =
        '${GlobalFunctions.getFormattedDate(date: car.yearMonthOfManufacture, type: GlobalFunctions.year)} ';

    return Obx(() {
      final isSold = otoBuyController.isSold(car.id, car.auctionStatus);
      
      return GestureDetector(
        onTap: isSold ? null : () => _showActionsDialog(car),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isSold ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCarImage(car, isSold),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$yearOfManufacture${car.make} ${car.model}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(car.variant, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                          _buildSpecsRow(car),
                          const Spacer(),
                          _buildBottomRow(car, isSold),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCarImage(CarsListModel car, bool isSold) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: CachedNetworkImage(
            imageUrl: car.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.grey[800]!])),
              child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2)),
            ),
            errorWidget: (context, error, stackTrace) => Container(
              height: 180,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.grey[800]!])),
              child: Center(child: Icon(Icons.directions_car, size: 50, color: Colors.grey[600])),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)]),
            ),
          ),
        ),
        // Status badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSold ? Colors.redAccent : Colors.blueAccent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: (isSold ? Colors.redAccent : Colors.blueAccent).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isSold ? Icons.sell : Icons.shopping_cart, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(isSold ? 'SOLD' : 'OTOBUY', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
        ),
        // Price badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              '₹${NumberFormat.compact().format(car.oneClickPrice)}',
              style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildMiniChip(Icons.speed, '${NumberFormat.compact().format(car.odometerReadingInKms)} km'),
                const SizedBox(width: 8),
                _buildMiniChip(Icons.settings, car.commentsOnTransmission),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSpecsRow(CarsListModel car) {
    return Row(
      children: [
        _buildSpecItem(Icons.local_gas_station, car.fuelType.isNotEmpty ? car.fuelType : 'N/A'),
        const SizedBox(width: 8),
        _buildSpecItem(Icons.person, car.ownerSerialNumber == 1 ? '1st Owner' : '${car.ownerSerialNumber} Owners'),
        const SizedBox(width: 8),
        _buildSpecItem(Icons.location_on, car.inspectionLocation),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.blueAccent.withOpacity(0.8)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(value, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow(CarsListModel car, bool isSold) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isSold ? 'Sold At' : 'Current Offer', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 2),
                Obx(() => Text(
                  '₹${NumberFormat.decimalPattern('en_IN').format(isSold ? otoBuyController.soldAtFor(car.id, car.soldAt.toDouble()) : otoBuyController.offerFor(car.id, car.otobuyOffer))}',
                  style: TextStyle(fontSize: 16, color: isSold ? Colors.redAccent : AppColors.neonGreen, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
          if (!isSold)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blueAccent, Color(0xFF2196F3)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sell, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Actions', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Obx(() => Text(
                'To: ${otoBuyController.soldToNameFor(car.id, car.soldToName)}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 0.72),
      itemCount: 6,
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget(height: 180, borderRadius: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(height: 20, width: 150),
                      const SizedBox(height: 8),
                      ShimmerWidget(height: 14, width: 100),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ShimmerWidget(height: 10, width: 60), const SizedBox(height: 4), ShimmerWidget(height: 18, width: 80)]),
                          ShimmerWidget(height: 36, width: 100, borderRadius: 12),
                        ],
                      ),
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

  void _showActionsDialog(final CarsListModel car) {
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 450,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    height: 120,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: CachedNetworkImage(imageUrl: car.imageUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[900])),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 20,
                          right: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${car.make} ${car.model} ${car.variant}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('OCP: ₹${NumberFormat.decimalPattern('en_IN').format(car.oneClickPrice)}', style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildActionButton(
                          icon: Icons.sell,
                          label: 'Mark as Sold',
                          color: AppColors.neonGreen,
                          onTap: () {
                            Get.back();
                            _showMarkSoldDialog(car);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          label: 'Remove Car',
                          color: Colors.redAccent,
                          onTap: () {
                            Get.back();
                            _showRemoveDialog(car);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14))),
            Icon(Icons.arrow_forward_ios, size: 16, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _showMarkSoldDialog(CarsListModel car) {
    final double currentOffer = otoBuyController.offerFor(car.id, car.otobuyOffer);
    final TextEditingController soldAtController = TextEditingController(text: currentOffer.round().toString());
    String? selectedDealerId;

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: otoBuyController.fetchDealers(),
              builder: (context, snapshot) {
                return Container(
                  width: 450,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2A).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mark as Sold', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(onTap: () => Get.back(), child: Icon(Icons.close, color: Colors.white54)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Current Offer: ₹${NumberFormat.decimalPattern("en_IN").format(currentOffer)}', style: TextStyle(color: AppColors.neonGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),
                      
                      // Dealer dropdown
                      Text('Select Dealer', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 8),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2))
                      else if (snapshot.hasError)
                        Text('Failed to load dealers', style: TextStyle(color: Colors.redAccent))
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1A1F2A),
                              hint: Text('Select dealer', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                              value: selectedDealerId,
                              items: (snapshot.data ?? []).map((dealer) {
                                final id = '${dealer['id']}';
                                final name = '${dealer['name'] ?? dealer['dealerName'] ?? 'Dealer'}';
                                return DropdownMenuItem<String>(value: id, child: Text(name, style: const TextStyle(color: Colors.white)));
                              }).toList(),
                              onChanged: (value) {
                                selectedDealerId = value;
                                (context as Element).markNeedsBuild();
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      
                      // Sold amount
                      Text('Sold Amount (₹)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: TextField(
                          controller: soldAtController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      GestureDetector(
                        onTap: () async {
                          if (selectedDealerId == null || selectedDealerId!.isEmpty) {
                            ToastWidget.show(context: Get.context!, title: 'Please select a dealer', type: ToastType.error);
                            return;
                          }
                          final rawText = soldAtController.text.trim();
                          if (rawText.isEmpty) {
                            ToastWidget.show(context: Get.context!, title: 'Please enter sold amount', type: ToastType.error);
                            return;
                          }
                          final double? soldAt = double.tryParse(rawText.replaceAll(',', ''));
                          if (soldAt == null || soldAt <= 0) {
                            ToastWidget.show(context: Get.context!, title: 'Enter a valid amount', type: ToastType.error);
                            return;
                          }
                          await otoBuyController.markCarAsSold(carId: car.id, soldTo: selectedDealerId!, soldAt: soldAt);
                          Get.back();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(color: AppColors.neonGreen, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Obx(() => otoBuyController.isMarkCarAsSoldButtonLoading.value
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : const Text('Mark as Sold', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15))),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(CarsListModel car) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remove Car', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => Get.back(), child: Icon(Icons.close, color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Reason for removal', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: reasonController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter reason...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                            child: Center(child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7)))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (reasonController.text.trim().isEmpty) {
                              ToastWidget.show(context: Get.context!, title: 'Please enter a reason', type: ToastType.error);
                              return;
                            }
                            otoBuyController.reasonText.value = reasonController.text;
                            await otoBuyController.removeCar(carId: car.id);
                            Get.back();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
