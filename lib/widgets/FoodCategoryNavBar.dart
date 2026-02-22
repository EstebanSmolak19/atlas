import 'package:atlas/enum/ProductType.dart';
import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/providers/CategoryProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodCategoryNavBar extends StatefulWidget {
  const FoodCategoryNavBar({super.key});

  @override
  State<FoodCategoryNavBar> createState() => _FoodCategoryNavBarState();
}

class _FoodCategoryNavBarState extends State<FoodCategoryNavBar> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  ProductType _mapStringToEnum(String categoryName) {
    try {
      return ProductType.values.firstWhere(
        (e) => e.name.toLowerCase() == categoryName.toLowerCase()
      );
    } catch (e) {
      return ProductType.burger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (categoryProvider.isLoading) {
      return SizedBox(
        height: 130,
        child: Center(child: CircularProgressIndicator(color: isDark ? yellowColor : Colors.black)),
      );
    }

    if (categoryProvider.categories.isEmpty) {
      return const SizedBox(
        height: 130,
        child: Center(child: Text("Aucune catégorie")),
      );
    }

    return Container(
      height: 130,
      padding: const EdgeInsets.only(left: 16.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categoryProvider.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categoryProvider.categories[index];

          return GestureDetector(
            onTap: () {
              ProductType type = _mapStringToEnum(category.name);

              Navigator.pushNamed(
                context,
                AppRoutes.categoryPage,
                arguments: type
              );
            },
            child: CategoryItem(
              imagePath: category.icon,
              label: category.name,
              width: category.width,
              top: category.top,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final double width;
  final double top;
  final bool isDark;

  const CategoryItem({
    super.key,
    required this.imagePath,
    required this.label,
    required this.width,
    required this.top,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: top,
            width: width,
            child: Container(
              decoration: const BoxDecoration(
                 shape: BoxShape.circle,
              ),
              child: imagePath.startsWith('http')
                  ? Image.network(imagePath, fit: BoxFit.contain)
                  : Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),

          Positioned(
            bottom: 10,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}