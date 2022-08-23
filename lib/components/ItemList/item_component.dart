import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../../widgets/custome_stepper.dart';
import '../../../controller/mutations/cart_mutation.dart';
import '../../../helper/custome_calculation.dart';
import '../../../models/VxModels/VxStore.dart';
import '../../../models/newmodle/cartModle.dart';
import '../../../models/newmodle/product_data.dart';
import '../../../models/newmodle/user.dart';
import '../../../components/login_web.dart';
import '../../rought_genrator.dart';
import '../../widgets/productWidget/item_badge.dart';
import '../../widgets/productWidget/item_variation.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../generated/l10n.dart';
import '../../../screens/signup_selection_screen.dart';
import '../../../screens/subscribe_screen.dart';
import '../../../constants/IConstants.dart';
import '../../../screens/home_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/features.dart';
import '../../../main.dart';
import '../../../screens/singleproduct_screen.dart';
import '../../../screens/membership_screen.dart';
import '../../../data/hiveDB.dart';
import '../../../assets/images.dart';
import '../../../utils/prefUtils.dart';
import '../../../utils/ResponsiveLayout.dart';
import '../../../assets/ColorCodes.dart';

class Itemsv2 extends StatefulWidget {
  final String _fromScreen;
  final ItemData _itemdata;
  final UserData _customerDetail;
  Itemsv2(this._fromScreen, this._itemdata, this._customerDetail);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Itemsv2> with Navigations {
  int itemindex = 0;
  var textcolor;
  bool _isNotify = false;
  bool _checkmembership = false;
  List<CartItem> productBox=[];
  int _groupValue = 0;
  int quantity = 0;
  double weight = 0.0;
  int _count = 1;

  @override
  void initState() {
    productBox = (VxState.store as GroceStore).CartItemList;
    // if(widget._itemdata.priceVariation==null)
      print("item components of ${widget._itemdata.toJson().toString()}");
    if(Features.btobModule){
      if (productBox.where((element) => element.itemId == widget._itemdata.id)
          .count() >= 1) {
        debugPrint("count...1");
        for (int i = 0; i < productBox.length; i++) {
          debugPrint("count...1 if inside");
          for(int j = 0 ; j < widget._itemdata.priceVariation!.length; j++)
          {
            print("j value...."+j.toString()+"...."+widget._itemdata.priceVariation!.length.toString()+"///"+i.toString());
            print("proudct box id if..." + widget._itemdata.priceVariation![j].minItem.toString()+ widget._itemdata.priceVariation![j].maxItem.toString() + "hve varid..." + productBox.where((element) => element.itemId == widget._itemdata.id).first.quantity
                .toString());
            if ((int.parse(productBox.where((element) => element.itemId == widget._itemdata.id).first.quantity.toString()) >=  int.parse(widget._itemdata.priceVariation![j].minItem.toString())) && int.parse(productBox.where((element) => element.itemId == widget._itemdata.id).first.quantity.toString()) <=  int.parse(widget._itemdata.priceVariation![j].maxItem.toString())) {
              print("proudct box id if..." + widget._itemdata.priceVariation![j].quantity.toString() + "hve varid..." + productBox.where((element) => element.itemId == widget._itemdata.id).first.quantity
                  .toString());
              print("variation equal");
              _groupValue = j;

            }
            else{
              print("variation not equal");
            }
          }

        }
      }
    }
    super.initState();
  }


   showoptions1() {
   // _checkmembership?widget._itemdata.priceVariation[itemindex].membershipPrice:widget._itemdata.priceVariation[itemindex].price
    (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return  Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius. only(topLeft: Radius. circular(15.0), topRight: Radius. circular(15.0)),),
              child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                //height: 200,
                padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                child: ItemVariation(itemdata: widget._itemdata,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
                  setState(() {
                    itemindex = i;
                    // Navigator.of(context).pop();
                  });
                },),
              ),
            );
          });
        })
        .then((_) => setState(() { }))
    :showModalBottomSheet<dynamic>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius. only(topLeft: Radius. circular(15.0), topRight: Radius. circular(15.0)),),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return ItemVariation(itemdata: widget._itemdata,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
            setState(() {
              itemindex = i;
              // Navigator.of(context).pop();
            });
          },);
        })
        .then((_) => setState(() { }));
  }
  @override
  Widget build(BuildContext context) {
  //  print("stock..." + widget._itemdata.type.toString()+"loyalty...."+widget._itemdata.priceVariation![itemindex].loyalty.toString());


    if(Features.btobModule){
      if (productBox.where((element) => element.itemId == widget._itemdata.id)
          .count() >= 1) {
        debugPrint("count...1");
        for (int i = 0; i < productBox.length; i++) {
          debugPrint("count...1 if inside");
          for(int j = 0 ; j < widget._itemdata.priceVariation!.length; j++)
            {
              print("j value...."+j.toString()+"...."+widget._itemdata.priceVariation!.length.toString()+"///"+i.toString());
            }
          if (productBox[i].itemId == widget._itemdata.id &&
              productBox[i].toppings == "0") {
            debugPrint("true...1");
            quantity = quantity + int.parse(productBox
                .where((element) =>
            element.itemId == widget._itemdata.id)
                .first
                .quantity!);
            weight = weight + double.parse(productBox
                .where((element) =>
            element.itemId == widget._itemdata.id)
                .first
                .weight!);
          }
        }
      }
    }
    else {
      if (productBox.where((element) => element.itemId == widget._itemdata.id)
          .count() >= 1) {
        debugPrint("count...1");
        for (int i = 0; i < productBox.length; i++) {
          if (productBox[i].itemId == widget._itemdata.id &&
              productBox[i].toppings == "0") {
            debugPrint("true...1");
            quantity = quantity + int.parse(productBox
                .where((element) =>
            element.itemId == widget._itemdata.id)
                .first
                .quantity!);
            weight = weight + double.parse(productBox
                .where((element) =>
            element.itemId == widget._itemdata.id)
                .first
                .weight!);
          }
        }
      }
    }


  double margins = (widget._itemdata.type=="1")?Calculate().getmargin(widget._itemdata.mrp,
      VxState.store.userData.membership! == "0" || VxState.store.userData.membership! == "2" ?
      widget._itemdata.discointDisplay! ? widget._itemdata.price : widget._itemdata.mrp
          : widget._itemdata.membershipDisplay!? widget._itemdata.membershipPrice: widget._itemdata.price): Calculate().getmargin(widget._itemdata.priceVariation![itemindex].mrp,
      VxState.store.userData.membership! == "0" || VxState.store.userData.membership! == "2" ?
      widget._itemdata.priceVariation![itemindex].discointDisplay! ? widget._itemdata.priceVariation![itemindex].price : widget._itemdata.priceVariation![itemindex].mrp
    : widget._itemdata.priceVariation![itemindex].membershipDisplay!? widget._itemdata.priceVariation![itemindex].membershipPrice: widget._itemdata.priceVariation![itemindex].price);

  print("margi..." + widget._itemdata.itemName! + "..." + margins.toString()+"..."+widget._itemdata.unit.toString()+"...."+widget._itemdata.eligibleForExpress.toString());
    return widget._itemdata.type=="1"?
    Expanded(
      child: Container(
        width: _checkmembership? 210:195.0,
        //height: MediaQuery.of(context).size.height,//aaaaaaaaaaaaaaaaaa
        child:Container(
          margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
          decoration: new BoxDecoration(
              color: Colors.white,
              //border: Border.all(color: Colors.black26),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 0.50)),
              ],
              borderRadius: new BorderRadius.all(const Radius.circular(8.0),)),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Column(
                children: [
                  SizedBox(height: 8,),
                  Stack(
                    children:[
                      ItemBadge(
                        outOfStock: widget._itemdata.stock!<=0?OutOfStock(singleproduct: false,):null,
                        badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
                        /*  widgetBadge: WidgetBadge(isdisplay: true,child: widget._itemdata.eligibleForExpress=="0"?Padding(
                        padding: EdgeInsets.only(right: 5.0,),
                        child: Image.asset(Images.express,
                          height: 20.0,
                          width: 25.0,),
                      ):SizedBox.shrink()),*/
                        child: Align(
                          alignment: Alignment.center,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                debugPrint("single product...."+{
                                  "itemid": widget._itemdata.id,
                                  "itemname": widget._itemdata.itemName,
                                  "itemimg": widget._itemdata.itemFeaturedImage,
                                  "eligibleforexpress": widget._itemdata.eligibleForExpress,
                                  "delivery": widget._itemdata.delivery,
                                  "duration": widget._itemdata.duration,
                                  "durationType":widget._itemdata.deliveryDuration.durationType,
                                  "note":widget._itemdata.deliveryDuration.note,
                                  "fromScreen":widget._fromScreen,
                                }.toString());
                                /*     Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget._itemdata.id.toString(),
                                    "itemname": widget._itemdata.itemName,
                                    "itemimg": widget._itemdata.itemFeaturedImage,
                                    "eligibleforexpress": widget._itemdata.eligibleForExpress,
                                    "delivery": widget._itemdata.delivery,
                                    "duration": widget._itemdata.duration,
                                    "durationType":widget._itemdata.deliveryDuration.durationType,
                                    "note":widget._itemdata.deliveryDuration.note,
                                    "fromScreen":widget._fromScreen,
                                  });*/

                                // debugPrint("varid......"+widget._itemdata.priceVariation![itemindex].id.toString());
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget._itemdata.id.toString(),"productId": widget._itemdata.id!});
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                                child: CachedNetworkImage(
                                  imageUrl: widget._itemdata.itemFeaturedImage,
                                  errorWidget: (context, url, error) => Image.asset(
                                    Images.defaultProductImg,
                                    width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  ),
                                  placeholder: (context, url) => Image.asset(
                                    Images.defaultProductImg,
                                    width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  ),
                                  width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  //  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      widget._itemdata.eligibleForExpress=="0"?Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5,bottom: 5),
                          child: Container(
                            width: 46,
                            height: 17,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                  color: ColorCodes.varcolor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:2.0),
                                  child: Text("Express",style: TextStyle(fontSize: 8,color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,fontWeight: FontWeight.w800),),
                                ),
                                Image.asset(Images.express,
                                  height: 15.0,
                                  width: 13.0,
                                  color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ):SizedBox.shrink(),
                    ]

                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),

              Row(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      widget._itemdata.brand!,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,
                        color: ColorCodes.lightGreyColor,fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Spacer(),
                  if(Features.isLoyalty)
                    if(double.parse(widget._itemdata.loyalty.toString()) > 0)
                      Container(
                        height: 18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(Images.coinImg,
                              height: 12.0,
                              width: 18.0,),
                            SizedBox(width: 2),
                            Text(widget._itemdata.loyalty.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),),
                          ],
                        ),
                      ),
                ],
              ),
              SizedBox(height: 2,),
              Row(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Container(
                      height: 35,
                      child: Text(
                        widget._itemdata.itemName!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style:
                        TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Features.isSubscription && widget._itemdata.eligibleForSubscription=="0"?
                  Container(
                    height:30,
                    width: 70,
                    child: Padding(
                      padding: const EdgeInsets.only(left:0,right:5.0),
                      child: CustomeStepper(fontSize: 9,itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,issubscription: "Subscribe",addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex),
                    ),
                  ):SizedBox.shrink(),
                  SizedBox(
                    width: 5.0,
                  ),
                ],
              ),
              // Spacer(),

              Row(
                children: <Widget>[
                  SizedBox(
                    width: 10.0,
                  ),
                  (widget._itemdata.singleshortNote.toString() == "0" || widget._itemdata.singleshortNote.toString() == "") ?
                  SizedBox(height: 15) :
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //SizedBox(width:10),
                      Text(widget._itemdata.singleshortNote.toString(),style: TextStyle(fontSize: 9,color: ColorCodes.emailColor,fontWeight: FontWeight.bold),),
                    ],
                  ),

                  SizedBox(width: 10)
                ],
              ),
              SizedBox(height:2),
              (Features.netWeight && widget._itemdata.vegType == "fish")?
              Row(
                children: [
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    Features.iscurrencyformatalign?
                    "Whole Uncut:" +" " +
                        widget._itemdata.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                    "Whole Uncut:" +" "+ IConstants.currencyFormat +
                        widget._itemdata.salePrice! +" / "+ "500 G",
                    style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 11, fontWeight: FontWeight.bold),),
                  SizedBox(
                    width: 10.0,
                  ),
                ],
              ):SizedBox.shrink(),
              (Features.netWeight && widget._itemdata.vegType == "fish")?
              SizedBox(
                height: 2,
              ): /*SizedBox(
                height: 2,
              )*/SizedBox.shrink(),
              (Features.netWeight && widget._itemdata.vegType == "fish")
                  ? Row(
                  children: [
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("G Weight:" +" "+
                            /*'$weight '*/widget._itemdata.weight!,
                            style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 11, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("N Weight:" +" "+
                            /*'$netWeight '*/widget._itemdata.netWeight!,
                            style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 11, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                  ]
              ):SizedBox.shrink(),
              (Features.netWeight && widget._itemdata.vegType == "fish") ?
             SizedBox(height: 18,):SizedBox.shrink(),
              SizedBox(height:5),
       /*       ( widget._itemdata.priceVariation!.length > 1)
                  ? Features.btobModule?
              Container(
                // height: 200,
                  child: SingleChildScrollView(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget._itemdata.priceVariation!.length,
                          itemBuilder: (_, i) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  //showoptions1();
                                  setState(() {
                                    _groupValue = i;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Container(
                                          decoration: BoxDecoration(
                                            // border: Border.all(color: ColorCodes.greenColor),
                                            color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                              color: ColorCodes.greenColor,
                                            ),
                                       *//*      borderRadius: new BorderRadius.only(
                                         topLeft: const Radius.circular(2.0),
                                         bottomLeft: const Radius.circular(2.0),
                                       )*//*),
                                          height: 30,
                                          margin: EdgeInsets.only(bottom:5),
                                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                style: TextStyle(color: ColorCodes.darkgreen*//*Colors.black*//*,fontWeight: FontWeight.bold),
                                              ),
                                              _groupValue == i ?
                                              Container(
                                                width: 18.0,
                                                height: 18.0,
                                                padding: EdgeInsets.only(right:3),
                                                decoration: BoxDecoration(
                                                  color: ColorCodes.greenColor,
                                                  border: Border.all(
                                                    color: ColorCodes.greenColor,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Container(
                                                  margin: EdgeInsets.all(1.5),
                                                  decoration: BoxDecoration(
                                                    color: ColorCodes.greenColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.check,
                                                      color: ColorCodes.whiteColor,
                                                      size: 12.0),
                                                ),
                                              )
                                                  :
                                              Icon(
                                                  Icons.radio_button_off_outlined,
                                                  color: ColorCodes.greenColor),

                                            ],
                                          )

                                      ),
                                    ),
                                     Container(
                                 height: 30,
                                 decoration: BoxDecoration(
                                     color: ColorCodes.varcolor,
                                     borderRadius: new BorderRadius.only(
                                       topRight: const Radius.circular(2.0),
                                       bottomRight: const Radius.circular(2.0),
                                     )),
                                 child: Icon(
                                   Icons.keyboard_arrow_down,
                                   color: ColorCodes.darkgreen,
                                 ),
                               ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  )
              )
                  :
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    showoptions1();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            // border: Border.all(color: ColorCodes.greenColor),
                              color: ColorCodes.varcolor,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                              )),
                          height: 30,
                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                          child: Text(
                            "${widget._itemdata.priceVariation![itemindex].variationName}"+" "+"${widget._itemdata.priceVariation![itemindex].unit}",
                            style: TextStyle(color: ColorCodes.darkgreen*//*Colors.black*//*,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: ColorCodes.varcolor,
                            borderRadius: new BorderRadius.only(
                              topRight: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorCodes.darkgreen,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),
              ) :
              Features.btobModule?
              Container(
                // height: 200,
                  child: SingleChildScrollView(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget._itemdata.priceVariation!.length,
                          itemBuilder: (_, i) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  //showoptions1();
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Container(
                                          decoration: BoxDecoration(
                                            // border: Border.all(color: ColorCodes.greenColor),
                                            color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                              color: ColorCodes.greenColor,
                                            ),
                                         *//*    borderRadius: new BorderRadius.only(
                                         topLeft: const Radius.circular(2.0),
                                         bottomLeft: const Radius.circular(2.0),
                                       )*//*),
                                          height: 30,
                                          margin: EdgeInsets.only(bottom:5),
                                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                style: TextStyle(color: ColorCodes.darkgreen*//*Colors.black*//*,fontWeight: FontWeight.bold),
                                              ),
                                              _groupValue == i ?
                                              Container(
                                                width: 18.0,
                                                height: 18.0,
                                                padding: EdgeInsets.only(right:3),
                                                decoration: BoxDecoration(
                                                  color: ColorCodes.greenColor,
                                                  border: Border.all(
                                                    color: ColorCodes.greenColor,
                                                  ),
                                                  shape: BoxShape.circle,

                                                ),
                                                child: Container(
                                                  margin: EdgeInsets.all(1.5),
                                                  decoration: BoxDecoration(
                                                    color: ColorCodes.greenColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.check,
                                                      color: ColorCodes.whiteColor,
                                                      size: 12.0),
                                                ),
                                              )
                                                  :
                                              Icon(
                                                  Icons.radio_button_off_outlined,
                                                  color: ColorCodes.greenColor),

                                            ],
                                          )

                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  )
              ):*/
              // Row(
              //   children: [
              //     SizedBox(
              //       width: 13.0,
              //     ),
              //     Expanded(
              //       child: Container(
              //         decoration: BoxDecoration(
              //             color: ColorCodes.whiteColor,
              //             // border: Border.all(color: ColorCodes.greenColor),
              //             borderRadius: new BorderRadius.only(
              //               topLeft: const Radius.circular(2.0),
              //               topRight: const Radius.circular(2.0),
              //               bottomLeft: const Radius.circular(2.0),
              //               bottomRight: const Radius.circular(2.0),
              //             )),
              //         height: 10,
              //         padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
              //         child: SizedBox.shrink(),
              //       ),
              //     ),
              //     SizedBox(
              //       width: 10.0,
              //     ),
              //   ],
              // ),
              // SizedBox(height: 5),
              //
              //  (Features.isSubscription)?(widget._itemdata.eligibleForSubscription == "0")?
              //  MouseRegion(
              //    cursor: SystemMouseCursors.click,
              //    child: (widget._itemdata.priceVariation![itemindex].stock !<= 0) ?
              //    SizedBox(height: 30,)
              //        :GestureDetector(
              //      onTap: () {
              // //TODO: on click subscribe
              //        if(!PrefUtils.prefs!.containsKey("apikey"))
              //        if(kIsWeb&&  !ResponsiveLayout.isSmallScreen(context)){
              //          LoginWeb(context,result: (sucsess){
              //            if(sucsess){
              //              Navigator.of(context).pop();
              //              Navigator.pushNamedAndRemoveUntil(
              //                  context, HomeScreen.routeName, (route) => false);
              //            }else{
              //              Navigator.of(context).pop();
              //            }
              //          });
              //        }else{
              //          Navigator.of(context).pushNamed(
              //            SignupSelectionScreen.routeName,
              //          );
              //        }else{
              //          Navigator.of(context).pushNamed(
              //              SubscribeScreen.routeName,
              //              arguments: {
              //                "itemid": widget._itemdata.id,
              //                "itemname": widget._itemdata.itemName,
              //                "itemimg": widget._itemdata.itemFeaturedImage,
              //                "varname": widget._itemdata.priceVariation![itemindex].variationName!+widget._itemdata.priceVariation![itemindex].unit!,
              //                "varmrp":widget._itemdata.priceVariation![itemindex].mrp,
              //                "varprice":  widget._customerDetail.membership=="1" ? widget._itemdata.priceVariation![itemindex].membershipPrice.toString():widget._itemdata.priceVariation![itemindex].discointDisplay! ?widget._itemdata.priceVariation![itemindex].price.toString():widget._itemdata.priceVariation![itemindex].mrp.toString(),
              //                "paymentMode": widget._itemdata.paymentMode,
              //                "cronTime": widget._itemdata.subscriptionSlot![0].cronTime,
              //                "name": widget._itemdata.subscriptionSlot![0].name,
              //                "varid":widget._itemdata.priceVariation![itemindex].id,
              //                "brand": widget._itemdata.brand
              //              }
              //          );
              //        }
              //      },
              //      child: Row(
              //        children: [
              //          SizedBox(
              //            width: 10,
              //          ),
              //          Expanded(
              //            child: Container(
              //              height: 30.0,
              //              decoration: new BoxDecoration(
              //                  color: ColorCodes.whiteColor,
              //                  border: Border.all(color: Theme.of(context).primaryColor),
              //                  borderRadius: new BorderRadius.only(
              //                    topLeft: const Radius.circular(2.0),
              //                    topRight:
              //                    const Radius.circular(2.0),
              //                    bottomLeft:
              //                    const Radius.circular(2.0),
              //                    bottomRight:
              //                    const Radius.circular(2.0),
              //                  )),
              //              child: Row(
              //                mainAxisAlignment: MainAxisAlignment.center,
              //                crossAxisAlignment: CrossAxisAlignment.center,
              //                children: [
              //
              //                  Text(
              //                    S .of(context).subscribe,//'SUBSCRIBE',
              //                    style: TextStyle(
              //                        color: Theme.of(context).primaryColor,
              //                        fontSize: 12, fontWeight: FontWeight.bold),
              //                    textAlign: TextAlign.center,
              //                  ),
              //                ],
              //              ) ,
              //            ),
              //          ),
              //          SizedBox(
              //            width: 10,
              //          ),
              //        ],
              //      ),
              //    ),
              //  ):SizedBox(height: 30,):SizedBox.shrink(),
              //  SizedBox(
              //    height: 8,
              //  ),
              Padding(
                padding: const EdgeInsets.only(left:10,right:5.0),
                child: Container(
                  //  height:50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VxBuilder(
                          mutations: {ProductMutation,SetCartItem},
                          builder: (context, GroceStore box, _) {
                            if(VxState.store.userData.membership! == "1"){
                              _checkmembership = true;
                            } else {
                              _checkmembership = false;
                              for (int i = 0; i < productBox.length; i++) {
                                if (productBox[i].mode == "1") {
                                  _checkmembership = true;
                                }
                              }
                            }
                            return  Row(
                              children: <Widget>[
                               /* if(Features.isMembership)
                                  _checkmembership?Container(
                                    width: 10.0,
                                    height: 9.0,
                                    margin: EdgeInsets.only(right: 3.0),
                                    child: Image.asset(
                                      Images.starImg,
                                      color: ColorCodes.starColor,
                                    ),
                                  ):SizedBox.shrink(),*/

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new RichText(
                                      text: new TextSpan(
                                        style: new TextStyle(
                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,
                                          color: Colors.black,
                                        ),
                                        children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                          new TextSpan(
                                              text:  Features.iscurrencyformatalign?
                                              '${_checkmembership?widget._itemdata.membershipPrice:widget._itemdata.price} ' + IConstants.currencyFormat:
                                              IConstants.currencyFormat + '${_checkmembership?widget._itemdata.membershipPrice:widget._itemdata.price} ',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _checkmembership?ColorCodes.greenColor:Colors.black,
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                          new TextSpan(
                                              text: widget._itemdata.price!=widget._itemdata.mrp?
                                              Features.iscurrencyformatalign?
                                              '${widget._itemdata.mrp} ' + IConstants.currencyFormat:
                                              IConstants.currencyFormat + '${widget._itemdata.mrp} ':"",
                                              style: TextStyle(
                                                color: ColorCodes.emailColor,
                                                decoration:
                                                TextDecoration.lineThrough,
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 9 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                          // TextSpan(
                                          //     text:  (widget._itemdata.unit==null ||widget._itemdata.unit=="")?"":" /"+widget._itemdata.unit.toString(),
                                          //     style: TextStyle(
                                          //       color: ColorCodes.emailColor,
                                          //       fontSize: ResponsiveLayout.isSmallScreen(context) ? 9 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,))
                                        ],
                                      ),
                                    ),

                                    _checkmembership?Text("Membership Price",style: TextStyle(color: ColorCodes.greenColor,fontSize:7),):SizedBox.shrink(),
                                  ],
                                ),
                                Spacer(),
                                _checkmembership?(double.parse(widget._itemdata.mrp!) - double.parse(widget._itemdata.membershipPrice!))>0?
                                Container(
                                  height: 20,
                                  // width: 80,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                                      // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                    ),
                                    color: ColorCodes.varcolor,
                                  ),

                                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 3),
                                      Image.asset(
                                        Images.bottomnavMembershipImg,
                                        color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                        width: 15,
                                        height: 10,),
                                      Text(
                                          Features.iscurrencyformatalign? "Savings" + " " +
                                          (double.parse(widget._itemdata.mrp!) - double.parse(widget._itemdata.membershipPrice!)).toString() + IConstants.currencyFormat: "Savings" + " " +
                                          IConstants.currencyFormat +
                                              (double.parse(widget._itemdata.mrp!) - double.parse(widget._itemdata.membershipPrice!)).toString() /*+ " " +S.of(context).membership_price*/,
                                          style: TextStyle(fontSize: 9,/*fontWeight: FontWeight.bold,*/color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                      SizedBox(width: 5),
                                    ],
                                  ),
                                ):SizedBox.shrink()
                                    :
                                Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: VxBuilder(
                                    mutations: {SetCartItem,ProductMutation},
                                    builder: (context, GroceStore box, index) {
                                      return Column(
                                        children: [
                                          if(Features.isMembership && double.parse(widget._itemdata.membershipPrice.toString()) > 0)
                                            Row(
                                              children: <Widget>[
                                                !_checkmembership
                                                    ? widget._itemdata.membershipDisplay!
                                                    ? GestureDetector(
                                                  onTap: () {
                                                    if(!PrefUtils.prefs!.containsKey("apikey")) {
                                                      if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                                          context)) {
                                                        LoginWeb(context, result: (sucsess) {
                                                          if (sucsess) {
                                                            Navigator.of(context).pop();
                                                            /* Navigator.pushNamedAndRemoveUntil(
                                              context, HomeScreen.routeName, (
                                              route) => false);*/
                                                            Navigation(context, navigatore: NavigatoreTyp.homenav);
                                                          } else {
                                                            Navigator.of(context).pop();
                                                          }
                                                        });
                                                      } else {
                                                        /* Navigator.of(context).pushNamed(
                                        SignupSelectionScreen.routeName,
                                      );*/
                                                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                                      }
                                                    }
                                                    else{
                                                      /*Navigator.of(context).pushNamed(
                                      MembershipScreen.routeName,
                                    );*/
                                                      Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 20,
                                                    padding: EdgeInsets.only(left: 2),
                                                    // width: 178,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                                                        // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                      ),
                                                      color: ColorCodes.varcolor,
                                                    ),
                                                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        SizedBox(width: 3),
                                                        Image.asset(
                                                          Images.bottomnavMembershipImg,
                                                          color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                                          width: 14,
                                                          height: 8,),
                                                        Text(
                                                          // S .of(context).membership_price+ " " +//"Membership Price "
                                                            S.of(context).price + " ",
                                                            style: TextStyle(fontSize: 8.0,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                                                        Text(
                                                          // S .of(context).membership_price+ " " +//"Membership Price "
                                                            Features.iscurrencyformatalign?
                                                            widget._itemdata.membershipPrice.toString() + IConstants.currencyFormat:
                                                            IConstants.currencyFormat +
                                                                widget._itemdata.membershipPrice.toString(),
                                                            style: TextStyle(fontSize: 8.0,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                                                        /* Spacer(),
                                                        Icon(
                                                          Icons.lock,
                                                          color: Colors.black,
                                                          size: 10,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Icon(
                                                          Icons.arrow_forward_ios_sharp,
                                                          color: Colors.black,
                                                          size: 10,
                                                        ),*/

                                                        SizedBox(width: 5),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                    : SizedBox.shrink()
                                                    : SizedBox.shrink(),
                                              ],
                                            ),
                                          !_checkmembership
                                              ? widget._itemdata.membershipDisplay!
                                              ? SizedBox(
                                            height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                          )
                                              : SizedBox(
                                            height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                          )
                                              : SizedBox(
                                            height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                      ],
                    )),
              ),
              SizedBox(height:5),
              Padding(
                padding: const EdgeInsets.only(left: 5.0,right: 5.0),
                child: Container(
                  height:40,
                  child: Row(
                    children: [
                      Container(
                        height:(Features.isSubscription)?40:40,
                        width: _checkmembership?180:173,
                        child: Padding(
                          padding: const EdgeInsets.only(left:5,right:5.0),
                          child: CustomeStepper(itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex,issubscription: "Add", ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 8.0,right: 8.0,),
              //   child: Container(
              //       height:40,
              //       child: Row(
              //         children: [
              //           Container(
              //               height:(Features.isSubscription)?40:40,
              //               width:  _checkmembership?180:160,
              //               child: Padding(
              //                 padding: const EdgeInsets.only(left:5,right:5.0),
              //                 child: CustomeStepper(itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex,issubscription: "Add", ),
              //               )),
              //         ],
              //       )),
              // ),

            ],
          ),
        ),
      ),
    ):
    Expanded(
      child: Container(
        width:  _checkmembership? 210:195.0,
        //height: MediaQuery.of(context).size.height,//aaaaaaaaaaaaaaaaaa
        child:Container(
          margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
          decoration: new BoxDecoration(
              color: Colors.white,
              //border: Border.all(color: Colors.black26),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 10.0,
                     offset: Offset(0.0, 0.50)),
              ],
              borderRadius: new BorderRadius.all(const Radius.circular(8.0),)),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Column(
                children: [
                  SizedBox(height: 8,),
                  Stack(
                    children:[
                    ItemBadge(
                      outOfStock: widget._itemdata.priceVariation![itemindex].stock!<=0?OutOfStock(singleproduct: false,):null,
                      badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
                      // widgetBadge: WidgetBadge(isdisplay: true,child: widget._itemdata.eligibleForExpress=="0"?Padding(
                      //   padding: EdgeInsets.only(right: 5.0,),//EdgeInsets.all(3.0),
                      //   child: Image.asset(Images.express,
                      //     height: 20.0,
                      //     width: 25.0,),
                      // ):SizedBox.shrink()),
                      child: Align(
                        alignment: Alignment.center,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              debugPrint("single product...."+{
                                "itemid": widget._itemdata.id,
                                "itemname": widget._itemdata.itemName,
                                "itemimg": widget._itemdata.itemFeaturedImage,
                                "eligibleforexpress": widget._itemdata.eligibleForExpress,
                                "delivery": widget._itemdata.delivery,
                                "duration": widget._itemdata.duration,
                                "durationType":widget._itemdata.deliveryDuration.durationType,
                                "note":widget._itemdata.deliveryDuration.note,
                                "fromScreen":widget._fromScreen,
                              }.toString());
                              /*     Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget._itemdata.id.toString(),
                                    "itemname": widget._itemdata.itemName,
                                    "itemimg": widget._itemdata.itemFeaturedImage,
                                    "eligibleforexpress": widget._itemdata.eligibleForExpress,
                                    "delivery": widget._itemdata.delivery,
                                    "duration": widget._itemdata.duration,
                                    "durationType":widget._itemdata.deliveryDuration.durationType,
                                    "note":widget._itemdata.deliveryDuration.note,
                                    "fromScreen":widget._fromScreen,
                                  });*/

                              debugPrint("varid......"+widget._itemdata.priceVariation![itemindex].menuItemId.toString());
                              if(widget._fromScreen =="Forget"){
                                Navigation(context, navigatore: NavigatoreTyp.Pop);
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget._itemdata.priceVariation![itemindex].menuItemId.toString(),"productId": widget._itemdata.priceVariation![itemindex].menuItemId.toString()});
                              }else{
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget._itemdata.priceVariation![itemindex].menuItemId.toString(),"productId": widget._itemdata.priceVariation![itemindex].menuItemId.toString()});
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                              child: CachedNetworkImage(
                                imageUrl: widget._itemdata.priceVariation![itemindex].images!.length<=0?widget._itemdata.itemFeaturedImage:widget._itemdata.priceVariation![itemindex].images![0].image,
                                errorWidget: (context, url, error) => Image.asset(
                                  Images.defaultProductImg,
                                  width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                ),
                                placeholder: (context, url) => Image.asset(
                                  Images.defaultProductImg,
                                  width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                ),
                                width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                //  fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                      widget._itemdata.eligibleForExpress == "0" ?Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.0,left: 5,bottom: 5),
                          child: Container(
                            width: 46,
                            height: 17,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                  color: ColorCodes.varcolor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:2.0),
                                  child: Text(S.of(context).express,style: TextStyle(fontSize: 8,color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,fontWeight: FontWeight.w800),),
                                ),
                                Image.asset(Images.express,
                                  height: 15.0,
                                  width: 13.0,
                                  color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ):SizedBox.shrink(),
                    ],

                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),

              Row(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      widget._itemdata.brand!,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,
                        color: ColorCodes.lightGreyColor,fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  if(Features.btobModule)
                  SizedBox(
                    width: 10.0,
                  ),
                  if(Features.btobModule)
                  if(Features.isLoyalty)
                    if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(Images.coinImg,
                              height: 13.0,
                              width: 20.0,),
                            SizedBox(width: 2),
                            Text(widget._itemdata.priceVariation![itemindex].loyalty.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                          ],
                        ),
                      ),
                  if(Features.isLoyalty)
                    Spacer(),
                  if(Features.isLoyalty)
                    if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(Images.coinImg,
                              height: 12.0,
                              width: 18.0,),
                            SizedBox(width: 2),
                            Text(widget._itemdata.priceVariation![itemindex].loyalty.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),),
                          ],
                        ),
                      ),
                  SizedBox(
                    width: 10.0,
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Container(
                      height: 35,
                      child: Text(
                        widget._itemdata.itemName!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style:
                        TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),

                  Features.isSubscription && widget._itemdata.eligibleForSubscription=="0"?
                  Container(
                    height:30,
                    width: 70,
                    child: Padding(
                      padding: const EdgeInsets.only(left:0,right:5.0),
                      child: CustomeStepper(fontSize: 9,priceVariation:widget._itemdata.priceVariation![itemindex],itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,issubscription: "Subscribe",addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex),
                    ),
                  ):SizedBox.shrink(),
                  SizedBox(
                    width: 5.0,
                  ),
                ],
              ),


              // Spacer(),

//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     width: 10.0,
//                   ),
//                   VxBuilder(
//                     mutations: {ProductMutation},
//                     builder: (context, GroceStore box, _) {
//                       if(VxState.store.userData.membership! == "1"){
//                         _checkmembership = true;
//                       } else {
//                         _checkmembership = false;
//                         for (int i = 0; i < productBox.length; i++) {
//                           if (productBox[i].mode == "1") {
//                             _checkmembership = true;
//                           }
//                         }
//                       }
//                       return  Row(
//                         children: <Widget>[
//                           if(Features.isMembership)
//                             _checkmembership?Container(
//                               width: 10.0,
//                               height: 9.0,
//                               margin: EdgeInsets.only(right: 3.0),
//                               child: Image.asset(
//                                 Images.starImg,
//                                 color: ColorCodes.starColor,
//                               ),
//                             ):SizedBox.shrink(),
//
//                           new RichText(
//                             text: new TextSpan(
//                               style: new TextStyle(
//                                 fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
//                                 color: Colors.black,
//                               ),
//                               children: <TextSpan>[
// //                            if(varmemberprice.toString() == varmrp.toString())
//                                 new TextSpan(
//                                     text:  Features.iscurrencyformatalign?
//                                     '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation! [itemindex].price} ' + IConstants.currencyFormat:
//                                     IConstants.currencyFormat + '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation![itemindex].price} ',
//                                     style: new TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                       fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
//                                 new TextSpan(
//                                     text: _checkmembership?
//                                     widget._itemdata.priceVariation![itemindex].membershipPrice==widget._itemdata.priceVariation![itemindex].price||widget._itemdata.priceVariation![itemindex].membershipPrice==widget._itemdata.priceVariation![itemindex].mrp ?""
//                                         : widget._itemdata.priceVariation![itemindex].price!=widget._itemdata.priceVariation![itemindex].mrp?
//                                         Features.iscurrencyformatalign?
//                                         '${widget._itemdata.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
//                                     IConstants.currencyFormat + '${widget._itemdata.priceVariation![itemindex].mrp} ':""
//                                     :widget._itemdata.priceVariation![itemindex].price!=widget._itemdata.priceVariation![itemindex].mrp?
//                                     Features.iscurrencyformatalign?
//                                     '${widget._itemdata.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
//                                     IConstants.currencyFormat + '${widget._itemdata.priceVariation![itemindex].mrp} ':"",
//                                     style: TextStyle(
//                                       decoration:
//                                       TextDecoration.lineThrough,
//                                       fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
//                               ],
//                             ),
//                           )
//                         ],
//                       );
//                     },
//                   ),
//                   Spacer(),
//                   if(Features.isLoyalty)
//                     if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
//                       Container(
//                         child: Row(
//                           children: [
//                             Image.asset(Images.coinImg,
//                               height: 15.0,
//                               width: 20.0,),
//                             SizedBox(width: 4),
//                             Text(widget._itemdata.priceVariation![itemindex].loyalty.toString()),
//                           ],
//                         ),
//                       ),
//                   SizedBox(width: 10)
//                 ],
//               ),
//               SizedBox(
//                 height: 2,
//               ),
              (Features.netWeight && widget._itemdata.vegType == "fish")?
                Row(
                  children: [
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      Features.iscurrencyformatalign?
                      "Whole Uncut:" +" " +
                          widget._itemdata.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                      "Whole Uncut:" +" "+ IConstants.currencyFormat +
                        widget._itemdata.salePrice! +" / "+ "500 G",
                      style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 11, fontWeight: FontWeight.bold),),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ):
                  SizedBox.shrink(),
              /*SizedBox(
                height: 5,
              ),*/
            (Features.netWeight && widget._itemdata.vegType == "fish")?
                SizedBox(
                  height: 2,
                ):
            SizedBox.shrink()/*SizedBox(
              height: 2,
            )*/,
              (Features.netWeight && widget._itemdata.vegType == "fish")
               ? Row(
                    children: [
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("G Weight:" +" "+
                              /*'$weight '*/widget._itemdata.priceVariation![itemindex].weight!,
                              style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 11, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("N Weight:" +" "+
                              /*'$netWeight '*/widget._itemdata.priceVariation![itemindex].netWeight!,
                              style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 11, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                    ]
                ):/*SizedBox(height: 5,)*/SizedBox.shrink(),

             SizedBox(height: 2),
             ( widget._itemdata.priceVariation!.length > 1)
                 ? Features.btobModule?
              Container(
              // height: 200,
                child: SingleChildScrollView(
                   child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                       itemCount: widget._itemdata.priceVariation!.length,
                      itemBuilder: (_, i) {
                        return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      //showoptions1();

                      setState(() {
                        _groupValue = i;
                      });
                      print("hdhvsdhsdfds"+""+widget._itemdata.id!+"..."+widget._itemdata.priceVariation![0].id.toString() +
                          "..var id.." );
                      if(productBox
                          .where((element) =>
                      element.itemId! == widget._itemdata.id
                      ).length >= 1) {
                        cartcontroller.update((done) {
                          print("done value in calling update " + done.toString());
                          setState(() {

                          });
                        }, price: widget._itemdata.price.toString(),
                            quantity: widget._itemdata.priceVariation![i].minItem.toString(),
                            type: widget._itemdata.type,
                            weight: (/*weight +*/
                                double.parse(widget._itemdata.increament!)).toString(),
                            var_id: /*widget.itemdata!.id!*/widget._itemdata.priceVariation![0].id.toString(),
                            increament: widget._itemdata.increament,
                            cart_id: productBox
                                .where((element) =>
                            element.itemId! == widget._itemdata.id
                            ).first.parent_id.toString(),
                            toppings: "",
                            topping_id: "",
                            item_id: widget._itemdata.id!

                        );
                      }
                      else {
                        cartcontroller.addtoCart(itemdata: widget._itemdata,
                            onload: (isloading) {
                              setState(() {
                                debugPrint("add to cart......1");
                                //loading = isloading;
                                //onload(true);
                                //onload(isloading);
                                // print("value of loading in add cart fn " + loading.toString());
                              });
                            },
                            topping_type: "",
                            varid: widget._itemdata.priceVariation![0].id,
                            toppings: "",
                            parent_id: "",
                            newproduct: "0",
                            toppingsList: [],
                            itembody: widget._itemdata.priceVariation![i],
                            context: context);
                        print("group value....2" + _groupValue.toString());
                      }
                      // print("hdhvsdhsdfds"+""+widget._itemdata.id!+"..."+widget._itemdata.priceVariation![i].id.toString()/*+productBox
                      //     .where((element) =>
                      // element.itemId! == widget._itemdata.id
                      // ).first.itemId.toString()*/);
                      // if(productBox
                      //     .where((element) =>
                      // element.itemId! == widget._itemdata.id
                      // ).length >= 1) {
                      //   cartcontroller.update((done) {
                      //     print("done value in calling update " + done.toString());
                      //     setState(() {
                      //       /*loading = !done;
                      //       print("value of loading in update cart increment case: " +
                      //           loading.toString());*/
                      //     });
                      //   }, price: widget._itemdata.price.toString(),
                      //       quantity: widget._itemdata.priceVariation![i].minItem.toString(),
                      //       type: widget._itemdata.type,
                      //       weight: (weight +
                      //           double.parse(widget._itemdata.increament!)).toString(),
                      //       var_id:  widget._itemdata.priceVariation![i].id.toString(),
                      //       increament: widget._itemdata.increament,
                      //       cart_id: productBox
                      //           .where((element) =>
                      //       element.itemId! == widget._itemdata.id
                      //       ).first.parent_id.toString(),
                      //       toppings: "",
                      //       topping_id: ""
                      //
                      //   );
                      // }
                      // else {
                      //   cartcontroller.addtoCart(itemdata: widget._itemdata,
                      //       onload: (isloading) {
                      //         setState(() {
                      //           debugPrint("add to cart......1");
                      //           //loading = isloading;
                      //           //onload(true);
                      //           //onload(isloading);
                      //           // print("value of loading in add cart fn " + loading.toString());
                      //         });
                      //       },
                      //       topping_type: "",
                      //       varid: widget._itemdata.priceVariation![i].id,
                      //       toppings: "",
                      //       parent_id: "",
                      //       newproduct: "0",
                      //       toppingsList: [],
                      //       itembody: widget._itemdata.priceVariation![i],
                      //       context: context);
                      //   print("group value....2" + _groupValue.toString());
                      // }



                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                // border: Border.all(color: ColorCodes.greenColor),
                                color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: ColorCodes.greenColor,
                                ),
                                /* borderRadius: new BorderRadius.only(
                                         topLeft: const Radius.circular(2.0),
                                         bottomLeft: const Radius.circular(2.0),
                                       )*/),
                              height: 30,
                              margin: EdgeInsets.only(bottom:5),
                              padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                              child:
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                    style: TextStyle(color: _groupValue == i?ColorCodes.darkgreen:ColorCodes.blackColor,fontWeight: FontWeight.bold,fontSize: 12),
                                  ),

                                  new RichText(
                                    text: new TextSpan(
                                      style: new TextStyle(
                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,
                                        color: _groupValue == i?ColorCodes.darkgreen:ColorCodes.blackColor,
                                      ),
                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                        new TextSpan(
                                            text:  Features.iscurrencyformatalign?
                                            '${_checkmembership?widget._itemdata.priceVariation![i].membershipPrice:widget._itemdata.priceVariation! [i].price} ' + IConstants.currencyFormat:
                                            IConstants.currencyFormat + '${_checkmembership?widget._itemdata.priceVariation![i].membershipPrice:widget._itemdata.priceVariation![i].price} ',
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:_checkmembership?_groupValue == i?ColorCodes.darkgreen:ColorCodes.blackColor: _groupValue == i?ColorCodes.darkgreen:ColorCodes.blackColor,
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                        new TextSpan(
                                            text: _checkmembership?
                                            ( (widget._itemdata.priceVariation![i].membershipPrice==widget._itemdata.priceVariation![i].price)||(widget._itemdata.priceVariation![i].membershipPrice==widget._itemdata.priceVariation![i].mrp)) ?""
                                                : widget._itemdata.priceVariation![i].price!=widget._itemdata.priceVariation![i].mrp?
                                            Features.iscurrencyformatalign?
                                            '${widget._itemdata.priceVariation![i].mrp} ' + IConstants.currencyFormat:
                                            IConstants.currencyFormat + '${widget._itemdata.priceVariation![i].mrp} ':""
                                                :widget._itemdata.priceVariation![i].price!=widget._itemdata.priceVariation![i].mrp?
                                            Features.iscurrencyformatalign?
                                            '${widget._itemdata.priceVariation![i].mrp} ' + IConstants.currencyFormat:
                                            IConstants.currencyFormat + '${widget._itemdata.priceVariation![i].mrp} ':"",
                                            style: TextStyle(
                                              decoration:
                                              TextDecoration.lineThrough,
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,)),
                                      ],
                                    ),
                                  ),

                                  _groupValue == i ?
                                  Container(
                                    width: 18.0,
                                    height: 18.0,
                                    padding: EdgeInsets.only(right:3),
                                    decoration: BoxDecoration(
                                      color: ColorCodes.greenColor,
                                      border: Border.all(
                                        color: ColorCodes.greenColor,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(1.5),
                                      decoration: BoxDecoration(
                                        color: ColorCodes.greenColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.check,
                                          color: ColorCodes.whiteColor,
                                          size: 12.0),
                                    ),
                                  )
                                      :
                                  Icon(
                                      Icons.radio_button_off_outlined,
                                      color: ColorCodes.greenColor),

                                ],
                              )

                          ),
                        ),
                        Spacer(),
                        Text(widget._itemdata.singleshortNote.toString(),style: TextStyle(fontSize: 9,color: ColorCodes.emailColor,fontWeight: FontWeight.bold),),
                        SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                );
                      }
                  )
                )
              )
                 :
             MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                     showoptions1();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          // border: Border.all(color: ColorCodes.greenColor),
                            //color: ColorCodes.varcolor,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(2.0),
                              bottomLeft: const Radius.circular(2.0),
                            )),
                        height: 18,
                        padding: EdgeInsets.fromLTRB(0.0, 0, 5.0, 0),
                        child: Text(
                          "${widget._itemdata.priceVariation![itemindex].variationName}"+" "+"${widget._itemdata.priceVariation![itemindex].unit}",
                          style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.w600,fontSize: 12),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: ColorCodes.darkgreen,
                        size: 18,
                      ),
                      Spacer(),
                      Text(widget._itemdata.singleshortNote.toString(),style: TextStyle(fontSize: 9,color: ColorCodes.emailColor,fontWeight: FontWeight.bold),),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),
              ) :
                /* Features.btobModule?
                 Container(
                   // height: 200,
                     child: SingleChildScrollView(
                         child: ListView.builder(
                             physics: NeverScrollableScrollPhysics(),
                             scrollDirection: Axis.vertical,
                             shrinkWrap: true,
                             itemCount: widget._itemdata.priceVariation!.length,
                             itemBuilder: (_, i) {
                               return MouseRegion(
                                 cursor: SystemMouseCursors.click,
                                 child: GestureDetector(
                                   onTap: () {
                                     //showoptions1();
                                     setState(() {
                                       _groupValue = i;
                                       // CustomeStepper(itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex,issubscription: "Update",);
                                     });
                                   },
                                   child: Row(
                                     children: [
                                       SizedBox(
                                         width: 10.0,
                                       ),
                                       Expanded(
                                         child: Container(
                                             decoration: BoxDecoration(
                                               // border: Border.all(color: ColorCodes.greenColor),
                                               color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                               borderRadius: BorderRadius.circular(5.0),
                                               border: Border.all(
                                                 color: ColorCodes.greenColor,
                                               ),
                                               *//* borderRadius: new BorderRadius.only(
                                         topLeft: const Radius.circular(2.0),
                                         bottomLeft: const Radius.circular(2.0),
                                       )*//*),
                                             height: 30,
                                             margin: EdgeInsets.only(bottom:5),
                                             padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                             child:
                                             Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 Text(
                                                   "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                   style: TextStyle(color: ColorCodes.darkgreen*//*Colors.black*//*,fontWeight: FontWeight.bold),
                                                 ),
                                                 _groupValue == i ?
                                                 Container(
                                                   width: 18.0,
                                                   height: 18.0,
                                                   padding: EdgeInsets.only(right:3),
                                                   decoration: BoxDecoration(
                                                     color: ColorCodes.greenColor,
                                                     border: Border.all(
                                                       color: ColorCodes.greenColor,
                                                     ),
                                                     shape: BoxShape.circle,

                                                   ),
                                                   child: Container(
                                                     margin: EdgeInsets.all(1.5),
                                                     decoration: BoxDecoration(
                                                       color: ColorCodes.greenColor,
                                                       shape: BoxShape.circle,
                                                     ),
                                                     child: Icon(Icons.check,
                                                         color: ColorCodes.whiteColor,
                                                         size: 12.0),
                                                   ),
                                                 )
                                                     :
                                                 Icon(
                                                     Icons.radio_button_off_outlined,
                                                     color: ColorCodes.greenColor),

                                               ],
                                             )

                                         ),
                                       ),
                                       SizedBox(
                                         width: 10.0,
                                       ),
                                     ],
                                   ),
                                 ),
                               );
                             }
                         )
                     )
                 ):*/
                 Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        //color: ColorCodes.varcolor,
                        // border: Border.all(color: ColorCodes.greenColor),
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(2.0),
                          bottomLeft: const Radius.circular(2.0),
                          bottomRight: const Radius.circular(2.0),
                        )),
                    height: 18,
                    padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                    child: Text(
                      "${widget._itemdata.priceVariation![itemindex].variationName}"+" "+"${widget._itemdata.priceVariation![itemindex].unit}",
                      style: TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.w600,fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Spacer(),
                  Text(widget._itemdata.singleshortNote.toString()
                    ,style: TextStyle(fontSize: 9,color: ColorCodes.emailColor,fontWeight: FontWeight.bold),),
                  SizedBox(
                    width: 10.0,
                  ),
                  // if(Features.isLoyalty)
                  //   if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
                  //     Container(
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Image.asset(Images.coinImg,
                  //             height: 13.0,
                  //             width: 20.0,),
                  //           SizedBox(width: 2),
                  //           Text(widget._itemdata.priceVariation![itemindex].loyalty.toString(),
                  //           style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                  //         ],
                  //       ),
                  //     ),
                  SizedBox(
                    width: 10.0,
                  ),
                ],
              ),
            SizedBox(height: 2,),

            //  SizedBox(height: 5),
             //
             //  (Features.isSubscription)?(widget._itemdata.eligibleForSubscription == "0")?
             //  MouseRegion(
             //    cursor: SystemMouseCursors.click,
             //    child: (widget._itemdata.priceVariation![itemindex].stock !<= 0) ?
             //    SizedBox(height: 30,)
             //        :GestureDetector(
             //      onTap: () {
             // //TODO: on click subscribe
             //        if(!PrefUtils.prefs!.containsKey("apikey"))
             //        if(kIsWeb&&  !ResponsiveLayout.isSmallScreen(context)){
             //          LoginWeb(context,result: (sucsess){
             //            if(sucsess){
             //              Navigator.of(context).pop();
             //              Navigator.pushNamedAndRemoveUntil(
             //                  context, HomeScreen.routeName, (route) => false);
             //            }else{
             //              Navigator.of(context).pop();
             //            }
             //          });
             //        }else{
             //          Navigator.of(context).pushNamed(
             //            SignupSelectionScreen.routeName,
             //          );
             //        }else{
             //          Navigator.of(context).pushNamed(
             //              SubscribeScreen.routeName,
             //              arguments: {
             //                "itemid": widget._itemdata.id,
             //                "itemname": widget._itemdata.itemName,
             //                "itemimg": widget._itemdata.itemFeaturedImage,
             //                "varname": widget._itemdata.priceVariation![itemindex].variationName!+widget._itemdata.priceVariation![itemindex].unit!,
             //                "varmrp":widget._itemdata.priceVariation![itemindex].mrp,
             //                "varprice":  widget._customerDetail.membership=="1" ? widget._itemdata.priceVariation![itemindex].membershipPrice.toString():widget._itemdata.priceVariation![itemindex].discointDisplay! ?widget._itemdata.priceVariation![itemindex].price.toString():widget._itemdata.priceVariation![itemindex].mrp.toString(),
             //                "paymentMode": widget._itemdata.paymentMode,
             //                "cronTime": widget._itemdata.subscriptionSlot![0].cronTime,
             //                "name": widget._itemdata.subscriptionSlot![0].name,
             //                "varid":widget._itemdata.priceVariation![itemindex].id,
             //                "brand": widget._itemdata.brand
             //              }
             //          );
             //        }
             //      },
             //      child: Row(
             //        children: [
             //          SizedBox(
             //            width: 10,
             //          ),
             //          Expanded(
             //            child: Container(
             //              height: 30.0,
             //              decoration: new BoxDecoration(
             //                  color: ColorCodes.whiteColor,
             //                  border: Border.all(color: Theme.of(context).primaryColor),
             //                  borderRadius: new BorderRadius.only(
             //                    topLeft: const Radius.circular(2.0),
             //                    topRight:
             //                    const Radius.circular(2.0),
             //                    bottomLeft:
             //                    const Radius.circular(2.0),
             //                    bottomRight:
             //                    const Radius.circular(2.0),
             //                  )),
             //              child: Row(
             //                mainAxisAlignment: MainAxisAlignment.center,
             //                crossAxisAlignment: CrossAxisAlignment.center,
             //                children: [
             //
             //                  Text(
             //                    S .of(context).subscribe,//'SUBSCRIBE',
             //                    style: TextStyle(
             //                        color: Theme.of(context).primaryColor,
             //                        fontSize: 12, fontWeight: FontWeight.bold),
             //                    textAlign: TextAlign.center,
             //                  ),
             //                ],
             //              ) ,
             //            ),
             //          ),
             //          SizedBox(
             //            width: 10,
             //          ),
             //        ],
             //      ),
             //    ),
             //  ):SizedBox(height: 30,):SizedBox.shrink(),
             //  SizedBox(
             //    height: 8,
             //  ),
             // SizedBox(height: 20,),
              if(!Features.btobModule)
              Padding(
                padding: const EdgeInsets.only(left:10.0,right:10),
                child: Container(
                 // height:50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VxBuilder(
                        mutations: {ProductMutation,SetCartItem},
                        builder: (context, GroceStore box, _) {
                          if(VxState.store.userData.membership! == "1"){
                            _checkmembership = true;
                          } else {
                            _checkmembership = false;
                            for (int i = 0; i < productBox.length; i++) {
                              if (productBox[i].mode == "1") {
                                _checkmembership = true;
                              }
                            }
                          }
                          return  Row(
                            children: <Widget>[
                             /* if(Features.isMembership)
                                _checkmembership?Container(
                                  width: 10.0,
                                  height: 9.0,
                                  margin: EdgeInsets.only(right: 3.0),
                                  child: Image.asset(
                                    Images.starImg,
                                    color: ColorCodes.starColor,
                                  ),
                                ):SizedBox.shrink(),*/

                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  new RichText(
                                    text: new TextSpan(
                                      style: new TextStyle(
                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                        new TextSpan(
                                            text:  Features.iscurrencyformatalign?
                                            '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation! [itemindex].price} ' + IConstants.currencyFormat:
                                            IConstants.currencyFormat + '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation![itemindex].price} ',
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:_checkmembership?ColorCodes.greenColor: Colors.black,
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                        new TextSpan(
                                            text: _checkmembership?
                                           ( (widget._itemdata.priceVariation![itemindex].membershipPrice==widget._itemdata.priceVariation![itemindex].price)||(widget._itemdata.priceVariation![itemindex].membershipPrice==widget._itemdata.priceVariation![itemindex].mrp)) ?""
                                                : widget._itemdata.priceVariation![itemindex].price!=widget._itemdata.priceVariation![itemindex].mrp?
                                            Features.iscurrencyformatalign?
                                            '${widget._itemdata.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
                                            IConstants.currencyFormat + '${widget._itemdata.priceVariation![itemindex].mrp} ':""
                                                :widget._itemdata.priceVariation![itemindex].price!=widget._itemdata.priceVariation![itemindex].mrp?
                                            Features.iscurrencyformatalign?
                                            '${widget._itemdata.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
                                            IConstants.currencyFormat + '${widget._itemdata.priceVariation![itemindex].mrp} ':"",
                                            style: TextStyle(
                                              color: ColorCodes.emailColor,
                                              decoration:
                                              TextDecoration.lineThrough,
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 9 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,)),
                                      ],
                                    ),
                                  ),

                                  _checkmembership?Text("Membership Price",style: TextStyle(color: ColorCodes.greenColor,fontSize: 7),):SizedBox.shrink(),
                                  SizedBox(height:5),
                                ],
                              ),
                              Spacer(),
                              _checkmembership?(double.parse(widget._itemdata.priceVariation![itemindex].mrp!)
                                  - double.parse(widget._itemdata.priceVariation![itemindex].membershipPrice!))>0?
                              Container(
                                height: 20,
                                // width: 80,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                                    // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                  ),
                                  color: ColorCodes.varcolor,
                                ),

                                child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(width: 3,),
                                    Image.asset(
                                      Images.bottomnavMembershipImg,
                                      color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                      width: 15,
                                      height: 10,),
                                    Text( "Savings ",style: TextStyle(fontSize: 8.5,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                                    Text(
                                        Features.iscurrencyformatalign?
                                        (double.parse(widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].mrp!) - double.parse(widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice!)).toString() + IConstants.currencyFormat:
                                        IConstants.currencyFormat +
                                            (double.parse(widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].mrp!) - double.parse(widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice!)).toString() /*+ " " +S.of(context).membership_price*/,
                                        style: TextStyle(fontSize: 9,/*fontWeight: FontWeight.bold,*/color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                    SizedBox(width: 5),
                                  ],
                                ),
                              ):SizedBox(height: 20,)
                              :VxBuilder(
                                mutations: {SetCartItem,ProductMutation},
                                builder: (context, GroceStore box, index) {
                                  return Column(
                                    children: [
                                      if(Features.isMembership && double.parse(widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString()) > 0)
                                        Row(
                                          children: <Widget>[
                                            !_checkmembership
                                                ? widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipDisplay!
                                                ? GestureDetector(
                                              onTap: () {
                                                if(!PrefUtils.prefs!.containsKey("apikey")) {
                                                  if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                                      context)) {
                                                    LoginWeb(context, result: (sucsess) {
                                                      if (sucsess) {
                                                        Navigator.of(context).pop();
                                                        /* Navigator.pushNamedAndRemoveUntil(
                                                      context, HomeScreen.routeName, (
                                                      route) => false);*/
                                                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                                                      } else {
                                                        Navigator.of(context).pop();
                                                      }
                                                    });
                                                  } else {
                                                    /* Navigator.of(context).pushNamed(
                                                SignupSelectionScreen.routeName,
                                              );*/
                                                    Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                                  }
                                                }
                                                else{
                                                  /*Navigator.of(context).pushNamed(
                                              MembershipScreen.routeName,
                                            );*/
                                                  Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                                }
                                              },
                                              child: Container(
                                                height: 19,
                                                // width: 80,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                                                    // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                  ),
                                                  color: ColorCodes.varcolor,
                                                ),

                                                child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizedBox(width: 3),
                                                    Image.asset(
                                                      Images.bottomnavMembershipImg,
                                                      color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                                      width: 14,
                                                      height: 8,),
                                                    Text(
                                                      // S .of(context).membership_price+ " " +//"Membership Price "
                                                        S.of(context).price + " ",
                                                        style: TextStyle(fontSize: 8.0,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                                                    Text(
                                                      // S .of(context).membership_price+ " " +//"Membership Price "
                                                        Features.iscurrencyformatalign?
                                                        widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                                        IConstants.currencyFormat +
                                                            widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString() /*+ " " +S.of(context).membership_price*/,
                                                        style: TextStyle(fontSize: 8.0,/*fontWeight: FontWeight.bold,*/color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                                    SizedBox(width: 5),
                                                  ],
                                                ),
                                              ),
                                            )
                                                : SizedBox.shrink()
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                      !_checkmembership
                                          ? widget._itemdata.priceVariation![Features.btobModule?_groupValue:itemindex].membershipDisplay!
                                          ? SizedBox(
                                        height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                      )
                                          : SizedBox(
                                        height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                      )
                                          : SizedBox(
                                        height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),


                    ],
                  ),
                ),
              ),
              SizedBox(height:4),
              Features.btobModule?
              Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0,),
                child: Container(
                  height:40,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(S.of(context).total,style: TextStyle(color: ColorCodes.blackColor)),
                          productBox
                              .where((element) =>
                          element.itemId == widget._itemdata.id).length > 0?
                          Text( IConstants.currencyFormat + (double.parse(widget._itemdata.priceVariation![_groupValue].price!) * /*(double.parse(productBox
                              .where((element) =>
                          element.itemId! == widget._itemdata.id
                          ).first.quantity!))*/_count).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                            style: TextStyle(
                                color: ColorCodes.greenColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),): Text( IConstants.currencyFormat + (double.parse(widget._itemdata.priceVariation![itemindex].price!)).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                            style: TextStyle(
                                color: ColorCodes.greenColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),),

                        ],
                      ),
                      Container(
                        height:(Features.isSubscription)?40:40,
                        width: _checkmembership?180:110,
                        child: Padding(
                          padding: const EdgeInsets.only(left:10,right:5.0),
                          child: Features.btobModule?CustomeStepper(priceVariation:widget._itemdata.priceVariation![itemindex],itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex,groupvalue: _groupValue,onChange: (int value,int count){
                            print("i value....groupvalue"+value.toString()+"count..."+count.toString());
                            setState(() {
                              _groupValue = value;
                              _count = count;
                            });
                          },):CustomeStepper(priceVariation:widget._itemdata.priceVariation![itemindex],itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex),
                        ),
                      ),
                    ],
                  ),
                ),
              ):
              Padding(
                padding: const EdgeInsets.only(left: 5.0,right: 5.0),
                child: Container(
                  height:40,
                  child: Row(
                    children: [
                      Container(
                        height:(Features.isSubscription)?38:38,
                        width: _checkmembership?188:173,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0,right: 5.0),
                          child: Features.btobModule?CustomeStepper(priceVariation:widget._itemdata.priceVariation![itemindex],itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex,groupvalue: _groupValue,onChange: (int value,int count){
                            print("i value....groupvalue"+value.toString()+"hjghjhh"+count.toString());
                            setState(() {
                              _groupValue = value;
                              _count = count;
                            });
                          },):CustomeStepper(priceVariation:widget._itemdata.priceVariation![itemindex],itemdata: widget._itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget._itemdata.addon!.length > 0)?widget._itemdata.addon![0]:null, index: itemindex),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             /* (widget._itemdata.priceVariation![itemindex].membershipDisplay!)?
              (Features.isSubscription)? SizedBox(height: 8):SizedBox(height: 5): Spacer(),
              if(widget._itemdata.priceVariation![itemindex].membershipDisplay!) Spacer(),*/

            ],
          ),
        ),
      ),
    );
  }

}