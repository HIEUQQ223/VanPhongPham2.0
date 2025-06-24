import 'package:http/http.dart' as http;
import 'dart:convert';

class ThanhToanService {
  static const String baseUrl = 'https://localhost:7212/donHang';

  Future<Map<String, dynamic>> createOrder(
    int maTaiKhoan,
    int? maDiaChi,
    String selectedPaymentMethod,
    List<Map<String, dynamic>> cartItems,
  ) async {
    final String endpoint = '$baseUrl/Them/$maTaiKhoan';

    final orderData = {
      'maTaiKhoan': maTaiKhoan,
      'ngayDatHang': DateTime.now().toIso8601String(),
      'maKhuyenMai': null,
      'trangThaiDonHang': 1,
      'maDiaChi': maDiaChi,
      'hinhThucThanhToan': selectedPaymentMethod == 'cod' ? 1 : 2,
      'ghiChu': null,
      'chiTietDonHangs': cartItems,
    };

    print('Gửi yêu cầu đến $endpoint với dữ liệu: $orderData');
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      print('Phản hồi: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'Message':
              'Lỗi khi đặt hàng: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Lỗi: $e');
      return {'Message': 'Lỗi kết nối: $e'};
    }
  }
}
