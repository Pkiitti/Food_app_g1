import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_app_project/screen/product/product_detail_page.dart';

import '../../handle_api/handle_api.dart';
import '../../model/add_or_remove_favorite/add_or_remove_favorite_request.dart';
import '../../model/add_or_remove_favorite/add_or_remove_favorite_response.dart';
import '../../model/get_products/foods_response.dart';
import '../../model/get_products/product_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/show_loading_dialog.dart';

class ListAllProduct extends StatefulWidget {
  final ProductResponse productInfo;

  const ListAllProduct({Key? key, required this.productInfo}) : super(key: key);

  @override
  State<ListAllProduct> createState() => _ListAllProductState();
}

class _ListAllProductState extends State<ListAllProduct> {
  TextEditingController inputSearchController = TextEditingController();
  String inputSearch = "";
  bool isSearching = false;
  List<FoodsResponse> dataFoods = [];
  List<FoodsResponse> result = [];

  // Luu id cac mon vua bam favorite tren man nay de doi mau icon tam thoi
  Set<String> favoriteFoodIds = {};

  @override
  void initState() {
    dataFoods = widget.productInfo.listFoods ?? [];
    result = dataFoods;
    super.initState();
  }

  void updateSearchProduct(String value) {
    setState(() {
      inputSearch = value;
      result = dataFoods
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

  Future<void> toggleFavorite(String foodId) async {
    IsShowDialog().showLoadingDialog(context);

    try {
      final request = AddOrRemoveFavoriteRequest(foodId);

      final body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/favorite/toggleFavorite"),
        RequestType.post,
        headers: null,
        body: const JsonEncoder().convert(request.toBodyRequest()),
      );

      Navigator.of(context).pop();

      if (body == null) return;

      final response = AddOrRemoveFavoriteResponse.fromJson(body);

      setState(() {
        if (response.message == "Favorited") {
          favoriteFoodIds.add(foodId);
        } else {
          favoriteFoodIds.remove(foodId);
        }
      });

      Fluttertoast.showToast(
        msg: response.message == "Favorited"
            ? "Added to favorites"
            : "Removed from favorites",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        fontSize: 16,
      );
    } catch (error) {
      Navigator.of(context).pop();

      Fluttertoast.showToast(
        msg: "Favorite failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );

      debugPrint("Toggle favorite failed: $error");
    }
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
                        onChanged: updateSearchProduct,
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
                          hintText: "Search product...",
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
      body: result.isEmpty && isSearching
          ? const Center(
        child: Text(
          "The product does not exist",
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 16,
          ),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
        scrollDirection: Axis.vertical,
        itemCount: result.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final food = result[index];
          final String foodId = food.id ?? "";
          final bool isFavorite =
              foodId.isNotEmpty && favoriteFoodIds.contains(foodId);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    dataFood: food,
                  ),
                ),
              );
            },
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                        child: Image.network(
                          food.image ?? "",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 122,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 122,
                              color: AppColors.border,
                              child: const Icon(
                                Icons.fastfood,
                                color: AppColors.textGrey,
                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (foodId.isNotEmpty) {
                              toggleFavorite(foodId);
                            }
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? AppColors.danger
                                  : AppColors.primary,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            food.description ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                              height: 1.25,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "${food.price}.000đ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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