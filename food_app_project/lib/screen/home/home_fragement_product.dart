import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../handle_api/handle_api.dart';
import '../../model/add_or_remove_favorite/add_or_remove_favorite_request.dart';
import '../../model/add_or_remove_favorite/add_or_remove_favorite_response.dart';
import '../../model/get_products/foods_response.dart';
import '../../model/get_products/product_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/show_loading_dialog.dart';
import '../product/list_all_product.dart';
import '../product/product_detail_page.dart';

class ProductPopular extends StatefulWidget {
  final String? categoryId;
  final String categoryTitle;

  const ProductPopular({
    Key? key,
    this.categoryId,
    this.categoryTitle = "Popular Products",
  }) : super(key: key);

  @override
  State<ProductPopular> createState() => _ProductPopularState();
}

class _ProductPopularState extends State<ProductPopular> {
  List<FoodsResponse>? data;
  ProductResponse? dataProduct;

  // Luu id cac mon vua duoc bam favorite tren man home de doi mau icon tam thoi
  Set<String> favoriteFoodIds = {};

  @override
  void initState() {
    getProduct();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProductPopular oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryId != widget.categoryId) {
      getProduct();
    }
  }

  Future<ProductResponse> getProduct() async {
    ProductResponse productResponse;
    Map<String, dynamic>? body;

    try {
      final String apiUrl = widget.categoryId == null
          ? "${Global.apiAddress}/api/food/getAllFoods"
          : "${Global.apiAddress}/api/food/getFoodsByCategory/${widget.categoryId}";

      body = await HttpHelper.invokeHttp(
        Uri.parse(apiUrl),
        RequestType.get,
        headers: null,
        body: null,
      );
    } catch (error) {
      debugPrint("Fail to foods info $error");
      rethrow;
    }

    if (body == null) return ProductResponse.buildDefault();

    productResponse = ProductResponse.fromJson(body);

    setState(() {
      data = productResponse.listFoods;
      dataProduct = productResponse;
    });

    return productResponse;
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
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.categoryTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (dataProduct != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListAllProduct(productInfo: dataProduct!),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "See more",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          data != null
              ? data!.isNotEmpty
              ? GridView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data!.length > 6 ? 6 : data!.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final food = data![index];
              final String foodId = food.id ?? "";
              final bool isFavorite =
                  foodId.isNotEmpty && favoriteFoodIds.contains(foodId);

              return food.title != null &&
                  food.title!.isNotEmpty &&
                  food.price != null &&
                  food.image != null &&
                  food.image!.isNotEmpty
                  ? GestureDetector(
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                            const BorderRadius.only(
                              topLeft: Radius.circular(22),
                              topRight: Radius.circular(22),
                            ),
                            child: Image.network(
                              food.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 122,
                              errorBuilder:
                                  (context, error, stackTrace) {
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
                              behavior:
                              HitTestBehavior.opaque,
                              onTap: () {
                                if (foodId.isNotEmpty) {
                                  toggleFavorite(foodId);
                                }
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.92),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons
                                      .favorite_border_rounded,
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
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            10,
                            12,
                            10,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.title!,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
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
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 12,
                                  height: 1.25,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${food.price}.000đ",
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color:
                                        AppColors.primary,
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
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
              )
                  : const SizedBox();
            },
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(minHeight: 170),
            alignment: Alignment.center,
            child: const Text(
              "No products found",
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
            ),
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(minHeight: 170),
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