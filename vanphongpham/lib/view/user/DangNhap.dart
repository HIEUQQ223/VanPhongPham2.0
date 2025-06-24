import 'package:flutter/material.dart';
import 'package:vanphongpham/model/services/GioHang.dart';
import 'package:vanphongpham/model/services/user_service.dart';
import 'package:vanphongpham/model/entities/gioHang.dart'; // Import GioHang
import 'package:vanphongpham/view/product/TrangChu.dart';
import 'package:vanphongpham/view/product/widgets/widget_bottomNavigationbar.dart';
import 'package:vanphongpham/view/user/DangKy.dart';
import 'package:vanphongpham/view/user/Quenmatkhau.dart';

class DangNhap extends StatefulWidget {
  @override
  _DangNhapState createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _loginUsernameController =
      TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  bool _obscureLoginPassword = true;
  bool _isLoginLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() => _isLoginLoading = true);
      try {
        final loginResult = await UserService.login(
          _loginUsernameController.text.trim(),
          _loginPasswordController.text.trim(),
        );
        if (loginResult['success'] == true) {
          // Reset giỏ hàng khi đăng nhập thành công
          String userId =
              loginResult['userId']?.toString() ??
              _loginUsernameController.text.trim();
          GioHang().onUserLogin(userId);

          _showSuccessDialog(loginResult['message'] ?? 'Đăng nhập thành công');
        } else {
          _showErrorDialog(loginResult['message'] ?? 'Đăng nhập thất bại');
        }
      } catch (e) {
        _showErrorDialog('Lỗi kết nối. Vui lòng thử lại sau');
      } finally {
        if (mounted) {
          setState(() => _isLoginLoading = false);
        }
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              "Đăng nhập thành công!",
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("Vào ứng dụng", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TrangChu()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.blue, size: 48),
            SizedBox(height: 16),
            Text("Có lỗi xảy ra", style: TextStyle(color: Colors.blue)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Đóng", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, size: 48, color: Colors.blue),
        ),
        SizedBox(height: 16),
        Text(
          "Đăng nhập tài khoản",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "Vui lòng nhập thông tin đăng nhập",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    required String? Function(String?) validator,
    Widget? suffixIcon,
    IconData? prefixIcon, // Added prefixIcon parameter
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.blue) // Add prefix icon with color
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _loginFormKey,
          child: Column(
            children: [
              _buildLoginHeader(),
              _buildTextField(
                controller: _loginUsernameController,
                label: "Email",
                prefixIcon: Icons.email, // Add email icon
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Tài khoản không được để trống";
                  }
                  if (value.trim().length < 3) {
                    return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _loginPasswordController,
                label: "Mật khẩu",
                obscure: _obscureLoginPassword,
                prefixIcon: Icons.lock, // Add lock icon for password
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLoginPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mật khẩu không được để trống";
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: TextButton(
              //     onPressed: () => Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => Quenmatkhau()),
              //     ),
              //     child: Text(
              //       "Quên mật khẩu?",
              //       style: TextStyle(color: Colors.blue),
              //     ),
              //   ),
              // ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoginLoading ? null : _handleLogin,
                  child: _isLoginLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Bạn chưa có tài khoản? "),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DangKyKhachHangPage(),
                      ),
                    ),
                    child: Text(
                      "Đăng ký",
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Đăng nhập"),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true, // Căn giữa tiêu đề
        automaticallyImplyLeading: false, // Ẩn icon back mặc định
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _buildLoginForm(),
      ),
      bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 3),
    );
  }
}
