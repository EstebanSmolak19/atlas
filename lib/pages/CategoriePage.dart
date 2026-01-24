import 'package:atlas/enum/ProductType.dart';
import 'package:atlas/pages/DetailPage.dart';
import 'package:atlas/providers/CategoryProvider.dart';
import 'package:atlas/providers/ProductProvider.dart';
import 'package:atlas/widgets/appbar/ProductAppbar.dart';
import 'package:atlas/widgets/productItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  ProductType? _currentType;
  bool isMenu = false; 
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is ProductType && _currentType == null) {
      _currentType = args;
      _fetchData(args);
    }
  }

  void _fetchData(ProductType type) {
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProductsByCategory(type);
    });
  }

  void _onCategorySelected(ProductType type) {
    if (_currentType == type) return;

    setState(() {
      _currentType = type;
    });

    _fetchData(type);
  }

  Future<void> _refresh() async {
    await Provider.of<CategoryProvider>(context, listen: false).refreshCategories();
    if (_currentType != null) {
      await Provider.of<ProductProvider>(context, listen: false).fetchProductsByCategory(_currentType!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    
    final products = productProvider.categoryProducts;
    final categories = categoryProvider.categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const ProductAppbar(),
      
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Colors.black,
        child: Column(
          children: [
            Container(
              height: 70,
              color: Colors.white,
              child: categoryProvider.isLoading || categories.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  
                  ProductType type;
                  try {
                    type = ProductType.values.firstWhere(
                      (e) => e.name.toLowerCase() == category.name.toLowerCase(),
                    );
                  } catch (e) {
                    type = ProductType.burger;
                  }
                  
                  final typeName = category.name;
                  final isSelected = _currentType == type;
                  
                  return GestureDetector(
                    onTap: () => _onCategorySelected(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: isSelected 
                          ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
                          : [],
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            if (isSelected) ...[
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: yellowColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              typeName[0].toUpperCase() + typeName.substring(1),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: isMenu ? Alignment.centerRight : Alignment.centerLeft,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutExpo,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => setState(() => isMenu = false),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: !isMenu ? Colors.black : Colors.grey[600],
                              ),
                              child: const Text("Choix simple"),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => setState(() => isMenu = true),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isMenu ? Colors.black : Colors.grey[600],
                              ),
                              child: const Text("Menu"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: productProvider.isLoadingCategory
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text(
                                "Aucun produit trouvé dans\n${_currentType?.name ?? 'cette catégorie'}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(isMenu: isMenu),
                                    settings: RouteSettings(arguments: product),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: ProductItem(
                                  product: product,
                                  isMenu: isMenu,
                                ) 
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}