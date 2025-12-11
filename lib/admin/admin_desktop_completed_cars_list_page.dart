import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_cars_list_controller.dart';
import 'package:otobix_crm/models/cars_list_model.dart';
import 'package:otobix_crm/network/api_service.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_urls.dart';
import 'package:otobix_crm/utils/global_functions.dart';
import 'package:otobix_crm/utils/hero_dialog_route.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/widgets/expanded_car_card_dialog.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';
import 'package:otobix_crm/admin/controller/admin_auction_completed_cars_list_controller.dart';
import 'dart:ui' as ui;

class AdminDesktopAuctionCompletedCarsListPage extends StatelessWidget {
  AdminDesktopAuctionCompletedCarsListPage({super.key});

  final AdminCarsListController carsListController = Get.find<AdminCarsListController>();
  final AdminAuctionCompletedCarsListController auctionCompletedController = Get.find<AdminAuctionCompletedCarsListController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Obx(() {
        if (auctionCompletedController.isLoading.value) {
          return _buildLoadingGrid();
        }
        final carsList = carsListController.searchCar(
          carsList: auctionCompletedController.filteredAuctionCompletedCarsList,
        );
        if (carsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No Completed Cars', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
              ],
            ),
          );
        }
        return _buildCarsGrid(carsList);
      }),
    );
  }

  Widget _buildCarsGrid(List<CarsListModel> carsList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 700) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.72,
          ),
          itemCount: carsList.length,
          itemBuilder: (context, index) {
            final car = carsList[index];
            return _buildCarCard(car, context);
          },
        );
      },
    );
  }

  Widget _buildCarCard(CarsListModel car, BuildContext context) {
    final String yearOfManufacture =
        '${GlobalFunctions.getFormattedDate(date: car.yearMonthOfManufacture, type: GlobalFunctions.year)} ';
    final heroTag = 'completed-car-${car.id}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          HeroDialogRoute(
            builder: (context) => ExpandedCarCardDialog(
              car: car,
              heroTag: heroTag,
              carType: 'completed',
              onAction: () => _showActionsDialog(car),
            ),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.01)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarImage(car),
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
                            _buildBottomRow(car),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarImage(CarsListModel car) {
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
              child: Center(child: CircularProgressIndicator(color: AppColors.neonGreen, strokeWidth: 2)),
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
        // Completed badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: Colors.black),
                SizedBox(width: 6),
                Text('COMPLETED', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
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
            Icon(icon, size: 14, color: AppColors.neonGreen.withOpacity(0.8)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(value, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow(CarsListModel car) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Highest Bid', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 2),
              Obx(() => Text('₹${NumberFormat.decimalPattern('en_IN').format(car.highestBid.value)}', style: TextStyle(fontSize: 18, color: AppColors.neonGreen, fontWeight: FontWeight.bold))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.neonGreen, AppColors.neonGreen.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.more_horiz, size: 16, color: Colors.black),
                SizedBox(width: 6),
                Text('Actions', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
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
                  // Header with car image
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
                              Obx(() => Text('Highest Bid: ₹${NumberFormat.decimalPattern('en_IN').format(car.highestBid.value)}', style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w600))),
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
                          icon: Icons.shopping_cart,
                          label: 'Move to OtoBuy',
                          color: Colors.blueAccent,
                          onTap: () => _moveToOtobuy(car),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.replay,
                          label: 'Make Live Again',
                          color: AppColors.neonGreen,
                          onTap: () {
                            Get.back();
                            _showMakeLiveDialog(car);
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

  Future<void> _moveToOtobuy(CarsListModel car) async {
    try {
      final body = {'carId': car.id};
      final response = await ApiService.post(endpoint: AppUrls.moveCarToOtobuy, body: body);
      if (response.statusCode == 200) {
        ToastWidget.show(context: Get.context!, title: 'Moved to OtoBuy', type: ToastType.success);
        Get.back();
      } else {
        ToastWidget.show(context: Get.context!, title: 'Failed to move', type: ToastType.error);
      }
    } catch (e) {
      ToastWidget.show(context: Get.context!, title: 'Something went wrong', type: ToastType.error);
    }
  }

  void _showMakeLiveDialog(CarsListModel car) {
    int durationHrs = (car.auctionDuration > 0) ? car.auctionDuration : 2;
    
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
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
                          const Text('Make Live Again', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(onTap: () => Get.back(), child: Icon(Icons.close, color: Colors.white54)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Duration picker
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: AppColors.neonGreen),
                            const SizedBox(width: 16),
                            Expanded(child: Text('Duration: $durationHrs hours', style: const TextStyle(color: Colors.white))),
                            GestureDetector(
                              onTap: () { if (durationHrs > 1) setState(() => durationHrs--); },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.remove, color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => durationHrs++),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.neonGreen, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add, color: Colors.black, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final now = DateTime.now();
                            final body = {
                              'carId': car.id,
                              'auctionStartTime': now.toUtc().toIso8601String(),
                              'auctionDuration': durationHrs,
                              'auctionEndTime': now.add(Duration(hours: durationHrs)).toUtc().toIso8601String(),
                              'auctionMode': 'makeLiveNow',
                            };
                            final response = await ApiService.post(endpoint: AppUrls.schedulAuction, body: body);
                            if (response.statusCode == 200) {
                              ToastWidget.show(context: Get.context!, title: 'Car is live now', type: ToastType.success);
                              Get.back();
                            } else {
                              ToastWidget.show(context: Get.context!, title: 'Failed to update', type: ToastType.error);
                            }
                          } catch (e) {
                            ToastWidget.show(context: Get.context!, title: 'Something went wrong', type: ToastType.error);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(color: AppColors.neonGreen, borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('Make Live Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))),
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
                            await auctionCompletedController.removeCar(carId: car.id);
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
