import 'package:atlas/enum/ProductType.dart';
import 'package:atlas/models/AppRoutes.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is ProductType && args != _currentType) {
      _currentType = args;
      
      Future.microtask(() {
        Provider.of<ProductProvider>(context, listen: false).fetchProductsByCategory(args);
      });
    }
  }

  void _onCategorySelected(ProductType type) {
    setState(() {
      _currentType = type;
    });
    Provider.of<ProductProvider>(context, listen: false).fetchProductsByCategory(type);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.categoryProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const ProductAppbar(),
      
      body: Column(
        children: [
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: ProductType.values.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final type = ProductType.values[index];
                final isSelected = _currentType == type;
                
                return GestureDetector(
                  onTap: () => _onCategorySelected(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color.fromARGB(255, 242, 202, 80) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        type.name[0].toUpperCase() + type.name.substring(1),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: provider.isLoadingCategory
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : products.isEmpty
                    ? Center(child: Text("Aucun produit trouvé pour ${_currentType?.name ?? 'cette catégorie'}"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.detailPage, arguments: product);
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
                              child: ProductItem(product: product)
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}