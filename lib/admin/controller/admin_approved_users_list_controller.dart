import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/models/user_model.dart';
import 'package:otobix_crm/network/api_service.dart';
import 'package:otobix_crm/network/socket_service.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/utils/app_urls.dart';
import 'package:otobix_crm/utils/socket_events.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';

class AdminApprovedUsersListController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingUpdateUserThroughAdmin = false.obs;
  RxBool isAssignKamLoading = false.obs;
  RxBool isRegisterLoading = false.obs;
  RxList<UserModel> approvedUsersList = <UserModel>[].obs;

  final formKey = GlobalKey<FormState>();
  final obscurePasswordText = true.obs;

  // Text Controllers for Add User Form - User Information
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  // Dropdowns
  final selectedRole = ''.obs;
  final selectedLocation =
      ''.obs; // Changed from TextEditingController to Observable
  final selectedEntityType = ''.obs;

  // Permissions - Multi-select
  final RxList<String> selectedPermissions = <String>[].obs;
  final List<String> availablePermissions = [
    'view_leads',
    'view_inspection',
    'view_price_discovery',
    'view_auction',
  ];

  // Text Controllers - Dealership Details
  final dealershipNameController = TextEditingController();

  // Text Controllers - Contact Information
  final primaryContactPersonController = TextEditingController();
  final primaryContactNumberController = TextEditingController();
  final secondaryContactPersonController = TextEditingController();
  final secondaryContactNumberController = TextEditingController();

  // Text Controllers - Address
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Text Controllers - Security
  final passwordController = TextEditingController();

  @override
  onInit() {
    super.onInit();
    fetchApprovedUsersList();
    listenToUpdatedUsersList();
  }

  @override
  void onClose() {
    // Dispose all text controllers
    userNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dealershipNameController.dispose();
    primaryContactPersonController.dispose();
    primaryContactNumberController.dispose();
    secondaryContactPersonController.dispose();
    secondaryContactNumberController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle permission selection
  void togglePermission(String permission) {
    if (selectedPermissions.contains(permission)) {
      selectedPermissions.remove(permission);
    } else {
      selectedPermissions.add(permission);
    }
  }

  // Check if permission is selected
  bool isPermissionSelected(String permission) {
    return selectedPermissions.contains(permission);
  }

  // Fetch Approved Users List
  Future<void> fetchApprovedUsersList() async {
    isLoading.value = true;

    try {
      final response = await ApiService.get(
        endpoint: AppUrls.approvedUsersList,
      );

      // Check for valid JSON response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> usersJson = data['users'] ?? [];

        approvedUsersList.value =
            usersJson.map((json) => UserModel.fromJson(json)).toList();
      } else {
        debugPrint("Error fetching approved users: ${response.body}");
        ToastWidget.show(
          context: Get.context!,
          title: "Error fetching approved users: ${response.statusCode}",
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint("Error fetching approved users: $e");
      ToastWidget.show(
        context: Get.context!,
        title: "Error fetching approved users",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update User Through Admin
  Future<void> updateUserThroughAdmin({
    required String userId,
    required String status,
    // required String password,
  }) async {
    isLoadingUpdateUserThroughAdmin.value = true;

    try {
      final response = await ApiService.put(
        endpoint: AppUrls.updateUserThroughAdmin(userId),
        body: {
          // 'password': password,
          'approvalStatus': status,
        },
      );

      // Check for valid JSON response
      if (response.statusCode == 200) {
        ToastWidget.show(
          context: Get.context!,
          title: "User updated successfully",
          type: ToastType.success,
        );
      } else if (response.statusCode == 404) {
        ToastWidget.show(
          context: Get.context!,
          title: "User not found",
          type: ToastType.error,
        );
      } else {
        debugPrint("Error updating user: ${response.body}");
        ToastWidget.show(
          context: Get.context!,
          title: "Error updating user.",
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint("Error updating user: $e");
      ToastWidget.show(
        context: Get.context!,
        title: "Error updating user.",
        type: ToastType.error,
      );
    } finally {
      isLoadingUpdateUserThroughAdmin.value = false;
    }
  }

  // Listen to updated users list
  void listenToUpdatedUsersList() {
    SocketService.instance.joinRoom(SocketEvents.adminHomeRoom);
    SocketService.instance.on(SocketEvents.updatedAdminHomeUsers, (data) {
      final List<dynamic> usersList = data['approvedUsersList'] ?? [];

      approvedUsersList.value =
          usersList.map((user) => UserModel.fromJson(user)).toList();
    });
  }

  // Assign / Unassign KAM to a dealer
  Future<void> assignKamToDealer({
    required String dealerId,
    String? kamId, // null or empty => unassign
  }) async {
    isAssignKamLoading.value = true;

    try {
      final body = <String, dynamic>{
        'dealerId': dealerId,
      };

      // If kamId is provided and not empty, include it.
      // If omitted, backend will unassign.
      if (kamId != null && kamId.isNotEmpty) {
        body['kamId'] = kamId;
      }

      final response = await ApiService.post(
        endpoint: AppUrls.assignKamToDealer,
        body: body,
      );

      if (response.statusCode == 200) {
        ToastWidget.show(
          context: Get.context!,
          title: (kamId == null || kamId.isEmpty)
              ? "KAM unassigned successfully"
              : "KAM assigned successfully",
          type: ToastType.success,
        );

        // If you don't fully trust sockets / want immediate UI update:
        // await fetchApprovedUsersList();
      } else if (response.statusCode == 404) {
        ToastWidget.show(
          context: Get.context!,
          title: "Dealer or KAM not found",
          type: ToastType.error,
        );
      } else {
        debugPrint("Error assigning KAM: ${response.body}");
        ToastWidget.show(
          context: Get.context!,
          title: "Error assigning KAM.",
          type: ToastType.error,
        );
      }
    } catch (e) {
      debugPrint("Error assigning KAM: $e");
      ToastWidget.show(
        context: Get.context!,
        title: "Error assigning KAM.",
        type: ToastType.error,
      );
    } finally {
      isAssignKamLoading.value = false;
    }
  }

  // Register New User
  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) {
      ToastWidget.show(
        context: Get.context!,
        title: "Please fill all required fields",
        type: ToastType.error,
      );
      return;
    }

    isRegisterLoading.value = true;

    try {
      // Build address list
      final addressList = [
        {
          "addressLine1": addressLine1Controller.text.trim(),
          "addressLine2": addressLine2Controller.text.trim(),
          "city": cityController.text.trim(),
          "state": stateController.text.trim(),
          "pincode": pincodeController.text.trim(),
        }
      ];

      // Build the request body based on role
      final Map<String, dynamic> requestBody = {
        "userRole": selectedRole.value,
        "phoneNumber": phoneNumberController.text.trim(),
        "location": selectedLocation.value, // Using dropdown value
        "userName": userNameController.text.trim(),
        "email": emailController.text.trim(),
        "primaryContactPerson": primaryContactPersonController.text.trim(),
        "primaryContactNumber": primaryContactNumberController.text.trim(),
        "password": passwordController.text.trim(),
        "addressList": addressList,
        "permissions": selectedPermissions.toList(), // Add selected permissions
      };

      // Add secondary contact if provided
      if (secondaryContactPersonController.text.trim().isNotEmpty) {
        requestBody["secondaryContactPerson"] =
            secondaryContactPersonController.text.trim();
      }
      if (secondaryContactNumberController.text.trim().isNotEmpty) {
        requestBody["secondaryContactNumber"] =
            secondaryContactNumberController.text.trim();
      }

      // Add dealership details if role is dealer
      if (selectedRole.value.toLowerCase() == 'dealer') {
        requestBody["dealershipName"] = dealershipNameController.text.trim();
        requestBody["entityType"] = selectedEntityType.value;
      }

      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      // Make API call
      final response = await ApiService.post(
        endpoint: AppUrls.register,
        body: requestBody,
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        ToastWidget.show(
          context: Get.context!,
          title: "User registered successfully",
          type: ToastType.success,
        );

        // Clear form
        clearRegistrationForm();

        // Refresh the users list
        await fetchApprovedUsersList();

        // Close dialog
        Get.back();
      } else if (response.statusCode == 409) {
        // User already exists
        final data = jsonDecode(response.body);
        ToastWidget.show(
          context: Get.context!,
          title: data['message'] ?? "User already exists",
          type: ToastType.error,
        );
      } else if (response.statusCode == 400) {
        // Bad request
        final data = jsonDecode(response.body);
        ToastWidget.show(
          context: Get.context!,
          title: data['message'] ?? "Invalid data provided",
          type: ToastType.error,
        );
      } else {
        // Other errors
        debugPrint("Error registering user: ${response.body}");
        ToastWidget.show(
          context: Get.context!,
          title: "Error registering user. Please try again.",
          type: ToastType.error,
        );
        print("error body ${response.body}");
      }
    } catch (e) {
      debugPrint("Error registering user: $e");
      ToastWidget.show(
        context: Get.context!,
        title: "Error registering user. Please check your connection.",
        type: ToastType.error,
      );
      print("error with e $e");
    } finally {
      isRegisterLoading.value = false;
    }
  }

  // Clear registration form
  void clearRegistrationForm() {
    userNameController.clear();
    emailController.clear();
    phoneNumberController.clear();
    dealershipNameController.clear();
    primaryContactPersonController.clear();
    primaryContactNumberController.clear();
    secondaryContactPersonController.clear();
    secondaryContactNumberController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    passwordController.clear();
    selectedRole.value = '';
    selectedLocation.value = ''; // Clear location dropdown
    selectedEntityType.value = '';
    selectedPermissions.clear(); // Clear permissions
  }
}
