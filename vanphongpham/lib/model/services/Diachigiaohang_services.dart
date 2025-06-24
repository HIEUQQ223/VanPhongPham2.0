import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiaChiGiaoHangViewModel extends ChangeNotifier {
  final int maTaiKhoan;
  final String baseUrl = 'https://localhost:7212';

  List<Map<String, dynamic>> addresses = [];
  bool isLoading = false;
  String? errorMessage;
  int? selectedAddressId;

  DiaChiGiaoHangViewModel({required this.maTaiKhoan, int? currentAddressId}) {
    selectedAddressId = currentAddressId;
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final url = '$baseUrl/diaChiGiaoHang/DanhSach/$maTaiKhoan';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: Không thể kết nối đến server');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          addresses = List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          errorMessage = data['message'] ?? 'Không thể tải dữ liệu';
        }
      } else if (response.statusCode == 404) {
        errorMessage =
            'API không tồn tại. Vui lòng kiểm tra server và URL API.';
      } else {
        errorMessage = 'Lỗi server: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Lỗi kết nối: ${e.toString()}';
    }
    isLoading = false;
    notifyListeners();
  }

  void selectAddress(Map<String, dynamic> address) {
    selectedAddressId = address['id'];
    notifyListeners();
  }

  // THÊM METHOD NÀY - Xóa địa chỉ khỏi danh sách ngay lập tức
  void removeAddressFromList(int diaChiId) {
    addresses.removeWhere((address) => address['maDiaChi'] == diaChiId);

    // Nếu địa chỉ bị xóa là địa chỉ đang được chọn, reset selectedAddressId
    if (selectedAddressId == diaChiId) {
      selectedAddressId = null;
    }

    notifyListeners();
  }

  // THÊM METHOD NÀY - Cập nhật thông tin địa chỉ trong danh sách
  void updateAddressInList(Map<String, dynamic> updatedAddress) {
    final index = addresses.indexWhere(
      (address) => address['maDiaChi'] == updatedAddress['maDiaChi'],
    );

    if (index != -1) {
      addresses[index] = updatedAddress;
      notifyListeners();
    }
  }
}

class AddressService {
  final String baseUrl = 'https://localhost:7212';

  Future<bool> updateAddress({
    required int diaChiId,
    required int maTaiKhoan,
    required String tenNguoiNhan,
    required String soDienThoai,
    required String diaChiChiTiet,
    required bool trangThai,
  }) async {
    try {
      final url = '$baseUrl/diaChiGiaoHang/Sua/$diaChiId';

      final requestData = {
        'maTaiKhoan': maTaiKhoan,
        'tenNguoiNhan': tenNguoiNhan.trim(),
        'soDienThoai': soDienThoai.trim(),
        'diaChiChiTiet': diaChiChiTiet.trim(),
        'trangThai': trangThai,
      };

      print('Updating address with data: $requestData');

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestData),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout: Không thể kết nối đến server');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error updating address: $e');
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  Future<bool> deleteAddress(int diaChiId) async {
    try {
      final url = '$baseUrl/diaChiGiaoHang/Xoa/$diaChiId';

      print('Deleting address with ID: $diaChiId');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout: Không thể kết nối đến server');
            },
          );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting address: $e');
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }
}

class DiaChiService {
  // URL API
  static const String apiUrl = 'https://localhost:7212/diaChiGiaoHang/Them';

  Future<Map<String, dynamic>> themDiaChiGiaoHang({
    required int maTaiKhoan,
    required String tenNguoiNhan,
    required String soDienThoai,
    required String diaChiChiTiet,
    required bool trangThai,
  }) async {
    try {
      final dto = {
        'MaTaiKhoan': maTaiKhoan,
        'TenNguoiNhan': tenNguoiNhan.trim(),
        'SoDienThoai': soDienThoai.trim(),
        'DiaChiChiTiet': diaChiChiTiet.trim(),
        'TrangThai': trangThai,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(dto),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Có lỗi xảy ra',
          'errors': responseData['errors'] != null
              ? List<String>.from(responseData['errors'])
              : [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối tới máy chủ',
        'errors': ['Vui lòng kiểm tra kết nối mạng'],
      };
    }
  }
}
