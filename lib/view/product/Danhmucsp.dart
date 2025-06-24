import 'package:flutter/material.dart' hide SearchBar;
import 'package:provider/provider.dart';
import 'package:vanphongpham/model/entities/danhmucsanpham.dart';
import 'package:vanphongpham/model/services/Giohang_services.dart';
import 'package:vanphongpham/model/services/Danhmucsanpham_services.dart';
import 'package:vanphongpham/model/services/Sanpham_services.dart';
import 'package:vanphongpham/model/services/timkiemsp_service.dart';
import 'package:vanphongpham/view/product/TrangChu.dart';
import 'package:vanphongpham/view/product/chitietsanpham.dart';
import 'package:vanphongpham/view/product/widgets/widget_bottomNavigationbar.dart';
import 'package:vanphongpham/model/entities/sanPham.dart';
import 'package:vanphongpham/view/product/GioHang.dart';

// Widget để hiển thị chi tiết danh mục với sản phẩm
class DanhMucSanPham extends StatefulWidget {
  final int danhMucId; // Đổi thành int
  final String tenDanhMuc;

  const DanhMucSanPham({
    Key? key,
    required this.danhMucId,
    required this.tenDanhMuc,
  }) : super(key: key);

  @override
  _DanhMucSanPhamState createState() => _DanhMucSanPhamState();
}

class _DanhMucSanPhamState extends State<DanhMucSanPham> {
  List<SanPham> sanPhams = [];
  ChiTietDanhMuc? chiTietDanhMuc;
  bool isLoading = true;
  String? errorMessage;
  bool isGridView = true;

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
      final chiTiet = await DanhMucService.getChiTietDanhMuc(widget.danhMucId);

