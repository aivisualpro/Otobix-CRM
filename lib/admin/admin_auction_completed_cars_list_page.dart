import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_auction_completed_cars_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_cars_list_controller.dart';
import 'package:otobix_crm/models/cars_list_model.dart';
import 'package:otobix_crm/network/api_service.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_images.dart';
import 'package:otobix_crm/utils/app_urls.dart';
import 'package:otobix_crm/utils/global_functions.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/widgets/empty_data_widget.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'package:otobix_crm/widgets/tab_bar_widget.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';

class AdminAuctionCompletedCarsListPage extends StatelessWidget {
  AdminAuctionCompletedCarsListPage({super.key});

  // Main controller
  final AdminCarsListController carsListController =
      Get.find<AdminCarsListController>();

  // Current page controller
  final AdminAuctionCompletedCarsListController auctionCompletedController =
      Get.find<AdminAuctionCompletedCarsListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(() {
            if (auctionCompletedController.isLoading.value) {
              return _buildLoadingWidget();
            }

            final carsList = carsListController.searchCar(
              carsList:
                  auctionCompletedController.filteredAuctionCompletedCarsList,
            );

            if (carsList.isEmpty) {
              return Expanded(
                child: Center(
                  child: const EmptyDataWidget(
                    icon: Icons.local_car_wash,
                    message: 'No Auction Completed Cars',
                  ),
                ),
              );
            } else {
              return _buildAuctionCompletedCarsList(carsList);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildAuctionCompletedCarsList(List<CarsListModel> carsList) {
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: carsList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        itemBuilder: (context, index) {
          final car = carsList[index];
          return _buildCarCard(car);
        },
      ),
    );
  }

  Widget _buildCarCard(CarsListModel car) {
    final String yearMonthOfManufacture =
        '${GlobalFunctions.getFormattedDate(date: car.yearMonthOfManufacture, type: GlobalFunctions.year)} ';

    return GestureDetector(
      onTap: () => _showAuctionCompletedCarsBottomSheet(car),
      child: Card(
        elevation: 4,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: car.imageUrl,
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 80,
                                      width: 120,
                                      color:
                                          AppColors.grey.withValues(alpha: .3),
                                      child: const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: AppColors.green,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Image.asset(
                                        AppImages.carAlternateImage,
                                        width: 120,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$yearMonthOfManufacture${car.make} ${car.model} ${car.variant}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'HB: ',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Obx(
                                            () => Text(
                                              'Rs. ${NumberFormat.decimalPattern('en_IN').format(car.highestBid.value)}/-',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.green,
                                                fontWeight: FontWeight.bold,
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
                            const SizedBox(height: 5),
                            const Divider(),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconAndTextWidget(
                                      icon: Icons.calendar_today,
                                      text: GlobalFunctions.getFormattedDate(
                                            date: car.registrationDate,
                                            type: GlobalFunctions.monthYear,
                                          ) ??
                                          'N/A',
                                    ),
                                    _buildIconAndTextWidget(
                                      icon: Icons.numbers,
                                      text: car.appointmentId,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconAndTextWidget(
                                      icon: Icons.speed,
                                      text:
                                          '${NumberFormat.decimalPattern('en_IN').format(car.odometerReadingInKms)} km',
                                    ),
                                    _buildIconAndTextWidget(
                                      icon: Icons.location_on,
                                      text: car.inspectionLocation,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildIconAndTextWidget(
                                      icon: Icons.receipt_long,
                                      text: car.roadTaxValidity == 'LTT' ||
                                              car.roadTaxValidity == 'OTT'
                                          ? car.roadTaxValidity
                                          : GlobalFunctions.getFormattedDate(
                                                date: car.taxValidTill,
                                                type: GlobalFunctions.monthYear,
                                              ) ??
                                              'N/A',
                                    ),
                                    _buildIconAndTextWidget(
                                      icon: Icons.person,
                                      text: car.ownerSerialNumber == 1
                                          ? 'First Owner'
                                          : '${car.ownerSerialNumber} Owners',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet
  void _showAuctionCompletedCarsBottomSheet(final CarsListModel car) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.55,
          initialChildSize: 0.7,
          builder: (_, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return _buildBottomSheetContent(car);
              },
            );
          },
        );
      },
    );
  }

  // Bottom sheet content
  Widget _buildBottomSheetContent(final CarsListModel car) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Grab handle
        Center(
          child: Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: car.imageUrl,
                  width: 64,
                  height: 48,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.directions_car),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.make} ${car.model} ${car.variant}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'FMV: Rs. ${NumberFormat.decimalPattern('en_IN').format(car.priceDiscovery)}/-',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        Expanded(
          child: TabBarWidget(
            titles: const ['Move to Otobuy', 'Make Live Again', 'Remove Car'],
            counts: const [0, 0, 0],
            showCount: false,
            screens: [
              _buildMoveToOtobuyWidget(car),
              _buildMakeLiveWidget(car, Get.context!),
              _buildRemoveScreen(car),
            ],
            titleSize: 10,
            countSize: 0,
            spaceFromSides: 10,
            tabsHeight: 30,
          ),
        ),
      ],
    );
  }

