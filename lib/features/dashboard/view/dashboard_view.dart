import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../product/model/product_model.dart';

class DashboardView extends StatefulWidget {
  final String userId;
  final String userRole;

  const DashboardView({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFilters = false;
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında ürünleri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: _buildAppBar(viewModel),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              _buildCategoryList(viewModel),
              _buildFilterSection(viewModel),
              if (viewModel.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (viewModel.error != null)
                Expanded(
                  child: Center(
                    child: Text(
                      viewModel.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                )
              else if (viewModel.products.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const Gap(16),
                        Text(
                          'Henüz ürün bulunmuyor',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (widget.userRole != 'buyer') ...[
                          const Gap(24),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Ürün ekleme sayfasına yönlendir
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('İlk İlanı Sen Ver'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: viewModel.fetchProducts,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: viewModel.products.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(viewModel.products[index]);
                      },
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: widget.userRole != 'buyer'
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // TODO: Ürün ekleme sayfasına yönlendir
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('İlan Ver'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş Geldiniz! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const Gap(8),
          Text(
            'Taze ve doğal ürünler burada sizi bekliyor',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DashboardViewModel viewModel) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 180 : 0,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fiyat Aralığı',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '${_priceRange.start.round()}₺',
                  '${_priceRange.end.round()}₺',
                ),
                onChanged: (values) {
                  setState(() => _priceRange = values);
                  // TODO: Implement price filtering
                },
              ),
              const Gap(16),
              Row(
                children: [
                  Text(
                    'Sıralama',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(16),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('En Yeni'),
                      ),
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('En Düşük Fiyat'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('En Yüksek Fiyat'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      // TODO: Implement sorting
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DashboardViewModel viewModel) {
    if (_isSearching) {
      return AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ürün ara...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearching = false);
                viewModel.fetchProducts();
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              viewModel.searchProducts(value);
            }
          },
        ),
      );
    }

    return AppBar(
      title: const Text('Tarım Pazarı'),
      actions: [
        IconButton(
          icon: Icon(
            _showFilters ? Icons.filter_list_off : Icons.filter_list,
          ),
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            // TODO: Profil sayfasına yönlendir
          },
        ),
      ],
    );
  }

  Widget _buildCategoryList(DashboardViewModel viewModel) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.categories.length,
        separatorBuilder: (context, index) => const Gap(8),
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = category == viewModel.selectedCategory;
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => viewModel.changeCategory(category),
            backgroundColor: Colors.white,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Ürün detay sayfasına yönlendir
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    '${product.price} ₺/${product.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    product.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 