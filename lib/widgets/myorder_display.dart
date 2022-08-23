import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../repository/authenticate/AuthRepo.dart';
import '../constants/api.dart';
import '../constants/features.dart';
import '../generated/l10n.dart';
import '../models/myordersfields.dart';
import '../rought_genrator.dart';
import '../screens/rate_order_screen.dart';
import '../screens/orderhistory_screen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/addressitems.dart';
import '../screens/return_screen.dart';
import '../screens/address_screen.dart';
import '../constants/IConstants.dart';
import '../screens/myorder_screen.dart';
import '../assets/images.dart';
import '../utils/ResponsiveLayout.dart';
import '../utils/prefUtils.dart';
import '../assets/ColorCodes.dart';


extension StringCasingExtension on String {
  String toCapitalized() => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get toTitleCase => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.toCapitalized()).join(" ");
}


class MyorderDisplay extends StatefulWidget {
  // final int refer_id;
  List<MyordersFields> splitorder;

  MyorderDisplay(
      this.splitorder,
  );

  @override
  _MyorderDisplayState createState() => _MyorderDisplayState();
}


class _MyorderDisplayState extends State<MyorderDisplay> with Navigations{
  bool _showreorder = false;
  bool _showCancelled = false;
  bool _showReturn = false;
  int _groupValue = -1;
  var _message = TextEditingController();
  var _comment = TextEditingController();
  var _isWeb = false;
  int itemleftcount = 0;
  bool _rateorder = false;
  double ratings = 3.0;
  int? splitlength;
  List<List<MyordersFields>> myorders =[] ;
  String comment = S .current.good;

