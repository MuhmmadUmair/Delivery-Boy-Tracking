import 'package:firebase_google_apple_notif/app/data/response/status.dart';

class ApiResponse<T> {
  const ApiResponse.error(String message)
    : this._(status: Status.error, message: message);

  const ApiResponse.completed(T data)
    : this._(status: Status.completed, data: data);

  const ApiResponse.loading() : this._(status: Status.loading);

  const ApiResponse._({required this.status, this.data, this.message});

  final Status status;
  final T? data;
  final String? message;

  @override
  String toString() {
    return 'Status: $status\nMessage: $message\nData: $data';
  }
}
