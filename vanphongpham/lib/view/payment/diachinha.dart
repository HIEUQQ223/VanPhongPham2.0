import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanphongpham/view/payment/Suadiachigiaohang.dart';
import 'package:vanphongpham/view/payment/Themdiachigiaohang.dart';
import 'package:vanphongpham/model/services/Diachigiaohang_services.dart';

class DiaChiGiaoHang extends StatelessWidget {
  final int maTaiKhoan;
  final Function(Map<String, dynamic>)? onAddressSelected;
  final Map<String, dynamic>? currentAddress;

  const DiaChiGiaoHang({
    Key? key,
    required this.maTaiKhoan,
    this.onAddressSelected,
    this.currentAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiaChiGiaoHangViewModel(
        maTaiKhoan: maTaiKhoan,
        currentAddressId: currentAddress?['id'],
      ),
      child: const _DiaChiGiaoHangBody(),
    );
  }
}

class _DiaChiGiaoHangBody extends StatelessWidget {
  const _DiaChiGiaoHangBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiaChiGiaoHangViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Chọn địa chỉ giao hàng',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color(0xFF3498DB),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Chọn địa chỉ để giao hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn có ${vm.addresses.length} địa chỉ đã lưu',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: vm.fetchAddresses,
              color: const Color(0xFF3498DB),
              child: _buildBody(context, vm),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ThemDiaChiPage(maTaiKhoan: vm.maTaiKhoan),
                    ),
                  );
                  if (result == true) {
                    vm.fetchAddresses();
                  }
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Thêm địa chỉ mới'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3498DB),
                  side: const BorderSide(color: Color(0xFF3498DB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DiaChiGiaoHangViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải danh sách địa chỉ...',
              style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.wifi_off,
                  size: 48,
                  color: Colors.red.shade300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Không thể tải dữ liệu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vm.errorMessage!,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: vm.fetchAddresses,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.addresses.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.addresses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildAddressCard(context, vm, vm.addresses[index]);
      },
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    DiaChiGiaoHangViewModel vm,
    Map<String, dynamic> address,
  ) {
    final bool isDefault = address['trangThai'] == true;
    final bool isSelected = vm.selectedAddressId == address['id'];

    return InkWell(
      onTap: () {
        vm.selectAddress(address);
        Navigator.pop(context, address);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF3498DB).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 2),
              spreadRadius: isSelected ? 1 : 0,
            ),
          ],
          border: isSelected
              ? Border.all(color: const Color(0xFF3498DB), width: 2)
              : isDefault
              ? Border.all(color: const Color(0xFF27AE60), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3498DB)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF3498DB)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                address['tenNguoiNhan'] ?? 'Không có tên',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF3498DB)
                                      : const Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27AE60),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              address['soDienThoai'] ?? 'Không có SĐT',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Nút sửa
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuaDiaChiPage(
                            maTaiKhoan: vm.maTaiKhoan,
                            diaChiId: address['maDiaChi'],
                            currentAddress: address,
                          ),
                        ),
                      );

                      // Xử lý kết quả trả về
                      if (result != null) {
                        if (result == 'deleted') {
                          // Xóa địa chỉ khỏi danh sách ngay lập tức
                          vm.removeAddressFromList(address['maDiaChi']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Địa chỉ đã được xóa khỏi danh sách'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF27AE60),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } else if (result == 'updated') {
                          // Làm mới danh sách khi cập nhật
                          vm.fetchAddresses();
                        }
                      }
                    },
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    color: const Color(0xFF3498DB),
                    tooltip: 'Sửa địa chỉ',
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3498DB).withOpacity(0.05)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3498DB).withOpacity(0.2)
                        : const Color(0xFFE9ECEF),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelected
                          ? const Color(0xFF3498DB)
                          : const Color(0xFFE74C3C),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address['diaChiChiTiet'] ?? 'Không có địa chỉ',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF2C3E50),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: const Color(0xFF3498DB),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bấm để chọn địa chỉ này',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
