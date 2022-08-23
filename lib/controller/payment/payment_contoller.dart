import 'dart:convert';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../assets/ColorCodes.dart';
import '../../constants/features.dart';
import '../../controller/payment/cashfree_web.dart';
import '../../generated/l10n.dart';
import '../../models/VxModels/VxStore.dart';
import '../../utils/coros_bypass.dart';
import '../../widgets/simmers/pymentoption_Simmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../models/payment/cashfree_model.dart';
import '../../rought_genrator.dart';
import '../../screens/paytm_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../screens/subscription_confirm_screen.dart';
import '../../constants/IConstants.dart';
import '../../models/payment/paytm_tocken_modle.dart';
import '../../screens/orderconfirmation_screen.dart';
import '../../screens/payment_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../constants/api.dart';
import '../../utils/prefUtils.dart';
// import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

import 'paytm_web.dart';

class Payment with Navigations {
  String? mid,_orderId,_amount,_usenam;
  bool _restrictAppInvoke = true;
  var _context;
  var _routeArgs;
  String? _prev;
  bool? _isweb;
  Razorpay? _razorpay;
  String? _name;
  GroceStore store = VxState.store;
  String? get name => _name;

  /// Paytm Token Generate
  Future<PaytmTocken?> _getPaytmOrderTocken() async {
    // var staging;
    String url;
    if(IConstants.isPaymentTesting ==true){
      url = Api.paytmteckenapi +'orderid=$_orderId&m_key=plcc0aPkvbE4n@f@&mid=xexqsh45840354978392&t_amt=$_amount&currency=INR&isstaging=1&custId=$_usenam';
    }else{
      url = Api.paytmteckenapi +'orderid=$_orderId&m_key=${IConstants.gateway_secret}&mid=${IConstants.gatewayId}&t_amt=$_amount&currency=INR&isstaging=0&custId=$_usenam';
    }
    try {
      // _sellingitems.clear();
      final response = await http
          .get(
        kIsWeb?  "https://groce-bay.herokuapp.com/"+url:""+url,
        /* body: {
          "rows": "2",
          "branch": PrefUtils.prefs!.getString('branch'),
          "user": user,
          // await keyword is used to wait to this operation is complete.
        }*/
      );
      // SellingItemModel result;
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      print("resp ${responseJson}");
      if(responseJson.toString() != "[]") {
        Map<String, dynamic> resdata;
        resdata = responseJson as Map<String, dynamic>;
        // resdata["featuredCategoryBColor"] = list[_random.nextInt(list.length)];
        return  PaytmTocken.fromJson(resdata);
      }else{
        return null;
      }
    } catch (error) {
      throw error;
    }
  }
  /// Paytm Token Generate
  Future<Object> _getCashFreeOrderTocken() async {
    // var staging;
    String url;
    if(Vx.isWeb){
      if (IConstants.isPaymentTesting == true) {
        url = 'https://sandbox.cashfree.com/pg/orders';
      }else{
        url = 'https://api.cashfree.com/pg/orders';
      }
    }
    else{
      if (IConstants.isPaymentTesting == true) {
        url = 'https://test.cashfree.com/api/v2/cftoken/order/';
      } else {
        url = 'https://api.cashfree.com/api/v2/cftoken/order/';
      }
    }
    // try {
      debugPrint("gateway...."+IConstants.gatewayId.toString()+"  "+IConstants.gateway_secret.toString());
      var headers = Vx.isWeb?{
        'x-client-id': IConstants.gatewayId,
        'x-client-secret': IConstants.gateway_secret,
        'Content-Type': 'application/json',
        'x-api-version': '2022-01-01'
      }:{
        'x-client-id': '${IConstants.gatewayId}',
        'x-client-secret': '${IConstants.gateway_secret}',
        'Content-Type': 'application/json',

      };
      var request = Vx.isWeb ? http.Request('POST', Uri.parse(COROsBypass().getbypassUrl(url)))
      : http.Request('POST', Uri.parse(url/*COROsBypass().getbypassUrl('https://api.cashfree.com/api/v2/cftoken/order/')*/));
      request.body = Vx.isWeb?json.encode({
        "order_id": "$_orderId",
        //"orderId":"$_orderId",
        "order_amount": "$_amount",
      //  "orderAmount": "$_amount",
        "order_currency": "INR",
     // "orderCurrency": "INR",
        "customer_details": {
          "customer_id": PrefUtils.prefs!.getString("apikey"),
          "customer_name": store.userData.username,
          "customer_email": "techsupport@cashfree.com",
          "customer_phone": store.userData.mobileNumber
        },}):json.encode({
        "orderId": "$_orderId",
        "orderAmount": "$_amount",
        "orderCurrency": "INR"
      });
      request.headers.addAll(headers);
      debugPrint("gateway...."+IConstants.gatewayId.toString()+"  "+IConstants.gateway_secret.toString());
      debugPrint("request..."+request.toString() +"  "+request.body.toString());
      http.StreamedResponse response = await request.send();
      debugPrint("response..."+response.statusCode.toString());
      if (response.statusCode == 200) {
        final stream =await response.stream.bytesToString();
        debugPrint(stream);
        return  Vx.isWeb?CashFreeWebTocken.fromJson(json.decode(stream)):
        CashFreeTocken.fromJson(json.decode(stream));

      }
      else {
        debugPrint("response..."+await response.stream.bytesToString());
        final stream =await response.stream.bytesToString();
        return  Vx.isWeb?CashFreeWebTocken.fromJson(json.decode(stream)):
        CashFreeTocken.fromJson(json.decode(stream));
      }


    // } catch (error) {
    //   throw error;
    // }
  }

