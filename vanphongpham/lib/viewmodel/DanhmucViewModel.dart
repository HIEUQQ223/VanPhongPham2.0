import 'package:flutter/material.dart';
import 'package:vanphongpham/model/entities/danhmucsanpham.dart';
import 'package:vanphongpham/model/entities/sanPham.dart';
import 'package:vanphongpham/model/services/danhmucsanpham.dart';

class ChiTietDanhMucViewModel extends StatefulWidget {
  final int danhMucId;

  ChiTietDanhMucViewModel({required this.danhMucId});

  @override
  _ChiTietDanhMucViewModelState createState() =>
      _ChiTietDanhMucViewModelState();
}

class _ChiTietDanhMucViewModelState extends State<ChiTietDanhMucViewModel> {
  ChiTietDanhMuc? chiTietDanhMuc;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChiTietDanhMuc();
  }

  Future<void> _loadChiTietDanhMuc() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await DanhMucService.getChiTietDanhMuc(widget.danhMucId);

      setState(() {
        chiTietDanhMuc = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chiTietDanhMuc?.danhMuc.tenDanhMuc ?? 'Chi Tiết Danh Mục'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue[600]),
            SizedBox(height: 16),
            Text('Đang tải sản phẩm...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChiTietDanhMuc,
              child: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (chiTietDanhMuc == null) {
      return Center(child: Text('Không có dữ liệu'));
    }

    return Column(
      children: [
        _buildDanhMucHeader(),
        Expanded(child: _buildSanPhamList()),
      ],
    );
  }

  Widget _buildDanhMucHeader() {
    final danhMuc = chiTietDanhMuc!.danhMuc;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            danhMuc.tenDanhMuc,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          if (danhMuc.moTa != null) ...[
            SizedBox(height: 8),
            Text(
              danhMuc.moTa!,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${chiTietDanhMuc!.sanPhams.length} sản phẩm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSanPhamList() {
    if (chiTietDanhMuc!.sanPhams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có sản phẩm nào',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChiTietDanhMuc,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: chiTietDanhMuc!.sanPhams.length,
        itemBuilder: (context, index) {
          return _buildSanPhamCard(chiTietDanhMuc!.sanPhams[index]);
        },
      ),
    );
  }

  Widget _buildSanPhamCard(SanPham sanPham) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: sanPham.hinhAnh != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        sanPham.hinhAnh!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultProductImage();
                        },
                      ),
                    )
                  : _buildDefaultProductImage(),
            ),
            SizedBox(width: 16),
            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sanPham.tenSanPham,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sanPham.thuongHieu != null) ...[
                    SizedBox(height: 4),
                    Text(
                      sanPham.thuongHieu!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${sanPham.gia.toStringAsFixed(0)}đ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sanPham.soLuong > 0
                              ? Colors.blue[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'SL: ${sanPham.soLuong}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: sanPham.soLuong > 0
                                ? Colors.blue[700]
                                : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (sanPham.moTa != null) ...[
                    SizedBox(height: 6),
                    Text(
                      sanPham.moTa!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProductImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [Colors.grey[100]!, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.inventory_2, size: 32, color: Colors.grey[500]),
      ),
    );
  }
}
