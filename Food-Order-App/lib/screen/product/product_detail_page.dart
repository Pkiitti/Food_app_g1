import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_app_project/model/add_or_remove_favorite/add_or_remove_favorite_request.dart';
import 'package:food_app_project/model/add_or_remove_favorite/add_or_remove_favorite_response.dart';

import '../../handle_api/handle_api.dart';
import '../../model/add_or_remove_item_basket/basket_request.dart';
import '../../model/add_or_remove_item_basket/basket_response.dart';
import '../../model/check_is_fav/check_is_fav_requuest.dart';
import '../../model/check_is_fav/check_is_favorite_response.dart';
import '../../model/error_response.dart';
import '../../model/get_products/foods_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/show_loading_dialog.dart';
import '../home/home_page.dart';

class ProductDetailPage extends StatefulWidget {
  final FoodsResponse? dataFood;
  static String routeName = "/product_screen";

  const ProductDetailPage({Key? key, required this.dataFood}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFav = false;

  @override
  void initState() {
    checkFav();
    super.initState();
  }

  Future<void> checkFav() async {
    if (widget.dataFood != null && widget.dataFood!.id!.isNotEmpty) {
      CheckIsFavoriteRequest checkIsFavoriteRequest =
      CheckIsFavoriteRequest(widget.dataFood!.id!);
      checkIsFavoriteApi(checkIsFavoriteRequest);
    }
  }

  Future<void> addOrRemoveFavoriteApi(
      AddOrRemoveFavoriteRequest addOrRemoveFavoriteRequest,
      ) async {
    setState(() {
      IsShowDialog().showLoadingDialog(context);
    });

    AddOrRemoveFavoriteResponse addOrRemoveFavoriteResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/favorite/toggleFavorite"),
        RequestType.post,
        headers: null,
        body: const JsonEncoder().convert(
          addOrRemoveFavoriteRequest.toBodyRequest(),
        ),
      );
    } catch (error) {
      debugPrint("Fail to add to fav $error");
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Error from server",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      rethrow;
    }

    if (body == null) return;

    addOrRemoveFavoriteResponse = AddOrRemoveFavoriteResponse.fromJson(body);

    Navigator.of(context).pop();

    if (addOrRemoveFavoriteResponse.status == false) {
      Fluttertoast.showToast(
        msg: "Add to favorite fail",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
    } else {
      setState(() {
        isFav = addOrRemoveFavoriteResponse.message == "Favorited";
      });

      Fluttertoast.showToast(
        msg: isFav
            ? "Added to favorite successfully"
            : "Removed from favorite successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        fontSize: 16,
      );
    }

    return;
  }

  Future<void> checkIsFavoriteApi(
      CheckIsFavoriteRequest checkIsFavoriteRequest,
      ) async {
    CheckIsFavoriteResponse checkIsFavoriteResponse;
    ErrorResponse? errorResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/favorite/checkFavorite"),
        RequestType.post,
        headers: null,
        body:
        const JsonEncoder().convert(checkIsFavoriteRequest.toBodyRequest()),
      );

      if (body == null) return;

      checkIsFavoriteResponse = CheckIsFavoriteResponse.fromJson(body);

      if (body.containsKey('statusCode')) {
        errorResponse = ErrorResponse.fromJson(body);
        Fluttertoast.showToast(
          msg: errorResponse.errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          fontSize: 16,
        );
      } else {
        setState(() {
          isFav = checkIsFavoriteResponse.isFavorite;
        });
      }
    } catch (error) {
      debugPrint("Fail to check fav $error");
      Fluttertoast.showToast(
        msg: "Error from server",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      rethrow;
    }

    return;
  }

  Future<void> addToBasket(BasketRequest request) async {
    IsShowDialog().showLoadingDialog(context);

    BasketResponse response;
    ErrorResponse errorResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/basket/addToBasket"),
        RequestType.post,
        headers: null,
        body: const JsonEncoder().convert(request.toBodyRequest()),
      );

      if (body == null) return;

      Navigator.of(context).pop();

      if (body.containsKey('statusCode')) {
        errorResponse = ErrorResponse.fromJson(body);
        Fluttertoast.showToast(
          msg: errorResponse.errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          fontSize: 16,
        );
      } else {
        response = BasketResponse.fromJson(body);
        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    } catch (error) {
      debugPrint("Fail to add basket $error");
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Server Error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      rethrow;
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.dataFood;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: food == null
          ? const Center(
        child: Text(
          "Product not found",
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 16,
          ),
        ),
      )
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                productImage(food),
                productInfo(food),
              ],
            ),
          ),
          topBar(context),
        ],
      ),
      bottomNavigationBar: food == null ? null : bottomActionBar(food),
    );
  }

  Widget topBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (Global.isAvailableToClick()) {
                  if (widget.dataFood != null &&
                      widget.dataFood!.id!.isNotEmpty) {
                    AddOrRemoveFavoriteRequest request =
                    AddOrRemoveFavoriteRequest(widget.dataFood!.id!);
                    addOrRemoveFavoriteApi(request);
                  }
                }
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.danger : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productImage(FoodsResponse food) {
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: Stack(
        children: [
          Image.network(
            food.image ?? "",
            width: double.infinity,
            height: 340,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 340,
                color: AppColors.border,
                child: const Icon(
                  Icons.fastfood,
                  color: AppColors.textGrey,
                  size: 70,
                ),
              );
            },
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.02),
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget productInfo(FoodsResponse food) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    food.title ?? "",
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${food.price}.000đ",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                infoChip(Icons.star_rounded, "4.8"),
                const SizedBox(width: 10),
                infoChip(Icons.timer_rounded, "20-30 min"),
                const SizedBox(width: 10),
                infoChip(Icons.local_fire_department_rounded, "Hot"),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Chi tiet",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              food.description ?? "",
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 15,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.secondary,
            size: 17,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomActionBar(FoodsResponse food) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Price",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${food.price}.000đ",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  if (Global.isAvailableToClick()) {
                    if (widget.dataFood != null) {
                      BasketRequest request =
                      BasketRequest(widget.dataFood!.id ?? '');

                      await addToBasket(request);

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        HomePage.routeName,
                            (Route<dynamic> route) => false,
                      ).then((value) {
                        setState(() {});
                      });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Add to cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}