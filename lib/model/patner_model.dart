class PartnerModel {
  final String name;
  final String company;
  final String email;
  final String phone;
  final String location;
  final String status;
  final String appliedDate;

  PartnerModel({
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.location,
    required this.status,
    required this.appliedDate,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      name: json['name'],
      company: json['company'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      status: json['status'],
      appliedDate: json['applied_date'],
    );
  }
}
