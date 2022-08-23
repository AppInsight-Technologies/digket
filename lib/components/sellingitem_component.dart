import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/newmodle/search_data.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../widgets/productWidget/item_badge.dart';
import '../../widgets/productWidget/item_variation.dart';
import 'package:sign_in_apple/apple_id_user.dart';
import 'package:sign_in_apple/sign_in_apple.dart';
import '../controller/mutations/cart_mutation.dart';
import '../helper/custome_calculation.dart';
import '../models/VxModels/VxStore.dart';
import '../models/newmodle/cartModle.dart';
import '../models/newmodle/product_data.dart';
import '../rought_genrator.dart';
import 'package:velocity_x/velocity_x.dart';
import '../constants/api.dart';
import '../generated/l10n.dart';
import '../constants/IConstants.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/features.dart';
import '../utils/prefUtils.dart';
import '../providers/branditems.dart';
import '../assets/images.dart';
import '../assets/ColorCodes.dart';
import 'package:http/http.dart' as http;

import '../widgets/custome_stepper.dart';
import 'login_web.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
class SellingItemsv2 extends StatefulWidget {
  final String fromScreen;
  final String? seeallpress;
  final String? notid; //for not brand product screen
  final ItemData? itemdata;
  final StoreSearchData? storedsearchdata;


  Map<String, String>? returnparm;

  SellingItemsv2({Key? key,required this.fromScreen,this.seeallpress,
    this.itemdata,this.notid,this. returnparm,this.storedsearchdata}) : super(key: key);

/*  SellingItemsv2(this.fromScreen,this._seeallpress,
     this.itemdata,this._notid,{this. returnparm});*/

  @override
  _SellingItemsv2State createState() => _SellingItemsv2State();
}

class _SellingItemsv2State extends State<SellingItemsv2> with Navigations{
  List<CartItem> productBox=[];
  int itemindex = 0;
  var _varlength = false;
  int varlength = 0;
  var itemvarData;
  var dialogdisplay = false;
  var _checkmembership = false;
  var colorRight = 0xff3d8d3c;
  var colorLeft = 0xff8abb50;
  var _checkmargin = true;
  Color? varcolor;
  var multiimage;
  String itemimg = "";

  String? varid;
  String? varname;
  String? unit;
  String? varmrp;
  String? varprice;
  String? varmemberprice;
  String? varminitem;
  String? varmaxitem;
  int varLoyalty = 0;
  int varQty = 0;
  String? varstock;
  String? varimageurl;
  bool discountDisplay = false;
  bool? memberpriceDisplay;
  var margins;

  List variationdisplaydata = [];
  List variddata = [];
  List varnamedata = [];
  List unitdata =[];
  List varmrpdata = [];
  List varpricedata = [];
  List varmemberpricedata = [];
  List varminitemdata = [];
  List varmaxitemdata = [];
  List varLoyaltydata = [];
  List varQtyData = [];
  List varstockdata = [];
  List vardiscountdata = [];
  List discountDisplaydata = [];
  List memberpriceDisplaydata = [];

  List checkBoxdata = [];
  var containercolor = [];
  var textcolor = [];
  var iconcolor = [];
  bool _isWeb = false;
  bool _isAddToCart = false;
  bool _isNotify = false;

  bool checkskip = false;

  // String countryName = "${CountryPickerUtils.getCountryByPhoneCode(IConstants.countryCode.split('+')[1]).name}";
  String photourl = "";
  String name = "";
  String phone = "";
  String apple = "";
  String email = "";
  String mobile = "";
  String tokenid = "";
  bool _isAvailable = false;
  Timer? _timer;
  int _timeRemaining = 30;
  StreamController<int>? _events;
  TextEditingController controller = TextEditingController();
  bool _showOtp = false;
  final TextEditingController firstnamecontroller = new TextEditingController();
  final TextEditingController lastnamecontroller = new TextEditingController();
  final _lnameFocusNode = FocusNode();
  String fn = "";
  String ln = "";
  String ea = "";
  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  var addressitemsData;
  var deliveryslotData;
  var delChargeData;
  var timeslotsData;
  var timeslotsindex = "0";
  var otpvalue = "";

  String? otp1, otp2, otp3, otp4;
  final _form = GlobalKey<FormState>();
  var day, date, time = "10 AM - 1 PM";
  var addtype;
  var address;
  IconData? addressicon;
  DateTime? pickedDate;
  GroceStore store = VxState.store;
  int _groupValue = 0;
  int _count = 1;

  @override
  void initState() {
    _events = new StreamController<int>.broadcast();
    _events!.add(30);
    pickedDate = DateTime.now();
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
    productBox = /*Hive.box<Product>(productBoxName)*/(VxState.store as GroceStore).CartItemList;
    //print("from screennn..."+widget.fromScreen.toString()+"variation length..."+widget.itemdata!.priceVariation!.length.toString());
    Future.delayed(Duration.zero, () async {
      //await Provider.of<BrandItemsList>(context, listen: false).getLoyalty();
      //prefs = await SharedPreferences.getInstance();
      setState(() {
        if (store.userData.membership! == "1") {
          setState(() {
            _checkmembership = true;
          });
        } else {
          setState(() {
            _checkmembership = false;
          });
          for (int i = 0; i < productBox.length; i++) {
            if (productBox[i].mode == "1") {
              setState(() {
                _checkmembership = true;
              });
            }
          }
        }
        dialogdisplay = true;
      });

      if(Features.btobModule){
        if (productBox.where((element) => element.itemId == widget.itemdata!.id)
            .count() >= 1) {
          debugPrint("count...1");
          for (int i = 0; i < productBox.length; i++) {
            debugPrint("count...1 if inside");
            for(int j = 0 ; j < widget.itemdata!.priceVariation!.length; j++)
            {
              print("j value...."+j.toString()+"...."+widget.itemdata!.priceVariation!.length.toString()+"///"+i.toString());
              print("proudct box id if..." + widget.itemdata!.priceVariation![j].minItem.toString()+ widget.itemdata!.priceVariation![j].maxItem.toString() + "hve varid..." + productBox.where((element) => element.itemId == widget.itemdata!.id).first.quantity
                  .toString());
              if ((int.parse(productBox.where((element) => element.itemId == widget.itemdata!.id).first.quantity.toString()) >=  int.parse(widget.itemdata!.priceVariation![j].minItem.toString())) && int.parse(productBox.where((element) => element.itemId == widget.itemdata!.id).first.quantity.toString()) <=  int.parse(widget.itemdata!.priceVariation![j].maxItem.toString())) {
                print("proudct box id if..." + widget.itemdata!.priceVariation![j].quantity.toString() + "hve varid..." + productBox.where((element) => element.itemId == widget.itemdata!.id).first.quantity
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
      // if (widget.fromScreen == "home_screen") {
      //   multiimage = Provider.of<SellingItemsList>(context, listen: false).findByfeaturedimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // }else if (widget.fromScreen == "singleproduct_screen") {
      //   multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIditemsnewimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // } else if (widget.fromScreen == "searchitem_screen") {
      //   sbloc.searchItemsBloc();
      //   multiimage = Provider.of<ItemsList>(context, listen: false).findBysearchimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // } else if (widget.fromScreen == "sellingitem_screen") {
      //   multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIdallimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // } else if (widget.fromScreen == "item_screen") {
      //   multiimage = Provider.of<ItemsList>(context, listen: false).findByIditemimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // } else if (widget.fromScreen == "shoppinglistitem_screen") {
      //   multiimage = Provider.of<BrandItemsList>(context, listen: false).findByshoppingimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // } else if (widget.fromScreen == "brands_screen") {
      //   multiimage = Provider.of<BrandItemsList>(context, listen: false).findBybrandimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // }else if(widget.fromScreen == "not_product_screen"){
      //   multiimage = Provider.of<NotificationItemsList>(context, listen: false,).findBynotproductimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // }else if(widget.fromScreen == "notavailableProduct"){
      //   multiimage = Provider.of<SellingItemsList>(context, listen: false,).findBySwapimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // } else if (widget.fromScreen == "Forget") {
      //   multiimage = Provider.of<SellingItemsList>(context, listen: false).findByForgotimage(varid);
      //   _displayimg = multiimage[0].imageUrl;
      // }


    });
    setState(() {
      if (PrefUtils.prefs!.containsKey("LoginStatus")) {
        if (PrefUtils.prefs!.getString('LoginStatus') == "true") {
          PrefUtils.prefs!.setString('skip', "no");
          checkskip = false;
        } else {
          PrefUtils.prefs!.setString('skip', "yes");
          checkskip = true;
        }
      } else {
        PrefUtils.prefs!.setString('skip', "yes");
        checkskip = true;
      }
    });
    super.initState();
  }

  Future<void> _getprimarylocation() async {
    try {
      final response = await http.post(Api.getProfile, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": PrefUtils.prefs!.getString('apiKey'),
        "branch" : PrefUtils.prefs!.getString("branch")
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final dataJson =
      json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);
      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>)); //store each category values in data list
      for (int i = 0; i < data.length; i++) {
        PrefUtils.prefs!.setString("deliverylocation", data[i]['area']);

        if (PrefUtils.prefs!.containsKey("deliverylocation")) {
          Navigator.of(context).pop();
          if (PrefUtils.prefs!.containsKey("fromcart")) {
            if (PrefUtils.prefs!.getString("fromcart") == "cart_screen") {
              PrefUtils.prefs!.remove("fromcart");
           /*   Navigator.of(context).pushNamedAndRemoveUntil(
                  CartScreen.routeName,
                  ModalRoute.withName(HomeScreen.routeName),arguments: {
                "afterlogin": ""
              });*/
              Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,parms: {"afterlogin":"Ok"});
            } else {
              /*Navigator.of(context).popUntil(ModalRoute.withName(
                HomeScreen.routeName,
              ));*/
              Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);
            }
          } else {
            /*Navigator.of(context).pushNamed(
              HomeScreen.routeName,
            );*/
            Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);
          }
        } else {
          Navigator.of(context).pop();
         // Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
          Navigation(context,name: Routename.MapScreen, navigatore: NavigatoreTyp.Push);
        }
      }
      //Navigator.of(context).pop();
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  void initiateFacebookLogin() async {
    //web.......
    final facebookSignIn = FacebookLoginWeb();
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    //app........
    /*final facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
    final result = await facebookLogin.logIn(['email']);*/
    switch (result.status) {
      case FacebookLoginStatus.error:
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: S .of(context).sign_in_failed,//"Sign in failed!",
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor: ColorCodes.blackColor,
            textColor: ColorCodes.whiteColor);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: S .of(context).sign_in_cancelledbyuser,//"Sign in cancelled by user!",
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor: ColorCodes.blackColor,
            textColor: ColorCodes.whiteColor);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${token}');
        final profile = json.decode(graphResponse.body);

        PrefUtils.prefs!.setString("FBAccessToken", token);

        PrefUtils.prefs!.setString('FirstName', profile['first_name'].toString());
        PrefUtils.prefs!.setString('LastName', profile['last_name'].toString());
        PrefUtils.prefs!.setString('Email', profile['email'].toString());

        final pictureencode = json.encode(profile['picture']);
        final picturedecode = json.decode(pictureencode);

        final dataencode = json.encode(picturedecode['data']);
        final datadecode = json.decode(dataencode);

        PrefUtils.prefs!.setString("photoUrl", datadecode['url'].toString());

        PrefUtils.prefs!.setString('prevscreen', "signinfacebook");
        checkusertype("Facebooksigin");
        //onLoginStatusChanged(true);
        break;
    }
  }
  Future<void> checkusertype(String prev) async {
    try {
      var response;
      if (prev == "signInApple") {
        response = await http.post(Api.emailLogin, body: {
          "email": PrefUtils.prefs!.getString('Email'),
          "tokenId": PrefUtils.prefs!.getString('tokenid'),
          "apple": PrefUtils.prefs!.getString('apple'),
        });
      } else {
        response = await http.post(Api.emailLogin, body: {
          "email": PrefUtils.prefs!.getString('Email'),
          "tokenId": PrefUtils.prefs!.getString('tokenid'),
        });
      }

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['type'].toString() == "old") {
        if (responseJson['data'] != "null") {
          final data = responseJson['data'] as Map<String, dynamic>;

          if (responseJson['status'].toString() == "true") {
            PrefUtils.prefs!.setString('apiKey', data['apiKey'].toString());
            PrefUtils.prefs!.setString('userID', data['userID'].toString());
            PrefUtils.prefs!.setString('membership', data['membership'].toString());
            PrefUtils.prefs!.setString("mobile", data['mobile'].toString());
            PrefUtils.prefs!.setString("latitude", data['latitude'].toString());
            PrefUtils.prefs!.setString("longitude", data['longitude'].toString());
          } else if (responseJson['status'].toString() == "false") {}
        }

        PrefUtils.prefs!.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
          /*if (PrefUtils.prefs!.getString('FirstName') != null) {
            if (PrefUtils.prefs!.getString('LastName') != null) {
              name = PrefUtils.prefs!.getString('FirstName').toString() +
                  " " +
                  PrefUtils.prefs!.getString('LastName').toString();
            } else {
              name = PrefUtils.prefs!.getString('FirstName').toString();
            }
          } else {
            name = "";
          }*/
          name = store.userData.username!;
          //name = PrefUtils.prefs!.getString('FirstName') + " " + PrefUtils.prefs!.getString('LastName');
          if (PrefUtils.prefs!.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = PrefUtils.prefs!.getString('Email').toString();
          }
          mobile = PrefUtils.prefs!.getString('Mobilenum')!;
          tokenid = PrefUtils.prefs!.getString('tokenid')!;

          if (PrefUtils.prefs!.getString('mobile') != null) {
            phone = PrefUtils.prefs!.getString('mobile')!;
          } else {
            phone = "";
          }
          if (PrefUtils.prefs!.getString('photoUrl') != null) {
            photourl = PrefUtils.prefs!.getString('photoUrl')!;
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      } else {
        Navigator.of(context).pop();
        /* Navigator.of(context).pushReplacementNamed(
          LoginScreen.routeName,
        );*/
        (_isWeb && !ResponsiveLayout.isSmallScreen(context))?signupUser():null;
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  Future<void> facebooklogin() async {
    PrefUtils.prefs!.setString('skip', "no");
    PrefUtils.prefs!.setString('applesignin', "no");
    initiateFacebookLogin();
  }

  Future<void> appleLogIn() async {
    PrefUtils.prefs!.setString('applesignin', "yes");
    _dialogforProcessing();
    PrefUtils.prefs!.setString('skip', "no");
    if (await SignInApple.canUseAppleSigin()) {
      /// AppleIdUser(name: ,mail: ,userIdentifier: ,authorizationCode: ,identifyToken: )
      SignInApple.handleAppleSignInCallBack(onCompleteWithSignIn: (AppleIdUser? appleidentifier) async {
        // print("flutter receiveCode: \n");
        // print(authorizationCode);
        // print("flutter receiveToken \n");
        // print(identifyToken);
        // setState(() {
        //   _name = name;
        //   _mail = mail;
        //   _userIdentify = userIdentifier;
        //   _authorizationCode = authorizationCode;
        // });
        try {
          final response = await http.post(Api.emailLogin, body: {
            // await keyword is used to wait to this operation is complete.
            "email": appleidentifier!.mail,
            "tokenId": PrefUtils.prefs!.getString('tokenid'),
          });
          final responseJson = json.decode(response.body);
          if (responseJson['type'].toString() == "old") {
            if (responseJson['data'] != "null") {
              final data = responseJson['data'] as Map<String, dynamic>;

              if (responseJson['status'].toString() == "true") {
                PrefUtils.prefs!.setString('apiKey', data['apiKey'].toString());
                // PrefUtils.prefs!.setString('userID', data['userID'].toString());
                PrefUtils.prefs!.setString('membership', data['membership'].toString());
                PrefUtils.prefs!.setString("mobile", data['mobile'].toString());
                PrefUtils.prefs!.setString("latitude", data['latitude'].toString());
                PrefUtils.prefs!.setString("longitude", data['longitude'].toString());

                PrefUtils.prefs!.setString('name', data['name'].toString());
                PrefUtils.prefs!.setString('FirstName', data['name'].toString());
                PrefUtils.prefs!.setString('FirstName', data['username'].toString());
                PrefUtils.prefs!.setString('LastName', "");
                PrefUtils.prefs!.setString('Email', data['email'].toString());
                PrefUtils.prefs!.setString("photoUrl", "");
                PrefUtils.prefs!.setString('apple', data['apple'].toString());
              } else if (responseJson['status'].toString() == "false") {}
            }
            PrefUtils.prefs!.setString('LoginStatus', "true");
            _getprimarylocation();
          } else {
            PrefUtils.prefs!.setString('apple', appleidentifier.mail!);
            PrefUtils.prefs!.setString(
                'FirstName', appleidentifier.givenName!);
            PrefUtils.prefs!.setString(
                'LastName',appleidentifier.familyName!);
            PrefUtils.prefs!.setString("photoUrl", "");

            if (appleidentifier.mail.toString() == "null") {
              PrefUtils.prefs!.setString('prevscreen', "signInAppleNoEmail");
              Navigator.of(context).pop();
              /*Navigator.of(context).pushReplacementNamed(
                  LoginScreen.routeName,
                  arguments: {
                    "prev": "signupSelectionScreen"
                  }
              );*/
              Navigation(context, name:Routename.Login,navigatore: NavigatoreTyp.Push,
              qparms: {
                "prev": "signupSelectionScreen"
              });
            } else {
              PrefUtils.prefs!.setString('Email', appleidentifier.mail!);
              PrefUtils.prefs!.setString('prevscreen', "signInApple");
              checkusertype("signInApple");
            }
          }
        } catch (error) {
          Navigator.of(context).pop();
          throw error;
        }
      }, onCompleteWithError: (AppleSignInErrorCode code) async {
        var errorMsg = "unknown";
        switch (code) {
          case AppleSignInErrorCode.canceled:
            errorMsg = S .of(context).sign_in_cancelledbyuser;
            break;
          case AppleSignInErrorCode.failed:
            errorMsg =  S .of(context).sign_in_failed;
            break;
          case AppleSignInErrorCode.invalidResponse:
            errorMsg =S .of(context).apple_signin_not_available_forthis_device;
            break;
          case AppleSignInErrorCode.notHandled:
            errorMsg = S .of(context).apple_signin_not_available_forthis_device;
            break;
          case AppleSignInErrorCode.unknown:
            errorMsg = S .of(context).apple_signin_not_available_forthis_device;
            break;
        }
        Navigator.of(context).pop();
        if(Platform.isIOS)FocusManager.instance.primaryFocus!.unfocus();
        Fluttertoast.showToast(
            msg:errorMsg,//"Sign in failed!",
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor: Colors.black87,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white);
        print(errorMsg);
      });
      SignInApple.clickAppleSignIn();
      // final AuthorizationResult result = await AppleSignIn.performRequests([
      //   AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      // ]);
      // switch (result.status) {
      //   case AuthorizationStatus.authorized:
      //     try {
      //       final response = await http.post(Api.emailLogin, body: {
      //         // await keyword is used to wait to this operation is complete.
      //         "email": result.credential.user.toString(),
      //         "tokenId": PrefUtils.prefs!.getString('tokenid'),
      //       });
      //       final responseJson = json.decode(response.body);
      //       if (responseJson['type'].toString() == "old") {
      //         if (responseJson['data'] != "null") {
      //           final data = responseJson['data'] as Map<String, dynamic>;
      //
      //           if (responseJson['status'].toString() == "true") {
      //             PrefUtils.prefs!.setString('apiKey', data['apiKey'].toString());
      //             // PrefUtils.prefs!.setString('userID', data['userID'].toString());
      //             PrefUtils.prefs!.setString('membership', data['membership'].toString());
      //             PrefUtils.prefs!.setString("mobile", data['mobile'].toString());
      //             PrefUtils.prefs!.setString("latitude", data['latitude'].toString());
      //             PrefUtils.prefs!.setString("longitude", data['longitude'].toString());
      //
      //             PrefUtils.prefs!.setString('name', data['name'].toString());
      //             PrefUtils.prefs!.setString('FirstName', data['name'].toString());
      //             PrefUtils.prefs!.setString('FirstName', data['username'].toString());
      //             PrefUtils.prefs!.setString('LastName', "");
      //             PrefUtils.prefs!.setString('Email', data['email'].toString());
      //             PrefUtils.prefs!.setString("photoUrl", "");
      //             PrefUtils.prefs!.setString('apple', data['apple'].toString());
      //           } else if (responseJson['status'].toString() == "false") {}
      //         }
      //         PrefUtils.prefs!.setString('LoginStatus', "true");
      //         _getprimarylocation();
      //       } else {
      //         PrefUtils.prefs!.setString('apple', result.credential.user.toString());
      //         PrefUtils.prefs!.setString(
      //             'FirstName', result.credential.fullName.givenName);
      //         PrefUtils.prefs!.setString(
      //             'LastName', result.credential.fullName.familyName);
      //         PrefUtils.prefs!.setString("photoUrl", "");
      //
      //         if (result.credential.email.toString() == "null") {
      //           PrefUtils.prefs!.setString('prevscreen', "signInAppleNoEmail");
      //           Navigator.of(context).pop();
      //           Navigator.of(context).pushReplacementNamed(
      //             LoginScreen.routeName,
      //               arguments: {
      //                 "prev": "signupSelectionScreen"
      //               }
      //           );
      //         } else {
      //           PrefUtils.prefs!.setString('Email', result.credential.email);
      //           PrefUtils.prefs!.setString('prevscreen', "signInApple");
      //           checkusertype("signInApple");
      //         }
      //       }
      //     } catch (error) {
      //       Navigator.of(context).pop();
      //       throw error;
      //     }
      //
      //     break;
      //   case AuthorizationStatus.error:
      //     Navigator.of(context).pop();
      //     if(Platform.isIOS)FocusManager.instance.primaryFocus!.unfocus();
      //     Fluttertoast.showToast(
      //         msg: S .of(context).sign_in_failed,//"Sign in failed!",
      //         fontSize: MediaQuery.of(context).textScaleFactor *13,
      //         backgroundColor: Colors.black87,
      //         gravity: ToastGravity.BOTTOM,
      //         textColor: Colors.white);
      //     break;
      //   case AuthorizationStatus.cancelled:
      //     Navigator.of(context).pop();
      //     if(Platform.isIOS)FocusManager.instance.primaryFocus!.unfocus();
      //     Fluttertoast.showToast(
      //         msg: S .of(context).sign_in_cancelledbyuser,//"Sign in cancelled by user!",
      //         fontSize: MediaQuery.of(context).textScaleFactor *13,
      //         backgroundColor: Colors.black87,
      //         gravity: ToastGravity.BOTTOM,
      //         textColor: Colors.white);
      //     break;
      // }
    } else {
      Navigator.of(context).pop();
      if(Platform.isIOS)FocusManager.instance.primaryFocus!.unfocus();
      Fluttertoast.showToast(
          msg: S .of(context).apple_signin_not_available_forthis_device,//"Apple SignIn is not available for your device!",
          fontSize: MediaQuery.of(context).textScaleFactor *13,
          backgroundColor: Colors.black87,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white);
    }
  }

  Future<void> otpCall() async {
    try {
      final response = await http.post(Api.resendOtpCall, body: {
        "resOtp": PrefUtils.prefs!.getString('Otp'),
        "mobileNumber": PrefUtils.prefs!.getString('Mobilenum'),
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> Otpin30sec() async {
    try {
      final response = await http.post(Api.resendOtp30, body: {
        "resOtp": PrefUtils.prefs!.getString('Otp'),
        "mobileNumber": PrefUtils.prefs!.getString('Mobilenum'),
      });
    } catch (error) {
      throw error;
    }
  }



  Future<void> _handleSignIn() async {
    PrefUtils.prefs!.setString('skip', "no");
    PrefUtils.prefs!.setString('applesignin', "no");
    try {
      final response = await _googleSignIn.signIn();
      response!.email.toString();
      response.displayName.toString();
      response.photoUrl.toString();

      PrefUtils.prefs!.setString('FirstName', response.displayName.toString());
      PrefUtils.prefs!.setString('LastName', "");
      PrefUtils.prefs!.setString('Email', response.email.toString());
      PrefUtils.prefs!.setString("photoUrl", response.photoUrl.toString());

      PrefUtils.prefs!.setString('prevscreen', "signingoogle");
      checkusertype("Googlesigin");
    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: S .of(context).sign_in_failed,//"Sign in failed!",
          fontSize: MediaQuery.of(context).textScaleFactor *13,
          backgroundColor: Colors.black87,
          textColor: Colors.white);
    }
  }
  _customToast() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              S .of(context).please_enter_valid_otp,//"Please enter a valid otp!!!"
            ),
          );
        });
  }

  addMobilenumToSF(String value) async {
    PrefUtils.prefs!.setString('Mobilenum', value);
  }

  _verifyOtp() async {
    if (controller.text == PrefUtils.prefs!.getString('Otp')) {
      if (PrefUtils.prefs!.getString('type') == "old") {
        PrefUtils.prefs!.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
         /* if (PrefUtils.prefs!.getString('FirstName') != null) {
            if (PrefUtils.prefs!.getString('LastName') != null) {
              name = PrefUtils.prefs!.getString('FirstName') +
                  " " +
                  PrefUtils.prefs!.getString('LastName');
            } else {
              name = PrefUtils.prefs!.getString('FirstName');
            }
          } else {
            name = "";
          }*/
          name = store.userData.username!;
          //name = PrefUtils.prefs!.getString('FirstName') + " " + PrefUtils.prefs!.getString('LastName');
          if (PrefUtils.prefs!.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = PrefUtils.prefs!.getString('Email')!;
          }
          mobile = PrefUtils.prefs!.getString('Mobilenum')!;
          tokenid = PrefUtils.prefs!.getString('tokenid')!;

          if (PrefUtils.prefs!.getString('mobile') != null) {
            phone = PrefUtils.prefs!.getString('mobile')!;
          } else {
            phone = "";
          }
          if (PrefUtils.prefs!.getString('photoUrl') != null) {
            photourl = PrefUtils.prefs!.getString('photoUrl')!;
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      } else {
        if (PrefUtils.prefs!.getString('prevscreen') == 'signingoogle' ||
            PrefUtils.prefs!.getString('prevscreen') == 'signupselectionscreen' ||
            PrefUtils.prefs!.getString('prevscreen') == 'signInAppleNoEmail' ||
            PrefUtils.prefs!.getString('prevscreen') == 'signInApple' ||
            PrefUtils.prefs!.getString('prevscreen') == 'signinfacebook') {
          return signupUser();
        } else {
          PrefUtils.prefs!.setString('prevscreen', "otpconfirmscreen");
          await Future.delayed(Duration(seconds: 2));
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          _dialogforAddInfo();
        }
      }
    } else {
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
      _customToast();
    }
  }

  _saveAddInfoForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState!.save();
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //checkemail();
    _dialogforProcessing();
    if(PrefUtils.prefs!.getString('Email') == "" || PrefUtils.prefs!.getString('Email') == "null") {
      return SignupUser();
    } else {
      checkemail();
    }
  }
  Future<void> checkemail() async {
    // imp feature in adding async is the it automatically wrap into Future.
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(Api.emailCheck, body: {
        // await keyword is used to wait to this operation is complete.
        "email": PrefUtils.prefs!.getString('Email'),
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          (_isWeb)?Navigator.of(context).pop():null;
           Fluttertoast.showToast(
              msg: S .of(context).email_exist,//"Email id already exists",
              fontSize: MediaQuery.of(context).textScaleFactor *13,
              backgroundColor: Colors.black87,
              textColor: Colors.white);
        } else if (responseJson['type'].toString() == "new") {
          return SignupUser();
        }
      } else {
         Fluttertoast.showToast(msg: S .of(context).something_went_wrong,//"Something went wrong!!!"
        );
      }
    } catch (error) {
      throw error;
    }
  }
  Future<void> signupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    String channel = "";
    try {
      if (Platform.isIOS) {
        channel = "IOS";
      } else {
        channel = "Android";
      }
    } catch (e) {
      channel = "Web";
    }

    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(Api.register, body: {
        // await keyword is used to wait to this operation is complete.
        "username": name,
        "email": email,
        "mobileNumber": mobile,
        "path": apple,
        "tokenId": tokenid,
        "branch": PrefUtils.prefs!.getString('branch') /*'999'*/,
        "signature":
        PrefUtils.prefs!.containsKey("signature") ? PrefUtils.prefs!.getString('signature') : "",
        "device": channel.toString(),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;

      if (responseJson['status'].toString() == "true") {
        PrefUtils.prefs!.setString('apiKey', data['apiKey'].toString());
        PrefUtils.prefs!.setString('userID', responseJson['userId'].toString());
        PrefUtils.prefs!.setString('membership', responseJson['membership'].toString());

        PrefUtils.prefs!.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
          /*if (PrefUtils.prefs!.getString('FirstName') != null) {
            if (PrefUtils.prefs!.getString('LastName') != null) {
              name = PrefUtils.prefs!.getString('FirstName').toString() +
                  " " +
                  PrefUtils.prefs!.getString('LastName').toString();
            } else {
              name = PrefUtils.prefs!.getString('FirstName').toString();
            }
          } else {
            name = "";
          }*/
          name = store.userData.username!;
          //name = PrefUtils.prefs!.getString('FirstName') + " " + PrefUtils.prefs!.getString('LastName');
          if (PrefUtils.prefs!.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = PrefUtils.prefs!.getString('Email').toString();
          }
          mobile = PrefUtils.prefs!.getString('Mobilenum')!;
          tokenid = PrefUtils.prefs!.getString('tokenid')!;

          if (PrefUtils.prefs!.getString('mobile') != null) {
            phone = PrefUtils.prefs!.getString('mobile')!;
          } else {
            phone = "";
          }
          if (PrefUtils.prefs!.getString('photoUrl') != null) {
            photourl = PrefUtils.prefs!.getString('photoUrl')!;
          } else {
            photourl = "";
          }
        });
        Navigation(context,name: Routename.MapScreen, navigatore: NavigatoreTyp.Push);
        /* Navigator.of(context).pushNamedAndRemoveUntil(
            MapScreen.routeName, ModalRoute.withName('/'));*/
      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      throw error;
    }
  }

