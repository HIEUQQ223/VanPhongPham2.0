import 'package:flutter/material.dart';
import 'package:vanphongpham/model/services/Nguoidung_service.dart';
import 'package:vanphongpham/view/product/widgets/widget_bottomNavigationbar.dart';

class DangKyKhachHangPage extends StatefulWidget {
  @override
  _DangKyKhachHangPageState createState() => _DangKyKhachHangPageState();
}

class _DangKyKhachHangPageState extends State<DangKyKhachHangPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  final TextEditingController _soDienThoaiController = TextEditingController();
  String _gioiTinh = 'Nam';
  bool _isLoading = false;

  Future<void> _dangKy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await UserService.dangKy(
        tenNguoiDung: _tenController.text.trim(),
        email: _emailController.text.trim(),
        matKhau: _matKhauController.text,
        gioiTinh: _gioiTinh,
        soDienThoai: _soDienThoaiController.text.trim(),
      );

      _showResultDialog(
        isSuccess: result['success'] == true,
        message: result['message'] ?? 'Có lỗi xảy ra',
      );

      // Nếu đăng ký thành công, clear form
      if (result['success'] == true) {
        _clearForm();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _tenController.clear();
    _emailController.clear();
    _matKhauController.clear();
    _soDienThoaiController.clear();
    setState(() => _gioiTinh = 'Nam');
  }

  void _showResultDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSuccess ? "Thành công" : "Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tenController.dispose();
    _emailController.dispose();
    _matKhauController.dispose();
    _soDienThoaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng ký khách hàng"),
        backgroundColor: Colors.blue,
        centerTitle: true, // Căn giữa tiêu đề
        automaticallyImplyLeading: false, // Tắt nút quay lại
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Icon đăng ký person ở đầu
              Container(
                alignment: Alignment.center,
                width: 80,
                height: 80,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.app_registration,
                  size: 48, // giữ nguyên icon
                  color: Colors.blue,
                ),
              ),

              // Text chào mừng
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Text(
                      'Đăng ký tài khoản',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chào mừng bạn đến với Văn Phòng Phẩm',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _tenController,
                decoration: InputDecoration(
                  labelText: 'Tên người dùng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) =>
                    value?.trim().isEmpty == true ? 'Vui lòng nhập tên' : null,
                enabled: !_isLoading,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!)) {
                    return 'Định dạng email không hợp lệ';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _matKhauController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 8) {
                    return 'Mật khẩu tối thiểu 8 ký tự';
                  }
                  // Kiểm tra mật khẩu mạnh (như backend)
                  if (!RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                  ).hasMatch(value)) {
                    return 'Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gioiTinh,
                items: ['Nam', 'Nữ'].map((gioiTinh) {
                  return DropdownMenuItem(
                    value: gioiTinh,
                    child: Text(gioiTinh),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) => setState(() => _gioiTinh = value!),
                decoration: InputDecoration(
                  labelText: 'Giới tính',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _soDienThoaiController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.phone, color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value!)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _dangKy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang xử lý...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ĐĂNG KÝ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Đã có tài khoản? Đăng nhập',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 3),
    );
  }
}
