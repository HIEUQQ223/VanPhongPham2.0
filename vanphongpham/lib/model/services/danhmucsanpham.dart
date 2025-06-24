import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanphongpham/model/entities/danhmucsanpham.dart';
import 'package:vanphongpham/model/entities/sanPham.dart';

class DanhMucService {
  static const String baseUrl = 'https://localhost:7212';

  // Lấy danh sách tất cả danh mục
  static Future<List<DanhMuc>> getDanhSachDanhMuc() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/danhMuc/danhSachDanhMuc'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DanhMuc.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy chi tiết danh mục và sản phẩm
  static Future<ChiTietDanhMuc> getChiTietDanhMuc(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/danhMuc/chiTietDanhMuc/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChiTietDanhMuc.fromJson(data);
      } else {
        throw Exception('Failed to load category details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy danh sách sản phẩm theo danh mục
  static Future<List<SanPham>> getSanPhamTheoDanhMuc(String danhMucId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sanpham/danhmuc/$danhMucId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => SanPham.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products by category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future fetchSanPhamsTheoDanhMuc(String danhMucId) async {}
}