  Future<void> startPaytmTransaction(context, isweb,{required orderId, required username, amount = "1.00",required routeArgs, String? prev}) async {
    this._orderId =orderId;
    this._amount =amount;
    this._amount =amount;
    this._usenam = username;
    this._context = context;
    this._routeArgs = routeArgs;
    this._prev = prev;
    this._isweb = isweb;
    // if (PrefUtils.prefs!.getString('FirstName') != null) {
    //   if (PrefUtils.prefs!.getString('LastName') != null) {
    //     this._name =  PrefUtils.prefs!.getString('FirstName') + " " + PrefUtils.prefs!.getString('LastName');
    //   } else {
    //     this._name =  PrefUtils.prefs!.getString('FirstName');
    //   }
    // } else {
    //   this._name = "";
    // }
    this._name = store.userData.username;
print("in payment controller, paymentgateway"+IConstants.paymentGateway);
    switch(IConstants.paymentGateway){
    //  case "paytm": _paytmTransaction(); break;
      case "razorpay": _razorpayTransaction();break;
      case "cashfree": _cashFreeTransaction();break;
      case "webview": _webViewTransaction();break;
    }
  }


  /// Transaction Through PayTm
/*  _paytmTransaction() async {
    await _getPaytmOrderTocken().then((value) {
      if(value!=null)
        if (value.body.resultInfo.resultStatus == "S") {
          try {
            if(_isweb) WebPaytmSdk.startTransaction(value.body.txnToken, _orderId, _amount,IConstants.isPaymentTesting
                ,IConstants.gatewayId,(value)=>_onresponse(value)).onError((error, stackTrace) => _catchError(error));
            else
              AllInOneSdk.startTransaction(IConstants.isPaymentTesting
                  ? "xexqsh45840354978392" : IConstants.gatewayId, _orderId, _amount, value.body.txnToken, IConstants.isPaymentTesting
                  ?"https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$_orderId":"https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$_orderId", IConstants.isPaymentTesting
                  , _restrictAppInvoke).then((value) => _onresponse(value)).onError((error, stackTrace) => _catchError(error));
          } catch (err) {
            return err.toString();
          }
        } else {
          return value.body.resultInfo.resultMsg;
        }
    });

  }*/