  Future<void> SignupUser() async {
    String channel = "";
    try {
      if (Platform.isIOS) {
        channel = "IOS";
      } else {
        channel = "Android";
      }
    } catch (e) {
      channel = "Web";
    }

    try {
      String apple = "";
      if (PrefUtils.prefs!.getString('applesignin') == "yes") {
        apple = PrefUtils.prefs!.getString('apple')!;
      } else {
        apple = "";
      }

      String name =
          PrefUtils.prefs!.getString('FirstName').toString() + " " + PrefUtils.prefs!.getString('LastName').toString();

      final response = await http.post(Api.register, body: {
        "username": name,
        "email": PrefUtils.prefs!.getString('Email'),
        "mobileNumber": PrefUtils.prefs!.containsKey("Mobilenum") ? PrefUtils.prefs!.getString('Mobilenum') : "",
        "path": apple,
        "tokenId": PrefUtils.prefs!.getString('tokenid'),
        "branch": PrefUtils.prefs!.getString('branch'),
        "signature":
        PrefUtils.prefs!.containsKey("signature") ? PrefUtils.prefs!.getString('signature') : "",
        "device": channel.toString(),
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final data = responseJson['data'] as Map<String, dynamic>;
        PrefUtils.prefs!.setString('apiKey', data['apiKey'].toString());
        PrefUtils.prefs!.setString('userID', responseJson['userId'].toString());
        PrefUtils.prefs!.setString('membership', responseJson['membership'].toString());
        PrefUtils.prefs!.setString("mobile", PrefUtils.prefs!.getString('Mobilenum')!);

        PrefUtils.prefs!.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
         /* if (PrefUtils.prefs!.getString('FirstName') != null) {
            if (PrefUtils.prefs!.getString('LastName') != null) {
              name = PrefUtils.prefs!.getString('FirstName').toString() +
                  " " +
                  PrefUtils.prefs!.getString('LastName').toString();
            } else {
              name = PrefUtils.prefs!.getString('FirstName').toString();
            }
          } else {
            name = "";
          }*/
          name = store.userData.username!;
          //name = PrefUtils.prefs!.getString('FirstName') + " " + PrefUtils.prefs!.getString('LastName');
          if (PrefUtils.prefs!.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = PrefUtils.prefs!.getString('Email').toString();
          }
          mobile = PrefUtils.prefs!.getString('Mobilenum')!;
          tokenid = PrefUtils.prefs!.getString('tokenid')!;

          if (PrefUtils.prefs!.getString('mobile') != null) {
            phone = PrefUtils.prefs!.getString('mobile')!;
          } else {
            phone = "";
          }
          if (PrefUtils.prefs!.getString('photoUrl') != null) {
            photourl = PrefUtils.prefs!.getString('photoUrl')!;
          } else {
            photourl = "";
          }
        });
        Navigator.of(context).pop();
        PrefUtils.prefs!.setString("formapscreen", "");
        // Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
        Navigation(context,name: Routename.MapScreen, navigatore: NavigatoreTyp.Push);

        // return Navigator.pushNamedAndRemoveUntil(
        //     context, HomeScreen.routeName, (route) => false);

        /*Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );*/

      } else if (responseJson['status'].toString() == "false") {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: responseJson['data'].toString(),
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }
    } catch (error) {
      setState(() {});
      throw error;
    }
  }

  addFirstnameToSF(String value) async {
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    PrefUtils.prefs!.setString('FirstName', value);
  }

  addLastnameToSF(String value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    PrefUtils.prefs!.setString('LastName', value);
  }

  addEmailToSF(String value) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    PrefUtils.prefs!.setString('Email', value);
  }

  _dialogforAddInfo() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.width / 3.3,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 2.7,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S .of(context).add_info,//"Add your info",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _form,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  S .of(context).what_should_we_call_you,//'* What should we call you?',
                                  style: TextStyle(
                                      fontSize: 17, color: ColorCodes.lightBlack
                                  //Color(0xFF1D1D1D)
                                  ),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: firstnamecontroller,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
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
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      setState(() {
                                        fn = "  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fn = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value!);
                                  },
                                ),
                                Text(
                                  fn,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  S .of(context).tell_us_your_email,//'Tell us your e-mail',
                                  style: TextStyle(
                                      fontSize: 17, color: ColorCodes.lightBlack
                                 // Color(0xFF1D1D1D)
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  style: new TextStyle(
                                      decorationColor:
                                      Theme.of(context).primaryColor),
                                  decoration: InputDecoration(
                                    hintText: 'xyz@gmail.com',
                                    fillColor: ColorCodes.primaryColor,
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
                                      borderSide: BorderSide(
                                          color: ColorCodes.primaryColor, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    if (value == "")
                                      emailValid = true;
                                    else
                                      emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value!);

                                    if (!emailValid) {
                                      setState(() {
                                        ea =
                                        ' Please enter a valid email address';
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      ea = "";
                                    });
                                    return null; //it means user entered a valid input
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value!);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      ea,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Text(
                                  S .of(context).we_will_email,//' We\'ll email you as a reservation confirmation.',
                                  style: TextStyle(
                                      fontSize: 15.2, color: ColorCodes.emailColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //  Spacer(),
                      ],
                    ),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _saveAddInfoForm();
                          _dialogforProcessing();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              )),
                          height: 60.0,
                          child: Center(
                            child: Text(
                              S .of(context).continue_button,//"CONTINUE",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ),
                ]),
              ),
            );
          });
        });
  }

  _dialogforOtp() async {
    return alertOtp(context);
  }
  _dialogforSignIn() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.width / 2.2,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 3.0,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          S .of(context).signin,//"Sign in",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52,
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: ColorCodes.borderColor),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                Images.countryImg,
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                      S .of(context).country_region,//"Country/Region",
                                      style: TextStyle(
                                        color: ColorCodes.darkgrey,
                                      )),
                                  Text(CountryPickerUtils.getCountryByPhoneCode(IConstants.countryCode.split('+')[1]).name + " (" + IConstants.countryCode + ")",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52.0,
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: ColorCodes.borderColor),
                          ),
                          child: Row(
                            children: <Widget>[
                              Image.asset(Images.phoneImg),
                              SizedBox(
                                width: 14,
                              ),
                              Container(
                                  width:
                                  MediaQuery.of(context).size.width / 4.0,
                                  child: Form(
                                    key: _form,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.left,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12)
                                      ],
                                      cursorColor:
                                      Theme.of(context).primaryColor,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: new InputDecoration.collapsed(
                                          hintText: 'Enter Your Mobile Number',
                                          hintStyle: TextStyle(
                                            color: Colors.black12,
                                          )),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a Mobile number.';
                                        }
                                        return null; //it means user entered a valid input
                                      },
                                      onSaved: (value) {
                                        addMobilenumToSF(value!);
                                      },
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 8.0, bottom: 36.0),
                          child: Text(
                            S .of(context).we_will_call_or_text,//"We'll call or text you to confirm your number. Standard message data rates apply.",
                            style: TextStyle(
                                fontSize: 13, color: ColorCodes.lightblack1),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              PrefUtils.prefs!.setString('skip', "no");
                              PrefUtils.prefs!.setString('prevscreen', "mobilenumber");
                              // PrefUtils.prefs!.setString('Mobilenum', value);
                              _saveFormLogin();
                              _dialogforProcess();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 32,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  width: 1.0,
                                  color: ColorCodes.greenColor,
                                ),
                              ),
                              child: Text(
                                S .of(context).login_using_otp,//"LOGIN USING OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                    color: ColorCodes.black),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 12.0, bottom: 32.0),
                          child: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                  text: S .of(context).agreed_terms,//'By continuing you agree to the '
                                ),
                                new TextSpan(
                                    text: S .of(context).terms_of_service,//' terms of service',
                                    style:
                                    new TextStyle(color: ColorCodes.darkthemeColor),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {"title": "Terms of Use"/*, "body" :IConstants.restaurantTerms*/});
                                      }),
                                new TextSpan(text: S .of(context).and,//' and'
                                ),
                                new TextSpan(
                                    text: S .of(context).privacy_policy,//' Privacy Policy',
                                    style:
                                    new TextStyle(color: ColorCodes.darkthemeColor),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,
                                            parms: {"title": "Privacy"/*, "body" :PrefUtils.prefs!.getString("privacy").toString()*/});
                                      }),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: ColorCodes.greyColor,
                                ),
                              ),
                              Container(
                                //padding: EdgeInsets.all(4.0),
                                width: 23.0,
                                height: 23.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: ColorCodes.greyColor,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: Text(
                                      S .of(context).or,//"OR",
                                      style: TextStyle(
                                          fontSize: 10.0, color: ColorCodes.greyColord),
                                    )),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: ColorCodes.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 28),
                              child: GestureDetector(
                                onTap: () {
                                  _dialogforProcessing();
                                  Navigator.of(context).pop();
                                  _handleSignIn();
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(4.0),
                                  elevation: 2,
                                  shadowColor: Colors.grey,
                                  child: Container(

                                    padding: EdgeInsets.only(
                                        left: 10.0, right: 5.0,top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),),
                                    child:
                                    Padding(
                                      padding: const EdgeInsets.only(right:23.0,left:23,),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            SvgPicture.asset(Images.googleImg, width: 25, height: 25,),
                                            //Image.asset(Images.googleImg,width: 20,height: 40,),
                                            SizedBox(
                                              width: 14,
                                            ),
                                            Text(
                                              S .of(context).sign_in_with_google,//"Sign in with Google" , //"Sign in with Google",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorCodes.signincolor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/70, horizontal: 28),
                              child: GestureDetector(
                                onTap: () {
                                  _dialogforProcessing();
                                  Navigator.of(context).pop();
                                  facebooklogin();
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(4.0),
                                  elevation: 2,
                                  shadowColor: Colors.grey,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: 10.0,  right: 5.0, top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),

                                      // border: Border.all(width: 0.5, color: Color(0xff4B4B4B)),
                                    ),
                                    child:
                                    Padding(
                                      padding: const EdgeInsets.only(right:23.0,left: 23),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            SvgPicture.asset(Images.facebookImg, width: 25, height: 25,),
                                            //Image.asset(Images.facebookImg,width: 20,height: 40,),
                                            SizedBox(
                                              width: 14,
                                            ),
                                            Text(
                                              S .of(context).sign_in_with_facebook,//"Sign in with Facebook" ,// "Sign in with Facebook",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorCodes.signincolor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isAvailable)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 28),
                                child: GestureDetector(
                                  onTap: () {
                                    appleLogIn();
                                  },
                                  child: Material(
                                    borderRadius: BorderRadius.circular(4.0),
                                    elevation: 2,
                                    shadowColor: Colors.grey,
                                    child: Container(

                                      padding: EdgeInsets.only(
                                          left: 10.0, right: 5.0,top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.0),),
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.only(right:23.0,left:23,),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SvgPicture.asset(Images.appleImg, width: 25, height: 25,),
                                              //Image.asset(Images.appleImg, width: 20,height: 40,),
                                              SizedBox(
                                                width: 14,
                                              ),
                                              Text(
                                                S .of(context).signin_apple,//"Sign in with Apple"  , //"Sign in with Apple",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorCodes.signincolor),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          });
        });
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
  _dialogforProcess() {
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
  _saveFormLogin() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState!.save();
    Provider.of<BrandItemsList>(context,listen: false).LoginUser();
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    _dialogforOtp();
  }
  void alertOtp(BuildContext ctx) {
    mobile = PrefUtils.prefs!.getString("Mobilenum")!;
    var alert = AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        content: StreamBuilder<int>(
            stream: _events!.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Container(
                  height: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.width / 3,
                  width: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width / 2.5,
                  child: Column(children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      padding: EdgeInsets.only(left: 20.0),
                      color: ColorCodes.lightGreyWebColor,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            S .of(context).signup_otp,//"Signup using OTP",
                            style: TextStyle(
                                color: ColorCodes.mediumBlackColor,
                                fontSize: 20.0),
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 25.0),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                S .of(context).please_check_otp_sent_to_your_mobile_number,//'Please check OTP sent to your mobile number',
                                style: TextStyle(
                                    color: ColorCodes.lightblack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),

                                // textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 20.0),
                                Text(
                                  IConstants.countryCode + '  $mobile',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 16.0),
                                ),
                                SizedBox(width: 30.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _dialogforSignIn();
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: ColorCodes.baseColordark, width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text(
                                            S .of(context).change,//'Change',
                                            style: TextStyle(
                                                color: ColorCodes.black,
                                                fontSize: 13))),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                S .of(context).enter_otp,//'Enter OTP',
                                style: TextStyle(
                                    color: ColorCodes.greyColord, fontSize: 14),
                                //textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Auto Sms
                                  Container(
                                      height: 40,
                                      //width: MediaQuery.of(context).size.width*80/100,
                                      width: (_isWeb &&
                                          ResponsiveLayout.isSmallScreen(
                                              context))
                                          ? MediaQuery.of(context).size.width /
                                          2
                                          : MediaQuery.of(context).size.width /
                                          3,
                                      //padding: EdgeInsets.zero,
                                      child: PinFieldAutoFill(
                                          controller: controller,
                                          decoration: UnderlineDecoration(
                                              colorBuilder: FixedColorBuilder(
                                                  ColorCodes.greyColor)),
                                          onCodeChanged: (text) {
                                            otpvalue = text!;
                                            SchedulerBinding.instance!
                                                .addPostFrameCallback(
                                                    (_) => setState(() {}));
                                          },
                                          onCodeSubmitted: (text) {
                                            SchedulerBinding.instance!
                                                .addPostFrameCallback(
                                                    (_) => setState(() {
                                                  otpvalue = text;
                                                }));
                                          },
                                          codeLength: 4,
                                          currentCode: otpvalue)),
                                ]),
                            SizedBox(
                              height: 20,
                            ),
                            _showOtp
                                ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      width: (_isWeb &&
                                          ResponsiveLayout
                                              .isSmallScreen(context))
                                          ? MediaQuery.of(context)
                                          .size
                                          .width *
                                          50 /
                                          100
                                          : MediaQuery.of(context)
                                          .size
                                          .width *
                                          32 /
                                          100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        border: Border.all(
                                            color: ColorCodes.borderdark,
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text(
                                            S .of(context).resend_otp,//'Resend OTP'
                                          )),
                                    ),
                                  ),
                                  if(Features.callMeInsteadOTP)
                                    Container(
                                      height: 28,
                                      width: 28,
                                      margin: EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        border: Border.all(
                                            color: ColorCodes.borderdark,
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text(
                                            S .of(context).or,//'OR',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                    ),
                                  if(Features.callMeInsteadOTP)
                                    _timeRemaining == 0
                                        ? MouseRegion(
                                      cursor:
                                      SystemMouseCursors.click,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior
                                            .translucent,
                                        onTap: () {
                                          otpCall();
                                          _timeRemaining = 60;
                                        },
                                        child: Expanded(
                                          child: Container(
                                            height: 40,
                                            //width: MediaQuery.of(context).size.width*32/100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(6),
                                              border: Border.all(
                                                  color: ColorCodes.primaryColor,
                                                  width: 1.5),
                                            ),

                                            child: Center(
                                                child: Text(
                                                  S .of(context).call_me_instead,//'Call me Instead'
                                                )),
                                          ),
                                        ),
                                      ),
                                    )
                                        : Expanded(
                                      child: Container(
                                        height: 40,
                                        //width: MediaQuery.of(context).size.width*32/100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              6),
                                          border: Border.all(
                                              color:
                                              ColorCodes.borderdark,
                                              width: 1.5),
                                        ),
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: S .of(context).call_in,//'Call in',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .black)),
                                                new TextSpan(
                                                  text:
                                                  ' 00:$_timeRemaining',
                                                  style: TextStyle(
                                                    color: ColorCodes.varcolorlight,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ])
                                : Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _timeRemaining == 0
                                    ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior:
                                    HitTestBehavior.translucent,
                                    onTap: () {
                                      //  _showCall = true;
                                      _showOtp = true;
                                      _timeRemaining += 30;
                                      Otpin30sec();
                                    },
                                    child: Expanded(
                                      child: Container(
                                        height: 40,
                                        width: (_isWeb &&
                                            ResponsiveLayout
                                                .isSmallScreen(
                                                context))
                                            ? MediaQuery.of(context)
                                            .size
                                            .width *
                                            30 /
                                            100
                                            : MediaQuery.of(context)
                                            .size
                                            .width *
                                            15 /
                                            100,
                                        //width: MediaQuery.of(context).size.width*32/100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              6),
                                          border: Border.all(
                                              color: ColorCodes.primaryColor,
                                              width: 1.5),
                                        ),
                                        child: Center(
                                            child:
                                            Text(S .of(context).resend_otp,//'Resend OTP'
                                            )),
                                      ),
                                    ),
                                  ),
                                )
                                    : Expanded(
                                  child: Container(
                                    height: 40,
                                    //width: MediaQuery.of(context).size.width*40/100,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      border: Border.all(
                                          color: ColorCodes.baseColordark,
                                          width: 1.5),
                                    ),
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text:
                                                S .of(context).resend_otp_in,//'Resend Otp in',
                                                style: TextStyle(
                                                    color: Colors
                                                        .black)),
                                            new TextSpan(
                                              text:
                                              ' 00:$_timeRemaining',
                                              style: TextStyle(
                                                color: ColorCodes.varcolorlight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if(Features.callMeInsteadOTP)
                                  Container(
                                    height: 28,
                                    width: 28,
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                      border: Border.all(
                                          color: ColorCodes.borderdark,
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text(
                                          S .of(context).or,//'OR',
                                          style: TextStyle(fontSize: 10),
                                        )),
                                  ),
                                if(Features.callMeInsteadOTP)
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      //width: MediaQuery.of(context).size.width*32/100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        border: Border.all(
                                            color: ColorCodes.borderdark,
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text(S .of(context).call_me_instead,//'Call me Instead'
                                          )),
                                    ),
                                  ),
                              ],
                            ),
                          ]),
                    ),
                    Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _verifyOtp();
                            _dialogforProcessing();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                )),
                            height: 60.0,
                            child: Center(
                              child: Text(
                                S .of(context).login,//"LOGIN",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Theme.of(context).buttonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                    ),
                  ]));
            }));
    _startTimer();
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return alert;
        });
  }
  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //setState(() {
      (_timeRemaining > 0) ? _timeRemaining-- : _timer!.cancel();
      //});
      _events!.add(_timeRemaining);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("membership....."+ Features.isMembership.toString()+"..."+_checkmembership.toString());
    bool _isStock = false;
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 2;
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    double wid= queryData.size.width;
    double maxwid=wid*0.90;
    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 372:
    Features.btobModule?(deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 70 :
    (!Features.ismultivendor) ? (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 165 : (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 150;

    /* if (widget.fromScreen == "home_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findById(widget.itemdata!.id);
    } else if (widget.fromScreen == "searchitem_screen") {
      itemvarData = null;
      itemvarData = Provider.of<ItemsList>(
        context,
        listen: false,
      ).findByIdsearch(widget.id);
    } else if (widget.fromScreen == "sellingitem_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdall(widget.id);
    } else if (widget.fromScreen == "notavailableProduct") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdswap(widget.id);
    } else if (widget.fromScreen == "not_product_screen") {
      itemvarData = null;
      itemvarData = Provider.of<NotificationItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    } else if (widget.fromScreen == "shoppinglistitem_screen") {
      itemvarData = null;
      itemvarData = Provider.of<BrandItemsList>(
        context,
        listen: false,
      ).findByIditempricevar(widget.shoppinglistid, widget.id);
    }  else if (widget.fromScreen == "Forget") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdforget(widget.id);
    }else if (widget.fromScreen == "brands_screen") {
      itemvarData = null;
      itemvarData = Provider.of<BrandItemsList>(
        context,
        listen: false,
      ).findById( widget.id);
    }
    else {
      itemvarData = null;
      variddata = [];
      varnamedata = [];
      unitdata=[];
      varmrpdata = [];
      varpricedata = [];
      varmemberpricedata = [];
      varminitemdata = [];
      varmaxitemdata = [];
      varLoyaltydata = [];
      varQtyData = [];
      varstockdata = [];
      vardiscountdata = [];
      discountDisplaydata = [];
      memberpriceDisplaydata = [];

      checkBoxdata = [];
      containercolor = [];
      // textcolor = [];

      itemvarData = Provider.of<ItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
      if(widget.fromScreen == "searchitem_screen"){
        itemvarData = Provider.of<ItemsList>(
          context,
          listen: false,
        ).findByIdsearch(widget.id);
      }
    }
    for(int i= 0; i<itemvarData.length;i++){

    }
    varlength = itemvarData.length;

    if (varlength > 1) {
      _varlength = true;
      variddata.clear();
      variationdisplaydata.clear();
      for (int i = 0; i < varlength; i++) {
        variddata.add(itemvarData[i].varid);
        variationdisplaydata.add(variddata[i]);
        varnamedata.add(itemvarData[i].varname);
        unitdata.add(itemvarData[i].unit);
        varmrpdata.add(itemvarData[i].varmrp);
        varpricedata.add(itemvarData[i].varprice);
        varmemberpricedata.add(itemvarData[i].varmemberprice);
        varminitemdata.add(itemvarData[i].varminitem);
        varmaxitemdata.add(itemvarData[i].varmaxitem);
        varLoyaltydata.add(itemvarData[i].varLoyalty);
        varQtyData.add(itemvarData[i].varQty);
        varstockdata.add(itemvarData[i].varstock);
        discountDisplaydata.add(itemvarData[i].discountDisplay);
        memberpriceDisplaydata.add(itemvarData[i].membershipDisplay);

        if (i == 0) {
          checkBoxdata.add(true);
          containercolor.add(0xffffffff);
          textcolor.add(0xFF2966A2);
          iconcolor.add(0xFF2966A2);
        } else {
          checkBoxdata.add(false);
          containercolor.add(0xffffffff);
          textcolor.add(0xff060606);
          iconcolor.add(0xFFC1C1C1);
        }

        *//*var difference = (double.parse(itemvarData[i].varmrp) - int.parse(itemvarData[i].varprice));
        var profit = (difference / double.parse(itemvarData[0].varmrp)) * 100;
        vardiscountdata.add("$profit");*//*

      }
    }

    if (varlength <= 0) {
    } else {
      if (!dialogdisplay) {

        varid = itemvarData[0].varid;
        varname = itemvarData[0].varname;
        unit=itemvarData[0].unit;
        varmrp = itemvarData[0].varmrp;
        varprice = itemvarData[0].varprice;
        varmemberprice = itemvarData[0].varmemberprice;
        varminitem = itemvarData[0].varminitem;
        varmaxitem = itemvarData[0].varmaxitem;
        varLoyalty = itemvarData[0].varLoyalty;
        varQty = itemvarData[0].varQty;
        varstock = itemvarData[0].varstock;
        discountDisplay = itemvarData[0].discountDisplay;
        memberpriceDisplay = itemvarData[0].membershipDisplay;
        //varimageurl = itemvarData[0].imageUrl;
        if (_checkmembership) {
          if (varmemberprice.toString() == '-' ||
              double.parse(varmemberprice) <= 0) {
            if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
              margins = "0";
            } else {
              var difference = (double.parse(varmrp) - double.parse(varprice));
              var profit = difference / double.parse(varmrp);
              margins = profit * 100;

              //discount price rounding
              margins = num.parse(margins.toStringAsFixed(0));
              margins = margins.toString();
            }
          } else {
            var difference =
            (double.parse(varmrp) - double.parse(varmemberprice));
            var profit = difference / double.parse(varmrp);
            margins = profit * 100;

            //discount price rounding
            margins = num.parse(margins.toStringAsFixed(0));
            margins = margins.toString();
          }
        } else {
          if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
            margins = "0";
          } else {
            var difference = (double.parse(varmrp) - double.parse(varprice));
            var profit = difference / double.parse(varmrp);
            margins = profit * 100;

            //discount price rounding
            margins = num.parse(margins.toStringAsFixed(0));
            margins = margins.toString();
          }
        }
      }
    }*/
    _Toast(String value){
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(value),
            );
          });
    }

    _notifyMe() async {
      setState(() {
        _isNotify = true;
      });
      //_notifyMe();
      int resposne = await Provider.of<BrandItemsList>(context, listen: false).notifyMe(widget.itemdata!.id!,varid!,widget.itemdata!.type!);
      if(resposne == 200) {

        //_isWeb?_Toast("You will be notified via SMS/Push notification, when the product is available"):
        Fluttertoast.showToast(msg: S .of(context).you_will_notify,//"You will be notified via SMS/Push notification, when the product is available" ,
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor:
            Colors.black87,
            textColor: Colors.white);
        setState(() {
          _isNotify = false;
        });
      } else {
        Fluttertoast.showToast(msg: S .of(context).something_went_wrong,//"Something went wrong" ,
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor:
            Colors.black87,
            textColor: Colors.white);
        setState(() {
          _isNotify = false;
        });
      }
    }

   /* addToCart(int _itemCount) async {
      if (widget.fromScreen == "home_screen") {
        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByfeaturedimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      }else if (widget.fromScreen == "singleproduct_screen") {
        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIditemsnewimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "notavailableProduct") {
        multiimage = Provider.of<SellingItemsList>(context, listen: false).findBySwapimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "searchitem_screen") {
        multiimage = Provider.of<ItemsList>(context, listen: false).findBysearchimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "sellingitem_screen") {
        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIdallimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "item_screen") {
        multiimage = Provider.of<ItemsList>(context, listen: false).findByIditemimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "shoppinglistitem_screen") {
        multiimage = Provider.of<BrandItemsList>(context, listen: false).findByshoppingimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "brands_screen") {
        multiimage = Provider.of<BrandItemsList>(context, listen: false).findBybrandimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      }else if(widget.fromScreen == "not_product_screen"){
        multiimage = Provider.of<NotificationItemsList>(context, listen: false,).findBynotproductimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      } else if (widget.fromScreen == "Forget") {
        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByForgotimage(varid);
        _displayimg = multiimage[0].imageUrl;
        if(itemvarData.length<=1) {
          itemimg =  widget.imageUrl;
        }else{
          itemimg =_displayimg;
        }
      }
      await Provider.of<CartItems>(context, listen: false).addToCart(
          widget.id, varid, varname+unit, varminitem, varmaxitem, varLoyalty.toString(), varstock, varmrp, widget.title,
          _itemCount.toString(), varprice, varmemberprice, *//*widget.imageUrl*//*itemimg, "0", "0",widget.veg_type,widget.type,widget.eligibleforexpress,widget.delivery,widget.duration,widget.durationType,widget.note).then((_) {


        setState(() {
          _isAddToCart = false;
          varQty = _itemCount;
        });
        final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
        for(int i = 0; i < sellingitemData.featuredVariation.length; i++) {
          if(sellingitemData.featuredVariation[i].varid == varid) {
            sellingitemData.featuredVariation[i].varQty = _itemCount;
            break;
          }
        }
        for(int i = 0; i < sellingitemData.itemspricevarOffer.length; i++) {
          if(sellingitemData.itemspricevarOffer[i].varid == varid) {
            sellingitemData.itemspricevarOffer[i].varQty = _itemCount;
            break;
          }
        }
        for(int i = 0; i < sellingitemData.itemspricevarSwap.length; i++) {
          if(sellingitemData.itemspricevarSwap[i].varid == varid) {
            sellingitemData.itemspricevarSwap[i].varQty = _itemCount;
            break;
          }
        }
        for(int i = 0; i < sellingitemData.discountedVariation.length; i++) {
          if(sellingitemData.discountedVariation[i].varid == varid) {
            sellingitemData.discountedVariation[i].varQty = _itemCount;
            break;
          }
        }
        for(int i = 0; i < sellingitemData.recentVariation.length; i++) {
          if(sellingitemData.recentVariation[i].varid == varid) {
            sellingitemData.recentVariation[i].varQty = _itemCount;
            break;
          }
        }

        for(int i = 0; i < variationdisplaydata.length; i++) {
          if(itemvarData[i].varid == varid) {
            itemvarData[i].varQty = _itemCount;
            break;
          }
        }



        _bloc.setFeaturedItem(sellingitemData);

        *//*CartItems.itemsList.add(CartItemsFields(
        itemId: int.parse(widget.id),
        varId: int.parse(varid),
        varName: varname,
        varMinItem: int.parse(varminitem),
        varMaxItem: int.parse(varmaxitem),
        varStock: int.parse(varstock),
        varMrp: double.parse(varmrp),
        itemName: widget.title,
        itemQty: _itemCount,
        status: 0,
        itemPrice: double.parse(varprice),
        membershipPrice: varmemberprice,
        itemActualprice: double.parse(varmrp),
        itemImage: widget.imageUrl,
        itemLoyalty: varLoyalty,
        membershipId: 0,
        mode: 0,
      ));
      final cartItemsData = Provider.of<CartItems>(context, listen: false);
      _bloc.setCartItem(cartItemsData);
*//*
        Product products = Product(
            itemId: int.parse(widget.id),
            varId: int.parse(varid),
            varName: varname+unit,
            varMinItem: int.parse(varminitem),
            varMaxItem: int.parse(varmaxitem),
            itemLoyalty: varLoyalty,
            varStock: int.parse(varstock),
            varMrp: double.parse(varmrp),
            itemName: widget.title,
            itemQty: _itemCount,
            itemPrice: double.parse(varprice),
            membershipPrice: varmemberprice,
            itemActualprice: double.parse(varmrp),
            itemImage: widget.imageUrl,
            membershipId: 0,
            mode: 0,
            veg_type: widget.veg_type,
            type: widget.type,
            eligible_for_express: widget.eligibleforexpress,
            delivery: widget.delivery,
            duration: widget.duration,
            durationType: widget.durationType,
            note: widget.note
        );

        productBox.add(products);
      });
    }*/
  /*  addToCart(PriceVariation priceVariation, ItemData itemdata,) async {
      cartcontroller.addtoCart(itemdata,(isloading){
        setState(() {
          _isAddToCart = isloading;
        });
      },priceVariation,);
    }*/


   /* incrementToCart(_itemCount) async {
      if (_itemCount + 1 <= int.parse(varminitem)) {
        _itemCount = 0;
      }
      final s = await Provider.of<CartItems>(context, listen: false).updateCart(varid, _itemCount.toString(), varprice).then((_) {
        setState(() {
          _isAddToCart = false;
          varQty = _itemCount;
        });
        if (_itemCount + 1 <= int.parse(varminitem)) {
          for (int i = 0; i < productBox.values.length; i++) {
            if (productBox.values.elementAt(i).varId == int.parse(varid)) {
              productBox.deleteAt(i);
              break;
            }
          }
          final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
          for(int i = 0; i < sellingitemData.featuredVariation.length; i++) {
            if(sellingitemData.featuredVariation[i].varid == varid) {
              sellingitemData.featuredVariation[i].varQty = _itemCount;
            }
          }
          for(int i = 0; i < sellingitemData.itemspricevarOffer.length; i++) {
            if(sellingitemData.itemspricevarOffer[i].varid == varid) {
              sellingitemData.itemspricevarOffer[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.itemspricevarSwap.length; i++) {
            if(sellingitemData.itemspricevarSwap[i].varid == varid) {
              sellingitemData.itemspricevarSwap[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.discountedVariation.length; i++) {
            if(sellingitemData.discountedVariation[i].varid == varid) {
              sellingitemData.discountedVariation[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.recentVariation.length; i++) {
            if(sellingitemData.recentVariation[i].varid == varid) {
              sellingitemData.recentVariation[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < variationdisplaydata.length; i++) {
            if(itemvarData[i].varid == varid) {
              itemvarData[i].varQty = _itemCount;
              break;
            }
          }
          _bloc.setFeaturedItem(sellingitemData);
        } else {
          final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
          for(int i = 0; i < sellingitemData.featuredVariation.length; i++) {
            if(sellingitemData.featuredVariation[i].varid == varid) {
              sellingitemData.featuredVariation[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.itemspricevarOffer.length; i++) {
            if(sellingitemData.itemspricevarOffer[i].varid == varid) {
              sellingitemData.itemspricevarOffer[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.itemspricevarSwap.length; i++) {
            if(sellingitemData.itemspricevarSwap[i].varid == varid) {
              sellingitemData.itemspricevarSwap[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.discountedVariation.length; i++) {
            if(sellingitemData.discountedVariation[i].varid == varid) {
              sellingitemData.discountedVariation[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < sellingitemData.recentVariation.length; i++) {
            if(sellingitemData.recentVariation[i].varid == varid) {
              sellingitemData.recentVariation[i].varQty = _itemCount;
              break;
            }
          }
          for(int i = 0; i < variationdisplaydata.length; i++) {
            if(itemvarData[i].varid == varid) {
              itemvarData[i].varQty = _itemCount;
              break;
            }
          }
          _bloc.setFeaturedItem(sellingitemData);
          final cartItemsData = Provider.of<CartItems>(context, listen: false);
          for(int i = 0; i < cartItemsData.items.length; i++) {
            if(cartItemsData.items[i].varId == int.parse(varid)) {
              cartItemsData.items[i].itemQty = _itemCount;
            }
          }
          _bloc.setCartItem(cartItemsData);
          Product products = Product(
              itemId: int.parse(widget.id),
              varId: int.parse(varid),
              varName: varname+unit,
              varMinItem: int.parse(varminitem),
              varMaxItem: int.parse(varmaxitem),
              itemLoyalty: varLoyalty,
              varStock: int.parse(varstock),
              varMrp: double.parse(varmrp),
              itemName: widget.title,
              itemQty: _itemCount,
              itemPrice: double.parse(varprice),
              membershipPrice: varmemberprice,
              itemActualprice: double.parse(varmrp),
              itemImage: widget.imageUrl,
              membershipId: 0,
              mode: 0,
              veg_type: widget.veg_type,
              type: widget.type,
              eligible_for_express: widget.eligibleforexpress,
              delivery:widget.delivery,
              duration: widget.duration,
              durationType: widget.durationType,
              note: widget.note
          );

          var items = Hive.box<Product>(productBoxName);

          for (int i = 0; i < items.length; i++) {
            if (Hive.box<Product>(productBoxName).values.elementAt(i).varId == int.parse(varid)) {
              Hive.box<Product>(productBoxName).putAt(i, products);
            }
          }
        }
      });
    }*/
    if (_checkmembership) {
      //membershipdisplay = false;
      colorRight = 0xffffffff;
      colorLeft = 0xffffffff;
    } else {
      if (varmemberprice == '-' || varmemberprice == "0") {
        setState(() {
          //membershipdisplay = false;
          colorRight = 0xffffffff;
          colorLeft = 0xffffffff;
        });
      } else {
        setState(() {
          //membershipdisplay = true;
          colorRight = 0xff3d8d3c;
          colorLeft = 0xff8abb50;
        });
      }
    }

    /*if(double.parse(varprice) <= 0 || varprice.toString() == "" || double.parse(varprice) == double.parse(varmrp)){
      discountedPriceDisplay = false;
    } else {
      discountedPriceDisplay = true;
    }*/

  /*  if (margins == null) {
      _checkmargin = false;
    } else {
      if (int.parse(margins) <= 0) {
        _checkmargin = false;
      } else {
        _checkmargin = true;
      }
    }*/
    setState(() {
      if(varstock!=null)
        if (int.parse(varstock!) <= 0) {
          _isStock = false;
        } else {
          _isStock = true;
        }
    });

    Widget handler( int i) {
      if (int.parse(varstock!) <= 0) {
        return (varid == itemvarData[i].varid) ?
        Icon(
            Icons.radio_button_checked_outlined,
            color: ColorCodes.grey)
            :
        Icon(
            Icons.radio_button_off_outlined,
            color: ColorCodes.blackColor);

      } else {
        return (varid == itemvarData[i].varid) ?
        Icon(
            Icons.radio_button_checked_outlined,
            color: ColorCodes.mediumBlueColor)
            :
        Icon(
            Icons.radio_button_off_outlined,
            color: ColorCodes.blackColor);
      }
    }

   /* Widget showoptions() {
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return  Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  width: 800,
                  //  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(widget.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Theme
                                      .of(context)
                                      .primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image(
                                height: 40,
                                width: 40,
                                image: AssetImage(
                                    Images.bottomsheetcancelImg),
                                color: Colors.black,
                              )),
                        ],
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        // height: 200,
                        child: SingleChildScrollView(
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: variationdisplaydata.length,
                              itemBuilder: (_, i) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    setState(() {
                                      varid = itemvarData[i].varid;
                                      varname = itemvarData[i].varname;
                                      unit=itemvarData[i].unit;
                                      varmrp = itemvarData[i].varmrp;
                                      varprice = itemvarData[i].varprice;
                                      varmemberprice = itemvarData[i].varmemberprice;
                                      varminitem = itemvarData[i].varminitem;
                                      varmaxitem = itemvarData[i].varmaxitem;
                                      varLoyalty = itemvarData[i].varLoyalty;
                                      varQty = (itemvarData[i].varQty >= 0) ? itemvarData[i].varQty : int.parse(itemvarData[i].varminitem);
                                      varstock = itemvarData[i].varstock;
                                      discountDisplay = itemvarData[i].discountDisplay;
                                      memberpriceDisplay = itemvarData[i].membershipDisplay;
                                      if (_checkmembership) {
                                        if (varmemberprice.toString() == '-' || double.parse(varmemberprice) <= 0) {
                                          if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                            margins = "0";
                                          } else {
                                            var difference = (double.parse(varmrp) - double.parse(varprice));
                                            var profit = difference / double.parse(varmrp);
                                            margins = profit * 100;

                                            //discount price rounding
                                            margins = num.parse(margins.toStringAsFixed(0));
                                            margins = margins.toString();
                                          }
                                        } else {
                                          var difference = (double.parse(varmrp) - double.parse(varmemberprice));
                                          var profit = difference / double.parse(varmrp);
                                          margins = profit * 100;

                                          //discount price rounding
                                          margins = num.parse(margins.toStringAsFixed(0));
                                          margins = margins.toString();
                                        }
                                      } else {
                                        if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                          margins = "0";
                                        } else {
                                          var difference = (double.parse(varmrp) - double.parse(varprice));
                                          var profit = difference / double.parse(varmrp);
                                          margins = profit * 100;

                                          //discount price rounding
                                          margins = num.parse(margins.toStringAsFixed(0));
                                          margins = margins.toString();
                                        }
                                      }
                                      if (widget.fromScreen == "home_screen") {
                                        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByfeaturedimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      }else if (widget.fromScreen == "singleproduct_screen") {
                                        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIditemsnewimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      } else if (widget.fromScreen == "searchitem_screen") {
                                        multiimage = Provider.of<ItemsList>(context, listen: false).findBysearchimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      } else if (widget.fromScreen == "sellingitem_screen") {
                                        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIdallimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      } else if (widget.fromScreen == "notavailableProduct") {
                                        multiimage = Provider.of<SellingItemsList>(context, listen: false).findBySwapimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      }else if (widget.fromScreen == "item_screen") {
                                        multiimage = Provider.of<ItemsList>(context, listen: false).findByIditemimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      } else if (widget.fromScreen == "shoppinglistitem_screen") {
                                        multiimage = Provider.of<BrandItemsList>(context, listen: false).findByshoppingimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      } else if (widget.fromScreen == "brands_screen") {
                                        multiimage = Provider.of<BrandItemsList>(context, listen: false).findBybrandimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      }else if(widget.fromScreen == "not_product_screen"){
                                        multiimage = Provider.of<NotificationItemsList>(context, listen: false,).findBynotproductimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      } else if (widget.fromScreen == "Forget") {
                                        multiimage = Provider.of<SellingItemsList>(context, listen: false).findByForgotimage(varid);
                                        _displayimg = multiimage[0].imageUrl;
                                      }
                                      Future.delayed(Duration(seconds: 0), () {
                                        dialogdisplay = true;
                                        for (int j = 0; j < variddata.length; j++) {
                                          if (i == j) {
                                            setState(() {
                                              checkBoxdata[i] = true;
                                              containercolor[i] = 0xFFFFFFFF;
                                              // textcolor[i] = 0xFF2966A2;
                                              iconcolor[i] = 0xFF2966A2;
                                            });
                                          } else {
                                            setState(() {
                                              checkBoxdata[j] = false;
                                              containercolor[j] = 0xFFFFFFFF;
                                              iconcolor[j] = 0xFFC1C1C1;
                                              //  textcolor[j] = 0xFF060606;
                                            });
                                          }
                                        }
                                      });
                                      // Navigator.of(context).pop(true);
                                    });
                                  },
                                  child: Container(
                                    height: 50,

                                    padding: EdgeInsets.only(right: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        _checkmembership
                                            ? //membered usesr
                                        itemvarData[i].membershipDisplay
                                            ? RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: itemvarData[i]
                                                  .varcolor,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: varnamedata[i]+" "+unitdata[i]+
                                                    " - ",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color:Colors.black,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                              TextSpan(
                                                text: IConstants.currencyFormat +
                                                    varmemberpricedata[
                                                    i] +
                                                    " ",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color:Colors.black,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                  IConstants.currencyFormat +
                                                      varmrpdata[
                                                      i],
                                                  style: TextStyle(
                                                    color:Colors.black,
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )
                                            : itemvarData[i].discountDisplay
                                            ? RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color:
                                              itemvarData[i]
                                                  .varcolor,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: varnamedata[i]+" "+unitdata[i]+
                                                    " - ",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color:Colors.black,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                              TextSpan(
                                                text: IConstants.currencyFormat +
                                                    varpricedata[
                                                    i] +
                                                    " ",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color:Colors.black,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                              TextSpan(
                                                  text: IConstants.currencyFormat +
                                                      varmrpdata[
                                                      i],
                                                  style:
                                                  TextStyle(
                                                    color:Colors.black,
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )
                                            : new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color:
                                              itemvarData[i]
                                                  .varcolor,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                text: varnamedata[i]+" "+unitdata[i]+
                                                    " - ",
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:Colors.black,
                                                ),
                                              ),
                                              new TextSpan(
                                                text:
                                                IConstants.currencyFormat +
                                                    " " +
                                                    varmrpdata[
                                                    i],
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                            : itemvarData[i].discountDisplay
                                            ? RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: itemvarData[i]
                                                  .varcolor,
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: varnamedata[i]+" "+unitdata[i]+ " - ",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color:Colors.black,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text:
                                                IConstants.currencyFormat + varpricedata[i] + " ",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color:Colors.black,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text: IConstants.currencyFormat + varmrpdata[i],
                                                  style: TextStyle(
                                                    color:Colors.black,
                                                    decoration: TextDecoration.lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )
                                            : new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: itemvarData[i]
                                                  .varcolor,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                text: varnamedata[i]+" "+unitdata[i]+
                                                    " - ",
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color:Colors.black,
                                                ),
                                              ),
                                              new TextSpan(
                                                text:
                                                IConstants.currencyFormat +
                                                    " " +
                                                    varmrpdata[i],
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color:Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),


                                        handler(i),

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

                      Row(
                        children: [
                          if(Features.isSubscription)
                            (widget.subscribe == "0")?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                (int.parse(varstock) <= 0)  ?
                                SizedBox(height: 40,)
                                    :
                                GestureDetector(
                                  onTap: () async {
                                    if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                      _dialogforSignIn();
                                    }
                                    else {
                                      (checkskip) ?
                                      Navigator.of(context).pushNamed(
                                        SignupSelectionScreen.routeName,
                                      ) :
                                      Navigator.of(context).pushNamed(
                                          SubscribeScreen.routeName,
                                          arguments: {
                                            "itemid": widget.id,
                                            "itemname": widget.title,
                                            "itemimg": widget.imageUrl,
                                            "varname": varname+unit,
                                            "varmrp":varmrp,
                                            "varprice":  _checkmembership ? varmemberprice :discountDisplay ?varprice:varmrp,
                                            "paymentMode": widget.paymentmode,
                                            "cronTime": widget.cronTime,
                                            "name": widget.name,
                                            "varid": varid.toString(),
                                            "brand": widget.brand
                                          }
                                      );
                                    }
                                  },
                                  child: Container(
                                      height: 40.0,
                                      width:(MediaQuery.of(context).size.width / 4) + 15,
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: ColorCodes.primaryColor),
                                          color: ColorCodes.whiteColor,
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight: const Radius.circular(2.0),
                                            bottomLeft: const Radius.circular(2.0),
                                            bottomRight: const Radius.circular(2.0),
                                          )),
                                      child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Center(
                                              child: Text(
                                                S .of(context).subscribe,//'SUBSCRIBE',
                                                style: TextStyle(
                                                  color: ColorCodes.mediumBlueColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              )),
                                        ],
                                      )
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                )
                              ],
                            ):SizedBox.shrink(),
                          if(Features.isSubscription)
                            SizedBox(
                              width: 10,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              (int.parse(varstock) <= 0) ?
                              GestureDetector(
                                onTap: () async {
                                  if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                    Navigator.of(context).pop();
                                    _dialogforSignIn();
                                  }
                                  else {
                                    if (checkskip) {
                                      Navigator.of(context).pushNamed(
                                        SignupSelectionScreen.routeName,
                                      );
                                      // _notifyMe();
                                    }

                                    else {
                                      setState(() {
                                        _isNotify = true;
                                      });
                                      //_notifyMe();
                                      int resposne = await Provider.of<
                                          BrandItemsList>(context, listen: false)
                                          .notifyMe(widget.id, varid, widget.type);
                                      if (resposne == 200) {
                                        setState(() {
                                          _isNotify = false;
                                        });
                                        *//* _isWeb
                                            ? _Toast(
                                            "You will be notified via SMS/Push notification, when the product is available")
                                            :*//*
                                        Fluttertoast.showToast(
                                            msg: S .of(context).you_will_notify,//"You will be notified via SMS/Push notification, when the product is available",
                                            fontSize: MediaQuery
                                                .of(context)
                                                .textScaleFactor * 13,
                                            backgroundColor:
                                            Colors.black87,
                                            textColor: Colors.white);

                                      } else {
                                        Fluttertoast.showToast(
                                            msg: S .of(context).something_went_wrong,//"Something went wrong",
                                            fontSize: MediaQuery
                                                .of(context)
                                                .textScaleFactor * 13,
                                            backgroundColor:
                                            Colors.black87,
                                            textColor: Colors.white);
                                        setState(() {
                                          _isNotify = false;
                                        });
                                      }
                                    }
                                  }
                                  *//* setState(() {
                                    _isNotify = true;
                                  });
                                  //_notifyMe();
                                  int resposne = await Provider.of<BrandItemsList>(context, listen: false).notifyMe(widget.id,varid,widget.type);
                                  if(resposne == 200) {
                                    Fluttertoast.showToast(msg: "You will be notified via SMS/Push notification, when the product is available" ,
                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                        backgroundColor:
                                        Colors.black87,
                                        textColor: Colors.white);
                                    setState(() {
                                      _isNotify = false;
                                    });
                                  } else {
                                    Fluttertoast.showToast(msg: "Something went wrong" ,
                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                        backgroundColor:
                                        Colors.black87,
                                        textColor: Colors.white);
                                    setState(() {
                                      _isNotify = false;
                                    });
                                  }*//*
                                },
                                child: Container(
                                  height: 40.0,
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width / 4) + 15,
                                  decoration: new BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.grey,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        topRight: const Radius.circular(2.0),
                                        bottomLeft: const Radius.circular(2.0),
                                        bottomRight: const Radius.circular(2.0),
                                      )),
                                  child:
                                  _isNotify ?
                                  Center(
                                    child: SizedBox(
                                        width: 20.0,
                                        height: 20.0,
                                        child: new CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: new AlwaysStoppedAnimation<
                                              Color>(Colors.white),)),
                                  )
                                      : Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Center(
                                          child: Text(
                                            S .of(context).notify_me,//'Notify Me',
                                            *//* "ADD",*//*
                                            style: TextStyle(
                                              *//*fontWeight: FontWeight.w700,*//*
                                                color:
                                                Colors
                                                    .white *//*Colors.black87*//*),
                                            textAlign: TextAlign.center,
                                          )),
                                      Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius: new BorderRadius.only(
                                              topRight:
                                              const Radius.circular(2.0),
                                              bottomRight:
                                              const Radius.circular(2.0),
                                            )),
                                        height: 40,
                                        width: 25,
                                        child: Icon(
                                          Icons.add,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Container(
                                height: 40.0,
                                width: (MediaQuery
                                    .of(context)
                                    .size
                                    .width / 4) + 15,
                                *//*(MediaQuery.of(context).size.width / 3) + 18,*//*
                                child: ValueListenableBuilder(
                                  valueListenable:
                                  Hive.box<Product>(productBoxName)
                                      .listenable(),
                                  builder: (context, Box<Product> box, _) {
                                    *//*if (box.values.length <= 0)*//* if (varQty <= 0)
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isAddToCart = true;
                                          });
                                          addToCart(int.parse(varminitem));
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          decoration: BoxDecoration(
                                            color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
                                            borderRadius:
                                            BorderRadius.circular(3),
                                          ),
                                          child: _isAddToCart ?
                                          Center(
                                            child: SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: new CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor: new AlwaysStoppedAnimation<
                                                      Color>(Colors.white),)),
                                          )
                                              :
                                          (Features.isSubscription)?  Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [

                                              Center(
                                                  child: Text(
                                                    S .of(context).buy_once,//'BUY ONCE',
                                                    style: TextStyle(
                                                      color: ColorCodes.whiteColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )),

                                            ],
                                          ) :
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Center(
                                                  child: Text(
                                                    S .of(context).add,//'ADD',
                                                    style: TextStyle(
                                                      color: Theme
                                                          .of(context)
                                                          .buttonColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                  new BorderRadius.only(
                                                    bottomRight:
                                                    const Radius.circular(3),
                                                    topRight:
                                                    const Radius.circular(3),
                                                  ),
                                                ),
                                                height: 40,
                                                width: 30,
                                                child: Icon(
                                                  Icons.add,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    else
                                      return Container(
                                        child: Row(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  _isAddToCart = true;
                                                  incrementToCart(varQty - 1);
                                                });
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color:(Features.isSubscription)?Color(0xFFFFDBE9): Theme
                                                          .of(context)
                                                          .primaryColor,
                                                    ),
                                                    borderRadius:
                                                    new BorderRadius.only(
                                                      bottomLeft:
                                                      const Radius.circular(
                                                          3),
                                                      topLeft:
                                                      const Radius.circular(
                                                          3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "-",
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: (Features.isSubscription)?ColorCodes.blackColor:Theme
                                                            .of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            Expanded(
                                              child: _isAddToCart ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: (Features.isSubscription)?Color(0xFFFFDBE9):Theme
                                                      .of(context)
                                                      .primaryColor,
                                                ),
                                                height: 40,
                                                width: 30,
                                                padding: EdgeInsets.only(
                                                    left: 5.0,
                                                    top: 10.0,
                                                    right: 5.0,
                                                    bottom: 10.0),
                                                child: Center(
                                                  child: SizedBox(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      child: new CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        valueColor: new AlwaysStoppedAnimation<
                                                            Color>(
                                                            Colors.white),)),
                                                ),
                                              )
                                                  :
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: (Features.isSubscription)?ColorCodes.whiteColor:Theme
                                                        .of(context)
                                                        .primaryColor,
                                                  ),
                                                  height: 40,
                                                  width: 30,
                                                  child: Center(
                                                    child: Text(
                                                      varQty.toString(),
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        color: (Features.isSubscription)?ColorCodes.blackColor:Colors.white,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (varQty < int.parse(varstock)) {
                                                  if (varQty < int.parse(varmaxitem)) {
                                                    setState(() {
                                                      _isAddToCart = true;
                                                    });
                                                    incrementToCart(varQty + 1);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: S .of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
                                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                                        backgroundColor: Colors.black87,
                                                        textColor: Colors.white);
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: S .of(context).sorry_outofstock,//"Sorry, Out of Stock!",
                                                      fontSize: MediaQuery.of(context).textScaleFactor *13,
                                                      backgroundColor:
                                                      Colors.black87,
                                                      textColor: Colors.white);
                                                }
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color: (Features.isSubscription)?Color(0xFFFFDBE9):Theme
                                                          .of(context)
                                                          .primaryColor,
                                                    ),
                                                    borderRadius:
                                                    new BorderRadius.only(
                                                      bottomRight:
                                                      const Radius.circular(
                                                          3),
                                                      topRight:
                                                      const Radius.circular(
                                                          3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+",
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: (Features.isSubscription)?ColorCodes.blackColor:Theme
                                                            .of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 10)
                    ],
                  ),
                ),
              );
            });

          })
          .then((_) => setState(() {
        variddata.clear();
        variationdisplaydata.clear();
      }));
    }*/



   /* Widget showoptions1() {

      showModalBottomSheet<dynamic>(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return Wrap(
              children: [
                StatefulBuilder(builder: (context, setState) {
                  return Container(
                    // height: 400,
                    child: Padding(

                      padding: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 28),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(widget.itemdata!.itemName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Image(
                                    height: 40,
                                    width: 40,
                                    image: AssetImage(
                                        Images.bottomsheetcancelImg),
                                    color: Colors.black,
                                  )),
                            ],
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            // height: 200,
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: variationdisplaydata.length,
                                  itemBuilder: (_, i) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () async {
                                        setState(() {
                                          varid = itemvarData[i].varid;
                                          varname = itemvarData[i].varname;
                                          unit=itemvarData[i].unit;
                                          varmrp = itemvarData[i].varmrp;
                                          varprice = itemvarData[i].varprice;
                                          varmemberprice = itemvarData[i].varmemberprice;
                                          varminitem = itemvarData[i].varminitem;
                                          varmaxitem = itemvarData[i].varmaxitem;
                                          varLoyalty = itemvarData[i].varLoyalty;
                                          varQty = (itemvarData[i].varQty >= 0) ? itemvarData[i].varQty : int.parse(itemvarData[i].varminitem);
                                          varstock = itemvarData[i].varstock;
                                          discountDisplay = itemvarData[i].discountDisplay;
                                          memberpriceDisplay = itemvarData[i].membershipDisplay;
                                          if (_checkmembership) {
                                            if (varmemberprice.toString() == '-' || double.parse(varmemberprice) <= 0) {
                                              if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                                margins = "0";
                                              } else {
                                                var difference = (double.parse(varmrp) - double.parse(varprice));
                                                var profit = difference / double.parse(varmrp);
                                                margins = profit * 100;

                                                //discount price rounding
                                                margins = num.parse(margins.toStringAsFixed(0));
                                                margins = margins.toString();
                                              }
                                            } else {
                                              var difference = (double.parse(varmrp) - double.parse(varmemberprice));
                                              var profit = difference / double.parse(varmrp);
                                              margins = profit * 100;

                                              //discount price rounding
                                              margins = num.parse(margins.toStringAsFixed(0));
                                              margins = margins.toString();
                                            }
                                          } else {
                                            if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {margins = "0";
                                            } else {
                                              var difference = (double.parse(varmrp) - double.parse(varprice));
                                              var profit = difference / double.parse(varmrp);
                                              margins = profit * 100;

                                              //discount price rounding
                                              margins = num.parse(margins.toStringAsFixed(0));
                                              margins = margins.toString();
                                            }
                                          }
                                          if (widget.fromScreen == "home_screen") {
                                            multiimage = Provider.of<SellingItemsList>(context, listen: false).findByfeaturedimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          }else if (widget.fromScreen == "singleproduct_screen") {
                                            multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIditemsnewimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          } else if (widget.fromScreen == "searchitem_screen") {
                                            multiimage = Provider.of<ItemsList>(context, listen: false).findBysearchimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          } else if (widget.fromScreen == "notavailableProduct") {
                                            multiimage = Provider.of<SellingItemsList>(context, listen: false).findBySwapimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          }else if (widget.fromScreen == "sellingitem_screen") {
                                            multiimage = Provider.of<SellingItemsList>(context, listen: false).findByIdallimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          } else if (widget.fromScreen == "item_screen") {
                                            multiimage = Provider.of<ItemsList>(context, listen: false).findByIditemimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          } else if (widget.fromScreen == "shoppinglistitem_screen") {
                                            multiimage = Provider.of<BrandItemsList>(context, listen: false).findByshoppingimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          } else if (widget.fromScreen == "brands_screen") {
                                            multiimage = Provider.of<BrandItemsList>(context, listen: false).findBybrandimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          }else if(widget.fromScreen == "not_product_screen"){
                                            multiimage = Provider.of<NotificationItemsList>(context, listen: false,).findBynotproductimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          } else if (widget.fromScreen == "Forget") {
                                            multiimage = Provider.of<SellingItemsList>(context, listen: false).findByForgotimage(varid);
                                            _displayimg = multiimage[0].imageUrl;
                                          }

                                          Future.delayed(Duration(seconds: 0), () {
                                            dialogdisplay = true;
                                            for (int j = 0; j < variddata.length; j++) {
                                              if (i == j) {
                                                setState(() {
                                                  checkBoxdata[i] = true;
                                                  containercolor[i] = 0xFFFFFFFF;
                                                  textcolor[i] = 0xFF2966A2;
                                                  iconcolor[i] = 0xFF2966A2;
                                                });
                                              } else {
                                                setState(() {
                                                  checkBoxdata[j] = false;
                                                  containercolor[j] = 0xFFFFFFFF;
                                                  iconcolor[j] = 0xFFC1C1C1;
                                                  textcolor[j] = 0xFF060606;
                                                });
                                              }
                                            }
                                          });
                                          // Navigator.of(context).pop(true);
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.only(right: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _checkmembership
                                                ? //membered usesr
                                            itemvarData[i].membershipDisplay
                                                ? RichText(
                                              text: TextSpan(
                                                style: TextStyle(fontSize: 14.0, color: itemvarData[i].varcolor,),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: varnamedata[i]+" "+unitdata[i]+
                                                        " - ",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Color(textcolor[i]),
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: IConstants.currencyFormat + varmemberpricedata[i] + " ",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Color(textcolor[i]),
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: IConstants.currencyFormat + varmrpdata[i],
                                                      style: TextStyle(color: Color(textcolor[i]),
                                                        decoration: TextDecoration.lineThrough,)),
                                                ],
                                              ),
                                            )
                                                : itemvarData[i].discountDisplay
                                                ? RichText(
                                              text: TextSpan(
                                                style: TextStyle(fontSize: 14.0, color: itemvarData[i].varcolor,),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: varnamedata[i]+" "+unitdata[i]+ " - ",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Color(textcolor[i]),
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text: IConstants.currencyFormat +
                                                        varpricedata[i] + " ",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Color(textcolor[i]),
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text: IConstants.currencyFormat + varmrpdata[i],
                                                      style:
                                                      TextStyle(
                                                        color: Color(textcolor[i]),
                                                        decoration:
                                                        TextDecoration.lineThrough,
                                                      )),
                                                ],
                                              ),
                                            )
                                                : new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color:
                                                  itemvarData[i]
                                                      .varcolor,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                    text: varnamedata[i]+" "+unitdata[i]+ " - ",
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color(textcolor[i]),
                                                    ),
                                                  ),
                                                  new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        " " +
                                                        varmrpdata[
                                                        i],
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Color(
                                                          textcolor[
                                                          i]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                                : itemvarData[i].discountDisplay
                                                ? RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: itemvarData[i]
                                                      .varcolor,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: varnamedata[i]+" "+unitdata[i]+
                                                        " - ",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Color(
                                                            textcolor[i]),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        varpricedata[
                                                        i] +
                                                        " ",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Color(
                                                            textcolor[i]),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                      IConstants.currencyFormat +
                                                          varmrpdata[
                                                          i],
                                                      style: TextStyle(
                                                        color: Color(
                                                            textcolor[i]),
                                                        decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                      )),
                                                ],
                                              ),
                                            )
                                                : new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: itemvarData[i]
                                                      .varcolor,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                    text: varnamedata[i]+" "+unitdata[i]+
                                                        " - ",
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color(
                                                          textcolor[i]),
                                                    ),
                                                  ),
                                                  new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        " " +
                                                        varmrpdata[i],
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color(
                                                          textcolor[i]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            handler(i),
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
                          if(Features.isSubscription)
                            (widget.subscribe == "0")?
                            (int.parse(varstock) <= 0)?
                            SizedBox(height: 30,):
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                      _dialogforSignIn();
                                    }
                                    else {
                                      (checkskip) ?
                                      Navigator.of(context).pushNamed(
                                        SignupSelectionScreen.routeName,
                                      ) :
                                      Navigator.of(context).pushNamed(
                                          SubscribeScreen.routeName,
                                          arguments: {
                                            "itemid": widget.id,
                                            "itemname": widget.title,
                                            "itemimg": widget.imageUrl,
                                            "varname": varname+unit,
                                            "varmrp":varmrp,
                                            "varprice":  _checkmembership ? varmemberprice :discountDisplay ?varprice:varmrp,
                                            "paymentMode": widget.paymentmode,
                                            "cronTime": widget.cronTime,
                                            "name": widget.name,
                                            "varid": varid.toString(),
                                            "brand": widget.brand
                                          }
                                      );
                                    }
                                  },
                                  child: Container(
                                      height: 40.0,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width - 76,
                                      decoration: new BoxDecoration(
                                          border: Border.all(color: Theme
                                              .of(context)
                                              .primaryColor),
                                          color: ColorCodes.whiteColor,
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight: const Radius.circular(2.0),
                                            bottomLeft: const Radius.circular(2.0),
                                            bottomRight: const Radius.circular(2.0),
                                          )),
                                      child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Center(
                                              child: Text(
                                                S .of(context).subscribe,//'SUBSCRIBE',
                                                style: TextStyle(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              )),
                                        ],
                                      )
                                  ),
                                ),
                              ],
                            ):
                            SizedBox.shrink(),
                          if(Features.isSubscription)
                            SizedBox(
                              height: 10,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              (int.parse(varstock) <= 0) ?
                              GestureDetector(
                                onTap: () async {
                                  if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                    _dialogforSignIn();
                                  }
                                  else {
                                    (checkskip ) ?
                                    Navigator.of(context).pushNamed(
                                      SignupSelectionScreen.routeName,
                                    ) :
                                    _notifyMe();
                                  }
                                  *//*setState(() {
                                    _isNotify = true;
                                  });
                                  //_notifyMe();
                                  int resposne = await Provider.of<BrandItemsList>(context, listen: false).notifyMe(widget.id,varid,widget.type);
                                  if(resposne == 200) {
                                    Fluttertoast.showToast(msg: "You will be notified via SMS/Push notification, when the product is available" ,
                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                        backgroundColor:
                                        Colors.black87,
                                        textColor: Colors.white);
                                    setState(() {
                                      _isNotify = false;
                                    });
                                  } else {
                                    Fluttertoast.showToast(msg: "Something went wrong" ,
                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                        backgroundColor:
                                        Colors.black87,
                                        textColor: Colors.white);
                                    setState(() {
                                      _isNotify = false;
                                    });
                                  }*//*
                                },
                                child: Container(
                                  height: 40.0,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width - 76,
                                  decoration: new BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      color: Colors.grey,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        topRight: const Radius.circular(2.0),
                                        bottomLeft: const Radius.circular(2.0),
                                        bottomRight: const Radius.circular(2.0),
                                      )),
                                  child:
                                  _isNotify ?
                                  Center(
                                    child: SizedBox(
                                        width: 20.0,
                                        height: 20.0,
                                        child: new CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor: new AlwaysStoppedAnimation<
                                              Color>(Colors.white),)),
                                  )
                                      :
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Center(
                                          child: Text(
                                            S .of(context).notify_me,//'Notify Me',
                                            *//*"ADD",*//*
                                            style: TextStyle(
                                              *//*fontWeight: FontWeight.w700,*//*
                                                color:
                                                Colors
                                                    .white *//*Colors.black87*//*),
                                            textAlign: TextAlign.center,
                                          )),
                                      Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius: new BorderRadius.only(
                                              topRight:
                                              const Radius.circular(2.0),
                                              bottomRight:
                                              const Radius.circular(2.0),
                                            )),
                                        height: 40,
                                        width: 25,
                                        child: Icon(
                                          Icons.add,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Container(
                                height: 40.0,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width - 76,
                                *//*(MediaQuery.of(context).size.width / 3) + 18,*//*
                                child: ValueListenableBuilder(
                                  valueListenable:
                                  Hive.box<Product>(productBoxName)
                                      .listenable(),
                                  builder: (context, Box<Product> box, _) {
                                    *//*if (box.values.length <= 0)*//* if(varQty <= 0)
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isAddToCart = true;
                                          });
                                          //addToCart(int.parse(itemvarData[0].varminitem));
                                          addToCart(int.parse(varminitem));
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: _isAddToCart ?
                                          Center(
                                            child: SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: new CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
                                          )
                                              :
                                          (Features.isSubscription)?
                                          Container(
                                              height: 50.0,
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                color: Theme
                                                    .of(context)
                                                    .primaryColor,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: _isAddToCart ?
                                              Center(
                                                child: SizedBox(
                                                    width: 20.0,
                                                    height: 20.0,
                                                    child: new CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
                                              )
                                                  :
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [

                                                  Center(
                                                      child: Text(
                                                        S .of(context).buy_once,//'BUY ONCE',
                                                        style: TextStyle(
                                                          color: ColorCodes.whiteColor,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      )),
                                                ],
                                              )
                                          ):
                                          Container(
                                            height: 50.0,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: _isAddToCart ?
                                            Center(
                                              child: SizedBox(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  child: new CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
                                            )
                                                :
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Center(
                                                    child: Text(
                                                      S .of(context).add,//'ADD',
                                                      style: TextStyle(
                                                        color: Theme
                                                            .of(context)
                                                            .buttonColor,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    )),
                                                Spacer(),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme
                                                        .of(context)
                                                        .primaryColor,
                                                    borderRadius:
                                                    new BorderRadius.only(
                                                      bottomRight:
                                                      const Radius.circular(3),
                                                      topRight:
                                                      const Radius.circular(3),
                                                    ),
                                                  ),
                                                  height: 40,
                                                  width: 30,
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    else
                                      return Container(
                                        child: Row(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  _isAddToCart = true;
                                                  incrementToCart(varQty - 1);
                                                });
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color: (Features.isSubscription)?Theme
                                                          .of(context)
                                                          .primaryColor:
                                                      Theme
                                                          .of(context)
                                                          .primaryColor,
                                                    ),
                                                    borderRadius:
                                                    new BorderRadius.only(
                                                      bottomLeft:
                                                      const Radius.circular(
                                                          3),
                                                      topLeft:
                                                      const Radius.circular(
                                                          3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "-",
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color:(Features.isSubscription)?Theme
                                                            .of(context)
                                                            .primaryColor: Theme
                                                            .of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            Expanded(
                                              child: _isAddToCart ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: (Features.isSubscription)?Theme
                                                      .of(context)
                                                      .primaryColor:Theme
                                                      .of(context)
                                                      .primaryColor,
                                                ),
                                                height: 40,
                                                width: 30,
                                                padding: EdgeInsets.only(
                                                    left: 5.0,
                                                    top: 10.0,
                                                    right: 5.0,
                                                    bottom: 10.0),
                                                child: Center(
                                                  child: SizedBox(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      child: new CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        valueColor: new AlwaysStoppedAnimation<
                                                            Color>(
                                                            Colors.white),)),
                                                ),
                                              )
                                                  :
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: (Features.isSubscription)?Theme
                                                        .of(context)
                                                        .primaryColor:Theme
                                                        .of(context)
                                                        .primaryColor,
                                                  ),
                                                  height: 40,
                                                  width: 30,
                                                  child: Center(
                                                    child: Text(
                                                      varQty.toString(),
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        color: (Features.isSubscription)?ColorCodes.whiteColor:Colors.white,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (varQty < int.parse(varstock)) {
                                                  if (varQty < int.parse(varmaxitem)) {
                                                    setState(() {
                                                      _isAddToCart = true;
                                                    });
                                                    incrementToCart(varQty + 1);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                        S .of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
                                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                                        backgroundColor:
                                                        Colors.black87,
                                                        textColor: Colors
                                                            .white);
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: S .of(context).sorry_outofstock,//"Sorry, Out of Stock!",
                                                      fontSize: MediaQuery.of(context).textScaleFactor *13,
                                                      backgroundColor:
                                                      Colors.black87,
                                                      textColor: Colors.white);
                                                }
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color: (Features.isSubscription)?Theme
                                                          .of(context)
                                                          .primaryColor:Theme
                                                          .of(context)
                                                          .primaryColor,
                                                    ),
                                                    borderRadius:
                                                    new BorderRadius.only(
                                                      bottomRight:
                                                      const Radius.circular(
                                                          3),
                                                      topRight:
                                                      const Radius.circular(
                                                          3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+",
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: (Features.isSubscription)?Theme
                                                            .of(context)
                                                            .primaryColor:Theme
                                                            .of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                          SizedBox(width: 10)
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          })
          .then((_) => setState(() {
        variddata.clear();
        variationdisplaydata.clear();
      }));
    }
    */
    showoptions1() {
      //print("from scrteen....show option..."+widget.fromScreen.toString());
      if(PrefUtils.prefs!.getString("membership") == "1"){
        _checkmembership = true;
      } else {
        _checkmembership = false;
        for (int i = 0; i < productBox.length; i++) {
          if (productBox[i].mode == "1") {
            _checkmembership = true;
          }
        }
      }

      (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
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
                  child:
                  (widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?
                  ItemVariation(searchdata: widget.storedsearchdata!,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
                    setState(() {
                      itemindex = i;
                      // Navigator.of(context).pop();
                    });
                  },fromscreen: "search_item_multivendor",):
                  ItemVariation(itemdata: widget.itemdata!,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
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
            return

              (widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?
              ItemVariation(searchdata: widget.storedsearchdata!,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
                setState(() {
                  itemindex = i;
                  // Navigator.of(context).pop();
                });
              },fromscreen: "search_item_multivendor"):
              ItemVariation(itemdata: widget.itemdata!,ismember: _checkmembership,selectedindex: itemindex,onselect: (i){
              setState(() {
                itemindex = i;
                // Navigator.of(context).pop();
              });
            },);
          })
          .then((_) => setState(() { }));
    }

    double margins;
    if(widget.fromScreen == "search_item_multivendor" && Features.ismultivendor){
       margins = (widget.storedsearchdata!.type == "1") ? Calculate().getmargin(
          widget.storedsearchdata!.mrp,
          store.userData.membership! == "0" || store.userData.membership! == "2"
              ?
          widget.storedsearchdata!.discointDisplay! ? widget.storedsearchdata!.price : widget
              .storedsearchdata!.mrp
              : widget.storedsearchdata!.membershipDisplay! ? widget.storedsearchdata!
              .membershipPrice : widget.storedsearchdata!.price) :
      Calculate().getmargin(widget.storedsearchdata!.priceVariation![itemindex].mrp.toString(),
          store.userData.membership! == "0" || store.userData.membership! == "2"
              ?
          widget.storedsearchdata!.priceVariation![itemindex].discointDisplay! ? widget
              .storedsearchdata!.priceVariation![itemindex].price : widget.storedsearchdata!
              .priceVariation![itemindex].mrp
              : widget.storedsearchdata!.priceVariation![itemindex].membershipDisplay!
              ? widget.storedsearchdata!.priceVariation![itemindex].membershipPrice
              : widget.storedsearchdata!.priceVariation![itemindex].price);
    }
    else {
       margins = (widget.itemdata!.type == "1") ? Calculate().getmargin(
          widget.itemdata!.mrp,
          store.userData.membership! == "0" || store.userData.membership! == "2"
              ?
          widget.itemdata!.discointDisplay! ? widget.itemdata!.price : widget
              .itemdata!.mrp
              : widget.itemdata!.membershipDisplay! ? widget.itemdata!
              .membershipPrice : widget.itemdata!.price) :
      Calculate().getmargin(widget.itemdata!.priceVariation![itemindex].mrp,
          store.userData.membership! == "0" || store.userData.membership! == "2"
              ?
          widget.itemdata!.priceVariation![itemindex].discointDisplay! ? widget
              .itemdata!.priceVariation![itemindex].price : widget.itemdata!
              .priceVariation![itemindex].mrp
              : widget.itemdata!.priceVariation![itemindex].membershipDisplay!
              ? widget.itemdata!.priceVariation![itemindex].membershipPrice
              : widget.itemdata!.priceVariation![itemindex].price);
    }

    if(_isWeb && !ResponsiveLayout.isSmallScreen(context)) {

      if (store.userData.membership! =="1") {
        setState(() {
          _checkmembership = true;
        });
      } else {
        setState(() {
          _checkmembership = false;
        });
        for (int i = 0; i < productBox.length; i++) {
          if (productBox[i].mode == "1") {
            setState(() {
              _checkmembership = true;
            });
          }
        }
      }

      return  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor?
           widget.storedsearchdata!.type=="1"?Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
          border: Border.all(color: ColorCodes.shimmercolor),
        ),
        margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0, right: 5),
        child: Column(
          children: [
            ItemBadge(
              outOfStock: widget.storedsearchdata!.stock!<=0?OutOfStock(singleproduct: false,):null,
              // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
              /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):SizedBox.shrink()),*/
              child: Align(
                alignment: Alignment.center,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if(widget.fromScreen == "sellingitem_screen") {
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.id.toString(),"productId": widget.storedsearchdata!.id!});

                      }
                      else{
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        //   notid: widget._notid,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.id.toString(),"productId": widget.storedsearchdata!.id!});
                      }
                      /*
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.itemdata!.id,
                                    "itemname": widget.itemdata!.itemName,
                                    "itemimg": widget.itemdata!.itemFeaturedImage,
                                    "eligibleforexpress": widget.itemdata!.eligibleForExpress,
                                    "delivery": widget.itemdata.delivery,
                                    "duration": widget.itemdata.duration,
                                    "durationType":widget.itemdata.deliveryDuration.durationType,
                                    "note":widget.itemdata.deliveryDuration.note,
                                    "fromScreen":widget.fromScreen,
                                  });*/
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.storedsearchdata!.itemFeaturedImage,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding:EdgeInsets.only(left: 10),
                  // width: (MediaQuery
                  //     .of(context)
                  //     .size
                  //     .width / 2) + 60,
                  child: Column(
                    children: [
                      Container(
                        // width: (MediaQuery
                        //     .of(context)
                        //     .size
                        //     .width / 4) + 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      widget.storedsearchdata!.brand!,
                                      style: TextStyle(
                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height:30,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        widget.storedsearchdata!.shop!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          //fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            /*  SizedBox(
                                height: 5,
                              ),*/
                              Text(
                                widget.storedsearchdata!.location!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                    //fontWeight: FontWeight.bold
                                    ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(Images.starimg,
                                        height: 12,
                                        width: 12,
                                        color: ColorCodes.darkthemeColor),
                                    SizedBox(width: 3,),
                                    Text(
                                      widget.storedsearchdata!.ratings!.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: ColorCodes.darkthemeColor),
                                    ),
                                    SizedBox(width: 15,),
                                    Icon(Icons.info, color: ColorCodes.lightGreyColor, size: 6),
                                    SizedBox(width: 15,),
                                    Text(
                                      widget.storedsearchdata!.distance!.toStringAsFixed(2) +
                                          " Km",
                                      style: TextStyle(
                                          fontSize: 11, color: ColorCodes.greyColord),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 40,
                                child: Text(
                                  widget.storedsearchdata!.itemName!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              Container(
                                  child: Row(
                                    children: <Widget>[
                                      /*    _checkmembership
                                          ?*/ Row(
                                          children: <Widget>[
                                            if(Features.isMembership)
                                              _checkmembership?Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image.asset(
                                                  Images.starImg,
                                                ),
                                              ):SizedBox.shrink(),
                                            new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                  new TextSpan(
                                                      text: Features.iscurrencyformatalign?
                                                      '${_checkmembership?widget.storedsearchdata!.membershipPrice:widget.storedsearchdata!.price} ' + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + '${_checkmembership?widget.storedsearchdata!.membershipPrice:widget.storedsearchdata!.price} ',
                                                      style: new TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                  new TextSpan(
                                                      text: widget.storedsearchdata!.price!=widget.storedsearchdata!.mrp?
                                                      Features.iscurrencyformatalign?
                                                      '${widget.storedsearchdata!.mrp} ' + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + '${widget.storedsearchdata!.mrp} ':"",
                                                      style: TextStyle(
                                                          decoration:
                                                          TextDecoration.lineThrough,
                                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15)),
                                                ],
                                              ),
                                            ),
                                          ]),
                                      if(widget.storedsearchdata!.eligibleForExpress == "0")
                                        Image.asset(Images.express,
                                          height: 20.0,
                                          width: 25.0,),
                                      Spacer(),
                                      if(Features.isLoyalty)
                                        if(double.parse(widget.storedsearchdata!.loyalty.toString()) > 0)
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Image.asset(Images.coinImg,
                                                  height: 15.0,
                                                  width: 20.0,),
                                                SizedBox(width: 4),
                                                Text(widget.storedsearchdata!.loyalty.toString()),
                                              ],
                                            ),
                                          ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              if(Features.netWeight && widget.storedsearchdata!.vegType == "fish")
                                Container(
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2) + 70,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            Features.iscurrencyformatalign?
                                            "Whole Uncut:" +" " +
                                                widget.storedsearchdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                                            "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                                widget.storedsearchdata!.salePrice! +" / "+ "500 G",
                                            style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      SizedBox(height: 3),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text("Gross Weight:" +" "+
                                                    /*'$weight '*/widget.storedsearchdata!.weight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("Net Weight:" +" "+
                                                    /*'$netWeight '*/widget.storedsearchdata!.netWeight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),


                            ],
                          )),
                      SizedBox(
                        width: 10,
                      ),

                    ],
                  ),
                ),
