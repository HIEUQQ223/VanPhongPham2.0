import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanphongpham/model/services/Giohang_services.dart';
import 'package:vanphongpham/view/user/DangNhap.dart';

class DangXuat {
  static Future<bool?> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Đăng xuất?'),
          ],
        ),
        content: Text('Bạn có muốn thoát không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              performLogout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Có', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<void> performLogout(BuildContext context) async {
    try {
      _clearCartData();
      await _clearAllUserData();
      _showSuccessAndNavigate(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static void _clearCartData() {
    GioHang().clearCart();
  }

  static Future<void> _clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'cart_items',
      'cart_count',
      'cart_total',
      'user_token',
      'user_id',
      'user_email',
      'user_name',
      'user_phone',
      'user_address',
      'favorite_products',
      'recent_searches',
      'order_history',
      'login_time',
      'last_activity',
    ];

    for (String key in keys) {
      await prefs.remove(key);
    }
  }

  static void _showSuccessAndNavigate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã đăng xuất thành công'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => DangNhap()),
      (route) => false,
    );
  }

  static Future<void> clearCartOnly(BuildContext context) async {
    final cartManager = GioHang();
    final itemCount = cartManager.cartItems.length;

    if (itemCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Giỏ hàng đã trống')));
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa giỏ hàng'),
        content: Text('Xóa tất cả $itemCount sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      cartManager.clearCart();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_items');
      await prefs.remove('cart_count');
      await prefs.remove('cart_total');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa $itemCount sản phẩm'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

extension LogoutHelper on BuildContext {
  Future<void> showLogout() async {
    await DangXuat.showLogoutDialog(this);
  }

  Future<void> clearCartOnly() async {
    await DangXuat.clearCartOnly(this);
  }
}
