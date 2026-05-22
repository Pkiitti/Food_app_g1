import 'package:flutter/material.dart';

import 'home_fragement_product.dart';
import 'home_fragment_categories.dart';

class HomeDetail extends StatefulWidget {
  const HomeDetail({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeDetail> createState() => _HomeDetailState();
}

class _HomeDetailState extends State<HomeDetail> {
  String? selectedCategoryId;
  String selectedCategoryTitle = "Popular Products";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoriesStore(
            onCategorySelected: (categoryId, categoryTitle) {
              setState(() {
                selectedCategoryId = categoryId;
                selectedCategoryTitle = categoryTitle;
              });
            },
          ),
          ProductPopular(
            categoryId: selectedCategoryId,
            categoryTitle: selectedCategoryTitle,
          ),
        ],
      ),
    );
  }
}