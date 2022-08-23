import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:go_router/go_router.dart';
import '../../components/singleItemComponents/singel_Item_web.dart';
import '../../components/singleItemComponents/single_item_mobile.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../helper/custome_checker.dart';
import '../../models/SellingItemsModle.dart';
import '../../models/sellingitemsfields.dart';
import '../../widgets/custome_stepper.dart';
import '../../widgets/eception_widget/product_not_found.dart';
import '../../screens/banner_product_screen.dart';
import '../controller/mutations/cart_mutation.dart';
import '../models/VxModels/VxStore.dart';
import '../models/newmodle/cartModle.dart';
import '../models/newmodle/product_data.dart' as pm;
import '../repository/productandCategory/category_or_product.dart';
import '../components/ItemList/item_component.dart';
import '../components/login_web.dart';
import '../rought_genrator.dart';
import '../widgets/simmers/singel_item_of_list_shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../generated/l10n.dart';
import '../components/varint_widget.dart';
import '../screens/items_screen.dart';
import '../screens/sellingitem_screen.dart';
import '../screens/signup_selection_screen.dart';
//import '../screens/subscribe_screen.dart';
import 'package:intl/intl.dart';

import '../services/firebaseAnaliticsService.dart';
import '../widgets/simmers/singel_item_screen_shimmer.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../screens/singleproductimage_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/searchitem_screen.dart';
import '../providers/itemslist.dart';
import '../providers/sellingitems.dart';
import '../providers/branditems.dart';
import '../constants/IConstants.dart';
import '../widgets/badge_ofstock.dart';
import '../data/calculations.dart';
import '../widgets/badge.dart';
import '../assets/images.dart';
import '../widgets/header.dart';
import '../utils/prefUtils.dart';
import '../screens/home_screen.dart';
import '../constants/features.dart';
import '../assets/ColorCodes.dart';
import '../data/hiveDB.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/badge_discount.dart';
import '../widgets/footer.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'brands_screen.dart';

class SingleproductScreen extends StatefulWidget {
  static const routeName = '/singleproduct-screen';

  String _varid;
  String _productID;
  SingleproductScreen(this._varid, this._productID);

  @override
  _SingleproductScreenState createState() => _SingleproductScreenState();
}

