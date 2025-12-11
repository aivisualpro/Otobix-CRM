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
import 'package:otobix_crm/admin/controller/admin_upcoming_cars_list_controller.dart';
import 'dart:ui' as ui;

class AdminDesktopUpcomingCarsListPage extends StatelessWidget {
  AdminDesktopUpcomingCarsListPage({super.key});

  final AdminCarsListController carsListController =
      Get.find<AdminCarsListController>();
  final AdminUpcomingCarsListController upcomingController =
      Get.find<AdminUpcomingCarsListController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Obx(() {
        if (upcomingController.isLoading.value) {
          return _buildLoadingGrid();
        }
        final carsList = carsListController.searchCar(
          carsList: upcomingController.filteredUpcomingCarsList,
        );
        if (carsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 80, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No Upcoming Cars', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
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
          itemBuilder: (context, index) => _buildCarCard(carsList[index], context),
        );
      },
    );
  }

  Widget _buildCarCard(CarsListModel car, BuildContext context) {
    final String yearOfManufacture =
        '${GlobalFunctions.getFormattedDate(date: car.yearMonthOfManufacture, type: GlobalFunctions.year)} ';
    final heroTag = 'upcoming-car-${car.id}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          HeroDialogRoute(
            builder: (context) => ExpandedCarCardDialog(
              car: car,
              heroTag: heroTag,
              carType: 'upcoming',
              onAction: () => _showAuctionDialog(car),
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
              child: Center(child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2)),
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
        // Upcoming badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                const Text('UPCOMING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
        ),
        // Go Live countdown
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: AppColors.neonGreen),
                const SizedBox(width: 4),
                Obx(() => Text(
                  upcomingController.remainingTimes[car.id] ?? "--",
                  style: TextStyle(color: AppColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                )),
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
            Icon(icon, size: 14, color: Colors.orange.withOpacity(0.8)),
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
              Text('FMV Price', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 2),
              Text('₹${NumberFormat.decimalPattern('en_IN').format(car.priceDiscovery)}', style: TextStyle(fontSize: 18, color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orange, Color(0xFFFF9800)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Schedule', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
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

  void _showAuctionDialog(final CarsListModel car) {
    int goLiveNowOrScheduleIndex = 0;
    DateTime now = DateTime.now();
    DateTime? startAt = (car.auctionStartTime ?? now);
    int durationHrs = (car.auctionDuration is int && car.auctionDuration > 0) ? car.auctionDuration : 2;

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
                DateTime getEnd(DateTime s, int h) => s.add(Duration(hours: h));
                final effectiveStart = (goLiveNowOrScheduleIndex == 0 ? now : startAt!);
                final endAt = getEnd(effectiveStart, durationHrs);
                String fmt(DateTime d) => DateFormat('EEE, dd MMM yyyy • hh:mm a').format(d.toLocal());

                Future<void> pickDateTime() async {
                  final date = await showDatePicker(context: context, initialDate: startAt!, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 2));
                  if (date == null) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(startAt!));
                  if (time == null) return;
                  startAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  setState(() {});
                }

                Future<void> submit() async {
                  try {
                    final DateTime currentTime = DateTime.now();
                    final DateTime auctionStartTimeLocal = (goLiveNowOrScheduleIndex == 0) ? currentTime : (startAt ?? currentTime);
                    final DateTime auctionEndTimeLocal = auctionStartTimeLocal.add(Duration(hours: durationHrs));
                    final body = {
                      'carId': car.id,
                      'auctionStartTime': auctionStartTimeLocal.toUtc().toIso8601String(),
                      'auctionDuration': durationHrs,
                      'auctionEndTime': auctionEndTimeLocal.toUtc().toIso8601String(),
                      'auctionMode': goLiveNowOrScheduleIndex == 0 ? 'makeLiveNow' : 'scheduledForLater',
                    };
                    final response = await ApiService.post(endpoint: AppUrls.schedulAuction, body: body);
                    if (response.statusCode == 200) {
                      ToastWidget.show(context: Get.context!, title: goLiveNowOrScheduleIndex == 0 ? 'Car is live now' : 'Auction scheduled', type: ToastType.success);
                      Get.back();
                    } else {
                      ToastWidget.show(context: Get.context!, title: 'Failed to update', type: ToastType.error);
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                    ToastWidget.show(context: Get.context!, title: 'Something went wrong', type: ToastType.error);
                  }
                }

                return Container(
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
                              right: 20,
                              child: Text('${car.make} ${car.model} ${car.variant}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mode switcher
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => goLiveNowOrScheduleIndex = 0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: goLiveNowOrScheduleIndex == 0 ? Colors.orange : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(child: Text('Go Live Now', style: TextStyle(color: goLiveNowOrScheduleIndex == 0 ? Colors.white : Colors.white54, fontWeight: FontWeight.w600))),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => goLiveNowOrScheduleIndex = 1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: goLiveNowOrScheduleIndex == 1 ? Colors.orange : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(child: Text('Schedule', style: TextStyle(color: goLiveNowOrScheduleIndex == 1 ? Colors.white : Colors.white54, fontWeight: FontWeight.w600))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Start time
                            _buildDialogTile(
                              icon: Icons.access_time,
                              title: goLiveNowOrScheduleIndex == 0 ? 'Live start' : 'Scheduled start',
                              subtitle: fmt(effectiveStart),
                              trailing: goLiveNowOrScheduleIndex == 1 ? Icons.edit_calendar : Icons.lock_clock,
                              enabled: goLiveNowOrScheduleIndex == 1,
                              onTap: goLiveNowOrScheduleIndex == 1 ? pickDateTime : null,
                            ),
                            const SizedBox(height: 12),
                            // Duration
                            _buildDurationTile(durationHrs, (val) => setState(() => durationHrs = val)),
                            const SizedBox(height: 12),
                            // End time
                            _buildDialogTile(icon: Icons.flag, title: 'Ends at', subtitle: fmt(endAt), trailing: Icons.info_outline, enabled: false),
                            const SizedBox(height: 24),
                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                                      child: Center(child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500))),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: submit,
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                                      child: Center(child: Text(goLiveNowOrScheduleIndex == 0 ? 'Make Live Now' : 'Save Schedule', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildDialogTile({required IconData icon, required String title, required String subtitle, required IconData trailing, bool enabled = true, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: enabled ? Colors.white : Colors.white54, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            Icon(trailing, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationTile(int durationHrs, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.timer, size: 20, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Duration (hours)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text('$durationHrs hour${durationHrs == 1 ? '' : 's'}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () { if (durationHrs > 1) onChanged(durationHrs - 1); },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.remove, color: Colors.white, size: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$durationHrs', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              GestureDetector(
                onTap: () => onChanged(durationHrs + 1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