//                SizedBox(height: 10,),
                Column(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) + 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: (MediaQuery.of(context).size.width / 4) + 30,
                            padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                            child:  Container(
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
                              width: (MediaQuery.of(context).size.width / 4) + 30,
                              padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                              child: SizedBox.shrink(),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          if(ResponsiveLayout.isSmallScreen(context))
                            if(Features.isSubscription)
                              (widget.storedsearchdata!.eligibleForSubscription == "0")?
                              (widget.storedsearchdata!.stock!>=0)?
                              Container(
                                width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                    widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8)+20:
                                (MediaQuery.of(context).size.width / 7.5)+20 ,

                                child: GestureDetector(
                                  onTap: () async {
                                    if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                      _dialogforSignIn();
                                    }
                                    else {
                                      (checkskip) ?
                                      /* Navigator.of(context).pushNamed(
                                      SignupSelectionScreen.routeName,
                                    )*/
                                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push):
                                      /*            Navigator.of(context).pushNamed(
                                        SubscribeScreen.routeName,
                                        arguments: {
                                          "itemid": widget.itemdata!.id,
                                          "itemname": widget.itemdata!.itemName,
                                          "itemimg": widget.itemdata!.itemFeaturedImage,
                                          "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                                          "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                                          "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                                          "paymentMode": widget.itemdata!.paymentMode,
                                          "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                          "name": widget.itemdata!.subscriptionSlot![0].name,
                                          "varid":widget.itemdata!.priceVariation![itemindex].id,
                                          "brand": widget.itemdata!.brand
                                        }
                                    );*/
                                      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                                          qparms: {
                                            "itemid": widget.storedsearchdata!.id,
                                            "itemname": widget.storedsearchdata!.itemName,
                                            "itemimg": widget.storedsearchdata!.itemFeaturedImage,
                                            "varname": "",
                                            "varmrp":widget.storedsearchdata!.mrp,
                                            "varprice":  store.userData.membership! == "1" ? widget.storedsearchdata!.membershipPrice.toString() :widget.storedsearchdata!.discointDisplay! ?widget.storedsearchdata!.price.toString():widget.storedsearchdata!.mrp.toString(),
                                            "paymentMode": widget.storedsearchdata!.paymentMode,
                                            "cronTime": widget.storedsearchdata!.subscriptionSlot![0].cronTime,
                                            "name": widget.storedsearchdata!.subscriptionSlot![0].name,
                                            "varid":widget.storedsearchdata!.id,
                                            "brand": widget.storedsearchdata!.brand,
                                            "deliveriesarray": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                                            "daily":(  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                                            "dailyDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                                            "weekend": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                                            "weekendDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                                            "weekday": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                                            "weekdayDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                                            "custom": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                                            "customDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                                          });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Container(
                                        // padding:EdgeInsets.only(left:55,right:55),
                                          height: 30.0,
                                          width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                              widget.fromScreen == "home_screen" ||widget.fromScreen == "search_item" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8):
                                          (MediaQuery.of(context).size.width / 7.5) ,
                                          // width: (MediaQuery.of(context).size.width / 4) + 15,
                                          decoration: new BoxDecoration(
                                              border: Border.all(color: ColorCodes.primaryColor),
                                              color: ColorCodes.whiteColor,
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(2.0),
                                                topRight: const Radius.circular(2.0),
                                                bottomLeft: const Radius.circular(2.0),
                                                bottomRight: const Radius.circular(2.0),
                                              )),
                                          child:
                                          Center(
                                              child: Text(
                                                'SUBSCRIBE',
                                                style: TextStyle(
                                                  color: ColorCodes.primaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ))
                                      ),
                                      SizedBox(width: 10,),
                                    ],
                                  ),
                                ),
                              ):
                              SizedBox(height: 30,):
                              SizedBox(height: 30,),
                          if(ResponsiveLayout.isSmallScreen(context))
                            if(Features.isSubscription)
                              SizedBox(
                                height: 10,
                              ),

