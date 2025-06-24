import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanphongpham/model/services/my_http_overrides.dart';

class UserService {
  static const String baseUrl = 'https://localhost:7212';

  // ==== Đăng ký tài khoản ====
  static Future<Map<String, dynamic>> dangKy({
    required String tenNguoiDung,
    required String email,
    required String matKhau,
    required String gioiTinh,
    required String soDienThoai,
  }) async {
    try {
      final body = {
        'tenNguoiDung': tenNguoiDung,
        'email': email,
        'matKhau': matKhau,
        'gioiTinh': gioiTinh,
        'soDienThoai': soDienThoai,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/dangKy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Đăng ký thành công!',
        };
      } else {
        // Xử lý lỗi từ backend
        String errorMessage = data['message'] ?? 'Đăng ký không thành công';

        // Nếu có danh sách errors từ backend, kết hợp chúng
        if (data['errors'] != null && data['errors'] is List) {
          List<String> errors = List<String>.from(data['errors']);
          if (errors.isNotEmpty) {
            errorMessage = errors.join('\n');
          }
        }

        return {
          'error': true,
          'message': errorMessage,
          'errors': data['errors'], // Trả về danh sách lỗi gốc nếu cần
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Không thể kết nối tới máy chủ. Vui lòng thử lại sau.',
      };
    }
  }

  // ==== Đăng nhập ====
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/taiKhoan/DangNhap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'matKhau': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveUserInfo(
          data['maLoaiTaiKhoan'].toString(),
          data['taiKhoan'],
        );
        return {
          'success': true,
          'message': data['message'] ?? 'Đăng nhập thành công',
          'maLoaiTaiKhoan': data['maLoaiTaiKhoan'],
          'taiKhoan': data['taiKhoan'],
        };
      }

      return {
        'error': true,
        'message': data['message'] ?? 'Sai email hoặc mật khẩu',
      };
    } catch (e) {
      return {
        'error': true,
        'message': 'Không thể kết nối tới máy chủ. Vui lòng thử lại sau.',
      };
    }
  }

  // ==== Lưu thông tin người dùng ====
  static Future<void> _saveUserInfo(
    String maLoaiTaiKhoan,
    Map<String, dynamic>? taiKhoan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('maLoaiTaiKhoan', maLoaiTaiKhoan);

    if (taiKhoan != null) {
      await prefs.setString('userInfo', jsonEncode(taiKhoan));
      await prefs.setString('email', taiKhoan['email'] ?? '');
      await prefs.setString('tenNguoiDung', taiKhoan['tenNguoiDung'] ?? '');
      await prefs.setString('gioiTinh', taiKhoan['gioiTinh'] ?? '');
      await prefs.setString('soDienThoai', taiKhoan['soDienThoai'] ?? '');
      await prefs.setInt('maLoaiTaiKhoan', taiKhoan['maLoaiTaiKhoan'] ?? 2);
      await prefs.setInt('maTaiKhoan', taiKhoan['maTaiKhoan'] ?? 0);
      await prefs.setBool('isLoggedIn', true);
    }
  }

  // ==== Lấy thông tin ====
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('userInfo');
    return str != null ? jsonDecode(str) : null;
  }

  static Future<String?> getEmail() async =>
      (await SharedPreferences.getInstance()).getString('email');
  static Future<String?> getTenNguoiDung() async =>
      (await SharedPreferences.getInstance()).getString('tenNguoiDung');
  static Future<String?> getGioiTinh() async =>
      (await SharedPreferences.getInstance()).getString('gioiTinh');
  static Future<String?> getSoDienThoai() async =>
      (await SharedPreferences.getInstance()).getString('soDienThoai');
  static Future<int?> getMaLoaiTaiKhoan() async =>
      (await SharedPreferences.getInstance()).getInt('maLoaiTaiKhoan');

  static Future<int?> getMaTaiKhoan() async =>
      (await SharedPreferences.getInstance()).getInt('maTaiKhoan');

  // ==== Trạng thái đăng nhập ====
  static Future<bool> isLoggedIn() async =>
      (await SharedPreferences.getInstance()).getBool('isLoggedIn') ?? false;

  // ==== Đăng xuất ====
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==== Kiểm tra kết nối mạng ====
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==== Validate ====
  static Map<String, String> validateLoginData({
    required String email,
    required String matKhau,
  }) {
    final errors = <String, String>{};
    if (email.trim().isEmpty) {
      errors['email'] = 'Email không được để trống';
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      errors['email'] = 'Định dạng email không hợp lệ';
    }

    if (matKhau.trim().isEmpty) {
      errors['matKhau'] = 'Mật khẩu không được để trống';
    }

    return errors;
  }

  static Map<String, String> validateRegisterData({
    required String tenNguoiDung,
    required String email,
    required String matKhau,
    required String soDienThoai,
  }) {
    final errors = <String, String>{};
    if (tenNguoiDung.trim().isEmpty)
      errors['tenNguoiDung'] = 'Tên người dùng không được để trống';
    if (email.trim().isEmpty) {
      errors['email'] = 'Email không được để trống';
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      errors['email'] = 'Định dạng email không hợp lệ';
    }
    if (matKhau.trim().isEmpty) {
      errors['matKhau'] = 'Mật khẩu không được để trống';
    } else if (matKhau.length < 8) {
      errors['matKhau'] = 'Mật khẩu tối thiểu 8 ký tự';
    }
    if (soDienThoai.trim().isEmpty) {
      errors['soDienThoai'] = 'Số điện thoại không được để trống';
    } else if (!RegExp(r'^[0-9]{10,11}$').hasMatch(soDienThoai)) {
      errors['soDienThoai'] = 'Số điện thoại không hợp lệ';
    }
    return errors;
  }

  // ==== Override SSL ====
  static void overrideHttp() {
    HttpOverrides.global = MyHttpOverrides();
  }
}