  /// Transaction Through RazorPay
  _razorpayTransaction() {

    _razorpay = Razorpay();
    Navigator.of(_context).pop();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response){
      if (_prev == "SubscribeScreen")
        _subscriptionstatus("paid", response.paymentId.toString(), "Payment done through Razorpay");
      else
        _paymentstatus("paid", response.paymentId.toString(), "Payment done through Razorpay");
    });
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) async {
      if (_prev == "SubscribeScreen")
        _subscriptionstatus("cancelled", "", response.message!);
      else {
        if(PrefUtils.prefs!.containsKey("orderId")) {
          debugPrint("back......2");
          final orderId = PrefUtils.prefs!.getString("orderId");
          //await  paymentStatus(orderId);
          await _cancelOrderback();
        }
        //_paymentstatus("cancelled", "", response.message);
      }
    });
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET,(ExternalWalletResponse response){
      Fluttertoast.showToast(
          msg: "EXTERNAL_WALLET: " + response.walletName!, timeInSecForIosWeb: 4);
      if (_prev == "SubscribeScreen")
        _subscriptionstatus("paid", response.walletName!, "Payment done through Razorpay");
      else _paymentstatus("paid", response.walletName!, "Payment done through Razorpay");
    });
    var options = {
      'key': IConstants.gatewayId,
      'amount': double.parse(_amount!) * 100 ,
      'name': name,
      //'description': 'Fine T-Shirt',
      'prefill': {
        'contact': store.userData.mobileNumber,
        'email': store.userData.email,
      }
    };
    try {
      _razorpay!.open(options);
      // Navigator.of(context).pop();
    } catch (e) {
    }
  }
  /// Transaction Through CashFree
  _cashFreeTransaction() async{

    String stage;
    await _getCashFreeOrderTocken().then((value) {
      Navigator.of(_context).pop();
      if(IConstants.isPaymentTesting) stage = "TEST"; else stage = "PROD";
      if(Vx.isWeb){
        value = value as CashFreeWebTocken;
        CashFreeWeb.doPayment(value.orderToken,OnSucsess: (value){
          debugPrint("on sucsess....");
          // _paymentstatus("paid", value.transaction!.transactionId!.toString(), value.order!.status!);
          if (_prev == "SubscribeScreen")
            _subscriptionstatus(
                "paid",value.transaction!.transactionId!.toString(), value.order!.status!);
          else
            _paymentstatus(
                "paid",value.transaction!.transactionId!.toString(), value.order!.status!);
        },OnFailure: (value){
            debugPrint("on failure...."+PrefUtils.prefs!.containsKey("orderId").toString());
           if (PrefUtils.prefs!.containsKey("orderId")) {
              debugPrint("back......2");
            _cancelOrderback();
            }
        },);

      }else {
        value = value as CashFreeTocken;
        if (value.status == "OK") {
          debugPrint("inputparam..." +
              {
                "orderId": _orderId,
                "orderAmount": _amount,
                "customerName": name,
                "orderNote": "Payment through Cash Free",
                "orderCurrency": "INR",
                "appId": IConstants.gatewayId,
                "customerPhone": store.userData.mobileNumber,
                "customerEmail": store.userData.email != ""
                    ? store.userData.email
                    : "${IConstants.primaryEmail}",
                "stage": stage,
                "tokenData": value.cftoken,
                "notifyUrl": "https://test.gocashfree.com/notify"
              }.toString());
          Map<String, dynamic> inputParams = {
            "orderId": _orderId,
            "orderAmount": _amount,
            "customerName": name,
            "orderNote": "Payment through Cash Free",
            "orderCurrency": "INR",
            "appId": IConstants.gatewayId,
            "customerPhone": store.userData.mobileNumber,
            "customerEmail": store.userData.email != ""
                ? store.userData.email
                : "${IConstants.primaryEmail}",
            "stage": stage,
            "tokenData": value.cftoken,
            "notifyUrl": "https://test.gocashfree.com/notify"
          };
         CashfreePGSDK.doPayment(inputParams).then((value) async {
                  debugPrint("txt status...." + value.toString());

                  if (value!["txStatus"] == "SUCCESS") {
                      _paymentstatus(
                          "paid", value['referenceId'], value['txMsg']);
                      if (_prev == "SubscribeScreen")
                        _subscriptionstatus(
                            "paid", value['referenceId'], value['txMsg']);
                      else
                        _paymentstatus(
                            "paid", value['referenceId'], value['txMsg']);


                  } else if (value["txStatus"] == "FAILED") {
                    debugPrint("txt status....1");
                    // _paymentstatus("cancelled", value['referenceId'], value['txMsg']);
                    if (_prev == "SubscribeScreen")
                      _subscriptionstatus(
                          "failed", value['referenceId'], value['txMsg']);
                    else
                      _paymentstatus(
                          "failed", value['referenceId'], value['txMsg']);
                  } else {
                    debugPrint("txt status....2");
                    if (_prev == "SubscribeScreen")
                      _subscriptionstatus(
                          "cancelled", value['orderId'], value['txStatus']);
                    else {
                      if (PrefUtils.prefs!.containsKey("orderId")) {
                        debugPrint("back......2");
                        final orderId = PrefUtils.prefs!.getString("orderId");
                        //await  paymentStatus(orderId);
                        await _cancelOrderback();
                      }
                      //_paymentstatus("cancelled", value['orderId'], value['txStatus']);
                    }
                  }
                });
        } else {}
      }
    });
  }
  /// Transaction Through WebView
  _webViewTransaction(){
    _routeArgs["orderId"]=_orderId;
    _routeArgs["amount"]=_amount;
    Navigator.of(_context).pushReplacementNamed(PaytmScreen.routeName, arguments: _routeArgs);
  }

  Future<void> _paymentstatus(String status, String tansactionid, String note) async { // imp feature in adding async is the it automatically wrap into Future.
    try{
      debugPrint("update...."+{ // await keyword is used to wait to this operation is complete.
        "status": status,
        "transction": (tansactionid),
        "refid": _orderId,
        "mobile": store.userData.mobileNumber,
        "name": name,
        "note": note,
      }.toString());
      if(_prev == "WalletScreen"){
        print("inside walletscreen condition");
       /* debugPrint("addmoneytowallet body "+{ // await keyword is used to wait to this operation is complete.
          "userID": store.userData.id,
          "credits": _amount,
          "branch": store.userData.branch,
          "name": store.userData.username,
          "subscription_id":_orderId,
          //"transaction_id":(tansactionid)
        }.toString());*/
        final response = await http.post(Api.addMoneyToWallet, body: { // await keyword is used to wait to this operation is complete.
          "userID": store.userData.id,
          "credits": _amount,
          "branch": store.userData.branch,
          "name": store.userData.username,
          "subscription_id":_orderId,
          "type": !Features.isSubscription ? "0" : "5",
          "mode": !Features.isSubscription ? "wallet" : "subscription"

        //"transaction_id":(tansactionid)
        });

        final responseJson = json.decode(response.body);
        debugPrint("update resp addmoneywallet...."+responseJson.toString());
        if(responseJson['status'].toString() == "200") {
          Fluttertoast.showToast(
              msg: "Amount Added Successfully",//"Sign in failed!",
              fontSize: 10,
              backgroundColor: ColorCodes.blackColor,
              textColor: ColorCodes.whiteColor);
        }
        else{
          debugPrint("addmoney api else condition");
          Fluttertoast.showToast(
              msg: "Amount Not Added",//"Sign in failed!",
              fontSize: 10,
              backgroundColor: ColorCodes.blackColor,
              textColor: ColorCodes.whiteColor);
        }
      }
      else{
        final response = await http.post(Api.updatePaymentStatusSplit, body: { // await keyword is used to wait to this operation is complete.
          "status": status,
          "transction": (tansactionid),
          "refid": _orderId,
          "mobile": store.userData.mobileNumber,
          "name": name,
          "note": note,
        });

        final responseJson = json.decode(response.body);
        debugPrint("update resp...."+responseJson.toString());
        if(responseJson['status'].toString() == "200") {
          if(status == "paid") {

            PrefUtils.prefs!.remove("orderId");
            /*     Navigator.of(_context).pushReplacementNamed(
              OrderconfirmationScreen.routeName,
              arguments: {
                'orderstatus' : "success",
                'orderid': _orderId

              }
          );*/
            Navigation(_context, name: Routename.OrderConfirmation, navigatore: NavigatoreTyp.Push,
                parms: {'orderstatus' : "success",
                  'orderid': _orderId.toString()});
          }
          else if(status == "cancelled"){

            final routeArgs = ModalRoute.of(_context)!.settings.arguments as Map<String, String>;
            String minimumOrderAmountNoraml=routeArgs["minimumOrderAmountNoraml"]!;
            String deliveryChargeNormal = routeArgs["deliveryChargeNormal"]!;
            String minimumOrderAmountPrime = routeArgs["deliveryChargePrime"]!;
            String deliveryChargePrime = routeArgs["deliveryChargePrime"]!;
            String minimumOrderAmountExpress = routeArgs["minimumOrderAmountExpress"]!;
            String deliveryChargeExpress = routeArgs["deliveryChargeExpress"]!;
            String deliveryType =routeArgs["deliveryType"]!;
            String note =routeArgs["note"]!;
            String prev =routeArgs['prev']!;
            String addressId = routeArgs["addressId"]!;
            String deliveryCharge = routeArgs["deliveryCharge"]!;
            String deliveryDurationExpress = routeArgs["deliveryDurationExpress"]!;
            debugPrint('cancelled.....');
            if(PrefUtils.prefs!.containsKey("orderId")) {
              debugPrint("back......2");
              final orderId = PrefUtils.prefs!.getString("orderId");
              //await  paymentStatus(orderId);
              await _cancelOrderback();
            }


            // Navigator.of(_context).pop();
            // Navigator.of(_context).pushReplacementNamed(
            //     PaymentScreen.routeName,
            //     arguments: {
            //       'minimumOrderAmountNoraml': minimumOrderAmountNoraml,
            //       'deliveryChargeNormal': deliveryChargeNormal,
            //       'minimumOrderAmountPrime': minimumOrderAmountPrime,
            //       'deliveryChargePrime': deliveryChargePrime,
            //       'minimumOrderAmountExpress': minimumOrderAmountExpress,
            //       'deliveryChargeExpress':deliveryChargeExpress ,
            //       'deliveryType': deliveryType,
            //       'note': note,
            //       'addressId': addressId,
            //       'deliveryCharge': deliveryCharge,
            //       'deliveryDurationExpress' : deliveryDurationExpress,
            //     }
            // );

          }
          else {
            String orderid;
            if( PrefUtils.prefs!.containsKey("subscriptionorderId")){
              orderid = PrefUtils.prefs!.getString("subscriptionorderId").toString();
            }else{
              orderid = _orderId.toString();
            }
            /*       Navigator.of(_context).pushReplacementNamed(
              OrderconfirmationScreen.routeName,
              arguments: {
                'orderstatus': "failure",
                'orderId':  PrefUtils.prefs!.containsKey("subscriptionorderId")?PrefUtils.prefs!.getString("subscriptionorderId"):_orderId
              }
          );*/
            Navigation(_context, name: Routename.OrderConfirmation, navigatore: NavigatoreTyp.Push,
                parms: {'orderstatus' : "failure",
                  'orderid': orderid});
          }
        }
        else {
        }
      }


    } catch (error) {
      throw error;
    }
  }

  Future<void> paymentStatus(String orderId) async { // imp feature in adding async is the it automatically wrap into Future.
    debugPrint("payment status..."+orderId);
    var url = Api.getOrderStatus + orderId;
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": PrefUtils.prefs!.getString('branch'),
          }
      );
      final responseJson = json.decode(response.body);
      debugPrint("resp...."+responseJson.toString());
      if(responseJson['status'].toString() == "yes") {
        PrefUtils.prefs!.remove("orderId");
      } else {
        //await _cancelOrder();
        await _cancelOrderback();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> _cancelOrderback() async { // imp feature in adding async is the it automatically wrap into Future.
    try {
      debugPrint("cancel back..."+{ // await keyword is used to wait to this operation is complete.
        "id": PrefUtils.prefs!.getString('orderId'),
        "note": "Payment cancelled by user",
        "branch": PrefUtils.prefs!.getString('branch'),
      }.toString());
      final response = await http.post(
          Api.cancelOrderBack,
          body: { // await keyword is used to wait to this operation is complete.
            "id": PrefUtils.prefs!.getString('orderId'),
            "note": "Payment cancelled by user",
            "branch": PrefUtils.prefs!.getString('branch'),
          }
      );
      final responseJson = json.decode(response.body);
      debugPrint("response...."+responseJson.toString());
      if(responseJson['status'].toString() == "200"){
        debugPrint("response....1");

        debugPrint("response....2");
        if(Vx.isWeb){
          Navigation(_context, name: Routename.OrderConfirmation, navigatore: NavigatoreTyp.Push,
              parms: {'orderstatus' : "failure",
                'orderid':PrefUtils.prefs!.getString("orderId").toString()});
        }else{
          PrefUtils.prefs!.remove("orderId");
        }
        /* await Provider.of<BrandItemsList>(context,listen: false).userDetails().then((_) {
          setState(() {

          });
        });*/
      }

    } catch (error) {
      Fluttertoast.showToast(msg: S.of(_context).something_went_wrong,//"Something went wrong!!!",
        fontSize: MediaQuery.of(_context).textScaleFactor *13,);
      throw error;
    }
  }

  Future<void> _subscriptionstatus(String status, String tansactionid, String note) async { // imp feature in adding async is the it automatically wrap into Future.
    debugPrint("subscription status.....");
    try {
      final response = await http.post(
          Api.updateSubscriptionPayment,
          body: { // await keyword is used to wait to this operation is complete.
            "user_id": PrefUtils.prefs!.getString('apikey').toString(),
            "payment_status": status,
            "transaction_id": tansactionid,
            "order": _orderId,
            "amount": _amount,
            "payment_note": note,
          }
      );
      print("update subscription....."+{
        "user_id": PrefUtils.prefs!.getString('apikey').toString(),
        "payment_status": status,
        "transaction_id": tansactionid,
        "order": _orderId,
        "amount": _amount,
        "payment_note": note,
      }.toString());
      final responseJson = json.decode(response.body);
      print("update sub response......"+responseJson.toString());
      if(responseJson['status'].toString() == "200") {
        print("response status 200....");
        if(status == "paid") {

         // PrefUtils.prefs!.remove("subscriptionorderId");
          debugPrint("subscription success.....");
         /* Navigator.of(_context).pushReplacementNamed(
              SubscriptionConfirmScreen.routeName,
              arguments: {
                'orderstatus' : "success",
                'sorderId': PrefUtils.prefs!.getString("subscriptionorderId")
              }
          );*/
          Navigation(_context, name: Routename.SubscriptionConfirm, navigatore: NavigatoreTyp.Push,
              parms: {
                'orderstatus' : "success",
                'sorderId': PrefUtils.prefs!.getString("subscriptionorderId").toString()
              });
        }
        else {
          debugPrint("subscription failure id.....");
         /* Navigator.of(_context).pushReplacementNamed(
              SubscriptionConfirmScreen.routeName,
              arguments: {
                'orderstatus': "failure",
                'sorderId': PrefUtils.prefs!.getString("subscriptionorderId")
              }
          );*/
          Navigation(_context, name: Routename.SubscriptionConfirm, navigatore: NavigatoreTyp.Push,
              parms: {
                'orderstatus' : "failure",
                'sorderId': PrefUtils.prefs!.getString("subscriptionorderId").toString()
              });
        }/*else{
          final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;

          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(
              PaymenSubscriptionScreen.routeName,
              arguments: {
                "addressid":routeArgs['addressid'].toString(),
                "useraddtype": routeArgs['useraddtype'].toString(),
                "startDate":routeArgs['startDate'].toString(),
                "endDate": routeArgs['endDate'].toString(),
                "itemCount":routeArgs['itemCount'].toString(),
                "deliveries": routeArgs['deliveries'].toString(),
                "total": routeArgs['total'].toString(),
                //"weeklist":(typeselected == "Daily")? SelectedDaily.toString():SelectedWeek.toString(),
                "schedule": routeArgs['schedule'].toString(),
                "itemid": routeArgs['itemid'].toString(),
                "itemimg": routeArgs['itemimg'].toString(),
                "itemname":routeArgs['itemname'].toString(),
                "varprice":routeArgs['varprice'].toString(),
                "varname":routeArgs['varname'].toString(),
                "address":routeArgs['address'].toString(),
                "paymentMode": routeArgs['paymentMode'].toString(),
                "cronTime": routeArgs['cronTime'].toString(),
                "name": routeArgs['name'].toString(),
                "varid": routeArgs['varid'].toString(),
                "varmrp":routeArgs['varmrp'].toString(),
              }
          );

        }*/

      }
      else {
      }

    } catch (error) {
      throw error;
    }
  }

  /// On Response For Paytm Transaction
  _onresponse(value) async {
    if(value["RESPCODE"]=="01") {
      if (_prev == "SubscribeScreen") {
        debugPrint("subscription paid.....");
        _subscriptionstatus("paid", value['TXNID'], value['RESPMSG']);
      } else {
        _paymentstatus("paid", value['TXNID'], value['RESPMSG']);
      }
    }
    else {
      if (_prev == "SubscribeScreen") {
        debugPrint("subscription failed.....");
        _subscriptionstatus("failed", value['TXNID'], value['RESPMSG']);
      } else {
        if(PrefUtils.prefs!.containsKey("orderId")) {
          debugPrint("back......2");
          final orderId = PrefUtils.prefs!.getString("orderId");
          //await  paymentStatus(orderId);
          await _cancelOrderback();
        }
        //_paymentstatus("cancelled", value['TXNID'], value['RESPMSG']);
      }
    }
    return  value.toString();
  }
  /// On Error For Paytm Transaction
  _catchError(onError) {
    if (onError is PlatformException) {
      if(_prev == "PaymentScreen")
        /* Navigator.of(context)
                    .pushReplacementNamed(PaymentScreen.routeName, arguments: {
                  'minimumOrderAmountNoraml': routeArgs['minimumOrderAmountNoraml'].toString(),
                  'deliveryChargeNormal': routeArgs['deliveryChargeNormal'].toString(),
                  'minimumOrderAmountPrime': routeArgs['minimumOrderAmountPrime'].toString(),
                  'deliveryChargePrime': routeArgs['deliveryChargePrime'].toString(),
                  'minimumOrderAmountExpress': routeArgs['minimumOrderAmountExpress'].toString(),
                  'deliveryChargeExpress': routeArgs['deliveryChargeExpress'].toString(),
                  'deliveryType': routeArgs['deliveryType'].toString(),
                  'note': routeArgs['note'].toString(),
                  'deliveryCharge': routeArgs['deliveryCharge'].toString(),
                  'deliveryDurationExpress' : routeArgs['deliveryDurationExpress'].toString(),
                });*/
      /*  Navigator.of(_context).pushReplacementNamed(
            OrderconfirmationScreen.routeName,
            arguments: {
              'orderstatus': "failure",
              'orderId': PrefUtils.prefs!.getString("orderId")
            }
        );*/
        Navigation(_context, name: Routename.OrderConfirmation, navigatore: NavigatoreTyp.Push,
            parms: {'orderstatus' : "failure",
              'orderid':PrefUtils.prefs!.getString("orderId").toString()});
      else if(_prev == "SubscribeScreen"){
        /*Navigator.of(context)
                      .pushReplacementNamed(PaymenSubscriptionScreen.routeName, arguments: {
                    "addressid":routeArgs['addressid'].toString(),
                    "useraddtype": routeArgs['useraddtype'].toString(),
                    "startDate":routeArgs['startDate'].toString(),
                    "endDate": routeArgs['endDate'].toString(),
                    "itemCount":routeArgs['itemCount'].toString(),
                    "deliveries": routeArgs['deliveries'].toString(),
                    "total":routeArgs['total'].toString(),
                    "schedule": routeArgs['schedule'].toString(),
                    "itemid": routeArgs['itemid'].toString(),
                    "itemimg": routeArgs['itemimg'].toString(),
                    "itemname":routeArgs['itemname'].toString(),
                    "varprice":routeArgs['varprice'].toString(),
                    "varname":routeArgs['varname'].toString(),
                    "address":routeArgs['address'].toString(),
                    "paymentMode":routeArgs['paymentMode'].toString(),
                    "cronTime": routeArgs['cronTime'].toString(),
                    "name": routeArgs['name'].toString(),
                    "varid": routeArgs['varid'].toString(),
                    "varmrp":routeArgs['varmrp'].toString(),

                  });*/
        debugPrint("subscription failure.....");
       /* Navigator.of(_context).pushReplacementNamed(
            SubscriptionConfirmScreen.routeName,
            arguments: {
              'orderstatus': "failure",
              'sorderId': PrefUtils.prefs!.getString("subscriptionorderId")
            }
        );*/
        Navigation(_context, name: Routename.SubscriptionConfirm, navigatore: NavigatoreTyp.Push,
            parms: {
              'orderstatus' : "failure",
              'sorderId': PrefUtils.prefs!.getString("subscriptionorderId").toString()
            });
      }
      return  onError.message.toString() + " \n  " + onError.details.toString();
    } else {
      return  onError.toString();
    }
  }
  dispose(){
    if(_razorpay!=null)
      _razorpay!.clear();
  }
}

final payment = Payment();