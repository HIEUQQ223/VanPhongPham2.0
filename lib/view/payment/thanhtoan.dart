import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanphongpham/model/services/Giaodien_services.dart';
import 'package:vanphongpham/viewmodel/thanhToanViewModel.dart';

class ThanhToan extends StatefulWidget {
  final int? maTaiKhoan;

  const ThanhToan({Key? key, this.maTaiKhoan}) : super(key: key);

  @override
  _ThanhToanState createState() => _ThanhToanState();
}

class _ThanhToanState extends State<ThanhToan> {
  late ThanhToanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ThanhToanViewModel(currentUserId: widget.maTaiKhoan)
      ..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThanhToanViewModel>(
      create: (_) => _viewModel,
      child: Consumer<ThanhToanViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingUser) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
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
            backgroundColor: const Color(0xFFF5F5F5),
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
                  _buildAddressSection(viewModel),
                  _buildProductList(viewModel),
                  _buildShippingSection(viewModel),
                  _buildPaymentSection(viewModel),
                  _buildBottomPaymentSection(viewModel),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressSection(ThanhToanViewModel viewModel) {
    final bool hasAddress =
        viewModel.userName != null &&
        viewModel.phoneNumber != null &&
        viewModel.address != null;
    return InkWell(
      onTap: () => viewModel.navigateToAddressPage(context),
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
                          "${viewModel.userName} | ${viewModel.phoneNumber}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          viewModel.address!,
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

  Widget _buildProductList(ThanhToanViewModel viewModel) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewModel.cartItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = viewModel.cartItems[index];
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

  Widget _buildShippingSection(ThanhToanViewModel viewModel) {
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
                        viewModel.shippingMethods[viewModel
                            .selectedShippingMethod]!['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      viewModel.shippingMethods[viewModel
                              .selectedShippingMethod]!['isFree']
                          ? 'Miễn phí'
                          : GiaodienServices.formatGia(
                              viewModel.shippingFee as double,
                            ),
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
                  viewModel.shippingMethods[viewModel
                      .selectedShippingMethod]!['description'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.shippingMethods[viewModel
                      .selectedShippingMethod]!['voucher'],
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

  Widget _buildPaymentSection(ThanhToanViewModel viewModel) {
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
          ...viewModel.paymentMethods.entries.map((entry) {
            final key = entry.key;
            final method = entry.value;
            return RadioListTile<String>(
              value: key,
              groupValue: viewModel.selectedPaymentMethod,
              onChanged: (value) {
                viewModel.setSelectedPaymentMethod(value!);
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

  Widget _buildBottomPaymentSection(ThanhToanViewModel viewModel) {
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
                GiaodienServices.formatGia(viewModel.totalPriceFromCart),
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
                viewModel.shippingFee == 0
                    ? 'Miễn phí'
                    : GiaodienServices.formatGia(
                        viewModel.shippingFee as double,
                      ),
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
                GiaodienServices.formatGia(viewModel.totalPrice),
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
            onPressed: () => viewModel.createOrder(context),
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
}
