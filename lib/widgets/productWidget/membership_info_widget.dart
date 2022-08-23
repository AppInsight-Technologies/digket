import 'package:flutter/material.dart';
import '../../controller/mutations/cart_mutation.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../generated/l10n.dart';
import '../../helper/custome_checker.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../constants/IConstants.dart';
import '../../models/newmodle/product_data.dart';
import '../../constants/features.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/cartModle.dart';
import 'package:velocity_x/velocity_x.dart';

import '../custome_stepper.dart';

class MembershipInfoWidget extends StatelessWidget {
  var _checkmembership = false;
  final ItemData itemdata;
   int? itemindex;
  final int itemindexs;
  int? groupValue;
  final Function() ontap;
  Function(int)? onChangeRadio;
   MembershipInfoWidget({Key? key,required this.itemdata,required String varid, required this.itemindexs, required this.ontap, this.groupValue,this.onChangeRadio}){
     this.itemindex = itemdata.priceVariation!.indexWhere((element) => element.id == varid);
   }

  List<CartItem> productBox = /*Hive.box<Product>(productBoxName)*/(VxState.store as GroceStore).CartItemList;

  @override
  Widget build(BuildContext context)  {
print("membergroupvalue"+groupValue.toString()+"membership..."+_checkmembership.toString());

      return (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?Padding(
        padding: EdgeInsets.symmetric(horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?30:0),
        child: itemdata.type=="1"?
        VxBuilder(
            mutations: {ProductMutation},
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
            return
              _checkmembership?(double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!))>0?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 35,
                    width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                    MediaQuery.of(context).size.width / 2.03:(MediaQuery
                        .of(context)
                        .size
                        .width / 3) + 20 ,
                    // width: 80,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                        // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                      ),
                      color: ColorCodes.varcolor,
                    ),

                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 10),
                        Image.asset(
                          Images.bottomnavMembershipImg,
                          color: ColorCodes.primaryColor,
                          width: 15,
                          height: 10,),
                        Text( "Savings ",style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                       // Text( /*"Membership Savings "*/S.of(context).membership_saving,style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),
                        Text(
                            Features.iscurrencyformatalign?
                            (double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!)).toString() + IConstants.currencyFormat:
                            IConstants.currencyFormat +
                                (double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!)).toString() /*+ " " +S.of(context).membership_price*/,
                            style: TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                        SizedBox(width: 5),
                      ],
                    ),
                  ),
                  Spacer(),
                  itemdata.type=="1"?
                  Container(
                    height:(Features.isSubscription)?45:55,
                    width:  (MediaQuery.of(context).size.width/3)+5,
                    child: Padding(
                      padding: const EdgeInsets.only(left:5,right:5.0),
                      child: CustomeStepper(itemdata:itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,issubscription: "Add", ),
                    ),
                  )
                      :
                  Features.btobModule?
                  Container(
                    height:(Features.isSubscription)?45:55,
                    width:  (MediaQuery.of(context).size.width/3)+5,
                    child: Padding(
                      padding: const EdgeInsets.only(left:5,right:5.0),
                      child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,groupvalue: groupValue,onChange: (int value,int count){
                        print("group value...click..."+groupValue.toString()+"value.."+value.toString());
                        groupValue = value;

                      }),
                    ),
                  ):Container(
                    height:(Features.isSubscription)?45:55,
                    width:  (MediaQuery.of(context).size.width/3)+5,
                    child: Padding(
                      padding: const EdgeInsets.only(left:5,right:5.0),
                      child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,),
                    ),
                  ),
                ],
              ):SizedBox.shrink()
                  :
              Column(
              children: [
                if(Features.isMembership  && double.parse(itemdata.membershipPrice.toString()) > 0)
                  Row(
                    children: [
                      !_checkmembership
                          ? itemdata.membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          ontap();

                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                          padding: EdgeInsets.symmetric(vertical: 5,),
                          height: 35,
                          width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                          MediaQuery.of(context).size.width / 2.03:(MediaQuery.of(context)
                              .size
                              .width) -
                              20 ,
                          decoration: BoxDecoration(
                              color: ColorCodes.membershipColor),
                          child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  Features.iscurrencyformatalign ?
                                  itemdata.membershipPrice
                                      .toString() + IConstants.currencyFormat :
                                  IConstants.currencyFormat +
                                      itemdata
                                          .membershipPrice.toString(),
                                  style: TextStyle(
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
                              Spacer(),
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
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    ],
                  ),
                !_checkmembership
                    ? itemdata.membershipDisplay!
                    ? SizedBox(
                  height: 1,
                )
                    : SizedBox(
                  height: 1,
                )
                    : SizedBox(
                  height: 1,
                ),
              ],
            );
          }
        ):
        VxBuilder(
            mutations: {ProductMutation},
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
            return  _checkmembership?(double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!))>0?
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                  MediaQuery.of(context).size.width / 2.03:(MediaQuery
                      .of(context)
                      .size
                      .width / 3) + 20 ,
                  // width: 80,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                      // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                    ),
                    color: ColorCodes.varcolor,
                  ),

                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 10),
                      Image.asset(
                        Images.bottomnavMembershipImg,
                        color: ColorCodes.primaryColor,
                        width: 15,
                        height: 10,),
                      Text( "Savings ",style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                     // Text( /*"Membership Savings "*/S.of(context).membership_saving,style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),
                      Text(
                          Features.iscurrencyformatalign?
                          (double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!)).toString() + IConstants.currencyFormat:
                          IConstants.currencyFormat +
                              (double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!)).toString() /*+ " " +S.of(context).membership_price*/,
                          style: TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                      SizedBox(width: 5),
                    ],
                  ),
                ),
                Spacer(),
                itemdata.type=="1"?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(itemdata:itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,issubscription: "Add", ),
                  ),
                )
                    :
                Features.btobModule?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,groupvalue: groupValue,onChange: (int value,int count){
                      print("group value...click..."+groupValue.toString()+"value.."+value.toString());
                      groupValue = value;

                    }),
                  ),
                ):Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,),
                  ),
                ),
              ],
            ):SizedBox.shrink()
                :
              Column(
              children: [
                if(Features.isMembership  && double.parse(itemdata.priceVariation![itemindexs].membershipPrice.toString()) > 0)
                  Row(
                    children: [
                      !_checkmembership
                          ? itemdata.priceVariation![itemindexs].membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          ontap();

                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                          padding: EdgeInsets.symmetric(vertical: 5,),
                          height: 35,
                          width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                          MediaQuery.of(context).size.width / 2.03:(MediaQuery.of(context)
                              .size
                              .width) -
                              20 ,
                          decoration: BoxDecoration(
                              color: ColorCodes.membershipColor),
                          child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  Features.iscurrencyformatalign ?
                                  itemdata.priceVariation![itemindexs].membershipPrice
                                      .toString() + IConstants.currencyFormat :
                                  IConstants.currencyFormat +
                                      itemdata.priceVariation![itemindexs]
                                          .membershipPrice.toString(),
                                  style: TextStyle(
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
                              Spacer(),
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
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    ],
                  ),
                !_checkmembership
                    ? itemdata.priceVariation![itemindexs].membershipDisplay!
                    ? SizedBox(
                  height: 1,
                )
                    : SizedBox(
                  height: 1,
                )
                    : SizedBox(
                  height: 1,
                ),
              ],
            );
          }
        ),
      ):
        VxBuilder(
            mutations: {ProductMutation},
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
            return Padding(
            padding: EdgeInsets.symmetric(horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?30:0),
            child: itemdata.type=="1"?
            _checkmembership?(double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!))>0?
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                  MediaQuery.of(context).size.width / 2.03:(MediaQuery
                      .of(context)
                      .size
                      .width / 3) + 20 ,
                  // width: 80,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                      // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                    ),
                    color: ColorCodes.varcolor,
                  ),

                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 10),
                      Image.asset(
                        Images.bottomnavMembershipImg,
                        color: ColorCodes.primaryColor,
                        width: 15,
                        height: 10,),
                      Text( "Savings ",style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                      //Text( /*"Membership Savings "*/S.of(context).membership_saving,style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),
                      Text(
                          Features.iscurrencyformatalign?
                          (double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!)).toString() + IConstants.currencyFormat:
                          IConstants.currencyFormat +
                              (double.parse(itemdata.mrp!) - double.parse(itemdata.membershipPrice!)).toString() /*+ " " +S.of(context).membership_price*/,
                          style: TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                      SizedBox(width: 5),
                    ],
                  ),
                ),
                Spacer(),
                itemdata.type=="1"?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(itemdata:itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,issubscription: "Add", ),
                  ),
                )
                    :
                Features.btobModule?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,groupvalue: groupValue,onChange: (int value,int count){
                      print("group value...click..."+groupValue.toString()+"value.."+value.toString());
                      groupValue = value;

                    }),
                  ),
                ):Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,),
                  ),
                ),
              ],
            ):SizedBox.shrink()
                :
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    if(Features.isMembership  && double.parse(itemdata.membershipPrice.toString()) > 0)
                      Row(
                        children: [
                          !_checkmembership
                              ? itemdata.membershipDisplay!
                              ? GestureDetector(
                            onTap: () {
                              ontap();

                            },
                            child: Container(
                              // margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              // padding: EdgeInsets.symmetric(vertical: 5,),
                              height: 35,
                              width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                              MediaQuery.of(context).size.width / 2.03:(MediaQuery
                                  .of(context)
                                  .size
                                  .width / 3) + 10 ,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                                  // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                ),
                                color: ColorCodes.varcolor,
                              ),
                              child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(width: 10),
                                  Image.asset(
                                    Images.bottomnavMembershipImg,
                                    color: ColorCodes.primaryColor,
                                    width: 14,
                                    height: 8,),
                                  Text(
                                    // S .of(context).membership_price+ " " +//"Membership Price "
                                      S.of(context).price + " ",
                                      style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 10 : 12,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                  Text(
                                      Features.iscurrencyformatalign ?
                                      itemdata.membershipPrice
                                          .toString() + IConstants.currencyFormat :
                                      IConstants.currencyFormat +
                                          itemdata
                                              .membershipPrice.toString()/*+" Membership Price"*/,
                                      style: TextStyle(
                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor)),

                                ],
                              ),
                            ),
                          )
                              : SizedBox.shrink()
                              : SizedBox.shrink(),
                        ],
                      ),
                    !_checkmembership
                        ? itemdata.membershipDisplay!
                        ? SizedBox(
                      height: 1,
                    )
                        : SizedBox(
                      height: 1,
                    )
                        : SizedBox(
                      height: 1,
                    ),
                  ],
                ),
                Spacer(),
                itemdata.type=="1"?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(itemdata:itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,issubscription: "Add", ),
                  ),
                )
                    :Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs),
                  ),
                ),
              ],
            ):

            _checkmembership?(double.parse(itemdata.priceVariation![itemindexs].mrp!) - double.parse(itemdata.priceVariation![itemindexs].membershipPrice!))>0?
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 35,
                  width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                  MediaQuery.of(context).size.width / 2.03:(MediaQuery
                      .of(context)
                      .size
                      .width / 3) + 20 ,
                  // width: 80,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                      // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                    ),
                    color: ColorCodes.varcolor,
                  ),

                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 10),
                      Image.asset(
                        Images.bottomnavMembershipImg,
                        color: ColorCodes.primaryColor,
                        width: 15,
                        height: 10,),
                      Text( "Savings ",style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                      //Text( /*"Membership Savings "*/S.of(context).membership_saving,style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),
                      Text(
                          Features.iscurrencyformatalign?
                          (double.parse(itemdata.priceVariation![itemindexs].mrp!) - double.parse(itemdata.priceVariation![itemindexs].membershipPrice!)).toString() + IConstants.currencyFormat:
                          IConstants.currencyFormat +
                              (double.parse(itemdata.priceVariation![itemindexs].mrp!) - double.parse(itemdata.priceVariation![itemindexs].membershipPrice!)).toString() /*+ " " +S.of(context).membership_price*/,
                          style: TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                      SizedBox(width: 5),
                    ],
                  ),
                ),
                Spacer(),
                itemdata.type=="1"?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(itemdata:itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,issubscription: "Add", ),
                  ),
                )
                    :
                Features.btobModule?
                Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,groupvalue: groupValue,onChange: (int value,int count){
                      print("group value...click..."+groupValue.toString()+"value.."+value.toString());
                      groupValue = value;

                    }),
                  ),
                ):Container(
                  height:(Features.isSubscription)?45:55,
                  width:  (MediaQuery.of(context).size.width/3)+5,
                  child: Padding(
                    padding: const EdgeInsets.only(left:5,right:5.0),
                    child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,),
                  ),
                ),
              ],
            ):SizedBox.shrink()
                :
                      VxBuilder(
                mutations: {SetCartItem,ProductMutation},
                builder: (context, GroceStore box, index)  {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        if(Features.isMembership  && double.parse(itemdata.priceVariation![itemindexs].membershipPrice.toString()) > 0)
                          Row(
                            children: [
                              !_checkmembership
                                  ? itemdata.priceVariation![itemindexs].membershipDisplay!
                                  ? GestureDetector(
                                onTap: () {
                                  ontap();

                                },
                                child: Container(
                                //  margin: EdgeInsets.symmetric(/*vertical: 5*/horizontal: 10),
                                //  padding: EdgeInsets.symmetric(vertical: 5,),
                                  height: 35,
                                  width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                                  MediaQuery.of(context).size.width / 2.03:(MediaQuery
                                        .of(context)
                                        .size
                                        .width / 3) + 15 ,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                                      // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                    ),
                                    color: ColorCodes.varcolor,
                                  ),
                                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Image.asset(
                                        Images.bottomnavMembershipImg,
                                        color: ColorCodes.primaryColor,
                                        width: 14,
                                        height: 8,),
                                      Text(
                                        // S .of(context).membership_price+ " " +//"Membership Price "
                                          S.of(context).price + " ",
                                          style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 10 : 12,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                      Text(
                                          Features.iscurrencyformatalign ?
                                          itemdata.priceVariation![itemindexs].membershipPrice
                                              .toString() + IConstants.currencyFormat :
                                          IConstants.currencyFormat +
                                              itemdata.priceVariation![itemindexs]
                                                  .membershipPrice.toString()/*+" Membership Price"*/,
                                          style: TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                                    ],
                                  ),
                                ),
                              )
                                  : SizedBox.shrink()
                                  : SizedBox.shrink(),
                            ],
                          ),
                        !_checkmembership
                            ? itemdata.priceVariation![itemindexs].membershipDisplay!
                            ? SizedBox(
                          height: 1,
                        )
                            : SizedBox(
                          height: 1,
                        )
                            : SizedBox(
                          height: 1,
                        ),
                      ],
                    ),
                    Spacer(),
                    itemdata.type=="1"?
                    Container(
                      height:(Features.isSubscription)?45:45,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(itemdata:itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,issubscription: "Add", ),
                      ),
                    )
                        :
                    Features.btobModule?
                    Container(
                      height:(Features.isSubscription)?45:45,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,groupvalue: groupValue,onChange: (int value,int count){
                          print("group value...click..."+groupValue.toString()+"value.."+value.toString());
                          groupValue = value;

                        }),
                      ),
                    ):Container(
                      height:(Features.isSubscription)?45:45,
                      width:  (MediaQuery.of(context).size.width/3)+5,
                      child: Padding(
                        padding: const EdgeInsets.only(left:5,right:5.0),
                        child: CustomeStepper(priceVariation:itemdata.priceVariation![itemindexs],itemdata: itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(itemdata.addon!.length > 0)?itemdata.addon![0]:null, index: itemindexs,),
                      ),
                    ),
                  ],
                );
              }
            ),

      );
          }
        );
    }
  }

