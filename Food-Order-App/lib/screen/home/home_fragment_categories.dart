import 'package:flutter/material.dart';

import '../../handle_api/handle_api.dart';
import '../../model/get_categories/categories_response.dart';
import '../../model/get_categories/store_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../categories/list_all_categories.dart';

class CategoriesStore extends StatefulWidget {
  final Function(String categoryId, String categoryTitle)? onCategorySelected;

  const CategoriesStore({
    Key? key,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoriesStore> createState() => _CategoriesStoreState();
}

class _CategoriesStoreState extends State<CategoriesStore> {
  List<CategoriesResponse>? dataCategories;
  StoreResponse? dataStore;
  int selectedIndex = -1;

  @override
  void initState() {
    getStore();
    super.initState();
  }

  Future<StoreResponse> getStore() async {
    StoreResponse storeResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/category/getCategories"),
        RequestType.get,
        headers: null,
        body: null,
      );
    } catch (error) {
      debugPrint("Fail to categories info $error");
      rethrow;
    }

    if (body == null) return StoreResponse.buildDefault();

    storeResponse = StoreResponse.fromJson(body);

    setState(() {
      dataCategories = storeResponse.listCategories;
      dataStore = storeResponse;
    });

    return storeResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (dataCategories != null && dataStore != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListAllCategories(storeInfo: dataStore!),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "See more",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          dataCategories != null
              ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 128,
            child: ListView.builder(
              shrinkWrap: true,
              primary: true,
              scrollDirection: Axis.horizontal,
              itemCount: dataCategories!.length,
              itemBuilder: (context, index) {
                final category = dataCategories![index];
                final bool isSelected = selectedIndex == index;

                return category.image != null &&
                    category.image!.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });

                    widget.onCategorySelected?.call(
                      category.id,
                      category.title ?? "Products",
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: 102,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.28)
                              : Colors.black.withOpacity(0.06),
                          blurRadius: isSelected ? 16 : 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            category.image!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          category.title ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : const SizedBox();
              },
            ),
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}