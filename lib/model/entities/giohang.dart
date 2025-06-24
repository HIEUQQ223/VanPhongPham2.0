
class gioHang {
  final int maGioHang;
  final int maSanPham;
  final String tenSP;
  int soLuong;
  final double gia;
  final String hinhAnh;

  gioHang({
    required this.maGioHang,
    required this.maSanPham,
    required this.tenSP,
    required this.soLuong,
    required this.gia,
    required this.hinhAnh});

  factory gioHang.fromJson(Map<String, dynamic> json) {
    return gioHang(
        maGioHang: json['maGioHang'],
        maSanPham: json['maSanPham'],
        tenSP: json['tenSanPham'],
        soLuong: json['soLuong'],
        gia: json['giaXuat'],
        hinhAnh: json['hinhAnh']);
  }
}