//                           (widget.itemdata!.priceVariation[itemindex].stock >= 0)
//                               ? Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child:  VxBuilder( mutations: {SetCartItem},
//                               builder: (context,GroceStore store,state){
//                                 final item =store.CartItemList;
//                                 int itemCount = 0;
//                                 if (item == null) {
//                                   return SizedBox(height: 0);
//                                 }
//                                 else{
//                                   item.forEach((element) {
//                                     if(element.varId == widget.itemdata!.priceVariation[itemindex].id) {
//                                       {
//                                         itemCount = int.parse(element.quantity);
//                                       }
//                                     }
//                                   });
//                                 }
//                                 widget.itemdata!.priceVariation[itemindex].quantity = itemCount;
//                               if (itemCount <= 0)
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         _isAddToCart = true;
//                                       });
//                                       //addToCart(int.parse(itemvarData[0].varminitem));
//                                      // addToCart(int.parse(varminitem));
//                                       addToCart(widget.itemdata!.priceVariation[itemindex],widget.itemdata);
//                                     },
//                                     child: Container(
//                                       height: 30.0,
//                                       width: (MediaQuery.of(context).size.width / 4) + 15,
//                                       decoration: new BoxDecoration(
//                                           color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                           borderRadius:
//                                           new BorderRadius.only(
//                                             topLeft:
//                                             const Radius.circular(2.0),
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomLeft:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       child: _isAddToCart ?
//                                       Center(
//                                         child: SizedBox(
//                                             width: 20.0,
//                                             height: 20.0,
//                                             child: new CircularProgressIndicator(
//                                               strokeWidth: 2.0,
//                                               valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                       )
//                                           :(Features.isSubscription)?
//                                       (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                       :Row(
//                                         mainAxisAlignment: MainAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                           :
//                                       Row(
//                                         children: [
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           Center(
//                                               child: Text(
//                                                 'ADD',
//                                                 style: TextStyle(
//                                                   color: Theme
//                                                       .of(context)
//                                                       .buttonColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )),
//                                           Spacer(),
//                                           Container(
//                                             decoration: BoxDecoration(
//                                                 color: ColorCodes.greenColor,//Color(0xff1BA130),
//                                                 borderRadius:
//                                                 new BorderRadius.only(
//                                                   topLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   topRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                 )),
//                                             height: 30,
//                                             width: 25,
//                                             child: Icon(
//                                               Icons.add,
//                                               size: 12,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 else
//                                   return Container(
//                                     child: Row(
//                                       children: <Widget>[
//                                         GestureDetector(
//                                           onTap: () async {
//                                             setState(() {
//                                              // _isAddToCart = true;
//                                              // incrementToCart(varQty - 1);
//                                               updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.decrement, widget.itemdata!.priceVariation[itemindex].id);
//                                             });
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomLeft: const Radius
//                                                         .circular(2.0),
//                                                     topLeft: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "-",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         Expanded(
//                                           child: _isAddToCart ?
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                             ),
//                                             height: 30,
//                                             padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
//                                             child: Center(
//                                               child: SizedBox(
//                                                   width: 20.0,
//                                                   height: 20.0,
//                                                   child: new CircularProgressIndicator(
//                                                     strokeWidth: 2.0,
//                                                     valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                             ),
//                                           )
//                                               :
//                                           Container(
// //                                            width: 40,
//                                               decoration: BoxDecoration(
//                                                 color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                               ),
//                                               height: 30,
//                                               child: Center(
//                                                 child: Text(
//                                                   varQty.toString(),
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.whiteColor:Theme
//                                                         .of(context)
//                                                         .buttonColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                            /* if (varQty < int.parse(varstock)) {
//                                               if (varQty < int.parse(varmaxitem)) {
//                                                 setState(() {
//                                                   _isAddToCart = true;
//                                                 });
//                                                 incrementToCart(varQty + 1);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     "Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor:
//                                                     Colors.black87,
//                                                     textColor:
//                                                     Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg:
//                                                   "Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor:
//                                                   Colors.black87,
//                                                   textColor: Colors.white);
//                                             }*/
//                                             if (widget.itemdata!.priceVariation[itemindex].quantity < widget.itemdata!.priceVariation[itemindex].stock) {
//                                               if (widget.itemdata!.priceVariation[itemindex].quantity < int.parse(widget.itemdata!.priceVariation[itemindex].maxItem)) {
//                                                 updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.increment, widget.itemdata!.priceVariation[itemindex].id);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     S .of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor: Colors.black87,
//                                                     textColor: Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg: S .of(context).sorry_outofstock,//"Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor: Colors.black87,
//                                                   textColor: Colors.white);
//                                             }
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.primaryColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomRight:
//                                                     const Radius
//                                                         .circular(2.0),
//                                                     topRight: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "+",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.blackColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//
//
//                               },
//                             ),
//                           )
//                               : Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child: GestureDetector(
//                               onTap: () {
//                                 if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
//                                   _dialogforSignIn();
//                                 }
//                                 else {
//                                   (checkskip ) ?
//                                   Navigator.of(context).pushNamed(
//                                     SignupSelectionScreen.routeName,
//                                   ) :
//                                   _notifyMe();
//                                 }
//                                 /* setState(() {
//                                 _isNotify = true;
//                               });
//                               _notifyMe();*/
//                                 // Fluttertoast.showToast(
//                                 //     msg: "You will be notified via SMS/Push notification, when the product is available",
//                                 //     /*"Out Of Stock",*/
//                                 //     fontSize: 12.0,
//                                 //     backgroundColor: Colors.black87,
//                                 //     textColor: Colors.white);
//                               },
//                               child: Container(
//                                 height: 30.0,
//                                 width: (MediaQuery.of(context).size.width / 4) + 15,
//                                 decoration: new BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey,
//                                     borderRadius: new BorderRadius.only(
//                                       topLeft: const Radius.circular(2.0),
//                                       topRight: const Radius.circular(2.0),
//                                       bottomLeft: const Radius.circular(2.0),
//                                       bottomRight: const Radius.circular(2.0),
//                                     )),
//                                 child:
//                                 _isNotify ?
//                                 Center(
//                                   child: SizedBox(
//                                       width: 20.0,
//                                       height: 20.0,
//                                       child: new CircularProgressIndicator(
//                                         strokeWidth: 2.0,
//                                         valueColor: new AlwaysStoppedAnimation<
//                                             Color>(Colors.white),)),
//                                 )
//                                     :
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 10,
//                                     ),
//                                     Center(
//                                         child: Text(
//                                           'Notify Me',
//                                           /*"ADD",*/
//                                           style: TextStyle(
//                                             /*fontWeight: FontWeight.w700,*/
//                                               color:
//                                               Colors
//                                                   .white /*Colors.black87*/),
//                                           textAlign: TextAlign.center,
//                                         )),
//                                     Spacer(),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                           color: Colors.black12,
//                                           borderRadius: new BorderRadius.only(
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       height: 30,
//                                       width: 25,
//                                       child: Icon(
//                                         Icons.add,
//                                         size: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // height: 90.0,
                                  // width: Vx.isWeb?(widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "search_item")?
                                  // (MediaQuery.of(context).size.width / 5.5):
                                  // (MediaQuery.of(context).size.width / 6.9):
                                  // (MediaQuery.of(context).size.width / 5.5),
                                    child: CustomeStepper(searchstoredata:widget.storedsearchdata,from: "search_screen",checkmembership:_checkmembership,alignmnt: StepperAlignment.Vertical,height: (Features.isSubscription)?40:40,addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null,index:itemindex)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                !_checkmembership
                    ? widget.storedsearchdata!.membershipDisplay!
                    ? SizedBox(height: 12,)
                    : SizedBox(height: 12,)
                    : SizedBox(height: 12,),

                if(ResponsiveLayout.isSmallScreen(context))
                  if(Features.isMembership)
                    (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                        widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?
                    Container(
                      width: (MediaQuery.of(context).size.width / 4) + 30,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:  !_checkmembership
                          ? widget.storedsearchdata!.membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          if(!PrefUtils.prefs!.containsKey("apikey")) {
                            if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                context)) {
                              LoginWeb(context, result: (sucsess) {
                                if (sucsess) {
                                  Navigator.of(context).pop();
                                  /*Navigator.pushNamedAndRemoveUntil(
                                    context, HomeScreen.routeName, (
                                    route) => false);*/
                                  Navigation(context, navigatore: NavigatoreTyp.homenav);
                                } else {
                                  Navigator.of(context).pop();
                                }
                              });
                            } else {
                              /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            );*/
                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                            }
                          }
                          else{
                            /* Navigator.of(context).pushNamed(
                            MembershipScreen.routeName,
                          );*/
                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                          }
                        },
                        child: Container(
                          height: 23,
                          decoration: BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  Features.iscurrencyformatalign?
                                  widget.storedsearchdata!.membershipPrice.toString() +  IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.storedsearchdata!.membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
                        :
                    Container(
                      width: (MediaQuery.of(context).size.width/5.2),
                      child: !_checkmembership
                          ? widget.storedsearchdata!.membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
                          _dialogforSignIn() :
                          (checkskip && !_isWeb)?
                          /*Navigator.of(context).pushReplacementNamed(
                            SignupSelectionScreen.routeName)*/
                          Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                              :/*Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );*/
                          Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                        },
                        //                   child: Padding(
                        // padding: EdgeInsets.all(10),
                        child: Container(
                          height: 23,
                          // padding: EdgeInsets.only(left: 10),
                          width: (MediaQuery.of(context).size.width/5.2),

                          decoration:
                          BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
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
                                  Features.iscurrencyformatalign?
                                  widget.storedsearchdata!.membershipPrice.toString() + IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.storedsearchdata!.membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12, color: Colors.black)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
              ],
            ),
          ],
        ),
      ):
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
          border: Border.all(color: ColorCodes.shimmercolor),
        ),
        margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0, right: 5),
        child: Column(
          children: [
            ItemBadge(
              outOfStock: widget.storedsearchdata!.priceVariation![itemindex].stock!<=0?OutOfStock(singleproduct: false,):null,
              // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
              /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):SizedBox.shrink()),*/
              child: Align(
                alignment: Alignment.center,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if(widget.fromScreen == "sellingitem_screen") {
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
                      }
                      else{
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        //   notid: widget._notid,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
                      }
                      /*
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.itemdata!.id,
                                    "itemname": widget.itemdata!.itemName,
                                    "itemimg": widget.itemdata!.itemFeaturedImage,
                                    "eligibleforexpress": widget.itemdata!.eligibleForExpress,
                                    "delivery": widget.itemdata.delivery,
                                    "duration": widget.itemdata.duration,
                                    "durationType":widget.itemdata.deliveryDuration.durationType,
                                    "note":widget.itemdata.deliveryDuration.note,
                                    "fromScreen":widget.fromScreen,
                                  });*/
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.storedsearchdata!.priceVariation![itemindex].images!.length<=0?widget.storedsearchdata!.itemFeaturedImage:widget.storedsearchdata!.priceVariation![itemindex].images![0].image,
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
            /*Container(
                width: (MediaQuery.of(context).size.width / 3) + 10,
                child: Column(
                  children: [
                    (_checkmargin)?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 5.0),
                          padding: EdgeInsets.all(3.0),
                          // color: Theme.of(context).accentColor,
                          *//* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                3.0),
                            color: ColorCodes.checkmarginColor, //Color(0xff6CBB3C),
                          ),*//*
                          constraints: BoxConstraints(
                            minWidth: 28,
                            minHeight: 18,
                          ),
                          child: Text(
                            margins + S .of(context).off,//"% OFF",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorCodes.greenColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ):SizedBox(height: 24,),
                    SizedBox(
                      height: 10,
                    ),

                  ],
                )),
            Container(
              padding: EdgeInsets.only(top: 0),
              // width: (MediaQuery
              //     .of(context)
              //     .size
              //     .width / 2) - 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !_isStock
                      ? Consumer<Calculations>(
                    builder: (_, cart, ch) =>
                        BadgeOfStock(
                          child: ch,
                          value: margins,
                          singleproduct: false,
                        ),
                    child: GestureDetector(
                      onTap: () {
                        navigatetoSingelproductscreen(context,widget.returnparm,
                            duration: widget.duration,
                            delivery: widget.delivery,
                            durationType: widget.durationType,
                            note: widget.note,
                            eligibleforexpress: widget.eligibleforexpress,
                            fromScreen: widget.fromScreen,
                            id: widget.id,
                            imageUrl: widget.imageUrl,
                            itemvarData:itemvarData,
                            title:widget.title );
                      },
                      child: CachedNetworkImage(
                        imageUrl: *//*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                        placeholder: (context, url) =>
                            Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            ),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.defaultProductImg,
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        ),
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      navigatetoSingelproductscreen(context,widget.returnparm,
                          duration: widget.duration,
                          delivery: widget.delivery,
                          durationType: widget.durationType,
                          eligibleforexpress: widget.eligibleforexpress,
                          fromScreen: widget.fromScreen,
                          id: widget.id,
                          note: widget.note,
                          imageUrl: widget.imageUrl,
                          itemvarData:itemvarData,
                          title:widget.title );
                    },
                    child: CachedNetworkImage(
                      imageUrl:*//* (widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                      placeholder: (context, url) =>
                          Image.asset(
                            Images.defaultProductImg,
                            width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          ),
                      errorWidget: (context, url, error) => Image.asset(
                        Images.defaultProductImg,
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      ),
                      width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),*/
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding:EdgeInsets.only(left: 10),
                  // width: (MediaQuery
                  //     .of(context)
                  //     .size
                  //     .width / 2) + 60,
                  child: Column(
                    children: [
                      Container(
                        // width: (MediaQuery
                        //     .of(context)
                        //     .size
                        //     .width / 4) + 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      widget.itemdata!.brand!,
                                      style: TextStyle(
                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),*/
                              Container(
                                height:30,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        widget.storedsearchdata!.shop!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          //fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              /*SizedBox(
                                height: 5,
                              ),*/
                              Text(
                                widget.storedsearchdata!.location!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                    //fontWeight: FontWeight.bold
                                    ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(Images.starimg,
                                        height: 12,
                                        width: 12,
                                        color: ColorCodes.darkthemeColor),
                                    SizedBox(width: 3,),
                                    Text(
                                      widget.storedsearchdata!.ratings!.toStringAsFixed(2),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: ColorCodes.darkthemeColor),
                                    ),
                                    SizedBox(width: 15,),
                                    Icon(Icons.info, color: ColorCodes.lightGreyColor, size: 6),
                                    SizedBox(width: 15,),
                                    Text(
                                      widget.storedsearchdata!.distance!.toStringAsFixed(2) +
                                          " Km",
                                      style: TextStyle(
                                          fontSize: 11, color: ColorCodes.greyColord),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: Text(
                                        widget.storedsearchdata!.itemName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Features.isSubscription && widget.storedsearchdata!.eligibleForSubscription=="0"?
                                  Container(
                                    height:40,
                                    width: 85,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:0,right:5.0),
                                      child: CustomeStepper(priceVariation:widget.itemdata!.priceVariation![itemindex],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Subscribe",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null, index: itemindex),
                                    ),
                                  ):SizedBox.shrink(),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              Container(
                                  child: Row(
                                    children: <Widget>[
                                      /*    _checkmembership
                                          ?*/ Row(
                                          children: <Widget>[
                                            if(Features.isMembership)
                                              _checkmembership?Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image.asset(
                                                  Images.starImg,
                                                ),
                                              ):SizedBox.shrink(),
                                            new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                  new TextSpan(
                                                      text: Features.iscurrencyformatalign?
                                                      '${_checkmembership?widget.storedsearchdata!.priceVariation![itemindex].membershipPrice:widget.storedsearchdata!.priceVariation![itemindex].price} ' + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + '${_checkmembership?widget.storedsearchdata!.priceVariation![itemindex].membershipPrice:widget.storedsearchdata!.priceVariation![itemindex].price} ',
                                                      style: new TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                  new TextSpan(
                                                      text: widget.storedsearchdata!.priceVariation![itemindex].price!=widget.storedsearchdata!.priceVariation![itemindex].mrp?
                                                      Features.iscurrencyformatalign?
                                                      '${widget.storedsearchdata!.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + '${widget.storedsearchdata!.priceVariation![itemindex].mrp} ':"",
                                                      style: TextStyle(
                                                          decoration:
                                                          TextDecoration.lineThrough,
                                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15)),
                                                ],
                                              ),
                                            ),
                                          ]),
                                      /*      widget.itemdata!.priceVariation[itemindex].membershipDisplay
                                              ? new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                new TextSpan(
                                                    text: IConstants.currencyFormat +
                                                        *//*'$varmemberprice '*//*widget.itemdata!.priceVariation[itemindex].membershipPrice.toString(),
                                                    style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      Colors.black,
                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        *//*'$varmrp '*//*widget.itemdata!.priceVariation[itemindex].mrp.toString(),
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                    )),
                                              ],
                                            ),
                                          )
                                              : discountDisplay
                                              ? new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: IConstants.currencyFormat +
                                                        '$varprice ',
                                                    style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .black,
                                                      fontSize:
                                                      ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        '$varmrp ',
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                    )),
                                              ],
                                            ),
                                          )
                                              : new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        '$varmrp ',
                                                    style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .black,
                                                      fontSize:
                                                      ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                          : discountDisplay
                                          ? new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text: IConstants.currencyFormat +
                                                    '$varprice ',
                                                style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                            new TextSpan(
                                                text: IConstants.currencyFormat +
                                                    '$varmrp ',
                                                style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                )),
                                          ],
                                        ),
                                      )
                                          : new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text: IConstants.currencyFormat +
                                                    '$varmrp ',
                                                style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                          ],
                                        ),
                                      ),*/
                                      if(widget.storedsearchdata!.eligibleForExpress == "0")
                                        Image.asset(Images.express,
                                          height: 20.0,
                                          width: 25.0,),
                                      Spacer(),
                                      if(Features.isLoyalty)
                                        if(double.parse(widget.storedsearchdata!.priceVariation![itemindex].loyalty.toString()) > 0)
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Image.asset(Images.coinImg,
                                                  height: 15.0,
                                                  width: 20.0,),
                                                SizedBox(width: 4),
                                                Text(widget.storedsearchdata!.priceVariation![itemindex].loyalty.toString()),
                                              ],
                                            ),
                                          ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              if(Features.netWeight && widget.storedsearchdata!.vegType == "fish")
                                Container(
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2) + 70,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            Features.iscurrencyformatalign?
                                            "Whole Uncut:" +" " +
                                                widget.storedsearchdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                                            "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                                widget.storedsearchdata!.salePrice! +" / "+ "500 G",
                                            style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      SizedBox(height: 3),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text("Gross Weight:" +" "+
                                                    /*'$weight '*/widget.storedsearchdata!.priceVariation![itemindex].weight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("Net Weight:" +" "+
                                                    /*'$netWeight '*/widget.storedsearchdata!.priceVariation![itemindex].netWeight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),


                            ],
                          )),
                      SizedBox(
                        width: 10,
                      ),

                    ],
                  ),
                ),
//                SizedBox(height: 10,),
                Column(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) + 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: (MediaQuery.of(context).size.width / 4) + 30,
                            padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                            child: ( widget.storedsearchdata!.priceVariation!.length > 1)
                                ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  //isweb
                                  // showoptions();
                                  showoptions1();
                                });

                              },
                              child: Container(
                                height: 30,
                                width: (MediaQuery.of(context).size.width / 4) + 30,
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
                                    /* Container(
                                      //width: (MediaQuery.of(context).size.width /2)+20,
                                      decoration: BoxDecoration(
                                          *//*border: Border.all(
                                            color: ColorCodes.greenColor,),*//*
                                          color: ColorCodes.varcolor,
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            bottomLeft: const Radius.circular(2.0),
                                          )),
                                      height: 30,
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 4.5, 0.0, 4.5),
                                      child:*/ Text(
                                      //"$varname"+" "+"$unit",
                                      "${widget.storedsearchdata!.priceVariation![itemindex].variationName}"+" "+"${widget.storedsearchdata!.priceVariation![itemindex].unit}",
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
                              width: (MediaQuery.of(context).size.width / 4) + 30,
                              padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                              child: Text(
                                "${widget.storedsearchdata!.priceVariation![itemindex].variationName}"+" "+"${widget.storedsearchdata!.priceVariation![itemindex].unit}",
                                style:
                                TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          if(ResponsiveLayout.isSmallScreen(context))
                            if(Features.isSubscription)
                              (widget.storedsearchdata!.eligibleForSubscription == "0")?
                              (widget.storedsearchdata!.priceVariation![itemindex].stock!>=0)?
                              Container(
                                width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                    widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8)+20:
                                (MediaQuery.of(context).size.width / 7.5)+20 ,

                                child: GestureDetector(
                                  onTap: () async {
                                    if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                      _dialogforSignIn();
                                    }
                                    else {
                                      (checkskip) ?
                                      /* Navigator.of(context).pushNamed(
                                      SignupSelectionScreen.routeName,
                                    )*/
                                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push):
                                      /*            Navigator.of(context).pushNamed(
                                        SubscribeScreen.routeName,
                                        arguments: {
                                          "itemid": widget.itemdata!.id,
                                          "itemname": widget.itemdata!.itemName,
                                          "itemimg": widget.itemdata!.itemFeaturedImage,
                                          "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                                          "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                                          "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                                          "paymentMode": widget.itemdata!.paymentMode,
                                          "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                          "name": widget.itemdata!.subscriptionSlot![0].name,
                                          "varid":widget.itemdata!.priceVariation![itemindex].id,
                                          "brand": widget.itemdata!.brand
                                        }
                                    );*/
                                      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                                          qparms: {
                                            "itemid": widget.storedsearchdata!.id,
                                            "itemname": widget.storedsearchdata!.itemName,
                                            "itemimg": widget.storedsearchdata!.itemFeaturedImage,
                                            "varname": widget.storedsearchdata!.priceVariation![itemindex].variationName!+widget.storedsearchdata!.priceVariation![itemindex].unit!,
                                            "varmrp":widget.storedsearchdata!.priceVariation![itemindex].mrp,
                                            "varprice":  store.userData.membership! == "1" ? widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString() :widget.storedsearchdata!.priceVariation![itemindex].discointDisplay! ?widget.storedsearchdata!.priceVariation![itemindex].price.toString():widget.storedsearchdata!.priceVariation![itemindex].mrp.toString(),
                                            "paymentMode": widget.storedsearchdata!.paymentMode,
                                            "cronTime": widget.storedsearchdata!.subscriptionSlot![0].cronTime,
                                            "name": widget.storedsearchdata!.subscriptionSlot![0].name,
                                            "varid":widget.storedsearchdata!.priceVariation![itemindex].id,
                                            "brand": widget.storedsearchdata!.brand,
                                            "deliveriesarray": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                                            "daily":(  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                                            "dailyDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                                            "weekend": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                                            "weekendDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                                            "weekday": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                                            "weekdayDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                                            "custom": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                                            "customDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,});
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Container(
                                        // padding:EdgeInsets.only(left:55,right:55),
                                          height: 30.0,
                                          width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                              widget.fromScreen == "home_screen" ||widget.fromScreen == "search_item" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8):
                                          (MediaQuery.of(context).size.width / 7.5) ,
                                          // width: (MediaQuery.of(context).size.width / 4) + 15,
                                          decoration: new BoxDecoration(
                                              border: Border.all(color: ColorCodes.primaryColor),
                                              color: ColorCodes.whiteColor,
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(2.0),
                                                topRight: const Radius.circular(2.0),
                                                bottomLeft: const Radius.circular(2.0),
                                                bottomRight: const Radius.circular(2.0),
                                              )),
                                          child:
                                          Center(
                                              child: Text(
                                                'SUBSCRIBE',
                                                style: TextStyle(
                                                  color: ColorCodes.primaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ))
                                      ),
                                      SizedBox(width: 10,),
                                    ],
                                  ),
                                ),
                              ):
                              SizedBox(height: 30,):
                              SizedBox(height: 30,),
                          if(ResponsiveLayout.isSmallScreen(context))
                            if(Features.isSubscription)
                              SizedBox(
                                height: 10,
                              ),

//                           (widget.itemdata!.priceVariation[itemindex].stock >= 0)
//                               ? Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child:  VxBuilder( mutations: {SetCartItem},
//                               builder: (context,GroceStore store,state){
//                                 final item =store.CartItemList;
//                                 int itemCount = 0;
//                                 if (item == null) {
//                                   return SizedBox(height: 0);
//                                 }
//                                 else{
//                                   item.forEach((element) {
//                                     if(element.varId == widget.itemdata!.priceVariation[itemindex].id) {
//                                       {
//                                         itemCount = int.parse(element.quantity);
//                                       }
//                                     }
//                                   });
//                                 }
//                                 widget.itemdata!.priceVariation[itemindex].quantity = itemCount;
//                               if (itemCount <= 0)
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         _isAddToCart = true;
//                                       });
//                                       //addToCart(int.parse(itemvarData[0].varminitem));
//                                      // addToCart(int.parse(varminitem));
//                                       addToCart(widget.itemdata!.priceVariation[itemindex],widget.itemdata);
//                                     },
//                                     child: Container(
//                                       height: 30.0,
//                                       width: (MediaQuery.of(context).size.width / 4) + 15,
//                                       decoration: new BoxDecoration(
//                                           color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                           borderRadius:
//                                           new BorderRadius.only(
//                                             topLeft:
//                                             const Radius.circular(2.0),
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomLeft:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       child: _isAddToCart ?
//                                       Center(
//                                         child: SizedBox(
//                                             width: 20.0,
//                                             height: 20.0,
//                                             child: new CircularProgressIndicator(
//                                               strokeWidth: 2.0,
//                                               valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                       )
//                                           :(Features.isSubscription)?
//                                       (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                       :Row(
//                                         mainAxisAlignment: MainAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                           :
//                                       Row(
//                                         children: [
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           Center(
//                                               child: Text(
//                                                 'ADD',
//                                                 style: TextStyle(
//                                                   color: Theme
//                                                       .of(context)
//                                                       .buttonColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )),
//                                           Spacer(),
//                                           Container(
//                                             decoration: BoxDecoration(
//                                                 color: ColorCodes.greenColor,//Color(0xff1BA130),
//                                                 borderRadius:
//                                                 new BorderRadius.only(
//                                                   topLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   topRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                 )),
//                                             height: 30,
//                                             width: 25,
//                                             child: Icon(
//                                               Icons.add,
//                                               size: 12,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 else
//                                   return Container(
//                                     child: Row(
//                                       children: <Widget>[
//                                         GestureDetector(
//                                           onTap: () async {
//                                             setState(() {
//                                              // _isAddToCart = true;
//                                              // incrementToCart(varQty - 1);
//                                               updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.decrement, widget.itemdata!.priceVariation[itemindex].id);
//                                             });
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomLeft: const Radius
//                                                         .circular(2.0),
//                                                     topLeft: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "-",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         Expanded(
//                                           child: _isAddToCart ?
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                             ),
//                                             height: 30,
//                                             padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
//                                             child: Center(
//                                               child: SizedBox(
//                                                   width: 20.0,
//                                                   height: 20.0,
//                                                   child: new CircularProgressIndicator(
//                                                     strokeWidth: 2.0,
//                                                     valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                             ),
//                                           )
//                                               :
//                                           Container(
// //                                            width: 40,
//                                               decoration: BoxDecoration(
//                                                 color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                               ),
//                                               height: 30,
//                                               child: Center(
//                                                 child: Text(
//                                                   varQty.toString(),
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.whiteColor:Theme
//                                                         .of(context)
//                                                         .buttonColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                            /* if (varQty < int.parse(varstock)) {
//                                               if (varQty < int.parse(varmaxitem)) {
//                                                 setState(() {
//                                                   _isAddToCart = true;
//                                                 });
//                                                 incrementToCart(varQty + 1);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     "Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor:
//                                                     Colors.black87,
//                                                     textColor:
//                                                     Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg:
//                                                   "Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor:
//                                                   Colors.black87,
//                                                   textColor: Colors.white);
//                                             }*/
//                                             if (widget.itemdata!.priceVariation[itemindex].quantity < widget.itemdata!.priceVariation[itemindex].stock) {
//                                               if (widget.itemdata!.priceVariation[itemindex].quantity < int.parse(widget.itemdata!.priceVariation[itemindex].maxItem)) {
//                                                 updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.increment, widget.itemdata!.priceVariation[itemindex].id);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     S .of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor: Colors.black87,
//                                                     textColor: Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg: S .of(context).sorry_outofstock,//"Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor: Colors.black87,
//                                                   textColor: Colors.white);
//                                             }
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.primaryColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomRight:
//                                                     const Radius
//                                                         .circular(2.0),
//                                                     topRight: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "+",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.blackColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//
//
//                               },
//                             ),
//                           )
//                               : Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child: GestureDetector(
//                               onTap: () {
//                                 if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
//                                   _dialogforSignIn();
//                                 }
//                                 else {
//                                   (checkskip ) ?
//                                   Navigator.of(context).pushNamed(
//                                     SignupSelectionScreen.routeName,
//                                   ) :
//                                   _notifyMe();
//                                 }
//                                 /* setState(() {
//                                 _isNotify = true;
//                               });
//                               _notifyMe();*/
//                                 // Fluttertoast.showToast(
//                                 //     msg: "You will be notified via SMS/Push notification, when the product is available",
//                                 //     /*"Out Of Stock",*/
//                                 //     fontSize: 12.0,
//                                 //     backgroundColor: Colors.black87,
//                                 //     textColor: Colors.white);
//                               },
//                               child: Container(
//                                 height: 30.0,
//                                 width: (MediaQuery.of(context).size.width / 4) + 15,
//                                 decoration: new BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey,
//                                     borderRadius: new BorderRadius.only(
//                                       topLeft: const Radius.circular(2.0),
//                                       topRight: const Radius.circular(2.0),
//                                       bottomLeft: const Radius.circular(2.0),
//                                       bottomRight: const Radius.circular(2.0),
//                                     )),
//                                 child:
//                                 _isNotify ?
//                                 Center(
//                                   child: SizedBox(
//                                       width: 20.0,
//                                       height: 20.0,
//                                       child: new CircularProgressIndicator(
//                                         strokeWidth: 2.0,
//                                         valueColor: new AlwaysStoppedAnimation<
//                                             Color>(Colors.white),)),
//                                 )
//                                     :
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 10,
//                                     ),
//                                     Center(
//                                         child: Text(
//                                           'Notify Me',
//                                           /*"ADD",*/
//                                           style: TextStyle(
//                                             /*fontWeight: FontWeight.w700,*/
//                                               color:
//                                               Colors
//                                                   .white /*Colors.black87*/),
//                                           textAlign: TextAlign.center,
//                                         )),
//                                     Spacer(),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                           color: Colors.black12,
//                                           borderRadius: new BorderRadius.only(
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       height: 30,
//                                       width: 25,
//                                       child: Icon(
//                                         Icons.add,
//                                         size: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // height: 90.0,
                                  // width: Vx.isWeb?(widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "search_item")?
                                  // (MediaQuery.of(context).size.width / 5.5):
                                  // (MediaQuery.of(context).size.width / 6.9):
                                  // (MediaQuery.of(context).size.width / 5.5),
                                    child: CustomeStepper(priceVariationSearch: widget.storedsearchdata!.priceVariation![itemindex],searchstoredata: widget.storedsearchdata,from: "search_screen",checkmembership:_checkmembership,alignmnt: StepperAlignment.Vertical,height: (Features.isSubscription)?40:40,addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null,index:itemindex)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                !_checkmembership
                    ? widget.storedsearchdata!.priceVariation![itemindex].membershipDisplay!
                    ? SizedBox(height: 12,)
                    : SizedBox(height: 12,)
                    : SizedBox(height: 12,),

                if(ResponsiveLayout.isSmallScreen(context))
                  if(Features.isMembership)
                    (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                        widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?
                    Container(
                      width: (MediaQuery.of(context).size.width / 4) + 30,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:  !_checkmembership
                          ? widget.storedsearchdata!.priceVariation![itemindex].membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          if(!PrefUtils.prefs!.containsKey("apikey")) {
                            if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                context)) {
                              LoginWeb(context, result: (sucsess) {
                                if (sucsess) {
                                  Navigator.of(context).pop();
                                  /*Navigator.pushNamedAndRemoveUntil(
                                    context, HomeScreen.routeName, (
                                    route) => false);*/
                                  Navigation(context, navigatore: NavigatoreTyp.homenav);
                                } else {
                                  Navigator.of(context).pop();
                                }
                              });
                            } else {
                              /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            );*/
                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                            }
                          }
                          else{
                            /* Navigator.of(context).pushNamed(
                            MembershipScreen.routeName,
                          );*/
                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                          }
                        },
                        child: Container(
                          height: 23,
                          decoration: BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  Features.iscurrencyformatalign?
                                  widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString() +  IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
                        :
                    Container(
                      width: (MediaQuery.of(context).size.width/5.2),
                      child: !_checkmembership
                          ? widget.storedsearchdata!.priceVariation![itemindex].membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
                          _dialogforSignIn() :
                          (checkskip && !_isWeb)?
                          /*Navigator.of(context).pushReplacementNamed(
                            SignupSelectionScreen.routeName)*/
                          Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                              :/*Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );*/
                          Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                        },
                        //                   child: Padding(
                        // padding: EdgeInsets.all(10),
                        child: Container(
                          height: 23,
                          // padding: EdgeInsets.only(left: 10),
                          width: (MediaQuery.of(context).size.width/5.2),

                          decoration:
                          BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
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
                                  Features.iscurrencyformatalign?
                                  widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12, color: Colors.black)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
              ],
            ),
          ],
        ),
      )
          :
      widget.itemdata!.type=="1"?Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
          border: Border.all(color: ColorCodes.shimmercolor),
        ),
        margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0, right: 5),
        child: Column(
          children: [
            ItemBadge(
              outOfStock: widget.itemdata!.stock!<=0?OutOfStock(singleproduct: false,):null,
              // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
              /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):SizedBox.shrink()),*/
              child: Align(
                alignment: Alignment.center,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if(widget.fromScreen == "sellingitem_screen") {
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.id.toString(),"productId": widget.itemdata!.id!});

                      }
                      else{
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        //   notid: widget._notid,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.id.toString(),"productId": widget.itemdata!.id!});
                      }
                      /*
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.itemdata!.id,
                                    "itemname": widget.itemdata!.itemName,
                                    "itemimg": widget.itemdata!.itemFeaturedImage,
                                    "eligibleforexpress": widget.itemdata!.eligibleForExpress,
                                    "delivery": widget.itemdata.delivery,
                                    "duration": widget.itemdata.duration,
                                    "durationType":widget.itemdata.deliveryDuration.durationType,
                                    "note":widget.itemdata.deliveryDuration.note,
                                    "fromScreen":widget.fromScreen,
                                  });*/
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.itemdata!.itemFeaturedImage,
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding:EdgeInsets.only(left: 10),
                  // width: (MediaQuery
                  //     .of(context)
                  //     .size
                  //     .width / 2) + 60,
                  child: Column(
                    children: [
                      Container(
                        // width: (MediaQuery
                        //     .of(context)
                        //     .size
                        //     .width / 4) + 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      widget.itemdata!.brand!,
                                      style: TextStyle(
                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 9 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: Text(
                                        widget.itemdata!.itemName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Features.isSubscription && widget.itemdata!.eligibleForSubscription=="0"?
                                  Container(
                                    height:40,
                                    width: 85,
                                    child: Padding(
                                        padding: const EdgeInsets.only(left:0,right:5.0),
                                        child: CustomeStepper(itemdata: widget.itemdata!,from: "selling_item",checkmembership:_checkmembership,alignmnt: StepperAlignment.Vertical,height: (Features.isSubscription)?40:40,addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null,index:itemindex,issubscription: "Subscribe",)
                                    ),
                                  ):SizedBox.shrink(),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              Container(
                                  child: Row(
                                    children: <Widget>[
                                      /*    _checkmembership
                                          ?*/ Row(
                                          children: <Widget>[
                                            if(Features.isMembership)
                                              _checkmembership?Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image.asset(
                                                  Images.starImg,
                                                ),
                                              ):SizedBox.shrink(),
                                            new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                  new TextSpan(
                                                      text: Features.iscurrencyformatalign?
                                                      '${_checkmembership?widget.itemdata!.membershipPrice:widget.itemdata!.price} ' + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + '${_checkmembership?widget.itemdata!.membershipPrice:widget.itemdata!.price} ',
                                                      style: new TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                  new TextSpan(
                                                      text: widget.itemdata!.price!=widget.itemdata!.mrp?
                                                      Features.iscurrencyformatalign?
                                                      '${widget.itemdata!.mrp} ' + IConstants.currencyFormat:
                                                      IConstants.currencyFormat + '${widget.itemdata!.mrp} ':"",
                                                      style: TextStyle(
                                                          decoration:
                                                          TextDecoration.lineThrough,
                                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15)),
                                                ],
                                              ),
                                            ),
                                          ]),
                                      if(widget.itemdata!.eligibleForExpress == "0")
                                        Image.asset(Images.express,
                                          height: 20.0,
                                          width: 25.0,),
                                      Spacer(),
                                      if(Features.isLoyalty)
                                        if(double.parse(widget.itemdata!.loyalty.toString()) > 0)
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Image.asset(Images.coinImg,
                                                  height: 15.0,
                                                  width: 20.0,),
                                                SizedBox(width: 4),
                                                Text(widget.itemdata!.loyalty.toString()),
                                              ],
                                            ),
                                          ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              if(Features.netWeight && widget.itemdata!.vegType == "fish")
                                Container(
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2) + 70,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            Features.iscurrencyformatalign?
                                            "Whole Uncut:" +" " +
                                                widget.itemdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                                            "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                                widget.itemdata!.salePrice! +" / "+ "500 G",
                                            style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      SizedBox(height: 3),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text("Gross Weight:" +" "+
                                                    /*'$weight '*/widget.itemdata!.weight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("Net Weight:" +" "+
                                                    /*'$netWeight '*/widget.itemdata!.netWeight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),


                            ],
                          )),
                      SizedBox(
                        width: 10,
                      ),

                    ],
                  ),
                ),
