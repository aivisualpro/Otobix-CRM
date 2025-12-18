import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/models/staff_model.dart';
import 'package:otobix_crm/network/api_service.dart';
import 'package:otobix_crm/utils/app_urls.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';

class AdminStaffController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getAllStaff();
  }

  // ================= FORM =================
  final formKey = GlobalKey<FormState>();
  final staffNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  final RxString selectedRole = 'Lead'.obs;
  final RxString selectedLocation = ''.obs;
  final RxList<String> selectedPermissions = <String>[].obs;
  final RxBool isAddStaffLoading = false.obs;

  // ================= STAFF LIST =================
  final RxList<StaffModel> allStaff = <StaffModel>[].obs;
  final RxBool isLoading = false.obs;

  // ================= TABS =================
  final RxInt currentTabIndex = 0.obs; // 0 = Active, 1 = Inactive

  List<StaffModel> get displayedStaff {
    final isActiveTab = currentTabIndex.value == 0;
    return allStaff.where((staff) => staff.isActive == isActiveTab).toList();
  }

  RxInt get activeStaffCount => allStaff.where((e) => e.isActive).length.obs;
  RxInt get inactiveStaffCount => allStaff.where((e) => !e.isActive).length.obs;

  // ================= API CALL =================
  Future<void> getAllStaff() async {
    isLoading.value = true;
    try {
      final response = await ApiService.get(endpoint: AppUrls.allUsersList);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List users = decoded['users'] ?? [];
        final staffList = users
            .map((e) => StaffModel.fromJson(e))
            .where((e) => e.isStaff)
            .toList();
        allStaff.assignAll(staffList);
      } else {
        ToastWidget.show(
          context: Get.context!,
          title: "Failed to fetch staff",
          type: ToastType.error,
        );
      }
    } catch (e) {
      ToastWidget.show(
        context: Get.context!,
        title: "Something went wrong",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ADD STAFF =================
  Future<void> addStaff() async {
    if (!formKey.currentState!.validate() || selectedLocation.value.isEmpty) {
      ToastWidget.show(
        context: Get.context!,
        title: "Please fill all required fields",
        type: ToastType.error,
      );
      return;
    }

    isAddStaffLoading.value = true;

    try {
      final requestBody = {
        "userRole": selectedRole.value,
        "phoneNumber": phoneController.text.trim(),
        "isStaff": true,
        "location": selectedLocation.value,
        "userName": staffNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "permissions":
            _mapPermissionsToBackendFields(selectedPermissions.toList()),
        "addressList": [
          addressLine1Controller.text.trim(),
          addressLine2Controller.text.trim(),
        ],
      };

      final response = await ApiService.post(
        endpoint: AppUrls.register,
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        allStaff.add(StaffModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: staffNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          role: selectedRole.value,
          location: selectedLocation.value,
          isStaff: true,
          permissions: selectedPermissions.toList(),
          createdAt: DateTime.now(),
          image: '',
          assignedKam: '',
          addressList: [],
          approvalStatus: 'Pending',
        ));

        ToastWidget.show(
          context: Get.context!,
          title: "Staff added successfully",
          type: ToastType.success,
        );

        clearForm();
        Get.back();
      } else {
        final data = jsonDecode(response.body);
        ToastWidget.show(
          context: Get.context!,
          title: data['message'] ?? "Failed to add staff",
          type: ToastType.error,
        );
      }
    } catch (e) {
      ToastWidget.show(
        context: Get.context!,
        title: "Something went wrong",
        type: ToastType.error,
      );
    } finally {
      isAddStaffLoading.value = false;
    }
  }

  void clearForm() {
    staffNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    selectedPermissions.clear();
    selectedLocation.value = '';
    selectedRole.value = 'Staff';
  }

  List<String> _mapPermissionsToBackendFields(List<String> permissions) {
    final permissionMap = {
      'View Home': 'view_home',
      'View Admin': 'view_admin',
      'View Leads': 'view_leads',
      'View Inspection': 'view_inspection',
      'View Price Discovery': 'view_price_discovery',
      'View Auction': 'view_auction',
    };

    return permissions.map((p) => permissionMap[p] ?? '').toList();
  }

  @override
  void onClose() {
    staffNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}
