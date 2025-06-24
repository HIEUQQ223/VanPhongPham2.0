class SanPham {
  final int maSanPham;
  final String tenSanPham;
  final String hinhAnh;
  final double gia;
  final int soLuong;
  final String xuatXu;
  final String thuongHieu;
  final int trangThai;
  final String moTa;

  SanPham({
    required this.maSanPham,
    required this.tenSanPham,
    required this.hinhAnh,
    required this.gia,
    required this.soLuong,
    required this.xuatXu,
    required this.thuongHieu,
    required this.trangThai,
    required this.moTa,
  });

  // Getter để kiểm tra trạng thái hàng hóa
  bool get isOutOfStock => soLuong <= 0;

  // Getter để lấy text trạng thái hàng hóa
  String get stockStatus {
    if (soLuong <= 0) {
      return "Hết hàng";
    } else if (soLuong <= 5) {
      return "Sắp hết hàng";
    } else {
      return "Còn hàng";
    }
  }

  // Getter để lấy text hiển thị số lượng
  String get displayQuantity {
    return soLuong <= 0 ? "Hết hàng" : "Còn $soLuong sản phẩm";
  }

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      maSanPham: json['maSanPham'] is int ? json['maSanPham'] : 0,
      tenSanPham: json['tenSanPham'] is String ? json['tenSanPham'] : '',
      hinhAnh: json['hinhAnh'] is String ? json['hinhAnh'] : '',
      gia: (json['giaTien'] != null)
          ? (json['giaTien'] is int
                ? (json['giaTien'] as int).toDouble()
                : (json['giaTien'] is double ? json['giaTien'] : 0.0))
          : 0.0,
      soLuong: json['soLuong'] is int ? json['soLuong'] : 0,
      xuatXu: json['xuatXu'] is String ? json['xuatXu'] : '',
      thuongHieu: json['thuongHieu'] is String ? json['thuongHieu'] : '',
      trangThai: json['trangThai'] is int ? json['trangThai'] : 1,
      moTa: json['moTa'] is String ? json['moTa'] : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maSanPham': maSanPham,
      'tenSanPham': tenSanPham,
      'hinhAnh': hinhAnh,
      'giaTien': gia,
      'soLuong': soLuong,
      'xuatXu': xuatXu,
      'thuongHieu': thuongHieu,
      'trangThai': trangThai,
      'moTa': moTa,
    };
  }
}
