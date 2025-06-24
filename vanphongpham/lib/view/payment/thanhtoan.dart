import 'package:flutter/material.dart';
import 'package:vanphongpham/model/services/giaoDien_services.dart';
import 'package:vanphongpham/model/services/GioHang.dart';
import 'package:vanphongpham/view/payment/diachinha.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanphongpham/view/user/DangNhap.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ThanhToan extends StatefulWidget {
  final int? maTaiKhoan;

  const ThanhToan({Key? key, this.maTaiKhoan}) : super(key: key);

  @override
  _ThanhToanState createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  final GioHang _cartManager = GioHang();
  String selectedShippingMethod = 'standard';
  String selectedPaymentMethod = 'cod';

  // Thông tin tài khoản
  int? _currentUserId;
  bool _isLoadingUser = true;

  // Thông tin địa chỉ (nullable)
  String? userName;
  String? phoneNumber;
  String? address;

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
    },
    'momo': {
      'name': 'Momo',
      'icon': Icons.account_balance_wallet,
      'selected': false,
    },
  };

  int get shippingFee => shippingMethods[selectedShippingMethod]?['price'] ?? 0;
  double get totalPrice => _cartManager.getTotalPrice() + shippingFee;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadUserData();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('vi_VN', null);
  }

  Future<void> _loadUserData() async {
    try {
      int? userId = widget.maTaiKhoan;

      if (userId == null) {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getInt('userId') ?? prefs.getInt('maTaiKhoan');
      }

      setState(() {
        _currentUserId = userId;
        _isLoadingUser = false;
      });

      if (userId == null || userId <= 0) {
        _showLoginRequiredDialog();
      } else {
        // TODO: Lấy danh sách địa chỉ từ API hoặc local, nếu có thì lấy địa chỉ đầu tiên
        // Ví dụ giả lập:
        // final addresses = await fetchAddresses(userId);
        // if (addresses.isNotEmpty) {
        //   setState(() {
        //     userName = addresses[0]['tenNguoiNhan'];
        //     phoneNumber = addresses[0]['soDienThoai'];
        //     address = addresses[0]['diaChiChiTiet'];
        //   });
        // }
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      _showLoginRequiredDialog();
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text('Bạn cần đăng nhập để tiếp tục thanh toán.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quay lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DangNhap()),
              );
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFEE4D2D);
    const Color backgroundColor = Color(0xFFF5F5F5);

    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Thanh toán"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Thanh toán",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddressSection(),
            _buildProductList(),
            _buildShippingSection(),
            _buildPaymentSection(),
            _buildBottomPaymentSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final bool hasAddress =
        userName != null && phoneNumber != null && address != null;
    return InkWell(
      onTap: () => _navigateToAddressPage(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFFEE4D2D), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: hasAddress
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Địa chỉ nhận hàng",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "Thay đổi",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$userName | $phoneNumber",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Text(
                          "Chọn địa chỉ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _cartManager.cartItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _cartManager.cartItems[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.product.hinhAnh ?? 'https://via.placeholder.com/60',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.tenSanPham,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Đen không có khung",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            GiaodienServices.formatGia(item.product.gia),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFEE4D2D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "x${item.quantity}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShippingSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  "Phương thức vận chuyển",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Spacer(),
                const Text(
                  "Xem tất cả",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Miễn Phí",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shippingMethods[selectedShippingMethod]!['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      shippingMethods[selectedShippingMethod]!['isFree']
                          ? 'Miễn phí'
                          : GiaodienServices.formatGia(shippingFee as double),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFEE4D2D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  shippingMethods[selectedShippingMethod]!['description'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  shippingMethods[selectedShippingMethod]!['voucher'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Phương thức thanh toán",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...paymentMethods.entries.map((entry) {
            final key = entry.key;
            final method = entry.value;
            return RadioListTile<String>(
              value: key,
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
              title: Row(
                children: [
                  Icon(
                    method['icon'],
                    color: const Color(0xFFEE4D2D),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    method['name'],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              activeColor: const Color(0xFFEE4D2D),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng tiền hàng:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                GiaodienServices.formatGia(_cartManager.getTotalPrice()),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Phí vận chuyển:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                shippingFee == 0
                    ? 'Miễn phí'
                    : GiaodienServices.formatGia(shippingFee as double),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tổng thanh toán:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                GiaodienServices.formatGia(totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFEE4D2D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đặt hàng thành công!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE4D2D),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Đặt hàng",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddressPage() async {
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
          onAddressSelected: (selectedAddress) {
            setState(() {
              userName = selectedAddress['tenNguoiNhan'];
              phoneNumber = selectedAddress['soDienThoai'];
              address = selectedAddress['diaChiChiTiet'];
            });
          },
        ),
      ),
    );

    // Nếu result là danh sách địa chỉ, lấy địa chỉ đầu tiên
    if (result != null) {
      if (result is List && result.isNotEmpty) {
        final firstAddress = result.first;
        setState(() {
          userName = firstAddress['tenNguoiNhan'];
          phoneNumber = firstAddress['soDienThoai'];
          address = firstAddress['diaChiChiTiet'];
        });
      } else if (result is Map) {
        setState(() {
          userName = result['tenNguoiNhan'];
          phoneNumber = result['soDienThoai'];
          address = result['diaChiChiTiet'];
        });
      }
    }
  }
}
