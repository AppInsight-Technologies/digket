import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/footer.dart';
import '../../widgets/productWidget/item_variation.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../constants/IConstants.dart';
import '../../constants/api.dart';
import '../../generated/l10n.dart';
import '../../rought_genrator.dart';
import '../../widgets/simmers/singel_item_of_list_shimmer.dart';
import '../../widgets/header.dart';
import '../../components/ItemList/item_component.dart';
import '../../components/singleItemComponents/single_item_mobile.dart';
import '../../constants/features.dart';
import '../../models/VxModels/VxStore.dart';
import '../../screens/home_screen.dart';
import '../../screens/membership_screen.dart';
import '../../screens/signup_selection_screen.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../utils/prefUtils.dart';
import '../../widgets/productWidget/item_detais_widget.dart';
import '../../widgets/productWidget/membership_info_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../repository/productandCategory/category_or_product.dart';
import '../../models/newmodle/product_data.dart';
import '../../widgets/productWidget/product_info_widget.dart';
import '../../widgets/productWidget/product_sliding_image_widget.dart';
import '../login_web.dart';
import 'package:http/http.dart' as http;

class SingleItemWebComponent extends StatefulWidget {
  final Future<ItemModle>? similarProduct;
  final ItemData product;
  final String variationId;

  const SingleItemWebComponent({Key? key, this.similarProduct, required this.product,required this.variationId}) : super(key: key);


  @override
  _SingleItemWebComponentState createState() => _SingleItemWebComponentState();
}

