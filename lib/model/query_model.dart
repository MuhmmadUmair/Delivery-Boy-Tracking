class QueryModel {
  final String nameTitle;
  final String purpose;
  final String location;
  final String createdAt;
  final String status;

  QueryModel({
    required this.nameTitle,
    required this.purpose,
    required this.location,
    required this.createdAt,
    required this.status,
  });

  factory QueryModel.fromJson(Map<String, dynamic> json) {
    return QueryModel(
      nameTitle: json['nameTitle'] ?? '',
      purpose: json['purpose'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