  // Remove screen
  Widget _buildRemoveScreen(final CarsListModel car) {
    return GetX<AdminAuctionCompletedCarsListController>(
      builder: (completedController) {
        final canRemove =
            completedController.reasonText.value.trim().isNotEmpty &&
                !completedController.isRemoveButtonLoading.value;

        return Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason of Removal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: completedController.reasontextController,
                    maxLines: 3,
                    onChanged: (v) => completedController.reasonText.value = v,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Enter reason (required)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AbsorbPointer(
                          absorbing: !canRemove,
                          child: Opacity(
                            opacity: canRemove ? 1 : 0.6,
                            child: ButtonWidget(
                              text: 'Remove Car',
                              height: 40,
                              fontSize: 12,
                              isLoading:
                                  completedController.isRemoveButtonLoading,
                              onTap: () async {
                                final reason =
                                    completedController.reasonText.value.trim();

                                final ok = await Get.dialog<bool>(
                                      AlertDialog(
                                        title: const Text('Confirm removal'),
                                        content: Text(
                                          'Remove this car from live bids?\n\nReason:\n$reason',
                                        ),
                                        actions: [
                                          ButtonWidget(
                                            text: 'Cancel',
                                            height: 35,
                                            fontSize: 12,
                                            backgroundColor: AppColors.grey,
                                            isLoading: false.obs,
                                            onTap: () =>
                                                Get.back(result: false),
                                          ),
                                          ButtonWidget(
                                            text: 'Remove',
                                            height: 35,
                                            fontSize: 12,
                                            backgroundColor: AppColors.red,
                                            isLoading: false.obs,
                                            onTap: () => Get.back(result: true),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (!ok) return;

                                await completedController.removeCar(
                                  carId: car.id,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

// ===================== MAKE LIVE AGAIN (UI like screenshot + Set Margin) =====================
  Widget _buildMakeLiveWidget(CarsListModel car, BuildContext context) {
    int modeIndex = 0; // 0 = Go Live Now, 1 = Schedule, 2 = Set Margin

    final now = DateTime.now();
    DateTime startAt = (car.auctionStartTime ?? now);
    int durationHrs = (car.auctionDuration > 0) ? car.auctionDuration : 24;

    // margin (%)
    double marginPercentage = 0.0;

    DateTime getEnd(DateTime s, int h) => s.add(Duration(hours: h));

    // ---- colors (match screenshot vibe) ----
    const bgCard = Color(0xFF1E2430);
    const bgTile = Color(0xFF242B38);
    const orange = Color(0xFFFFA300);
    const textDim = Color(0xFFB8C0CC);

    String fmt(DateTime d) =>
        DateFormat('EEE, dd MMM yyyy • hh:mm a').format(d);

    Future<void> pickDateTime(StateSetter setState) async {
      final date = await showDatePicker(
        context: context,
        initialDate: startAt,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 2),
      );
      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startAt),
      );
      if (time == null) return;

      setState(() {
        startAt =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
      });
    }

    Future<void> submit() async {
      try {
        // ===== Set Margin =====
        if (modeIndex == 2) {
          if (marginPercentage <= 0) {
            ToastWidget.show(
              context: Get.context!,
              title: 'Please set margin',
              subtitle: 'Margin must be greater than 0%',
              type: ToastType.error,
            );
            return;
          }

          final body = {
            "carId": car.id,
            "marginPercentage": marginPercentage,
          };

          final res = await ApiService.post(
            endpoint: AppUrls.setMargin, // <-- apni API constant yahan
            body: body,
          );

          if (res.statusCode == 200) {
            ToastWidget.show(
              context: Get.context!,
              title: 'Margin set successfully',
              type: ToastType.success,
            );
            Get.back();
          } else {
            ToastWidget.show(
              context: Get.context!,
              title: 'Failed to set margin',
              type: ToastType.error,
            );
          }
          return;
        }

        // ===== Go Live / Schedule =====
        final start = (modeIndex == 0) ? DateTime.now() : startAt;
        final end = start.add(Duration(hours: durationHrs));

        final body = {
          "carId": car.id,
          "auctionStartTime": start.toUtc().toIso8601String(),
          "auctionDuration": durationHrs,
          "auctionEndTime": end.toUtc().toIso8601String(),
          "auctionMode": modeIndex == 0 ? "makeLiveNow" : "scheduledForLater",
        };

        final res = await ApiService.post(
          endpoint: AppUrls.schedulAuction,
          body: body,
        );

        if (res.statusCode == 200) {
          ToastWidget.show(
            context: Get.context!,
            title: modeIndex == 0 ? 'Car is live now' : 'Auction scheduled',
            type: ToastType.success,
          );
          Get.back();
        } else {
          ToastWidget.show(
            context: Get.context!,
            title: 'Failed to update',
            type: ToastType.error,
          );
        }
      } catch (e) {
        debugPrint(e.toString());
        ToastWidget.show(
          context: Get.context!,
          title: 'Something went wrong',
          type: ToastType.error,
        );
      }
    }

    Widget pillButton({
      required String text,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? orange : bgTile,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: selected ? Colors.white : textDim,
              ),
            ),
          ),
        ),
      );
    }

    Widget tile({
      required IconData icon,
      required String title,
      required String sub,
      Widget? trailing,
      VoidCallback? onTap,
      bool enabled = true,
    }) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgTile,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0x33222222),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: orange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: const TextStyle(
                        color: textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        final effectiveStart = (modeIndex == 0) ? now : startAt;
        final endAt = getEnd(effectiveStart, durationHrs);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== TOP 3 BUTTONS (this is the missing part in your UI) =====
              // Row(
              //   children: [
              //     // pillButton(
              //     //   text: "Go Live Now",
              //     //   selected: modeIndex == 0,
              //     //   onTap: () => setState(() => modeIndex = 0),
              //     // ),
              //     const SizedBox(width: 12),
              //     pillButton(
              //       text: "Schedule",
              //       selected: modeIndex == 1,
              //       onTap: () => setState(() => modeIndex = 1),
              //     ),
              //     const SizedBox(width: 12),
              //     pillButton(
              //       text: "Set Margin",
              //       selected: modeIndex == 2,
              //       onTap: () => setState(() => modeIndex = 2),
              //     ),
              //   ],
              // ),

              const SizedBox(height: 14),

              // ===== CONTENT =====
              if (modeIndex != 2) ...[
                tile(
                  icon: Icons.access_time,
                  title: modeIndex == 0 ? "Live start" : "Scheduled start",
                  sub: fmt(effectiveStart),
                  enabled: modeIndex == 1,
                  onTap: modeIndex == 1 ? () => pickDateTime(setState) : null,
                  trailing: Icon(
                    Icons.edit_calendar,
                    color: modeIndex == 1 ? textDim : Colors.transparent,
                  ),
                ),
                const SizedBox(height: 12),
                tile(
                  icon: Icons.timer,
                  title: "Duration (hours)",
                  sub: "$durationHrs hours",
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _miniBtn(
                        icon: Icons.remove,
                        onTap: () => setState(() {
                          if (durationHrs > 1) durationHrs--;
                        }),
                        bg: bgCard,
                        fg: textDim,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$durationHrs",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _miniBtn(
                        icon: Icons.add,
                        onTap: () => setState(() => durationHrs++),
                        bg: orange,
                        fg: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                tile(
                  icon: Icons.flag,
                  title: "Ends at",
                  sub: fmt(endAt),
                  trailing: const Icon(Icons.info_outline, color: textDim),
                  enabled: false,
                ),
              ] else ...[
                tile(
                  icon: Icons.percent,
                  title: "Margin (%)",
                  sub: "Profit margin for this car",
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _miniBtn(
                        icon: Icons.remove,
                        onTap: () => setState(() {
                          if (marginPercentage > 0) marginPercentage -= 0.5;
                        }),
                        bg: bgCard,
                        fg: textDim,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${marginPercentage.toStringAsFixed(1)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text("%",
                          style: TextStyle(
                            color: textDim,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 10),
                      _miniBtn(
                        icon: Icons.add,
                        onTap: () => setState(() => marginPercentage += 0.5),
                        bg: orange,
                        fg: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ===== BOTTOM BUTTONS =====
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: bgTile,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: textDim,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: submit,
                        child: Text(
                          modeIndex == 0
                              ? "Make Live Now"
                              : modeIndex == 1
                                  ? "Save Schedule"
                                  : "Set Margin",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// small square button (used in duration + margin)
  Widget _miniBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Color bg,
    required Color fg,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: fg),
      ),
    );
  }

  // Loading widget
  Widget _buildLoadingWidget() {
    return Expanded(
      child: ListView.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget(height: 160, borderRadius: 12),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerWidget(height: 14, width: 150),
                      SizedBox(height: 10),
                      ShimmerWidget(height: 12, width: 100),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          ShimmerWidget(height: 10, width: 60),
                          SizedBox(width: 10),
                          ShimmerWidget(height: 10, width: 80),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          ShimmerWidget(height: 10, width: 60),
                          SizedBox(width: 10),
                          ShimmerWidget(height: 10, width: 80),
                        ],
                      ),
                      SizedBox(height: 8),
                      ShimmerWidget(height: 10, width: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Icon and text widget
  Widget _buildIconAndTextWidget({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ===================== MOVE TO OTOBUY =====================
Widget _buildMoveToOtobuyWidget(CarsListModel car) {
  return _MoveToOtobuyTab(key: ValueKey('otobuy-${car.id}'), car: car);
}

class _MoveToOtobuyTab extends StatefulWidget {
  final CarsListModel car;
  const _MoveToOtobuyTab({super.key, required this.car});

  @override
  State<_MoveToOtobuyTab> createState() => _MoveToOtobuyTabState();
}

class _MoveToOtobuyTabState extends State<_MoveToOtobuyTab> {
  final TextEditingController priceCtrl = TextEditingController();
  final FocusNode priceFocus = FocusNode();
  final ScrollController scrollCtrl = ScrollController();
  final GlobalKey _fieldKey = GlobalKey();

  final AdminAuctionCompletedCarsListController auctionCompletedController =
      Get.find<AdminAuctionCompletedCarsListController>();

  double? selectedPrice;
  late final NumberFormat nf;
  late final List<int> suggested;

  @override
  void initState() {
    super.initState();
    nf = NumberFormat.decimalPattern('en_IN');
    final fmv = widget.car.priceDiscovery.toInt();

    suggested = (fmv <= 0)
        ? [100000, 150000, 200000, 250000]
        : [
            fmv,
            (fmv * 1.10).round(),
            (fmv * 1.20).round(),
            (fmv * 1.30).round(),
          ];

    priceFocus.addListener(() {
      if (priceFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), _scrollFieldIntoView);
      }
    });
  }

  @override
  void dispose() {
    priceCtrl.dispose();
    priceFocus.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollFieldIntoView() {
    final ctx = _fieldKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.2,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _selectChip(int v) {
    setState(() {
      selectedPrice = v.toDouble();
      priceCtrl.text = nf.format(v);
    });
    _scrollFieldIntoView();
  }

  void _onPriceChanged(String s) {
    final raw = s.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      selectedPrice = raw.isEmpty ? null : double.tryParse(raw);
    });
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: .2)),
          color: enabled ? Colors.white : Colors.grey.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: enabled ? AppColors.black : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        controller: scrollCtrl,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'One-click price',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: suggested.map((v) {
                final isSel = (selectedPrice?.round() == v);
                return GestureDetector(
                  onTap: () => _selectChip(v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.green.withValues(alpha: .1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSel
                            ? AppColors.green
                            : Colors.grey.withValues(alpha: .25),
                      ),
                    ),
                    child: Text(
                      'Rs. ${nf.format(v)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isSel ? AppColors.green : AppColors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _tile(
              icon: Icons.sell_outlined,
              title: 'Custom price',
              subtitle: selectedPrice == null
                  ? 'Enter amount'
                  : 'Selected: Rs. ${nf.format(selectedPrice!.round())}/-',
              trailing: SizedBox(
                key: _fieldKey,
                width: 160,
                child: TextField(
                  controller: priceCtrl,
                  focusNode: priceFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Rs.',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onTap: _scrollFieldIntoView,
                  onChanged: _onPriceChanged,
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: 'Move to Otobuy',
                    isLoading: false.obs,
                    onTap: () => auctionCompletedController.moveCarToOtobuy(
                      carId: widget.car.id,
                      oneClickPrice: selectedPrice?.round() ?? 0,
                    ),
                    height: 40,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
