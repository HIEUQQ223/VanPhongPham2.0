import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vanphongpham/model/entities/sanPham.dart';

class SearchViewModel extends ChangeNotifier {
  List<SanPham> _searchResults = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SanPham> get searchResults => _searchResults;
  List<String> get searchSuggestions => _searchSuggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String baseUrl = 'https://localhost:7212';

  // Tìm kiếm sản phẩm theo tên
  Future<void> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      _clearSearch();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/sanPham/timkiem/Ten?name=${Uri.encodeComponent(keyword)}',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );

        print('Parsed JSON Response: $jsonResponse');

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'] ?? [];
          print('Raw data from API: $data');

          if (data.isNotEmpty) {
            print('First item structure: ${data[0]}');
          }

          _searchResults = data.map((item) {
            print('Mapping item: $item');
            try {
              final sanPham = SanPham.fromJson(item);
              print(
                'Mapped SanPham: tenSanPham=${sanPham.tenSanPham}, trangThai=${sanPham.trangThai}, giaTien=${sanPham.gia}',
              );
              return sanPham;
            } catch (e) {
              print('Error mapping item: $e');
              print('Item causing error: $item');
              rethrow;
            }
          }).toList();

          print('Total mapped products: ${_searchResults.length}');
        } else {
          _searchResults = [];
          _errorMessage = jsonResponse['message'] ?? 'Không tìm thấy sản phẩm';
        }
      } else {
        _errorMessage = 'Lỗi kết nối: ${response.statusCode}';
        _searchResults = [];
      }
    } catch (e) {
      print('Search error: $e');
      _errorMessage = 'Lỗi: ${e.toString()}';
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  // Tạo gợi ý tìm kiếm dựa trên từ khóa
  void generateSearchSuggestions(String keyword) {
    if (keyword.trim().isEmpty) {
      _searchSuggestions = [];
      notifyListeners();
      return;
    }

    // Danh sách từ khóa mẫu - trong thực tế có thể lấy từ API hoặc database
    final List<String> sampleKeywords = [
      'bút',
      'bút bi',
      'bút chì',
      'bút máy',
      'bút gel',
      'bút lông',
      'bút dạ',
      'bút màu',
      'bút bi thiên long',
      'bút chì 2B',
      'bút chì 4B',
      'bút máy parker',
      'bút gel uni',
      'vở',
      'vở học sinh',
      'vở campus',
      'vở ô ly',
      'vở kẻ ngang',
      'thước',
      'thước kẻ',
      'thước đo',
      'máy tính',
      'máy tính casio',
      'máy tính bỏ túi',
      'sách',
      'sách giáo khoa',
      'sách tham khảo',
      'balo',
      'balo học sinh',
      'balo văn phòng',
    ];

    // Lọc gợi ý dựa trên từ khóa nhập vào
    _searchSuggestions = sampleKeywords
        .where(
          (suggestion) =>
              suggestion.toLowerCase().contains(keyword.toLowerCase()),
        )
        .take(10) // Giới hạn 10 gợi ý
        .toList();

    notifyListeners();
  }

  // Xóa kết quả tìm kiếm
  void _clearSearch() {
    _searchResults = [];
    _searchSuggestions = [];
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reset search
  void resetSearch() {
    _clearSearch();
  }
}
