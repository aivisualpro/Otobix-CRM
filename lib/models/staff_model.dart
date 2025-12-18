class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String location;
  final bool isStaff;
  final List<dynamic> permissions;
  final DateTime createdAt;
  final String image;
  final String assignedKam;
  final List<dynamic> addressList;
  final String approvalStatus;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.location,
    required this.isStaff,
    required this.permissions,
    required this.createdAt,
    required this.image,
    required this.assignedKam,
    required this.addressList,
    required this.approvalStatus,
  });

  bool get isActive => approvalStatus.toLowerCase() == 'approved';

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['_id'] ?? '',
      name: json['userName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phoneNumber'] ?? '',
      role: json['userRole'] ?? '',
      location: json['location'] ?? '',
      isStaff: json['isStaff'] ?? false,
      permissions: json['permissions'] ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      image: json['image'] ?? '',
      assignedKam: json['assignedKam'] ?? '',
      addressList: json['addressList'] ?? [],
      approvalStatus: json['approvalStatus'] ?? '',
    );
  }
}
