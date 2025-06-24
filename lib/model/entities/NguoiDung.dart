class NguoiDung {
  final int? maTaiKhoan;
  final String tenNguoiDung;
  final String gioiTinh;
  final String diaChi;
  final String soDienThoai;
  final String email;
  final bool? trangThai;

  NguoiDung({
    this.maTaiKhoan,
    required this.tenNguoiDung,
    required this.gioiTinh,
    required this.diaChi,
    required this.soDienThoai,
    required this.email,
    this.trangThai,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      maTaiKhoan: json['maTaiKhoan'] ?? json['MaTaiKhoan'],
      tenNguoiDung: json['tenNguoiDung'] ?? '',
      gioiTinh: json['gioiTinh'] ?? '',
      diaChi: json['diaChi'] ?? '',
      soDienThoai: json['soDienThoai'] ?? '',
      email: json['email'] ?? '',
      trangThai: json['trangThai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maTaiKhoan': maTaiKhoan,
      'tenNguoiDung': tenNguoiDung,
      'gioiTinh': gioiTinh,
      'diaChi': diaChi,
      'soDienThoai': soDienThoai,
      'email': email,
      'trangThai': trangThai ?? true,
    };
  }

  NguoiDung copyWith({
    int? maTaiKhoan,
    String? tenNguoiDung,
    String? gioiTinh,
    String? diaChi,
    String? soDienThoai,
    String? email,
    bool? trangThai,
  }) {
    return NguoiDung(
      maTaiKhoan: maTaiKhoan ?? this.maTaiKhoan,
      tenNguoiDung: tenNguoiDung ?? this.tenNguoiDung,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      diaChi: diaChi ?? this.diaChi,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      email: email ?? this.email,
      trangThai: trangThai ?? this.trangThai,
    );
  }

  // Helper method to get user ID from various possible key formats
  static String? getUserIdFromMap(Map<String, dynamic>? userInfo) {
    if (userInfo == null) return null;

    final possibleKeys = [
      'MaTaiKhoan',
      'maTaiKhoan',
      'id',
      'Id',
      'ID',
      'userId',
      'user_id',
      'mataikhoan',
    ];

    for (String key in possibleKeys) {
      if (userInfo.containsKey(key) && userInfo[key] != null) {
        return userInfo[key].toString();
      }
    }

    if (userInfo.containsKey('taiKhoan') && userInfo['taiKhoan'] is Map) {
      final taiKhoan = userInfo['taiKhoan'] as Map;
      for (String key in possibleKeys) {
        if (taiKhoan.containsKey(key) && taiKhoan[key] != null) {
          return taiKhoan[key].toString();
        }
      }
    }

    return null;
  }
}
