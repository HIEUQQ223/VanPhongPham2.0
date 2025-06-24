import 'package:flutter/material.dart';
import 'package:vanphongpham/model/entities/NguoiDung.dart';
import 'package:vanphongpham/model/services/Suathongtin_services.dart';

class ThongTinCaNhanViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController tenController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sdtController = TextEditingController();
  final TextEditingController gioiTinhController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State
  bool _isEditing = false;
  bool _isLoading = false;
  NguoiDung? _nguoiDung;
  String? _errorMessage;

  // Getters
  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  NguoiDung? get nguoiDung => _nguoiDung;
  String? get errorMessage => _errorMessage;

  // Initialize with user info
  void initializeUserInfo(Map<String, dynamic>? userInfo) {
    if (userInfo != null) {
      _nguoiDung = NguoiDung.fromJson(userInfo);
      _updateControllers();
    }
    notifyListeners();
  }

  // Thêm method để cập nhật dữ liệu từ bên ngoài
  void updateUserInfo(Map<String, dynamic>? userInfo) {
    if (userInfo != null) {
      _nguoiDung = NguoiDung.fromJson(userInfo);
      _updateControllers();
      notifyListeners();
    }
  }

  void _updateControllers() {
    if (_nguoiDung != null) {
      tenController.text = _nguoiDung!.tenNguoiDung;
      emailController.text = _nguoiDung!.email;
      sdtController.text = _nguoiDung!.soDienThoai;
      gioiTinhController.text = _nguoiDung!.gioiTinh;
    }
  }

  // Get user ID
  String? getUserId() {
    return _nguoiDung?.maTaiKhoan?.toString();
  }

  // Toggle editing mode
  void toggleEditing() {
    _isEditing = !_isEditing;
    if (!_isEditing) {
      // Reset controllers when canceling edit
      _updateControllers();
    }
    notifyListeners();
  }

  // Cancel editing
  void cancelEditing() {
    _isEditing = false;
    _updateControllers();
    notifyListeners();
  }

  // Validation methods
  String? validateName(String? value) {
    return value?.trim().isEmpty == true ? 'Vui lòng nhập họ tên' : null;
  }

  String? validateEmail(String? value) {
    if (value?.trim().isEmpty == true) return 'Vui lòng nhập email';
    if (!NguoiDungService.isValidEmail(value!.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value?.trim().isNotEmpty == true &&
        !NguoiDungService.isValidPhoneNumber(value!.trim())) {
      return 'Số điện thoại không đúng định dạng';
    }
    return null;
  }

  String? validateGender(String? value) {
    return value?.trim().isEmpty == true ? 'Vui lòng nhập giới tính' : null;
  }

  // Save user information
  Future<bool> saveUserInfo() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (_nguoiDung?.maTaiKhoan == null) {
      _errorMessage = "Không tìm thấy ID người dùng. Vui lòng đăng nhập lại.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create updated user object
      final updatedUser = _nguoiDung!.copyWith(
        tenNguoiDung: tenController.text.trim(),
        email: emailController.text.trim(),
        soDienThoai: sdtController.text.trim(),
        gioiTinh: gioiTinhController.text.trim(),
      );

      // Call service to update
      bool success = await NguoiDungService.updateUserInfo(updatedUser);

      if (success) {
        // Cập nhật dữ liệu local ngay lập tức
        _nguoiDung = updatedUser;
        _isEditing = false;
        _isLoading = false;

        // Refresh lại controllers với dữ liệu mới
        _updateControllers();

        notifyListeners();
        return true;
      } else {
        _errorMessage = "Cập nhật thông tin thất bại";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUserInfo() async {
    if (_nguoiDung?.maTaiKhoan == null) return;

    try {
      final refreshedUser = await NguoiDungService.getUserInfo(
        _nguoiDung!.maTaiKhoan.toString(),
      );
      print("DEBUG - Refreshed user: ${refreshedUser?.toJson()}");

      if (refreshedUser != null) {
        _nguoiDung = refreshedUser;
        _updateControllers();
        notifyListeners();
      }
    } catch (e) {
      print("DEBUG - Error refreshing user info: $e");
      // Không cần throw error ở đây vì đã có dữ liệu local
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    tenController.dispose();
    emailController.dispose();
    sdtController.dispose();
    gioiTinhController.dispose();
    super.dispose();
  }
}
