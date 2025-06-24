import 'package:flutter/material.dart';

class Phimtat extends StatelessWidget {
  const Phimtat({Key? key}) : super(key: key);

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFeatureShortcut(
              icon: Icons.favorite,
              color: Colors.red.shade400,
              label: 'Yêu thích',
            ),
            _buildFeatureShortcut(
              icon: Icons.history,
              color: Colors.purple.shade400,
              label: 'Đã xem',
            ),
            _buildFeatureShortcut(
              icon: Icons.confirmation_number,
              color: Colors.amber.shade400,
              label: 'Voucher',
              badge: '16',
            ),
            _buildFeatureShortcut(
              icon: Icons.local_offer,
              color: Colors.green.shade400,
              label: 'Ưu đãi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureShortcut({
    required IconData icon,
    required Color color,
    required String label,
    String? badge,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            if (badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