class _SingleproductScreenState extends State<SingleproductScreen>
    with TickerProviderStateMixin, Navigations {
  bool _isLoading = true;
  var singleitemData;
  List<SellingItemsFields> singleitemvar =[];
  var multiimage=[];
  List<pm.ImageDate> varimage=[];
  bool _isWeb = Vx.isWeb;
  bool _isIOS = !Vx.isWeb&&!Vx.isAndroid;
  bool _checkmembership = false;
  var _checkmargin = true;
  var margins;
  bool _isStock = false;
  var shoplistData;
  String dropdownValue = 'One';

   String? varmemberprice;
   String? varprice;
   double? weight;
   double? netWeight;
   String? salePrice;
   String? varmrp;
   String? varid;
   String? varname;
   String? unit;
   String? varstock;
   String? varminitem;
   String? varmaxitem;
   int? varLoyalty;
   String? type;
   String? veg_type;
   int? _varQty;
   bool? discountDisplay;
   bool? memberpriceDisplay;
   Color? varcolor;
  String itemname = "";
   String? itemimg;
  String itemdescription = "";
  String itemmanufact = "";
  bool _isdescription = false;
  bool _ismanufacturer = false;
  String _displayimg = "";
  bool _similarProduct = false;
  final _form = GlobalKey<FormState>();
   List<String?> _varMarginList = <String>[];
  final _key = GlobalKey<FormState>();

   List<Tab?> tabList = [];
   TabController? _tabController;

   MediaQueryData? queryData;
   double? wid;
   double? maxwid;
  bool _isAddToCart = false;
  bool iphonex = false;
  var currentDate;
  bool _isNotify = false;
  var itemid;
  var fromScreen;
  var seeallpress;
  var notificationFor;
  bool checkskip = false;
  var mobilenum = "";
  String phone = "";
  String apple = "";
  String email = "";
  String mobile = "";
  String tokenid = "";
  String photourl = "";
  int unreadCount = 0;
   StreamController<int>? _events;
  String ea = "";
  var addressitemsData;
  var deliveryslotData;
  var delChargeData;
  var timeslotsData;
  var timeslotsindex = "0";
  var otpvalue = "";

   String? otp1, otp2, otp3, otp4;

  var day, date, time = "10 AM - 1 PM";
  var addtype;
  var address;
   IconData? addressicon;
   DateTime? pickedDate;
  GroceStore store = VxState.store;
    Future<ItemModle>? _preduct;
  List<CartItem> productBox = [];

  get _varid => widget._varid.toString();
  Uri? dynamicUrl;
  Uri? LongdynamicUrl;
  @override
  void initState() {
    _events = new StreamController<int>.broadcast();
    _events!.add(30);
    productBox =(VxState.store as GroceStore).CartItemList;
    initialRoute(()async {
      checkskip = !PrefUtils.prefs!.containsKey('apikey');

      // Provider.of<BrandItemsList>(context, listen: false).fetchShoppinglist().then((value) {
      //   final shoplistData = Provider.of<BrandItemsList>(context, listen: false);
      // });
      // setState(() {
      //   if(PrefUtils.prefs!.getString("membership") == "1"){
      //     _checkmembership = true;
      //   } else {
      //     _checkmembership = false;
      //     for (int i = 0; i < productBox.length; i++) {
      //       if (productBox[i].mode == "1") {
      //         _checkmembership = true;
      //       }
      //     }
      //   }
      // });

      // final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      //  // itemid = routeArgs['itemid'];
      //  fromScreen = routeArgs['fromScreen'];
      //  seeallpress=routeArgs['seeallpress'];
      //   notificationFor = routeArgs['notificationFor'];
      debugPrint("varid........"+widget._varid.toString()+"  "+widget._productID.toString());
      _preduct = ProductRepo().getRecentProduct(widget._productID.toString());
      debugPrint("_preduct..."+await _preduct.toString());
      ProductController().getprodut(widget._varid.toString(),"").whenComplete(() {
      createShareLink(widget._varid,widget._productID);
      setState(() {
      _isLoading= false;
      });
      // setState(() {
      //   _preduct = ProductRepo().getRecentProduct((VxState.store as GroceStore).productlist.first.id);
      // });
      });
      final now = new DateTime.now();
      currentDate = DateFormat('dd/MM/y').format(now);
    });
    super.initState();
  }

  void dispose() {
    // _tabController!.dispose();
    super.dispose();
  }

  addListnameToSF(String value) async {
    PrefUtils.prefs!.setString('list_name', value);
  }

  _saveFormTwo() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState!.save();
    Navigator.of(context).pop();
    _dialogforProceesing(context, S.current.creating_list);

    Provider.of<BrandItemsList>(context, listen: false).CreateShoppinglist().then((_) {
      Provider.of<BrandItemsList>(context, listen: false).fetchShoppinglist().then((_) {
        shoplistData = Provider.of<BrandItemsList>(context, listen: false);
        Navigator.of(context).pop();
        _dialogforShoppinglistTwo(context);
      });
    });
  }

  additemtolistTwo() {
    final shoplistDataTwo = Provider.of<BrandItemsList>(context, listen: false);
    _dialogforProceesing(context, "Add item to list...");
    for (int i = 0; i < shoplistDataTwo.itemsshoplist.length; i++) {
      //adding item to multiple list
      if (shoplistDataTwo.itemsshoplist[i].listcheckbox == true) {
        addtoshoppinglisttwo(i);
      }
    }
  }

  addtoshoppinglisttwo(i) async {
    final shoplistDataTwo = Provider.of<BrandItemsList>(context, listen: false);
    final routeArgs =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final itemid = routeArgs['itemid'];

    Provider.of<BrandItemsList>(context, listen: false).AdditemtoShoppinglist(
        itemid.toString(), varid.toString(), shoplistDataTwo.itemsshoplist[i].listid!).then((_) {
      Provider.of<BrandItemsList>(context, listen: false).fetchShoppinglist().then((_) {
        shoplistData = Provider.of<BrandItemsList>(context, listen: false);
        Navigator.of(context).pop();
      });
    });
  }

  _dialogforProceesing(BuildContext context, String text) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  height: 100.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        width: 40.0,
                      ),
                      Text(text),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforCreatelistTwo(BuildContext context, shoplistData) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  height: 250.0,
                  margin: EdgeInsets.only(
                      left: 20.0, top: 10.0, right: 10.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.current.create_shopping_list,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Form(
                        key: _form,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return S.current.please_enter_list_name;
                                }
                                return null; //it means user entered a valid input
                              },
                              onSaved: (value) {
                                addListnameToSF(value!);
                              },
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: S.current.shopping_list_name,
                                labelStyle: TextStyle(
                                    color: Theme
                                        .of(context)
                                        .accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'ex: Monthly Grocery',
                                hintStyle: TextStyle(
                                    color: Colors.black12, fontSize: 10.0),
                                //prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          _saveFormTwo();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                S.current.shopping_list_name,
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(color: Theme
                                    .of(context)
                                    .buttonColor),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                S.current.cancel,
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(color: Theme
                                    .of(context)
                                    .buttonColor),
                              )),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforShoppinglistTwo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          final x = Provider.of<BrandItemsList>(context, listen: false);
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 10.0, top: 20.0, right: 10.0, bottom: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          S.current.add_to_list,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        SizedBox(
                          child: new ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: x.itemsshoplist.length,
                            itemBuilder: (_, i) =>
                                Row(
                                  children: [
                                    Checkbox(
                                      value: x.itemsshoplist[i].listcheckbox,
                                      onChanged: ( bool? value) async {
                                        setState(() {
                                          x.itemsshoplist[i].listcheckbox = value;
                                        });
                                      },
                                    ),
                                    Text(x.itemsshoplist[i].listname!,
                                        style: TextStyle(fontSize: 18.0)),
                                  ],
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();

                            _dialogforCreatelistTwo(context, shoplistData);

                            for (int i = 0; i < x.itemsshoplist.length; i++) {
                              x.itemsshoplist[i].listcheckbox = false;
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10.0,
                              ),
                              Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                S.current.create_new,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            bool check = false;
                            for (int i = 0; i < x.itemsshoplist.length; i++) {
                              if (x.itemsshoplist[i].listcheckbox!)
                                setState(() {
                                  check = true;
                                });
                            }
                            if (check) {
                              Navigator.of(context).pop();
                              additemtolistTwo();
                            } else {
                              Fluttertoast.showToast(
                                  msg: S.current.please_select_atleastonelist,
                                  fontSize: MediaQuery.of(context).textScaleFactor *13,
                                  backgroundColor: Colors.black87,
                                  textColor: Colors.white);
                            }
                          },
                          child: Container(
                            width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                            // color: Theme.of(context).primaryColor,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Center(
                                child: Text(
                                  S.current.add,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .buttonColor),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            for (int i = 0; i < x.itemsshoplist.length; i++) {
                              x.itemsshoplist[i].listcheckbox = false;
                            }
                          },
                          child: Container(
                            width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                            // color: Theme.of(context).primaryColor,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Center(
                                child: Text(
                                  S.current.cancel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .buttonColor),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          });
        });
  }

  Widget handler( int i) {
    if (int.parse(singleitemvar[i].varstock!) <= 0) {
      return (varid == singleitemvar[i].varid) ?
      Icon(
          Icons.radio_button_checked_outlined,
          color: ColorCodes.grey)
          :
      Icon(
          Icons.radio_button_off_outlined,
          color: ColorCodes.grey);

    } else {
      return (varid == singleitemvar[i].varid) ?
      Icon(
          Icons.radio_button_checked_outlined,
          color: ColorCodes.mediumBlueColor)
          :
      Icon(
          Icons.radio_button_off_outlined,
          color: ColorCodes.blackColor);
    }
  }

  @override
  Widget build(BuildContext context) {

    queryData = MediaQuery.of(context);
    wid= queryData!.size.width;
    maxwid=wid!*0.90;
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
    if (sellingitemData.itemsnew.length <= 0) {
      _similarProduct = false;
    } else {
      _similarProduct = true;
    }

    return  WillPopScope(
        onWillPop: () { // this is the block you need
          if(GoRouter.of(context).navigator!.canPop())
            Navigation(context, navigatore: NavigatoreTyp.Pop);
          else
            Navigation(context, navigatore: NavigatoreTyp.homenav,);
      return Future.value(false);

    },
    child: Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      AppBarMobile(routeArgs,sellingitemData) : null,
      backgroundColor: Colors.white,
      body:_isLoading?SingelItemScreenShimmer():VxBuilder(builder: (context,GroceStore store,state){
        // switch(state){
        //
        //   case VxStatus.none:
        //     // TODO: Handle this case.
        //     break;
        //   case VxStatus.loading:
        //     // TODO: Handle this case.
        //     break;
        //   case VxStatus.success:
        //     // TODO: Handle this case.
        //     break;
        //   case VxStatus.error:
        //     // TODO: Handle this case.
        //     break;
        // }
       /* if(state==VxStatus.loading)
          return Container();*/
       if (store.singelproduct!=null&&store.singelproduct!.toJson().isNotEmpty) {
         return ResponsiveLayout.isSmallScreen(context) ?
         SingleItemMobileComponent(similarProduct: _preduct,
             product: store.singelproduct!,
             variationId: widget._varid.toString(),
             iphonex: iphonex) :
         SingleItemWebComponent(similarProduct: _preduct,
           product: store.singelproduct!,
           variationId: widget._varid.toString(),);
       }else {
         return ProductNotFound();
       }

    }, mutations: {ProductMutation},),

    ));
  }
  Future<String> createShareLink(String singleProduct, String productID) async {
   // debugPrint("yes..."+store.singelproduct!.itemFeaturedImage.toString());
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
        uriPrefix: 'https://gbay.page.link',
        link: Uri.parse('${IConstants.AppDomain}/store/product/$singleProduct/$productID'),
        androidParameters: AndroidParameters(
          packageName: IConstants.androidId,
        ),
        iosParameters: IOSParameters(
            bundleId: IConstants.androidId,
            appStoreId: IConstants.appleId
        ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: store.singelproduct!=null?store.singelproduct!.item_description:"",
        //  description: store.singelproduct!=null?store.singelproduct!.item_description:"",
          imageUrl: Uri.parse(/*"https://demo.grocbay.com/uploads/items/images/potato.webp"*/store.singelproduct!.itemFeaturedImage.toString())),
    );