//                SizedBox(height: 10,),
                Column(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) + 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: (MediaQuery.of(context).size.width / 4) + 30,
                            padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                            child:  Container(
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
                              width: (MediaQuery.of(context).size.width / 4) + 30,
                              padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                              child: SizedBox.shrink(),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          if(ResponsiveLayout.isSmallScreen(context))
                            if(Features.isSubscription)
                              (widget.itemdata!.eligibleForSubscription == "0")?
                              (widget.itemdata!.stock!>=0)?
                              Container(
                                width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                    widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8)+20:
                                (MediaQuery.of(context).size.width / 7.5)+20 ,

                                child: GestureDetector(
                                  onTap: () async {
                                    if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                      _dialogforSignIn();
                                    }
                                    else {
                                      (checkskip) ?
                                      /* Navigator.of(context).pushNamed(
                                      SignupSelectionScreen.routeName,
                                    )*/
                                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push):
                                      /*            Navigator.of(context).pushNamed(
                                        SubscribeScreen.routeName,
                                        arguments: {
                                          "itemid": widget.itemdata!.id,
                                          "itemname": widget.itemdata!.itemName,
                                          "itemimg": widget.itemdata!.itemFeaturedImage,
                                          "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                                          "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                                          "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                                          "paymentMode": widget.itemdata!.paymentMode,
                                          "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                          "name": widget.itemdata!.subscriptionSlot![0].name,
                                          "varid":widget.itemdata!.priceVariation![itemindex].id,
                                          "brand": widget.itemdata!.brand
                                        }
                                    );*/
                                      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                                          qparms: {
                                            "itemid": widget.itemdata!.id,
                                            "itemname": widget.itemdata!.itemName,
                                            "itemimg": widget.itemdata!.itemFeaturedImage,
                                            "varname": "",
                                            "varmrp":widget.itemdata!.mrp,
                                            "varprice":  store.userData.membership! == "1" ? widget.itemdata!.membershipPrice.toString() :widget.itemdata!.discointDisplay! ?widget.itemdata!.price.toString():widget.itemdata!.mrp.toString(),
                                            "paymentMode": widget.itemdata!.paymentMode,
                                            "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                            "name": widget.itemdata!.subscriptionSlot![0].name,
                                            "varid":widget.itemdata!.id,
                                            "brand": widget.itemdata!.brand,
                                            "deliveriesarray": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                                            "daily":(  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                                            "dailyDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                                            "weekend": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                                            "weekendDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                                            "weekday": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                                            "weekdayDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                                            "custom": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                                            "customDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays, });
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10,),
                                      Container(
                                        // padding:EdgeInsets.only(left:55,right:55),
                                          height: 30.0,
                                          width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                              widget.fromScreen == "home_screen" ||widget.fromScreen == "search_item" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8):
                                          (MediaQuery.of(context).size.width / 7.5) ,
                                          // width: (MediaQuery.of(context).size.width / 4) + 15,
                                          decoration: new BoxDecoration(
                                              border: Border.all(color: ColorCodes.primaryColor),
                                              color: ColorCodes.whiteColor,
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(2.0),
                                                topRight: const Radius.circular(2.0),
                                                bottomLeft: const Radius.circular(2.0),
                                                bottomRight: const Radius.circular(2.0),
                                              )),
                                          child:
                                          Center(
                                              child: Text(
                                                'SUBSCRIBE',
                                                style: TextStyle(
                                                  color: ColorCodes.primaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ))
                                      ),
                                      SizedBox(width: 10,),
                                    ],
                                  ),
                                ),
                              ):
                              SizedBox(height: 30,):
                              SizedBox(height: 30,),
                          if(ResponsiveLayout.isSmallScreen(context))
                            if(Features.isSubscription)
                              SizedBox(
                                height: 10,
                              ),

//                           (widget.itemdata!.priceVariation[itemindex].stock >= 0)
//                               ? Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child:  VxBuilder( mutations: {SetCartItem},
//                               builder: (context,GroceStore store,state){
//                                 final item =store.CartItemList;
//                                 int itemCount = 0;
//                                 if (item == null) {
//                                   return SizedBox(height: 0);
//                                 }
//                                 else{
//                                   item.forEach((element) {
//                                     if(element.varId == widget.itemdata!.priceVariation[itemindex].id) {
//                                       {
//                                         itemCount = int.parse(element.quantity);
//                                       }
//                                     }
//                                   });
//                                 }
//                                 widget.itemdata!.priceVariation[itemindex].quantity = itemCount;
//                               if (itemCount <= 0)
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         _isAddToCart = true;
//                                       });
//                                       //addToCart(int.parse(itemvarData[0].varminitem));
//                                      // addToCart(int.parse(varminitem));
//                                       addToCart(widget.itemdata!.priceVariation[itemindex],widget.itemdata);
//                                     },
//                                     child: Container(
//                                       height: 30.0,
//                                       width: (MediaQuery.of(context).size.width / 4) + 15,
//                                       decoration: new BoxDecoration(
//                                           color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                           borderRadius:
//                                           new BorderRadius.only(
//                                             topLeft:
//                                             const Radius.circular(2.0),
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomLeft:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       child: _isAddToCart ?
//                                       Center(
//                                         child: SizedBox(
//                                             width: 20.0,
//                                             height: 20.0,
//                                             child: new CircularProgressIndicator(
//                                               strokeWidth: 2.0,
//                                               valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                       )
//                                           :(Features.isSubscription)?
//                                       (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                       :Row(
//                                         mainAxisAlignment: MainAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                           :
//                                       Row(
//                                         children: [
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           Center(
//                                               child: Text(
//                                                 'ADD',
//                                                 style: TextStyle(
//                                                   color: Theme
//                                                       .of(context)
//                                                       .buttonColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )),
//                                           Spacer(),
//                                           Container(
//                                             decoration: BoxDecoration(
//                                                 color: ColorCodes.greenColor,//Color(0xff1BA130),
//                                                 borderRadius:
//                                                 new BorderRadius.only(
//                                                   topLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   topRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                 )),
//                                             height: 30,
//                                             width: 25,
//                                             child: Icon(
//                                               Icons.add,
//                                               size: 12,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 else
//                                   return Container(
//                                     child: Row(
//                                       children: <Widget>[
//                                         GestureDetector(
//                                           onTap: () async {
//                                             setState(() {
//                                              // _isAddToCart = true;
//                                              // incrementToCart(varQty - 1);
//                                               updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.decrement, widget.itemdata!.priceVariation[itemindex].id);
//                                             });
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomLeft: const Radius
//                                                         .circular(2.0),
//                                                     topLeft: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "-",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         Expanded(
//                                           child: _isAddToCart ?
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                             ),
//                                             height: 30,
//                                             padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
//                                             child: Center(
//                                               child: SizedBox(
//                                                   width: 20.0,
//                                                   height: 20.0,
//                                                   child: new CircularProgressIndicator(
//                                                     strokeWidth: 2.0,
//                                                     valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                             ),
//                                           )
//                                               :
//                                           Container(
// //                                            width: 40,
//                                               decoration: BoxDecoration(
//                                                 color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                               ),
//                                               height: 30,
//                                               child: Center(
//                                                 child: Text(
//                                                   varQty.toString(),
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.whiteColor:Theme
//                                                         .of(context)
//                                                         .buttonColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                            /* if (varQty < int.parse(varstock)) {
//                                               if (varQty < int.parse(varmaxitem)) {
//                                                 setState(() {
//                                                   _isAddToCart = true;
//                                                 });
//                                                 incrementToCart(varQty + 1);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     "Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor:
//                                                     Colors.black87,
//                                                     textColor:
//                                                     Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg:
//                                                   "Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor:
//                                                   Colors.black87,
//                                                   textColor: Colors.white);
//                                             }*/
//                                             if (widget.itemdata!.priceVariation[itemindex].quantity < widget.itemdata!.priceVariation[itemindex].stock) {
//                                               if (widget.itemdata!.priceVariation[itemindex].quantity < int.parse(widget.itemdata!.priceVariation[itemindex].maxItem)) {
//                                                 updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.increment, widget.itemdata!.priceVariation[itemindex].id);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     S .of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor: Colors.black87,
//                                                     textColor: Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg: S .of(context).sorry_outofstock,//"Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor: Colors.black87,
//                                                   textColor: Colors.white);
//                                             }
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.primaryColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomRight:
//                                                     const Radius
//                                                         .circular(2.0),
//                                                     topRight: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "+",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.blackColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//
//
//                               },
//                             ),
//                           )
//                               : Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child: GestureDetector(
//                               onTap: () {
//                                 if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
//                                   _dialogforSignIn();
//                                 }
//                                 else {
//                                   (checkskip ) ?
//                                   Navigator.of(context).pushNamed(
//                                     SignupSelectionScreen.routeName,
//                                   ) :
//                                   _notifyMe();
//                                 }
//                                 /* setState(() {
//                                 _isNotify = true;
//                               });
//                               _notifyMe();*/
//                                 // Fluttertoast.showToast(
//                                 //     msg: "You will be notified via SMS/Push notification, when the product is available",
//                                 //     /*"Out Of Stock",*/
//                                 //     fontSize: 12.0,
//                                 //     backgroundColor: Colors.black87,
//                                 //     textColor: Colors.white);
//                               },
//                               child: Container(
//                                 height: 30.0,
//                                 width: (MediaQuery.of(context).size.width / 4) + 15,
//                                 decoration: new BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey,
//                                     borderRadius: new BorderRadius.only(
//                                       topLeft: const Radius.circular(2.0),
//                                       topRight: const Radius.circular(2.0),
//                                       bottomLeft: const Radius.circular(2.0),
//                                       bottomRight: const Radius.circular(2.0),
//                                     )),
//                                 child:
//                                 _isNotify ?
//                                 Center(
//                                   child: SizedBox(
//                                       width: 20.0,
//                                       height: 20.0,
//                                       child: new CircularProgressIndicator(
//                                         strokeWidth: 2.0,
//                                         valueColor: new AlwaysStoppedAnimation<
//                                             Color>(Colors.white),)),
//                                 )
//                                     :
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 10,
//                                     ),
//                                     Center(
//                                         child: Text(
//                                           'Notify Me',
//                                           /*"ADD",*/
//                                           style: TextStyle(
//                                             /*fontWeight: FontWeight.w700,*/
//                                               color:
//                                               Colors
//                                                   .white /*Colors.black87*/),
//                                           textAlign: TextAlign.center,
//                                         )),
//                                     Spacer(),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                           color: Colors.black12,
//                                           borderRadius: new BorderRadius.only(
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       height: 30,
//                                       width: 25,
//                                       child: Icon(
//                                         Icons.add,
//                                         size: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // height: 90.0,
                                  // width: Vx.isWeb?(widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "search_item")?
                                  // (MediaQuery.of(context).size.width / 5.5):
                                  // (MediaQuery.of(context).size.width / 6.9):
                                  // (MediaQuery.of(context).size.width / 5.5),
                                    child: CustomeStepper(itemdata: widget.itemdata,from: "selling_item",checkmembership:_checkmembership,alignmnt: StepperAlignment.Vertical,height: (Features.isSubscription)?40:40,addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null,index:itemindex,issubscription: "Add",)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                !_checkmembership
                    ? widget.itemdata!.membershipDisplay!
                    ? SizedBox(height: 12,)
                    : SizedBox(height: 12,)
                    : SizedBox(height: 12,),

               // if(ResponsiveLayout.isSmallScreen(context))
                  if(Features.isMembership)
                    if(widget.itemdata!.membershipPrice! != "0")
                    (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                        widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?
                    Container(
                      width: (MediaQuery.of(context).size.width / 4) + 30,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:  !_checkmembership
                          ? widget.itemdata!.membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          if(!PrefUtils.prefs!.containsKey("apikey")) {
                            if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                context)) {
                              LoginWeb(context, result: (sucsess) {
                                if (sucsess) {
                                  Navigator.of(context).pop();
                                  /*Navigator.pushNamedAndRemoveUntil(
                                    context, HomeScreen.routeName, (
                                    route) => false);*/
                                  Navigation(context, navigatore: NavigatoreTyp.homenav);
                                } else {
                                  Navigator.of(context).pop();
                                }
                              });
                            } else {
                              /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            );*/
                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                            }
                          }
                          else{
                            /* Navigator.of(context).pushNamed(
                            MembershipScreen.routeName,
                          );*/
                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                          }
                        },
                        child: Container(
                          height: 23,
                          decoration: BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  Features.iscurrencyformatalign?
                                  widget.itemdata!.membershipPrice.toString() +  IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.itemdata!.membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
                        :
                    Container(
                      width: (MediaQuery.of(context).size.width/5.2),
                      child: !_checkmembership
                          ? widget.itemdata!.membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
                          _dialogforSignIn() :
                          (checkskip && !_isWeb)?
                          /*Navigator.of(context).pushReplacementNamed(
                            SignupSelectionScreen.routeName)*/
                          Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                              :/*Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );*/
                          Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                        },
                        //                   child: Padding(
                        // padding: EdgeInsets.all(10),
                        child: Container(
                          height: 23,
                          // padding: EdgeInsets.only(left: 10),
                          width: (MediaQuery.of(context).size.width/5.2),

                          decoration:
                          BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
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
                                  Features.iscurrencyformatalign?
                                  widget.itemdata!.membershipPrice.toString() + IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.itemdata!.membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12, color: Colors.black)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
              ],
            ),
          ],
        ),
      ):
        Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
          border: Border.all(color: ColorCodes.shimmercolor),
        ),
        margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0, right: 5),
        child: Column(
          children: [
            ItemBadge(
              outOfStock: widget.itemdata!.priceVariation![itemindex].stock!<=0?OutOfStock(singleproduct: false,):null,
              // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
              /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):SizedBox.shrink()),*/
              child: Align(
                alignment: Alignment.center,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if(widget.fromScreen == "sellingitem_screen") {
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.itemdata!.priceVariation![itemindex].menuItemId.toString()});
                      }
                      else{
                        // navigatetoSingelproductscreen(context,widget.returnparm,
                        //     duration: widget.itemdata.duration,
                        //     delivery: widget.itemdata.delivery,
                        //     durationType: widget.itemdata.deliveryDuration.durationType,
                        //     eligibleforexpress: widget.itemdata!.eligibleForExpress,
                        //     fromScreen: widget.fromScreen,
                        //     id: widget.itemdata!.id,
                        //     note: widget.itemdata.deliveryDuration.note,
                        //     imageUrl: widget.itemdata!.itemFeaturedImage,
                        //     itemvarData:itemvarData,
                        //     title:widget.itemdata!.itemName,
                        //   seeallpress:widget._seeallpress,
                        //   notid: widget._notid,
                        // );
                        Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.itemdata!.priceVariation![itemindex].menuItemId.toString()});
                      }
                      /*
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.itemdata!.id,
                                    "itemname": widget.itemdata!.itemName,
                                    "itemimg": widget.itemdata!.itemFeaturedImage,
                                    "eligibleforexpress": widget.itemdata!.eligibleForExpress,
                                    "delivery": widget.itemdata.delivery,
                                    "duration": widget.itemdata.duration,
                                    "durationType":widget.itemdata.deliveryDuration.durationType,
                                    "note":widget.itemdata.deliveryDuration.note,
                                    "fromScreen":widget.fromScreen,
                                  });*/
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.itemdata!.priceVariation![itemindex].images!.length<=0?widget.itemdata!.itemFeaturedImage:widget.itemdata!.priceVariation![itemindex].images![0].image,
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
            /*Container(
                width: (MediaQuery.of(context).size.width / 3) + 10,
                child: Column(
                  children: [
                    (_checkmargin)?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 5.0),
                          padding: EdgeInsets.all(3.0),
                          // color: Theme.of(context).accentColor,
                          *//* decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                3.0),
                            color: ColorCodes.checkmarginColor, //Color(0xff6CBB3C),
                          ),*//*
                          constraints: BoxConstraints(
                            minWidth: 28,
                            minHeight: 18,
                          ),
                          child: Text(
                            margins + S .of(context).off,//"% OFF",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorCodes.greenColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ):SizedBox(height: 24,),
                    SizedBox(
                      height: 10,
                    ),

                  ],
                )),
            Container(
              padding: EdgeInsets.only(top: 0),
              // width: (MediaQuery
              //     .of(context)
              //     .size
              //     .width / 2) - 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !_isStock
                      ? Consumer<Calculations>(
                    builder: (_, cart, ch) =>
                        BadgeOfStock(
                          child: ch,
                          value: margins,
                          singleproduct: false,
                        ),
                    child: GestureDetector(
                      onTap: () {
                        navigatetoSingelproductscreen(context,widget.returnparm,
                            duration: widget.duration,
                            delivery: widget.delivery,
                            durationType: widget.durationType,
                            note: widget.note,
                            eligibleforexpress: widget.eligibleforexpress,
                            fromScreen: widget.fromScreen,
                            id: widget.id,
                            imageUrl: widget.imageUrl,
                            itemvarData:itemvarData,
                            title:widget.title );
                      },
                      child: CachedNetworkImage(
                        imageUrl: *//*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                        placeholder: (context, url) =>
                            Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            ),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.defaultProductImg,
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        ),
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      navigatetoSingelproductscreen(context,widget.returnparm,
                          duration: widget.duration,
                          delivery: widget.delivery,
                          durationType: widget.durationType,
                          eligibleforexpress: widget.eligibleforexpress,
                          fromScreen: widget.fromScreen,
                          id: widget.id,
                          note: widget.note,
                          imageUrl: widget.imageUrl,
                          itemvarData:itemvarData,
                          title:widget.title );
                    },
                    child: CachedNetworkImage(
                      imageUrl:*//* (widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                      placeholder: (context, url) =>
                          Image.asset(
                            Images.defaultProductImg,
                            width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          ),
                      errorWidget: (context, url, error) => Image.asset(
                        Images.defaultProductImg,
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      ),
                      width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),*/
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding:EdgeInsets.only(left: 10),
                  // width: (MediaQuery
                  //     .of(context)
                  //     .size
                  //     .width / 2) + 60,
                  child: Column(
                    children: [
                      Container(
                        // width: (MediaQuery
                        //     .of(context)
                        //     .size
                        //     .width / 4) + 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      widget.itemdata!.brand!,
                                      style: TextStyle(
                                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 9 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      child: Text(
                                        widget.itemdata!.itemName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Features.isSubscription && widget.itemdata!.eligibleForSubscription=="0"?
                                  Container(
                                    height:40,
                                    width: 85,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:0,right:5.0),
                                      child: CustomeStepper(priceVariation:widget.itemdata!.priceVariation![itemindex],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Subscribe",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null, index: itemindex),
                                    ),
                                  ):SizedBox.shrink(),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              Container(
                                  child: Row(
                                    children: <Widget>[
                                  /*    _checkmembership
                                          ?*/ Row(
                                        children: <Widget>[
                                          if(Features.isMembership)
                                            _checkmembership?Container(
                                              width: 25.0,
                                              height: 25.0,
                                              child: Image.asset(
                                                Images.starImg,
                                              ),
                                            ):SizedBox.shrink(),
                                          new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                 fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                new TextSpan(
                                                    text: Features.iscurrencyformatalign?
                                                        '${_checkmembership?widget.itemdata!.priceVariation![itemindex].membershipPrice:widget.itemdata!.priceVariation![itemindex].price} ' + IConstants.currencyFormat:
                                                    IConstants.currencyFormat + '${_checkmembership?widget.itemdata!.priceVariation![itemindex].membershipPrice:widget.itemdata!.priceVariation![itemindex].price} ',
                                                    style: new TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                new TextSpan(
                                                    text: widget.itemdata!.priceVariation![itemindex].price!=widget.itemdata!.priceVariation![itemindex].mrp?
                                                        Features.iscurrencyformatalign?
                                                        '${widget.itemdata!.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
                                                    IConstants.currencyFormat + '${widget.itemdata!.priceVariation![itemindex].mrp} ':"",
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration.lineThrough,
                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15)),
                                              ],
                                            ),
                                          ),
                                    ]),
                                    /*      widget.itemdata!.priceVariation[itemindex].membershipDisplay
                                              ? new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                new TextSpan(
                                                    text: IConstants.currencyFormat +
                                                        *//*'$varmemberprice '*//*widget.itemdata!.priceVariation[itemindex].membershipPrice.toString(),
                                                    style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      Colors.black,
                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        *//*'$varmrp '*//*widget.itemdata!.priceVariation[itemindex].mrp.toString(),
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                    )),
                                              ],
                                            ),
                                          )
                                              : discountDisplay
                                              ? new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: IConstants.currencyFormat +
                                                        '$varprice ',
                                                    style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .black,
                                                      fontSize:
                                                      ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                                new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        '$varmrp ',
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                    )),
                                              ],
                                            ),
                                          )
                                              : new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text:
                                                    IConstants.currencyFormat +
                                                        '$varmrp ',
                                                    style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Colors
                                                          .black,
                                                      fontSize:
                                                      ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                          : discountDisplay
                                          ? new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text: IConstants.currencyFormat +
                                                    '$varprice ',
                                                style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                            new TextSpan(
                                                text: IConstants.currencyFormat +
                                                    '$varmrp ',
                                                style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                )),
                                          ],
                                        ),
                                      )
                                          : new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text: IConstants.currencyFormat +
                                                    '$varmrp ',
                                                style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15,)),
                                          ],
                                        ),
                                      ),*/
                                      if(widget.itemdata!.eligibleForExpress == "0")
                                        Image.asset(Images.express,
                                          height: 20.0,
                                          width: 25.0,),
                                      Spacer(),
                                      if(Features.isLoyalty)
                                        if(double.parse(widget.itemdata!.priceVariation![itemindex].loyalty.toString()) > 0)
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Image.asset(Images.coinImg,
                                                  height: 15.0,
                                                  width: 20.0,),
                                                SizedBox(width: 4),
                                                Text(widget.itemdata!.priceVariation![itemindex].loyalty.toString()),
                                              ],
                                            ),
                                          ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              if(Features.netWeight && widget.itemdata!.vegType == "fish")
                                Container(
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2) + 70,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            Features.iscurrencyformatalign?
                                            "Whole Uncut:" +" " +
                                                widget.itemdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                                            "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                              widget.itemdata!.salePrice! +" / "+ "500 G",
                                            style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      SizedBox(height: 3),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text("Gross Weight:" +" "+
                                                    /*'$weight '*/widget.itemdata!.priceVariation![itemindex].weight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),
                                              Container(
                                                child: Text("Net Weight:" +" "+
                                                    /*'$netWeight '*/widget.itemdata!.priceVariation![itemindex].netWeight!,
                                                    style: new TextStyle( fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 15, fontWeight: FontWeight.bold)
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),


                            ],
                          )),
                      SizedBox(
                        width: 10,
                      ),

                    ],
                  ),
                ),
//                SizedBox(height: 10,),
                Column(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) + 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: (MediaQuery.of(context).size.width / 4) + 30,
                            padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                            child: ( widget.itemdata!.priceVariation!.length > 1)
                                ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  //isweb
                                 // showoptions();
                                  showoptions1();
                                });

                              },
                              child: Container(
                                height: 30,
                                width: (MediaQuery.of(context).size.width / 4) + 30,
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
                                    /* Container(
                                      //width: (MediaQuery.of(context).size.width /2)+20,
                                      decoration: BoxDecoration(
                                          *//*border: Border.all(
                                            color: ColorCodes.greenColor,),*//*
                                          color: ColorCodes.varcolor,
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            bottomLeft: const Radius.circular(2.0),
                                          )),
                                      height: 30,
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 4.5, 0.0, 4.5),
                                      child:*/ Text(
                                      //"$varname"+" "+"$unit",
                                      "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
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
                              width: (MediaQuery.of(context).size.width / 4) + 30,
                              padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                              child: Text(
                                "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                style:
                                TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),

                          if(ResponsiveLayout.isSmallScreen(context))
                          if(Features.isSubscription)
                            (widget.itemdata!.eligibleForSubscription == "0")?
                            (widget.itemdata!.priceVariation![itemindex].stock!>=0)?
                            Container(
                              width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                  widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8)+20:
                              (MediaQuery.of(context).size.width / 7.5)+20 ,

                              child: GestureDetector(
                                onTap: () async {
                                  if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                                    _dialogforSignIn();
                                  }
                                  else {
                                    (checkskip) ?
                                   /* Navigator.of(context).pushNamed(
                                      SignupSelectionScreen.routeName,
                                    )*/
                                    Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push):
                        /*            Navigator.of(context).pushNamed(
                                        SubscribeScreen.routeName,
                                        arguments: {
                                          "itemid": widget.itemdata!.id,
                                          "itemname": widget.itemdata!.itemName,
                                          "itemimg": widget.itemdata!.itemFeaturedImage,
                                          "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                                          "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                                          "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                                          "paymentMode": widget.itemdata!.paymentMode,
                                          "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                          "name": widget.itemdata!.subscriptionSlot![0].name,
                                          "varid":widget.itemdata!.priceVariation![itemindex].id,
                                          "brand": widget.itemdata!.brand
                                        }
                                    );*/
                                    Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                                        qparms: {
                                          "itemid": widget.itemdata!.id,
                                          "itemname": widget.itemdata!.itemName,
                                          "itemimg": widget.itemdata!.itemFeaturedImage,
                                          "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                                          "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                                          "varprice":  store.userData.membership! == "1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                                          "paymentMode": widget.itemdata!.paymentMode,
                                          "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                          "name": widget.itemdata!.subscriptionSlot![0].name,
                                          "varid":widget.itemdata!.priceVariation![itemindex].id,
                                          "brand": widget.itemdata!.brand,
                                          "deliveriesarray": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                                          "daily":(  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                                          "dailyDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                                          "weekend": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                                          "weekendDays": (  widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                                          "weekday": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                                          "weekdayDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                                          "custom": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                                          "customDays": ( widget.fromScreen == "search_item_multivendor" && Features.ismultivendor)?widget.storedsearchdata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                                        });
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 10,),
                                    Container(
                                      // padding:EdgeInsets.only(left:55,right:55),
                                        height: 30.0,
                                        width: (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                                            widget.fromScreen == "home_screen" ||widget.fromScreen == "search_item" || widget.fromScreen=="not_product_screen")?(MediaQuery.of(context).size.width / 5.8):
                                        (MediaQuery.of(context).size.width / 7.5) ,
                                        // width: (MediaQuery.of(context).size.width / 4) + 15,
                                        decoration: new BoxDecoration(
                                            border: Border.all(color: ColorCodes.primaryColor),
                                            color: ColorCodes.whiteColor,
                                            borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(2.0),
                                              topRight: const Radius.circular(2.0),
                                              bottomLeft: const Radius.circular(2.0),
                                              bottomRight: const Radius.circular(2.0),
                                            )),
                                        child:
                                        Center(
                                            child: Text(
                                              'SUBSCRIBE',
                                              style: TextStyle(
                                                color: ColorCodes.primaryColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ))
                                    ),
                                    SizedBox(width: 10,),
                                  ],
                                ),
                              ),
                            ):
                            SizedBox(height: 30,):
                            SizedBox(height: 30,),
                          if(ResponsiveLayout.isSmallScreen(context))
                          if(Features.isSubscription)
                            SizedBox(
                              height: 10,
                            ),

