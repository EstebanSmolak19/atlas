import 'package:flutter/material.dart';

class FoodCategoryNavBar extends StatefulWidget {
  const FoodCategoryNavBar({Key? key}) : super(key: key);

  @override
  State<FoodCategoryNavBar> createState() => _FoodCategoryNavBarState();
}

class _FoodCategoryNavBarState extends State<FoodCategoryNavBar> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'icon': 'assets/icon-burger.png', 'label': 'Burger', 'width': 350.0},
    {'icon': 'assets/icon-pizza.png', 'label': 'Pizza', 'width': 250.0, 'top': 15.0},
    {'icon': 'assets/icon-drink.png', 'label': 'Boisson', 'width': 330.0, 'top': 0.0},
    {'icon': 'assets/icon-dessert.png', 'label': 'Dessert', 'width': 250.0, 'top': 10.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130, 
      padding: const EdgeInsets.only(left: 16.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: CategoryItem(
              imagePath: category['icon']!,
              label: category['label']!,
              isSelected: isSelected,
              width: category['width'],
              top: category['top'] ?? 10
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
    Key? key,
    required this.imagePath,
    required this.label,
    required this.isSelected,
    required this.width,
    required this.top
  }) : super(key: key);

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
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
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