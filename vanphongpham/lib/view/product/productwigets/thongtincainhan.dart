import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanphongpham/view/product/widgets/widget_bottomNavigationbar.dart';
import 'package:vanphongpham/viewmodel/ThongtincainhanViewModel.dart';

class ThongTinCaNhanView extends StatefulWidget {
  final Map<String, dynamic>? userInfo;
  final void Function() onEditPressed;
  // Thêm callback để refresh dữ liệu
  final Future<void> Function()? onRefreshData;

  const ThongTinCaNhanView({
    Key? key,
    this.userInfo,
    required this.onEditPressed,
    this.onRefreshData, // Thêm parameter này
  }) : super(key: key);

  @override
  State<ThongTinCaNhanView> createState() => _ThongTinCaNhanViewState();
}

class _ThongTinCaNhanViewState extends State<ThongTinCaNhanView> {
  late ThongTinCaNhanViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ThongTinCaNhanViewModel();
    viewModel.initializeUserInfo(widget.userInfo);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    TextEditingController controller,
    bool editable, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: editable
                ? Colors.orange.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: editable
              ? Colors.orange.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              editable
                  ? TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        hintText: 'Nhập ${label.toLowerCase()}',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      validator: validator,
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'Chưa cập nhật',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: controller.text.isNotEmpty
                              ? Colors.black87
                              : Colors.grey[500],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Đang cập nhật thông tin..."),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Cập nhật thông tin thành công"),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text("Lỗi: $message")),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Thử lại',
          textColor: Colors.white,
          onPressed: () => _handleSave(),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (viewModel.getUserId() == null) {
      _showErrorMessage(
        "Không tìm thấy ID người dùng. Vui lòng đăng nhập lại.",
      );
      return;
    }

    _showLoadingDialog();

    bool success = await viewModel.saveUserInfo();

    Navigator.of(context).pop(); // Close loading dialog

    if (success) {
      // Gọi callback để refresh dữ liệu từ parent
      if (widget.onRefreshData != null) {
        await widget.onRefreshData!();
      }

      widget.onEditPressed();
      _showSuccessMessage();

      // Force rebuild với dữ liệu mới
      setState(() {});
    } else {
      _showErrorMessage(viewModel.errorMessage ?? "Có lỗi xảy ra");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<ThongTinCaNhanViewModel>(
        builder: (context, vm, child) {
          if (widget.userInfo == null) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "Không có thông tin người dùng",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Quay lại"),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 3),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: vm.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.person_outline_rounded,
                            color: Colors.orange,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Thông tin cá nhân",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 32, color: Colors.grey[300]),
                      if (vm.getUserId() != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "ID: ${vm.getUserId()}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      _buildInfoRow(
                        Icons.badge_rounded,
                        "Họ tên",
                        vm.tenController,
                        vm.isEditing,
                        validator: vm.validateName,
                      ),
                      _buildInfoRow(
                        Icons.email_rounded,
                        "Email",
                        vm.emailController,
                        vm.isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: vm.validateEmail,
                      ),
                      _buildInfoRow(
                        Icons.phone_rounded,
                        "Điện thoại",
                        vm.sdtController,
                        vm.isEditing,
                        keyboardType: TextInputType.phone,
                        validator: vm.validatePhoneNumber,
                      ),
                      _buildInfoRow(
                        Icons.wc_rounded,
                        "Giới tính",
                        vm.gioiTinhController,
                        vm.isEditing,
                        validator: vm.validateGender,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (vm.isEditing) {
                                  _handleSave();
                                } else {
                                  vm.toggleEditing();
                                }
                              },
                              icon: Icon(
                                vm.isEditing ? Icons.save : Icons.edit,
                                size: 18,
                              ),
                              label: Text(
                                vm.isEditing
                                    ? "Lưu thông tin"
                                    : "Chỉnh sửa thông tin",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          if (vm.isEditing) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: vm.cancelEditing,
                              icon: const Icon(Icons.cancel, size: 18),
                              label: const Text("Hủy"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 3),
          );
        },
      ),
    );
  }
}