//                           (widget.itemdata!.priceVariation[itemindex].stock >= 0)
//                               ? Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child:  VxBuilder( mutations: {SetCartItem},
//                               builder: (context,GroceStore store,state){
//                                 final item =store.CartItemList;
//                                 int itemCount = 0;
//                                 if (item == null) {
//                                   return SizedBox(height: 0);
//                                 }
//                                 else{
//                                   item.forEach((element) {
//                                     if(element.varId == widget.itemdata!.priceVariation[itemindex].id) {
//                                       {
//                                         itemCount = int.parse(element.quantity);
//                                       }
//                                     }
//                                   });
//                                 }
//                                 widget.itemdata!.priceVariation[itemindex].quantity = itemCount;
//                               if (itemCount <= 0)
//                                   return GestureDetector(
//                                     onTap: () {
//                                       setState(() {
//                                         _isAddToCart = true;
//                                       });
//                                       //addToCart(int.parse(itemvarData[0].varminitem));
//                                      // addToCart(int.parse(varminitem));
//                                       addToCart(widget.itemdata!.priceVariation[itemindex],widget.itemdata);
//                                     },
//                                     child: Container(
//                                       height: 30.0,
//                                       width: (MediaQuery.of(context).size.width / 4) + 15,
//                                       decoration: new BoxDecoration(
//                                           color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                           borderRadius:
//                                           new BorderRadius.only(
//                                             topLeft:
//                                             const Radius.circular(2.0),
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomLeft:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       child: _isAddToCart ?
//                                       Center(
//                                         child: SizedBox(
//                                             width: 20.0,
//                                             height: 20.0,
//                                             child: new CircularProgressIndicator(
//                                               strokeWidth: 2.0,
//                                               valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                       )
//                                           :(Features.isSubscription)?
//                                       (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                       :Row(
//                                         mainAxisAlignment: MainAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'BUY ONCE',
//                                             style: TextStyle(
//                                                 color: ColorCodes.whiteColor,
//                                                 fontSize: 12, fontWeight: FontWeight.bold
//                                             ),
//
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ],
//                                       )
//                                           :
//                                       Row(
//                                         children: [
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                           Center(
//                                               child: Text(
//                                                 'ADD',
//                                                 style: TextStyle(
//                                                   color: Theme
//                                                       .of(context)
//                                                       .buttonColor,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )),
//                                           Spacer(),
//                                           Container(
//                                             decoration: BoxDecoration(
//                                                 color: ColorCodes.greenColor,//Color(0xff1BA130),
//                                                 borderRadius:
//                                                 new BorderRadius.only(
//                                                   topLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomLeft:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   topRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                   bottomRight:
//                                                   const Radius.circular(
//                                                       2.0),
//                                                 )),
//                                             height: 30,
//                                             width: 25,
//                                             child: Icon(
//                                               Icons.add,
//                                               size: 12,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 else
//                                   return Container(
//                                     child: Row(
//                                       children: <Widget>[
//                                         GestureDetector(
//                                           onTap: () async {
//                                             setState(() {
//                                              // _isAddToCart = true;
//                                              // incrementToCart(varQty - 1);
//                                               updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.decrement, widget.itemdata!.priceVariation[itemindex].id);
//                                             });
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomLeft: const Radius
//                                                         .circular(2.0),
//                                                     topLeft: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "-",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         Expanded(
//                                           child: _isAddToCart ?
//                                           Container(
//                                             decoration: BoxDecoration(
//                                               color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                             ),
//                                             height: 30,
//                                             padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
//                                             child: Center(
//                                               child: SizedBox(
//                                                   width: 20.0,
//                                                   height: 20.0,
//                                                   child: new CircularProgressIndicator(
//                                                     strokeWidth: 2.0,
//                                                     valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)),
//                                             ),
//                                           )
//                                               :
//                                           Container(
// //                                            width: 40,
//                                               decoration: BoxDecoration(
//                                                 color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor,
//                                               ),
//                                               height: 30,
//                                               child: Center(
//                                                 child: Text(
//                                                   varQty.toString(),
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.whiteColor:Theme
//                                                         .of(context)
//                                                         .buttonColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                         GestureDetector(
//                                           onTap: () {
//                                            /* if (varQty < int.parse(varstock)) {
//                                               if (varQty < int.parse(varmaxitem)) {
//                                                 setState(() {
//                                                   _isAddToCart = true;
//                                                 });
//                                                 incrementToCart(varQty + 1);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     "Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor:
//                                                     Colors.black87,
//                                                     textColor:
//                                                     Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg:
//                                                   "Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor:
//                                                   Colors.black87,
//                                                   textColor: Colors.white);
//                                             }*/
//                                             if (widget.itemdata!.priceVariation[itemindex].quantity < widget.itemdata!.priceVariation[itemindex].stock) {
//                                               if (widget.itemdata!.priceVariation[itemindex].quantity < int.parse(widget.itemdata!.priceVariation[itemindex].maxItem)) {
//                                                 updateCart(widget.itemdata!.priceVariation[itemindex].quantity, CartStatus.increment, widget.itemdata!.priceVariation[itemindex].id);
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg:
//                                                     S .of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
//                                                     fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                     backgroundColor: Colors.black87,
//                                                     textColor: Colors.white);
//                                               }
//                                             } else {
//                                               Fluttertoast.showToast(
//                                                   msg: S .of(context).sorry_outofstock,//"Sorry, Out of Stock!",
//                                                   fontSize: MediaQuery.of(context).textScaleFactor *13,
//                                                   backgroundColor: Colors.black87,
//                                                   textColor: Colors.white);
//                                             }
//                                           },
//                                           child: Container(
//                                               width: 30,
//                                               height: 30,
//                                               decoration: new BoxDecoration(
//                                                   border: Border.all(
//                                                     color: (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.primaryColor,
//                                                   ),
//                                                   borderRadius:
//                                                   new BorderRadius.only(
//                                                     bottomRight:
//                                                     const Radius
//                                                         .circular(2.0),
//                                                     topRight: const Radius
//                                                         .circular(2.0),
//                                                   )),
//                                               child: Center(
//                                                 child: Text(
//                                                   "+",
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                     color: (Features.isSubscription)?ColorCodes.blackColor:ColorCodes.greenColor,
//                                                   ),
//                                                 ),
//                                               )),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//
//
//                               },
//                             ),
//                           )
//                               : Container(
//                             padding: EdgeInsets.only(left: 10,right: 10),
//                             height: 30.0,
//                             width: (MediaQuery.of(context).size.width / 4) + 30,
//                             child: GestureDetector(
//                               onTap: () {
//                                 if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
//                                   _dialogforSignIn();
//                                 }
//                                 else {
//                                   (checkskip ) ?
//                                   Navigator.of(context).pushNamed(
//                                     SignupSelectionScreen.routeName,
//                                   ) :
//                                   _notifyMe();
//                                 }
//                                 /* setState(() {
//                                 _isNotify = true;
//                               });
//                               _notifyMe();*/
//                                 // Fluttertoast.showToast(
//                                 //     msg: "You will be notified via SMS/Push notification, when the product is available",
//                                 //     /*"Out Of Stock",*/
//                                 //     fontSize: 12.0,
//                                 //     backgroundColor: Colors.black87,
//                                 //     textColor: Colors.white);
//                               },
//                               child: Container(
//                                 height: 30.0,
//                                 width: (MediaQuery.of(context).size.width / 4) + 15,
//                                 decoration: new BoxDecoration(
//                                     border: Border.all(color: Colors.grey),
//                                     color: Colors.grey,
//                                     borderRadius: new BorderRadius.only(
//                                       topLeft: const Radius.circular(2.0),
//                                       topRight: const Radius.circular(2.0),
//                                       bottomLeft: const Radius.circular(2.0),
//                                       bottomRight: const Radius.circular(2.0),
//                                     )),
//                                 child:
//                                 _isNotify ?
//                                 Center(
//                                   child: SizedBox(
//                                       width: 20.0,
//                                       height: 20.0,
//                                       child: new CircularProgressIndicator(
//                                         strokeWidth: 2.0,
//                                         valueColor: new AlwaysStoppedAnimation<
//                                             Color>(Colors.white),)),
//                                 )
//                                     :
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 10,
//                                     ),
//                                     Center(
//                                         child: Text(
//                                           'Notify Me',
//                                           /*"ADD",*/
//                                           style: TextStyle(
//                                             /*fontWeight: FontWeight.w700,*/
//                                               color:
//                                               Colors
//                                                   .white /*Colors.black87*/),
//                                           textAlign: TextAlign.center,
//                                         )),
//                                     Spacer(),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                           color: Colors.black12,
//                                           borderRadius: new BorderRadius.only(
//                                             topRight:
//                                             const Radius.circular(2.0),
//                                             bottomRight:
//                                             const Radius.circular(2.0),
//                                           )),
//                                       height: 30,
//                                       width: 25,
//                                       child: Icon(
//                                         Icons.add,
//                                         size: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
                          Row(
                           // mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // height: 90.0,
                                  // width: Vx.isWeb?(widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "search_item")?
                                  // (MediaQuery.of(context).size.width / 5.5):
                                  // (MediaQuery.of(context).size.width / 6.9):
                                  // (MediaQuery.of(context).size.width / 5.5),
                                    child: CustomeStepper(priceVariation: widget.itemdata!.priceVariation![itemindex],itemdata: widget.itemdata,from: "selling_item",checkmembership:_checkmembership,alignmnt: StepperAlignment.Vertical,height: (Features.isSubscription)?40:40,addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null,index:itemindex,issubscription: "Add",)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                !_checkmembership
                    ? widget.itemdata!.priceVariation![itemindex].membershipDisplay!
                    ? SizedBox(height: 12,)
                    : SizedBox(height: 12,)
                    : SizedBox(height: 12,),

               // if(ResponsiveLayout.isSmallScreen(context))
                  if(Features.isMembership)
                    if(widget.itemdata!.priceVariation![itemindex].membershipPrice! != "0")
                    (widget.fromScreen == "brands_screen" || widget.fromScreen == "sellingitem_screen" || widget.fromScreen == "shoppinglistitem_screen" ||
                        widget.fromScreen == "home_screen" ||widget.fromScreen == "searchitem_screen" || widget.fromScreen=="not_product_screen")?
                    Container(
                      width: (MediaQuery.of(context).size.width / 4) + 30,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child:  !_checkmembership
                          ? widget.itemdata!.priceVariation![itemindex].membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          if(!PrefUtils.prefs!.containsKey("apikey")) {
                            if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                context)) {
                              LoginWeb(context, result: (sucsess) {
                                if (sucsess) {
                                  Navigator.of(context).pop();
                                  /*Navigator.pushNamedAndRemoveUntil(
                                    context, HomeScreen.routeName, (
                                    route) => false);*/
                                  Navigation(context, navigatore: NavigatoreTyp.homenav);
                                } else {
                                  Navigator.of(context).pop();
                                }
                              });
                            } else {
                              /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            );*/
                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                            }
                          }
                          else{
                            /* Navigator.of(context).pushNamed(
                            MembershipScreen.routeName,
                          );*/
                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                          }
                        },
                        child: Container(
                          height: 23,
                          decoration: BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  Features.iscurrencyformatalign?
                                  widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() +  IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.itemdata!.priceVariation![itemindex].membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
                        :
                    Container(
                      width: (MediaQuery.of(context).size.width/5.2),
                      child: !_checkmembership
                          ? widget.itemdata!.priceVariation![itemindex].membershipDisplay!
                          ? GestureDetector(
                        onTap: () {
                          (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
                          _dialogforSignIn() :
                          (checkskip && !_isWeb)?
                          /*Navigator.of(context).pushReplacementNamed(
                            SignupSelectionScreen.routeName)*/
                          Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                              :/*Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );*/
                          Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                        },
                        //                   child: Padding(
                        // padding: EdgeInsets.all(10),
                        child: Container(
                          height: 23,
                          // padding: EdgeInsets.only(left: 10),
                          width: (MediaQuery.of(context).size.width/5.2),

                          decoration:
                          BoxDecoration(color: ColorCodes.membershipColor),
                          child: Row(
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
                                  Features.iscurrencyformatalign?
                                  widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                  IConstants.currencyFormat +
                                      widget.itemdata!.priceVariation![itemindex].membershipPrice.toString(),
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12, color: Colors.black)),
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
                        //)



                      )
                          : SizedBox.shrink()
                          : SizedBox.shrink(),
                    )
              ],
            ),
          ],
        ),
      );


    }
    else{
     /* for(int i= 0; i<itemvarData.length;i++){
      }*/
      return widget.fromScreen == "search_item_multivendor" && Features.ismultivendor?
      widget.storedsearchdata!.type=="1"?
      GestureDetector(
        onTap: (){
          if(widget.fromScreen == "sellingitem_screen") {
            if (widget.storedsearchdata!.stock !>= 0)
              /*navigatetoSingelproductscreen(context,widget.returnparm,
                  duration: widget.itemdata.duration,
                  delivery: widget.itemdata.delivery,
                  note: widget.itemdata.deliveryDuration.note,
                  durationType: widget.itemdata.deliveryDuration.durationType,
                  eligibleforexpress: widget.itemdata!.eligibleForExpress,
                  fromScreen: widget.fromScreen,
                  id: widget.itemdata!.id,
                  imageUrl: widget.itemdata!.itemFeaturedImage,
                  itemvarData:itemvarData,
                  title:widget.itemdata!.itemName,
                notid: widget._notid,
                seeallpress:widget._seeallpress,
              );*/
              Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
            // else
            // Navigator.of(context).pushReplacementNamed(
            //     SingleproductScreen.routeName,
            //     arguments: {
            //       "itemid": widget.itemdata!.id.toString(),
            //       "itemname": widget.itemdata!.itemName,
            //       'fromScreen': widget.fromScreen,
            //       "itemimg": widget.itemdata!.itemFeaturedImage,
            //       "eligibleforexpress": widget.itemdata!.eligibleForExpress,
            //       "delivery": widget.itemdata.delivery,
            //       "duration": widget.itemdata.duration,
            //       "durationType": widget.itemdata.deliveryDuration.durationType,
            //       "note": widget.itemdata.deliveryDuration.note,
            //       "updateItemList": variationdisplaydata,
            //       "updateItem": itemvarData,
            //       "seeallpress":widget._seeallpress,
            //       "notid":widget._notid,
            //       // "fromScreen":"sellingitem_screen",
            //     });
          }
          else{
            if (widget.storedsearchdata!.stock !>= 0)
              /*navigatetoSingelproductscreen(context,widget.returnparm,
                  duration: widget.itemdata.duration,
                  delivery: widget.itemdata.delivery,
                  note: widget.itemdata.deliveryDuration.note,
                  durationType: widget.itemdata.deliveryDuration.durationType,
                  eligibleforexpress: widget.itemdata!.eligibleForExpress,
                  fromScreen: widget.fromScreen,
                  id: widget.itemdata!.id,
                  imageUrl: widget.itemdata!.itemFeaturedImage,
                  itemvarData:itemvarData,
                  title:widget.itemdata!.itemName,
                notid: widget._notid,);*/
              Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
            else
              /* navigatetoSingelproductscreen(context,widget.returnparm,
                  duration: widget.itemdata.duration,
                  delivery: widget.itemdata.delivery,
                  note: widget.itemdata.deliveryDuration.note,
                  durationType: widget.itemdata.deliveryDuration.durationType,
                  eligibleforexpress: widget.itemdata!.eligibleForExpress,
                  fromScreen: widget.fromScreen,
                  id: widget.itemdata!.id,
                  imageUrl: widget.itemdata!.itemFeaturedImage,
                  itemvarData:itemvarData,
                  title:widget.itemdata!.itemName,notid: widget._notid, );*/
              Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(width: 2.0, color: ColorCodes.lightGreyWebColor),
            ),
          ),
          margin: (Features.ismultivendor)? EdgeInsets.only(left: 0.0,  bottom: 0.0, right: 0) : EdgeInsets.only(left: 5.0,  bottom: 0.0, right: 5),
          child: Row(
            children: [
              Container(
                width: (MediaQuery
                    .of(context)
                    .size
                    .width / 2) - 100,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ItemBadge(
                      outOfStock: widget.storedsearchdata!.stock!<=0?OutOfStock(singleproduct: false,):null,
                      // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
                      /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):SizedBox.shrink()),*/
                      child: Align(
                        alignment: Alignment.center,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if(widget.fromScreen == "sellingitem_screen") {
                                /* navigatetoSingelproductscreen(context,widget.returnparm,
                                      duration: widget.itemdata.duration,
                                      delivery: widget.itemdata.delivery,
                                      durationType: widget.itemdata.deliveryDuration.durationType,
                                      eligibleforexpress: widget.itemdata!.eligibleForExpress,
                                      fromScreen: widget.fromScreen,
                                      id: widget.itemdata!.id,
                                      note: widget.itemdata.deliveryDuration.note,
                                      imageUrl: widget.itemdata!.itemFeaturedImage,
                                      itemvarData:itemvarData,
                                      seeallpress: widget._seeallpress,
                                      title:widget.itemdata!.itemName,notid: widget._notid );*/
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.id.toString(),"productId": widget.storedsearchdata!.id!});


                              }
                              else{
                                /*navigatetoSingelproductscreen(context,widget.returnparm,
                                      duration: widget.itemdata.duration,
                                      delivery: widget.itemdata.delivery,
                                      durationType: widget.itemdata.deliveryDuration.durationType,
                                      eligibleforexpress: widget.itemdata!.eligibleForExpress,
                                      fromScreen: widget.fromScreen,
                                      id: widget.itemdata!.id,
                                      note: widget.itemdata.deliveryDuration.note,
                                      imageUrl: widget.itemdata!.itemFeaturedImage,
                                      itemvarData:itemvarData,
                                      seeallpress: widget._seeallpress,
                                      title:widget.itemdata!.itemName,notid: widget._notid );*/
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.id.toString(),"productId": widget.storedsearchdata!.id!});
                              }
                              /*
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.itemdata!.id,
                                    "itemname": widget.itemdata!.itemName,
                                    "itemimg": widget.itemdata!.itemFeaturedImage,
                                    "eligibleforexpress": widget.itemdata!.eligibleForExpress,
                                    "delivery": widget.itemdata.delivery,
                                    "duration": widget.itemdata.duration,
                                    "durationType":widget.itemdata.deliveryDuration.durationType,
                                    "note":widget.itemdata.deliveryDuration.note,
                                    "fromScreen":widget.fromScreen,
                                  });*/
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 4.0, bottom: 3.0),
                              child: CachedNetworkImage(
                                imageUrl: widget.storedsearchdata!.itemFeaturedImage,
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
                                height: ResponsiveLayout.isSmallScreen(context) ? 120 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                //  fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    /* !_isStock
                        ? Consumer<Calculations>(
                      builder: (_, cart, ch) =>
                          BadgeOfStock(
                            child: ch,
                            value: margins,
                            singleproduct: false,
                          ),
                      child: GestureDetector(
                        onTap: () {
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              note: widget.note,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                        },
                        child: CachedNetworkImage(
                          imageUrl:*/
                    /*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*widget.itemdata!.priceVariation[itemindex].images.length<=0?widget.itemdata!.itemFeaturedImage:widget.itemdata!.priceVariation[itemindex].images[itemindex].image,
                          placeholder: (context, url) =>
                              Image.asset(
                                Images.defaultProductImg,
                                width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              ),
                          errorWidget: (context, url, error) => Image.asset(
                            Images.defaultProductImg,
                            width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          ),
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          //fit: BoxFit.fill,
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: () {
                        if(widget.fromScreen == "sellingitem_screen") {
                          if (_isStock)
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                          else
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                        }
                        else{
                          if (_isStock)
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                          else
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                        }
                        *//*            Navigator.of(context).pushReplacementNamed(
                            SingleproductScreen.routeName,
                            arguments: {
                              "itemid": widget.id,
                              "itemname": widget.title,
                              "itemimg": widget.imageUrl,
                              'fromScreen': widget.fromScreen,
                              "eligibleforexpress": widget.eligibleforexpress,
                              "delivery": widget.delivery,
                              "duration": widget.duration,
                              "durationType":widget.durationType,
                              "updateItemList": variationdisplaydata,
                              "updateItem": itemvarData,
                            });*//*
                      },
                      child: CachedNetworkImage(
                        imageUrl: *//*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                        placeholder: (context, url) =>
                            Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            ),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.defaultProductImg,
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        ),
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        //fit: BoxFit.fill,
                      ),
                    ),*/
                  ],
                ),
              ),
              // SizedBox(width: 5,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width / 1.6),
                    child: Row(
                      children: [
                        Container(
                            width: (MediaQuery
                                .of(context)
                                .size
                                .width / 2.6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5,),
                                 Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.storedsearchdata!.brand!,
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                               /* Container(
                                  height:30,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.storedsearchdata!.shop!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            //fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                *//*SizedBox(
                                  height: 5,
                                ),*//*
                                Text(
                                  widget.storedsearchdata!.location!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                      /*fontWeight: FontWeight.bold*/),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset(Images.starimg,
                                          height: 12,
                                          width: 12,
                                          color: ColorCodes.darkthemeColor),
                                      SizedBox(width: 3,),
                                      Text(
                                        widget.storedsearchdata!.ratings!.toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: ColorCodes.darkthemeColor),
                                      ),
                                      SizedBox(width: 15,),
                                      Icon(Icons.info, color: ColorCodes.lightGreyColor, size: 6),
                                      SizedBox(width: 15,),
                                      Text(
                                        widget.storedsearchdata!.distance!.toStringAsFixed(2) +
                                            " Km",
                                        style: TextStyle(
                                            fontSize: 11, color: ColorCodes.greyColord),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),*/
                                Container(
                                  height:40,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.storedsearchdata!.itemName!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            //fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                (widget.storedsearchdata!.singleshortNote != "")?
                                Container(
                                  height: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(widget.storedsearchdata!.singleshortNote.toString(),style: TextStyle(fontSize: 12,color: ColorCodes.greyColor,),),
                                    ],
                                  ),
                                ):SizedBox.shrink(),
                                SizedBox(height: 5,),
                                Container(
                                    child: Row(
                                      children: <Widget>[
                                        if(Features.isMembership)
                                          _checkmembership?Container(
                                            width: 10.0,
                                            height: 9.0,
                                            margin: EdgeInsets.only(right: 3.0),
                                            child: Image.asset(
                                              Images.starImg,
                                              color: ColorCodes.starColor,
                                            ),
                                          ):SizedBox.shrink(),
                                        new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                              new TextSpan(
                                                  text: Features.iscurrencyformatalign?
                                                  '${_checkmembership?widget.storedsearchdata!.membershipPrice:widget.storedsearchdata!.price} ' + IConstants.currencyFormat:
                                                  IConstants.currencyFormat + '${_checkmembership?widget.storedsearchdata!.membershipPrice:widget.storedsearchdata!.price} ',
                                                  style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 15 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                              new TextSpan(
                                                  text: widget.storedsearchdata!.price!=widget.storedsearchdata!.mrp?
                                                  Features.iscurrencyformatalign?
                                                  '${widget.storedsearchdata!.mrp} ' + IConstants.currencyFormat:
                                                  IConstants.currencyFormat + '${widget.storedsearchdata!.mrp} ':"",
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration.lineThrough,
                                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                            ],
                                          ),
                                        )
                                        /*  _checkmembership
                                            ? Row(
                                          children: <Widget>[
                                            if(Features.isMembership)
                                              Container(
                                                width: 10.0,
                                                height: 9.0,
                                                margin: EdgeInsets.only(right: 3.0),
                                                child: Image.asset(
                                                  Images.starImg,
                                                ),
                                              ),
                                            memberpriceDisplay
                                                ? new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                  new TextSpan(
                                                      text: IConstants.currencyFormat +
                                                          '$varmemberprice ',
                                                      style: new TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color:
                                                          Colors.black,
                                                          fontSize: 18.0)),
                                                  new TextSpan(
                                                      text:
                                                      IConstants.currencyFormat +
                                                          '$varmrp ',
                                                      style: TextStyle(
                                                        decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                      )),
                                                ],
                                              ),
                                            )
                                                : discountDisplay
                                                ? new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                      text: IConstants.currencyFormat +
                                                          '$varprice ',
                                                      style: new TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .black,
                                                          fontSize:
                                                          18.0)),
                                                  new TextSpan(
                                                      text:
                                                      IConstants.currencyFormat +
                                                          '$varmrp ',
                                                      style: TextStyle(
                                                        decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                      )),
                                                ],
                                              ),
                                            )
                                                : new RichText(
                                              text: new TextSpan(
                                                style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black,
                                                ),
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                      text:
                                                      IConstants.currencyFormat +
                                                          '$varmrp ',
                                                      style: new TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors
                                                              .black,
                                                          fontSize:
                                                          18.0)),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                            : discountDisplay
                                            ? new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: IConstants.currencyFormat +
                                                      '$varprice ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 18.0)),
                                              new TextSpan(
                                                  text: IConstants.currencyFormat +
                                                      '$varmrp ',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )
                                            : new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: IConstants.currencyFormat +
                                                      '$varmrp ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 18.0)),
                                            ],
                                          ),
                                        )*/
                                      ],
                                    )),

                                SizedBox(height: 8,),

                                /* (widget.itemdata!.membershipDisplay!)?
                                SizedBox(height: 4):SizedBox(height: 10),*/
                                VxBuilder(
                                  // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                  builder: (context, GroceStore box, index) {
                                    if(store.userData.membership! == "1"){
                                      _checkmembership = true;
                                    } else {
                                      _checkmembership = false;
                                      for (int i = 0; i < productBox.length; i++) {
                                        if (productBox[i].mode == "1") {
                                          _checkmembership = true;
                                        }
                                      }
                                    }
                                    return Column(
                                      children: [
                                        (Features.isMembership && double.parse(widget.storedsearchdata!.membershipPrice.toString()) > 0)?
                                        Row(
                                          children: [
                                            !_checkmembership
                                                ? widget.storedsearchdata!.membershipDisplay!
                                                ? GestureDetector(
                                              onTap: () {
                                                (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
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
                                                (checkskip && !_isWeb)?
                                                /* Navigator.of(context).pushReplacementNamed(
                                        SignupSelectionScreen.routeName)*/
                                                Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                                                    :/*Navigator.of(context).pushNamed(
                                      MembershipScreen.routeName,
                                    );*/
                                                Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 5,),
                                                width: (MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / 3) +
                                                    5,
                                                height:30,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                                                    // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                  ),
                                                  color: ColorCodes.varcolor,
                                                ),
                                                child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(width: 2),

                                                    Text(
                                                        Features.iscurrencyformatalign?
                                                        widget.storedsearchdata!.membershipPrice.toString() + IConstants.currencyFormat:
                                                        IConstants.currencyFormat +
                                                            widget.storedsearchdata!.membershipPrice.toString()+" Membership Price",
                                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor)),

                                                  ],
                                                ),
                                              ),
                                            )
                                                : SizedBox.shrink()
                                                : SizedBox.shrink(),
                                          ],
                                        ):SizedBox(height: 30,),

                                      ],
                                    );
                                  }, mutations: {ProductMutation,SetCartItem},
                                ),
                              ],
                            )),
                        Container(
                            width: (MediaQuery
                                .of(context)
                                .size
                                .width / 4.5),
                            child: Column(
                              children: [
                                (widget.storedsearchdata!.eligibleForExpress == "0")?
                                Container(
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.express,
                                        height: 20.0,
                                        width: 25.0,),
                                    ],
                                  ),
                                ):SizedBox(height: 40,),
                                SizedBox(height: 8,),
                                /* if(margins > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        //margin: EdgeInsets.only(left: 5.0),
                                        //padding: EdgeInsets.all(3.0),
                                        // color: Theme.of(context).accentColor,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              3.0),
                                          color: ColorCodes.whiteColor,//Color(0xff6CBB3C),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          margins.toStringAsFixed(0) + S .of(context).off ,//"% OFF",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ColorCodes.darkgreen,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),*/
                                Features.isSubscription && widget.storedsearchdata!.eligibleForSubscription=="0"?
                                Container(
                                  height:40,
                                  width: (MediaQuery.of(context).size.width/3)+5 ,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:0,right:0.0),
                                    child: CustomeStepper(searchstoredata: widget.storedsearchdata,from:"search_screen",height: (Features.isSubscription)?40:40,issubscription: "Subscribe",addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null, index: itemindex),
                                  ),
                                ):SizedBox(height:40,),
                                SizedBox(
                                  height: 4.5,
                                ),
                                if(Features.isLoyalty)
                                  (double.parse(widget.storedsearchdata!.loyalty.toString()) > 0)?
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 15.0,
                                          width: 20.0,),
                                        SizedBox(width: 4),
                                        Text(widget.storedsearchdata!.loyalty.toString()),
                                      ],
                                    ),
                                  ):SizedBox(height: 10,),
                                SizedBox(height: 8,),
                                // SizedBox(height: 5,),
                                Container(
                                  height:40,
                                  width: (MediaQuery.of(context).size.width/3)+5 ,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:0,right:0.0),
                                    child: CustomeStepper(searchstoredata: widget.storedsearchdata,from:"search_screen",height: (Features.isSubscription)?40:40,issubscription: "Add",addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null, index: itemindex),
                                  ),
                                ),

                              ],
                            )),
                      ],
                    ),
                  ),
                  if(Features.netWeight && widget.storedsearchdata!.vegType == "fish")
                    Container(
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2) + 70,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                Features.iscurrencyformatalign?
                                "Whole Uncut:" +" " +
                                    widget.storedsearchdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                                "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                    widget.storedsearchdata!.salePrice! +" / "+ "500 G",
                                style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold),),
                            ],
                          ),
                          SizedBox(height: 3),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text("Gross Weight:" +" "+
                                        widget.storedsearchdata!.weight!,
                                        style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  Container(
                                    child: Text("Net Weight:" +" "+
                                        widget.storedsearchdata!.netWeight!,
                                        style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  /* Features.btobModule?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //height: 70,
                        width: (MediaQuery
                            .of(context)
                            .size
                            .width / 2) + 70,
                        // child: SingleChildScrollView(
                        child:
                        GridView.builder(
                            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: widgetsInRow,
                              crossAxisSpacing: 0,
                              childAspectRatio: aspectRatio,
                              mainAxisSpacing: 0,
                            ),
                            controller: new ScrollController(keepScrollOffset: false),
                            shrinkWrap: true,
                            itemCount: variationdisplaydata.length,
                            itemBuilder: (_, i) {
                              return
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {

                                    },
                                    child: Container(
                                        height: 30,
                                        width:90,
                                        decoration: BoxDecoration(
                                          color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                          borderRadius: BorderRadius.circular(5.0),
                                          border: Border.all(
                                            color: ColorCodes.greenColor,
                                          ),
                                        ),
                                        margin: EdgeInsets.only(right: 10,bottom:8),
                                        padding: EdgeInsets.only(right: 5,left:5),
                                        child:

                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                                  style:
                                                  TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),),

                                                _groupValue == i ?
                                                Container(
                                                  width: 18.0,
                                                  height: 18.0,
                                                  margin: EdgeInsets.only(top:3),
                                                  decoration: BoxDecoration(
                                                    color: ColorCodes.greenColor,
                                                    border: Border.all(
                                                      color: ColorCodes.greenColor,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Container(
                                                    margin: EdgeInsets.all(3),
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
                                            ),


                                          ],)


                                    )
                                );

                            }),
                      ),
                      // )
                    ],
                  ):*/
                  Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width/2)+70,
                    child:   Row(
                      children: [
                        Container(
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width /2)+70 ,
                          child: /*(widget.itemdata!.priceVariation!.length > 1)
                              ? GestureDetector(
                            onTap: () {
                              setState(() {
                                showoptions1();
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      *//*  border: Border.all(
                                          color: ColorCodes.greenColor,),*//*
                                        color: ColorCodes.varcolor,
                                        borderRadius:
                                        new BorderRadius.only(
                                          topLeft:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                        )),
                                    height: 30,
                                    padding: EdgeInsets.fromLTRB(
                                        5.0, 4.5, 0.0, 4.5),
                                    child: Text(
                                      "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                      style:
                                      TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                //Spacer(),
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
                                    color: ColorCodes.darkgreen,
                                  ),
                                ),
                              ],
                            ),
                          )
                              :*/

                          Row( mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: ColorCodes.whiteColor,
                                        /* border: Border.all(
                                        color: ColorCodes.greenColor,),*/
                                        borderRadius: new BorderRadius.only(
                                          topLeft:
                                          const Radius.circular(2.0),
                                          topRight:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                          bottomRight:
                                          const Radius.circular(2.0),
                                        )),
                                    height: 10,
                                    padding: EdgeInsets.fromLTRB(
                                        5.0, 4.5, 0.0, 4.5),
                                    child: SizedBox.shrink()/*Text(
                                    "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                    style: TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                                  ),*/
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Spacer(),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   children: [
                        //     SizedBox(
                        //         height: 30.0,
                        //       width: (MediaQuery
                        //           .of(context)
                        //           .size
                        //           .width / 3.8) +
                        //           25,
                        //     child: CustomeStepper(priceVariation: widget.itemdata!.priceVariation[itemindex],itemdata: widget.itemdata,)),
                        //   ],
                        // ),
                      ],
                    ),
                  ),

                  /*    Container(
                      height:30,
                      width:(MediaQuery
                          .of(context)
                          .size
                          .width /2) +
                          70,
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: Features.isSubscription?40:30.0,
                              width: Features.isSubscription?
                              (widget.itemdata!.eligibleForSubscription == "0")?
                              (MediaQuery
                                  .of(context)
                                  .size
                                  .width /2)+67:
                              (MediaQuery
                                  .of(context)
                                  .size
                                  .width /2) +
                                  67 :(MediaQuery
                                  .of(context)
                                  .size
                                  .width /2) +
                                  67,
                              child: CustomeStepper(itemdata: widget.itemdata,alignmnt: StepperAlignment.Horizontal,height:(Features.isSubscription)?90:60,addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![itemindex]:null,index:itemindex,issubscription: "Add",)),

                          SizedBox(width:5),
                          // (Features.isSubscription)?(widget.itemdata!.eligibleForSubscription == "0")?
                          // MouseRegion(
                          //   cursor: SystemMouseCursors.click,
                          //   child: (widget.itemdata!.priceVariation![itemindex].stock !<= 0) ?
                          //   SizedBox(height: 30,)
                          //       :GestureDetector(
                          //     onTap: () {
                          //       if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                          //         //  _dialogforSignIn();
                          //         LoginWeb(context,result: (sucsess){
                          //           if(sucsess){
                          //             Navigator.of(context).pop();
                          //             Navigator.pushNamedAndRemoveUntil(
                          //                 context, HomeScreen.routeName, (route) => false);
                          //           }else{
                          //             Navigator.of(context).pop();
                          //           }
                          //         });
                          //       }
                          //       else {
                          //         (checkskip) ?
                          //         Navigator.of(context).pushNamed(
                          //           SignupSelectionScreen.routeName,
                          //         ) :
                          //         Navigator.of(context).pushNamed(
                          //             SubscribeScreen.routeName,
                          //             arguments: {
                          //               "itemid": widget.itemdata!.id,
                          //               "itemname": widget.itemdata!.itemName,
                          //               "itemimg": widget.itemdata!.itemFeaturedImage,
                          //               "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                          //               "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                          //               "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                          //               "paymentMode": widget.itemdata!.paymentMode,
                          //               "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                          //               "name": widget.itemdata!.subscriptionSlot![0].name,
                          //               "varid":widget.itemdata!.priceVariation![itemindex].id,
                          //               "brand": widget.itemdata!.brand,
                          //             }
                          //         );
                          //       }
                          //     },
                          //     child: Container(
                          //       height: 30.0,
                          //       width:(MediaQuery
                          //       .of(context)
                          //       .size
                          //       .width /3.8)+27,
                          //
                          //       decoration: new BoxDecoration(
                          //           color: ColorCodes.whiteColor,
                          //           border: Border.all(color: Theme.of(context).primaryColor),
                          //           borderRadius: new BorderRadius.only(
                          //             topLeft: const Radius.circular(2.0),
                          //             topRight:
                          //             const Radius.circular(2.0),
                          //             bottomLeft:
                          //             const Radius.circular(2.0),
                          //             bottomRight:
                          //             const Radius.circular(2.0),
                          //           )),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         crossAxisAlignment: CrossAxisAlignment.center,
                          //         children: [
                          //
                          //           Text(
                          //             S .of(context).subscribe,//'SUBSCRIBE',
                          //             style: TextStyle(
                          //                 color: Theme.of(context)
                          //                     .primaryColor,
                          //                 fontSize: 12, fontWeight: FontWeight.bold),
                          //             textAlign: TextAlign.center,
                          //           ),
                          //         ],
                          //       ) ,
                          //     ),
                          //   ),
                          // ):
                          // SizedBox(height: 30,):
                          // SizedBox.shrink(),
                        ],
                      )),*/

                ],
              ),
            ],
          ),
        ),
      ):
      GestureDetector(
        onTap: (){
          if(widget.fromScreen == "sellingitem_screen") {
            if (widget.storedsearchdata!.priceVariation![itemindex].stock !>= 0)
              /*navigatetoSingelproductscreen(context,widget.returnparm,
                  duration: widget.itemdata.duration,
                  delivery: widget.itemdata.delivery,
                  note: widget.itemdata.deliveryDuration.note,
                  durationType: widget.itemdata.deliveryDuration.durationType,
                  eligibleforexpress: widget.itemdata!.eligibleForExpress,
                  fromScreen: widget.fromScreen,
                  id: widget.itemdata!.id,
                  imageUrl: widget.itemdata!.itemFeaturedImage,
                  itemvarData:itemvarData,
                  title:widget.itemdata!.itemName,
                notid: widget._notid,
                seeallpress:widget._seeallpress,
              );*/
              Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
            // else
            // Navigator.of(context).pushReplacementNamed(
            //     SingleproductScreen.routeName,
            //     arguments: {
            //       "itemid": widget.itemdata!.id.toString(),
            //       "itemname": widget.itemdata!.itemName,
            //       'fromScreen': widget.fromScreen,
            //       "itemimg": widget.itemdata!.itemFeaturedImage,
            //       "eligibleforexpress": widget.itemdata!.eligibleForExpress,
            //       "delivery": widget.itemdata.delivery,
            //       "duration": widget.itemdata.duration,
            //       "durationType": widget.itemdata.deliveryDuration.durationType,
            //       "note": widget.itemdata.deliveryDuration.note,
            //       "updateItemList": variationdisplaydata,
            //       "updateItem": itemvarData,
            //       "seeallpress":widget._seeallpress,
            //       "notid":widget._notid,
            //       // "fromScreen":"sellingitem_screen",
            //     });
          }
          else{
            if (widget.storedsearchdata!.priceVariation![itemindex].stock !>= 0)
              /*navigatetoSingelproductscreen(context,widget.returnparm,
                  duration: widget.itemdata.duration,
                  delivery: widget.itemdata.delivery,
                  note: widget.itemdata.deliveryDuration.note,
                  durationType: widget.itemdata.deliveryDuration.durationType,
                  eligibleforexpress: widget.itemdata!.eligibleForExpress,
                  fromScreen: widget.fromScreen,
                  id: widget.itemdata!.id,
                  imageUrl: widget.itemdata!.itemFeaturedImage,
                  itemvarData:itemvarData,
                  title:widget.itemdata!.itemName,
                notid: widget._notid,);*/
              Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
            else
              /* navigatetoSingelproductscreen(context,widget.returnparm,
                  duration: widget.itemdata.duration,
                  delivery: widget.itemdata.delivery,
                  note: widget.itemdata.deliveryDuration.note,
                  durationType: widget.itemdata.deliveryDuration.durationType,
                  eligibleforexpress: widget.itemdata!.eligibleForExpress,
                  fromScreen: widget.fromScreen,
                  id: widget.itemdata!.id,
                  imageUrl: widget.itemdata!.itemFeaturedImage,
                  itemvarData:itemvarData,
                  title:widget.itemdata!.itemName,notid: widget._notid, );*/
              Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            border: (Features.ismultivendor)? Border(
              bottom: BorderSide(width: 0.0, color: Colors.transparent),
            ) : Border(
              bottom: BorderSide(width: 2.0, color: ColorCodes.lightGreyWebColor),
            ),
          ),
          margin: (Features.ismultivendor)? EdgeInsets.only(left: 0.0,  bottom: 0.0, right: 0) : EdgeInsets.only(left: 5.0,  bottom: 0.0, right: 5),
          child: Row(
            children: [
              Container(
                width: (MediaQuery
                    .of(context)
                    .size
                    .width / 2) - 100,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ItemBadge(
                      outOfStock: widget.storedsearchdata!.priceVariation![itemindex].stock!<=0?OutOfStock(singleproduct: false,):null,
                      // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
                      /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,):SizedBox.shrink()),*/
                      child: Align(
                        alignment: Alignment.center,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if(widget.fromScreen == "sellingitem_screen") {
                                /* navigatetoSingelproductscreen(context,widget.returnparm,
                                      duration: widget.itemdata.duration,
                                      delivery: widget.itemdata.delivery,
                                      durationType: widget.itemdata.deliveryDuration.durationType,
                                      eligibleforexpress: widget.itemdata!.eligibleForExpress,
                                      fromScreen: widget.fromScreen,
                                      id: widget.itemdata!.id,
                                      note: widget.itemdata.deliveryDuration.note,
                                      imageUrl: widget.itemdata!.itemFeaturedImage,
                                      itemvarData:itemvarData,
                                      seeallpress: widget._seeallpress,
                                      title:widget.itemdata!.itemName,notid: widget._notid );*/
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});

                              }
                              else{
                                /*navigatetoSingelproductscreen(context,widget.returnparm,
                                      duration: widget.itemdata.duration,
                                      delivery: widget.itemdata.delivery,
                                      durationType: widget.itemdata.deliveryDuration.durationType,
                                      eligibleforexpress: widget.itemdata!.eligibleForExpress,
                                      fromScreen: widget.fromScreen,
                                      id: widget.itemdata!.id,
                                      note: widget.itemdata.deliveryDuration.note,
                                      imageUrl: widget.itemdata!.itemFeaturedImage,
                                      itemvarData:itemvarData,
                                      seeallpress: widget._seeallpress,
                                      title:widget.itemdata!.itemName,notid: widget._notid );*/
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.storedsearchdata!.priceVariation![itemindex].menuItemId.toString()});
                              }
                              /*
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.itemdata!.id,
                                    "itemname": widget.itemdata!.itemName,
                                    "itemimg": widget.itemdata!.itemFeaturedImage,
                                    "eligibleforexpress": widget.itemdata!.eligibleForExpress,
                                    "delivery": widget.itemdata.delivery,
                                    "duration": widget.itemdata.duration,
                                    "durationType":widget.itemdata.deliveryDuration.durationType,
                                    "note":widget.itemdata.deliveryDuration.note,
                                    "fromScreen":widget.fromScreen,
                                  });*/
                            },
                            child:  Stack(
                              children: [
                                if(margins > 0)
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            3.0),
                                        color: ColorCodes.greenColor,//Color(0xff6CBB3C),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 28,
                                        minHeight: 15,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:5.0,right: 5,),
                                        child: Text(
                                          margins.toStringAsFixed(0) + S .of(context).off ,//"% OFF",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: ColorCodes.whiteColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.only(top: 15.0, bottom: 8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.storedsearchdata!.priceVariation![itemindex].images!.length<=0?widget.storedsearchdata!.itemFeaturedImage:widget.storedsearchdata!.priceVariation![itemindex].images![0].image,
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
                                    width: ResponsiveLayout.isSmallScreen(context) ? 115 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    height: ResponsiveLayout.isSmallScreen(context) ? 120 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    //  fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),

                          ),
                        ),
                      ),
                    ),
                    /* !_isStock
                        ? Consumer<Calculations>(
                      builder: (_, cart, ch) =>
                          BadgeOfStock(
                            child: ch,
                            value: margins,
                            singleproduct: false,
                          ),
                      child: GestureDetector(
                        onTap: () {
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              note: widget.note,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                        },
                        child: CachedNetworkImage(
                          imageUrl:*/
                    /*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*widget.itemdata!.priceVariation[itemindex].images.length<=0?widget.itemdata!.itemFeaturedImage:widget.itemdata!.priceVariation[itemindex].images[itemindex].image,
                          placeholder: (context, url) =>
                              Image.asset(
                                Images.defaultProductImg,
                                width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              ),
                          errorWidget: (context, url, error) => Image.asset(
                            Images.defaultProductImg,
                            width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          ),
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          //fit: BoxFit.fill,
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: () {
                        if(widget.fromScreen == "sellingitem_screen") {
                          if (_isStock)
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                          else
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                        }
                        else{
                          if (_isStock)
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                          else
                            navigatetoSingelproductscreen(context,widget.returnparm,
                                duration: widget.duration,
                                delivery: widget.delivery,
                                durationType: widget.durationType,
                                eligibleforexpress: widget.eligibleforexpress,
                                fromScreen: widget.fromScreen,
                                id: widget.id,
                                note: widget.note,
                                imageUrl: widget.imageUrl,
                                itemvarData:itemvarData,
                                title:widget.title );
                        }
                        *//*            Navigator.of(context).pushReplacementNamed(
                            SingleproductScreen.routeName,
                            arguments: {
                              "itemid": widget.id,
                              "itemname": widget.title,
                              "itemimg": widget.imageUrl,
                              'fromScreen': widget.fromScreen,
                              "eligibleforexpress": widget.eligibleforexpress,
                              "delivery": widget.delivery,
                              "duration": widget.duration,
                              "durationType":widget.durationType,
                              "updateItemList": variationdisplaydata,
                              "updateItem": itemvarData,
                            });*//*
                      },
                      child: CachedNetworkImage(
                        imageUrl: *//*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                        placeholder: (context, url) =>
                            Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            ),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.defaultProductImg,
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        ),
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        //fit: BoxFit.fill,
                      ),
                    ),*/
                  ],
                ),
              ),
              SizedBox(width: 5,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Features.btobModule?(MediaQuery
                        .of(context)
                        .size
                        .width / 1.5):(MediaQuery
                        .of(context)
                        .size
                        .width / 1.6),
                    child: Row(
                      children: [
                        Container(
                            width: Features.btobModule?(MediaQuery
                                .of(context)
                                .size
                                .width / 1.5):(MediaQuery
                                .of(context)
                                .size
                                .width / 2.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5,),
                                 Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.storedsearchdata!.brand!,
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                /*Container(
                                  height:30,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.storedsearchdata!.shop!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            //fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                *//*SizedBox(
                                  height: 3,
                                ),*//*
                                Text(
                                  widget.storedsearchdata!.location!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset(Images.starimg,
                                          height: 12,
                                          width: 12,
                                          color: ColorCodes.darkthemeColor),
                                      SizedBox(width: 3,),
                                      Text(
                                        widget.storedsearchdata!.ratings!.toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: ColorCodes.darkthemeColor),
                                      ),
                                      SizedBox(width: 15,),
                                      Icon(Icons.info, color: ColorCodes.lightGreyColor, size: 6),
                                      SizedBox(width: 15,),
                                      Text(
                                        widget.storedsearchdata!.distance!.toStringAsFixed(2) +
                                            " Km",
                                        style: TextStyle(
                                            fontSize: 11, color: ColorCodes.greyColord),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),*/
                                Container(
                                  height:40,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.storedsearchdata!.itemName!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            //fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                widget.storedsearchdata!.priceVariation!.length > 1?
                                Features.btobModule?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      //height: 70,
                                      width: /*(MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2) + 70,*/
                                      (MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2)+20,
                                      // child: SingleChildScrollView(
                                      child:
                                      GridView.builder(
                                          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: widgetsInRow,
                                            crossAxisSpacing: 0,
                                            childAspectRatio: aspectRatio,
                                            mainAxisSpacing: 0,
                                          ),
                                          controller: new ScrollController(keepScrollOffset: false),
                                          shrinkWrap: true,
                                          itemCount: widget.storedsearchdata!.priceVariation!.length,
                                          itemBuilder: (_, i) {
                                            return
                                              GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: () async {
                                                    setState(() {
                                                      _groupValue = i;
                                                    });
                                                    print("hdhvsdhsdfds"+""+widget.storedsearchdata!.id!+"..."+widget.storedsearchdata!.priceVariation![0].id.toString() +
                                                        "..var id.." + varid.toString());
                                                    if(productBox
                                                        .where((element) =>
                                                    element.itemId! == widget.storedsearchdata!.id
                                                    ).length >= 1) {
                                                      cartcontroller.update((done) {
                                                        print("done value in calling update " + done.toString());
                                                        setState(() {

                                                        });
                                                      }, price: widget.storedsearchdata!.price.toString(),
                                                          quantity: widget.storedsearchdata!.priceVariation![i].minItem.toString(),
                                                          type: widget.storedsearchdata!.type,
                                                          weight: (/*weight +*/
                                                              double.parse(widget.storedsearchdata!.increament!)).toString(),
                                                          var_id: /*widget.itemdata!.id!*/widget.storedsearchdata!.priceVariation![0].id.toString(),
                                                          increament: widget.storedsearchdata!.increament,
                                                          cart_id: productBox
                                                              .where((element) =>
                                                          element.itemId! == widget.storedsearchdata!.id
                                                          ).first.parent_id.toString(),
                                                          toppings: "",
                                                          topping_id: "",
                                                          item_id: widget.storedsearchdata!.id!

                                                      );
                                                    }
                                                    else {
                                                      cartcontroller.addtoCart(storeSearchData: widget.storedsearchdata,
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
                                                          varid: widget.storedsearchdata!.priceVariation![0].id,
                                                          toppings: "",
                                                          parent_id: "",
                                                          newproduct: "0",
                                                          toppingsList: [],
                                                          itembodysearch:  widget.storedsearchdata!.priceVariation![i],
                                                          context: context);
                                                      print("group value....2" + _groupValue.toString());
                                                    }

                                                  },
                                                  child: Container(
                                                      height: 50,
                                                      width:90,
                                                      decoration: BoxDecoration(
                                                        color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        border: Border.all(
                                                          color: ColorCodes.greenColor,
                                                        ),
                                                      ),
                                                      margin: EdgeInsets.only(right: 10,bottom:2),
                                                      padding: EdgeInsets.only(right: 5,left:5),
                                                      child:

                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                "${widget.storedsearchdata!.priceVariation![i].minItem}"+"-"+"${widget.storedsearchdata!.priceVariation![i].maxItem}"+" "+"${widget.storedsearchdata!.priceVariation![i].unit}",
                                                                style:
                                                                TextStyle(color: _groupValue == i ?ColorCodes.darkgreen:ColorCodes.blackColor,fontWeight: FontWeight.bold,fontSize: 12),),

                                                              _groupValue == i ?
                                                              Container(
                                                                width: 18.0,
                                                                height: 18.0,
                                                                margin: EdgeInsets.only(top:3),
                                                                decoration: BoxDecoration(
                                                                  color: ColorCodes.greenColor,
                                                                  border: Border.all(
                                                                    color: ColorCodes.greenColor,
                                                                  ),
                                                                  shape: BoxShape.circle,
                                                                ),
                                                                child: Container(
                                                                  margin: EdgeInsets.all(3),
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
                                                          ),

                                                          if(Features.isMembership)
                                                            _checkmembership?Container(
                                                              width: 10.0,
                                                              height: 9.0,
                                                              margin: EdgeInsets.only(right: 3.0),
                                                              child: Image.asset(
                                                                Images.starImg,
                                                                color: ColorCodes.starColor,
                                                              ),
                                                            ):SizedBox.shrink(),
                                                          new RichText(
                                                            text: new TextSpan(
                                                              style: new TextStyle(
                                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12,
                                                                color: _groupValue == i ?ColorCodes.darkgreen:ColorCodes.blackColor,
                                                              ),
                                                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                                new TextSpan(
                                                                    text: Features.iscurrencyformatalign?
                                                                    '${_checkmembership?widget.storedsearchdata!.priceVariation![i].membershipPrice:widget.storedsearchdata!.priceVariation![i].price} ' + IConstants.currencyFormat:
                                                                    IConstants.currencyFormat + '${_checkmembership?widget.storedsearchdata!.priceVariation![i].membershipPrice:widget.storedsearchdata!.priceVariation![i].price} ',
                                                                    style: new TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                      color: _groupValue == i ?ColorCodes.darkgreen:ColorCodes.blackColor,
                                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12,)),
                                                                new TextSpan(
                                                                    text: widget.storedsearchdata!.priceVariation![i].price!=widget.storedsearchdata!.priceVariation![i].mrp?
                                                                    Features.iscurrencyformatalign?
                                                                    '${widget.storedsearchdata!.priceVariation![i].mrp} ' + IConstants.currencyFormat:
                                                                    IConstants.currencyFormat + '${widget.storedsearchdata!.priceVariation![i].mrp} ':"",
                                                                    style: TextStyle(
                                                                      decoration:
                                                                      TextDecoration.lineThrough,
                                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                                              ],
                                                            ),
                                                          )


                                                        ],)


                                                  )
                                              );

                                          })
                                    ),
                                    // )
                                  ],
                                ):
                                Container(
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width / 3),
                                  child:   Row(
                                    children: [
                                      Container(
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width /3),
                                        child: (widget.storedsearchdata!.priceVariation!.length > 1)
                                            ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showoptions1();
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 40,
                                                child: Text(
                                                  "${widget.storedsearchdata!.priceVariation![itemindex].variationName}"+" "+"${widget.storedsearchdata!.priceVariation![itemindex].unit}",
                                                  style:
                                                  TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              //SizedBox(width: 10,),
                                              Icon(
                                                Icons.keyboard_arrow_down,
                                                color: ColorCodes.darkgreen,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        )
                                            : Row( mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                /* decoration: BoxDecoration(
                                                    color: ColorCodes.varcolor,
                                                    *//* border: Border.all(
                                        color: ColorCodes.greenColor,),*//*
                                                    borderRadius: new BorderRadius.only(
                                                      topLeft:
                                                      const Radius.circular(2.0),
                                                      topRight:
                                                      const Radius.circular(2.0),
                                                      bottomLeft:
                                                      const Radius.circular(2.0),
                                                      bottomRight:
                                                      const Radius.circular(2.0),
                                                    )),*/
                                                height: 40,
                                                child: Text(
                                                  "${widget.storedsearchdata!.priceVariation![itemindex].variationName}"+" "+"${widget.storedsearchdata!.priceVariation![itemindex].unit}",
                                                  style: TextStyle(color: ColorCodes.greyColor,fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ):SizedBox.shrink(),
                                Container(
                                    child: Row(
                                      children: <Widget>[
                                        if(!Features.btobModule)
                                        if(Features.isMembership)
                                          _checkmembership?Container(
                                            width: 10.0,
                                            height: 9.0,
                                            margin: EdgeInsets.only(right: 3.0),
                                            child: Image.asset(
                                              Images.starImg,
                                              color: ColorCodes.starColor,
                                            ),
                                          ):SizedBox.shrink(),
                                        if(!Features.btobModule)
                                        new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                              new TextSpan(
                                                  text: Features.iscurrencyformatalign?
                                                  '${_checkmembership?widget.storedsearchdata!.priceVariation![itemindex].membershipPrice:widget.storedsearchdata!.priceVariation![itemindex].price} ' + IConstants.currencyFormat:
                                                  IConstants.currencyFormat + '${_checkmembership?widget.storedsearchdata!.priceVariation![itemindex].membershipPrice:widget.storedsearchdata!.priceVariation![itemindex].price} ',
                                                  style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 15 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                              new TextSpan(
                                                  text: widget.storedsearchdata!.priceVariation![itemindex].price!=widget.storedsearchdata!.priceVariation![itemindex].mrp?
                                                  Features.iscurrencyformatalign?
                                                  '${widget.storedsearchdata!.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
                                                  IConstants.currencyFormat + '${widget.storedsearchdata!.priceVariation![itemindex].mrp} ':"",
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration.lineThrough,
                                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                            ],
                                          ),
                                        )

                                      ],
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Features.btobModule?
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text(S.of(context).total,style: TextStyle(color: ColorCodes.blackColor)),
                                        productBox
                                            .where((element) =>
                                        element.itemId == widget.storedsearchdata!.id).length > 0?
                                        Text( IConstants.currencyFormat + (double.parse(widget.storedsearchdata!.priceVariation![_groupValue].price!) * /*(double.parse(productBox
                              .where((element) =>
                          element.itemId! == widget._itemdata.id
                          ).first.quantity!))*/_count).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                          style: TextStyle(
                                              color: ColorCodes.greenColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                          ),): Text( IConstants.currencyFormat + (double.parse(widget.storedsearchdata!.priceVariation![itemindex].price!)).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                          style: TextStyle(
                                              color: ColorCodes.greenColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15
                                          ),),


                                      ],
                                    ),
                                    SizedBox(width:10),
                                    Container(
                                      height:40,
                                      width: (MediaQuery.of(context).size.width/3)+5 ,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:0,right:0.0),
                                        child:
                                        CustomeStepper(priceVariationSearch:widget.storedsearchdata!.priceVariation![itemindex],searchstoredata: widget.storedsearchdata,from:"search_screen",height: (Features.isSubscription)?40:40,issubscription: "Add",addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null, index: itemindex,groupvalue: _groupValue,onChange: (int value,int count){
                                          setState(() {
                                            _groupValue = value;
                                            _count = count;
                                          });
                                        }),
                                         
                                         

                                      /*CustomeStepper(priceVariationSearch:widget.storedsearchdata!.priceVariation![itemindex],searchstoredata: widget.storedsearchdata,from:"item_screen",height: (Features.isSubscription)?90:60,issubscription: "Add",addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null, index: itemindex,groupvalue: _groupValue,onChange: (int value,int count){
                                          setState(() {
                                            _groupValue = value;
                                            _count = count;
                                          });
                                          print("selling item grpoupvalue..."+_groupValue.toString()+"..."+value.toString());
                                        }),*/
                                      ),
                                    ),
                                  ],
                                ):SizedBox.shrink(),
                                /*(widget.itemdata!.priceVariation![itemindex].membershipDisplay!)?
                                SizedBox(height: 4):SizedBox(height: 10),*/
                                VxBuilder(
                                  // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                  builder: (context, GroceStore box, index) {
                                    if(store.userData.membership! == "1"){
                                      _checkmembership = true;
                                    } else {
                                      _checkmembership = false;
                                      for (int i = 0; i < productBox.length; i++) {
                                        if (productBox[i].mode == "1") {
                                          _checkmembership = true;
                                        }
                                      }
                                    }
                                    return Column(
                                      children: [
                                        if(Features.isMembership && double.parse(widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString()) > 0)
                                          Row(
                                            children: [
                                              !_checkmembership
                                                  ? widget.storedsearchdata!.priceVariation![itemindex].membershipDisplay!
                                                  ? GestureDetector(
                                                onTap: () {
                                                  (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
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
                                                  (checkskip && !_isWeb)?
                                                  /* Navigator.of(context).pushReplacementNamed(
                                        SignupSelectionScreen.routeName)*/
                                                  Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                                                      :/*Navigator.of(context).pushNamed(
                                      MembershipScreen.routeName,
                                    );*/
                                                  Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5,),
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width / 3) +
                                                      5,
                                                  height:30,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      left: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                                                      // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                    ),
                                                    color: ColorCodes.varcolor,
                                                  ),
                                                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: 2),

                                                      Text(
                                                          Features.iscurrencyformatalign?
                                                          widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                                          IConstants.currencyFormat +
                                                              widget.storedsearchdata!.priceVariation![itemindex].membershipPrice.toString() + " Membership Price",
                                                          style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                                                    ],
                                                  ),
                                                ),
                                              )
                                                  : SizedBox.shrink()
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        /*!_checkmembership
                                            ? widget.itemdata!.priceVariation![itemindex].membershipDisplay!
                                            ? SizedBox(
                                          height: 1,
                                        )
                                            : SizedBox(
                                          height: 1,
                                        )
                                            : SizedBox(
                                          height: 1,
                                        ),*/
                                      ],
                                    );
                                  }, mutations: {ProductMutation,SetCartItem},
                                ),
                              ],
                            )),
                        !Features.btobModule?
                        Container(
                            width: (MediaQuery
                                .of(context)
                                .size
                                .width / 4.5),
                            child: Column(
                              children: [
                                (widget.storedsearchdata!.eligibleForExpress == "0")?
                                Container(
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.express,
                                        height: 20.0,
                                        width: 25.0,),
                                    ],
                                  ),
                                ):SizedBox(height: 40,),
                                SizedBox(height: 8,),

                                Features.isSubscription && widget.storedsearchdata!.eligibleForSubscription=="0"?
                                Container(
                                  height:40,

                                  child: CustomeStepper(priceVariationSearch:widget.storedsearchdata!.priceVariation![itemindex],searchstoredata: widget.storedsearchdata,from:"search_screen",height: (Features.isSubscription)?40:40,issubscription: "Subscribe",addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null, index: itemindex),
                                ):SizedBox(height: 40,),


                                if(Features.isLoyalty)
                                  (double.parse(widget.storedsearchdata!.priceVariation![itemindex].loyalty.toString()) > 0)?
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 15.0,
                                          width: 20.0,),
                                        SizedBox(width: 4),
                                        Text(widget.storedsearchdata!.priceVariation![itemindex].loyalty.toString()),
                                      ],
                                    ),
                                  ):SizedBox(height: 10,),
                                SizedBox(height: 8,),
                                Container(
                                  height:40,
                                  width: (MediaQuery.of(context).size.width/3)+5 ,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:0,right:0.0),
                                    child: CustomeStepper(priceVariationSearch: widget.storedsearchdata!.priceVariation![itemindex],searchstoredata:widget.storedsearchdata,from:"search_screen",height: (Features.isSubscription)?40:40,issubscription: "Add",addon:(widget.storedsearchdata!.addon!.length > 0)?widget.storedsearchdata!.addon![0]:null, index: itemindex),
                                  ),
                                )

                              ],
                            )):SizedBox.shrink(),
                      ],
                    ),
                  ),
                  if(Features.netWeight && widget.storedsearchdata!.vegType == "fish")
                    Container(
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2) + 70,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                Features.iscurrencyformatalign?
                                "Whole Uncut:" +" " +
                                    widget.storedsearchdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                                "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                    widget.storedsearchdata!.salePrice! +" / "+ "500 G",
                                style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold),),
                            ],
                          ),
                          SizedBox(height: 3),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text("Gross Weight:" +" "+
                                        widget.storedsearchdata!.priceVariation![itemindex].weight!,
                                        style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  Container(
                                    child: Text("Net Weight:" +" "+
                                        widget.storedsearchdata!.priceVariation![itemindex].netWeight!,
                                        style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // SizedBox(height: 5,),


                ],
              ),
            ],
          ),
        ),
      ):


      widget.itemdata!.type=="1"?
      Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
             bottom: BorderSide(width: 2.0, color: ColorCodes.lightGreyWebColor),
          ),
        ),
        margin: EdgeInsets.only(left: 5.0, bottom: 0.0, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: (MediaQuery
                  .of(context)
                  .size
                  .width / 2) - 75,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ItemBadge(
                        outOfStock: widget.itemdata!.stock!<=0?OutOfStock(singleproduct: false,):null,
                        // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
                        /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                          height: 20.0,
                          width: 25.0,):SizedBox.shrink()),*/
                        child: Align(
                          alignment: Alignment.center,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if(widget.fromScreen == "sellingitem_screen") {

                                  Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.id.toString(),"productId": widget.itemdata!.id!});


                                }
                                else{

                                  Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.id.toString(),"productId": widget.itemdata!.id!});
                                }

                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                                child: CachedNetworkImage(
                                  imageUrl: widget.itemdata!.itemFeaturedImage,
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
                                  height: ResponsiveLayout.isSmallScreen(context) ? 120 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  //  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            if(margins > 0)
                              Container(
                                color: ColorCodes.primaryColor,

                                // constraints: BoxConstraints(
                                //   minWidth: 28,
                                //   minHeight: 15,
                                // ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 8, top:4, bottom: 4),
                                  child: Text(
                                    margins.toStringAsFixed(0) + S .of(context).off ,//"% OFF",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: ColorCodes.whiteColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            if(margins > 0)
                              Spacer(),

                            (widget.itemdata!.eligibleForExpress == "0")?
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: ColorCodes.varcolor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2, right: 2, top:4, bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      S .of(context).express ,//"% OFF",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 2),
                                    Image.asset(Images.express,
                                      color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                      height: 11.0,
                                      width: 11.0,),

                                  ],
                                ),
                              ),
                            ) : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  /* !_isStock
                      ? Consumer<Calculations>(
                    builder: (_, cart, ch) =>
                        BadgeOfStock(
                          child: ch,
                          value: margins,
                          singleproduct: false,
                        ),
                    child: GestureDetector(
                      onTap: () {
                        navigatetoSingelproductscreen(context,widget.returnparm,
                            duration: widget.duration,
                            delivery: widget.delivery,
                            note: widget.note,
                            durationType: widget.durationType,
                            eligibleforexpress: widget.eligibleforexpress,
                            fromScreen: widget.fromScreen,
                            id: widget.id,
                            imageUrl: widget.imageUrl,
                            itemvarData:itemvarData,
                            title:widget.title );
                      },
                      child: CachedNetworkImage(
                        imageUrl:*/
                  /*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*widget.itemdata!.priceVariation[itemindex].images.length<=0?widget.itemdata!.itemFeaturedImage:widget.itemdata!.priceVariation[itemindex].images[itemindex].image,
                        placeholder: (context, url) =>
                            Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            ),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.defaultProductImg,
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        ),
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        //fit: BoxFit.fill,
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      if(widget.fromScreen == "sellingitem_screen") {
                        if (_isStock)
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                        else
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                      }
                      else{
                        if (_isStock)
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                        else
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                      }
                      *//*            Navigator.of(context).pushReplacementNamed(
                          SingleproductScreen.routeName,
                          arguments: {
                            "itemid": widget.id,
                            "itemname": widget.title,
                            "itemimg": widget.imageUrl,
                            'fromScreen': widget.fromScreen,
                            "eligibleforexpress": widget.eligibleforexpress,
                            "delivery": widget.delivery,
                            "duration": widget.duration,
                            "durationType":widget.durationType,
                            "updateItemList": variationdisplaydata,
                            "updateItem": itemvarData,
                          });*//*
                    },
                    child: CachedNetworkImage(
                      imageUrl: *//*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                      placeholder: (context, url) =>
                          Image.asset(
                            Images.defaultProductImg,
                            width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          ),
                      errorWidget: (context, url, error) => Image.asset(
                        Images.defaultProductImg,
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      ),
                      width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      //fit: BoxFit.fill,
                    ),
                  ),*/
                ],
              ),
            ),
            SizedBox(width: 5,),
            Column(
              mainAxisAlignment: Features.btobModule?MainAxisAlignment.start:MainAxisAlignment.center,
              children: [
                Container(
                  width: (MediaQuery
                      .of(context)
                      .size
                      .width / 2) + 55,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width / 2.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        widget.itemdata!.brand!,
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4,),
                              Container(
                                height:38,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        widget.itemdata!.itemName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          //fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              (widget.itemdata!.singleshortNote != "" || widget.itemdata!.singleshortNote != "0")?
                              Container(
                                height: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(widget.itemdata!.singleshortNote.toString(),style: TextStyle(fontSize: 10,color: ColorCodes.greyColor,),),
                                  ],
                                ),
                              ):SizedBox.shrink(),
                              if(widget.itemdata!.singleshortNote != "" || widget.itemdata!.singleshortNote != "0")SizedBox(height: 4,),
                              VxBuilder(
                                // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                builder: (context, GroceStore box, index) {
                                  if(store.userData.membership! == "1"){
                                    _checkmembership = true;
                                  } else {
                                    _checkmembership = false;
                                    for (int i = 0; i < productBox.length; i++) {
                                      if (productBox[i].mode == "1") {
                                        _checkmembership = true;
                                      }
                                    }
                                  }
                                  return Column(
                                    children: [
                                      (Features.isMembership && double.parse(widget.itemdata!.membershipPrice.toString()) > 0)?
                                      Row(
                                        children: [
                                          !_checkmembership
                                              ? widget.itemdata!.membershipDisplay!
                                              ? GestureDetector(
                                            onTap: () {
                                              (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
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
                                              (checkskip && !_isWeb)?
                                              /* Navigator.of(context).pushReplacementNamed(
                                      SignupSelectionScreen.routeName)*/
                                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                                                  :/*Navigator.of(context).pushNamed(
                                    MembershipScreen.routeName,
                                  );*/
                                              Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 5,),
                                              width: (MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width / 3.5) /*+
                                                  5*/,
                                              height:22,
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
                                                  SizedBox(width: 2),
                                                  SizedBox(width: 2),
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
                                                      Features.iscurrencyformatalign?
                                                      widget.itemdata!.membershipPrice.toString() + IConstants.currencyFormat:
                                                      IConstants.currencyFormat +
                                                          widget.itemdata!.membershipPrice.toString()/*+" Membership Price"*/,
                                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor)),

                                                ],
                                              ),
                                            ),
                                          )
                                              : SizedBox(height:22,)
                                              : SizedBox.shrink(),
                                        ],
                                      ):SizedBox(height: 10,),
                                    ],
                                  );
                                }, mutations: {ProductMutation,SetCartItem},
                              ),
                              SizedBox(height: 4,),
                              Container(
                                  child: Row(
                                    children: <Widget>[
                                      if(Features.isMembership)
                                        _checkmembership?Container(
                                          width: 10.0,
                                          height: 9.0,
                                          margin: EdgeInsets.only(right: 3.0),
                                          child: Image.asset(
                                            Images.starImg,
                                            color: ColorCodes.starColor,
                                          ),
                                        ):SizedBox.shrink(),
                                      new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                            new TextSpan(
                                                text: Features.iscurrencyformatalign?
                                                '${_checkmembership?widget.itemdata!.membershipPrice:widget.itemdata!.price} ' + IConstants.currencyFormat:
                                                IConstants.currencyFormat + '${_checkmembership?widget.itemdata!.membershipPrice:widget.itemdata!.price} ',
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 15 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                            new TextSpan(
                                                text: widget.itemdata!.price!=widget.itemdata!.mrp?
                                                Features.iscurrencyformatalign?
                                                '${widget.itemdata!.mrp} ' + IConstants.currencyFormat:
                                                IConstants.currencyFormat + '${widget.itemdata!.mrp} ':"",
                                                style: TextStyle(
                                                  decoration:
                                                  TextDecoration.lineThrough,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          )),
                      Container(
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width / 4.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if(Features.isLoyalty)
                                (double.parse(widget.itemdata!.loyalty.toString()) > 0)?
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.coinImg,
                                        height: 12.0,
                                        width: 15.0,),
                                      SizedBox(width: 2),
                                      Text(widget.itemdata!.loyalty.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize:11),),
                                    ],
                                  ),
                                ):SizedBox(height: 10,),
                              SizedBox(height: 4,),
                              (Features.isSubscription && widget.itemdata!.eligibleForSubscription=="0")?
                              Container(
                                height:40,
                                width: (MediaQuery.of(context).size.width/3)+5 ,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:0,right:0.0),
                                  child: CustomeStepper(itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Subscribe",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null, index: itemindex),
                                ),
                              ):  SizedBox(height: 40,),
                              // SizedBox(
                              //   height: 4.5,
                              // ),

                              SizedBox(height: 30,),
                              Container(
                                height:40,
                                width: (MediaQuery.of(context).size.width/3)+5 ,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:0,right:0.0),
                                  child: CustomeStepper(itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Add",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![itemindex]:null, index: itemindex),
                                ),
                              ),

                            ],
                          )),
                    ],
                  ),
                ),
                (Features.netWeight && widget.itemdata!.vegType == "fish")?
                  Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width / 2) + 70,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              Features.iscurrencyformatalign?
                              "Whole Uncut:" +" " +
                                  widget.itemdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                              "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                  widget.itemdata!.salePrice! +" / "+ "500 G",
                              style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: 3),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text("Gross Weight:" +" "+
                                      widget.itemdata!.weight!,
                                      style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                  ),
                                ),
                                Container(
                                  child: Text("Net Weight:" +" "+
                                      widget.itemdata!.netWeight!,
                                      style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ): SizedBox.shrink(),

               /* Features.btobModule?
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      //height: 70,
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2) + 70,
                      // child: SingleChildScrollView(
                      child:
                      GridView.builder(
                          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widgetsInRow,
                            crossAxisSpacing: 0,
                            childAspectRatio: aspectRatio,
                            mainAxisSpacing: 0,
                          ),
                          controller: new ScrollController(keepScrollOffset: false),
                          shrinkWrap: true,
                          itemCount: variationdisplaydata.length,
                          itemBuilder: (_, i) {
                            return
                              GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {

                                  },
                                  child: Container(
                                      height: 30,
                                      width:90,
                                      decoration: BoxDecoration(
                                        color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: ColorCodes.greenColor,
                                        ),
                                      ),
                                      margin: EdgeInsets.only(right: 10,bottom:8),
                                      padding: EdgeInsets.only(right: 5,left:5),
                                      child:

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                                style:
                                                TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),),

                                              _groupValue == i ?
                                              Container(
                                                width: 18.0,
                                                height: 18.0,
                                                margin: EdgeInsets.only(top:3),
                                                decoration: BoxDecoration(
                                                  color: ColorCodes.greenColor,
                                                  border: Border.all(
                                                    color: ColorCodes.greenColor,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Container(
                                                  margin: EdgeInsets.all(3),
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
                                          ),


                                        ],)


                                  )
                              );

                          }),
                    ),
                    // )
                  ],
                ):*/
                // Container(
                //   width: (MediaQuery
                //       .of(context)
                //       .size
                //       .width/2)+70,
                //   child:   Row(
                //     children: [
                //       Container(
                //         width: (MediaQuery
                //             .of(context)
                //             .size
                //             .width /2)+70 ,
                //         child: /*(widget.itemdata!.priceVariation!.length > 1)
                //             ? GestureDetector(
                //           onTap: () {
                //             setState(() {
                //               showoptions1();
                //             });
                //           },
                //           child: Row(
                //             children: [
                //               Expanded(
                //                 child: Container(
                //                   decoration: BoxDecoration(
                //                     *//*  border: Border.all(
                //                         color: ColorCodes.greenColor,),*//*
                //                       color: ColorCodes.varcolor,
                //                       borderRadius:
                //                       new BorderRadius.only(
                //                         topLeft:
                //                         const Radius.circular(2.0),
                //                         bottomLeft:
                //                         const Radius.circular(2.0),
                //                       )),
                //                   height: 30,
                //                   padding: EdgeInsets.fromLTRB(
                //                       5.0, 4.5, 0.0, 4.5),
                //                   child: Text(
                //                     "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                //                     style:
                //                     TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                //                   ),
                //                 ),
                //               ),
                //               //Spacer(),
                //               Container(
                //                 height: 30,
                //                 decoration: BoxDecoration(
                //                     color: ColorCodes.varcolor,
                //                     borderRadius: new BorderRadius.only(
                //                       topRight:
                //                       const Radius.circular(2.0),
                //                       bottomRight:
                //                       const Radius.circular(2.0),
                //                     )),
                //                 child: Icon(
                //                   Icons.keyboard_arrow_down,
                //                   color: ColorCodes.darkgreen,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         )
                //             :*/
                //
                //         Row( mainAxisSize: MainAxisSize.max,
                //           children: [
                //             Expanded(
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                     color: ColorCodes.whiteColor,
                //                     /* border: Border.all(
                //                       color: ColorCodes.greenColor,),*/
                //                     borderRadius: new BorderRadius.only(
                //                       topLeft:
                //                       const Radius.circular(2.0),
                //                       topRight:
                //                       const Radius.circular(2.0),
                //                       bottomLeft:
                //                       const Radius.circular(2.0),
                //                       bottomRight:
                //                       const Radius.circular(2.0),
                //                     )),
                //                 height: 10,
                //                 padding: EdgeInsets.fromLTRB(
                //                     5.0, 4.5, 0.0, 4.5),
                //                 child: SizedBox.shrink()/*Text(
                //                   "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                //                   style: TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                //                 ),*/
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       // Spacer(),
                //       // Row(
                //       //   mainAxisAlignment: MainAxisAlignment.end,
                //       //   crossAxisAlignment: CrossAxisAlignment.end,
                //       //   children: [
                //       //     SizedBox(
                //       //         height: 30.0,
                //       //       width: (MediaQuery
                //       //           .of(context)
                //       //           .size
                //       //           .width / 3.8) +
                //       //           25,
                //       //     child: CustomeStepper(priceVariation: widget.itemdata!.priceVariation[itemindex],itemdata: widget.itemdata,)),
                //       //   ],
                //       // ),
                //     ],
                //   ),
                // ),

            /*    Container(
                    height:30,
                    width:(MediaQuery
                        .of(context)
                        .size
                        .width /2) +
                        70,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: Features.isSubscription?40:30.0,
                            width: Features.isSubscription?
                            (widget.itemdata!.eligibleForSubscription == "0")?
                            (MediaQuery
                                .of(context)
                                .size
                                .width /2)+67:
                            (MediaQuery
                                .of(context)
                                .size
                                .width /2) +
                                67 :(MediaQuery
                                .of(context)
                                .size
                                .width /2) +
                                67,
                            child: CustomeStepper(itemdata: widget.itemdata,alignmnt: StepperAlignment.Horizontal,height:(Features.isSubscription)?90:60,addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![itemindex]:null,index:itemindex,issubscription: "Add",)),

                        SizedBox(width:5),
                        // (Features.isSubscription)?(widget.itemdata!.eligibleForSubscription == "0")?
                        // MouseRegion(
                        //   cursor: SystemMouseCursors.click,
                        //   child: (widget.itemdata!.priceVariation![itemindex].stock !<= 0) ?
                        //   SizedBox(height: 30,)
                        //       :GestureDetector(
                        //     onTap: () {
                        //       if(checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context)){
                        //         //  _dialogforSignIn();
                        //         LoginWeb(context,result: (sucsess){
                        //           if(sucsess){
                        //             Navigator.of(context).pop();
                        //             Navigator.pushNamedAndRemoveUntil(
                        //                 context, HomeScreen.routeName, (route) => false);
                        //           }else{
                        //             Navigator.of(context).pop();
                        //           }
                        //         });
                        //       }
                        //       else {
                        //         (checkskip) ?
                        //         Navigator.of(context).pushNamed(
                        //           SignupSelectionScreen.routeName,
                        //         ) :
                        //         Navigator.of(context).pushNamed(
                        //             SubscribeScreen.routeName,
                        //             arguments: {
                        //               "itemid": widget.itemdata!.id,
                        //               "itemname": widget.itemdata!.itemName,
                        //               "itemimg": widget.itemdata!.itemFeaturedImage,
                        //               "varname": widget.itemdata!.priceVariation![itemindex].variationName!+widget.itemdata!.priceVariation![itemindex].unit!,
                        //               "varmrp":widget.itemdata!.priceVariation![itemindex].mrp,
                        //               "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![itemindex].membershipPrice.toString() :widget.itemdata!.priceVariation![itemindex].discointDisplay! ?widget.itemdata!.priceVariation![itemindex].price.toString():widget.itemdata!.priceVariation![itemindex].mrp.toString(),
                        //               "paymentMode": widget.itemdata!.paymentMode,
                        //               "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                        //               "name": widget.itemdata!.subscriptionSlot![0].name,
                        //               "varid":widget.itemdata!.priceVariation![itemindex].id,
                        //               "brand": widget.itemdata!.brand,
                        //             }
                        //         );
                        //       }
                        //     },
                        //     child: Container(
                        //       height: 30.0,
                        //       width:(MediaQuery
                        //       .of(context)
                        //       .size
                        //       .width /3.8)+27,
                        //
                        //       decoration: new BoxDecoration(
                        //           color: ColorCodes.whiteColor,
                        //           border: Border.all(color: Theme.of(context).primaryColor),
                        //           borderRadius: new BorderRadius.only(
                        //             topLeft: const Radius.circular(2.0),
                        //             topRight:
                        //             const Radius.circular(2.0),
                        //             bottomLeft:
                        //             const Radius.circular(2.0),
                        //             bottomRight:
                        //             const Radius.circular(2.0),
                        //           )),
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: [
                        //
                        //           Text(
                        //             S .of(context).subscribe,//'SUBSCRIBE',
                        //             style: TextStyle(
                        //                 color: Theme.of(context)
                        //                     .primaryColor,
                        //                 fontSize: 12, fontWeight: FontWeight.bold),
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ],
                        //       ) ,
                        //     ),
                        //   ),
                        // ):
                        // SizedBox(height: 30,):
                        // SizedBox.shrink(),
                      ],
                    )),*/

              ],
            ),
          ],
        ),
      ):
      Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 2.0, color: ColorCodes.lightGreyWebColor),
          ),
        ),
        margin: EdgeInsets.only(left: 5.0,  bottom: 0.0, right: 5),
        child: Row(
          children: [
            Container(
              width: (MediaQuery
                  .of(context)
                  .size
                  .width / 2) - 75,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ItemBadge(
                    outOfStock: widget.itemdata!.priceVariation![itemindex].stock!<=0?OutOfStock(singleproduct: false,):null,
                   // badgeDiscount: BadgeDiscounts(value: margins.toStringAsFixed(0)),
                   /* widgetBadge: WidgetBadge(isdisplay: true,child: widget.itemdata!.eligibleForExpress=="1"?Image.asset(Images.express,
                      height: 20.0,
                      width: 25.0,):SizedBox.shrink()),*/
                    child: Align(
                      alignment: Alignment.center,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if(widget.fromScreen == "sellingitem_screen") {
                              if (widget.itemdata!.priceVariation![itemindex].stock !>= 0)
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.itemdata!.priceVariation![itemindex].menuItemId.toString()});
                            }
                            else{
                              if (widget.itemdata!.priceVariation![itemindex].stock !>= 0)
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.itemdata!.priceVariation![itemindex].menuItemId.toString()});
                              else
                                Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid": widget.itemdata!.priceVariation![itemindex].menuItemId.toString(),"productId": widget.itemdata!.priceVariation![itemindex].menuItemId.toString()});
                            }
                          },
                          child:  Stack(
                              children: [

                                Container(
                                  margin: EdgeInsets.only(top: 15.0, bottom: 8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.itemdata!.priceVariation![itemindex].images!.length<=0?widget.itemdata!.itemFeaturedImage:widget.itemdata!.priceVariation![itemindex].images![0].image,
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
                                    width: ResponsiveLayout.isSmallScreen(context) ? 115 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    height: ResponsiveLayout.isSmallScreen(context) ? 120 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    //  fit: BoxFit.fill,
                                  ),
                                ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      children: [
                                        if(margins > 0)
                                        Container(
                                          color: ColorCodes.primaryColor,

                                          // constraints: BoxConstraints(
                                          //   minWidth: 28,
                                          //   minHeight: 15,
                                          // ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 8, top:4, bottom: 4),
                                            child: Text(
                                              margins.toStringAsFixed(0) + S .of(context).off ,//"% OFF",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: ColorCodes.whiteColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        if(margins > 0)
                                Spacer(),

                                (widget.itemdata!.eligibleForExpress == "0")?
                                Container(
                                  decoration: BoxDecoration(
                                  border: Border.all(
                                      color: ColorCodes.varcolor),
                                ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2, right: 2, top:4, bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          S .of(context).express ,//"% OFF",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 9,
                                              color:IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 2),
                                        Image.asset(Images.express,
                                          color: IConstants.isEnterprise? ColorCodes.primaryColor:ColorCodes.liteColor,
                                          height: 11.0,
                                          width: 11.0,),

                                      ],
                                    ),
                                  ),
                                ) : SizedBox.shrink(),
                                            ],
                                    ),
                                  ),
                              ],
                            ),

                        ),
                      ),
                    ),
                  ),
                 /* !_isStock
                      ? Consumer<Calculations>(
                    builder: (_, cart, ch) =>
                        BadgeOfStock(
                          child: ch,
                          value: margins,
                          singleproduct: false,
                        ),
                    child: GestureDetector(
                      onTap: () {
                        navigatetoSingelproductscreen(context,widget.returnparm,
                            duration: widget.duration,
                            delivery: widget.delivery,
                            note: widget.note,
                            durationType: widget.durationType,
                            eligibleforexpress: widget.eligibleforexpress,
                            fromScreen: widget.fromScreen,
                            id: widget.id,
                            imageUrl: widget.imageUrl,
                            itemvarData:itemvarData,
                            title:widget.title );
                      },
                      child: CachedNetworkImage(
                        imageUrl:*/
                  /*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*widget.itemdata!.priceVariation[itemindex].images.length<=0?widget.itemdata!.itemFeaturedImage:widget.itemdata!.priceVariation[itemindex].images[itemindex].image,
                        placeholder: (context, url) =>
                            Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                              height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            ),
                        errorWidget: (context, url, error) => Image.asset(
                          Images.defaultProductImg,
                          width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        ),
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        //fit: BoxFit.fill,
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      if(widget.fromScreen == "sellingitem_screen") {
                        if (_isStock)
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                        else
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                      }
                      else{
                        if (_isStock)
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                        else
                          navigatetoSingelproductscreen(context,widget.returnparm,
                              duration: widget.duration,
                              delivery: widget.delivery,
                              durationType: widget.durationType,
                              eligibleforexpress: widget.eligibleforexpress,
                              fromScreen: widget.fromScreen,
                              id: widget.id,
                              note: widget.note,
                              imageUrl: widget.imageUrl,
                              itemvarData:itemvarData,
                              title:widget.title );
                      }
                      *//*            Navigator.of(context).pushReplacementNamed(
                          SingleproductScreen.routeName,
                          arguments: {
                            "itemid": widget.id,
                            "itemname": widget.title,
                            "itemimg": widget.imageUrl,
                            'fromScreen': widget.fromScreen,
                            "eligibleforexpress": widget.eligibleforexpress,
                            "delivery": widget.delivery,
                            "duration": widget.duration,
                            "durationType":widget.durationType,
                            "updateItemList": variationdisplaydata,
                            "updateItem": itemvarData,
                          });*//*
                    },
                    child: CachedNetworkImage(
                      imageUrl: *//*(widget.fromScreen == "searchitem_screen")?widget.imageUrl:*//*_displayimg,
                      placeholder: (context, url) =>
                          Image.asset(
                            Images.defaultProductImg,
                            width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                            height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                          ),
                      errorWidget: (context, url, error) => Image.asset(
                        Images.defaultProductImg,
                        width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                        height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      ),
                      width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                      //fit: BoxFit.fill,
                    ),
                  ),*/
                ],
              ),
            ),
            SizedBox(width: 5,),
            Column(
              mainAxisAlignment: Features.btobModule?MainAxisAlignment.start:MainAxisAlignment.center,
              children: [
                Container(
                  width: (MediaQuery
                      .of(context)
                      .size
                      .width / 2) + 55,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: Features.btobModule?(MediaQuery
                              .of(context)
                              .size
                              .width / 1.5):(MediaQuery
                              .of(context)
                              .size
                              .width / 2.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Features.btobModule?
                              Container(
                                height:20,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      widget.itemdata!.brand!,
                                      style: TextStyle(
                                          fontSize: 9, color: Colors.black),
                                    ),
                                    Features.btobModule?
                                    (widget.itemdata!.eligibleForExpress == "0")?
                                    Container(
                                      height: 20,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Image .asset(Images.express,
                                            height: 20.0,
                                            width: 25.0,),
                                        ],
                                      ),
                                    ):SizedBox.shrink():SizedBox.shrink(),
                                    if(Features.btobModule)
                                      SizedBox(width:MediaQuery.of(context).size.width*0.15),
                                    if(Features.btobModule)
                                      if(Features.isLoyalty)
                                        (double.parse(widget.itemdata!.priceVariation![itemindex].loyalty.toString()) > 0)?
                                        Container(
                                          height:15,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Image.asset(Images.coinImg,
                                                height: 15.0,
                                                width: 20.0,),
                                              SizedBox(width: 4),
                                              Text(widget.itemdata!.priceVariation![itemindex].loyalty.toString()),
                                            ],
                                          ),
                                        ):SizedBox.shrink(),
                                  ],
                                ),
                              ):
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        widget.itemdata!.brand!,
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height:38,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        Features.btobModule?widget.itemdata!.itemName! + "-" + widget.itemdata!.priceVariation![0].variationName!:widget.itemdata!.itemName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          //fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              ( widget.itemdata!.priceVariation!.length > 1)?
                              Features.btobModule?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    //height: 70,
                                    width: /*(MediaQuery
                                        .of(context)
                                        .size
                                        .width / 3)*/(MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2)+20,
                                    // child: SingleChildScrollView(
                                    child:
                                    GridView.builder(
                                        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: widgetsInRow,
                                          crossAxisSpacing: 0,
                                          childAspectRatio: aspectRatio,
                                          mainAxisSpacing: 0,
                                        ),
                                        controller: new ScrollController(keepScrollOffset: false),
                                        shrinkWrap: true,
                                        itemCount: widget.itemdata!.priceVariation!.length,
                                        itemBuilder: (_, i) {
                                          //print("variation length..."+widget.itemdata!.priceVariation!.length.toString());
                                          return
                                            GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: () async {
                                                      setState(() {
                                                        _groupValue = i;
                                                      });
                                                      print("hdhvsdhsdfds"+""+widget.itemdata!.id!+"..."+widget.itemdata!.priceVariation![0].id.toString() +
                                                          "..var id.." + varid.toString());
                                                      if(productBox
                                                          .where((element) =>
                                                      element.itemId! == widget.itemdata!.id
                                                      ).length >= 1) {
                                                        cartcontroller.update((done) {
                                                          print("done value in calling update " + done.toString());
                                                          setState(() {

                                                          });
                                                        }, price: widget.itemdata!.price.toString(),
                                                            quantity: widget.itemdata!.priceVariation![i].minItem.toString(),
                                                            type: widget.itemdata!.type,
                                                            weight: (/*weight +*/
                                                                double.parse(widget.itemdata!.increament!)).toString(),
                                                            var_id: /*widget.itemdata!.id!*/widget.itemdata!.priceVariation![0].id.toString(),
                                                            increament: widget.itemdata!.increament,
                                                            cart_id: productBox
                                                                .where((element) =>
                                                            element.itemId! == widget.itemdata!.id
                                                            ).first.parent_id.toString(),
                                                            toppings: "",
                                                            topping_id: "",
                                                            item_id: widget.itemdata!.id!

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
                                                            varid: widget.itemdata!.priceVariation![0].id,
                                                            toppings: "",
                                                            parent_id: "",
                                                            newproduct: "0",
                                                            toppingsList: [],
                                                            itembody: widget.itemdata!.priceVariation![i],
                                                            context: context);
                                                        print("group value....2" + _groupValue.toString());
                                                      }

                                                },
                                                child: Container(
                                                    height: 60,
                                                    width:90,
                                                    decoration: BoxDecoration(
                                                      color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      border: Border.all(
                                                        color: ColorCodes.greenColor,
                                                      ),
                                                    ),
                                                    margin: EdgeInsets.only(right: 10,bottom:2),
                                                    padding: EdgeInsets.only(right: 5,left:5),
                                                    child:

                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              "${widget.itemdata!.priceVariation![i].minItem}"+"-"+"${widget.itemdata!.priceVariation![i].maxItem}"+" "+"${widget.itemdata!.priceVariation![i].unit}",
                                                              style:
                                                              TextStyle(color: _groupValue == i ? ColorCodes.darkgreen :ColorCodes.blackColor,fontWeight: FontWeight.bold,fontSize: 10),),

                                                            _groupValue == i ?
                                                            Container(
                                                              width: 18.0,
                                                              height: 18.0,
                                                              //margin: EdgeInsets.only(top:3),
                                                              decoration: BoxDecoration(
                                                                color: ColorCodes.greenColor,
                                                                border: Border.all(
                                                                  color: ColorCodes.greenColor,
                                                                ),
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Container(
                                                                margin: EdgeInsets.all(3),
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
                                                        ),

                                                        if(Features.isMembership)
                                                          _checkmembership?Container(
                                                            width: 10.0,
                                                            height: 9.0,
                                                            margin: EdgeInsets.only(right: 3.0),
                                                            child: Image.asset(
                                                              Images.starImg,
                                                              color: ColorCodes.starColor,
                                                            ),
                                                          ):SizedBox.shrink(),
                                                        new RichText(
                                                          text: new TextSpan(
                                                            style: new TextStyle(
                                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12,
                                                              color: _groupValue == i ? ColorCodes.darkgreen :ColorCodes.blackColor,
                                                            ),
                                                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                              new TextSpan(
                                                                  text: Features.iscurrencyformatalign?
                                                                  '${_checkmembership?widget.itemdata!.priceVariation![i].membershipPrice:widget.itemdata!.priceVariation![i].price} ' + IConstants.currencyFormat:
                                                                  IConstants.currencyFormat + '${_checkmembership?widget.itemdata!.priceVariation![i].membershipPrice:widget.itemdata!.priceVariation![i].price} ',
                                                                  style: new TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    color: _groupValue == i ? ColorCodes.darkgreen :ColorCodes.blackColor,
                                                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12,)),
                                                              new TextSpan(
                                                                  text: widget.itemdata!.priceVariation![i].price!=widget.itemdata!.priceVariation![i].mrp?
                                                                  Features.iscurrencyformatalign?
                                                                  '${widget.itemdata!.priceVariation![i].mrp} ' + IConstants.currencyFormat:
                                                                  IConstants.currencyFormat + '${widget.itemdata!.priceVariation![i].mrp} ':"",
                                                                  style: TextStyle(
                                                                    decoration:
                                                                    TextDecoration.lineThrough,
                                                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                                            ],
                                                          ),
                                                        ),


                                                      ],)


                                                )
                                            );

                                        }),
                                  ),
                                  // )
                                ],
                              ):
                              Container(
                                width: (MediaQuery
                                    .of(context)
                                    .size
                                    .width / 3),
                                child:   Row(
                                  children: [
                                    Container(
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width /3),
                                      child: (widget.itemdata!.priceVariation!.length > 1)
                                          ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showoptions1();
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 20,
                                              child: Text(
                                                "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                                style:
                                                TextStyle(color: ColorCodes.darkgreen,fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            //SizedBox(width: 10,),
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              color: ColorCodes.darkgreen,
                                                size: 20,
                                            ),
                                          ],
                                        ),
                                      )
                                          : Row( mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Container(
                                             /* decoration: BoxDecoration(
                                                  color: ColorCodes.varcolor,
                                                  *//* border: Border.all(
                                      color: ColorCodes.greenColor,),*//*
                                                  borderRadius: new BorderRadius.only(
                                                    topLeft:
                                                    const Radius.circular(2.0),
                                                    topRight:
                                                    const Radius.circular(2.0),
                                                    bottomLeft:
                                                    const Radius.circular(2.0),
                                                    bottomRight:
                                                    const Radius.circular(2.0),
                                                  )),*/
                                              height: 40,
                                              child: Text(
                                                "${widget.itemdata!.priceVariation![itemindex].variationName}"+" "+"${widget.itemdata!.priceVariation![itemindex].unit}",
                                                style: TextStyle(color: ColorCodes.greyColor,fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ):SizedBox(height:20),
                              SizedBox(
                                height: 4,
                              ),
                              (!Features.btobModule)?
                                VxBuilder(
                                  // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                  builder: (context, GroceStore box, index) {
                                    if(store.userData.membership! == "1"){
                                      _checkmembership = true;
                                    } else {
                                      _checkmembership = false;
                                      for (int i = 0; i < productBox.length; i++) {
                                        if (productBox[i].mode == "1") {
                                          _checkmembership = true;
                                        }
                                      }
                                    }
                                    return Column(
                                      children: [
                                        if(Features.isMembership && double.parse(widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString()) > 0)
                                          Row(
                                            children: [
                                              !_checkmembership
                                                  ? widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipDisplay!
                                                  ? GestureDetector(
                                                onTap: () {
                                                  (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
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
                                                  (checkskip && !_isWeb)?
                                                  /* Navigator.of(context).pushReplacementNamed(
                                      SignupSelectionScreen.routeName)*/
                                                  Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                                                      :/*Navigator.of(context).pushNamed(
                                    MembershipScreen.routeName,
                                  );*/
                                                  Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 5,),
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width / 3.5)
                                                      /*+ 5*/,
                                                  height:22,
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
                                                      SizedBox(width: 2),
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
                                                          Features.iscurrencyformatalign?
                                                          widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                                          IConstants.currencyFormat +
                                                              widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString() /*+ " Membership Price"*/,
                                                          style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 10 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                                                    ],
                                                  ),
                                                ),
                                              )
                                                  : SizedBox.shrink()
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        /*!_checkmembership
                                          ? widget.itemdata!.priceVariation![itemindex].membershipDisplay!
                                          ? SizedBox(
                                        height: 1,
                                      )
                                          : SizedBox(
                                        height: 1,
                                      )
                                          : SizedBox(
                                        height: 1,
                                      ),*/
                                      ],
                                    );
                                  }, mutations: {ProductMutation,SetCartItem},
                                ): SizedBox(height:25),
                              SizedBox(
                                height: 4,
                              ),
                              //(!Features.btobModule)?

                              Container(
                                  child: Row(
                                    children: <Widget>[
                                      if(!Features.btobModule)
                                      if(Features.isMembership)
                                        _checkmembership?Container(
                                          width: 10.0,
                                          height: 9.0,
                                          margin: EdgeInsets.only(right: 3.0),
                                          child: Image.asset(
                                            Images.starImg,
                                            color: ColorCodes.starColor,
                                          ),
                                        ):SizedBox.shrink(),
                                      if(!Features.btobModule)
                                      new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                            new TextSpan(
                                                text: Features.iscurrencyformatalign?
                                                '${_checkmembership?widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice:widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].price} ' + IConstants.currencyFormat:
                                                IConstants.currencyFormat + '${_checkmembership?widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice:widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].price} ',
                                                  style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 15 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                            new TextSpan(
                                                text: widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].price!=widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].mrp?
                                                    Features.iscurrencyformatalign?
                                                    '${widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].mrp} ' + IConstants.currencyFormat:
                                                IConstants.currencyFormat + '${widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].mrp} ':"",
                                                style: TextStyle(
                                                  decoration:
                                                  TextDecoration.lineThrough,
                                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                          ],
                                        ),
                                      ),
                                      if(Features.btobModule)
                                        SizedBox(width:MediaQuery.of(context).size.width*0.15),
                                      if(Features.btobModule)
                                      VxBuilder(
                                        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                        builder: (context, GroceStore box, index) {
                                          if(store.userData.membership! == "1"){
                                            _checkmembership = true;
                                          } else {
                                            _checkmembership = false;
                                            for (int i = 0; i < productBox.length; i++) {
                                              if (productBox[i].mode == "1") {
                                                _checkmembership = true;
                                              }
                                            }
                                          }
                                          return Column(
                                            children: [
                                              if(Features.isMembership && double.parse(widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString()) > 0)
                                                Row(
                                                  children: [
                                                    !_checkmembership
                                                        ? widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipDisplay!
                                                        ? GestureDetector(
                                                      onTap: () {
                                                        (checkskip &&_isWeb && !ResponsiveLayout.isSmallScreen(context))?
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
                                                        (checkskip && !_isWeb)?
                                                        /* Navigator.of(context).pushReplacementNamed(
                                      SignupSelectionScreen.routeName)*/
                                                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                                                            :/*Navigator.of(context).pushNamed(
                                    MembershipScreen.routeName,
                                  );*/
                                                        Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.symmetric(vertical: 5,),
                                                        width: (MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width / 3) +
                                                            5,
                                                        height:30,
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            left: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                                                            // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                          ),
                                                          color: ColorCodes.varcolor,
                                                        ),
                                                        child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            SizedBox(width: 2),
                                                            Text(
                                                                Features.iscurrencyformatalign?
                                                                widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                                                IConstants.currencyFormat +
                                                                    widget.itemdata!.priceVariation![Features.btobModule?_groupValue:itemindex].membershipPrice.toString() + " Membership Price",
                                                                style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 10 : 12,color: ColorCodes.greenColor,fontWeight: FontWeight.bold)),

                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                        : SizedBox.shrink()
                                                        : SizedBox.shrink(),
                                                  ],
                                                ),
                                              /*!_checkmembership
                                          ? widget.itemdata!.priceVariation![itemindex].membershipDisplay!
                                          ? SizedBox(
                                        height: 1,
                                      )
                                          : SizedBox(
                                        height: 1,
                                      )
                                          : SizedBox(
                                        height: 1,
                                      ),*/
                                            ],
                                          );
                                        }, mutations: {ProductMutation,SetCartItem},
                                      ),

                                    ],
                                  )),
                                  //:SizedBox.shrink(),
                              SizedBox(
                                height: 4,
                              ),
                              Features.btobModule?
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      Text(S.of(context).total,style: TextStyle(color: ColorCodes.blackColor)),
                                      productBox
                                          .where((element) =>
                                      element.itemId == widget.itemdata!.id).length > 0?
                                      Text( IConstants.currencyFormat + (double.parse(widget.itemdata!.priceVariation![_groupValue].price!) * /*(double.parse(productBox
                              .where((element) =>
                          element.itemId! == widget._itemdata.id
                          ).first.quantity!))*/_count).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                        style: TextStyle(
                                            color: ColorCodes.greenColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15
                                        ),): Text( IConstants.currencyFormat + (double.parse(widget.itemdata!.priceVariation![itemindex].price!)).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                        style: TextStyle(
                                            color: ColorCodes.greenColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15
                                        ),),


                                    ],
                                  ),
                                  SizedBox(width:10),
                                  Container(
                                    height:40,
                                    width: (MediaQuery.of(context).size.width/3)+5 ,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:0,right:0.0),
                                      child: CustomeStepper(priceVariation:widget.itemdata!.priceVariation![itemindex],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Add",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null, index: itemindex,groupvalue: _groupValue,onChange: (int value,int count){
                                        setState(() {
                                          _groupValue = value;
                                          _count = count;
                                        });
                                       print("selling item grpoupvalue..."+_groupValue.toString()+"..."+value.toString());
                                      }),
                                    ),
                                  ),
                                ],
                              ):SizedBox.shrink(),
                              /*(widget.itemdata!.priceVariation![itemindex].membershipDisplay!)?
                              SizedBox(height: 4):SizedBox(height: 10),*/
                            ],
                          )),
                      !Features.btobModule?
                      Spacer():SizedBox.shrink(),
                      !Features.btobModule?
                      Container(
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width / 4.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if(Features.isLoyalty)
                                (double.parse(widget.itemdata!.priceVariation![itemindex].loyalty.toString()) > 0)?
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.coinImg,
                                        height: 12.0,
                                        width: 15.0,),
                                      SizedBox(width: 2),
                                      Text(widget.itemdata!.priceVariation![itemindex].loyalty.toString(),
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    ],
                                  ),
                                ):SizedBox(height: 10,),
                              SizedBox(height: 4),
                              Features.isSubscription && widget.itemdata!.eligibleForSubscription=="0"?
                              Container(
                                height:40,
                                child: CustomeStepper(priceVariation:widget.itemdata!.priceVariation![itemindex],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Subscribe",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null, index: itemindex),
                              ):SizedBox(height: 40,),



                               SizedBox(height: 30,),
                              !Features.btobModule?
                              Container(
                                height:40,
                                width: (MediaQuery.of(context).size.width/3)+5 ,
                                child: Padding(
                                  padding: const EdgeInsets.only(left:0,right:0.0),
                                  child: CustomeStepper(priceVariation:widget.itemdata!.priceVariation![itemindex],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?40:40,issubscription: "Add",addon:(widget.itemdata!.addon!.length > 0)?widget.itemdata!.addon![0]:null, index: itemindex),
                                ),
                              ):SizedBox.shrink(),

                            ],
                          )):SizedBox.shrink(),
                    ],
                  ),
                ),
                if(Features.netWeight && widget.itemdata!.vegType == "fish")
                  Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width / 2) + 70,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              Features.iscurrencyformatalign?
                              "Whole Uncut:" +" " +
                                  widget.itemdata!.salePrice! + IConstants.currencyFormat +" / "+ "500 G":
                              "Whole Uncut:" +" "+ IConstants.currencyFormat +
                                widget.itemdata!.salePrice! +" / "+ "500 G",
                              style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: 3),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text("Gross Weight:" +" "+
                                      widget.itemdata!.priceVariation![itemindex].weight!,
                                      style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                  ),
                                ),
                                Container(
                                  child: Text("Net Weight:" +" "+
                                      widget.itemdata!.priceVariation![itemindex].netWeight!,
                                      style: new TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 16, fontWeight: FontWeight.bold)
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

               // SizedBox(height: 5,),


              ],
            ),
          ],
        ),
      );
    }
  }
}

