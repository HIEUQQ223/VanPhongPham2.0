import 'package:flutter/foundation.dart';
import 'package:vanphongpham/model/entities/sanPham.dart';
import 'package:vanphongpham/model/services/Sanpham_services.dart';

class TrangChuViewModel extends ChangeNotifier {
  final SanPhamService _sanPhamService = SanPhamService();
  List<SanPham> _sanPhams = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SanPham> get sanPhams => _sanPhams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSanPhams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sanPhams = await _sanPhamService.fetchSanPhams();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
