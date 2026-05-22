import 'package:flutter/material.dart';

import '../../handle_api/handle_api.dart';
import '../../model/get_products/foods_response.dart';
import '../../model/get_products/product_response.dart';
import '../../util/global.dart';
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

  /// call api list foods
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.categoryTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
                child: const Text(
                  "See more",
                  style: TextStyle(fontSize: 16, color: Colors.lightGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final food = data![index];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      food.image!,
                      fit: BoxFit.cover,
                      width: 105,
                      height: 105,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        food.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.green,
                      ),
                      child: Text(
                        "${food.price}.000 VNĐ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
              : Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(minHeight: 170),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}