Future<bool> navigatetoSingelproductscreen(context,returnparm,{fromScreen,seeallpress,id,title,imageUrl,eligibleforexpress,delivery,duration,durationType,variationdisplaydata,itemvarData,note,notid}) async{
  switch(fromScreen){
    case "sellingitem_screen":

      // Navigator.of(context).pushReplacementNamed(
      //     SingleproductScreen.routeName,
      //     arguments: {
      //       "itemid": id.toString(),
      //       'fromScreen': fromScreen,
      //       "itemname": title,
      //       "itemimg": imageUrl,
      //       "eligibleforexpress": eligibleforexpress,
      //       "note" :note,
      //       "delivery": delivery,
      //       "duration": duration,
      //       "durationType":durationType,
      //       "updateItemList": variationdisplaydata,
      //       "updateItem": itemvarData,
      //       "seeallpress":seeallpress,
      //       "fromScreen":"sellingitem_screen",
      //     });
      return false;
      break;
    case "not_product_screen":
      // Navigator.of(context).pushReplacementNamed(SingleproductScreen.routeName, arguments: {
      //   "itemid": id.toString(),
      //   "itemname": title,
      //   'fromScreen': fromScreen,
      //   "itemimg": imageUrl,
      //   "eligibleforexpress": eligibleforexpress,
      //   "delivery": delivery,
      //   "note" :note,
      //   "duration": duration,
      //   "durationType": durationType,
      //   "updateItemList": variationdisplaydata,
      //   "updateItem": itemvarData,
      //   /*'id' : returnparm['id'],
      //   "screen":returnparm['screen'],*/
      //   "seeallpress":seeallpress,
      //   "fromScreen":"not_product_screen",
      //   "notid":notid,
      // });
      break;
    case "item_screen":
      // Navigator.of(context).pushReplacementNamed(SingleproductScreen.routeName, arguments: {
      //   "itemid": id.toString(),
      //   "itemname": title,
      //   'fromScreen': fromScreen,
      //   "itemimg": imageUrl,
      //   "eligibleforexpress": eligibleforexpress,
      //   "delivery": delivery,
      //   "duration": duration,
      //   "note" :note,
      //   "durationType": durationType,
      //   "updateItemList": variationdisplaydata,
      //   "updateItem": itemvarData,
      //   'maincategory': seeallpress == "category"?"":returnparm['maincategory'],
      //   'catId':  seeallpress == "category"?"":returnparm['catId'],
      //   'catTitle': seeallpress == "category"?"": returnparm['catTitle'],
      //   'subcatId':  seeallpress == "category"?"":returnparm['subcatId'],
      //   'indexvalue':seeallpress == "category"?"": returnparm['indexvalue'],
      //   'prev': seeallpress == "category"?"":returnparm['prev'],
      //   "seeallpress":seeallpress,
      //   "fromScreen":"item_screen",
      //   "notid":notid,
      // });
      return false;
      break;
    case "brands_screen":
      // Navigator.of(context).pushReplacementNamed(SingleproductScreen.routeName, arguments: {
      //   "itemid": id.toString(),
      //   "itemname": title,
      //   'fromScreen': fromScreen,
      //   "itemimg": imageUrl,
      //   "eligibleforexpress": eligibleforexpress,
      //   "delivery": delivery,
      //   "duration": duration,
      //   "note" :note,
      //   "durationType": durationType,
      //   "updateItemList": variationdisplaydata,
      //   "updateItem": itemvarData,
      //   "indexvalue":returnparm['indexvalue'],
      //   "brandId":returnparm['brandId'],
      //   "seeallpress":seeallpress,
      //   "fromScreen":"brands_screen",
      // });
      break;
    case "searchitem_screen":
      // Navigator.of(context).pushReplacementNamed(SingleproductScreen.routeName, arguments: {
      //   "itemid": id.toString(),
      //   'fromScreen': fromScreen,
      //   "itemname": title,
      //   "itemimg": imageUrl,
      //   "eligibleforexpress": eligibleforexpress,
      //   "note" :note,
      //   "delivery": delivery,
      //   "duration": duration,
      //   "durationType":durationType,
      //   "updateItemList": variationdisplaydata,
      //   "updateItem": itemvarData,
      //   "seeallpress":seeallpress,
      //   "fromScreen":"sellingitem_screen",
      // });
      return false;
      break;
    case "sellingitem_screen":
      Navigator.of(context).pop();
      break;
    case "shoppinglistitem_screen":
      Navigator.of(context).pop();
      break;
  }
  return false;
}