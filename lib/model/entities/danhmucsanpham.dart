import 'package:vanphongpham/model/entities/sanPham.dart';

class DanhMuc {
  final int id;
  final String tenDanhMuc;
  final String? moTa;
  final String? hinhAnh;
  final String? xuatXu;

  DanhMuc({
    required this.id,
    required this.tenDanhMuc,
    this.moTa,
    this.hinhAnh,
    this.xuatXu,
  });

  factory DanhMuc.fromJson(Map<String, dynamic> json) {
    return DanhMuc(
      id: json['id'] ?? json['maDanhMuc'] ?? 0,
      tenDanhMuc: json['tenDanhMuc'] ?? '',
      moTa: json['moTa'],
      hinhAnh: json['hinhAnh'],
      xuatXu: json['xuatXu'],
    );
  }
}

class ChiTietDanhMuc {
  final DanhMuc danhMuc;
  final List<SanPham> sanPhams;

  ChiTietDanhMuc({required this.danhMuc, required this.sanPhams});

  factory ChiTietDanhMuc.fromJson(Map<String, dynamic> json) {
    return ChiTietDanhMuc(
      danhMuc: DanhMuc.fromJson(json['danhMuc']),
      sanPhams: (json['sanPhams'] as List)
          .map((item) => SanPham.fromJson(item))
          .toList(),
    );
  }
}
