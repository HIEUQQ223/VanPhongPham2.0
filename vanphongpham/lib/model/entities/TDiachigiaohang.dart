class DTODiaChiGiaoHang {
  final int maTaiKhoan;
  final String tenNguoiNhan;
  final String soDienThoai;
  final String diaChiChiTiet;
  final bool trangThai;

  DTODiaChiGiaoHang({
    required this.maTaiKhoan,
    required this.tenNguoiNhan,
    required this.soDienThoai,
    required this.diaChiChiTiet,
    required this.trangThai,
  });

  Map<String, dynamic> toJson() {
    return {
      'MaTaiKhoan': maTaiKhoan,
      'TenNguoiNhan': tenNguoiNhan,
      'SoDienThoai': soDienThoai,
      'DiaChiChiTiet': diaChiChiTiet,
      'TrangThai': trangThai,
    };
  }
}