  @override
  void initState() {
    try {
      if (Platform.isIOS) {
        setState(() {
          _isWeb = false;
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

    Future.delayed(Duration.zero, () async {
      _message.text = "";
      _comment.text = "";


    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double orderamount = 0.0;
double totalamount = 0.0;

    Future<void> RateOrder(var rating,String orderid) async {
      try {
        final response = await http.post(Api.addRatings, body: {
          // await keyword is used to wait to this operation is complete.
          "user": PrefUtils.prefs!.getString('apikey'),
          "order":orderid.toString(),
          "star": rating.toString(),
          "comment": comment.toString(),
          "branch": PrefUtils.prefs!.getString('branch'),
        });
        final responseJson = json.decode(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        if (responseJson['status'].toString() == "200") {
          /*Navigator.of(context).pushReplacementNamed(
          MyorderScreen.routeName,
            arguments: {
              "orderhistory": ""
            }
        );*/
          Navigation(context, name:Routename.MyOrders,navigatore: NavigatoreTyp.Push,
            //     parms: {
            //   "orderhistory": ""
            // }
          );
        } else {
          Fluttertoast.showToast(msg: S .current.something_went_wrong, fontSize: MediaQuery.of(context).textScaleFactor *13,);
        }
      } catch (error) {
        Navigator.pop(context);

        Fluttertoast.showToast(msg: S .current.something_went_wrong, fontSize: MediaQuery.of(context).textScaleFactor *13,);
        throw error;
      }
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

    showModalRateOrder( BuildContext context , setState,String orderid ) {
      showModalBottomSheet<dynamic>(
          isScrollControlled: true,
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius. only(topLeft: Radius. circular(15.0), topRight: Radius. circular(15.0)),
          ),
          builder: (context1) {
            return Wrap(
              children: [
                StatefulBuilder(builder: (context, setState1) {
                  return
                    SingleChildScrollView(
                      child: Container(
                        //height: 400,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(Images.starimage,height:200,),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  S .of(context).rate_your_order,
                                  style: TextStyle(fontSize: 18.0,color: ColorCodes.blackColor),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                /*Padding(
                padding: _isWeb?EdgeInsets.symmetric(horizontal:700):EdgeInsets.symmetric(horizontal:120.0),
                child: Divider(color: ColorCodes.darkgreen,thickness: 2,),
              ),*/
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  S .of(context).refund_orderid+ " : " + orderid.toString(),
                                  style: TextStyle(fontSize: 20.0,color: ColorCodes.blackColor,fontWeight: FontWeight.bold),
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
                                    color: ColorCodes.primaryColor,
                                  ),

                                  onRatingUpdate: (rating) {
                                    ratings = rating;
                                    if(ratings == 5){
                                      setState1(() {
                                        comment = S .of(context).excellent;//"Excellent";
                                      });

                                    }
                                    else if(ratings == 4){
                                      setState1(() {
                                        comment = S .of(context).good;//"Good";
                                      });

                                    }
                                    else if(ratings == 3){
                                      setState1(() {
                                        comment = S .of(context).average;//"Average";
                                      });

                                    }
                                    else if(ratings == 2){
                                      setState1(() {
                                        comment = S .of(context).bad;//"Bad";
                                      });
                                    }
                                    else if(ratings == 1){
                                      setState1(() {
                                        comment = S .of(context).verybad;//"Very Bad";
                                      });
                                    }
                                  },
                                ),

                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  comment,
                                  style: TextStyle(fontSize: 18.0,color: ColorCodes.blackColor),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      _dialogforProcessing();
                                      RateOrder(ratings,orderid.toString());
                                      /*Navigator.of(context).pushReplacementNamed(
                        MyorderScreen.routeName);*/
                                    },
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      //color: ColorCodes.greenColor,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
                      ),
                    );
                }),
              ],
            );
          });
    }
return Column(
  children: [
    Container(
      color: ColorCodes.whiteColor,
      //height: MediaQuery.of(context).size.height / 3,
      margin: EdgeInsets.only(left: 10,right: 10,top: 10),

      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
              ...widget.splitorder.map((e)
              {
                if (e.ostatus!.toLowerCase() == "received" ||
                    e.ostatus!.toLowerCase() == "ready") {
                  _showreorder = true;
                  _showCancelled = true;
                } else if (e.ostatus!.toLowerCase() == "delivered" ||
                    e.ostatus!.toLowerCase() == "completed") {
                  setState(() {
                    _showreorder = true;
                    _rateorder = true;
                    _showReturn = true;

                  });
                }
                if(e.itemodelcharge !=0){
                  orderamount= double.parse(e.itemoactualamount!) +
                      double.parse(e.itemodelcharge!) - e.loyalty!
                      - double.parse(e.totalDiscount!) + double.parse(e.dueamount!);
                }
                else{
                  orderamount= double.parse(e.itemoactualamount!) - e.loyalty!
                      - double.parse(e.totalDiscount!) + double.parse(e.dueamount!);
                }

                totalamount = totalamount + orderamount;
                itemleftcount = int.parse(e.itemLeftCount!) + 1;

                Widget membershipImage() {
                  if (e.extraAmount == "888") {
                    return Container(
                      width: 75,
                      child: Column(
                        children: [
                          Image.asset(Images.membershipImg,
                            color: Theme.of(context).primaryColor,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      width: 75,
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: e.itemImage,
                            placeholder: (context, url) => Image.asset(
                              Images.defaultProductImg,
                              width: 75,
                              height: 75,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              Images.defaultProductImg,
                              width: 75,
                              height: 75,
                            ),
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    );
                  }
                }
                _dialogforProcessing() {
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

                Future<void> cancelOrder() async {
                  try {
                    debugPrint("respo....body"+{
                      "id": e.oid,
                      "note": _message.text,
                      "branch": PrefUtils.prefs!.getString('branch'),
                    }.toString());
                    final response = await http.post(Api.cancelOrder, body: {
                      "id": e.oid,
                      "note": _message.text,
                      "branch": PrefUtils.prefs!.getString('branch'),
                    });
                    final responseJson = json.decode(response.body);
                    debugPrint("respo....canc"+responseJson.toString());
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (responseJson['status'].toString() == "200") {
                      /*Navigator.of(context).pushReplacementNamed(
                        MyorderScreen.routeName,
                          arguments: {
                            "orderhistory": ""
                          }
                      );*/
                      auth.getuserProfile(onsucsess: (value){
                      }, onerror: (){
                      });
                      Navigator.pop(context);
                      Navigation(context, name:Routename.MyOrders,navigatore: NavigatoreTyp.Push,

                         /* parms: {
                        "orderhistory": ""
                      }*/);

                    } else {
                       Fluttertoast.showToast(msg: S .current.something_went_wrong, fontSize: MediaQuery.of(context).textScaleFactor *13,);
                    }
                  } catch (error) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: S .current.something_went_wrong, fontSize: MediaQuery.of(context).textScaleFactor *13,);
                    throw error;
                  }
                }

                Widget _myRadioButton({String? title, int? value, required Function(int?) onChanged}) {
                  final addressitemsData =
                  Provider.of<AddressItemsList>(context, listen: false);

                  if (_groupValue == 0) {
                    PrefUtils.prefs!.setString("return_type", "0"); // 0 => Return
                    Future.delayed(Duration.zero, () async {
                      Navigator.pop(context);
                      _groupValue = -1;

                      if (addressitemsData.items.length > 0) {
                       /* Navigator.of(context).pushNamed(ReturnScreen.routeName, arguments: {
                          'orderid':e.oid,
                        });*/
                        Navigation(context, name:Routename.Return,navigatore: NavigatoreTyp.Push,
                            parms: {
                              'orderid':e.oid!,
                            });
                      } else {
                        PrefUtils.prefs!.setString("addressbook", "myorderdisplay");
                      /*  Navigator.of(context).pushNamed(AddressScreen.routeName, arguments: {
                          'addresstype': "new",
                          'addressid': "",
                          'delieveryLocation': "",
                        });*/
                        Navigation(context, name: Routename.AddressScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              'addresstype': "new",
                              'addressid': "",
                              'delieveryLocation': "",
                            });
                      }
                    });
                  } else if (_groupValue == 1) {
                    PrefUtils.prefs!.setString("return_type", "1"); // 1 => Exchange
                    Future.delayed(Duration.zero, () async {
                      Navigator.pop(context);
                      _groupValue = -1;
                      if (addressitemsData.items.length > 0) {
                        /*Navigator.of(context).pushNamed(ReturnScreen.routeName, arguments: {
                          'orderid': e.oid,
                        });*/
                        Navigation(context, name:Routename.Return,navigatore: NavigatoreTyp.Push,
                            parms: {
                              'orderid':e.oid!,
                            });
                      } else {
                        PrefUtils.prefs!.setString("addressbook", "myorderdisplay");
                       /* Navigator.of(context).pushNamed(AddressScreen.routeName, arguments: {
                          'addresstype': "new",
                          'addressid': "",
                          'orderid': e.oid,
                          'delieveryLocation': "",
                        });*/
                        Navigation(context, name: Routename.AddressScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              'addresstype': "new",
                              'addressid': "",
                              'delieveryLocation': "",
                              'orderid': e.oid,
                            });
                      }
                    });
                  }

                  return RadioListTile<int>(
                    activeColor: Theme.of(context).primaryColor,
                    value: value!,
                    groupValue: _groupValue,
                    onChanged: onChanged,
                    title: Text(title!),
                  );
                }
                // _dialogforReturn(BuildContext context) {
                //   return showDialog(
                //       context: context,
                //       builder: (context) {
                //         return StatefulBuilder(builder: (context, setState) {
                //           return Dialog(
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(3.0)),
                //             child: Container(
                //                 width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                //                 height: 150.0,
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.center,
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: <Widget>[
                //                     SizedBox(
                //                       height: 10.0,
                //                     ),
                //                     Text( S .of(context).do_you_want_return_exchange,
                //                       // "Do you want to return or exchange",
                //                       style: TextStyle(
                //                         color: Colors.black,
                //                       ),
                //                     ),
                //                     _myRadioButton(
                //                       title: S .of(context).returns,
                //                       // "Return",
                //                       value: 0,
                //                       onChanged: (newValue) =>
                //                           setState(() => _groupValue = newValue),
                //                     ),
                //                     _myRadioButton(
                //                       title: S .of(context).exchange,
                //                       //"Exchange",
                //                       value: 1,
                //                       onChanged: (newValue) =>
                //                           setState(() => _groupValue = newValue),
                //                     ),
                //                   ],
                //                 )),
                //           );
                //         });
                //       });
                // }

                _dialogforCancel(BuildContext context) {
                  return showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.0)),
                            child: Container(
                                width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                                height: 250.0,
                                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(  S .of(context).ordered_ID
                                        // "Order ID: "
                                        + e.oid!,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    TextField(
                                      controller: _message,
                                      decoration: InputDecoration(
                                        hintText:
                                        S .of(context).reason_optionla,
                                        //"Reasons (Optional)",
                                        contentPadding: EdgeInsets.all(16),
                                        border: OutlineInputBorder(),
                                      ),
                                      minLines: 3,
                                      maxLines: 5,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        _dialogforProcessing();
                                        cancelOrder();
                                      },
                                      child: Text(  S .of(context).next,
                                        //"Next",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                )),
                          );
                        });
                      });
                }

               return Padding(
                 padding: const EdgeInsets.symmetric(
                     vertical: 8.0, horizontal: 16),
                 child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // SizedBox(
                      //   height: 10,
                      // ),
                      Row(
                        children: [
                          Text(
                            S .of(context).refund_orderid + ": ",
                            style: TextStyle(
                                color: ColorCodes.greenColor,
                                //Theme.of(context).primaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "#" + e.oid!,
                            style: TextStyle(
                                color: ColorCodes.greenColor,
                                //Theme.of(context).primaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          (e.orderType!.toLowerCase() == "pickup")
                              ? Row(
                            children: [
                              Text(
                                  e.ostatus
                                      !.toLowerCase()
                                      .toCapitalized(),
                                  style: TextStyle(
                                      color: ColorCodes.greyColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                              : (e.returnStatus == "" ||
                              e.returnStatus == "null")
                              ?

                          //
                          (e.ostatus == "CANCELLED")
                              ? Text(
                              e.ostatus
                                  !.toLowerCase()
                                  .toCapitalized(),
                              style: TextStyle(
                                  color: ColorCodes.redColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold))
                              : Row(
                            children: [
                              Text(
                                  e.ostatus
                                      !.toLowerCase()
                                      .toCapitalized(),
                                  style: TextStyle(
                                      color: ColorCodes
                                          .greyColor,
                                      fontSize: 14.0,
                                      fontWeight:
                                      FontWeight.bold)),
                              SizedBox(
                                width: 5,
                              ),
                              if (e.ostatus!.toLowerCase() ==
                                  "delivered" ||
                                  e.ostatus!.toLowerCase() ==
                                      "completed")
                                Image.asset(Images.delivered,
                                    height: 25.0,
                                    width: 25.0),
                              if (e.ostatus!.toLowerCase() ==
                                  "received")
                                Image.asset(Images.received,
                                    height: 25.0,
                                    width: 25.0),
                              if (e.ostatus!.toLowerCase() ==
                                  "dispatched" ||
                                  e.ostatus!.toLowerCase() ==
                                      "out for delivery")
                                Image.asset(
                                    Images.outdelivery,
                                    height: 25.0,
                                    width: 25.0),
                            ],
                          )
                              : Text(e.returnStatus!.toUpperCase(),
                              style: TextStyle(
                                  color: ColorCodes.redColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [
                          Text(
                            //"+ " +
                            itemleftcount.toString() +
                                " " +
                                S .of(context).items,
                            //   " more items",
                            style: TextStyle(color: ColorCodes.greyColor),
                          ),
                          Spacer(),
                          if (e.orderType == "express")
                            Row(
                              children: [
                                Text(
                                  e.orderType!.toCapitalized(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorCodes.greyColor),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Image.asset(Images.expressdelivery,
                                    height: 25.0, width: 25.0),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        Features.iscurrencyformatalign?
                        orderamount.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit) + ' ' + IConstants.currencyFormat:
                      IConstants.currencyFormat + ' ' + orderamount.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorCodes.greyColor),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Text(
                                  (e.paymentType == "cod".toLowerCase()
                                      ? S .of(context).cash_delivery
                                      : e.paymentType!.toCapitalized()),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorCodes.greyColor),
                                ),
                      SizedBox(
                        height: 10,
                      ),
                      DottedLine(
                        dashColor: ColorCodes.lightGreyColor,
                      ),
                      if (e.ostatus == "CANCELLED")
                        SizedBox(
                          height: 10,
                        ),
                      if (e.ostatus != "CANCELLED")
                        SizedBox(
                          height: 10,
                        ),
                      if (e.ostatus != "CANCELLED")
                        Row(
                          children: [
                            Text(
                              S .of(context).scheduled_delivery, //widget.odelivery,
                              style: TextStyle(
                                  color: ColorCodes.greyColor,
                                  //Theme.of(context).primaryColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              e.odate!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: ColorCodes.darkGrey,
                                  //Theme.of(context).primaryColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              e.odeltime!,
                              style: TextStyle(
                                  color: ColorCodes.darkGrey,
                                  //Theme.of(context).primaryColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            // (ResponsiveLayout.isSmallScreen(context)|| ResponsiveLayout.isMediumScreen(context))?
                            // SizedBox(
                            //   width: 45,
                            // ):
                            // SizedBox(
                            //   width: MediaQuery.of(context).size.width - 400,
                            // ),
                            // Text(
                            //   widget.odate,
                            //   textAlign: TextAlign.right,
                            //   style: TextStyle(
                            //       color: Theme.of(context).primaryColor,
                            //       fontSize: 12.0,
                            //       fontWeight: FontWeight.bold
                            //   ),
                            // )
                          ],
                        ),
                      if (e.ostatus != "CANCELLED")
                        SizedBox(
                          height: 20,
                        ),
                      Row(
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (e.odelivery == "DELIVERY ON") {
                                } else {}
                                /*Navigator.of(context).pushNamed(OrderhistoryScreen.routeName,
                                    arguments: {
                                      'orderid' : widget.oid,
                                      'fromScreen' : "myOrders",
                                    }
                                );*/
                                if(_isWeb){
                                 /* Navigator.pushNamedAndRemoveUntil(context, OrderhistoryScreen.routeName, (route) => false,
                                      arguments: {
                                        'orderid': e.oid,
                                        'orderStatus': e.ostatus,
                                        'fromScreen': "webmyOrders",
                                      });*/
                                  Navigation(context, name:Routename.OrderHistory,navigatore: NavigatoreTyp.Push,
                                      qparms: {
                                        'orderid': e.oid!,
                                        'orderStatus': e.ostatus!,
                                        'fromScreen': "webmyOrders",
                                      });

                                }else{
                                  /*Navigator.of(context).pushNamed(
                                      OrderhistoryScreen.routeName,
                                      arguments: {
                                        'orderid': e.oid,
                                        'orderStatus': e.ostatus,
                                        'fromScreen': "myOrders",
                                      });*/
                                  Navigation(context, name:Routename.OrderHistory,navigatore: NavigatoreTyp.Push,
                                      qparms: {
                                        'orderid': e.oid!,
                                        'orderStatus': e.ostatus!,
                                        'fromScreen': "myOrders",
                                      });
                                }

                              },
                              child: Container(
                                height: 35,
                                width: 125,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                      color: ColorCodes.greenColor),
                                  // color: Theme.of(context).primaryColor
                                ),
                                child: Center(
                                    child: Text(
                                      S .of(context).view_details_order,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: ColorCodes
                                            .greenColor, //Theme.of(context).buttonColor,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          Spacer(),
                          // MouseRegion(
                          //  cursor: SystemMouseCursors.click,
                          //      child: GestureDetector(
                          //     onTap: () {
                          //       Navigator.of(context).pushNamed(
                          //         HelpScreen.routeName,
                          //       );
                          //     },
                          //     child: Container(
                          //       height: 35,
                          //       width: 125,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(3),
                          //           border:
                          //               Border.all(color: Theme.of(context).primaryColor),
                          //           color: Theme.of(context).buttonColor),
                          //       child: Center(
                          //           child: Text(
                          //             S .of(context).help,
                          //             style: TextStyle(fontSize: 13,
                          //                 color: Theme.of(context).primaryColor,
                          //                 fontWeight: FontWeight.bold),
                          //           )),
                          //     ),
                          //   ),
                          // ),
                          (e.ostatus!.toLowerCase() == "received" ||
                              e.ostatus!.toLowerCase() == "ready")
                              ? Row(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    _dialogforCancel(context);
                                  },
                                  child: Container(
                                    width: 140.0,
                                    height: 35.0,
                                    margin: EdgeInsets.only(top: 5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(
                                            3.0),
                                        border: Border(
                                          top: BorderSide(
                                            width: 1.0,
                                            color: ColorCodes.blackColor,
                                            // color: Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                          bottom: BorderSide(
                                            width: 1.0,
                                            color: ColorCodes.blackColor,
                                            // color: Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                          left: BorderSide(
                                            width: 1.0,
                                            color: ColorCodes.blackColor,
                                            // color: Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                          right: BorderSide(
                                            width: 1.0,
                                            color: ColorCodes.blackColor,
                                            // color: Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                        )),
                                    child: Center(
                                        child: Text(
                                          S .of(context).cancel_order,
                                          /*'Re-order',*/
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ColorCodes.blackColor,
                                              // color: Theme.of(context)
                                              //     .primaryColor,
                                              fontWeight:
                                              FontWeight.bold),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          )
                              :
                          Features.isRateOrderModule?
                            (e.ostatus!.toLowerCase() == "delivered" ||
                              e.ostatus!.toLowerCase() == "completed")
                              ? Row(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    /*Navigator.of(context).pushNamed(RateOrderScreen.routeName,arguments: {
                                      "orderid":e.oid,
                                    });*/
                                    /*Navigation(context, name:Routename.Rateorder,navigatore: NavigatoreTyp.Push,
                                    parms: {
                                      "orderid":e.oid!,
                                    });*/
                                    showModalRateOrder(context, setState,e.oid!);
                                   // _dialogforRateOrder(context);
                                  },
                                  child: Container(
                                    width: 140.0,
                                    height: 35.0,
                                    margin:
                                    EdgeInsets.only(top: 5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(
                                            3.0),
                                        border: Border(
                                          top: BorderSide(
                                            width: 1.0,
                                            color:ColorCodes.badgecolor,
                                            // Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                          bottom: BorderSide(
                                            width: 1.0,
                                            color:ColorCodes.badgecolor,
                                            // Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                          left: BorderSide(
                                            width: 1.0,
                                            color:ColorCodes.badgecolor,
                                            // Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                          right: BorderSide(
                                            width: 1.0,
                                            color:ColorCodes.badgecolor,
                                            // Theme.of(context)
                                            //     .primaryColor,
                                          ),
                                        )),
                                    child: Center(
                                        child: Text(
                                          S .of(context).rate_order,
                                          /*'Re-order',*/
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ColorCodes.badgecolor,// color: Theme.of(context)
                                              //     .primaryColor,
                                              fontWeight:
                                              FontWeight.bold),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          )
                              : SizedBox.shrink()
                          :SizedBox.shrink(),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //             Divider(
                      //               color: Color(0xffA9A9A9),
                      //             ),
                      //             SizedBox(
                      //               height: 10,
                      //             ),
                      //             (widget.orderType.toLowerCase() == "pickup")
                      //                 ? Row(
                      //               children: [
                      //                 Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold,),),
                      //                 Spacer(),
                      //                 Text(widget.ostatus, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0, fontWeight: FontWeight.bold)),
                      //               ],
                      //             )
                      //             /* : Row(
                      //                         children: [
                      //                           MouseRegion(
                      //                             cursor: SystemMouseCursors.click,
                      //                              child: GestureDetector(
                      //                               onTap: () {
                      //                                 _dialogforReturn(context);
                      //                               },
                      //                               child: Container(
                      //                                 height: 35,
                      //                                 width: 125,
                      //                                 margin: EdgeInsets.only(top: 5.0),
                      //                                 decoration: BoxDecoration(
                      //                                     color: Colors.white,
                      //                                     borderRadius: BorderRadius.circular(3.0),
                      //                                     border: Border(
                      //                                       top: BorderSide(
                      //                                         width: 1.0,
                      //                                         color: Theme.of(context).primaryColor,
                      //                                       ),
                      //                                       bottom: BorderSide(
                      //                                         width: 1.0,
                      //                                         color: Theme.of(context).primaryColor,
                      //                                       ),
                      //                                       left: BorderSide(
                      //                                         width: 1.0,
                      //                                         color: Theme.of(context).primaryColor,
                      //                                       ),
                      //                                       right: BorderSide(
                      //                                         width: 1.0,
                      //                                         color: Theme.of(context).primaryColor,
                      //                                       ),
                      //                                     )),
                      //                                 child: Center(
                      //                                     child: Text(
                      //                                   'Return or Exchange',
                      //                                   *//*'Re-order',*//*
                      //                                   textAlign: TextAlign.center,
                      //                                   style: TextStyle(
                      //                                       color: Theme.of(context).primaryColor,
                      //                                       fontWeight: FontWeight.bold,
                      //                                       fontSize: 13.0),
                      //                                 )),
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         ],
                      //                       )*/
                      //                 :
                      //             _showCancelled
                      //                 ? Row(
                      //               children: [
                      //                 MouseRegion(
                      //                   cursor: SystemMouseCursors.click,
                      //                   child: GestureDetector(
                      //                     onTap: () {
                      //                       _dialogforCancel(context);
                      //                     },
                      //                     child: Container(
                      //                       width: 140.0,
                      //                       height: 35.0,
                      //                       margin: EdgeInsets.only(top: 5.0),
                      //                       decoration: BoxDecoration(
                      //                           color: Colors.white,
                      //                           borderRadius: BorderRadius.circular(3.0),
                      //                           border: Border(
                      //                             top: BorderSide(
                      //                               width: 1.0,
                      //                               color: Theme.of(context).primaryColor,
                      //                             ),
                      //                             bottom: BorderSide(
                      //                               width: 1.0,
                      //                               color: Theme.of(context).primaryColor,
                      //                             ),
                      //                             left: BorderSide(
                      //                               width: 1.0,
                      //                               color: Theme.of(context).primaryColor,
                      //                             ),
                      //                             right: BorderSide(
                      //                               width: 1.0,
                      //                               color: Theme.of(context).primaryColor,
                      //                             ),
                      //                           )),
                      //                       child: Center(
                      //                           child: Text(
                      //                             S .of(context).cancel,
                      //                             /*'Re-order',*/
                      //                             textAlign: TextAlign.center,
                      //                             style: TextStyle(
                      //                                 fontSize: 14,
                      //                                 color: Theme.of(context).primaryColor,
                      //                                 fontWeight: FontWeight.bold),
                      //                           )),
                      //                     ),
                      //                   ),
                      //                 ),
                      //
                      //
                      //               ],
                      //             )
                      //                 :
                      //             (widget.returnStatus==""||widget.returnStatus=="null")?
                      //             Row(
                      //               children: [
                      // //                  Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 16.0),),
                      //                 Text(
                      //                   S .of(context).order_status,
                      //                   style:
                      //                   TextStyle(fontSize: 14,
                      //                       color: Theme.of(context).primaryColor,
                      //                       fontWeight: FontWeight.bold),
                      //                 ),
                      //                 Spacer(),
                      //                 if (widget.ostatus == "CANCELLED")
                      //                   Text(widget.ostatus,
                      //                       style: TextStyle(
                      //                           color: ColorCodes.redColor,
                      //                           fontSize: 14,
                      //                           fontWeight: FontWeight.bold)),
                      //                 if (widget.ostatus != "CANCELLED")
                      //                   Text(widget.ostatus,
                      //                       style: TextStyle(
                      //                           color: ColorCodes.greenColor,
                      //                           fontSize: 14.0,
                      //                           fontWeight: FontWeight.bold)),
                      //               ],
                      //             ):
                      //             Row(
                      //               children: [
                      // //                  Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 16.0),),
                      //                 Text(
                      //                         S .of(context).return_status,
                      //                         style:
                      //                         TextStyle(fontSize: 14,
                      //                             color: Theme.of(context).primaryColor,
                      //                             fontWeight: FontWeight.bold),
                      //                       ),
                      //                       Spacer(),
                      //                 Text(widget.returnStatus.toUpperCase(),
                      //                     style: TextStyle(
                      //                         color: ColorCodes.redColor,
                      //                         fontSize: 14,
                      //                         fontWeight: FontWeight.bold)),
                      //               ],
                      //             ) ,
                      //             SizedBox(
                      //               height: 10.0,
                      //             ),
                    ],
                  ),
               );
              }).toList(),

            ],),
          ),
          if(widget.splitorder.length >1)
          SizedBox(height:10),
          if(widget.splitorder.length >1)
          Container(
            color: ColorCodes.whiteColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    S .of(context).total_order_amount + ": ",
                    style: TextStyle(
                        color: ColorCodes.greenColor,
                        //Theme.of(context).primaryColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    Features.iscurrencyformatalign?
                     totalamount.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit) + ' ' + IConstants.currencyFormat:
                    IConstants.currencyFormat + ' ' + totalamount.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                    style: TextStyle(
                        color: ColorCodes.greenColor,
                        //Theme.of(context).primaryColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),

                ],
              ),
            ),
          ),

          Divider(),
        ],
      ),
    )

  ],
);

//
//
//       ListView.builder(
//           physics: NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           itemCount: myorders.length,
//           itemBuilder: (ctx, i)
//           {
//
//           return
//             Container(
//             height:MediaQuery.of(context).size.height/3,
//               margin: EdgeInsets.all(12),
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           S .of(context).refund_orderid + ": ",
//                           style: TextStyle(
//                               color: ColorCodes.greenColor,//Theme.of(context).primaryColor,
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         Text(
//                           "#"+myorders.elementAt(i).oid,
//                           style: TextStyle(
//                               color: ColorCodes.greenColor,//Theme.of(context).primaryColor,
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         Spacer(),
//
//                         (widget.orderType.toLowerCase() == "pickup")
//                             ?
//                         Row(
//                           children: [
//                             Text(widget.ostatus.toLowerCase().toCapitalized(), style: TextStyle(color: ColorCodes.greyColor, fontSize: 14.0, fontWeight: FontWeight.bold)),
//
//                           ],
//                         )
//                             :
//                         (widget.returnStatus==""||widget.returnStatus=="null")?
//
// //
//                         (widget.ostatus == "CANCELLED")?
//                         Text(widget.ostatus.toLowerCase().toCapitalized(),
//                             style: TextStyle(
//                                 color: ColorCodes.redColor,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold))
//                             :
//                         Row(
//                           children: [
//                             Text(widget.ostatus.toLowerCase().toCapitalized(),
//                                 style: TextStyle(
//                                     color: ColorCodes.greyColor,
//                                     fontSize: 14.0,
//                                     fontWeight: FontWeight.bold)),
//                             SizedBox(width: 5,),
//                             if(widget.ostatus.toLowerCase() == "delivered"||widget.ostatus.toLowerCase() == "completed")Image.asset(Images.delivered, height: 25.0, width: 25.0),
//                             if(widget.ostatus.toLowerCase() == "received")Image.asset(Images.received, height: 25.0, width: 25.0),
//                             if(widget.ostatus.toLowerCase() == "dispatched"||widget.ostatus.toLowerCase() == "out for delivery")Image.asset(Images.outdelivery, height: 25.0, width: 25.0),
//                           ],
//                         )
//
//                             :
//
//                         Text(widget.returnStatus.toUpperCase(),
//                             style: TextStyle(
//                                 color: ColorCodes.redColor,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold)),
//
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(
//                       height: 10,
//                     ),
//
//                     Row(
//                       children: [
//                         Text(
//                           //"+ " +
//                           itemleftcount.toString()
//                               + " " + S .of(context).items,
//                           //   " more items",
//                           style: TextStyle(color: ColorCodes.greyColor),
//                         ),
//                         Spacer(),
//                         if(widget.orderType == "express")Row(
//                           children: [
//                             Text(widget.orderType.toCapitalized(),
//                               style: TextStyle(fontWeight: FontWeight.bold,color: ColorCodes.greyColor),
//                             ),
//                             SizedBox(width: 5,),
//                             Image.asset(Images.expressdelivery, height: 25.0, width: 25.0),
//                           ],
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text(IConstants.currencyFormat + ' ' + widget.itemPrice,
//                       style: TextStyle(fontWeight: FontWeight.bold,color: ColorCodes.greyColor),
//                     ),
//
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text( widget.paymenttype == "cod".toLowerCase()?S .of(context).cash_delivery:widget.paymenttype.toCapitalized(),
//                       style: TextStyle(fontWeight: FontWeight.bold,color: ColorCodes.greyColor),
//                     ),
//
//                     SizedBox(
//                       height: 10,
//                     ),
//                     DottedLine(dashColor: ColorCodes.lightGreyColor,),
//                     if (widget.ostatus == "CANCELLED")
//                       SizedBox(
//                         height: 10,
//                       ),
//                     if (widget.ostatus != "CANCELLED")
//                       SizedBox(
//                         height: 10,
//                       ),
//                     if (widget.ostatus != "CANCELLED")
//                       Row(
//                         children: [
//                           Text(
//                             S .of(context).scheduled_delivery,//widget.odelivery,
//                             style: TextStyle(
//                                 color: ColorCodes.greyColor,//Theme.of(context).primaryColor,
//                                 fontSize: 12.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             widget.odate,
//                             textAlign: TextAlign.right,
//                             style: TextStyle(
//                                 color: ColorCodes.darkGrey,//Theme.of(context).primaryColor,
//                                 fontSize: 12.0,
//                                 fontWeight: FontWeight.bold
//                             ),
//                           ),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Text(
//                             widget.odeltime,
//                             style: TextStyle(
//                                 color: ColorCodes.darkGrey,//Theme.of(context).primaryColor,
//                                 fontSize: 12.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           // (ResponsiveLayout.isSmallScreen(context)|| ResponsiveLayout.isMediumScreen(context))?
//                           // SizedBox(
//                           //   width: 45,
//                           // ):
//                           // SizedBox(
//                           //   width: MediaQuery.of(context).size.width - 400,
//                           // ),
//                           // Text(
//                           //   widget.odate,
//                           //   textAlign: TextAlign.right,
//                           //   style: TextStyle(
//                           //       color: Theme.of(context).primaryColor,
//                           //       fontSize: 12.0,
//                           //       fontWeight: FontWeight.bold
//                           //   ),
//                           // )
//                         ],
//                       ),
//                     if (widget.ostatus != "CANCELLED")
//                       SizedBox(
//                         height: 20,
//                       ),
//                     Row(
//                       children: [
//                         MouseRegion(
//                           cursor: SystemMouseCursors.click,
//                           child: GestureDetector(
//                             onTap: () {
//                               if (widget.odelivery == "DELIVERY ON") {
//                               } else {}
//                               /*Navigator.of(context).pushNamed(OrderhistoryScreen.routeName,
//                           arguments: {
//                             'orderid' : widget.oid,
//                             'fromScreen' : "myOrders",
//                           }
//                       );*/
//                               Navigator.of(context).pushNamed(
//                                   OrderhistoryScreen.routeName,
//                                   arguments: {
//                                     'orderid': widget.oid,
//                                     'orderStatus':widget.ostatus,
//                                     'fromScreen': "myOrders",
//                                   });
//                             },
//                             child: Container(
//                               height: 35,
//                               width: 125,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(3),
//                                 border:
//                                 Border.all(color: ColorCodes.greenColor),
//                                 // color: Theme.of(context).primaryColor
//                               ),
//                               child: Center(
//                                   child: Text(
//                                     S .of(context).view_details_order,
//                                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColorCodes.greenColor,//Theme.of(context).buttonColor,
//                                     ),
//                                   )),
//                             ),
//                           ),
//                         ),
//                         Spacer(),
//                         // MouseRegion(
//                         //  cursor: SystemMouseCursors.click,
//                         //      child: GestureDetector(
//                         //     onTap: () {
//                         //       Navigator.of(context).pushNamed(
//                         //         HelpScreen.routeName,
//                         //       );
//                         //     },
//                         //     child: Container(
//                         //       height: 35,
//                         //       width: 125,
//                         //       decoration: BoxDecoration(
//                         //           borderRadius: BorderRadius.circular(3),
//                         //           border:
//                         //               Border.all(color: Theme.of(context).primaryColor),
//                         //           color: Theme.of(context).buttonColor),
//                         //       child: Center(
//                         //           child: Text(
//                         //             S .of(context).help,
//                         //             style: TextStyle(fontSize: 13,
//                         //                 color: Theme.of(context).primaryColor,
//                         //                 fontWeight: FontWeight.bold),
//                         //           )),
//                         //     ),
//                         //   ),
//                         // ),
//                         _showCancelled
//                             ?
//                         Row(
//                           children: [
//                             MouseRegion(
//                               cursor: SystemMouseCursors.click,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   _dialogforCancel(context);
//                                 },
//                                 child: Container(
//                                   width: 140.0,
//                                   height: 35.0,
//                                   margin: EdgeInsets.only(top: 5.0),
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(3.0),
//                                       border: Border(
//                                         top: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         bottom: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         left: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         right: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                       )),
//                                   child: Center(
//                                       child: Text(
//                                         S .of(context).cancel_order,
//                                         /*'Re-order',*/
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color: Theme.of(context).primaryColor,
//                                             fontWeight: FontWeight.bold),
//                                       )),
//                                 ),
//                               ),
//                             ),
//
//
//                           ],
//                         )
//                             :_rateorder?
//                         Row(
//                           children: [
//                             MouseRegion(
//                               cursor: SystemMouseCursors.click,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   _dialogforCancel(context);
//                                 },
//                                 child: Container(
//                                   width: 140.0,
//                                   height: 35.0,
//                                   margin: EdgeInsets.only(top: 5.0),
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(3.0),
//                                       border: Border(
//                                         top: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         bottom: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         left: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                         right: BorderSide(
//                                           width: 1.0,
//                                           color: Theme.of(context).primaryColor,
//                                         ),
//                                       )),
//                                   child: Center(
//                                       child: Text(
//                                         S .of(context).rate_order,
//                                         /*'Re-order',*/
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color: Theme.of(context).primaryColor,
//                                             fontWeight: FontWeight.bold),
//                                       )),
//                                 ),
//                               ),
//                             ),
//
//
//                           ],
//                         ):
//                         SizedBox.shrink(),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
// //             Divider(
// //               color: Color(0xffA9A9A9),
// //             ),
// //             SizedBox(
// //               height: 10,
// //             ),
// //             (widget.orderType.toLowerCase() == "pickup")
// //                 ? Row(
// //               children: [
// //                 Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold,),),
// //                 Spacer(),
// //                 Text(widget.ostatus, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0, fontWeight: FontWeight.bold)),
// //               ],
// //             )
// //             /* : Row(
// //                         children: [
// //                           MouseRegion(
// //                             cursor: SystemMouseCursors.click,
// //                              child: GestureDetector(
// //                               onTap: () {
// //                                 _dialogforReturn(context);
// //                               },
// //                               child: Container(
// //                                 height: 35,
// //                                 width: 125,
// //                                 margin: EdgeInsets.only(top: 5.0),
// //                                 decoration: BoxDecoration(
// //                                     color: Colors.white,
// //                                     borderRadius: BorderRadius.circular(3.0),
// //                                     border: Border(
// //                                       top: BorderSide(
// //                                         width: 1.0,
// //                                         color: Theme.of(context).primaryColor,
// //                                       ),
// //                                       bottom: BorderSide(
// //                                         width: 1.0,
// //                                         color: Theme.of(context).primaryColor,
// //                                       ),
// //                                       left: BorderSide(
// //                                         width: 1.0,
// //                                         color: Theme.of(context).primaryColor,
// //                                       ),
// //                                       right: BorderSide(
// //                                         width: 1.0,
// //                                         color: Theme.of(context).primaryColor,
// //                                       ),
// //                                     )),
// //                                 child: Center(
// //                                     child: Text(
// //                                   'Return or Exchange',
// //                                   *//*'Re-order',*//*
// //                                   textAlign: TextAlign.center,
// //                                   style: TextStyle(
// //                                       color: Theme.of(context).primaryColor,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontSize: 13.0),
// //                                 )),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       )*/
// //                 :
// //             _showCancelled
// //                 ? Row(
// //               children: [
// //                 MouseRegion(
// //                   cursor: SystemMouseCursors.click,
// //                   child: GestureDetector(
// //                     onTap: () {
// //                       _dialogforCancel(context);
// //                     },
// //                     child: Container(
// //                       width: 140.0,
// //                       height: 35.0,
// //                       margin: EdgeInsets.only(top: 5.0),
// //                       decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(3.0),
// //                           border: Border(
// //                             top: BorderSide(
// //                               width: 1.0,
// //                               color: Theme.of(context).primaryColor,
// //                             ),
// //                             bottom: BorderSide(
// //                               width: 1.0,
// //                               color: Theme.of(context).primaryColor,
// //                             ),
// //                             left: BorderSide(
// //                               width: 1.0,
// //                               color: Theme.of(context).primaryColor,
// //                             ),
// //                             right: BorderSide(
// //                               width: 1.0,
// //                               color: Theme.of(context).primaryColor,
// //                             ),
// //                           )),
// //                       child: Center(
// //                           child: Text(
// //                             S .of(context).cancel,
// //                             /*'Re-order',*/
// //                             textAlign: TextAlign.center,
// //                             style: TextStyle(
// //                                 fontSize: 14,
// //                                 color: Theme.of(context).primaryColor,
// //                                 fontWeight: FontWeight.bold),
// //                           )),
// //                     ),
// //                   ),
// //                 ),
// //
// //
// //               ],
// //             )
// //                 :
// //             (widget.returnStatus==""||widget.returnStatus=="null")?
// //             Row(
// //               children: [
// // //                  Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 16.0),),
// //                 Text(
// //                   S .of(context).order_status,
// //                   style:
// //                   TextStyle(fontSize: 14,
// //                       color: Theme.of(context).primaryColor,
// //                       fontWeight: FontWeight.bold),
// //                 ),
// //                 Spacer(),
// //                 if (widget.ostatus == "CANCELLED")
// //                   Text(widget.ostatus,
// //                       style: TextStyle(
// //                           color: ColorCodes.redColor,
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.bold)),
// //                 if (widget.ostatus != "CANCELLED")
// //                   Text(widget.ostatus,
// //                       style: TextStyle(
// //                           color: ColorCodes.greenColor,
// //                           fontSize: 14.0,
// //                           fontWeight: FontWeight.bold)),
// //               ],
// //             ):
// //             Row(
// //               children: [
// // //                  Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 16.0),),
// //                 Text(
// //                         S .of(context).return_status,
// //                         style:
// //                         TextStyle(fontSize: 14,
// //                             color: Theme.of(context).primaryColor,
// //                             fontWeight: FontWeight.bold),
// //                       ),
// //                       Spacer(),
// //                 Text(widget.returnStatus.toUpperCase(),
// //                     style: TextStyle(
// //                         color: ColorCodes.redColor,
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.bold)),
// //               ],
// //             ) ,
// //             SizedBox(
// //               height: 10.0,
// //             ),
//                   ],
//                 ),
//               ),
//             );
//           });

  }
}
