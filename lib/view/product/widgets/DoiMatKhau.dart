import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  final String userId;

  const ChangePasswordScreen({
    Key? key,
    required this.userId,
    required int maTaiKhoan,
  }) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          'https://localhost:7212/taiKhoan/DoiMatKhau/${widget.userId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'matKhauCu': _currentPasswordController.text,
          'matKhauMoi': _newPasswordController.text,
          'xacNhanMatKhau': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? 'Có lỗi xảy ra khi đổi mật khẩu');
      }
    } catch (e) {
      _showErrorDialog('Không thể kết nối đến server. Vui lòng thử lại sau.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Thành công'),
            ],
          ),
          content: const Text('Mật khẩu đã được thay đổi thành công!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Lỗi'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String? _validatePassword(String? value, {bool isConfirm = false}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (!isConfirm && value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    if (isConfirm && value != _newPasswordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: !showPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Đổi Mật Khẩu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.security, size: 64, color: Colors.blue.shade600),
                    const SizedBox(height: 16),
                    Text(
                      'Bảo mật tài khoản',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thay đổi mật khẩu để bảo vệ tài khoản của bạn',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Mật khẩu hiện tại',
                      hint: 'Nhập mật khẩu hiện tại',
                      showPassword: _showCurrentPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showCurrentPassword = !_showCurrentPassword;
                        });
                      },
                      validator: (value) => _validatePassword(value),
                    ),

                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'Mật khẩu mới',
                      hint: 'Nhập mật khẩu mới (ít nhất 6 ký tự)',
                      showPassword: _showNewPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                      validator: (value) => _validatePassword(value),
                    ),

                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu mới',
                      hint: 'Nhập lại mật khẩu mới',
                      showPassword: _showConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                      validator: (value) =>
                          _validatePassword(value, isConfirm: true),
                    ),

                    const SizedBox(height: 8),

                    // Password requirements
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yêu cầu mật khẩu:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement('Ít nhất 6 ký tự'),
                          _buildRequirement('Bao gồm chữ hoa và chữ thường'),
                          _buildRequirement('Có ít nhất một số'),
                          _buildRequirement('Có ít nhất một ký tự đặc biệt'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Đổi Mật Khẩu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }
}

// Model class cho request
class ChangePasswordRequest {
  final String matKhauCu;
  final String matKhauMoi;
  final String xacNhanMatKhau;

  ChangePasswordRequest({
    required this.matKhauCu,
    required this.matKhauMoi,
    required this.xacNhanMatKhau,
  });

  Map<String, dynamic> toJson() {
    return {
      'matKhauCu': matKhauCu,
      'matKhauMoi': matKhauMoi,
      'xacNhanMatKhau': xacNhanMatKhau,
    };
  }
}

// Service class cho API call
class AccountService {
  static const String baseUrl = 'https://localhost:7212';

  static Future<bool> changePassword(
    String userId,
    ChangePasswordRequest request,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/taiKhoan/DoiMatKhau/$userId'),
        headers: {
          'Content-Type': 'application/json',
          // Thêm authorization header nếu cần
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Không thể kết nối đến server: $e');
    }
  }
}