//Short link
   final ShortDynamicLink shortLink = await (await FirebaseDynamicLinks.instance).buildShortLink(dynamicLinkParameters);
    dynamicUrl = shortLink.shortUrl;

//Long link
 //  dynamicUrl = await (FirebaseDynamicLinks.instance).buildLink(dynamicLinkParameters);

    debugPrint("share..........product.......");
    print(dynamicUrl);
    return dynamicUrl.toString();
  }
  AppBarMobile(Map<String, dynamic> routeArgs, SellingItemsList sellingitemData){
    return  AppBar(
      toolbarHeight: 55.0,
      elevation: (IConstants.isEnterprise)?0:1,
      automaticallyImplyLeading: false,
      title: Text(_isLoading?"":store.singelproduct!=null&&store.singelproduct!.toJson().isNotEmpty?store.singelproduct!.itemName.toString():"",style: TextStyle(color: ColorCodes.iconColor, fontWeight: FontWeight.bold, fontSize: 18),),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color:ColorCodes.iconColor),
        onPressed: () {
            String routeName = "";
          var route = ModalRoute.of(context);
        /*  if(route!=null){
            print("current route....."+route.settings.name!+"   "+Routename.SingleProduct.name);
            if(route.settings.name! == "product"){

            }
          }*/
          if(GoRouter.of(context).navigator!.canPop())
             Navigation(context, navigatore: NavigatoreTyp.Pop);
            //Navigation(context, navigatore: NavigatoreTyp.PopUntill,name: Routename.SellingItem);
          else
            Navigation(context, navigatore: NavigatoreTyp.homenav,);
          /*       var title;
          if(seeallpress=="featured"){
            title =(VxState.store as GroceStore).homescreen.data!.featuredByCart!.label;
          }else if(seeallpress=="offers"){
            title =(VxState.store as GroceStore).homescreen.data!.offerByCart!.label;
          }else if(seeallpress=="discount"){
            title =(VxState.store as GroceStore).homescreen.data!.discountByCart!.label;
          }
          switch(fromScreen){
            case "sellingitem_screen":
              Navigator.of(context)
                  .pushReplacementNamed(SellingitemScreen.routeName, arguments: {
                'seeallpress': seeallpress,
                'title': title,
              });
            *//*  Navigator.of(context).pushReplacementNamed(ItemsScreen.routeName, arguments: {
                'maincategory': routeArgs['maincategory'],
                'catId':  routeArgs['catId'],
                'catTitle':  routeArgs['catTitle'],
                'subcatId':  routeArgs['subcatId'],
                'indexvalue': routeArgs['indexvalue'],
                'prev': routeArgs['prev'],
              });*//*

              break;
            case "not_product_screen":
             // Navigator.of(context).pop();
              final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              final type = routeArgs['type'];
              final id = routeArgs['id'].toString();
              Navigator.of(context).pushReplacementNamed(
                  BannerProductScreen.routeName,
                  arguments: {
                    "id" : routeArgs['notid'],
                    'type': seeallpress
                  }
              );
              break;
            case "item_screen":
              if(seeallpress == "category") {
                Navigator.of(context).pushReplacementNamed(
                    BannerProductScreen.routeName,
                    arguments: {
                      "id" : routeArgs['notid'],
                      'type': seeallpress
                    }
                );
              }else{
                Navigator.of(context).pushReplacementNamed(
                    ItemsScreen.routeName, arguments: {
                  'maincategory': routeArgs['maincategory'],
                  'catId': routeArgs['catId'],
                  'catTitle': routeArgs['catTitle'],
                  'subcatId': routeArgs['subcatId'],
                  'indexvalue': routeArgs['indexvalue'],
                  'prev': routeArgs['prev'],
                });
              }
              break;
            case "brands_screen":
              Navigator.of(context).pushReplacementNamed(BrandsScreen.routeName, arguments: {
                "indexvalue":routeArgs['indexvalue'],
                "brandId":routeArgs['brandId'],
              });
              break;
            case "searchitem_screen":
              Navigator.of(context).pop();
              break;
            case "sellingitem_screen":
              Navigator.of(context)
                  .pushReplacementNamed(SellingitemScreen.routeName, arguments: {
                'seeallpress': seeallpress,
                'title': title,
              });
              break;
            case "shoppinglistitem_screen":
              Navigator.of(context).pop();
              break;
            case "home_screen" :
              Navigator.of(context).pop();
              break;
            case "search_item" :
              // Navigator.of(context).pushNamed(SearchitemScreen.routeName);
             Navigator.of(context).pop();
              break;
            case "featured"  :
              Navigator.of(context)
                  .pushReplacementNamed(SellingitemScreen.routeName, arguments: {
                'seeallpress': "featured",
                'title': (VxState.store as GroceStore).homescreen.data!.featuredByCart!.label
              });
              break;
            case "offers" :
              Navigator.of(context).pop();
              break;
            case "home_screen" :
              Navigator.of(context).pop();
              break;
            case "Discount" :
              Navigator.of(context).pop();
              break;
            case "singleproduct_screen" :
              Navigator.of(context).pop();
              break;
            case "Forget" :
              Navigator.of(context).pop();
              break;
            case "NotificationScreen":
              Navigator.of(context).pop();
              break;
          }*/

          // Navigator.of(context).pop();
        },
      ),
      actions: [
        // Container(
        //   width: 25,
        //   height: 25,
        //   margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(100),
        //    // color: Colors.white,
        //   ),
        //   child: GestureDetector(
        //     onTap: () {
        //       Navigator.of(context).pushNamed(
        //         SearchitemScreen.routeName,
        //       );
        //     },
        //     child: Icon(
        //       Icons.search,
        //       size: 20,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   width: 15,
        // ),
        if(Features.isShare)
          Container(
            width: 25,
            height: 25,
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
             // color: Colors.white,
            ),
            child: GestureDetector(
              onTap: () {
               // Navigator.of(context).pop();
                if (_isIOS) {
                  Share.share(S.current.download_app +
                      IConstants.APP_NAME +
                      '${S.current.from_app_store} https://apps.apple.com/us/app/id' + IConstants.appleId);
                } else {
                /*  Share.share(S.current.download_app +
                      IConstants.APP_NAME +
                      '${S.current.from_google_play_store} https://play.google.com/store/apps/details?id=' + IConstants.androidId);*/

                  Share .share('Check out '+store.singelproduct!.itemName.toString()  +' on '+IConstants.APP_NAME+". "+"\n"+dynamicUrl.toString());
                }
              },
              child: Icon(
                Icons.share_outlined,
                size: 20,
                color: ColorCodes.iconColor,
              ),
            ),
          ),
        if(Features.isShare)
        SizedBox(width: 15,),
        if(Features.isShoppingList && !Features.ismultivendor)
          (PrefUtils.prefs!.containsKey("apikey"))?
          Container(
          width: 25,
          height: 25,
          margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
           // color: Colors.white,
          ),
          child: GestureDetector(
            onTap: () {
              final shoplistData = Provider.of<BrandItemsList>(context, listen: false);

              if (shoplistData.itemsshoplist.length <= 0) {
                _dialogforCreatelistTwo(context, shoplistData);
              } else {
                _dialogforShoppinglistTwo(context);
              }
            },
            child: /*Icon(
              Icons.add,
              size: 18,
              color: Theme
                  .of(context)
                  .primaryColor,
            )*/Image.asset(
              Images.addToListImg,width: 25,height: 25,color: ColorCodes.iconColor),
          ),
        ):
        SizedBox.shrink(),
        if(Features.isShoppingList)
        SizedBox(
          width: 15,
        ),
        VxBuilder(
          mutations: {SetCartItem},
          // valueListenable: Hive.box<Product>(productBoxName).listenable(),
          builder: (context,GroceStore store, index) {
            final box = (VxState.store as GroceStore).CartItemList;

            if (box.isEmpty)
              return GestureDetector(
                onTap: () {
                 /*  Navigator.of(context).pushNamed(CartScreen.routeName,arguments: {
                     "afterlogin": ""
                   });*/
                  Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                     /* color: Theme.of(context).buttonColor*/),
                  child:   Image.asset(
                    Features.ismultivendor?Images.MultivendorCart:Images.header_cart,
                    height: 28,
                    width: 28,
                    color: ColorCodes.iconColor,
                  ),
                ),
              );


            return Consumer<CartCalculations>(
              builder: (_, cart, ch) => Badge(
                child: ch!,
                color:  ColorCodes.badgecolor,
                value: CartCalculations.itemCount.toString(),
              ),
              child: GestureDetector(
                onTap: () {
            /*      Navigator.of(context).pushNamed(CartScreen.routeName,arguments: {
                    "afterlogin": ""
                  });*/
                  Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                     /* color: Theme.of(context).buttonColor*/),
                  child: Image.asset(
                    Features.ismultivendor?Images.MultivendorCart:Images.header_cart,
                    height: 28,
                    width: 28,
                    color: ColorCodes.iconColor,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(width: 10,)
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  ColorCodes.appbarColor,
                  ColorCodes.appbarColor2
                ])
        ),
      ),
    );
  }

  @override
  onloaddata() {
    print("Home Screen Loaded In Singel product screen");
    productBox =(VxState.store as GroceStore).CartItemList;
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
            _isIOS = true;
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
        } else {
          setState(() {
            _isWeb = false;
          });
        }
      } catch (e) {
        setState(() {
          _isWeb = true;
        });
      }
      checkskip = !PrefUtils.prefs!.containsKey('apikey');

      // Provider.of<BrandItemsList>(context, listen: false).fetchShoppinglist().then((value) {
      //   final shoplistData = Provider.of<BrandItemsList>(context, listen: false);
      // });
      // setState(() {
      //   if(PrefUtils.prefs!.getString("membership") == "1"){
      //     _checkmembership = true;
      //   } else {
      //     _checkmembership = false;
      //     for (int i = 0; i < productBox.length; i++) {
      //       if (productBox[i].mode == "1") {
      //         _checkmembership = true;
      //       }
      //     }
      //   }
      // });

      // final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      //  // itemid = routeArgs['itemid'];
      //  fromScreen = routeArgs['fromScreen'];
      //  seeallpress=routeArgs['seeallpress'];
      //   notificationFor = routeArgs['notificationFor'];
      debugPrint("varid........"+widget._varid.toString()+"  "+widget._productID.toString());
      _preduct = ProductRepo().getRecentProduct(widget._productID.toString());
      debugPrint("_preduct..."+await _preduct.toString());
      ProductController().getprodut(widget._varid.toString(),"").whenComplete(() {
        createShareLink(widget._varid,widget._productID);
        setState(() {
          _isLoading= false;
        });
        // setState(() {
        //   _preduct = ProductRepo().getRecentProduct((VxState.store as GroceStore).productlist.first.id);
        // });
      });
      final now = new DateTime.now();
      currentDate = DateFormat('dd/MM/y').format(now);
    });
    // TODO: implement onloaddata
    // throw UnimplementedError();
  }
}
