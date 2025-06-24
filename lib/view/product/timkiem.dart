import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vanphongpham/model/entities/sanPham.dart';
import 'package:vanphongpham/model/services/Giaodien_services.dart';
import 'package:vanphongpham/view/product/chitietsanpham.dart';
import '../../model/services/timkiemsp_service.dart';
import 'dart:async';

enum ViewType { grid, list }

enum SortType { relevant, priceAsc, priceDesc, newest }

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _showSuggestions = false;
  Timer? _debounceTimer;
  List<String> _recentSearches = [];

  // New state variables
  ViewType _currentViewType = ViewType.grid;
  SortType _currentSortType = SortType.relevant;
  String _sortDisplayText = 'Phù hợp nhất';

  static const Color primaryColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchFocusNode = FocusNode();

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SearchViewModel>(
          context,
          listen: false,
        ).searchProducts(widget.initialQuery!);
      });
    }

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });

    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadRecentSearches() {
    _recentSearches = ['Bút bi', 'Giấy A4', 'Bìa hồ sơ'];
  }

  void _saveRecentSearch(String query) {
    if (query.trim().isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      Provider.of<SearchViewModel>(
        context,
        listen: false,
      ).searchProducts(query);
      _saveRecentSearch(query);
      _searchFocusNode.unfocus();
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  List<SanPham> _getSortedProducts(List<SanPham> products) {
    List<SanPham> sortedProducts = List.from(products);

    switch (_currentSortType) {
      case SortType.priceAsc:
        sortedProducts.sort((a, b) => (a.gia ?? 0).compareTo(b.gia ?? 0));
        break;
      case SortType.priceDesc:
        sortedProducts.sort((a, b) => (b.gia ?? 0).compareTo(a.gia ?? 0));
        break;
      default:
        sortedProducts.sort(
          (a, b) => a.tenSanPham?.compareTo(b.tenSanPham ?? '') ?? 0,
        );
        break;
    }

    return sortedProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
        actions: [
          // View type toggle button
          IconButton(
            icon: Icon(
              _currentViewType == ViewType.grid
                  ? Icons.view_list
                  : Icons.grid_view,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _currentViewType = _currentViewType == ViewType.grid
                    ? ViewType.list
                    : ViewType.grid;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() {
            _showSuggestions = false;
          });
        },
        child: Consumer<SearchViewModel>(
          builder: (context, searchViewModel, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    if (searchViewModel.searchResults.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tìm thấy ${searchViewModel.searchResults.length} sản phẩm',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            InkWell(
                              onTap: _showSortBottomSheet,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sort,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _sortDisplayText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _buildSearchResults(searchViewModel)),
                  ],
                ),
                if (_showSuggestions) _buildSuggestionsList(searchViewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Consumer<SearchViewModel>(
      builder: (context, searchViewModel, child) {
        return TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            prefixIcon: const Icon(Icons.search, color: primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      searchViewModel.resetSearch();
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _showSuggestions = value.isNotEmpty && _searchFocusNode.hasFocus;
            });

            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              if (value.trim().isNotEmpty) {
                searchViewModel.generateSearchSuggestions(value);
              }
            });
          },
          onSubmitted: _performSearch,
        );
      },
    );
  }

  Widget _buildSuggestionsList(SearchViewModel searchViewModel) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            if (searchViewModel.searchSuggestions.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Gợi ý tìm kiếm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...searchViewModel.searchSuggestions
                  .take(3)
                  .map(
                    (suggestion) =>
                        _buildSuggestionItem(suggestion, Icons.search),
                  ),
            ],
            if (_recentSearches.isNotEmpty &&
                _searchController.text.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ..._recentSearches
                  .take(5)
                  .map((recent) => _buildSuggestionItem(recent, Icons.history)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(text, style: const TextStyle(fontSize: 14)),
      trailing: icon == Icons.history
          ? IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _recentSearches.remove(text);
                });
              },
            )
          : null,
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
    );
  }

  Widget _buildSearchResults(SearchViewModel searchViewModel) {
    if (searchViewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (searchViewModel.errorMessage != null) {
      return _buildErrorState(searchViewModel);
    }

    if (searchViewModel.searchResults.isEmpty &&
        _searchController.text.isNotEmpty) {
      return _buildEmptySearchState();
    }

    if (searchViewModel.searchResults.isEmpty &&
        _searchController.text.isEmpty) {
      return _buildInitialState();
    }

    final sortedProducts = _getSortedProducts(searchViewModel.searchResults);

    return _currentViewType == ViewType.grid
        ? _buildGridView(sortedProducts)
        : _buildListView(sortedProducts);
  }

  Widget _buildErrorState(SearchViewModel searchViewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            searchViewModel.errorMessage!,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _performSearch(_searchController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy sản phẩm nào',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thử tìm kiếm với từ khóa khác',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            children: ['Bút bi', 'Giấy A4', 'Bìa hồ sơ']
                .map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        _searchController.text = suggestion;
                        _performSearch(suggestion);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tìm kiếm sản phẩm',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Nhập từ khóa để bắt đầu tìm kiếm',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<SanPham> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildListView(List<SanPham> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductListItem(products[index]),
    );
  }

  Widget _buildProductCard(SanPham item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToProductDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildProductImage(item)),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        item.tenSanPham ?? 'Sản phẩm không tên',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.trangThai == 1
                                ? GiaodienServices.formatGia(item.gia)
                                : "Hết hàng",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: item.trangThai == 1
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        _buildFavoriteIcon(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(SanPham item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToProductDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildNetworkImage(item.hinhAnh),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tenSanPham ?? 'Sản phẩm không tên',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.trangThai == 1
                          ? GiaodienServices.formatGia(item.gia)
                          : "Hết hàng",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: item.trangThai == 1 ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildFavoriteIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(SanPham item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: _buildNetworkImage(item.hinhAnh),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              'Không có ảnh',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.favorite_border, size: 14, color: Colors.orange[600]),
    );
  }

  Future<void> _navigateToProductDetail(SanPham item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChiTietSanPham(product: item)),
    );

    if (result == 'added_to_cart') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm sản phẩm thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Bộ lọc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Expanded(
              child: Center(
                child: Text('Filter options will be implemented here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sắp xếp theo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSortOption('Giá: Thấp đến cao', SortType.priceAsc),
            _buildSortOption('Giá: Cao đến thấp', SortType.priceDesc),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, SortType sortType) {
    return ListTile(
      title: Text(title),
      trailing: _currentSortType == sortType
          ? const Icon(Icons.check, color: primaryColor)
          : null,
      onTap: () {
        setState(() {
          _currentSortType = sortType;
          _sortDisplayText = title;
        });
        Navigator.pop(context);
      },
    );
  }
}