      setState(() {
        chiTietDanhMuc = chiTiet;
        sanPhams = chiTiet.sanPhams;
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
    return ChangeNotifierProvider.value(
      value: GioHang(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 235, 245, 246),
        appBar: AppBar(
          title: Text(widget.tenDanhMuc),
          backgroundColor: const Color.fromARGB(255, 4, 126, 240),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: isGridView
                  ? 'Chuyển sang dạng danh sách'
                  : 'Chuyển sang dạng lưới',
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
            ),
            Consumer<GioHang>(
              builder: (context, gioHang, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GioHangScreen(),
                          ),
                        );
                      },
                    ),
                    if (gioHang.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${gioHang.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 1),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Đang tải sản phẩm...',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChiTietDanhMuc,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (sanPhams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm nào trong danh mục này',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: _loadChiTietDanhMuc,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isGridView
            ? GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: sanPhams.length,
                itemBuilder: (context, index) {
                  final sp = sanPhams[index];
                  return ProductCard(
                    product: sp,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChiTietSanPham(product: sp),
                        ),
                      );
                    },
                  );
                },
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: sanPhams.length,
                itemBuilder: (context, index) {
                  final sp = sanPhams[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ProductCard(
                      product: sp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChiTietSanPham(product: sp),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class ChiTietDanhMucScreen extends StatefulWidget {
  const ChiTietDanhMucScreen({Key? key}) : super(key: key);

  @override
  _ChiTietDanhMucScreenState createState() => _ChiTietDanhMucScreenState();
}

class _ChiTietDanhMucScreenState extends State<ChiTietDanhMucScreen> {
  List<DanhMuc> danhMucs = [];
  List<SanPham> sanPhams = [];
  bool isLoading = true;
  String? errorMessage;
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadDanhMucs();
    _loadSanPhams();
  }

  Future<void> _loadDanhMucs() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await DanhMucService.getDanhSachDanhMuc();
      setState(() {
        danhMucs = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadSanPhams() async {
    try {
      final result = await SanPhamService().fetchSanPhams();
      setState(() {
        sanPhams = result;
      });
    } catch (e) {
      print('Lỗi tải sản phẩm: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GioHang(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 235, 245, 246),
        appBar: AppBar(
          title: const Text('Danh mục sản phẩm'),
          backgroundColor: const Color.fromARGB(255, 4, 126, 240),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: isGridView
                  ? 'Chuyển sang dạng danh sách'
                  : 'Chuyển sang dạng lưới',
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
            ),
            Consumer<GioHang>(
              builder: (context, gioHang, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GioHangScreen(),
                          ),
                        );
                      },
                    ),
                    if (gioHang.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${gioHang.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: widget_bottomNavigationbar(currentIndex: 1),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Đang tải danh mục...',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDanhMucs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.blue,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.red,
      onRefresh: () async {
        await _loadDanhMucs();
        await _loadSanPhams();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị danh mục
                isGridView
                    ? Column(
                        children: [
                          for (int i = 0; i < danhMucs.length; i += 4)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  for (
                                    int j = i;
                                    j < i + 4 && j < danhMucs.length;
                                    j++
                                  )
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        child: _buildDanhMucCard(danhMucs[j]),
                                      ),
                                    ),
                                  for (
                                    int k = 0;
                                    k <
                                        4 -
                                            (danhMucs.length - i > 4
                                                ? 4
                                                : danhMucs.length - i);
                                    k++
                                  )
                                    Expanded(child: Container()),
                                ],
                              ),
                            ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: danhMucs.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: _buildDanhMucCard(danhMucs[index]),
                          );
                        },
                      ),
                const SizedBox(height: 24),
                // Tiêu đề sản phẩm
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Sản phẩm nổi bật',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Danh sách sản phẩm
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: sanPhams.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Không có sản phẩm nào'),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final sp = sanPhams[index];
                      return ProductCard(
                        product: sp,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChiTietSanPham(product: sp),
                            ),
                          );
                        },
                      );
                    }, childCount: sanPhams.length),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryImage(String tenDanhMuc) {
    switch (tenDanhMuc) {
      case "Giấy In Ấn Pho-To":
        return {
          'url':
              'https://cdn.fast.vn/tmp/20211122100125-gia%CC%82%CC%81y-in-a%CC%82%CC%81n-photo.png',
          'color': Colors.blue[700],
        };
      case "Bìa-Kệ-Rổ":
        return {
          'url':
              'https://cdn.fast.vn/tmp/20211122100100-ro%CC%82%CC%89-bi%CC%80a-ke%CC%A3%CC%82.png',
          'color': Colors.green[600],
        };
      case "Đụng cụ văn phòng chất lượng ":
        return {
          'url':
              'https://product.hstatic.net/1000362139/product/b873cbea42dd9883c1cc_38defec9f1ef44269b3d0c64a9cb4369.jpg',
          'color': Colors.orange[600],
        };
      case "Sổ-Tập-Bao Thư":
        return {
          'url':
              'https://cdn.fast.vn/tmp/20211122101554-so%CC%82%CC%89-ta%CC%A3%CC%82p-bao-thu%CC%9B.png',
          'color': Colors.purple[600],
        };
      case "Bút mực chất lượng cao":
        return {
          'url':
              'https://cdn.fast.vn/tmp/20211122095941-bu%CC%81t-mu%CC%9B%CC%A3c-cha%CC%82%CC%81t-lu%CC%9Bo%CC%9B%CC%A3ng-cao.png',
          'color': Colors.red[600],
        };
      case "Băng keo - Dao- Kéo":
        return {
          'url':
              'https://cdn.fast.vn/tmp/20211122095756-ba%CC%86ng-keo-dao-ke%CC%81o.png',
          'color': Colors.teal[600],
        };
      default:
        return {
          'url': 'https://via.placeholder.com/150?text=Default',
          'color': Colors.grey[400],
        };
    }
  }

  Widget _buildDanhMucCard(DanhMuc danhMuc) {
    final categoryImage = _getCategoryImage(danhMuc.tenDanhMuc);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          // Điều hướng đến trang chi tiết danh mục với sản phẩm - sử dụng ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DanhMucSanPham(
                danhMucId: danhMuc.id, // Sử dụng ID của danh mục
                tenDanhMuc: danhMuc.tenDanhMuc,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  color: Colors.grey[50],
                ),
                child: danhMuc.hinhAnh != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Image.network(
                          danhMuc.hinhAnh!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultImage(danhMuc.tenDanhMuc);
                          },
                        ),
                      )
                    : _buildDefaultImage(danhMuc.tenDanhMuc),
              ),
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        categoryImage['url'],
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_outlined,
                            size: 16,
                            color: categoryImage['color'],
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          danhMuc.tenDanhMuc,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImage(String tenDanhMuc) {
    final categoryImage = _getCategoryImage(tenDanhMuc);
    return Container(
      height: 75,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        color: Colors.grey[100],
      ),
      child: Center(
        child: Image.network(
          categoryImage['url'],
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_outlined,
              size: 30,
              color: categoryImage['color'],
            );
          },
        ),
      ),
    );
  }
}
