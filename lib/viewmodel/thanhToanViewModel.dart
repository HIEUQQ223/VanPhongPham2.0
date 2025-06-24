import 'package:flutter/material.dart';
import 'package:vanphongpham/model/services/Giohang_services.dart';
import 'package:vanphongpham/model/services/thanhToan_services.dart';
import 'package:vanphongpham/view/payment/diachinha.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanphongpham/view/product/TrangChu.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ThanhToanViewModel with ChangeNotifier {
  final GioHang _cartManager = GioHang();
  String _selectedShippingMethod = 'standard';
  String _selectedPaymentMethod = 'cod';

  // Thông tin tài khoản
  int? _currentUserId;
  bool _isLoadingUser = true;

  // Thông tin địa chỉ
  String? _userName;
  String? _phoneNumber;
  String? _address;
  int? _maDiaChi;

  // Phí vận chuyển
  Map<String, Map<String, dynamic>> get shippingMethods {
    final DateTime now = DateTime.now();
    final DateTime startDelivery = now.add(Duration(days: 1));
    final DateTime endDelivery = now.add(Duration(days: 5));
    final DateFormat formatter = DateFormat('d MMMM', 'vi_VN');

    return {
      'standard': {
        'name': 'Quốc tế Tiêu chuẩn - Standard International',
        'price': 0,
        'description':
            'Đảm bảo nhận hàng từ ${formatter.format(startDelivery)} - ${formatter.format(endDelivery)}',
        'voucher':
            'Nhận Voucher nếu đơn hàng được giao đến bạn sau ngày ${formatter.format(endDelivery)}.',
        'isFree': true,
      },
    };
  }

  // Phương thức thanh toán
  final Map<String, Map<String, dynamic>> paymentMethods = {
    'cod': {
      'name': 'Thanh toán khi nhận hàng',
      'icon': Icons.money,
      'selected': true,
      'value': 1,
    },
    'momo': {
      'name': 'Momo',
      'icon': Icons.account_balance_wallet,
      'selected': false,
      'value': 2,
    },
  };

  int get shippingFee =>
      shippingMethods[_selectedShippingMethod]?['price'] ?? 0;
  double get totalPrice => _cartManager.getTotalPrice() + shippingFee;
  double get totalPriceFromCart => _cartManager.getTotalPrice();
  List<dynamic> get cartItems => _cartManager.cartItems;

  // Getters
  int? get currentUserId => _currentUserId;
  bool get isLoadingUser => _isLoadingUser;
  String? get userName => _userName;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;
  int? get maDiaChi => _maDiaChi;
  String get selectedShippingMethod => _selectedShippingMethod;
  String get selectedPaymentMethod => _selectedPaymentMethod;

  // Setters
  void setSelectedShippingMethod(String value) {
    _selectedShippingMethod = value;
    notifyListeners();
  }

  void setSelectedPaymentMethod(String value) {
    _selectedPaymentMethod = value;
    notifyListeners();
  }

  void setAddressData(Map<String, dynamic> addressData) {
    _userName = addressData['tenNguoiNhan'] as String?;
    _phoneNumber = addressData['soDienThoai'] as String?;
    _address = addressData['diaChiChiTiet'] as String?;
    _maDiaChi = addressData['maDiaChi'] as int?;
    notifyListeners();
  }

  // Constructor với tham số có tên
  ThanhToanViewModel({int? currentUserId}) {
    _currentUserId = currentUserId;
  }

  Future<void> initialize() async {
    await _initializeDateFormatting();
    await _loadUserData();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('vi_VN', null);
  }

  Future<void> _loadUserData() async {
    try {
      if (_currentUserId == null) {
        final prefs = await SharedPreferences.getInstance();
        _currentUserId = prefs.getInt('userId') ?? prefs.getInt('maTaiKhoan');
      }

      _isLoadingUser = false;

      if (_currentUserId == null || _currentUserId! <= 0) {
        _showLoginRequiredDialog();
      } else {
        // TODO: Lấy danh sách địa chỉ từ API hoặc local, nếu có thì lấy địa chỉ đầu tiên
        // Ví dụ giả lập:
        // final addresses = await fetchAddresses(_currentUserId!);
        // if (addresses.isNotEmpty) {
        //   setAddressData(addresses[0]);
        // }
      }
      notifyListeners();
    } catch (e) {
      _isLoadingUser = false;
      _showLoginRequiredDialog();
      notifyListeners();
    }
  }

  void _showLoginRequiredDialog() {
    // Giả lập dialog, cần context từ View
  }

  Future<void> createOrder(BuildContext context) async {
    if (_currentUserId == null || _maDiaChi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập và chọn địa chỉ giao hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentService = ThanhToanService();
    final cartItemsData = _cartManager.cartItems
        .map(
          (item) => {
            'maSanPham': item.product.maSanPham,
            'soLuong': item.quantity,
            'ghiChu': null,
          },
        )
        .toList();

    final response = await paymentService.createOrder(
      _currentUserId!,
      _maDiaChi,
      _selectedPaymentMethod,
      cartItemsData,
    );

    if (response.containsKey('message') &&
        (response['message'] as String).contains('thành công')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Đặt hàng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _cartManager.clearCart();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TrangChu()),
      );
    } else {
      print('Phản hồi lỗi: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['Message'] ?? 'Lỗi khi đặt hàng'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void navigateToAddressPage(BuildContext context) async {
    if (_currentUserId == null || _currentUserId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để xem địa chỉ giao hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaChiGiaoHang(
          maTaiKhoan: _currentUserId!,
          onAddressSelected: (dynamic addressData) {
            if (addressData is Map<String, dynamic>) {
              setAddressData(addressData);
            } else if (addressData is List && addressData.isNotEmpty) {
              if (addressData.first is Map<String, dynamic>) {
                setAddressData(addressData.first);
              }
            }
          },
        ),
      ),
    );

    if (result != null) {
      if (result is Map<String, dynamic>) {
        setAddressData(result);
      } else if (result is List && result.isNotEmpty) {
        if (result.first is Map<String, dynamic>) {
          setAddressData(result.first);
        }
      }
    }
  }
}
