import 'package:flutter/material.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../components/login_web.dart';
import '../../constants/IConstants.dart';
import '../../constants/features.dart';
import '../../generated/l10n.dart';
import '../../helper/custome_calculation.dart';
import '../../helper/custome_checker.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/product_data.dart';
import '../../rought_genrator.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../utils/prefUtils.dart';
import '../../widgets/custome_stepper.dart';
import '../../widgets/productWidget/product_sliding_image_widget.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controller/mutations/cart_mutation.dart';
import '../../models/newmodle/cartModle.dart';
import 'item_variation.dart';
import 'membership_info_widget.dart';

class ProductInfoWidget extends StatefulWidget {
  final ItemData itemdata;
  late int itemindex;
  late int itemindexs;
  final String variationId;
  Function() ontap;
  ProductInfoWidget({Key? key,required this.itemdata,required String varid,required this.itemindexs,required this.ontap,required this.variationId}){
     this.itemindex = itemdata.priceVariation!.indexWhere((element) => element.id == varid);
   }

  @override
  State<ProductInfoWidget> createState() => _ProductInfoWidgetState();
}

class _ProductInfoWidgetState extends State<ProductInfoWidget> with Navigations{
  int _groupValue = 0;
  List<CartItem> productBox=[];

  @override
  void initState() {
    // TODO: implement initState
    productBox = /*Hive.box<Product>(productBoxName)*/(VxState.store as GroceStore).CartItemList;
    if(Features.btobModule){
      if (productBox.where((element) => element.itemId == widget.itemdata.id)
          .count() >= 1) {
        debugPrint("count...1");
        for (int i = 0; i < productBox.length; i++) {
          debugPrint("count...1 if inside");
          for(int j = 0 ; j < widget.itemdata.priceVariation!.length; j++)
          {
            print("j value...."+j.toString()+"...."+widget.itemdata.priceVariation!.length.toString()+"///"+i.toString());
            print("proudct box id if..." + widget.itemdata.priceVariation![j].minItem.toString()+ widget.itemdata.priceVariation![j].maxItem.toString() + "hve varid..." + productBox.where((element) => element.itemId == widget.itemdata.id).first.quantity
                .toString());
            if ((int.parse(productBox.where((element) => element.itemId == widget.itemdata.id).first.quantity.toString()) >=  int.parse(widget.itemdata.priceVariation![j].minItem.toString())) && int.parse(productBox.where((element) => element.itemId == widget.itemdata.id).first.quantity.toString()) <=  int.parse(widget.itemdata.priceVariation![j].maxItem.toString())) {
              print("proudct box id if..." + widget.itemdata.priceVariation![j].quantity.toString() + "hve varid..." + productBox.where((element) => element.itemId == widget.itemdata.id).first.quantity
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
  @override
  Widget build(BuildContext context) {
    StateSetter? stateSetter;
    var _checkmembership = false;

    print("express ..."+VxState.store.userData.membership!.toString());
    debugPrint("widget.itemindexs...."+widget.itemindexs.toString());
    if ((VxState.store as GroceStore).userData.membership! == "1") {
        _checkmembership = true;

    } else {
        _checkmembership = false;
      for (int i = 0; i < (VxState.store as GroceStore).CartItemList.length; i++) {
        if ((VxState.store as GroceStore).CartItemList[i].mode == "1") {
            _checkmembership = true;
        }
      }
    }
    showoptions1(/*StateSetter setState*/) {
      (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState1) {
              return  Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius. only(topLeft: Radius. circular(15.0), topRight: Radius. circular(15.0)),),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  //height: 200,
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                  child: ItemVariation(itemdata: widget.itemdata,ismember: _checkmembership,selectedindex: widget.itemindexs,onselect: (i){
                    setState1(() {
                      widget.itemindex = i;
                      // Navigator.of(context).pop();
                    });
                  },),
                ),
              );
            });
          }).then((_) => stateSetter!(() { }))

          :showModalBottomSheet<dynamic>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius. only(topLeft: Radius. circular(15.0), topRight: Radius. circular(15.0)),),
          isScrollControlled: true,
          context: context,
          builder: (context) {
            //return StatefulBuilder(builder: (context, setState){
                return ItemVariation(itemdata: widget.itemdata,ismember: _checkmembership,selectedindex: widget.itemindexs,onselect: (i){
                  debugPrint("stateSetter.....1");
                  setState((){
                    debugPrint("stateSetter.....");
                    widget.itemindexs = i;
                    debugPrint("itemindexs...."+widget.itemindexs.toString());
                  });
                },);
             // }
           // );
          });
    }


