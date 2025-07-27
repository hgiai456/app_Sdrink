import 'package:app_selldrinks/components/product_item.dart';
import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/screens/prod_detail_screen.dart';
import 'package:app_selldrinks/services/product_service.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Product> _searchResults = [];
  List<String> _recentSearches = [
    'Cà phê',
    'Trà sữa',
    'Nước ép',
    'Smoothie',
    'Bánh ngọt',
  ];

  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';
  Timer? _debounceTimer;

  late AnimationController _animationController;
  late AnimationController _searchBarController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _searchBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchBarController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _searchBarController.forward();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final results = await ProductService.searchProducts(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      // Add to recent searches if not empty result
      if (results.isNotEmpty && !_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        });
      }

      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tìm kiếm: ${e.toString()}';
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        _performSearch(value);
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _errorMessage = '';
    });
    _focusNode.requestFocus();
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGray,
      body: SafeArea(
        child: Column(
          children: [_buildSearchHeader(), Expanded(child: _buildBody())],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: kDarkGray.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kLightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: kDarkGray,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const SizedBox(width: 12),

          // Search Field
          Expanded(
            child: AnimatedBuilder(
              animation: _searchBarAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_searchBarAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _searchBarAnimation.value,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: kLightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _focusNode.hasFocus
                                  ? kDarkGray
                                  : kMediumGray.withOpacity(0.3),
                          width: _focusNode.hasFocus ? 1 : 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        onSubmitted: _performSearch,
                        style: const TextStyle(
                          color: kDarkGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          hintStyle: TextStyle(
                            color: kMediumGray.withOpacity(0.7),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: kMediumGray.withOpacity(0.7),
                            size: 22,
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      color: kMediumGray,
                                      size: 20,
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: kDarkGray.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kDarkGray),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang tìm kiếm...',
              style: TextStyle(
                color: kDarkGray,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kDarkGray.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: kLightGray,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: kMediumGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: kDarkGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _performSearch(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkGray,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    'Thử lại',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches Header
            const Row(
              children: [
                Icon(Icons.history_rounded, color: kDarkGray, size: 24),
                SizedBox(width: 8),
                Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkGray,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recent Searches List
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _recentSearches.map((search) {
                    return GestureDetector(
                      onTap: () => _onSuggestionTap(search),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kMediumGray.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kDarkGray.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 16,
                              color: kMediumGray.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              search,
                              style: const TextStyle(
                                color: kDarkGray,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 32),

            // Search Tips
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kDarkGray.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: kDarkGray,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Gợi ý tìm kiếm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kDarkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Tìm theo tên sản phẩm\n• Tìm theo danh mục\n• Sử dụng từ khóa đơn giản',
                    style: TextStyle(
                      color: kMediumGray,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kDarkGray.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: kMediumGray,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Không tìm thấy kết quả',
                style: TextStyle(
                  color: kDarkGray,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Không có sản phẩm nào phù hợp với\n"${_searchController.text}"',
                style: const TextStyle(
                  color: kMediumGray,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Tìm kiếm khác',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGray,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: kDarkGray, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Tìm thấy ${_searchResults.length} sản phẩm',
                  style: const TextStyle(
                    color: kDarkGray,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Results List
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ProductItem(
                      product: product,
                      onTap: () => _navigateToProductDetail(product),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
