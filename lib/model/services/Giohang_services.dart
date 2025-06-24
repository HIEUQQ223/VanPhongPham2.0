import 'package:flutter/material.dart';
import 'package:vanphongpham/model/entities/sanPham.dart';

class GioHang extends ChangeNotifier {
  static final GioHang _instance = GioHang._internal();
  factory GioHang() => _instance;
  GioHang._internal();

  final List<CartItem> _cartItems = [];
  String? _currentUserId; // Lưu trữ ID người dùng hiện tại

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(SanPham product) {
    int existingIndex = _cartItems.indexWhere(
      (item) => item.product.maSanPham == product.maSanPham,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Phương thức mới: Reset giỏ hàng khi người dùng đăng nhập
  void onUserLogin(String userId) {
    // Kiểm tra nếu người dùng khác đăng nhập
    if (_currentUserId != userId) {
      _currentUserId = userId;
      clearCart(); // Reset giỏ hàng
      print('Giỏ hàng đã được reset cho người dùng: $userId');
    }
  }

  // Phương thức để đăng xuất
  void onUserLogout() {
    _currentUserId = null;
    clearCart(); // Reset giỏ hàng khi đăng xuất
    print('Người dùng đã đăng xuất, giỏ hàng đã được reset');
  }

  // Getter để lấy ID người dùng hiện tại
  String? get currentUserId => _currentUserId;

  double getTotalPrice() {
    return _cartItems.fold(
      0.0,
      (total, item) => total + (item.product.gia * item.quantity),
    );
  }

  int get itemCount => _cartItems.length;
}

// Model cho item trong giỏ hàng
class CartItem {
  final SanPham product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
