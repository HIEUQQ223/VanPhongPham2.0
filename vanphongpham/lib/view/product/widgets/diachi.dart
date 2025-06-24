import 'package:flutter/material.dart';

class DiaChiView extends StatelessWidget {
  final List<Map<String, String>> danhSachDiaChi = [
    {
      'ten': 'Huỳnh Trung Hiếu',
      'sdt': '(+84) 352 901 691',
      'diaChi':
          'SONG SONG NHÀ 122/27/56 Đường Tôn Đản\nPhường 10, Quận 4, TP. Hồ Chí Minh',
      'macDinh': 'true',
    },
    {
      'ten': 'Huỳnh Thành Phước',
      'sdt': '(+84) 385 433 122',
      'diaChi':
          'Số 216, Tổ 30 Ấp Bình Trung\nXã Bình Phước Xuân, Huyện Chợ Mới, An Giang',
      'macDinh': 'false',
    },
    {
      'ten': 'Huỳnh Trung Hiếu',
      'sdt': '(+84) 352 901 691',
      'diaChi': '630 Tổ 26, Ấp Đông\nXã Mỹ Hiệp, Huyện Chợ Mới, An Giang',
      'macDinh': 'false',
    },
    {
      'ten': 'DUY KHƯƠNG CÓ TIỀN',
      'sdt': '(+84) 767 898 594',
      'diaChi': '965 Huỳnh Tấn Phát\nPhường Phú Thuận, Quận 7, TP. Hồ Chí Minh',
      'macDinh': 'false',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Địa chỉ của Tôi'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: danhSachDiaChi.length,
              itemBuilder: (context, index) {
                final diaChi = danhSachDiaChi[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    title: Text(
                      diaChi['ten']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diaChi['sdt']!),
                        SizedBox(height: 4),
                        Text(diaChi['diaChi']!),
                        if (diaChi['macDinh'] == 'true')
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Mặc định',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // Xử lý khi thêm địa chỉ mới
              },
              icon: Icon(Icons.add, color: Colors.red),
              label: Text(
                'Thêm Địa Chỉ Mới',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
