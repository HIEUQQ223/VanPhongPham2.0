import 'package:flutter/material.dart';

class TaiKhoanMenu extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onChangePasswordTap;
  final VoidCallback? onAddressTap;

  const TaiKhoanMenu({
    Key? key,
    this.onProfileTap,
    this.onLogoutTap,
    this.onChangePasswordTap,
    this.onAddressTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            iconColor: Colors.red.shade400,
            title: 'Hồ sơ cá nhân',
            subtitle: 'Quản lý thông tin cá nhân của bạn',
            onTap: onProfileTap,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock_outline,
            iconColor: Colors.blue.shade400,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu của tài khoản',
            onTap: onChangePasswordTap,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            iconColor: Colors.orange.shade400,
            title: 'Địa chỉ',
            subtitle: 'Quản lý địa chỉ giao hàng của bạn',
            onTap: onAddressTap,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            iconColor: Colors.grey.shade600,
            title: 'Đăng xuất',
            subtitle: 'Đăng xuất khỏi tài khoản hiện tại',
            showArrow: false,
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
