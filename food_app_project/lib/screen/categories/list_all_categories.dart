import 'package:flutter/material.dart';

import '../../model/get_categories/categories_response.dart';
import '../../model/get_categories/store_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';

class ListAllCategories extends StatefulWidget {
  final StoreResponse storeInfo;

  const ListAllCategories({Key? key, required this.storeInfo})
      : super(key: key);

  @override
  State<ListAllCategories> createState() => _ListAllCategoriesState();
}

class _ListAllCategoriesState extends State<ListAllCategories> {
  List<CategoriesResponse> dataCategories = [];
  TextEditingController inputSearchController = TextEditingController();
  String inputSearch = "";
  bool isSearching = false;

  List<CategoriesResponse> resultCategory = [];

  @override
  void initState() {
    dataCategories = widget.storeInfo.listCategories ?? [];
    resultCategory = dataCategories;
    super.initState();
  }

  void updateSearchCategories(String value) {
    setState(() {
      inputSearch = value;
      resultCategory = dataCategories
          .where(
            (element) => Global()
            .accentParser(element.title ?? "")
            .toLowerCase()
            .contains(Global().accentParser(value).toLowerCase()),
      )
          .toList();
      isSearching = value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(92),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: inputSearchController,
                        cursorColor: AppColors.primary,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        onChanged: updateSearchCategories,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.only(top: 13, bottom: 11),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textGrey,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minHeight: 24,
                            minWidth: 36,
                          ),
                          hintText: "Search category...",
                          hintStyle: TextStyle(
                            color: AppColors.textGrey.withOpacity(0.65),
                            fontFamily: 'NunitoSans',
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: resultCategory.isEmpty && isSearching
          ? const Center(
        child: Text(
          "The category does not exist",
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 16,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
        scrollDirection: Axis.vertical,
        itemCount: resultCategory.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final category = resultCategory[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      category.image ?? "",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.fastfood_rounded,
                          color: AppColors.primary,
                          size: 38,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    category.title ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Explore menu",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}