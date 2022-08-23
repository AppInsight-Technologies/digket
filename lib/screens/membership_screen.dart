import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/StoreBottomNavigationWidget.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../controller/mutations/home_screen_mutation.dart';
import '../../controller/mutations/cart_mutation.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/cartModle.dart';
import '../../models/newmodle/product_data.dart';
import 'package:velocity_x/velocity_x.dart';
import '../generated/l10n.dart';
import '../rought_genrator.dart';
import '../widgets/simmers/loyality_wallet_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/features.dart';
import 'package:provider/provider.dart';
import '../constants/IConstants.dart';
import '../providers/membershipitems.dart';
import '../widgets/badge.dart';
import '../assets/images.dart';
import '../assets/ColorCodes.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../data/calculations.dart';
import '../utils/prefUtils.dart';
import 'customer_support_screen.dart';

class MembershipScreen extends StatefulWidget {
  static const routeName = '/membership-screen';

  @override
  _MembershipScreenState createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> with Navigations{
 // Box<Product> productBox;
  bool _checkmembership = false;
  var orderdate = "";
  var expirydate = "";
  var orderid = "";
  var ordertotal = "";
  var name = "";
  var duration = "";
  var paytype = "";
  var address = "";
  bool _loading = true;
  bool checkskip = false;
  bool memberMode = false;
  //SharedPreferences prefs;
  // bool _isWeb = false;
  var _address = "";
  MediaQueryData? queryData;
  double? wid;
  double? maxwid;
  bool _isAddToCart = false;
  bool iphonex = false;
  var email = "", photourl = "", phone = "";
  var postImage= "";
  GroceStore store = VxState.store;
  List<CartItem> productBox=[];
  String addedmembership = "";

  String selectedPlan= "";
  String price = "";
  bool selected = false;
  int _isselect = 0;

  @override
  void initState() {

    productBox = /*Hive.box<Product>(productBoxName);*/(VxState.store as GroceStore).CartItemList;
    Future.delayed(Duration.zero, () async {
      _isselect = -1;
      // try {
      //   if (Platform.isIOS) {
      //     setState(() {
      //       _isWeb = false;
      //       iphonex = MediaQuery.of(context).size.height >= 812.0;
      //     });
      //   } else {
      //     setState(() {
      //       _isWeb = false;
      //     });
      //   }
      // } catch (e) {
      //   setState(() {
      //     _isWeb = true;
      //   });
      // }
      name = store.userData.username!;
      if (PrefUtils.prefs!.getString('Email') != null) {
        email = PrefUtils.prefs!.getString('Email')!;
      } else {
        email = "";
      }

      if (PrefUtils.prefs!.getString('mobile') != null) {
        phone = PrefUtils.prefs!.getString('mobile')!;
      } else {
        phone = "";
      }
      _address = PrefUtils.prefs!.getString("restaurant_address")!;
      if (!PrefUtils.prefs!.containsKey("apikey")) {
        setState(() {
          checkskip = true;
        });
      } else {
        checkskip = false;
      }

      for (int i = 0; i < productBox.length; i++) {
        debugPrint("mode...."+productBox[i].mode.toString());
        if (productBox[i].mode == "1") {
          memberMode = true;
        }
      }
      if (memberMode) {
        Provider.of<MembershipitemsList>(context, listen: false).Getmembership().then((_) async {
          final membershipData = Provider.of<MembershipitemsList>(context, listen: false);
          if (membershipData.items.length > 0)
            await precacheImage(AssetImage(membershipData.items[0].avator!), context).then((_) {
              Future.delayed(Duration.zero, () async {
                setState(() {
                  _loading = false;
                  _checkmembership = false;
                });
              });
            }); else {
            setState(() {
              _loading = false;
              _checkmembership = false;
            });
          }

        });
      } else if (store.userData.membership! == "1") {
        _checkmembership = true;
        Provider.of<MembershipitemsList>(context,listen: false).Getmembershipdetails().then((_) async {
          setState(() {
            postImage =PrefUtils.prefs!.getString("post_image")!;
            orderdate = PrefUtils.prefs!.getString("orderdate")!;
            expirydate = PrefUtils.prefs!.getString("expirydate")!;
            orderid = PrefUtils.prefs!.getString("orderid")!;
            ordertotal = PrefUtils.prefs!.getString("membershipprice")!;
            // name = PrefUtils.prefs!.getString("membershipname");
            duration = PrefUtils.prefs!.getString("duration")!;
            paytype = PrefUtils.prefs!.getString("memebershippaytype")!;
            address = PrefUtils.prefs!.getString("membershipaddress")!;
            _loading = false;
          });
        });
      } else {
        Provider.of<MembershipitemsList>(context, listen: false).Getmembership().then((_) async {
          final membershipData = Provider.of<MembershipitemsList>(context, listen: false);
          if (membershipData.items.length > 0)
            await precacheImage(AssetImage(membershipData.items[0].avator!), context).then((_) {
              Future.delayed(Duration.zero, () async {
                setState(() {
                  _loading = false;
                  _checkmembership = false;
                });
              });
            }); else {
            setState(() {
              _loading = false;
              _checkmembership = false;
            });
          }
        });
      }
      //prefs = await SharedPreferences.getInstance();
    //  await Provider.of<BrandItemsList>(context,listen: false).userDetails().then((_) {

      //});
    });
    super.initState();
  }

  _addtocart(String membershipid, String duration, String discountprice, String price) async {
    // await Provider.of<CartItems>(context, listen: false).addToCart(
    //     "0", "0", duration, "1", "1", "1", "1", price, "Membership",
    //     "1", double.parse(discountprice).toString(), discountprice, Images.membershipImg, membershipid, "1", "","1","","","","","").then((_) {
    //
    //
    //   setState(() {
    //     _isAddToCart = false;
    //   });
    //   PrefUtils.prefs!.setString("membership", "1");
    //
    //   Product products = Product(
    //       itemId: 0,
    //       varId: 0,
    //       varName: duration,
    //       varMinItem: 1,
    //       varMaxItem: 1,
    //       varStock: 1,
    //       varMrp: double.parse(price),
    //       itemName: "Membership",
    //       itemQty: 1,
    //       itemPrice: double.parse(discountprice),
    //       membershipPrice: discountprice,
    //       itemActualprice: double.parse(price),
    //       itemImage: Images.membershipImg,
    //       membershipId: int.parse(membershipid),
    //       mode: 1,
    //       veg_type: "",
    //       type: "",
    //       eligible_for_express: "",
    //       delivery: "",
    //       duration: "",
    //       durationType: "",
    //       note: ""
    //   );
    //
    //   //productBox.add(products);
    // });
    addedmembership = "yes";
    debugPrint("addmembership...."+addedmembership);
    cartcontroller.addtoCart( itemdata: ItemData(type: "",eligibleForExpress: "1",vegType:"",delivery: "0",
        duration:"0",brand: "",id: "0",itemName: "Membership",mode: "1",
        membershipId: membershipid,
        deliveryDuration:DeliveryDurationData(duration:"",status: "",durationType: "",note: "", id: "",branch: "",blockFor: "") ), onload: (onload){
    setState(() {
      _isAddToCart = onload;
    });
    },topping_type: "",varid: "",toppings: "0",parent_id: "",newproduct: "0",toppingsList: [],itembody: PriceVariation(quantity: 1,mode: "4",status: "0",discointDisplay: false,
        loyaltys:0,membershipDisplay:false,menuItemId: "",
        netWeight: "",weight:"",id: "0",variationName: duration,unit: S .of(context).membership_month ,minItem: "1",
        maxItem: "1",loyalty: 0,stock: 1,mrp:discountprice,
        price: discountprice,membershipPrice: discountprice),context: context);
  }

  _removefromcart(String discountprice) async {
    addedmembership = "No";
    // await Provider.of<CartItems>(context, listen: false).updateCart(
    //     "0", "0", double.parse(discountprice).toString()).then((_) {
    //
    //   PrefUtils.prefs!.setString("membership", "0");
    //   CartCalculations.deleteMembershipItem();
    //
    //   setState(() {
    //     _isAddToCart = false;
    //   });
    // });

    cartcontroller.update((done){
      PrefUtils.prefs!.setString("membership", "0");
      CartCalculations.deleteMembershipItem();

      setState(() {
        _isAddToCart = false;
      });
    },price: double.parse(discountprice).toString(),var_id:"0",quantity: "0",weight: "0",cart_id: "",toppings: "",
      topping_id: "",);
  }

  _updatetocart(String membershipid, String duration, String discountprice, String price) async {

    CartCalculations.deleteMembershipItem();
    cartcontroller.addtoCart(itemdata:
        ItemData(type: "",eligibleForExpress: "1",vegType:"",delivery: "0",
        duration:"0",brand: "",id: "0",itemName: "Membership",mode: "1",
            membershipId: membershipid,
            deliveryDuration:DeliveryDurationData(duration:"",status: "",durationType: "",note: "", id: "",branch: "",blockFor: "") ), onload: (onload){
          setState(() {
            _isAddToCart = onload;
          });
    },topping_type: "",varid: "",toppings: "0",parent_id: "",newproduct: "0",toppingsList: [],itembody: PriceVariation(quantity: 1,mode: "4",status: "0",discointDisplay: false,
        loyaltys:0,membershipDisplay:false,menuItemId: "",
        netWeight: "",weight:"",id: "0",variationName: duration,unit: S .of(context).membership_month ,
        minItem: "1",
        maxItem: "1",loyalty: 0,stock: 1,mrp: discountprice,
        price: discountprice,membershipPrice: discountprice),
    context: context);
  }


/*  void launchWhatsapp({required number,required message})async{
    String url ="whatsapp://send?phone=$number&text=$message";
    await canLaunch(url)?launch(url):print('can\'t open whatsapp');
  }*/
  void launchWhatsApp() async {
    String phone = /*"+918618320591"*/IConstants.secondaryMobile;
    debugPrint("Whatsapp . .. . . .. . .");
    String url() {
      if (Platform.isIOS) {
        debugPrint("Whatsapp1 . .. . . .. . .");
        return "whatsapp://wa.me/$phone/?text=${Uri.parse('I want to order Grocery')}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse('I want to order Grocery')}";
        const url = "https://wa.me/?text=YourTextHere";

      }
    }
    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    queryData = MediaQuery.of(context);
    wid= queryData!.size.width;
    maxwid=wid!*0.90;

    bottomNavigationbar() {
      return SingleChildScrollView(
        child: Container(
          height: 65,
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: ColorCodes.primaryColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
            // shape: BoxShape.circle,
          ),
          child: Row(
            children: <Widget>[
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);
                  //Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                },
                child: Container(
                  width: 60,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      CircleAvatar(
                        radius: 13.0,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          Images.homeImg,
                          color: ColorCodes.whiteColor,
                          width: 30,
                          height: 25,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          S .of(context).home,//"Home",
                          style: TextStyle(
                            color: ColorCodes.whiteColor,
                            fontSize: 10.0,
                          )),
                      SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  /*Navigator.of(context).pushReplacementNamed(
                    CategoryScreen.routeName,
                  );*/
                  Navigation(context, name:Routename.Category, navigatore: NavigatoreTyp.Push);
                },
                child: Container(
                  width: 60,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      CircleAvatar(
                        radius: 13.0,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(Images.categoriesImg,
                            width: 20,
                            height: 25,
                            color: ColorCodes.whiteColor),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          S .of(context).categories,//"Categories",
                          style: TextStyle(
                              color: ColorCodes.whiteColor, fontSize: 10.0)),
                      SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
              if(Features.isWallet)
                Spacer(),
              if(Features.isWallet)
                GestureDetector(
                  onTap: () {
                    checkskip
                        ? /*Navigator.of(context).pushNamed(
                      SignupSelectionScreen.routeName,
                    )*/
                    Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                        : /*Navigator.of(context).pushReplacementNamed(WalletScreen.routeName,
                          arguments: {"type": "wallet"});*/
                    Navigation(context, name: Routename.Wallet, navigatore: NavigatoreTyp.Push,
                    qparms: {
                      "type":"wallet",
                    });
                  },
                  child: Container(
                    width: 60,
                    child: Column(
                      children: <Widget>[
                        /*SizedBox(
                          height: 3.0,
                        ),
                        (PrefUtils.prefs!.containsKey("apikey")) ?((VxState.store as GroceStore).prepaid.prepaid.toString() != null || (VxState.store as GroceStore).prepaid.prepaid.toString() != "null" || (VxState.store as GroceStore).prepaid.prepaid.toString() != "")?Text(
                          Features.iscurrencyformatalign?
                          (VxState.store as GroceStore).prepaid.prepaid!.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit) + " " + IConstants.currencyFormat:
                          IConstants.currencyFormat + " " + (VxState.store as GroceStore).prepaid.prepaid!.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                          style: TextStyle(
                              color: ColorCodes.greenColor,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold
                          ),
                        ):
                        SizedBox(
                          height: 10.0,
                        ):*/
                        SizedBox(
                          height: 8.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.walletImg,
                              width: 20,
                              height: 25,
                              color: ColorCodes.whiteColor),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            S .of(context).wallet,//"Wallet",
                            style: TextStyle(
                                color: ColorCodes.whiteColor, fontSize: 10.0)),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              if(Features.isMembership)
                Spacer(),
              if(Features.isMembership)
                Container(
                  width: 60,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      CircleAvatar(
                        radius: 13.0,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(Images.bottomnavMembershipImg,
                            width: 20,
                            height: 25,
                            color: IConstants.isEnterprise?ColorCodes.badgecolor:ColorCodes.maphome),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          S .of(context).membership,//"Membership",
                          style: TextStyle(
                              color: IConstants.isEnterprise?ColorCodes.badgecolor:ColorCodes.maphome,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                ),
              if(!Features.isMembership)
                Spacer(),
              if(!Features.isMembership)
                GestureDetector(
                  onTap: () {
                    checkskip
                        ? /*Navigator.of(context).pushNamed(
                      SignupSelectionScreen.routeName,
                    )*/
                    Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                        : /*Navigator.of(context).pushReplacementNamed(
                      MyorderScreen.routeName,arguments: {
                      "orderhistory": ""
                    }
                    );*/
                    Navigation(context, name:Routename.MyOrders,navigatore: NavigatoreTyp.Push,
                       /* parms: {
                      "orderhistory": ""
                    }*/);
                  },
                  child: Container(
                    width: 60,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                              Images.shoppinglistsImg,
                              width: 20,
                              height: 25,
                              color: IConstants.isEnterprise?ColorCodes.badgecolor:ColorCodes.maphome
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            S .of(context).my_orders,//"My Orders",
                            style: TextStyle(
                                color: IConstants.isEnterprise?ColorCodes.badgecolor:ColorCodes.maphome,
                                fontSize: 10.0)),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              if(Features.isShoppingList)
                Spacer(flex: 1),
              if(Features.isShoppingList)
                GestureDetector(
                  onTap: () {
                    checkskip
                        ? /*Navigator.of(context).pushNamed(
                      SignupSelectionScreen.routeName,
                    )*/
                    Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                        :
                   /* Navigator.of(context).pushReplacementNamed(
                      ShoppinglistScreen.routeName,
                    );*/
                    Navigation(context, name: Routename.Shoppinglist, navigatore: NavigatoreTyp.Push);
                  },
                  child: Container(
                    width: 60,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.shoppinglistsImg,
                            width: 18,
                            height: 25,
                          color: ColorCodes.whiteColor,),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            S .of(context).shopping_list,//"Shopping list",
                            style: TextStyle(
                                color: ColorCodes.whiteColor, fontSize: 10.0)),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              if(!Features.isShoppingList)
                Spacer(),
              if(!Features.isShoppingList)
                GestureDetector(
                  onTap: () {
                    checkskip && Features.isLiveChat
                        ? /*Navigator.of(context).pushNamed(
                      SignupSelectionScreen.routeName,
                    )*/
                    Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                        : (Features.isLiveChat && Features.isWhatsapp)?
                    Navigator.of(context)
                        .pushNamed(CustomerSupportScreen.routeName, arguments: {
                      'name': name,
                      'email': email,
                      'photourl': photourl,
                      'phone': phone,
                    }):
                    (!Features.isLiveChat && !Features.isWhatsapp)?
                    Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search)
                        :
                    Features.isWhatsapp?launchWhatsApp()/*launchWhatsapp(number: IConstants.countryCode + IConstants.secondaryMobile, message:"I want to order Grocery")*/:
                    Navigator.of(context)
                        .pushNamed(CustomerSupportScreen.routeName, arguments: {
                      'name': name,
                      'email': email,
                      'photourl': photourl,
                      'phone': phone,
                    });
                  },
                  child: Container(
                    width: 60,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: (!Features.isLiveChat && !Features.isWhatsapp)?
                          Icon(
                            Icons.search,
                            color: ColorCodes.whiteColor,

                          )
                              :
                          Image.asset(
                            Features.isLiveChat?Images.appCustomer: Images.whatsapp,
                            width: 20,
                            height: 25,
                            color: Features.isLiveChat?ColorCodes.whiteColor:null,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text((!Features.isLiveChat && !Features.isWhatsapp)? S .of(context).search//"Search"
                            : S .of(context).chat,//"Chat",
                            style: TextStyle(
                                color: ColorCodes.whiteColor, fontSize: 10.0)),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              Spacer(),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: (){
        debugPrint("WillPopScope..");
        if(addedmembership == "yes"){
          debugPrint("addmembership....1.."+addedmembership);
          debugPrint("entered if..");
          if(Vx.isWeb){
            Navigator.of(context).pop();
           // Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);
            //Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }else {
            HomeScreenController(
                user: (VxState.store as GroceStore).userData.id ??
                    PrefUtils.prefs!.getString("tokenid"),
                branch: (VxState.store as GroceStore).userData.branch ?? "999",
                rows: "0");
            Navigator.of(context).pop();
          }
        }else if(addedmembership == "No"){
          if(Vx.isWeb){
            Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);
           // Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }else {
            HomeScreenController(
                user: (VxState.store as GroceStore).userData.id ??
                    PrefUtils.prefs!.getString("tokenid"),
                branch: (VxState.store as GroceStore).userData.branch ?? "999",
                rows: "0");
            Navigator.of(context).pop();
          }
        }else {
          debugPrint("entered else..");
          if(Vx.isWeb){
            Navigator.of(context).pop();
           // Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);
           // Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }else {
            Navigator.of(context).pop();
          }
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar:  ResponsiveLayout.isSmallScreen(context)
            ? gradientappbarmobile()
            : null,
//        drawer: AppDrawer(),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            if (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(false),
            _body(),
          ],
        ),
        bottomNavigationBar: Vx.isWeb ? SizedBox.shrink() : Padding(
          padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
          child: (Features.ismultivendor)? StoreBottomNavigation() : bottomNavigationbar(),
        ),
      ),
    );
  }

  Widget _body(){
    final membershipData = Provider.of<MembershipitemsList>(context,listen: false);
  /*  setState(() {
      for (int j = 0; j < membershipData.typesitems.length; j++) {
        if (membershipData.typesitems[j].text == "Select") {
          selectedPlan = membershipData.typesitems[j].typesduration!;
          price = membershipData.typesitems[j].typesdiscountprice!;
        } else if (membershipData.typesitems[j].text == "Update") {
          selectedPlan = membershipData.typesitems[j].typesduration!;
          price = membershipData.typesitems[j].typesdiscountprice!;
        } else {
          selectedPlan = "";
          price = "";
        }
      }

    });*/

    return _checkmembership
        ?  Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _loading
                ? Center(
              child: LoyalityorWalletShimmer(),
            )
                :
            Align(
              alignment: Alignment.center,
              child: Container(
                constraints: (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid!):null,
                child: Column(
                  children: <Widget>[
                    /*SizedBox(
                            height: 50.0,
                          ),*/
                    Image.network(
                      postImage,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    Divider(
                      color: ColorCodes.lightskybluecolor,
                      thickness: 2,
                      endIndent: 20,
                      indent: 20,
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: ColorCodes.yellowColor,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          S .of(context).plan,//"Plan:",
                          style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          PrefUtils.prefs!.getString("membershipname")!,
                          style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       Spacer(),
                        Text(
                          Features.iscurrencyformatalign?
                          double.parse(ordertotal).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit)  + " " + IConstants.currencyFormat :
                          IConstants.currencyFormat + " " + double.parse(ordertotal).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                          style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5.0),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Divider(
                      color: ColorCodes.lightskybluecolor,
                      thickness: 2,
                      endIndent: 20,
                      indent: 20,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 45.0),
                        Icon(
                          Icons.star,
                          color: ColorCodes.yellowColor,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          S .of(context).renewal_payment,//"Renewal and Next Payment",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(80, 5, 40, 10),
                      child: Text(
                        S .of(context).membership_expire//'Your membership will expire on '
                            + expirydate +
                            S .of(context).inform_via_sms, //'. You will be informed via email or SMS and can renew only after expiry.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(height: 50),
                    /*RaisedButton(
                                   onPressed: () {},
                                   color: Color(0xFFF2BF40),
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(6),
                                   ),
                                   child: Text(
                                     'View Order Details',
                                     style: TextStyle(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.black,
                                     ),
                                   ),
                                   padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
                                 ),*/
                  ],
                ),

              ),
            ),
            /* Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.grey),
                                left: BorderSide(width: 1.0, color: Colors.grey),
                                right: BorderSide(width: 1.0, color: Colors.grey),
                              )),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Order date",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                  Expanded(
                                      child: Text(
                                    orderdate,
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Order id",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                  Expanded(
                                      child: Text(
                                    orderid,
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                ],
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Order total",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                  Expanded(
                                      child: Text(
                                    _currencyFormat + ordertotal + " ( 1 item )",
                                    style: TextStyle(fontSize: 14.0),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),*/

            /* Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Purchase Details",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),*/
            /* Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.grey),
                                left: BorderSide(width: 1.0, color: Colors.grey),
                                right: BorderSide(width: 1.0, color: Colors.grey),
                              )),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 50.0,
                                height: 50.0,
                                child: Image.asset(
                                  Images.membershipImg,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      name + " (" + duration + " Months)",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "Qty: 1",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Text(
                                _currencyFormat + " " + ordertotal,
                                style: TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),*/
            /* Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "Payment information",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),*/
            /* Container(
                          margin: EdgeInsets.all(10.0),
                          padding: EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(width: 1.0, color: Colors.grey),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.grey),
                                left: BorderSide(width: 1.0, color: Colors.grey),
                                right: BorderSide(width: 1.0, color: Colors.grey),
                              )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Payment Method",
                                style: TextStyle(
                                    fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                paytype,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Divider(),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Billing Address",
                                style: TextStyle(
                                    fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                address,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),*/
            SizedBox(height: 40,),
            if (Vx.isWeb)
              Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
          ],
        ),
      ),
    )
        : Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _loading
                ? Container(
              height: 100,
              child: Center(
                child: Container(),
              ),
            )
                :
            Align(
              alignment: Alignment.center,
              child: Container(
                constraints: (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid!):null,
                child: Column(
                  children: <Widget>[
                    if(membershipData.items.length > 0)
                      CachedNetworkImage(
                        imageUrl: membershipData.items[0].avator,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    if(membershipData.items.length > 0)
                      SizedBox(height: 10.0),
                    VxBuilder(
                        mutations: {SetCartItem},
                        builder: (ctx,store,VxStatus? state)
                        {
                     return Container(
                        //height: 400,
                        padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                        color: ColorCodes.whiteColor,//Theme.of(context).primaryColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Text(
                                  S .of(context).select_membership,//"Select the membership plan which suits your needs",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      color: ColorCodes.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin:EdgeInsets.only(left:20,right: 20),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                 // scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                  membershipData.typesitems.length,
                                  itemBuilder: (ctx, i) {
                                    return VxBuilder(
                                        mutations: {ProductMutation},
                                        builder: (context, GroceStore box, _) {
                                          for (int j = 0; j < membershipData.typesitems.length; j++) {
                                            if (!CartCalculations.checkmembershipexist) {
                                              membershipData.typesitems[j].text = "Select";
                                              membershipData.typesitems[j].backgroundcolor = ColorCodes.varcolor;
                                              membershipData.typesitems[j].textcolor = ColorCodes.primaryColor;
                                              membershipData.typesitems[j].borderColor = ColorCodes.primaryColor;

                                            } else {
                                              for (int k = 0; k < productBox.length; k++) {
                                                if (productBox[k].membershipId.toString() == membershipData.typesitems[j].typesid) {
                                                  membershipData.typesitems[j].text = "Remove";
                                                  membershipData.typesitems[j].backgroundcolor = ColorCodes.varcolor;
                                                  membershipData.typesitems[j].textcolor = ColorCodes.primaryColor;
                                                  membershipData.typesitems[j].borderColor = ColorCodes.primaryColor;

                                                } else {
                                                  membershipData.typesitems[j].text = "Update";
                                                  membershipData.typesitems[j].backgroundcolor = ColorCodes.varcolor;
                                                  membershipData.typesitems[j].textcolor = ColorCodes.primaryColor;
                                                  membershipData.typesitems[j].borderColor = ColorCodes.primaryColor;

                                                }
                                              }
                                            }

                                          }
                                          return GestureDetector(
                                            onTap: () {
                                              debugPrint("select....."+(VxState.store as GroceStore).userData.membership!);
                                              if((VxState.store as GroceStore).userData.membership! == "0" || memberMode ||
                                                  (VxState.store as GroceStore).userData.membership! == "1") {
                                                debugPrint("select.....if");
                                                setState(() {
                                                  _isselect = i;
                                                  _isAddToCart = true;
                                                });
                                                if (membershipData.typesitems[i].text == "Select") {
                                                  selectedPlan = membershipData.typesitems[i].typesduration!;
                                                  price = membershipData.typesitems[i].typesdiscountprice!;
                                                  debugPrint("select.....1");
                                                  _addtocart(
                                                    membershipData.typesitems[i].typesid!,
                                                    membershipData.typesitems[i].typesduration!,
                                                    membershipData.typesitems[i].typesdiscountprice!,
                                                    membershipData.typesitems[i].typesprice!,
                                                  );
                                                } else
                                                if (membershipData.typesitems[i].text == "Remove") {
                                                  selectedPlan = "";
                                                  price = "";
                                                  _removefromcart(membershipData.typesitems[i].typesdiscountprice!);
                                                } else {
                                                  selectedPlan = membershipData.typesitems[i].typesduration!;
                                                  price = membershipData.typesitems[i].typesdiscountprice!;
                                                  _updatetocart(
                                                    membershipData.typesitems[i].typesid!,
                                                    membershipData.typesitems[i].typesduration!,
                                                    membershipData.typesitems[i].typesdiscountprice!,
                                                    membershipData.typesitems[i].typesprice!,
                                                  );
                                                }
                                              }
                                              else {
                                                debugPrint("select.....else" + membershipData.typesitems[i].typesdiscountprice!.toString());
                                                Fluttertoast.showToast(msg: S .of(context).membership_processing,//"Your order with Membership is processing!",
                                                    fontSize: MediaQuery.of(context).textScaleFactor *13, backgroundColor: Colors.black87, textColor: Colors.white);
                                              }
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: 50,
                                              //padding: EdgeInsets.all(10),
                                              margin:
                                              EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  /*horizontal: 10*/),
                                              decoration: BoxDecoration(
                                                color: membershipData.typesitems[i].backgroundcolor,
                                                borderRadius: BorderRadius.circular(5),
                                                border: Border.all(
                                                    width: 1.0,
                                                    color:  _isselect == i?membershipData.typesitems[i].borderColor!:ColorCodes.whiteColor),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: _isAddToCart ? Center(
                                                  child: SizedBox(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      child: new CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.primaryColor),)),
                                                )
                                                    :
                                                ((membershipData.typesitems[i].typesdiscountprice == membershipData.typesitems[i].typesprice) || double.parse(membershipData.typesitems[i].typesdiscountprice!) <= 0)?
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    double.parse(membershipData.typesitems[i].typesdiscountprice!) <= 0?
                                                    Text(
                                                      Features.iscurrencyformatalign?
                                                      double.parse(membershipData.typesitems[i].typesprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit)  + " " + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + " " + double.parse(membershipData.typesitems[i].typesprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: membershipData
                                                            .typesitems[i]
                                                            .textcolor,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                      ),
                                                    ):
                                                    Text(
                                                      Features.iscurrencyformatalign?
                                                      double.parse(membershipData.typesitems[i].typesdiscountprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit)  + " " + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + " " + double.parse(membershipData.typesitems[i].typesdiscountprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: membershipData
                                                            .typesitems[i]
                                                            .textcolor,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      membershipData.typesitems[i].typesduration! + S .of(context).membership_month,//" month",
                                                      style: TextStyle(
                                                          color: membershipData.typesitems[i].textcolor,
                                                          fontSize: 18.0,
                                                          fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                )
                                                    : Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          Features.iscurrencyformatalign?
                                                          double.parse(membershipData.typesitems[i].typesdiscountprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit)  + " " + IConstants.currencyFormat:
                                                          IConstants.currencyFormat + " " + double.parse(membershipData.typesitems[i].typesdiscountprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: membershipData
                                                                .typesitems[i]
                                                                .textcolor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4,),
                                                        Text(
                                                          Features.iscurrencyformatalign?
                                                          double.parse(membershipData.typesitems[i].typesprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit)  + " " + IConstants.currencyFormat :
                                                          IConstants.currencyFormat + " " + double.parse(membershipData.typesitems[i].typesprice!).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                                          style: TextStyle(
                                                              color: membershipData
                                                                  .typesitems[i]
                                                                  .textcolor,
                                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,
                                                              decoration: TextDecoration.lineThrough,
                                                              fontWeight: FontWeight.w400

                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      membershipData.typesitems[i].typesduration !+ S .of(context).membership_month,//" month",
                                                      style: TextStyle(
                                                          color: membershipData.typesitems[i].textcolor,
                                                          fontSize: 18.0,
                                                          fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }),
                            ),
                            /* new Row(
                        children: <Widget>[
                          Expanded(
                              child: SizedBox(
                                height: 220.0,
                                child: new ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: membershipData.typesitems.length,
                                  itemBuilder: (_, i) => Expanded(
                                    child: Container(
                                      width: 170.0,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3.0),
                                            border: Border(
                                              top: BorderSide(width: 1.0, color: Colors.white),
                                              bottom: BorderSide(width: 1.0, color: Colors.white),
                                              left: BorderSide(width: 1.0, color: Colors.white),
                                              right: BorderSide(width: 1.0, color: Colors.white),
                                            )),
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Text(
                                              membershipData.typesitems[i].typesduration + " month",
                                              style: TextStyle(color: Color(0xff48b9c6), fontSize: 18.0),
                                            ),
                                            Divider(),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  _currencyFormat + " " + membershipData.typesitems[i].typesdiscountprice,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Divider(),
                                                  ValueListenableBuilder(
                                                    valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                                    builder: (context, Box<Product> box, index) {
                                                      for(int j = 0; j < membershipData.typesitems.length; j++) {
                                                        if (Calculations.checkmembershipItem == 0) {
                                                          membershipData.typesitems[j].text = "Select";
                                                          membershipData.typesitems[j].backgroundcolor = Color(0xff35a2df);
                                                          membershipData.typesitems[j].textcolor = Colors.white;
                                                        } else {
                                                          for(int k = 0; k < productBox.length; k++) {
                                                            if(productBox.values.elementAt(k).membershipId.toString() == membershipData.typesitems[j].typesid) {
                                                              membershipData.typesitems[j].text = "Remove";
                                                              membershipData.typesitems[j].backgroundcolor = Colors.white;
                                                              membershipData.typesitems[j].textcolor = Color(0xff35a2df);
                                                            } else {
                                                              membershipData.typesitems[j].text = "Update";
                                                              membershipData.typesitems[j].backgroundcolor = Color(0xff35a2df);
                                                              membershipData.typesitems[j].textcolor = Colors.white;
                                                            }
                                                          }
                                                        }
                                                      }

                                                      return GestureDetector(
                                                        onTap: () {
                                                          if (membershipData.typesitems[i].text == "Select") {
                                                            _addtocart(
                                                              membershipData.typesitems[i].typesid,
                                                              membershipData.typesitems[i].typesduration,
                                                              membershipData.typesitems[i].typesdiscountprice,
                                                              membershipData.typesitems[i].typesprice,
                                                            );
                                                          } else if(membershipData.typesitems[i].text == "Remove") {
                                                            _removefromcart();
                                                          } else {
                                                            _updatetocart(
                                                              membershipData.typesitems[i].typesid,
                                                              membershipData.typesitems[i].typesduration,
                                                              membershipData.typesitems[i].typesdiscountprice,
                                                              membershipData.typesitems[i].typesprice,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: 40.0,
                                                          margin: EdgeInsets.all(10.0),
                                                          decoration: BoxDecoration(color: membershipData.typesitems[i].backgroundcolor, borderRadius: BorderRadius.circular(3.0),
                                                              border: Border(
                                                                top: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                                bottom: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                                left: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                                right: BorderSide(width: 1.0, color: Theme.of(context).accentColor,),
                                                              )),
                                                          child: Center(
                                                              child: Text(membershipData.typesitems[i].text,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: membershipData.typesitems[i].textcolor),
                                                              )),
                                                        ),
                                                      );
                                                    },
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
                              )
                          ),
                        ],
                      ),
                      */
                          ],
                        ),
                      );
                        }),
                    SizedBox(height: 10.0),
                    (selectedPlan == "" && price == "")?SizedBox.shrink():
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0,right: 10.0),
                      child: Center(
                          child: Text("You have selected Membership of price " +
                              IConstants.currencyFormat + " " + price+" for the duration of "+selectedPlan + S .of(context).membership_month,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ColorCodes.primaryColor
                            ),
                          ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
            if (Vx.isWeb)Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
          ],
        ),
      ),
    );
  }
  gradientappbarmobile() {
    return AppBar(
      brightness: Brightness.dark,
      //toolbarHeight: 60.0,
      elevation:  (IConstants.isEnterprise)?0:1,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorCodes.iconColor),
          onPressed: ()  {
            debugPrint("acbcncn..."+addedmembership);
            if(addedmembership == "yes"){
              debugPrint("addmembership....1.."+addedmembership);
              debugPrint("entered if..");
              HomeScreenController(user: (VxState.store as GroceStore).userData.id ??
                  PrefUtils.prefs!.getString("tokenid"),
                  branch: (VxState.store as GroceStore).userData.branch ?? "999",
                  rows: "0");
              Navigator.of(context).pop();
            }else if(addedmembership == "No"){
              HomeScreenController(user: (VxState.store as GroceStore).userData.id ??
                  PrefUtils.prefs!.getString("tokenid"),
                  branch: (VxState.store as GroceStore).userData.branch ?? "999",
                  rows: "0");
              Navigator.of(context).pop();
            }else {
              debugPrint("entered else..");
              Navigator.of(context).pop();
            }
          }),
      title: Text(
        S .of(context).membership,//'Membership',
        style: TextStyle(color: ColorCodes.iconColor, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorCodes.appbarColor,
                  ColorCodes.appbarColor2
                ])),
      ),
      actions: <Widget>[
        Container(
          //  margin: EdgeInsets.only(top: 2.0, bottom: 2.0),
          child: VxBuilder(
             mutations: {SetCartItem},
            builder: (context, GroceStore box, index) {
              if (box.CartItemList.isEmpty)
                return GestureDetector(
                  onTap: () {
                    debugPrint("addedmembership..."+addedmembership);
                  /*  Navigator.of(context).pushNamed(CartScreen.routeName, arguments: {
                      "afterlogin": addedmembership
                    });*/
                    Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":addedmembership});
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
                    width: 25,
                    height: 25,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      /* color: Theme.of(context).buttonColor*/),
                    child: /*Icon(
                        Icons.shopping_cart_outlined,
                        size: 17,
                        color: Theme.of(context).primaryColor,
                      ),*/
                    Image.asset(
                      Images.header_cart,
                      height: 28,
                      width: 28,
                      color:IConstants.isEnterprise ?ColorCodes.blackColor: ColorCodes.mediumBlackWebColor,
                    ),
                  ),
                );


              return Consumer<CartCalculations>(
                builder: (_, cart, ch) => Badge(
                  child: ch!,
                  color: ColorCodes.badgecolor,
                  value: CartCalculations.itemCount.toString(),
                ),
                child: GestureDetector(
                  onTap: () {
                    debugPrint("addedmembership...1"+addedmembership);
                /*    Navigator.of(context).pushNamed(CartScreen.routeName, arguments: {
                      "afterlogin": addedmembership
                    });*/
                    Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":addedmembership});
                  },
                  child: Container(
                    /* margin: EdgeInsets.only(top: 6, right: 10, bottom: 10),*/
                    margin: EdgeInsets.only(top: 10, right: 10, bottom: 15),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      /*color: Theme.of(context).buttonColor*/),
                    child: /*Icon(
                        Icons.shopping_cart_outlined,
                        size: 17,
                        color: Theme.of(context).primaryColor,
                      ),*/
                    Image.asset(
                      Images.header_cart,
                      height: 28,
                      width: 28,
                      color: IConstants.isEnterprise && !Features.ismultivendor ?ColorCodes.blackColor: ColorCodes.mediumBlackWebColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
