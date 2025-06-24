import 'package:flutter/material.dart';
import 'package:vanphongpham/model/services/user_service.dart';
import 'package:vanphongpham/view/product/productwigets/Thoat.dart';
import 'package:vanphongpham/view/product/productwigets/thongtincainhan.dart';
import 'package:vanphongpham/view/product/widgets/widget_bottomNavigationbar.dart';
import 'package:vanphongpham/view/user/DangNhap.dart';
import 'productwigets/Thongtinhienthi.dart';
import 'productwigets/feature_shortcuts.dart';
import 'productwigets/TrangThaiDonHang.dart';
import 'productwigets/TaiKhoanMenu.dart';

class TaiKhoan extends StatefulWidget {
  const TaiKhoan({Key? key}) : super(key: key);

  @override
  _TaiKhoanState createState() => _TaiKhoanState();
}

class _TaiKhoanState extends State<TaiKhoan> with TickerProviderStateMixin {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userInfo;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLoginStatus();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await UserService.isLoggedIn();
      if (isLoggedIn) {
        final userInfo = await UserService.getUserInfo();
        setState(() {
          _isLoggedIn = true;
          _userInfo = userInfo;
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DangNhap()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DangNhap()),
        );
      }
    }
  }

  Future<void> _logout() async {
    final result = await DangXuat.showLogoutDialog(context);
    if (result == true) {
      await UserService.logout();
      setState(() {
        _isLoggedIn = false;
        _userInfo = null;
      });
      DangXuat.showLogoutSuccessDialog(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DangNhap()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Tài khoản',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_isLoggedIn)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              setState(() => _isLoading = true);
              _checkLoginStatus();
            },
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }
    return _isLoggedIn ? _buildLoggedInView() : SizedBox.shrink();
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Colors.blue.shade600,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Đang tải thông tin...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Thongtinhienthi(userInfo: _userInfo),
              _buildUpdateAccountAlert(),
              TrangThaiDonHang(),
              TaiKhoanMenu(
                onProfileTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThongTinCaNhanView(
                      userInfo: _userInfo,
                      onEditPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                onLogoutTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateAccountAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFEAEA),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn vui lòng cập nhật thông tin tài khoản.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThongTinCaNhanView(
                        userInfo: _userInfo,
                        onEditPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Cập nhật thông tin ngay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.blue.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