class _SingleItemWebComponentState extends State<SingleItemWebComponent> with Navigations{
  int itemindex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var _checkmembership = false;
  String page ="SingleProduct";
  String comment = S .current.good;
  double ratings = 3.0;
  final TextEditingController commentController = new TextEditingController();
  @override
  Widget build(BuildContext context) {

    if ((VxState.store as GroceStore).userData.membership=="1") {
      setState(() {
        _checkmembership = true;
      });
    } else {
      setState(() {
        _checkmembership = false;
      });
      for (int i = 0; i < (VxState.store as GroceStore).CartItemList.length; i++) {
        if ((VxState.store as GroceStore).CartItemList[i].mode == "1") {
          setState(() {
            _checkmembership = true;
          });
        }
      }
    }
print("similar products..."+widget.similarProduct.toString());
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ColorCodes.whiteColor,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Header(false),
            SizedBox(
              height: 20.0,
            ),
            Expanded(child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    //mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SlidingImage(productdata: widget.product,varid:widget.variationId,itemindexs:itemindex,ontap: (){},)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          //mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ProductInfoWidget(itemdata: widget.product,varid:widget.variationId ,variationId:widget.variationId,itemindexs:itemindex,ontap: (){
                              print("popup,,,,");
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(builder: (context, setState) {
                                      return  Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(3.0)),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width / 2.9,
                                          //height: 200,
                                          padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                                          child:  ItemVariation(itemdata: widget.product,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
                                            //for changing color
                                            //  itemindex1 = i;
                                            setState(() {
                                              //for changing product price
                                              itemindex = i;
                                              print("apppp..."+itemindex.toString()+"index..");
                                              // Navigator.of(context).pop();
                                            });
                                          },)
                                        ),
                                      );
                                    });
                                  }).then((_) => setState(() { }));
                              // (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
                              // showDialog(
                              //     context: context,
                              //     builder: (context) {
                              //       return StatefulBuilder(builder: (context, setState) {
                              //         return  Dialog(
                              //           shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(3.0)),
                              //           child: Container(
                              //             width: 800,
                              //             //height: 200,
                              //             padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                              //             child: ItemVariation(widget.product,ismember: VxState.store.userData.membership,selectedindex: widget.product.priceVariation!.indexWhere((element) => element.id == widget.variationId),onselect: (i){
                              //               setState(() {
                              //                 widget.product.priceVariation!.indexWhere((element) => element.id == widget.variationId) == i;
                              //                 // Navigator.of(context).pop();
                              //               });
                              //             },),
                              //           ),
                              //         );
                              //       });
                              //     })
                              //     .then((_) => setState(() { }))
                              //     :showModalBottomSheet<dynamic>(
                              //     isScrollControlled: true,
                              //     context: context,
                              //     builder: (context) {
                              //       return ItemVariation(widget.product,ismember: VxState.store.userData.membership,selectedindex: widget.product.priceVariation!.indexWhere((element) => element.id == widget.variationId),onselect: (i){
                              //         setState(() {
                              //           widget.product.priceVariation!.indexWhere((element) => element.id == widget.variationId) == i;
                              //           // Navigator.of(context).pop();
                              //         });
                              //       },);
                              //     })
                              //     .then((_) => setState(() { }));
                            },),
                            if(Features.isMembership)
                              MembershipInfoWidget(itemdata: widget.product,varid:widget.variationId ,itemindexs:itemindex,ontap:(){
                                (!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
                                // _dialogforSignIn() :
                                LoginWeb(context,result: (sucsess){
                                  if(sucsess){
                                    Navigator.of(context).pop();
                                    Navigation(context, navigatore: NavigatoreTyp.homenav);
                                    /*Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.routeName, (route) => false);*/
                                  }else{
                                    Navigator.of(context).pop();
                                  }
                                })
                                    :
                                (!PrefUtils.prefs!.containsKey("apikey") && !Vx.isWeb)?
                                /*Navigator.of(context).pushReplacementNamed(
                                    SignupSelectionScreen.routeName)*/
                                Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                                    :/*Navigator.of(context).pushNamed(
                                  MembershipScreen.routeName,
                                );*/
                                Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ItemDetailsWidget(itmdata: widget.product,ontap: (){},),

                  if(Features.isRateOrderProduct)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(top: 15.0, bottom: 10.0,left:(Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0,right: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0 ),
                      color: /*Color(0xFFFFE8E8).withOpacity(0.7)*/ColorCodes.whiteColor,
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:10.0,right:10,bottom: 5),
                                child: Text(
                                  "Ratings & Reviews",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              if(Features.isRateOrderProduct)
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: (){
                                    showpopforRateorder();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10,),
                                    height: 30,
                                    decoration: new BoxDecoration(
                                        color: ColorCodes.whiteColor,
                                        border: Border.all(color: ColorCodes.darkgreen),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(5),
                                          topRight:
                                          const Radius.circular(5),
                                          bottomLeft:
                                          const Radius.circular(5),
                                          bottomRight:
                                          const Radius.circular(5),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right:10,left: 10,),
                                      child: Center(
                                        child: Text(
                                          "Rate Product",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                             SizedBox(width: 10,)
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(left:10.0,right:10),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.product.rating!.toStringAsFixed(2), style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: ColorCodes.greenColor),
                                    ),
                                    SizedBox(width: 5,),
                                    Image.asset(
                                      Images.starImg,
                                      width: 9,
                                      height: 9,
                                      color: ColorCodes.greenColor,
                                      fit: BoxFit.fill,
                                    ),
                                    Spacer(),
                                    (widget.product.ratingCount != 0)? IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color:ColorCodes.greenColor,
                                        size: 16,

                                      ),
                                      onPressed: () {
                                        Navigation(context, name: Routename.RateReviewScreen, navigatore: NavigatoreTyp.Push,
                                            parms: {"varid":widget.variationId});
                                      },
                                    ):SizedBox.shrink(),
                                  ],
                                ),
                                Text(widget.product.ratingCount.toString()+" ratings & "+widget.product.ratingCount.toString()+" reviews")
                              ],
                            ),
                          ),
                          SizedBox(height: 15,),
                          if(widget.product.ratingCount != 0) Divider(color: ColorCodes.lightGreyWebColor,thickness: 1,),
                          if(widget.product.ratingCount != 0) Container(
                            width: /*(Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:*/MediaQuery.of(context).size.width,
                            child: ListView.separated(
                                separatorBuilder: (context, index) => Divider(color: ColorCodes.lightGreyWebColor,thickness: 1,),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: (widget.product.reviews!.length)>5?5:widget.product.reviews!.length,
                                itemBuilder: (_, i) {
                                  return Container(
                                    padding: const EdgeInsets.only(left:10.0,right:10),
                                    width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.product.reviews![i].comment!,
                                            style: TextStyle(fontSize: 12.0,color: ColorCodes.borderColor)),
                                        SizedBox(height: 10,),
                                        Text(widget.product.reviews![i].user!,
                                            style: TextStyle(fontSize: 10.0,color: ColorCodes.lightGreyColor)),
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          ),
                          if(widget.product.ratingCount != 0)Divider(color: ColorCodes.lightGreyWebColor,thickness: 1,),
                          // SizedBox(height: 10,),
                          if(widget.product.ratingCount != 0) GestureDetector(
                            onTap: (){
                              Navigation(context, name: Routename.RateReviewScreen, navigatore: NavigatoreTyp.Push,
                                  parms: {"varid":widget.variationId});
                            },
                            child: Container(
                              //  padding: const EdgeInsets.only(left:10.0,right:10),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "View all Reviews",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorCodes.redColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 10,),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color:ColorCodes.redColor,
                                    size: 14,

                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if(widget.similarProduct!=null)
                  FutureBuilder<ItemModle>(
                    future: widget.similarProduct, // async work
                    builder: (BuildContext context, AsyncSnapshot<ItemModle> snapshot) {
                      switch (snapshot.connectionState) {

                        case ConnectionState.waiting:
                          return  SingelItemOfList();
                      // TODO: Handle this case.

                        default:
                        // TODO: Handle this case.
                          if (snapshot.hasError)
                            return SizedBox.shrink();
                          else
                            return  snapshot.data!.data!.length > 0?Container(
                              width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width,
                              //padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                              padding: EdgeInsets.only(top: 15.0, bottom: 10.0,left:(Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0,right: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0 ),
                              color: /*Color(0xFFFFE8E8).withOpacity(0.7)*/ColorCodes.whiteColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left:10.0,right:10),
                                    child: Text(
                                      snapshot.data!.label!,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme
                                              .of(context)
                                              .primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                      height: ResponsiveLayout.isSmallScreen(context) ?
                                      (Features.isSubscription)?410:310 :
                                      ResponsiveLayout.isMediumScreen(context) ?
                                      (Features.isSubscription)?380:350 : Features.btobModule?420:(Features.isSubscription) ? 280 : 270,

                                      // height: (Vx.isWeb)?380:360,
                                      child: new ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data!.data!.length,
                                        itemBuilder: (_, i) => Column(
                                          children: [
                                            Itemsv2(
                                              "Forget",
                                              snapshot.data!.data![i],
                                              (VxState.store as GroceStore).userData,
                                              //sellingitemData.items[i].brand,
                                            ),  /* Itemsv2(
                                                                "Forget",
                                                                snapshot.data.data[i],
                                                                (VxState.store as GroceStore).userData,
                                                                //sellingitemData.items[i].brand,
                                                              ),*/
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ):SizedBox.shrink();
                      }
                    },
                  ),

                  if(Vx.isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  _dialogforProcessing(){
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AbsorbPointer(
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          });
        });
  }
  Future<void> RateProduct(var rating) async {
    try {
      debugPrint("hihii...."+{
        "user": PrefUtils.prefs!.getString('apikey'),
        "itemId":widget.product.id.toString(),
        "star": rating.toString(),
        "comment": commentController.text.toString(),
        "branch": PrefUtils.prefs!.getString('branch').toString(),
        "ref":IConstants.isEnterprise && Features.ismultivendor?IConstants.refIdForMultiVendor.toString():"",
      }.toString());
      final response = await http.post(Api.addRatingsProduct, body: {
        "user": PrefUtils.prefs!.getString('apikey'),
        "itemId":widget.product.id.toString(),
        "star": rating.toString(),
        "comment": commentController.text.toString(),
        "branch": PrefUtils.prefs!.getString('branch').toString(),
        "ref":IConstants.isEnterprise && Features.ismultivendor?IConstants.refIdForMultiVendor.toString():"",
      });
      final responseJson = json.decode(response.body);
      debugPrint("responseJson...rate.."+responseJson.toString());

      Navigator.pop(context);
      if (responseJson['status'].toString() == "200") {
        // Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.product.type=="1"?widget.product.id.toString():widget.variationId,"productId": widget.product.id.toString()});
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Review added successfully, it is sent for approval.", fontSize: MediaQuery.of(context).textScaleFactor *13,);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: S .current.something_went_wrong, fontSize: MediaQuery.of(context).textScaleFactor *13,);
      }
    } catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: S .current.something_went_wrong, fontSize: MediaQuery.of(context).textScaleFactor *13,);
      throw error;
    }
  }

  showpopforRateorder() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width / 5,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Rate our Product",
                            style: TextStyle(fontSize: 18.0,color: ColorCodes.greyColor),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal:120.0),
                            child: Divider(color: ColorCodes.darkgreen,thickness: 2,),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),

                          Text(
                            comment,
                            style: TextStyle(fontSize: 20.0,color: ColorCodes.greyColor),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          RatingBar.builder(

                            initialRating: ratings,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 30,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star_rate,
                              color: ColorCodes.ratestarcolor,
                            ),

                            onRatingUpdate: (rating) {
                              ratings = rating;
                              if(ratings == 5){
                                setState(() {
                                  comment = S .of(context).excellent;//"Excellent";
                                });

                              }
                              else if(ratings == 4){
                                setState(() {
                                  comment = S .of(context).good;//"Good";
                                });

                              }
                              else if(ratings == 3){
                                setState(() {
                                  comment = S .of(context).average;//"Average";
                                });

                              }
                              else if(ratings == 2){
                                setState(() {
                                  comment = S .of(context).bad;//"Bad";
                                });
                              }
                              else if(ratings == 1){
                                setState(() {
                                  comment = S .of(context).verybad;//"Very Bad";
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            textAlign: TextAlign.left,
                            controller: commentController,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: '*Comment',
                              hoverColor: ColorCodes.primaryColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                BorderSide(color: Colors.grey),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                BorderSide(color: ColorCodes.primaryColor),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                BorderSide(color: ColorCodes.primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                BorderSide(color: ColorCodes.primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {

                                if(commentController.text == ""){
                                  Fluttertoast.showToast(msg: "Please enter comment", fontSize: MediaQuery.of(context).textScaleFactor *13,);
                                }else{
                                  _dialogforProcessing();
                                  // debugPrint(":widget.itemId...."+widget.itemId+"...."+widget.itemname);
                                  RateProduct(ratings);
                                }


                              },
                              child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width/1.5,
                                //color: ColorCodes.greenColor,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: ColorCodes.greenColor,
                                  border: Border.all(
                                      color: ColorCodes.greenColor),
                                  // color: Theme.of(context).primaryColor
                                ),
                                child: Center(
                                    child: Text(
                                      S .of(context).rate_order.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: ColorCodes
                                            .whiteColor, //Theme.of(context).buttonColor,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            );
          });
        });
  }
}
