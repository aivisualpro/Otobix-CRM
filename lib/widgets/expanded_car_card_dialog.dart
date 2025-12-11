import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/models/cars_list_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/global_functions.dart';

/// Expanded car card dialog that animates from the card using Hero animation.
/// This creates the "liquid expansion" effect when tapping on a car card.
class ExpandedCarCardDialog extends StatelessWidget {
  final CarsListModel car;
  final String heroTag;
  final String carType; // 'live', 'upcoming', 'completed', 'otobuy'
  final VoidCallback? onAction;

  const ExpandedCarCardDialog({
    super.key,
    required this.car,
    required this.heroTag,
    required this.carType,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: heroTag,
          createRectTween: (begin, end) {
            return MaterialRectCenterArcTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.transparent,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Container(
                width: 650,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2430).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCarImage(context),
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCarTitle(),
                              const SizedBox(height: 24),
                              _buildSpecsGrid(),
                              const SizedBox(height: 24),
                              Divider(color: Colors.white.withOpacity(0.08)),
                              const SizedBox(height: 24),
                              _buildPriceSection(),
                              const SizedBox(height: 28),
                              _buildActions(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarImage(BuildContext context) {
    final yearOfManufacture = GlobalFunctions.getFormattedDate(
      date: car.yearMonthOfManufacture,
      type: GlobalFunctions.year,
    ) ?? '';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (carType) {
      case 'live':
        statusColor = Colors.redAccent;
        statusText = 'LIVE AUCTION';
        statusIcon = Icons.live_tv;
        break;
      case 'upcoming':
        statusColor = Colors.orange;
        statusText = 'UPCOMING';
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = AppColors.neonGreen;
        statusText = 'COMPLETED';
        statusIcon = Icons.check_circle;
        break;
      case 'otobuy':
        statusColor = Colors.blueAccent;
        statusText = 'OTOBUY';
        statusIcon = Icons.shopping_cart;
        break;
      default:
        statusColor = AppColors.neonGreen;
        statusText = '';
        statusIcon = Icons.directions_car;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: CachedNetworkImage(
            imageUrl: car.imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.grey[800]!]),
              ),
              child: Center(
                child: CircularProgressIndicator(color: statusColor, strokeWidth: 2),
              ),
            ),
            errorWidget: (context, error, stackTrace) => Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.grey[800]!]),
              ),
              child: Center(child: Icon(Icons.directions_car, size: 60, color: Colors.grey[600])),
            ),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
        ),
        // Status badge
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Close button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        // Timer for live cars
        if (carType == 'live')
          Positioned(
            top: 16,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: AppColors.neonGreen),
                  const SizedBox(width: 6),
                  Obx(() => Text(
                    car.remainingAuctionTime.value,
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCarTitle() {
    final yearOfManufacture = GlobalFunctions.getFormattedDate(
      date: car.yearMonthOfManufacture,
      type: GlobalFunctions.year,
    ) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$yearOfManufacture ${car.make} ${car.model}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          car.variant,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _specChip(Icons.speed, '${NumberFormat.compact().format(car.odometerReadingInKms)} km'),
        _specChip(Icons.settings, car.commentsOnTransmission),
        _specChip(Icons.local_gas_station, car.fuelType.isNotEmpty ? car.fuelType : 'N/A'),
        _specChip(Icons.person, car.ownerSerialNumber == 1 ? '1st Owner' : '${car.ownerSerialNumber} Owners'),
        _specChip(Icons.location_on, car.inspectionLocation),
        _specChip(Icons.confirmation_number, 'ID: ${car.appointmentId}'),
      ],
    );
  }

  Widget _specChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.neonGreen.withOpacity(0.8)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    String priceLabel;
    double priceValue;
    Color priceColor;

    switch (carType) {
      case 'live':
      case 'completed':
        priceLabel = 'Highest Bid';
        priceValue = car.highestBid.value;
        priceColor = AppColors.neonGreen;
        break;
      case 'upcoming':
        priceLabel = 'FMV Price';
        priceValue = car.priceDiscovery.toDouble();
        priceColor = Colors.orange;
        break;
      case 'otobuy':
        priceLabel = 'One Click Price';
        priceValue = car.oneClickPrice.toDouble();
        priceColor = Colors.blueAccent;
        break;
      default:
        priceLabel = 'Price';
        priceValue = 0;
        priceColor = AppColors.neonGreen;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            priceColor.withOpacity(0.15),
            priceColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priceColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹${NumberFormat.decimalPattern('en_IN').format(priceValue)}',
                    style: TextStyle(
                      fontSize: 28,
                      color: priceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (carType == 'live')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: priceColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people, size: 18, color: priceColor),
                  const SizedBox(width: 8),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: priceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Center(
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              // Don't pop - let the action dialog show on top of this expanded dialog
              onAction?.call();
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.neonGreen, AppColors.neonGreen.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.more_horiz, size: 20, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Actions',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
