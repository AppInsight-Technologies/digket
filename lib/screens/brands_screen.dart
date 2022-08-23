import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import '../../components/sellingitem_component.dart';
import '../../rought_genrator.dart';
import '../../widgets/simmers/ItemWeb_shimmer.dart';
import '../controller/mutations/cart_mutation.dart';
import '../controller/mutations/cat_and_product_mutation.dart';
import '../models/VxModels/VxStore.dart';
import 'package:velocity_x/velocity_x.dart';

import '../generated/l10n.dart';
import '../widgets/bottom_navigation.dart';

import '../constants/features.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/simmers/item_list_shimmer.dart';

import '../constants/IConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../data/calculations.dart';
import '../providers/branditems.dart';
import '../screens/cart_screen.dart';
import '../assets/images.dart';
import '../utils/prefUtils.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../utils/ResponsiveLayout.dart';
import '../assets/ColorCodes.dart';

class BrandsScreen extends StatefulWidget {
  static const routeName = '/brands-screen';
  Map<String, String> queryParams;
  BrandsScreen(this.queryParams);
  @override
  _BrandsScreenState createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<BrandsScreen>, Navigations {
  int startItem = 0;
  bool isLoading = true;
  var load = true;
  var brandslistData;
  int previndex = -1;
  String? indvalue;
  var _checkitem = false;
  bool _checkmembership = false;
  final ItemScrollController _scrollController = ItemScrollController();
  bool endOfProduct = false;
  bool _isOnScroll = false;
  String brandId = "";
  //SharedPreferences prefs;
  var brandsData;
  bool _isWeb = false;

  MediaQueryData? queryData;
  double? wid;
  double? maxwid;

  String? indexvalue;
  bool iphonex = false;
  ProductController productController = ProductController();

  _displayitem(String brandid, int index) {
    debugPrint("brandid...."+brandid);
    setState(() {
      isLoading = true;
      brandId = brandid;
    });

/*    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    setState(() {
      brandId = brandid;
      endOfProduct = false;
      load = true;
      _checkitem = false;
      startItem = 0;
      indexvalue =index.toString();
    });
      for (int i = 0; i < brandsData.items.length; i++) {
        if (index != i) {
          brandsData.items[i].boxbackcolor = Theme.of(context).buttonColor;
          brandsData.items[i].boxsidecolor =
              Theme.of(context).textSelectionTheme.selectionColor;
          brandsData.items[i].textcolor =
              Theme.of(context).textSelectionTheme.selectionColor;
        } else {
          brandsData.items[i].boxbackcolor = Theme.of(context).accentColor;
          brandsData.items[i].boxsidecolor = Theme.of(context).accentColor;
          brandsData.items[i].textcolor = Theme.of(context).buttonColor;
        }
      }*/
      productController.getbrandprodutlist(brandid, 0,(isendofproduct){
        setState(() {
          isLoading = false;
         indexvalue =  index.toString();
          indvalue =  index.toString();
          endOfProduct = false;
        });
      });
   /*   Provider.of<BrandItemsList>(context, listen: false)
          .fetchBrandItems(brandId, startItem, "initialy")
          .then((_) {
            debugPrint("initially....");
        brandsData = Provider.of<BrandItemsList>(context, listen: false);
        startItem = brandsData.branditems.length;
        setState(() {
          debugPrint("initially....1");
          load = false;
          if (brandsData.branditems.length <= 0) {
            debugPrint("initially....2");
            _checkitem = false;
          } else {
            debugPrint("initially....3");
            _checkitem = true;
          }
        });
      });*/

  }

  @override
  void initState() {
    print("inside init");
    // _scrollController = ItemScrollController();
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
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
      //prefs = await SharedPreferences.getInstance();
      setState(() {
        if (PrefUtils.prefs!.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });

      // final routeArgs =
      //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
       indexvalue = widget.queryParams['indexvalue'];
      indvalue = (widget.queryParams['indexvalue']??"0");
setState(() {
  brandsData = Provider.of<BrandItemsList>(context, listen: false);
  for (int i = 0; i < brandsData.items.length; i++) {
    if (int.parse(indexvalue!) != i) {
      brandsData.items[i].boxbackcolor = Theme.of(context).buttonColor;
      brandsData.items[i].boxsidecolor =
          Theme.of(context).textSelectionTheme.selectionColor;
      brandsData.items[i].textcolor =
          Theme.of(context).textSelectionTheme.selectionColor;
    } else {
      brandsData.items[i].boxbackcolor = Theme.of(context).accentColor;
      brandsData.items[i].boxsidecolor = Theme.of(context).accentColor;
      brandsData.items[i].textcolor = Theme.of(context).buttonColor;
    }
  }
  setState(() {
    brandId = widget.queryParams['brandId']!;
  });

      ProductController productController = ProductController();
  productController.getbrandprodutlist(brandId, 0,(isendofproduct){
    setState(() {
      isLoading =false;
      endOfProduct = false;
    });

    Future.delayed(Duration.zero, () async {
          _scrollController.jumpTo(index: int.parse(indexvalue!));
    });
  });
/*  Provider.of<BrandItemsList>(context, listen: false)
      .fetchBrandItems(brandId, startItem, "initialy")
      .then((_) {
    debugPrint("initially....4");
    load = false;
    brandslistData = Provider.of<BrandItemsList>(context, listen: false);
    startItem = brandslistData.branditems.length;
    if (brandslistData.branditems.length <= 0) {
      debugPrint("initially....5");
      setState(() {
        _checkitem = false;
      });
    } else {
      setState(() {
        debugPrint("initially....6");
        _checkitem = true;
      });
    }
    Future.delayed(Duration.zero, () async {
      _scrollController.jumpTo(index: int.parse(indexvalue),
        *//*duration: Duration(seconds: 1)*//*);
});

        });*/
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   final brandsData =(VxState.store as GroceStore).homescreen.data!.allBrands;

    _buildBottomNavigationBar() {
      return VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context,GroceStore store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          if (box.isEmpty) return SizedBox.shrink();
          return BottomNaviagation(
            itemCount: CartCalculations.itemCount.toString() + " " + S .of(context).items,
            title: S .current.view_cart,
            total: _checkmembership ? (IConstants.numberFormat == "1")
                ?(CartCalculations.totalMember).toStringAsFixed(0):(CartCalculations.totalMember).toStringAsFixed(IConstants.decimaldigit)
                :
            (IConstants.numberFormat == "1")
                ?(CartCalculations.total).toStringAsFixed(0):(CartCalculations.total).toStringAsFixed(IConstants.decimaldigit),
            onPressed: (){
              setState(() {
              /*  Navigator.of(context)
                    .pushNamed(CartScreen.routeName,arguments: {
                  "afterlogin": ""
                });*/
                Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
              });
            },
          );
          // return Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: 50.0,
          //   child: Row(
          //     mainAxisSize: MainAxisSize.max,
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: <Widget>[
          //       Container(
          //         height:50,
          //         width:MediaQuery.of(context).size.width * 35/100,
          //         color: Theme.of(context).primaryColor,
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: <Widget>[
          //             /*SizedBox(
          //               height: 15.0,
          //             ),*/
          //             _checkmembership
          //                 ?
          //             Text(S .of(context).total
          //       //'Total: '
          //   + IConstants.currencyFormat + (Calculations.totalMember).toStringAsFixed(IConstants.decimaldigit), style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),)
          //                 :
          //             Text(S .of(context).total
          //               //'Total: '
          //                   + IConstants.currencyFormat + (Calculations.total).toStringAsFixed(IConstants.decimaldigit), style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
          //             Text(Calculations.itemCount.toString() + S .of(context).item
          //              //   " item"
          //               , style: TextStyle(color:Colors.green,fontWeight: FontWeight.w400,fontSize: 9),)
          //           ],
          //         ),),
          //       MouseRegion(
          //         cursor: SystemMouseCursors.click,
          //         child: GestureDetector(
          //             onTap: () =>
          //             {
          //               setState(() {
          //                 Navigator.of(context).pushNamed(CartScreen.routeName);
          //               })
          //             },
          //             child: Container(color: Theme.of(context).primaryColor, height:50,width:MediaQuery.of(context).size.width*65/100,
          //                 child:Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                     crossAxisAlignment: CrossAxisAlignment.center,
          //                     children:[
          //                   SizedBox(height: 17,),
          //                   Text(S .of(context).view_cart
          //                     //'VIEW CART'
          //                     , style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          //                   Icon(
          //                     Icons.arrow_right,
          //                     color: ColorCodes.whiteColor,
          //                   ),
          //                 ]
          //                 )
          //
          //             )
          //         ),
          //       ),
          //     ],
          //   ),
          // );
        },
      );
    }

    return DefaultTabController(
      length: brandsData!.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: ResponsiveLayout.isSmallScreen(context)   ?_appBarMobile() : PreferredSize(preferredSize: Size.fromHeight(0),
        child: SizedBox.shrink()),
        body:
          Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            SizedBox(
              height: 10.0,
            ),
            isLoading?SizedBox.shrink():Container(
              child: SizedBox(
                height: 60,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: brandsData.length,
                  itemBuilder: (_, i) => Column(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            _displayitem(brandsData[i].id!, i);
                            Future.delayed(const Duration(seconds: 1), () async {
                              _scrollController.jumpTo(index: int.parse(i.toString()));
                            });

                          },
                          child: Container(
                            height: 45,
                            margin: EdgeInsets.only(left: 3.0, right: 3.0),
                            decoration: BoxDecoration(
                                color: (i.toString() !=indvalue.toString())?ColorCodes.whiteColor:ColorCodes.varcolor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    width: 1.0,
                                    color: (i.toString() !=indvalue.toString())? ColorCodes.grey:ColorCodes.greenColor,


                                  // top: BorderSide(
                                  //   width: 1.0,
                                  //   color:(i.toString() !=indexvalue.toString())? ColorCodes.blackColor:Theme.of(context).accentColor,
                                  // ),
                                  // bottom: BorderSide(
                                  //   width: 1.0,
                                  //   color: (i.toString() !=indexvalue.toString())? ColorCodes.blackColor:Theme.of(context).accentColor,
                                  // ),
                                  // left: BorderSide(
                                  //   width: 1.0,
                                  //   color:(i.toString() !=indexvalue.toString())? ColorCodes.blackColor:Theme.of(context).accentColor,
                                  // ),
                                  // right: BorderSide(
                                  //   width: 1.0,
                                  //   color:(i.toString() !=indexvalue.toString())? ColorCodes.blackColor:Theme.of(context).accentColor,
                                  // ),
                                )),
                            child: Padding(
                              padding:
                              EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CachedNetworkImage(
                                    imageUrl: brandsData[i].iconImage,
                                    placeholder: (context, url) =>
                                        Image.asset(
                                          Images.defaultCategoryImg,
                                          height: 40,
                                          width: 40,
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          Images.defaultCategoryImg,
                                          width: 40,
                                          height: 40,
                                        ),
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),



                                  Text(
                                   // snapshot.data[i].categoryName,
                                   brandsData[i].categoryName!,
//                            textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                        color:(i.toString() !=indvalue.toString())? ColorCodes.grey:ColorCodes.greenColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
//
//            Container(
//               child:   StreamBuilder(
//                 stream: bloc.brandfiledBloc,
//                 builder: (context, AsyncSnapshot<List<BrandsFieldModel>> snapshot){
//                   if(snapshot.hasData){
//                     return SizedBox(
//                       height: 60,
//                       child: ScrollablePositionedList.builder(
//                         itemScrollController: _scrollController,
//                         scrollDirection: Axis.horizontal,
//                         itemCount: snapshot.data.length,
//                         itemBuilder: (_, i) => Column(
//                           children: [
//                             SizedBox(
//                               width: 10.0,
//                             ),
//                             MouseRegion(
//                               cursor: SystemMouseCursors.click,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   _displayitem(snapshot.data[i].id, i);
//                                 },
//                                 child: Container(
//                                   height: 40,
// //                      width:150,
//                                   margin: EdgeInsets.only(left: 5.0, right: 5.0),
//                                   decoration: BoxDecoration(
//                                       color: (int.parse(indexvalue) != i)?Colors.transparent:Theme.of(context).primaryColor,
//                                       borderRadius: BorderRadius.circular(3.0),
//                                       border: Border(
//                                         top: BorderSide(
//                                           width: 1.0,
//                                           color: (int.parse(indexvalue) != i)? ColorCodes.blackColor:Theme.of(context).primaryColor,
//                                         ),
//                                         bottom: BorderSide(
//                                           width: 1.0,
//                                           color: (int.parse(indexvalue) != i)? ColorCodes.blackColor:Theme.of(context).primaryColor,
//                                         ),
//                                         left: BorderSide(
//                                           width: 1.0,
//                                           color: (int.parse(indexvalue) != i)? ColorCodes.blackColor:Theme.of(context).primaryColor,
//                                         ),
//                                         right: BorderSide(
//                                           width: 1.0,
//                                           color: (int.parse(indexvalue) != i)? ColorCodes.blackColor:Theme.of(context).primaryColor,
//                                         ),
//                                       )),
//                                   child: Padding(
//                                     padding: EdgeInsets.only(left: 20.0, right: 20.0),
//                                     child: Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: <Widget>[
//                                         Text(
//                                           snapshot.data[i].categoryName,
// //                            textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                               color: (int.parse(indexvalue) != i)? ColorCodes.blackColor:Theme.of(context).buttonColor),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               width: 10.0,
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     );}
//                   if(snapshot.hasError){
//                     return SizedBox.shrink();}
//                   else return _sliderShimmer();
//                 },
//               ),
//             ),
          _body(),
             //

          ],
        ),
        bottomNavigationBar: _isWeb?SizedBox.shrink():Padding(
    padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
    child:_buildBottomNavigationBar(),
        ),
    ),
    );
  }
  _body(){
    return _isWeb ? _bodyweb() :
    _bodyMobile();
  }
  Widget _sliderShimmer() {
    return _isWeb ?
    SizedBox.shrink()
        :
    Shimmer.fromColors(
        baseColor: ColorCodes.baseColor,
        highlightColor: ColorCodes.lightGreyWebColor,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10.0,
            ),
            new Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              height: 150.0,
              width: MediaQuery.of(context).size.width - 20.0,
              color: Colors.white,
            ),
          ],
        ));
  }
  Widget _bodyweb(){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (Features.isSubscription)?(deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 392:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 290:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 170;
    // return
    return /*load
        ?(_isWeb && !ResponsiveLayout.isSmallScreen(context))? Center(
      child: CircularProgressIndicator(),
    ): ItemListShimmer()
        :_checkitem
        ?*/ /*Flexible(
      // fit: FlexFit.loose,
      child: SingleChildScrollView(
        child: NotificationListener<ScrollNotification>(
          // ignore: missing_return
            onNotification: (ScrollNotification scrollInfo) {
              if (!endOfProduct) if (!_isOnScroll &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                setState(() {
                  _isOnScroll = true;
                });
                Provider.of<BrandItemsList>(context, listen: false).fetchBrandItems(
                    brandId, startItem, "scrolling")
                    .then((_) {
                  setState(() {
                    //itemslistData = Provider.of<ItemsList>(context, listen: false);
                    startItem = brandslistData.branditems.length;
                    if (PrefUtils.prefs!.getBool("endOfProduct")) {
                      _isOnScroll = false;
                      endOfProduct = true;
                      isLoading = false;
                    } else {
                      isLoading = false;
                      _isOnScroll = false;
                      endOfProduct = false;
                    }
                  });
                });

              }
            },
            child: Align(
              child: Column(
                children: <Widget>[
                  GridView.builder(
                      shrinkWrap: true,
                      controller: new ScrollController(
                          keepScrollOffset: true),
                      itemCount:
                      brandslistData.branditems.length,
                      gridDelegate:
                      new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widgetsInRow,
                        crossAxisSpacing: 3,
                        childAspectRatio: aspectRatio,
                        mainAxisSpacing: 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final routeArgs =
                        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
                        return SellingItems(
                          "brands_screen",
                          brandslistData.branditems[index].id,
                          brandslistData.branditems[index].title,
                          brandslistData.branditems[index].imageUrl,
                          brandslistData.branditems[index].brand,
                          "",
                          brandslistData.branditems[index].veg_type,
                          brandslistData.branditems[index].type,
                          brandslistData.branditems[index].eligible_for_express,
                          brandslistData.branditems[index].delivery,
                          brandslistData.branditems[index].duration,
                          brandslistData.branditems[index].durationType,
                          brandslistData.branditems[index].note,
                          brandslistData.branditems[index].subscribe,
                          brandslistData.branditems[index].paymentmode,
                          brandslistData.branditems[index].cronTime,
                          brandslistData.branditems[index].name,

                          returnparm: {
                            "indexvalue": indexvalue,
                            "brandId": brandId,
                          },
                        );
                      }),
                  if (endOfProduct)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                      margin: EdgeInsets.only(top: 10.0),
                      // width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          top: 25.0, bottom: 25.0),
                      child: Text(
                        S .of(context).thats_all_folk,
                      //  "That's all folks!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                 // if(endOfProduct)
                    if (_isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")),
                ],
              ),
            )),
      ),
    )*/
    Flexible(
      fit: FlexFit.loose,
      child: NotificationListener<ScrollNotification>(
        // ignore: missing_return
          onNotification: (ScrollNotification scrollInfo) {
            if (!endOfProduct) if (!_isOnScroll &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              setState(() {
                _isOnScroll = true;
              });
              productController.getbrandprodutlist(brandId, (VxState.store as GroceStore).productlist.length,(isendofproduct){
                isendofproduct = isendofproduct;
                if(endOfProduct){
                  setState(() {
                    _isOnScroll = false;
                    endOfProduct = true;
                  });
                }else {
                  setState(() {
                    _isOnScroll = false;
                    endOfProduct = false;

                  });
                }
              });

              // start loading data
              /*  setState(() {
               isLoading = true;
             });*/
            }
            return true;
          },
          child:




          VxBuilder(
          mutations: {ProductMutation},
          builder: (ctx,GroceStore? store,VxStatus? state) {

          final productlist = (store as GroceStore).productlist;
         // debugPrint("brand/////" + productlist.length.toString());
         return  (isLoading) ?

             Center(
               child: (kIsWeb && !ResponsiveLayout.isSmallScreen(context))
                   ? ItemListShimmerWeb()
                   : ItemListShimmer(), //CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),

             )
             :
         /* _checkitem*/
         (productlist.length>0)
             ? SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Column(
                children: <Widget>[
                  GridView.builder(
                      shrinkWrap: true,
                      controller: new ScrollController(
                          keepScrollOffset: false),
                      itemCount:
                      productlist.length,
                      gridDelegate:
                      new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widgetsInRow,
                        crossAxisSpacing: 3,
                        childAspectRatio: aspectRatio,
                        mainAxisSpacing: 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final routeArgs =
                        ModalRoute
                            .of(context)!
                            .settings
                            .arguments as Map<String, dynamic>;
                        return SellingItemsv2(
                          fromScreen: "brands_screen",
                          seeallpress: "",
                          itemdata: productlist[index],
                          notid: "",
                          /*"brands_screen",
                          "",
                          productlist[index],
                         "",*/
                         /* "brands_screen",
                          brandslistData.branditems[index].id,
                          brandslistData.branditems[index].title,
                          brandslistData.branditems[index].imageUrl,
                          brandslistData.branditems[index].brand,
                          "",
                          brandslistData.branditems[index].veg_type,
                          brandslistData.branditems[index].type,
                          brandslistData.branditems[index].eligible_for_express,
                          brandslistData.branditems[index].delivery,
                          brandslistData.branditems[index].duration,
                          brandslistData.branditems[index].durationType,
                          brandslistData.branditems[index].note,
                          brandslistData.branditems[index].subscribe,
                          brandslistData.branditems[index].paymentmode,
                          brandslistData.branditems[index].cronTime,
                          brandslistData.branditems[index].name,*/

                          returnparm: {
                            "indexvalue": indexvalue!,
                            "brandId": brandId,
                          },
                        );
                      }),
                  if (endOfProduct)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                      margin: EdgeInsets.only(top: 10.0),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      padding: EdgeInsets.only(
                          top: 25.0, bottom: 25.0),
                      child: Text(S
                          .of(context)
                          .thats_all_folk,
                        // "That's all folks!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if(endOfProduct)
              if (_isWeb) Footer(
                  address: PrefUtils.prefs!.getString("restaurant_address")!),
            if(!_isWeb)Container(
              height: _isOnScroll ? 50 : 0,
              child: Center(
                child: new CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ): Container(
           height: MediaQuery
               .of(context)
               .size
               .height,
           child: Column(
             children: [
               Align(
                 // heightFactor: MediaQuery.of(context).size.height,
                 alignment: Alignment.center,
                 child: new Image.asset(
                   Images.noItemImg,
                   fit: BoxFit.fill,
                   height: 250.0,
                   width: 200.0,
//                    fit: BoxFit.cover
                 ),
               ),
               SizedBox(height: 10,),
               if (_isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
             ],
           ),
         );
          })
      ),
    );
       /* : Expanded(
        child:SingleChildScrollView(
          child:Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: new Image.asset(
                  Images.noItemImg, fit: BoxFit.fill,
                  height: 200.0,
                  width: 200.0,
//                    fit: BoxFit.cover
                ),
              ),
              SizedBox(height: 10,),
              if (_isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")),
            ],
          ) ,
        )
    );*/
  /*  Container(
      height: _isOnScroll ? 50 : 0,
      child: Center(
        child: new CircularProgressIndicator(),
      ),
    );*/
  }
/*  Widget _bodyweb(){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 330:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    // return
        return _checkitem
        ? Flexible(
       fit: FlexFit.loose,
      child: NotificationListener<ScrollNotification>(
        // ignore: missing_return
          onNotification: (ScrollNotification scrollInfo) {
            if (!endOfProduct) if (!_isOnScroll &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              setState(() {
                _isOnScroll = true;
              });
              Provider.of<BrandItemsList>(context, listen: false).fetchBrandItems(
                  brandId, startItem, "scrolling")
                  .then((_) {
                setState(() {
                  //itemslistData = Provider.of<ItemsList>(context, listen: false);
                  startItem = brandslistData.branditems.length;
                  if (PrefUtils.prefs!.getBool("endOfProduct")) {
                    _isOnScroll = false;
                    endOfProduct = true;
                  } else {
                    _isOnScroll = false;
                    endOfProduct = false;
                  }
                });
              });

              // start loading data
              setState(() {
                isLoading = true;
              });
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                GridView.builder(
                    shrinkWrap: true,
                    controller: new ScrollController(
                        keepScrollOffset: true),
                    itemCount:
                    brandslistData.branditems.length,
                    gridDelegate:
                    new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widgetsInRow,
                      crossAxisSpacing: 3,
                      childAspectRatio: aspectRatio,
                      mainAxisSpacing: 3,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return SellingItems(
                        "brands_screen",
                        brandslistData.branditems[index].id,
                        brandslistData.branditems[index].title,
                        brandslistData.branditems[index].imageUrl,
                        brandslistData.branditems[index].brand,
                        "",
                      );
                    }),
                if (endOfProduct)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                    ),
                    margin: EdgeInsets.only(top: 10.0),
                    // width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        top: 25.0, bottom: 25.0),
                    child: Text(
                      "That's all folks!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                *//*if(endOfProduct)*//*
                SizedBox(height: 10,),
                if (_isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")),
              ],
            ),
          )),
    )
        : Flexible(
        child:SingleChildScrollView(
          child:Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: new Image.asset(
                  Images.noItemImg, fit: BoxFit.fill,
                  height: 200.0,
                  width: 200.0,
//                    fit: BoxFit.cover
                ),
              ),
              SizedBox(height: 10,),
              if (_isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")),
            ],
          ) ,
        )
    );
    Container(
      height: _isOnScroll ? 50 : 0,
      child: Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }*/
  Widget _bodyMobile(){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;
    queryData = MediaQuery.of(context);
    wid= queryData!.size.width;
    maxwid=wid!*0.90;
    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 350:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 180;
   //return /*load
 //   ?(_isWeb && !ResponsiveLayout.isSmallScreen(context))? Center(
  //   child: CircularProgressIndicator(),
  // ): ItemListShimmer()
  //      :
    return (isLoading) ?
    Center(

      child: (kIsWeb && !ResponsiveLayout.isSmallScreen(context))
          ? ItemListShimmerWeb()
          : ItemListShimmer(), //CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),

    )
        :
    Flexible(
     fit: FlexFit.loose,
     child: NotificationListener<ScrollNotification>(
    // ignore: missing_return
         onNotification: (ScrollNotification scrollInfo) {
           if (!endOfProduct) if (!_isOnScroll &&
               scrollInfo.metrics.pixels ==
                   scrollInfo.metrics.maxScrollExtent) {
             setState(() {
               _isOnScroll = true;
             });
             productController.getbrandprodutlist(brandId, (VxState.store as GroceStore).productlist.length,(isendofproduct){
               startItem = (VxState.store as GroceStore).productlist.length;
               endOfProduct = isendofproduct;
               if(endOfProduct){
                 setState(() {
                   _isOnScroll = false;
                   endOfProduct = true;
                 });
               }else {
                 setState(() {
                   _isOnScroll = false;
                   endOfProduct = false;

                 });
               }
             });
           }
           return true;
           },
         child:
         SingleChildScrollView(

           child: Column(
             children: [
               VxBuilder(
                 mutations: {ProductMutation},
                 builder: (ctx,GroceStore? store,VxStatus? state){

                   //load = false;

                   final productlist = (store as GroceStore).productlist;
                   debugPrint("brand/////"+productlist.length.toString());
                   return
                   /* _checkitem*/(productlist.length>0)
                       ?  SingleChildScrollView(
                     child: Column(
                       children: <Widget>[
                         MouseRegion(
                           cursor: SystemMouseCursors.click,
                           child:
                           GridView.builder(
                               shrinkWrap: true,
                               controller: new ScrollController(
                                   keepScrollOffset: false),
                               itemCount: /*(_groupValue == 1) ? itemslistData.items
                                     .length : itemslistData.length*/productlist.length,
                               gridDelegate:
                               new SliverGridDelegateWithFixedCrossAxisCount(
                                 crossAxisCount: widgetsInRow,
                                 crossAxisSpacing: 3,
                                 childAspectRatio: aspectRatio,
                                 mainAxisSpacing: 3,
                               ),
                               itemBuilder: (BuildContext context, int index) {
                                 final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                                 /* return (_groupValue == 1) ?*/ return SellingItemsv2(
                                   fromScreen: "brands_screen",
                                   seeallpress: "",
                                   itemdata: productlist[index],
                                   notid: "",
                                  /* "brands_screen",
                                   "",
                                   productlist[index],
                                   "",*/
                                   /*   productlist[index].id,//itemslistData.items[index].id,
                                     productlist[index].itemName,//title,
                                     productlist[index].itemFeaturedImage,//imageUrl,
                                     productlist[index].brand,
                                     "",
                                     productlist[index].vegType,//veg_type,
                                     productlist[index].type,
                                     productlist[index].eligibleForExpress,
                                     productlist[index].delivery,
                                     productlist[index].duration,
                                     productlist[index].deliveryDuration.durationType,
                                     productlist[index].deliveryDuration.note,
                                     productlist[index].eligibleForSubscription,
                                     productlist[index].paymentMode,
                                     (productlist[index].subscriptionSlot.length>0)?productlist[index].subscriptionSlot[0].cronTime:"",
                                     (productlist[index].subscriptionSlot.length>0)?productlist[index].subscriptionSlot[0].name:"",*/

                                   returnparm: {
                                     "indexvalue": indexvalue!,
                                     "brandId": brandId,
                                   },
                                 ) ;
                                 /*    : SellingItems(
                                     "item_screen",
                                     itemslistData[index].id,
                                     itemslistData[index].title,
                                     itemslistData[index].imageUrl,
                                     itemslistData[index].brand,
                                     "",
                                     itemslistData[index].veg_type,
                                     itemslistData[index].type,
                                     itemslistData[index].eligible_for_express,
                                     itemslistData[index].delivery,
                                     itemslistData[index].duration,
                                     itemslistData[index].durationType,
                                     itemslistData[index].note,
                                     itemslistData[index].subscribe,
                                     itemslistData[index].paymentmode,
                                     itemslistData[index].cronTime,
                                     itemslistData[index].name,

                                     returnparm: {
                                       'maincategory': routeArgs['maincategory'],
                                       'catId': routeArgs['catId'],
                                       'catTitle': routeArgs['catTitle'],
                                       'subcatId': subcatId,
                                       'indexvalue': routeArgs['indexvalue'],
                                       'prev': routeArgs['prev'],
                                     },
                                   );*/
                               }),

                         ),

                         if (endOfProduct)
                           Container(
                             decoration: BoxDecoration(
                               color: Colors.black12,
                             ),
                             margin: EdgeInsets.only(top: 10.0),
                             width: MediaQuery
                                 .of(context)
                                 .size
                                 .width,
                             padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                             child: Text(
                               S .of(context)
                                   .thats_all_folk,
                               // "That's all folks!",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 fontSize: 16,
                               ),
                             ),
                           ),
                       ],
                     ),
                   )
//                        : Container(
//                      height: MediaQuery
//                          .of(context)
//                          .size
//                          .height,
//                      child: Align(
//                        // heightFactor: MediaQuery.of(context).size.height,
//                        alignment: Alignment.center,
//                        child: new Image.asset(
//                          Images.noItemImg,
//                          fit: BoxFit.fill,
//                          height: 250.0,
//                          width: 200.0,
// //                    fit: BoxFit.cover
//                        ),
//                      ),
//                    );
                   :Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                       SizedBox(height: MediaQuery.of(context).size.height/8,),
                       new Image.asset(
                         Images.noItemImg,
                         fit: BoxFit.fill,
                         height: 200.0,
                         width: 200.0,
                       ),
                       Padding(
                         padding: const EdgeInsets.only(top:8.0),
                         child: Text(S.of(context).no_product,style: TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 18,
                         ),),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(10.0),
                         child: Text(S.of(context).find_item,
                           style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w500,color:ColorCodes.grey),),
                       )
                     ],
                   );
                 },
               ),
               Container(
                 height: _isOnScroll ? 50 : 0,
                 child: Center(
                   child: new CircularProgressIndicator(),
                 ),
               ),
             ],
           ),
         ),

     ),
   );
  }
  PreferredSizeWidget _appBarMobile() {
    return  AppBar(
      toolbarHeight: 60.0,
      elevation: (IConstants.isEnterprise)?0:1,
      automaticallyImplyLeading: false,
      title: Text(S .of(context).brands
        //"Brands"
        ,style: TextStyle(color: ColorCodes.iconColor, fontWeight: FontWeight.bold, fontSize: 18),),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: ColorCodes.iconColor),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),

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
  bool get wantKeepAlive => true; // ** and here
}
