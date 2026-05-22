import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../handle_api/handle_api.dart';
import '../../model/get_basket_list/get_basket_response.dart';
import '../../model/get_products/foods_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/share_preferences.dart';
import '../cart/cart_page.dart';
import 'account_fragment.dart';
import 'appbar/menu_header.dart';
import 'favorite_fragment.dart';
import 'home_detail.dart';

class HomePage extends StatefulWidget {
  static String routeName = "/home_screen";
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectIndex = 0;
  bool favorites = true;
  bool homePage = true;
  List<FoodsResponse> basketListData = [];
  String userName = "";

  @override
  void initState() {
    getUserName();
    getBasketList();
    super.initState();
  }

  Future<void> getUserName() async {
    final name = await ConfigSharedPreferences()
        .getStringValue(SharedData.NAME.toString(), defaultValue: "");

    final email = await ConfigSharedPreferences()
        .getStringValue(SharedData.EMAIL.toString(), defaultValue: "");

    setState(() {
      if (name.isNotEmpty) {
        userName = name;
      } else if (email.isNotEmpty) {
        userName = email.split("@").first;
      } else {
        userName = "Foodie";
      }
    });
  }

  Future<void> getBasketList() async {
    GetBasketResponse getBasketResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/basket/getBasket"),
        RequestType.get,
        headers: null,
        body: null,
      );

      if (body == null) return;

      getBasketResponse = GetBasketResponse.fromJson(body);

      setState(() {
        basketListData = getBasketResponse.basketList;
        Global.basketList = basketListData;
        Global.basketId = getBasketResponse.basketId ?? "";
      });
    } catch (error) {
      debugPrint("Fail get basket list $error");
      rethrow;
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screen = [
      const HomeDetail(),
      const FavoriteDetail(),
      const AccountDetail(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
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
              padding: const EdgeInsets.fromLTRB(18, 8, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: homePage
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hello, ${userName.isEmpty ? "Foodie" : userName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Find your best meal",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : favorites
                        ? const Text(
                      "Favorites",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : const MenuHeader(),
                  ),
                  if (homePage)
                    GestureDetector(
                      onTap: () {
                        if (basketListData.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartPage(
                                listDataOrder: basketListData,
                              ),
                            ),
                          ).then((_) => getBasketList());
                        } else {
                          Fluttertoast.showToast(
                            msg: "Do not exist order!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 3,
                            backgroundColor: AppColors.danger,
                            textColor: Colors.white,
                            fontSize: 16,
                          );
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.28),
                              ),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (basketListData.isNotEmpty)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  basketListData.length > 9
                                      ? "9+"
                                      : "${basketListData.length}",
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: screen[selectIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectIndex,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          onTap: (index) {
            setState(() {
              selectIndex = index;
              homePage = selectIndex == 0;
              favorites = selectIndex == 1;
            });

            if (index == 0) {
              getUserName();
              getBasketList();
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}