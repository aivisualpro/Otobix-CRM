// lib/admin/controller/telecalling_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TelecallingController extends GetxController {
  // API URLs
  final String _baseUrl = 'https://otobix-app-backend-development.onrender.com';
  final String _getLeadsUrl = '/api/admin/leads/get-list';
  final String _addLeadUrl = '/api/admin/leads/add';
  final String _updateLeadUrl = '/api/admin/leads/update';
  final String _deleteLeadUrl = '/api/admin/leads/delete';

  // Rx Observables
  final RxList<Map<String, dynamic>> leads = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedPriorityFilter = ''.obs;
  final RxString selectedSourceFilter = ''.obs;
  final RxString selectedStatusFilter = ''.obs;

  // Filter options
  final List<String> priorityOptions = ['High', 'Medium', 'Low'];
  final List<String> sourceOptions = [
    'Reference',
    'Car Trade',
    'Website',
    'OLX',
    'Facebook Marketplace',
    'UCD',
    'NCD',
    'IE Generated Lead',
    'Data Calling',
    'Social Media Campaign',
    'Bank',
    'SMS/Whatsapp Blast',
    'Other',
    'PDI'
  ];
  final List<String> vehicleStatusOptions = [
    'Home Inspection',
    'Store Inspection',
    'NCD/UCD Stocked',
    'Test Drive Vehicle/Dealer Vehicle'
  ];
  final List<String> makeOptions = [
    'ASTON MARTIN',
    'AUDI',
    'BMW',
    'Chevrolet',
    'Citroen',
    'Daewoo',
    'Datsun',
    'Fiat',
    'Force Motors',
    'Ford',
    'Hindustan Motors',
    'Bentley',
    'BYD',
    'Ferrari',
    'ASHOK LEYLAND',
    'Chrysler',
    'Holden',
    'GMC',
    'Bugatti',
    'Cadillac',
    'Caterham'
  ];

  // Form controllers
  final TextEditingController carRegistrationNumberController =
      TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController carMakeModelVariantController =
      TextEditingController();
  final TextEditingController yearOfRegistrationController =
      TextEditingController();
  final TextEditingController ownershipSerialNumberController =
      TextEditingController();
  final TextEditingController yearOfManufactureController =
      TextEditingController();
  final TextEditingController odometerReadingController =
      TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController appointmentIdController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();
  final TextEditingController inspectionAddressController =
      TextEditingController();

  // Dropdown values
  final RxString selectedPriority = ''.obs;
  final RxString selectedSource = ''.obs;
  final RxString selectedMake = ''.obs;
  final RxString selectedVehicleStatus = ''.obs;

  // DateTime pickers
  final Rx<DateTime?> inspectionDateTime = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> inspectionTime = Rx<TimeOfDay?>(null);

  // Current editing lead
  final Rx<Map<String, dynamic>?> editingLead = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
  }

  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Fetch leads from API
  Future<void> fetchLeads() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl$_getLeadsUrl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          leads.assignAll(List<Map<String, dynamic>>.from(data['data'] ?? []));
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch leads');
        }
      } else {
        throw Exception('Failed to load leads: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add new lead
  Future<void> addLead() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate required fields
      if (selectedPriority.isEmpty ||
          selectedSource.isEmpty ||
          selectedMake.isEmpty ||
          selectedVehicleStatus.isEmpty ||
          yearOfManufactureController.text.isEmpty ||
          ownershipSerialNumberController.text.isEmpty ||
          ownerNameController.text.isEmpty ||
          contactNoController.text.isEmpty ||
          zipCodeController.text.isEmpty ||
          cityController.text.isEmpty) {
        throw Exception('Please fill all required fields');
      }

      // Prepare inspection datetime
      DateTime? inspectionDate;
      if (inspectionDateTime.value != null && inspectionTime.value != null) {
        inspectionDate = DateTime(
          inspectionDateTime.value!.year,
          inspectionDateTime.value!.month,
          inspectionDateTime.value!.day,
          inspectionTime.value!.hour,
          inspectionTime.value!.minute,
        );
      }

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final leadData = {
        "carRegistrationNumber": carRegistrationNumberController.text,
        "ownerName": ownerNameController.text,
        "carMakeModelVariant": carMakeModelVariantController.text,
        "yearOfRegistration": yearOfRegistrationController.text,
        "ownershipSerialNumber": ownershipSerialNumberController.text,
        "priority": selectedPriority.value,
        "source": selectedSource.value,
        "yearOfManufacture": yearOfManufactureController.text,
        "make": selectedMake.value,
        "vehicleStatus": selectedVehicleStatus.value,
        "contactNo": contactNoController.text,
        "zipCode": zipCodeController.text,
        "appointmentId": appointmentIdController.text.isEmpty
            ? 'APPT${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
            : appointmentIdController.text,
        "city": cityController.text,
        "odometerReadingInKms":
            int.tryParse(odometerReadingController.text) ?? 0,
        "additionalNotes": additionalNotesController.text,
        "carImages": [], // Empty array as per your requirement
        "inspectionDateTime": inspectionDate?.toIso8601String(),
        "inspectionAddress": inspectionAddressController.text,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_addLeadUrl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(leadData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.back(); // Close dialog
          Get.snackbar(
            'Success',
            'Lead added successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          clearForm();
          fetchLeads(); // Refresh list
        } else {
          throw Exception(data['message'] ?? 'Failed to add lead');
        }
      } else {
        throw Exception('Failed to add lead: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update lead
  Future<void> updateLead(String leadId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate required fields
      if (selectedPriority.isEmpty ||
          selectedSource.isEmpty ||
          selectedMake.isEmpty ||
          selectedVehicleStatus.isEmpty ||
          yearOfManufactureController.text.isEmpty ||
          ownershipSerialNumberController.text.isEmpty ||
          ownerNameController.text.isEmpty ||
          contactNoController.text.isEmpty ||
          zipCodeController.text.isEmpty ||
          cityController.text.isEmpty) {
        throw Exception('Please fill all required fields');
      }

      // Prepare inspection datetime
      DateTime? inspectionDate;
      if (inspectionDateTime.value != null && inspectionTime.value != null) {
        inspectionDate = DateTime(
          inspectionDateTime.value!.year,
          inspectionDateTime.value!.month,
          inspectionDateTime.value!.day,
          inspectionTime.value!.hour,
          inspectionTime.value!.minute,
        );
      }

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final leadData = {
        "id": leadId,
        "carRegistrationNumber": carRegistrationNumberController.text,
        "ownerName": ownerNameController.text,
        "carMakeModelVariant": carMakeModelVariantController.text,
        "yearOfRegistration": yearOfRegistrationController.text,
        "ownershipSerialNumber": ownershipSerialNumberController.text,
        "priority": selectedPriority.value,
        "source": selectedSource.value,
        "yearOfManufacture": yearOfManufactureController.text,
        "make": selectedMake.value,
        "vehicleStatus": selectedVehicleStatus.value,
        "contactNo": contactNoController.text,
        "zipCode": zipCodeController.text,
        "appointmentId": appointmentIdController.text,
        "city": cityController.text,
        "odometerReadingInKms":
            int.tryParse(odometerReadingController.text) ?? 0,
        "additionalNotes": additionalNotesController.text,
        "carImages": [], // Empty array as per your requirement
        "inspectionDateTime": inspectionDate?.toIso8601String(),
        "inspectionAddress": inspectionAddressController.text,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_updateLeadUrl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(leadData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.back(); // Close dialog
          Get.snackbar(
            'Success',
            'Lead updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          clearForm();
          fetchLeads(); // Refresh list
        } else {
          throw Exception(data['message'] ?? 'Failed to update lead');
        }
      } else {
        throw Exception('Failed to update lead: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete lead
  Future<void> deleteLead(String leadId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_deleteLeadUrl'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({"leadId": leadId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Get.back(); // Close confirmation dialog
          Get.snackbar(
            'Success',
            'Lead deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          fetchLeads(); // Refresh list
        } else {
          throw Exception(data['message'] ?? 'Failed to delete lead');
        }
      } else {
        throw Exception('Failed to delete lead: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load lead data into form for editing
  void loadLeadForEditing(Map<String, dynamic> lead) {
    editingLead.value = lead;

    // Fill form controllers
    carRegistrationNumberController.text = lead['carRegistrationNumber'] ?? '';
    ownerNameController.text = lead['ownerName'] ?? '';
    carMakeModelVariantController.text = lead['carMakeModelVariant'] ?? '';
    yearOfRegistrationController.text = lead['yearOfRegistration'] ?? '';
    ownershipSerialNumberController.text = lead['ownershipSerialNumber'] ?? '';
    yearOfManufactureController.text =
        lead['yearOfManufacture']?.toString() ?? '';
    odometerReadingController.text =
        lead['odometerReadingInKms']?.toString() ?? '';
    contactNoController.text = lead['contactNo'] ?? '';
    zipCodeController.text = lead['zipCode'] ?? '';
    appointmentIdController.text = lead['appointmentId'] ?? '';
    cityController.text = lead['city'] ?? '';
    additionalNotesController.text = lead['additionalNotes'] ?? '';
    inspectionAddressController.text = lead['inspectionAddress'] ?? '';

    // Set dropdown values
    selectedPriority.value = lead['priority'] ?? '';
    selectedSource.value = lead['source'] ?? '';
    selectedMake.value = lead['make'] ?? '';
    selectedVehicleStatus.value = lead['vehicleStatus'] ?? '';

    // Parse inspection datetime
    if (lead['inspectionDateTime'] != null) {
      try {
        final date = DateTime.parse(lead['inspectionDateTime']);
        inspectionDateTime.value = date;
        inspectionTime.value = TimeOfDay(hour: date.hour, minute: date.minute);
      } catch (e) {
        print('Error parsing inspection datetime: $e');
      }
    }
  }

  // Clear form
  void clearForm() {
    carRegistrationNumberController.clear();
    ownerNameController.clear();
    carMakeModelVariantController.clear();
    yearOfRegistrationController.clear();
    ownershipSerialNumberController.clear();
    yearOfManufactureController.clear();
    odometerReadingController.clear();
    contactNoController.clear();
    zipCodeController.clear();
    appointmentIdController.clear();
    cityController.clear();
    additionalNotesController.clear();
    inspectionAddressController.clear();

    selectedPriority.value = '';
    selectedSource.value = '';
    selectedMake.value = '';
    selectedVehicleStatus.value = '';

    inspectionDateTime.value = null;
    inspectionTime.value = null;
    editingLead.value = null;
  }

  // Get filtered leads
  List<Map<String, dynamic>> get filteredLeads {
    return leads.where((lead) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final matchesSearch = (lead['ownerName'] ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (lead['contactNo'] ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (lead['appointmentId'] ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (lead['carRegistrationNumber'] ?? '')
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
        if (!matchesSearch) return false;
      }

      // Priority filter
      if (selectedPriorityFilter.isNotEmpty &&
          (lead['priority'] ?? '') != selectedPriorityFilter.value) {
        return false;
      }

      // Source filter
      if (selectedSourceFilter.isNotEmpty &&
          (lead['source'] ?? '') != selectedSourceFilter.value) {
        return false;
      }

      // Status filter (using vehicleStatus as status)
      if (selectedStatusFilter.isNotEmpty &&
          (lead['vehicleStatus'] ?? '') != selectedStatusFilter.value) {
        return false;
      }

      return true;
    }).toList();
  }

  // Helper methods for UI
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Home Inspection':
        return Colors.blueAccent;
      case 'Store Inspection':
        return Colors.purpleAccent;
      case 'NCD/UCD Stocked':
        return Colors.tealAccent;
      case 'Test Drive Vehicle/Dealer Vehicle':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  Widget getStatusIcon(String status) {
    switch (status) {
      case 'Home Inspection':
        return Icon(Icons.home, size: 12, color: Colors.blueAccent);
      case 'Store Inspection':
        return Icon(Icons.store, size: 12, color: Colors.purpleAccent);
      case 'NCD/UCD Stocked':
        return Icon(Icons.inventory, size: 12, color: Colors.tealAccent);
      case 'Test Drive Vehicle/Dealer Vehicle':
        return Icon(Icons.directions_car, size: 12, color: Colors.amberAccent);
      default:
        return Icon(Icons.help, size: 12, color: Colors.grey);
    }
  }
}