    return  Padding(
      padding:  EdgeInsets.symmetric(horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?35:0),
      child: Container(
        width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
        MediaQuery.of(context).size.width / 2:(MediaQuery.of(context)
            .size
            .width) -
            20 ,
        child: Column(
          children: [

            (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))? SlidingImage(productdata: widget.itemdata,varid:widget.variationId,itemindexs:widget.itemindexs,ontap: (){},):(Vx.isWeb)?SizedBox.shrink():SlidingImage(productdata: widget.itemdata,varid:widget.variationId,itemindexs:widget.itemindexs,ontap: (){},),
            Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?Padding(
              padding:  EdgeInsets.symmetric(vertical:3.0,horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?10:0),
              child: Row(
                children: [
                  ///Show Brands
                  Text(
                    widget.itemdata.brand.toString(),
                    style: TextStyle(
                      fontSize: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?20:12,
                      fontWeight: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?FontWeight.bold:FontWeight.normal,
                    ),
                  ),
                  Spacer(),
                  ///Show margin
                  if (widget.itemdata.type=="1"?Calculate().getmargin(widget.itemdata.mrp,
                      VxState.store.userData.membership! == "0" || VxState.store.userData.membership! == "2" ?
                      widget.itemdata.discointDisplay! ? widget.itemdata.price : widget.itemdata.mrp
                          : widget.itemdata.membershipDisplay!? widget.itemdata.membershipPrice: widget.itemdata.price)>0:Calculate().getmargin(widget.itemdata.priceVariation![widget.itemindexs].mrp,
                      VxState.store.userData.membership! == "0" || VxState.store.userData.membership! == "2" ?
                      widget.itemdata.priceVariation![widget.itemindexs].discointDisplay! ? widget.itemdata.priceVariation![widget.itemindexs].price : widget.itemdata.priceVariation![widget.itemindexs].mrp
                          : widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice: widget.itemdata.priceVariation![widget.itemindexs].price)>0)
                    Container(
                      //margin: EdgeInsets.only(right:5.0),
                      padding: EdgeInsets.all(3.0),
                      // color: Theme.of(context).accentColor,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(3.0),
                        color: /*Color(0xff6CBB3C)*/Colors.transparent,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 28,
                        minHeight: 18,
                      ),
                      child: Text(
                        widget.itemdata.type=="1"?  Calculate().getmargin(widget.itemdata.mrp,
                            VxState.store.userData.membership! == "0" || VxState.store.userData.membership! == "2" ?
                            widget.itemdata.discointDisplay! ? widget.itemdata.price : widget.itemdata.mrp
                                : widget.itemdata.membershipDisplay!? widget.itemdata.membershipPrice: widget.itemdata.price).toStringAsFixed(2) + S .current.off:
                        Calculate().getmargin(widget.itemdata.priceVariation![widget.itemindexs].mrp,
                            VxState.store.userData.membership! == "0" || VxState.store.userData.membership! == "2" ?
                            widget.itemdata.priceVariation![widget.itemindexs].discointDisplay! ? widget.itemdata.priceVariation![widget.itemindexs].price : widget.itemdata.priceVariation![widget.itemindexs].mrp
                                : widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice: widget.itemdata.priceVariation![widget.itemindexs].price).toStringAsFixed(0) + S .current.off,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            color:ColorCodes.darkgreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ):SizedBox.shrink(),
            Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?Padding(
              padding:  EdgeInsets.symmetric(vertical: 3.0,horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?10:0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///Show Product Name
                      Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                      SizedBox(height: 10,):SizedBox.shrink(),
                      Text(
                        widget.itemdata.itemName.toString(),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?16:17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                      SizedBox(
                        height: 20.0,
                      ):
                      SizedBox(
                        height: 10.0,
                      ),
                      /// Show Product Price
                      Row(
                        children: [
                          if(Features.isMembership)
                            (_checkmembership)?Container(
                              width: 10.0,
                              height: 9.0,
                              margin: EdgeInsets.only(right: 3.0),
                              child: Image.asset(
                                Images.starImg,
                                color: ColorCodes.starColor,
                              ),
                            ):SizedBox.shrink(),
                          widget.itemdata.type=="1"?
                          RichText(
                            text: new TextSpan(
                              style: new TextStyle(
                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                new TextSpan(
                                    text: Features.iscurrencyformatalign?
                                    '${Check().checkmembership()?widget.itemdata.membershipPrice:widget.itemdata.price} ' + IConstants.currencyFormat:
                                    IConstants.currencyFormat + '${Check().checkmembership()?widget.itemdata.membershipPrice:widget.itemdata.price} ',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                                new TextSpan(
                                    text: widget.itemdata.price!=widget.itemdata.mrp?
                                    Features.iscurrencyformatalign?
                                    '${widget.itemdata.mrp} ' + IConstants.currencyFormat:
                                    IConstants.currencyFormat + '${widget.itemdata.mrp} ':"",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              ],
                            ),
                          ):
                          RichText(
                            text: new TextSpan(
                              style: new TextStyle(
                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                new TextSpan(
                                    text: Features.iscurrencyformatalign?
                                    '${Check().checkmembership()?widget.itemdata.priceVariation![widget.itemindexs].membershipPrice:widget.itemdata.priceVariation![widget.itemindexs].price} ' + IConstants.currencyFormat:
                                    IConstants.currencyFormat + '${Check().checkmembership()?widget.itemdata.priceVariation![widget.itemindexs].membershipPrice:widget.itemdata.priceVariation![widget.itemindexs].price} ',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                                new TextSpan(
                                    text: widget.itemdata.priceVariation![widget.itemindexs].price!=widget.itemdata.priceVariation![widget.itemindexs].mrp?
                                    Features.iscurrencyformatalign?
                                    '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ' + IConstants.currencyFormat:
                                    IConstants.currencyFormat + '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ':"",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        S .current.inclusive_of_all_tax,
                        style: TextStyle(
                            fontSize: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?12:8, color: Colors.grey),
                      )
                    ],
                  ),
                  ///Show Loyalty
                  widget.itemdata.type=="1"?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if(Features.isLoyalty)
                        if(double.parse(widget.itemdata.loyalty.toString()) > 0)
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(Images.coinImg,
                                  height: 15.0,
                                  width: 20.0,),
                                SizedBox(width: 4),
                                Text(widget.itemdata.loyalty.toString()),

                              ],
                            ),
                          ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (widget.itemdata.eligibleForExpress == "0") ?
                      Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):
                      SizedBox.shrink(),
                    ],
                  ):
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if(Features.isLoyalty)
                        if(double.parse(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()) > 0)
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(Images.coinImg,
                                  height: 15.0,
                                  width: 20.0,),
                                SizedBox(width: 4),
                                Text(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()),

                              ],
                            ),
                          ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      (widget.itemdata.eligibleForExpress == "0") ?
                      Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):
                      SizedBox.shrink(),
                    ],
                  )

                ],
              ),
            ):SizedBox.shrink(),
            (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width/2,
                      child: Text(
                        widget.itemdata.brand.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ///Show Product Name
                    Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                        SizedBox(height: 10,):SizedBox.shrink(),
                    Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width/2,
                      child: Text(
                        widget.itemdata.itemName.toString(),
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?16:20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                    SizedBox(
                      height: 20.0,
                    ):
                    SizedBox(
                      height: 10.0,
                    ),
                    /// Show Product Price
                    (widget.itemdata.type == "1")?
                        SizedBox.shrink()
                        :
                    ( widget.itemdata.priceVariation!.length > 1)
                        ?
                    //StatefulBuilder(builder: (context, setState) {
                      //debugPrint("sttateful...");
                        /*return*/ MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {

                              return showoptions1(/*setState*/);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(

                                  decoration: BoxDecoration(

                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        bottomLeft: const Radius.circular(2.0),
                                      )),
                                  height: 18,
                                  padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0),
                                  child: Text(
                                    "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                                    style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold,fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: ColorCodes.darkgreen,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ),
                        )
                      //}
                    //)
                        :
                    Container(
                      decoration: BoxDecoration(

                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(2.0),
                            topRight: const Radius.circular(2.0),
                            bottomLeft: const Radius.circular(2.0),
                            bottomRight: const Radius.circular(2.0),
                          )),
                      height: 18,
                      padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                      child: Text(
                        "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                        style: TextStyle(color:ColorCodes.greyColor,fontWeight: FontWeight.bold,fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    widget.itemdata.type == "1"?
                    Container(
                      width: MediaQuery.of(context).size.width/2,
                      child: Text(
                        widget.itemdata.singleshortNote.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorCodes.greyColor,
                        ),
                      ),
                    ):SizedBox.shrink(),
                    Row(
                      children: [
                        if(Features.isMembership)
                          (_checkmembership)?Container(
                            width: 10.0,
                            height: 9.0,
                            margin: EdgeInsets.only(right: 3.0),
                            child: Image.asset(
                              Images.starImg,
                              color: ColorCodes.starColor,
                            ),
                          ):SizedBox.shrink(),

                        widget.itemdata.type=="1"?
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                              new TextSpan(
                                  text: Features.iscurrencyformatalign?
                                  '${Check().checkmembership()?widget.itemdata.membershipPrice:widget.itemdata.price} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${Check().checkmembership()?widget.itemdata.membershipPrice:widget.itemdata.price} ',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              new TextSpan(
                                  text: widget.itemdata.price!=widget.itemdata.mrp?
                                  Features.iscurrencyformatalign?
                                  '${widget.itemdata.mrp} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${widget.itemdata.mrp} ':"",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                            ],
                          ),
                        ):
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                              new TextSpan(
                                  text: Features.iscurrencyformatalign?
                                  '${Check().checkmembership()?widget.itemdata.priceVariation![widget.itemindexs].membershipPrice:widget.itemdata.priceVariation![widget.itemindexs].price} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${Check().checkmembership()?widget.itemdata.priceVariation![widget.itemindexs].membershipPrice:widget.itemdata.priceVariation![widget.itemindexs].price} ',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              new TextSpan(
                                  text: widget.itemdata.priceVariation![widget.itemindexs].price!=widget.itemdata.priceVariation![widget.itemindexs].mrp?
                                  Features.iscurrencyformatalign?
                                  '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ':"",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
                ///Show Loyalty
                if(!Features.btobModule)
                widget.itemdata.type=="1"?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5,),
                    Features.isSubscription && widget.itemdata.eligibleForSubscription=="0"?
                    widget.itemdata.type=="1"?
                    Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Subscribe", ),
                      ),
                    )
                        :Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Subscribe",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                      ),
                    ):SizedBox(height: 35,),
                    if(Features.isLoyalty)
                      if(double.parse(widget.itemdata.loyalty.toString()) > 0)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(Images.coinImg,
                                height: 15.0,
                                width: 20.0,),
                              SizedBox(width: 4),
                              Text(widget.itemdata.loyalty.toString()),

                            ],
                          ),
                        ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    (widget.itemdata.eligibleForExpress == "0") ?
                    Image.asset(Images.express,
                      height: 20.0,
                      width: 25.0,):
                    SizedBox.shrink(),
                  ],
                ):
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5,),

                    Features.isSubscription && widget.itemdata.eligibleForSubscription=="0"?
                    widget.itemdata.type=="1"?
                    Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Subscribe", ),
                      ),
                    )
                        :Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Subscribe",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                      ),
                    ):SizedBox(height: 35,),
                    if(Features.isLoyalty)
                      if(double.parse(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()) > 0)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(Images.coinImg,
                                height: 15.0,
                                width: 20.0,),
                              SizedBox(width: 4),
                              Text(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()),

                            ],
                          ),
                        ),

                    (widget.itemdata.eligibleForExpress == "0") ?
                    Image.asset(Images.express,
                      height: 20.0,
                      width: 25.0,):
                    SizedBox.shrink(),
                    SizedBox(height: 10,),

                   ],
                )

              ],
            ):(Vx.isWeb)?SizedBox.shrink():
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Features.btobModule?MediaQuery.of(context).size.width/1.5:MediaQuery.of(context).size.width/2,
                      child: Text(
                        widget.itemdata.brand.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ///Show Product Name
                    Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                    SizedBox(height: 10,):SizedBox.shrink(),
                    Row(
                      children: [
                        Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width/2,
                          child: Text(
                            widget.itemdata.itemName.toString(),
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?16:17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if(Features.btobModule)SizedBox(width:MediaQuery.of(context).size.width*0.20),
                        if(Features.btobModule)
                          widget.itemdata.type=="1"?
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 5,),
                              Features.isSubscription && widget.itemdata.eligibleForSubscription=="0"?
                              widget.itemdata.type=="1"?
                              Container(
                                height:(Features.isSubscription)?45:55,
                                width:  (MediaQuery.of(context).size.width/3)+5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:5,right:5.0),
                                  child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Subscribe", ),
                                ),
                              )
                                  :Container(
                                height:(Features.isSubscription)?45:55,
                                width:  (MediaQuery.of(context).size.width/3)+5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:5,right:5.0),
                                  child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Subscribe",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                                ),
                              ):SizedBox(height: 35,),
                              if(Features.isLoyalty)
                                if(double.parse(widget.itemdata.loyalty.toString()) > 0)
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 15.0,
                                          width: 20.0,),
                                        SizedBox(width: 4),
                                        Text(widget.itemdata.loyalty.toString()),

                                      ],
                                    ),
                                  ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              (widget.itemdata.eligibleForExpress == "0") ?
                              Image.asset(Images.express,
                                height: 20.0,
                                width: 25.0,):
                              SizedBox.shrink(),
                            ],
                          ):
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 5,),

                              Features.isSubscription && widget.itemdata.eligibleForSubscription=="0"?
                              widget.itemdata.type=="1"?
                              Container(
                                height:(Features.isSubscription)?45:55,
                                width:  (MediaQuery.of(context).size.width/3)+5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:5,right:5.0),
                                  child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Subscribe", ),
                                ),
                              )
                                  :Container(
                                height:(Features.isSubscription)?45:55,
                                width:  (MediaQuery.of(context).size.width/3)+5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:5,right:5.0),
                                  child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Subscribe",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                                ),
                              ):SizedBox(height: 35,),
                              if(Features.isLoyalty)
                                if(double.parse(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()) > 0)
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 15.0,
                                          width: 20.0,),
                                        SizedBox(width: 4),
                                        Text(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()),

                                      ],
                                    ),
                                  ),

                              (widget.itemdata.eligibleForExpress == "0") ?
                              Image.asset(Images.express,
                                height: 20.0,
                                width: 25.0,):
                              SizedBox.shrink(),
                              SizedBox(height: 10,),

                            ],
                          )
                      ],
                    ),
                    Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                    SizedBox(
                      height: 20.0,
                    ):
                    SizedBox(
                      height: 10.0,
                    ),
                    /// Show Product Price
                    (widget.itemdata.type == "1")?
                    SizedBox.shrink()
                        :
                    ( widget.itemdata.priceVariation!.length > 1)
                        ?
                    Features.btobModule?
                    Container(
                      // height: 200,
                        width:MediaQuery.of(context).size.width*0.9,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: widget.itemdata.priceVariation!.length,
                            itemBuilder: (_, i) {
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {


                                    setState(() {
                                      _groupValue = i;
                                    });
                                    print("hdhvsdhsdfds"+""+widget.itemdata.id!+"..."+widget.itemdata.priceVariation![0].id.toString() +
                                        "..var id.." );
                                    if(productBox
                                        .where((element) =>
                                    element.itemId! == widget.itemdata.id
                                    ).length >= 1) {
                                      cartcontroller.update((done) {
                                        print("done value in calling update " + done.toString());
                                        setState(() {

                                        });
                                      }, price: widget.itemdata.price.toString(),
                                          quantity: widget.itemdata.priceVariation![i].minItem.toString(),
                                          type: widget.itemdata.type,
                                          weight: (/*weight +*/
                                              double.parse(widget.itemdata.increament!)).toString(),
                                          var_id: /*widget.itemdata!.id!*/widget.itemdata.priceVariation![0].id.toString(),
                                          increament: widget.itemdata.increament,
                                          cart_id: productBox
                                              .where((element) =>
                                          element.itemId! == widget.itemdata.id
                                          ).first.parent_id.toString(),
                                          toppings: "",
                                          topping_id: "",
                                          item_id: widget.itemdata.id!

                                      );
                                    }
                                    else {
                                      cartcontroller.addtoCart(itemdata: widget.itemdata,
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
                                          varid: widget.itemdata.priceVariation![0].id,
                                          toppings: "",
                                          parent_id: "",
                                          newproduct: "0",
                                          toppingsList: [],
                                          itembody: widget.itemdata.priceVariation![i],
                                          context: context);
                                      print("group value....2" + _groupValue.toString());
                                    }

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
                                                  "${widget.itemdata.priceVariation![i].minItem}"+"-"+"${widget.itemdata.priceVariation![i].maxItem}"+" "+"${widget.itemdata.priceVariation![i].unit}",
                                                  style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold),
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
                                      /* Container(
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
                           ),*/
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        )
                    ):
                    //StatefulBuilder(builder: (context, setState) {
                    //debugPrint("sttateful...");
                    /*return*/ MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {

                          return showoptions1(/*setState*/);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(

                              decoration: BoxDecoration(

                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(2.0),
                                    bottomLeft: const Radius.circular(2.0),
                                  )),
                              height: 18,
                              padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0),
                              child: Text(
                                "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                                style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold,fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: ColorCodes.darkgreen,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                          ],
                        ),
                      ),
                    )
                    //}
                    //)
                        :
                    Container(
                      decoration: BoxDecoration(

                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(2.0),
                            topRight: const Radius.circular(2.0),
                            bottomLeft: const Radius.circular(2.0),
                            bottomRight: const Radius.circular(2.0),
                          )),
                      height: 18,
                      padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                      child: Text(
                        "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                        style: TextStyle(color:ColorCodes.greyColor,fontWeight: FontWeight.bold,fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    widget.itemdata.type == "1"?
                    Container(
                      width: MediaQuery.of(context).size.width/2,
                      child: Text(
                        widget.itemdata.singleshortNote.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorCodes.greyColor,
                        ),
                      ),
                    ):SizedBox.shrink(),
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: [
                        if(Features.isMembership)
                          (_checkmembership)?Container(
                            width: 10.0,
                            height: 9.0,
                            margin: EdgeInsets.only(right: 3.0),
                            child: Image.asset(
                              Images.starImg,
                              color: ColorCodes.starColor,
                            ),
                          ):SizedBox.shrink(),
                        SizedBox(
                          height: 8.0,
                        ),
                        widget.itemdata.type=="1"?
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 16 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                              new TextSpan(
                                  text: Features.iscurrencyformatalign?
                                  '${Check().checkmembership()?widget.itemdata.membershipPrice:widget.itemdata.price} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${Check().checkmembership()?widget.itemdata.membershipPrice:widget.itemdata.price} ',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 16 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              new TextSpan(
                                  text: widget.itemdata.price!=widget.itemdata.mrp?
                                  Features.iscurrencyformatalign?
                                  '${widget.itemdata.mrp} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${widget.itemdata.mrp} ':"",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                            ],
                          ),
                        ):
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                              new TextSpan(
                                  text: Features.iscurrencyformatalign?
                                  '${Check().checkmembership()?widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].membershipPrice:widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].price} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${Check().checkmembership()?widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].membershipPrice:widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].price} ',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              new TextSpan(
                                  text: widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].price!=widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].mrp?
                                  Features.iscurrencyformatalign?
                                  '${widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].mrp} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${widget.itemdata.priceVariation![Features.btobModule?_groupValue:widget.itemindexs].mrp} ':"",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                            ],
                          ),
                        ),


                      ],
                    ),

                  ],
                ),
                ///Show Loyalty
                if(!Features.btobModule)
                widget.itemdata.type=="1"?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5,),
                    Features.isSubscription && widget.itemdata.eligibleForSubscription=="0"?
                    widget.itemdata.type=="1"?
                    Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Subscribe", ),
                    )
                        :Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Subscribe",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                    ):SizedBox(height: 45,),
                    if(Features.isLoyalty)
                      if(double.parse(widget.itemdata.loyalty.toString()) > 0)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(Images.coinImg,
                                height: 15.0,
                                width: 20.0,),
                              SizedBox(width: 4),
                              Text(widget.itemdata.loyalty.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                            ],
                          ),
                        ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // (widget.itemdata.eligibleForExpress == "0") ?
                    // Image.asset(Images.express,
                    //   height: 20.0,
                    //   width: 25.0,):
                    // SizedBox.shrink(),
                  ],
                ):
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 5,),

                    Features.isSubscription && widget.itemdata.eligibleForSubscription=="0"?
                    widget.itemdata.type=="1"?
                    Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Subscribe", ),
                    )
                        :Container(
                      height:(Features.isSubscription)?45:55,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Subscribe",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                    ):SizedBox(height: 35,),
                    if(Features.isLoyalty)
                      if(double.parse(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()) > 0)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(Images.coinImg,
                                height: 15.0,
                                width: 20.0,),
                              SizedBox(width: 4),
                              Text(widget.itemdata.priceVariation![widget.itemindexs].loyalty.toString()
                              , style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

                            ],
                          ),
                        ),

                    // (widget.itemdata.eligibleForExpress == "0") ?
                    // Image.asset(Images.express,
                    //   height: 20.0,
                    //   width: 25.0,):
                    // SizedBox.shrink(),
                    SizedBox(height: 10,),

                  ],
                )

              ],
            ),
           (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))? SizedBox(height: 10,):(Vx.isWeb)?SizedBox.shrink():SizedBox(height: 10,),
            (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))?  (Features.isMembership)?
              MembershipInfoWidget(itemdata: widget.itemdata,varid:widget.variationId ,itemindexs:widget.itemindexs,ontap:(){
                (!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
                // _dialogforSignIn() :
                LoginWeb(context,result: (sucsess){
                  if(sucsess){
                    Navigator.of(context).pop();
                    Navigation(context, navigatore: NavigatoreTyp.homenav);
                    /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                  }else{
                    Navigator.of(context).pop();
                  }
                })
                    :
                (!PrefUtils.prefs!.containsKey("apikey") && !Vx.isWeb)?
                /* Navigator.of(context).pushReplacementNamed(
                      SignupSelectionScreen.routeName)*/
                Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                    :/*Navigator.of(context).pushNamed(
                    MembershipScreen.routeName,
                  );*/
                Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
              }):
            widget.itemdata.type=="1"?
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height:(Features.isSubscription)?45:55,
                width:  (MediaQuery.of(context).size.width/3)+5,
                child: Padding(
                  padding: const EdgeInsets.only(left:5,right:5.0),
                  child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Add", ),
                ),
              ),
            )
                :Align(
              alignment: Alignment.topRight,
                  child: Container(
              height:(Features.isSubscription)?45:55,
              width:  (MediaQuery.of(context).size.width/3)+5,
              child: Padding(
                  padding: const EdgeInsets.only(left:5,right:5.0),
                  child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
              ),
            ),
                ): (Vx.isWeb)?SizedBox.shrink():(Features.isMembership)?
                Features.btobModule?
            MembershipInfoWidget(itemdata: widget.itemdata,varid:widget.variationId ,itemindexs:widget.itemindexs,ontap:(){
              (!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
              // _dialogforSignIn() :
              LoginWeb(context,result: (sucsess){
                if(sucsess){
                  Navigator.of(context).pop();
                  Navigation(context, navigatore: NavigatoreTyp.homenav);
                  /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                }else{
                  Navigator.of(context).pop();
                }
              })
                  :
              (!PrefUtils.prefs!.containsKey("apikey") && !Vx.isWeb)?
              /* Navigator.of(context).pushReplacementNamed(
                      SignupSelectionScreen.routeName)*/
              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                  :/*Navigator.of(context).pushNamed(
                    MembershipScreen.routeName,
                  );*/
              Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
            },groupValue: _groupValue,onChangeRadio: (int value){
              print("product info widget....."+value.toString()+ "  "+_groupValue.toString());
              _groupValue = value;
            },):
                MembershipInfoWidget(itemdata: widget.itemdata,varid:widget.variationId ,itemindexs:widget.itemindexs,ontap:(){
                  (!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
                  // _dialogforSignIn() :
                  LoginWeb(context,result: (sucsess){
                    if(sucsess){
                      Navigator.of(context).pop();
                      Navigation(context, navigatore: NavigatoreTyp.homenav);
                      /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                    }else{
                      Navigator.of(context).pop();
                    }
                  })
                      :
                  (!PrefUtils.prefs!.containsKey("apikey") && !Vx.isWeb)?
                  /* Navigator.of(context).pushReplacementNamed(
                      SignupSelectionScreen.routeName)*/
                  Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                      :/*Navigator.of(context).pushNamed(
                    MembershipScreen.routeName,
                  );*/
                  Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                },):
            widget.itemdata.type=="1"?
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height:(Features.isSubscription)?45:55,
                width:  (MediaQuery.of(context).size.width/3)+5,
                child: Padding(
                  padding: const EdgeInsets.only(left:5,right:5.0),
                  child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Add", ),
                ),
              ),
            )
                :
                Features.btobModule?
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height:(Features.isSubscription)?45:55,
                    width:  (MediaQuery.of(context).size.width/3)+5,
                    child: Padding(
                      padding: const EdgeInsets.only(left:5,right:5.0),
                      child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,groupvalue: _groupValue,onChange: (int value,int count){
                        print("product info stpeer..."+_groupValue.toString() +"  "+value.toString());
                        setState(() {
                          _groupValue = value;
                        });
                        print("product info stpeer...after"+_groupValue.toString() +"  "+value.toString());
                      }),
                    ),
                  ),
                ):
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height:(Features.isSubscription)?45:55,
                width:  (MediaQuery.of(context).size.width/3)+5,
                child: Padding(
                  padding: const EdgeInsets.only(left:5,right:5.0),
                  child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs),
                ),
              ),
            ),

            if(Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
            Row(
              children: [
                widget.itemdata.type=="1"?    Container(
                  //width: (MediaQuery.of(context).size.width / 7) ,
                  padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      /* border: Border.all(
                                  color: ColorCodes.greenColor,),*/
                        color: ColorCodes.whiteColor,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(2.0),
                          bottomLeft: const Radius.circular(2.0),
                          bottomRight: const Radius.circular(2.0),
                        )),
                    height: 30,
                    width: (MediaQuery.of(context).size.width / 7),
                    padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                    child: SizedBox.shrink(),
                  ),
                ):
                Container(
                  //width: (MediaQuery.of(context).size.width / 7) ,
                  padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                  child: ( widget.itemdata.priceVariation!.length > 1)
                      ?
                  GestureDetector(
                    onTap: () {
                      widget.ontap();

                    },
                    child: Container(
                      height: 30,
                      width: (MediaQuery.of(context).size.width / 7),
                      decoration: BoxDecoration(
                        /*border: Border.all(
                                          color: ColorCodes.greenColor,),*/
                          color: ColorCodes.varcolor,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(2.0),
                            bottomLeft: const Radius.circular(2.0),
                            topRight: const Radius.circular(2.0),
                            bottomRight: const Radius.circular(2.0),
                          )),
                      child: Row(
                        children: [
                          Text(

                            "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                            style:
                            TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                          ),
                          // ),
                          Spacer(),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: ColorCodes.varcolor,
                                borderRadius: new BorderRadius.only(
                                  topRight:
                                  const Radius.circular(2.0),
                                  bottomRight:
                                  const Radius.circular(2.0),
                                )),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color:ColorCodes.darkgreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      /* border: Border.all(
                                  color: ColorCodes.greenColor,),*/
                        color: ColorCodes.varcolor,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(2.0),
                          topRight: const Radius.circular(2.0),
                          bottomLeft: const Radius.circular(2.0),
                          bottomRight: const Radius.circular(2.0),
                        )),
                    height: 30,
                    width: (MediaQuery.of(context).size.width / 7),
                    padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                    child: Text(
                      "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                      style:
                      TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          widget.itemdata.type=="1"?
                          Container(
                            width: MediaQuery.of(context).size.width/7,
                            child: CustomeStepper(itemdata: widget.itemdata,alignmnt: StepperAlignment.Vertical,height:(Features.isSubscription)?40:40,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null,index:widget.itemindexs,issubscription: "Subscribe",),
                          ):
                          Container(
                            width: MediaQuery.of(context).size.width/7,
                            child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],
                                itemdata: widget.itemdata,alignmnt: StepperAlignment.Vertical,height:(Features.isSubscription)?40:40,
                                addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null,index:widget.itemindexs,issubscription: "Subscribe",),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          widget.itemdata.type=="1"?
                          Container(
                            width: MediaQuery.of(context).size.width/7,
                            child: CustomeStepper(itemdata: widget.itemdata,alignmnt: StepperAlignment.Vertical,height:(Features.isSubscription)?40:40,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null,index:widget.itemindexs,issubscription:"Add"),
                          ):
                          Container(
                            width: MediaQuery.of(context).size.width/7,
                            child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],
                            itemdata: widget.itemdata,alignmnt: StepperAlignment.Vertical,height:(Features.isSubscription)?40:40,
                                addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null,index:widget.itemindexs,issubscription:"Add"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
