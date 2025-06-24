import 'package:http/http.dart' as http;
import 'package:vanphongpham/model/entities/NguoiDung.dart';
import 'dart:convert';

class NguoiDungService {
  static const String baseUrl = 'https://localhost:7212';
  static const Duration timeoutDuration = Duration(seconds: 15);
  static const int maxRetries = 3;

  // Validation methods
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(
      r'^(0|\+84)(3[2-9]|5[689]|7[06-9]|8[1-689]|9[0-46-9])[0-9]{7}$',
    ).hasMatch(phone);
  }

  // Update user information
  static Future<bool> updateUserInfo(NguoiDung nguoiDung) async {
    if (nguoiDung.maTaiKhoan == null) {
      throw Exception('Không tìm thấy ID người dùng');
    }

    final url = Uri.parse(
      '$baseUrl/Thongtinkhachhang/sua/${nguoiDung.maTaiKhoan}',
    );
    final requestBody = jsonEncode(nguoiDung.toJson());

    print("DEBUG - Sending request to: $url");
    print("DEBUG - Request body: $requestBody");

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await http
            .put(
              url,
              headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
              },
              body: requestBody,
            )
            .timeout(timeoutDuration);

        print("DEBUG - Response status: ${response.statusCode}");
        print("DEBUG - Response body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 204) {
          return true;
        } else {
          String errorMessage = _getErrorMessage(response.statusCode);
          throw Exception(errorMessage);
        }
      } catch (e) {
        attempt++;
        if (attempt == maxRetries) {
          throw e;
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return false;
  }

  static String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return "Dữ liệu không hợp lệ";
      case 401:
        return "Không có quyền truy cập";
      case 404:
        return "Không tìm thấy người dùng";
      case 500:
        return "Lỗi server nội bộ";
      default:
        return "Lỗi không xác định ($statusCode)";
    }
  }

  // Get user info (if needed for future implementation)
  static Future<NguoiDung?> getUserInfo(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/Thongtinkhachhang/$userId');
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return NguoiDung.fromJson(data);
      } else {
        throw Exception(_getErrorMessage(response.statusCode));
      }
    } catch (e) {
      print("DEBUG - Get user info error: $e");
      throw e;
    }
  }
  
}
