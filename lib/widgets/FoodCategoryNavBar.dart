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
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (categoryProvider.isLoading) {
      return const SizedBox(
        height: 130,
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
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
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              
              //Récupère le nom de la catégorie.
              String categoryName = categoryProvider.categories[index].name;

              Navigator.pushNamed(context, AppRoutes.getRouteByName(categoryName)); 
            },
            child: CategoryItem(
              imagePath: category.icon,
              label: category.name,
              isSelected: isSelected,
              width: category.width,
              top: category.top,
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
  final bool isSelected;
  final double width;
  final double top;

  const CategoryItem({
    super.key,
    required this.imagePath,
    required this.label,
    required this.isSelected,
    required this.width,
    required this.top
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
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}