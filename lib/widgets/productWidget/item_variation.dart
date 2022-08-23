import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/newmodle/search_data.dart';
import '../../../constants/features.dart';
import '../../../generated/l10n.dart';
import '../../../models/newmodle/product_data.dart';
import '../../../screens/home_screen.dart';
import '../../../screens/signup_selection_screen.dart';
import '../../../screens/subscribe_screen.dart';
import '../../../utils/ResponsiveLayout.dart';
import '../../../utils/prefUtils.dart';
import '../../../components/login_web.dart';
import '../../../widgets/custome_stepper.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../assets/ColorCodes.dart';
import '../../constants/IConstants.dart';
import '../../assets/images.dart';
import '../../rought_genrator.dart';

class ItemVariation extends StatelessWidget with Navigations{
  Function? onselect;
  bool? ismember;
  int selectedindex;
  StoreSearchData? searchdata;
  String? page;
  String? fromscreen;
  ItemVariation({this.itemdata,this.searchdata,this.onselect,this.selectedindex = 0,this.ismember,this.page,this.fromscreen});
  ItemData? itemdata;
  bool checkskip = false;
  bool _isWeb = false;
  Widget handler(int i) {
    print("i...."+i.toString());
    if ((fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].stock! >= 0:itemdata!.priceVariation![i].stock! >= 0) {
      debugPrint("stock...");
      return (selectedindex == i) ?
      Icon(
          Icons.radio_button_checked_outlined,
          color: ColorCodes.greenColor)
          :
      Icon(
          Icons.radio_button_off_outlined,
          color: ColorCodes.greenColor);

    } else {
      debugPrint("out  stock...");
      return (selectedindex == i) ?
      Icon(
          Icons.radio_button_checked_outlined,
          color: ColorCodes.grey)
          :
      Icon(
          Icons.radio_button_off_outlined,
          color: ColorCodes.greenColor);
    }
  }
  Widget build(BuildContext context) {
    try {
      if (Platform.isIOS) {
        _isWeb = false;
      } else {
        _isWeb = false;
      }
    } catch (e) {
      _isWeb = true;
    }
    checkskip = !PrefUtils.prefs!.containsKey('apikey');

    return Wrap(
      children: [
        StatefulBuilder(builder: (context, setState) {
          return Container(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 5, horizontal: 10),
                  child:
                  Column(
                    children: [
                    SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text( S.of(context).available_quantity,
                            style: TextStyle(
                              color: ColorCodes.blackColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (page=="SingleProduct")?SizedBox.shrink():
                      Flexible(
                        child: Text( (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.itemName!:itemdata!.itemName!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: ColorCodes.blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      /*(page=="SingleProduct")?SizedBox.shrink():
                     GestureDetector(
                         onTap: () => Navigator.pop(context),
                         child: Image(
                           height: 40,
                           width: 40,
                           image: AssetImage(
                               Images.bottomsheetcancelImg),
                           color: Colors.black,
                         )),*/
                    ],
                  ),
                  (_isWeb && !ResponsiveLayout.isSmallScreen(context))?SizedBox(
                    height: 5,
                  ):SizedBox(
                    height: 25,
                  ),
                  (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( S .of(context).please_select_any_option,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: ColorCodes.grey ,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ): Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( S .of(context).choose_variant,
                          style: TextStyle(
                            color: ColorCodes.blackColor ,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 200,
                    child:
                    SingleChildScrollView(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation!.length:itemdata!.priceVariation!.length,
                          itemBuilder: (_, i) {
                            double discount = (fromscreen == "search_item_multivendor" && Features.ismultivendor)?
                            ismember!?searchdata!.priceVariation![i].membershipDisplay!?double.parse((searchdata!.priceVariation![i].membershipPrice!).toString()):double.parse(searchdata!.priceVariation![i].price!):double.parse(searchdata!.priceVariation![i].price!)
                                :ismember!?itemdata!.priceVariation![i].membershipDisplay!?double.parse(itemdata!.priceVariation![i].membershipPrice!):double.parse(itemdata!.priceVariation![i].price!):double.parse(itemdata!.priceVariation![i].price!);
                            debugPrint("discount...1"+discount.toString()+"  "+ismember.toString());
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                setState((){
                                  selectedindex = i;
                                });
                                onselect!(i);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(vertical: 5),
                                /* decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(6),
                                   color: selectedindex==i?ColorCodes.fill:ColorCodes.whiteColor,
                                   border: Border.all(color: ColorCodes.lightGreyColor),
                                 ),*/
                                child: Row(

                                  children: [
                                    handler(i),
                                    SizedBox(width: 10,),
                                    VariationListItem(variationName: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].variationName!:itemdata!.priceVariation![i].variationName!, mrp: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?double.parse(searchdata!.priceVariation![i].mrp!):double.parse(itemdata!.priceVariation![i].mrp!), discount: discount,
                                      unit: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].unit!:itemdata!.priceVariation![i].unit!, color:selectedindex==i? ColorCodes.mediumBlueColor: ColorCodes.blackColor,),


                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if(page!="SingleProduct")
                (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
                Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (Features.isSubscription)?
                    Container(
                        height:70,
                        width: 150,
                        child:
                        (fromscreen == "search_item_multivendor" && Features.ismultivendor)?
                        CustomeStepper(priceVariationSearch:searchdata!.priceVariation![selectedindex],searchstoredata: searchdata,height:(Features.isSubscription)?90:60,issubscription: "Subscribe",index: selectedindex,) :
                        CustomeStepper(priceVariation:itemdata!.priceVariation![selectedindex],itemdata: itemdata,height:(Features.isSubscription)?90:60,issubscription: "Subscribe",index: selectedindex,)):
                  SizedBox(width: 150,),
                  Spacer(),
                  Container(
                      height:60,
                      width: 150,
                      child:
                      (fromscreen == "search_item_multivendor" && Features.ismultivendor)?
                      CustomeStepper(priceVariationSearch:searchdata!.priceVariation![selectedindex],searchstoredata: searchdata,height:(Features.isSubscription)?90:60,issubscription: "Add",index: selectedindex,) :
                      CustomeStepper(priceVariation:itemdata!.priceVariation![selectedindex],itemdata: itemdata,height:(Features.isSubscription)?90:60,issubscription: "Add",index: selectedindex,)),
                  SizedBox(width: 10,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     if(!_isWeb)
                  //       if (Features.isSubscription)
                  //         (itemdata.eligibleForSubscription == "0")?
                  //         (itemdata.priceVariation![selectedindex].stock! <= 0)  ?
                  //         SizedBox(height: 40,)
                  //             :
                  //         GestureDetector(
                  //           onTap: () async {
                  //             if(checkskip && _isWeb && !ResponsiveLayout.isSmallScreen(context)){
                  //               if(!PrefUtils.prefs!.containsKey("apikey")){
                  //                 LoginWeb(context,result: (sucsess){
                  //                   if(sucsess){
                  //                     Navigator.of(context).pop();
                  //                     Navigation(context, navigatore: NavigatoreTyp.homenav);
                  //                     /*Navigator.pushNamedAndRemoveUntil(
                  //                          context, HomeScreen.routeName, (route) => false);*/
                  //                   }else{
                  //                     Navigator.of(context).pop();
                  //                   }
                  //                 });
                  //               }else{
                  //                 /*       Navigator.of(context).pushNamed(
                  //                      SubscribeScreen.routeName,
                  //                      arguments: {
                  //                        "itemid": itemdata.id,
                  //                        "itemname": itemdata.itemName,
                  //                        "itemimg": itemdata.itemFeaturedImage,
                  //                        "varname": itemdata.priceVariation![selectedindex].variationName !+ itemdata.priceVariation![selectedindex].unit!,
                  //                        "varmrp":itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                        "varprice": ismember! ? itemdata.priceVariation![selectedindex].membershipPrice.toString()
                  //                            :itemdata.priceVariation![selectedindex].discointDisplay! ?itemdata.priceVariation![0].price.toString()
                  //                            :itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                        "paymentMode": itemdata.paymentMode,
                  //                        "cronTime": itemdata.subscriptionSlot![selectedindex].cronTime,
                  //                        "name": itemdata.subscriptionSlot![selectedindex].name,
                  //                        "varid":itemdata.priceVariation![selectedindex].id,
                  //                        "brand": itemdata.brand
                  //                      }
                  //                  );*/
                  //                 Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                  //                     qparms: {
                  //                       "itemid": itemdata.id,
                  //                       "itemname": itemdata.itemName,
                  //                       "itemimg": itemdata.itemFeaturedImage,
                  //                       "varname": itemdata.priceVariation![selectedindex].variationName !+ itemdata.priceVariation![selectedindex].unit!,
                  //                       "varmrp":itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                       "varprice": ismember! ? itemdata.priceVariation![selectedindex].membershipPrice.toString()
                  //                           :itemdata.priceVariation![selectedindex].discointDisplay! ?itemdata.priceVariation![0].price.toString()
                  //                           :itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                       "paymentMode": itemdata.paymentMode,
                  //                       "cronTime": itemdata.subscriptionSlot![selectedindex].cronTime,
                  //                       "name": itemdata.subscriptionSlot![selectedindex].name,
                  //                       "varid":itemdata.priceVariation![selectedindex].id,
                  //                       "brand": itemdata.brand
                  //                     });
                  //               }
                  //             }
                  //             else {
                  //               debugPrint("api key..."+PrefUtils.prefs!.containsKey("apikey").toString());
                  //               if(!PrefUtils.prefs!.containsKey("apikey")) {
                  //                 debugPrint("not loged in...");
                  //                 Navigator.of(context).pushNamed(
                  //                   SignupSelectionScreen.routeName,
                  //                 );
                  //               }
                  //               else{
                  //                 debugPrint("loged in...");
                  //                 /*        Navigator.of(context).pushNamed(
                  //                      SubscribeScreen.routeName,
                  //                      arguments: {
                  //                        "itemid": itemdata.id,
                  //                        "itemname": itemdata.itemName,
                  //                        "itemimg": itemdata.itemFeaturedImage,
                  //                        "varname": itemdata.priceVariation![selectedindex].variationName !+ itemdata.priceVariation![0].unit!,
                  //                        "varmrp":itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                        "varprice": ismember! ? itemdata.priceVariation![selectedindex].membershipPrice.toString()
                  //                            :itemdata.priceVariation![selectedindex].discointDisplay! ?itemdata.priceVariation![0].price.toString()
                  //                            :itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                        "paymentMode": itemdata.paymentMode,
                  //                        "cronTime": itemdata.subscriptionSlot![selectedindex].cronTime,
                  //                        "name": itemdata.subscriptionSlot![selectedindex].name,
                  //                        "varid":itemdata.priceVariation![selectedindex].id,
                  //                        "brand": itemdata.brand
                  //                      }
                  //                  );*/
                  //                 Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                  //                     qparms: {
                  //                       "itemid": itemdata.id,
                  //                       "itemname": itemdata.itemName,
                  //                       "itemimg": itemdata.itemFeaturedImage,
                  //                       "varname": itemdata.priceVariation![selectedindex].variationName !+ itemdata.priceVariation![0].unit!,
                  //                       "varmrp":itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                       "varprice": ismember! ? itemdata.priceVariation![selectedindex].membershipPrice.toString()
                  //                           :itemdata.priceVariation![selectedindex].discointDisplay! ?itemdata.priceVariation![0].price.toString()
                  //                           :itemdata.priceVariation![selectedindex].mrp.toString(),
                  //                       "paymentMode": itemdata.paymentMode,
                  //                       "cronTime": itemdata.subscriptionSlot![selectedindex].cronTime,
                  //                       "name": itemdata.subscriptionSlot![selectedindex].name,
                  //                       "varid":itemdata.priceVariation![selectedindex].id,
                  //                       "brand": itemdata.brand
                  //                     });
                  //               }
                  //
                  //             }
                  //
                  //           },
                  //           child: Container(
                  //               height: 40.0,
                  //               width:(MediaQuery.of(context).size.width / 4.5) + 15,
                  //               decoration: new BoxDecoration(
                  //                   border: Border.all(color: Theme
                  //                       .of(context)
                  //                       .primaryColor),
                  //                   color: ColorCodes.whiteColor,
                  //                   borderRadius: new BorderRadius.only(
                  //                     topLeft: const Radius.circular(2.0),
                  //                     topRight: const Radius.circular(2.0),
                  //                     bottomLeft: const Radius.circular(2.0),
                  //                     bottomRight: const Radius.circular(2.0),
                  //                   )),
                  //               child:
                  //               Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 crossAxisAlignment: CrossAxisAlignment.center,
                  //                 children: [
                  //                   Center(
                  //                       child: Text(
                  //                         S .of(context).subscribe,//'SUBSCRIBE',
                  //                         style: TextStyle(
                  //                           color: Theme
                  //                               .of(context)
                  //                               .primaryColor,
                  //                           fontWeight: FontWeight.bold,
                  //                         ),
                  //                         textAlign: TextAlign.center,
                  //                       )),
                  //                 ],
                  //               )
                  //           ),
                  //         ) : SizedBox.shrink(),
                  //   ],),
                  // SizedBox(
                  //     height: 70,
                  //     width:MediaQuery.of(context).size.width/2.9,
                  //     child: CustomeStepper(priceVariation:itemdata.priceVariation![selectedindex],
                  //         itemdata: itemdata,height:(Features.isSubscription)?90:60,issubscription: "Add",
                  //         addon:(itemdata.addon!.length > 0)?itemdata.addon![selectedindex]:null,index:selectedindex)),
                ],
              )
                  :
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                  if(Features.isSubscription)

              Container(
              height:70,
              width: 150,
              child:
              (fromscreen == "search_item_multivendor" && Features.ismultivendor)?
              CustomeStepper(priceVariationSearch:searchdata!.priceVariation![selectedindex],searchstoredata: searchdata,height:(Features.isSubscription)?90:60,issubscription: "Subscribe",index: selectedindex, from: "search_screen",) :
              CustomeStepper(priceVariation:itemdata!.priceVariation![selectedindex],itemdata: itemdata,height:(Features.isSubscription)?90:60,issubscription: "Subscribe",index: selectedindex,)),
              Container(
              height:60,
              width: 150,
              child:
              (fromscreen == "search_item_multivendor" && Features.ismultivendor)?
              CustomeStepper(priceVariationSearch:searchdata!.priceVariation![selectedindex],searchstoredata: searchdata,height:(Features.isSubscription)?90:60,issubscription: "Add",index: selectedindex,from: "search_screen",) :
              CustomeStepper(priceVariation:itemdata!.priceVariation![selectedindex],itemdata: itemdata,height:(Features.isSubscription)?90:60,issubscription: "Add",index: selectedindex,)),
              ],
              )

              ],
              ),
              ),
              );

        }),
      ],
    );


  }
}
class VariationListItem extends StatelessWidget {
  String variationName = "";
  String unit;
  Color? color;
  double discount;
  double mrp;


  VariationListItem({Key? key,required this.variationName,required this.mrp, required this.discount,this.unit = "unit",this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("discount...."+discount.toStringAsFixed(2));
    return Container(
      height: 35,
      padding: EdgeInsets.only(right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14.0, //color: itemvarData[i].varcolor,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: variationName+" "+unit+"  ",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: ColorCodes.greenColor,
                      fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: Features.iscurrencyformatalign?
                  discount.toStringAsFixed(2) + IConstants.currencyFormat + " ":
                  IConstants.currencyFormat + discount.toStringAsFixed(2) + " ",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: ColorCodes.blackColor,
                      fontWeight: FontWeight.w600),
                ),
                TextSpan(
                    text: discount.toStringAsFixed(2)!=mrp.toStringAsFixed(2)?
                    Features.iscurrencyformatalign?
                    mrp.toStringAsFixed(2) + IConstants.currencyFormat:
                    IConstants.currencyFormat + mrp.toStringAsFixed(2) :"",
                    style: TextStyle(color: ColorCodes.blackColor,
                      decoration: TextDecoration.lineThrough,)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}