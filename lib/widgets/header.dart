import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../controller/mutations/home_store_mutation.dart';
import '../../screens/store_screen.dart';
import '../../controller/mutations/address_mutation.dart';
import '../../controller/mutations/cart_mutation.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../controller/mutations/home_screen_mutation.dart';
import '../../controller/mutations/login.dart';
import '../../models/newmodle/category_modle.dart';
import '../../models/newmodle/user.dart';
import '../../repository/authenticate/AuthRepo.dart';
import '../../components/login_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';
import '../controller/mutations/languagemutations.dart';
import '../generated/l10n.dart';
import '../models/VxModels/VxStore.dart';
import '../rought_genrator.dart';
import 'package:velocity_x/velocity_x.dart';
import '../widgets/controlled_scroll_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/features.dart';

import '../providers/itemslist.dart';
import '../utils/prefUtils.dart';
import '../screens/customer_support_screen.dart';
import '../assets/ColorCodes.dart';
import '../constants/IConstants.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../providers/branditems.dart';
import '../providers/categoryitems.dart';
import '../utils/ResponsiveLayout.dart';
import '../data/calculations.dart';
import '../providers/notificationitems.dart';
import '../providers/sellingitems.dart';
import '../widgets/badge.dart';
import "package:http/http.dart" as http;
import '../assets/images.dart';
import 'CoustomeDailogs/slectlanguageDailogBox.dart';

//enable this for web
//import 'dart:js' as js;

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class Header extends StatefulWidget {
  bool _isHome = false;
  Function(String,String,int,int)? onSubcatClick;
  Function(String)? onsearchClick;
  Header(this._isHome,{this.onsearchClick,this.onSubcatClick });
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with Navigations {

  bool _isDelivering = true;
  bool checkSkip = false;
  bool _isshow = true;
  String photourl = "";
  String name = "";
  TextEditingController controller = TextEditingController();
  Timer? _timer;
  bool isDropdownOpened = false;
  bool isDropdownSearch = false;
  OverlayEntry? floatingDropdown;
  StreamController<int>? _events;
  FocusNode _focus = new FocusNode();
  ItemsList searchData = ItemsList();
  List searchDispaly = [];
  String searchValue = "";
  bool _isSearchShow = false;
  var otpvalue = "";

  final _debouncer = Debouncer(milliseconds: 500);
  ScrollController cstscrollcontroller = ScrollController();

  bool lbtn = true;

  bool rbtn = true;
  GroceStore store = VxState.store;
  BuildContext? dailogcontext;
  StateSetter? searchliststate;
  bool issearchloading = false;
  CategoriesItemsList? subNestedcategoryData;
  Timer? timer;

  @override
  void initState() {
    _events = new StreamController<int>.broadcast();
    _events!.add(30);
    Future.delayed(Duration.zero, () async {
      if (!Vx.isWeb) _listenotp();
      PrimeryLocation().fetchPrimarylocation(context);
      checkSkip = !PrefUtils.prefs!.containsKey('apikey');
      setState(() {

        name = (VxState.store as GroceStore).userData.username??"";
        if (PrefUtils.prefs!.getString('photoUrl') != null) {
          photourl = PrefUtils.prefs!.getString('photoUrl')!;
        } else {
          photourl = "";
        }
        if(!Features.ismultivendor)
        if ((!PrefUtils.prefs!.containsKey("welcomeSheet") && !PrefUtils.prefs!.containsKey('apikey') ) && !Vx.isWeb)
          welcomeSheet();
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }
  void onremovedDrpDown(){
    if (isDropdownSearch) {
      floatingDropdown!.remove();
      floatingDropdown = null;
      isDropdownSearch = false;
    }
  }
  void onadddDrpDown(){
    if (floatingDropdown==null) {
      floatingDropdown = _searchBar();
      Overlay.of(context)!.insert(floatingDropdown!);
      isDropdownSearch = true;
    }
  }
  void _onFocusChange() {
    setState(() {
      //drop
      if (isDropdownSearch) {
        floatingDropdown!.remove();
        floatingDropdown = null;
      } else {
        floatingDropdown = _searchBar();
        Overlay.of(context)!.insert(floatingDropdown!);
      }
      isDropdownSearch = !isDropdownSearch;
    });
  }

  search(String value) async {
    issearchloading = true;
    await Provider.of<ItemsList>(context, listen: false).fetchsearchItems(value).then((isempty) {
      searchData = Provider.of<ItemsList>(context, listen: false);
      Future.delayed(Duration(milliseconds: 100), () {
        searchliststate!(() {
          issearchloading = false;
          searchDispaly = searchData.searchitems.toList();
        });
      });
    });
  }

  onSubmit(String value) async {
    if(widget.onsearchClick==null)
      Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search,qparms: {
        "itemname": value,
      });
    else{
      _focus = new FocusNode();
      FocusScope.of(context).requestFocus(_focus);
      widget.onsearchClick!(value);}
  }

  void _listenotp() async {
    await SmsAutoFill().listenForCode;
  }

  welcomeSheet() {
    PrefUtils.prefs!.setBool("welcomeSheet", true);
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SafeArea(
            child: Container(
              width: double.infinity,
              color: ColorCodes.whiteColor,
              padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new RichText(
                        text: new TextSpan(
                          style: new TextStyle(

                          ),
                          children: <TextSpan>[
                            new TextSpan(text: S.of(context).welcome + " ", style: TextStyle(fontSize: 18.0, color: ColorCodes.greyColor, fontWeight: FontWeight.bold)),
                            new TextSpan(text: IConstants.APP_NAME, style: TextStyle(fontSize: 20.0, color: ColorCodes.darkgreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      FlatButton(
                        height: 0,
                        minWidth: 0,
                        padding: EdgeInsets.all(0),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: ColorCodes.grey,
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                  image: AssetImage(Images.cancelImg))),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Text(
                      S.of(context).product_and_location_specified,
                      style: TextStyle(color: ColorCodes.greyColor, fontWeight: FontWeight.bold,fontSize: 14.0)
                    //'Product catalogue and offers are location specific'
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(Images.otherConfirm, height: 20, width: 20,color: ColorCodes.primaryColor,),
                      Container(
                        width:  MediaQuery.of(context).size.width * 0.45,
                        child: FlatButton(
                          height: 0,
                          minWidth: 0,
                          padding: EdgeInsets.only(left: 3, top: 0, right: 0.0, bottom: 0),
                          textColor: ColorCodes.darkgreen,
                          child: Text(S.of(context).explore + " " + (PrefUtils.prefs!.getString("restaurant_location")??""), textAlign: TextAlign.left, overflow: TextOverflow.ellipsis,maxLines: 1,

                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))
                          ,

                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Center(child: Text(S.of(context).or, style: TextStyle(fontSize: 13.0, color: ColorCodes.darkGrey))),
                      Container(
                        child: FlatButton(
                          height: 0,
                          minWidth: 0,
                          padding: EdgeInsets.only(left: 3.0, top: 0, right: 0.0, bottom: 0),
                          textColor: ColorCodes.darkgreen,
                          child: Text(S.of(context).change_location, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
                          onPressed: () {
                            PrefUtils.prefs!.setString("formapscreen", "homescreen");
                            Navigator.pop(context);
                            Navigation(context, name: Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                                qparms: {
                                  "valnext": "",
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).existing_customer,
                          style: TextStyle(color: ColorCodes.greyColor, fontWeight: FontWeight.bold,fontSize:17)
                        //'Existing customer?'
                      ),
                      FlatButton(
                        textColor:ColorCodes.primaryColor,
                        child: Text(S.of(context).login_small, style: TextStyle(fontWeight: FontWeight.bold,fontSize:15)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0,),
                  (IConstants.isEnterprise &&store.language.languages.length > 1)?
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if(store.language.languages.length > 1)
                            Text(S.of(context).chose_your_preferred_language,   //'Choose your preferred language' ,
                                style: TextStyle(
                                    color: ColorCodes.greyColor,
                                    fontWeight: FontWeight.bold,fontSize: 14)),
                          GridView.builder(
                            shrinkWrap: true,
                            controller: new ScrollController(keepScrollOffset: false),
                            itemCount: store.language.languages.length,
                            padding: ResponsiveLayout.isSmallScreen(context)? const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0):
                            const EdgeInsets.only(bottom:10.0),
                            itemBuilder: (ctx, i) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FlatButton(
                                  padding: EdgeInsets.all(0.0),
                                  textColor: ColorCodes.darkgreen,
                                  child: Row(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //Padding( padding: EdgeInsets.only(left:5.0),),
                                      Text(store.language.languages[i].localName!,
                                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16,
                                              fontWeight: store.language.languages[i].code == store.language.language.code ? FontWeight.bold : FontWeight.normal)),
                                      SizedBox(width: 30.0,),
                                      store.language.languages[i].code == store.language.language.code ?
                                      Container(

                                        width: 20.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.check,
                                              color: Theme.of(context).primaryColor,
                                              size: 15.0),
                                        ),
                                      )
                                          :
                                      Icon(
                                          Icons.radio_button_off_outlined,
                                          color: Theme.of(context).primaryColor)
                                    ],
                                  ),
                                  onPressed: () {
                                    SetLanguage(code: store.language.languages[i].code!);
                                    Navigator.pop(dailogcontext!);
                                    Navigator.of(context).pop();
                                    Navigation(context, navigatore: NavigatoreTyp.homenav);
                                  },
                                ),
                              ],
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.0,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 1,
                            ),
                          )
                        ],
                      ),
                    ):SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //for search bar
  OverlayEntry _searchBar() {
    // RenderBox renderBox = context.findRenderObject();
    return OverlayEntry(builder: (context) {
      return Positioned(
        width: MediaQuery.of(context).size.width/3,
        top: 70,
        right: 340,
        child: Container(
          color: ColorCodes.whiteColor,
          child: searchList(),
        ),
      );
    });
  }

  Widget searchList() {
    final popularSearch = (VxState.store as GroceStore).homescreen.data!.featuredByCart;
    return StatefulBuilder(
      builder: (context,setState){
        this.searchliststate = setState;
        return  Column(
          children: [
            Material(
              elevation: 35,
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(8.0),
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(issearchloading)
                        Container(
                          margin: EdgeInsets.all(20),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            minHeight: 5,
                          ),
                        ),
                      if (_isSearchShow)
                        SizedBox(
                          child: new ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: searchDispaly.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (_, i) => Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final variationdate = searchData.findByIdsearch(searchDispaly[i].id.toString());
                                    /// onclick remove popub search list
                                    onremovedDrpDown();
                                    Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid":variationdate.first.varid!,"productId": variationdate.first.menuid!});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                        color: ColorCodes.whiteColor,
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 2.0,
                                            color:
                                            Theme.of(context).backgroundColor,
                                          ),
                                        )),
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      searchDispaly[i].title,
                                      style: TextStyle(
                                          color: ColorCodes.blackColor, fontSize: 12.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.all(14.0),
                        child: Text(
                          S.of(context).popular_search,
                          //"Popular Searches"
                        ),
                      ),
                      SizedBox(
                        child: new ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: popularSearch!.data!.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (_, i) => Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  onremovedDrpDown();
                                  Navigation(context, name: Routename.SingleProduct, navigatore: NavigatoreTyp.Push,parms: {"varid":popularSearch.data![i].priceVariation!.first.id!,"productId": popularSearch.data![i].priceVariation!.first.menuItemId!});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(14.0),
                                  decoration: BoxDecoration(
                                      color: ColorCodes.whiteColor,
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 2.0,
                                          color: Theme.of(context).backgroundColor,
                                        ),
                                      )),
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    popularSearch.data![i].itemName!,
                                    style: TextStyle(
                                        color: ColorCodes.blackColor, fontSize: 12.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    _focus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: ColorCodes.whiteColor,
        child: ResponsiveLayout.isSmallScreen(context) || !Vx.isWeb
            ? createHeaderForMobile()
            : createHeaderForWeb(),
      ),
    );
  }

  createHeaderForWeb() {

    checkSkip = !PrefUtils.prefs!.containsKey('apikey');
    name = (VxState.store as GroceStore).userData.username??"";
    return VxBuilder(
      mutations: {HomeScreenController,SetPrimeryLocation},
      builder: (context, GroceStore store,state){
        String currentlocation ="";
        if(PrefUtils.prefs!.containsKey("deliverylocation")) {
          currentlocation = PrefUtils.prefs!.getString("deliverylocation")!;
        } else {
          currentlocation = PrefUtils.prefs!.getString("restaurant_location")??"";
        }
        if(store.homescreen.data!=null) {
          if (store.homescreen.data!.allBrands!.length > 0 || store.homescreen.data!.allCategoryDetails!.length > 0 || (store.homescreen.data!.discountByCart!=null)&&store.homescreen.data!.discountByCart!.data!.length > 0) {
            _isDelivering = true;
          } else {
            _isDelivering = false;
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.topRight,
                  colors: [
                    ColorCodes. whiteColor,
                    ColorCodes.whiteColor
                  ],
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: 60.0,
              child: Row(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap:() {
                        if(!widget._isHome){
                          HomeScreenController(user: (VxState.store as GroceStore).userData.id ??
                              PrefUtils.prefs!.getString("ftokenid"),
                              branch: (VxState.store as GroceStore).userData.branch ?? "999",
                              rows: "0");
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          GoRouter.of(context).refresh();

                        }
                      },
                      child: Features.isWebTrail ? Features.logo!=""?CachedNetworkImage(width: 200,imageUrl: "${Features.logo}") : SizedBox(width: 200,)
                          : Image.asset(
                        Images.logonImg1,
                        width: 220,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30.0,
                  ),

                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          PrefUtils.prefs!.setString("formapscreen", "homescreen");
                          Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push, qparms:{
                            "valnext": "",
                          });
                          onremovedDrpDown();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40.0,
                            ),
                            Icon(
                              Icons.location_on_outlined,
                              color: ColorCodes.greenColor,
                            ),
                            SizedBox(
                              width: 14.0,
                            ),
                            Expanded(
                              child:   Text(
                                currentlocation,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style:
                                TextStyle(color: ColorCodes.greenColor, fontSize: 17.0),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_sharp,
                              color: ColorCodes.greenColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40.0,
                  ),
                  Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width/3,
                    decoration: BoxDecoration(
                      color: ColorCodes.appdrawerColor                                                                                         ,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextField(
                        autofocus: false,
                        focusNode: _focus,
                        textInputAction: TextInputAction.search,
                        onTap: ()=>_onFocusChange(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top:13,left:20,right:10),
                          hintText: S.of(context).search_for_product,//' Search for Products ',
                          hintStyle: TextStyle(
                            color: (IConstants.isEnterprise)?ColorCodes.blackColor:ColorCodes.greyColor,
                          ),
                          suffixIcon:
                          Icon(Icons.search, color: (IConstants.isEnterprise)?ColorCodes.blackColor:ColorCodes.greyColor),
                          filled: (_focus.hasFocus),
                        ),
                        onSubmitted: (value) {
                          searchValue = value;
                          _focus.requestFocus();
                          onremovedDrpDown();
                          onSubmit(value);

                        },
                        onChanged: (String newVal) {
                          setState(() {
                            searchValue = newVal;
                            if (newVal.length == 0) {
                              setState(() {
                                _isSearchShow = false;
                              });
                              search("");
                              onremovedDrpDown();
                            }
                            else if (newVal.length == 2) {
                              _debouncer.run(() {
                                search(newVal);
                                onadddDrpDown();
                                _focus.requestFocus();
                              });
                            }
                            else if (newVal.length >= 3) {
                              _debouncer.run(() {
                                _isSearchShow = true;
                                onadddDrpDown();
                                search(newVal);
                                _focus.requestFocus();
                              });
                            }
                          });
                        }),
                  ),


                  SizedBox(
                    width: 40.0,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                        onremovedDrpDown();
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10.0,
                          ),
                          ValueListenableBuilder(
                            valueListenable:IConstants.currentdeliverylocation,
                            builder: (context, value, widget){
                              return VxBuilder(
                                builder: (context, GroceStore box, index) {
                                  if (CartCalculations.itemCount<=0)
                                    return GestureDetector(
                                      onTap: () {
                                        if (value != S.of(context).not_available_location)
                                          Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Image.asset(
                                          Images.cartImg,
                                          height: 30,
                                          width: 30,
                                          color: ColorCodes.blackColor,
                                        ),
                                      ),
                                    );
                                  return Consumer<CartCalculations>(
                                    builder: (_, cart, ch) => Badge(
                                      child: ch!,
                                      color: ColorCodes.darkgreen,
                                      value: CartCalculations.itemCount.toString(),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (value != S.of(context).not_available_location)
                                          Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child:
                                        Image.asset(
                                          Images.cartImg,
                                          height: 28,
                                          width: 28,
                                          color:  ColorCodes.blackColor,
                                        ),
                                      ),
                                    ),);
                                },mutations: {SetCartItem},
                              );
                            },
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width:40.0,
                  ),
                  checkSkip?
                  GestureDetector(
                    onTap: (){
                      onremovedDrpDown();
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          HomeScreenController(user: (VxState.store as GroceStore).userData.id ??
                              PrefUtils.prefs!.getString("ftokenid"),
                              branch: (VxState.store as GroceStore).userData.branch ?? "999",
                              rows: "0");
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          GoRouter.of(context).refresh();

                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    },
                    child: Container(

                      height: 45.0,

                      child:
                      Row(
                        children: [
                          SizedBox(width: 10.0),
                          Icon(Icons.person_outline_rounded,
                              color: ColorCodes.blackColor, size: 24.0),
                          SizedBox(
                            width: 9.0,
                          ),
                          new Text(
                            S.of(context).login_register,//"Login",
                            style: TextStyle(
                              color: ColorCodes.blackColor,
                              fontSize: 17,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_sharp,
                            color: ColorCodes.blackColor,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  )
                      :
                  Container(
                    child: PopupMenuButton(
                      offset: const Offset(0, 38),
                      onSelected: (selectedValue) {
                        setState(() {
                          if(selectedValue == "/MyOrders"){
                            Navigation(context, name:Routename.MyOrders,navigatore: NavigatoreTyp.Push,
                            );
                          }
                          else if(selectedValue == "/MySubscription"){
                            Navigation(context, name: Routename.MySubscription, navigatore: NavigatoreTyp.Push);
                          }
                          else if(selectedValue == "/shoppinglist"){
                            Navigation(context, name: Routename.Shoppinglist, navigatore: NavigatoreTyp.Push);
                          }
                          else if(selectedValue == "/Addressbook"){
                            Navigation(context, name: Routename.AddressBook, navigatore: NavigatoreTyp.Push);
                          }
                          else if(selectedValue == "/Membership"){
                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                          }
                          else if(selectedValue == "/Wallet"){
                            Navigation(context, name: Routename.Wallet, navigatore: NavigatoreTyp.Push,qparms: {
                              "type":"wallet",
                            });
                          }
                          else if(selectedValue == "/SubscribedWallet"){
                            Navigation(context, name: Routename.Wallet, navigatore: NavigatoreTyp.Push,qparms: {
                              "type":"subscribedwallet",
                            });
                          }
                          else if(selectedValue == "/Loyalty"){
                            Navigation(context, name: Routename.Loyalty, navigatore: NavigatoreTyp.Push,qparms: {
                              "type":"loyalty",
                            });
                          }
                          else if(selectedValue == "/language"){
                            showDialog(context: context, builder: (BuildContext context) => LanguageselectDailog(context));
                          }
                          else if(selectedValue == "/Logout"){
                            logout();
                          }
                        });
                      },
                      child:  Row(
                        children: [
                          SizedBox(
                            width: 14.0,
                          ),
                          new Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: ColorCodes.blackColor,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_sharp,
                            color: ColorCodes.blackColor,
                          ),
                        ],
                      ),
                      itemBuilder: (BuildContext bc) => [
                        PopupMenuItem(child:
                        Container(

                          padding: EdgeInsets.all(0.0),
                          child: Row(
                            children: <Widget>[

                              if (photourl != null)
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: ColorCodes.greyColor,
                                  backgroundImage: NetworkImage(photourl),
                                ),
                              if (photourl == null)
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundColor: ColorCodes.greyColor,
                                ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(
                                          color: ColorCodes.blackColor, fontSize: 18.0),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      store.userData.mobileNumber??"",
                                      //'$phone',
                                      style:
                                      TextStyle(
                                          color: ColorCodes.darkGrey, fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                        PopupMenuItem(child:

                        Row(
                          children: [
                            Image.asset(Images.appbar_myorder, height: 30.0, width: 30.0,color:ColorCodes.blackColor),
                            SizedBox(width: 10,),
                            Text(
                              S.of(context).my_orders,
                              style: TextStyle(
                                  color:ColorCodes.blackColor
                              ),
                              //"My Orders"
                            ),
                          ],
                        ),
                            value: "/MyOrders"),
                        if(Features.isSubscription)
                          PopupMenuItem(child:

                          Row(
                            children: [
                              Image.asset(Images.appbar_subscription, height: 30.0, width: 30.0, color: ColorCodes.blackColor,),
                              SizedBox(width: 10,),
                              Text(
                                S.of(context).my_subscription,
                                style: TextStyle(
                                    color:ColorCodes.blackColor
                                ),
                                //"My Orders"
                              ),
                            ],
                          ),
                              value: "/MySubscription"),
                        if(Features.isShoppingList)
                          PopupMenuItem(
                              child: Row(
                                children: [
                                  Image.asset(Images.appbar_shopping, height: 30.0, width: 30.0,color: ColorCodes.blackColor,),
                                  SizedBox(width: 10,),
                                  Text(
                                    S.of(context).shopping_list,
                                    style: TextStyle(
                                        color:ColorCodes.blackColor
                                    ),//"Shopping list"
                                  ),
                                ],
                              ),
                              value: "/shoppinglist"),
                        PopupMenuItem(child:
                        Row(
                          children: [
                            Image.asset(Images.appbar_address, height: 20.0, width: 20.0, color:ColorCodes.blackColor),
                            SizedBox(width: 10,),
                            Text(
                              S.of(context).address_book,
                              style: TextStyle(
                                  color:ColorCodes.blackColor
                              ), //"Address book"
                            ),
                          ],
                        ),
                            value: "/Addressbook"),
                        if(Features.isMembership)
                          PopupMenuItem(
                              child: Row(
                                children: [
                                  Image.asset(Images.memImg, height:20.0, width:20.0, color:ColorCodes.blackColor),
                                  SizedBox(width: 10,),
                                  Text(
                                    S.of(context).membership,
                                    style: TextStyle(
                                        color:ColorCodes.blackColor
                                    ),//"Membership"
                                  ),
                                ],
                              ),
                              value: "/Membership"),
                        if(Features.isWallet)
                          PopupMenuItem(
                              child: Row(
                                children: [
                                  Image.asset(Images.addwallet, height: 25.0, width: 25.0, color: ColorCodes.blackColor),
                                  SizedBox(width: 10,),
                                  Text(
                                    S.of(context).wallet,
                                    style: TextStyle(
                                        color:ColorCodes.blackColor
                                    ),//"Wallet"
                                  ),
                                ],
                              ),
                              value: "/Wallet"),
                        PopupMenuItem(
                            child: Row(
                              children: [
                                Image.asset(Images.addwallet, height: 25.0, width: 25.0, color: ColorCodes.blackColor),
                                SizedBox(width: 10,),
                                Text(
                                  S.of(context).subscribed_wallet,
                                  style: TextStyle(
                                      color:ColorCodes.blackColor
                                  ),//"Wallet"
                                ),
                              ],
                            ),
                            value: "/SubscribedWallet"),
                        if(Features.isLoyalty)
                          PopupMenuItem(
                              child: Row(
                                children: [
                                  Image.asset(Images.app_loyaltyweb, height: 20.0, width: 20.0, color:ColorCodes.blackColor),
                                  SizedBox(width: 10,),
                                  Text(
                                    S.of(context).loyalty,
                                    style: TextStyle(
                                        color:ColorCodes.blackColor
                                    ),//"Loyalty"
                                  ),
                                ],
                              ),
                              value: "/Loyalty"),
                        if(store.language.languages.length > 1)
                          PopupMenuItem(
                              child: Row(
                                children: [
                                  Image.asset(Images.addLanguage,height: 25.0, width: 25.0, color:ColorCodes.blackColor),
                                  SizedBox(width: 10,),
                                  Text(
                                    S.of(context).language,
                                    style: TextStyle(
                                        color:ColorCodes.blackColor
                                    ),//"Logout"
                                  ),
                                ],
                              ),
                              value: "/language"
                          ),
                        PopupMenuItem(
                            child: Row(
                              children: [
                                Image.asset(Images.logoutImg2, height: 25.0, width: 25.0),
                                SizedBox(width: 10,),
                                Text(
                                  S.of(context).log_out,
                                  style: TextStyle(
                                      color:ColorCodes.blackColor
                                  ),//"Logout"
                                ),
                              ],
                            ),
                            value: "/Logout"
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  )
                ],
              ),
            ),
            if(store.homescreen.data!=null) if( store.homescreen.data!.allCategoryDetails!.length>0) StatefulBuilder(
              builder: (context,setState){
                return ControlledScrollView(
                  lbtnval:lbtn,rbtnval:rbtn,
                  controller: cstscrollcontroller,
                  onLeftClick: () {
                    setState((){
                      rbtn = true;
                    });
                    int initcso = cstscrollcontroller.offset.toInt();
                    cstscrollcontroller.animateTo(cstscrollcontroller.offset -200,
                        curve: Curves.easeIn, duration: Duration(milliseconds: 500));
                    int finalcso = cstscrollcontroller.offset.toInt();
                    if(finalcso<=0){
                      setState(() {
                        lbtn = false;
                      });
                    }
                  },
                  onRightClick: () {
                    setState((){
                      lbtn = true;
                    });
                    int initcso = cstscrollcontroller.offset.toInt();
                    cstscrollcontroller.animateTo(cstscrollcontroller.offset +200,
                        curve: Curves.easeIn, duration: Duration(milliseconds: 500));
                    int finalcso = cstscrollcontroller.offset.toInt();

                    if((cstscrollcontroller.position.maxScrollExtent.toInt()-100)<finalcso){
                      setState(() {
                        rbtn = false;
                        lbtn = true;
                      });
                    }
                  },
                  child: new ListView.builder(
                    shrinkWrap: true,
                    controller: cstscrollcontroller,
                    scrollDirection: Axis.horizontal,
                    itemCount: store.homescreen.data!.allCategoryDetails!.length,
                    itemBuilder: (_, j) =>

                        showSubCategory(store.homescreen.data!.allCategoryDetails![j].id!,
                            store.homescreen.data!.allCategoryDetails![j].categoryName!,
                            store.homescreen.data!.allCategoryDetails![j].description!),

                  ),);
              },
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: ColorCodes.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: ColorCodes.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 3),
                    )
                  ],
                )
            ),
          ],
        );
      },
    );
  }

  void launchWhatsApp() async {
    String phone = /*"+918618320591"*/IConstants.secondaryMobile;
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse('I want to order Grocery')}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse('I want to order Grocery')}";
        const url = "https://wa.me/?text=YourTextHere";

      }
    }
    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  createHeaderForMobile() {


    final brandsData = Provider.of<BrandItemsList>(context, listen: false);
    final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
    final discountitemData = Provider.of<SellingItemsList>(context, listen: false);

    if (brandsData.items.length > 0 ||
        sellingitemData.items.length > 0 ||
        categoriesData.items.length > 0 ||
        discountitemData.itemsdiscount.length > 0) {
      _isDelivering = true;
    } else {
      _isDelivering = false;
    }
    return Container(

        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorCodes.whiteColor.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              )
            ],
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,

              colors: [
                ColorCodes.mainheaderColor1,
                ColorCodes.mainheaderColor2,
              ],
            )
        ),
        height: (Vx.isWeb && _isshow) ? Features.isWebTrail ? 195.0 : 220.0 :_isDelivering ? IConstants.isEnterprise && !Features.ismultivendor?IConstants.isEnterprise && !Features.isWebTrail ?  120.0 : 120 :120: IConstants.isEnterprise && !Features.ismultivendor?IConstants.isEnterprise && !Features.isWebTrail ? 100 : 120:120,
        width: MediaQuery.of(context).size.width,
        child:Column(
            children: <Widget>[
              (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))?
              _isshow ?
              Container(
                // height:50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      IConstants.isEnterprise && !Features.ismultivendor && !Features.isWebTrail ? ColorCodes.accentColor : ColorCodes.whiteColor,
                      IConstants.isEnterprise && !Features.ismultivendor && !Features.isWebTrail ? ColorCodes.primaryColor : ColorCodes.whiteColor
                    ],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Features.isWebTrail ? Features.logo != "" ? CachedNetworkImage(imageUrl: "${Features.logo}",
                        height: 75,
                        width: 165) : SizedBox(width: 200,)
                        :
                      Image.asset(
                        Images.logoImg1,
                        height: 30,
                      ),
                    if(!Features.isWebTrail)
                      SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(left: 20)),
                        Text(
                          S.of(context).download_our_app,//"DOWNLOAD APP",
                          style: TextStyle(fontSize: 14, color:IConstants.isEnterprise && !Features.isWebTrail ? Colors.white:Colors.black),
                        ),
                        SizedBox(width: 10,),
                        Text(
                            S.of(context).download_app_for_best,//"Download the app for the best",
                            style: TextStyle(
                                fontSize: 12, color: IConstants.isEnterprise && !Features.isWebTrail ? Colors.white:Colors.black)),
                        Text(
                            S.of(context).grocery_experience,//"Grocery Shopping Experiance",
                            style: TextStyle(
                                fontSize: 12, color: IConstants.isEnterprise && !Features.isWebTrail ? Colors.white:Colors.black)),
                      ],
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [

                        Container(
                          margin: EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isshow = !_isshow;
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              size: 15,
                              color: IConstants.isEnterprise && !Features.isWebTrail ? Colors.white:Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (Vx.isWeb) {
                              launch(
                                  'https://play.google.com/store/apps/details?id=' + IConstants.androidId);
                            }
                            else if (!Vx.isWeb) {
                              launch(
                                  'https://apps.apple.com/us/app/id' + IConstants.appleId);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.white, // Set border color
                                  width: 1.0),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(4.0)),
                            ),
                            // Set border width
                            child: Text("DOWNLOAD APP", style: TextStyle(
                                fontSize: 10, color: Colors.green)),
                          ),
                        ),
                      ],

                    ),
                  ],
                ),
              ) : SizedBox.shrink()
                  :SizedBox.shrink(),
              Row(
                children: <Widget>[
                  ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation,
                      builder: (context,value, widget){
                        return IconButton(
                          padding: EdgeInsets.only(left: 0.0),
                          icon: Icon(
                            Icons.menu,
                            color:  ColorCodes.headerIconColor,
                            size: IConstants.isEnterprise && !Features.isWebTrail ? 25.0 : 30,
                          ),
                          onPressed: () {
                            if (value != S.of(context).not_available_location)
                              Features.ismultivendor?StoreScreen.scaffoldKey.currentState!.openDrawer():HomeScreen.scaffoldKey.currentState!.openDrawer();
                          },
                        );
                      }),
                  if(!IConstants.isEnterprise || Features.ismultivendor)
                    Spacer(),
                  Features.isWebTrail ? Features.logo != "" ? CachedNetworkImage(imageUrl: "${Features.logo}",
                    height: 75,
                    width: 165) : SizedBox(width: 200,)
                      : Image.asset(
                    IConstants.isEnterprise && !Features.ismultivendor?
                    IConstants.isEnterprise ? Images.logoAppbarImg : Images.logoAppbarImglite: Images.logoAppbarImglite,
                    height: IConstants.isEnterprise ? 70 : 80,
                    width: IConstants.isEnterprise ? 138 : 200,
          // fit: BoxFit.fitWidth,
                  ),
                  Spacer(),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:5.0,left:10),
                    child: VxBuilder<GroceStore>(
                      mutations: {SetUserData, Features.ismultivendor?HomeStoreScreenController:HomeScreenController},
                      builder: (context,GroceStore store, status) {
                        return(Features.ismultivendor && Features.isWhatsapproot) ?
                         GestureDetector(
                          onTap: () {
                            launchWhatsApp();
                          },
                          child: Image.asset(
                            Images.whatsapp,
                            height: 25,
                            width: 25,
                            color: IConstants.isEnterprise && !Features.ismultivendor ? IConstants
                                .isEnterprise && !Features.isWebTrail ? Colors.white : ColorCodes
                                .greenColor : ColorCodes.blackColor,
                          ),
                        )
                            : (Features.isWhatsapp && !Features.ismultivendor) ? GestureDetector(
                          onTap:(){
                            launchWhatsApp();
                          },
                          child: Image.asset(
                            Images.whatsapp,
                            height: 25,
                            width: 25,
                            color: ColorCodes.headerIconColor,
                          ),
                        ) : SizedBox.shrink();
                      },
                      ),
                  ),

                  if(Features.isWhatsapproot)
                    SizedBox(
                      width: 7,
                    ),

                  ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation,
                      builder: (context, value, widget){
                        return  (Features.ismultivendor && Features.isPushNotificationroot) ?
                        VxBuilder<GroceStore>(
                          mutations: {SetUserData, Features.ismultivendor?HomeStoreScreenController:HomeScreenController},
                          builder: (context,GroceStore store, status) {
                            int _count = store.notificationCount ??= 0;
                            if (_count <= 0)
                              return Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  // color: Theme.of(context).buttonColor
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (value != S.of(context).not_available_location)
                                      if(!PrefUtils.prefs!.containsKey("apikey")){
                                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                      }else{
                                        Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.notify);

                                      }
                                  },
                                  child:
                                  Image.asset(
                                    Images.header_Notification,
                                    height: 25,
                                    width: 25,
                                    color: ColorCodes.headerIconColor,
                                  ),
                                ),
                              );
                            return Consumer<NotificationItemsList>(
                              builder: (_, cart, ch) => Badge(
                                child: ch!,
                                color: ColorCodes.darkgreen,
                                value: _count.toString(),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 10, right: 10, bottom: 10),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100)),
                                // color: Theme.of(context).buttonColor),
                                child: GestureDetector(
                                  onTap: () {
                                    if (value != S.of(context).not_available_location)
                                      if(!PrefUtils.prefs!.containsKey("apikey")){
                                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                      }else{
                                        Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.notify);
                                        NotificationController(NotificationTYP.clear);
                                      }
                                  },
                                  child:
                                  Image.asset(
                                    Images.header_Notification,
                                    height: 25,
                                    width: 25,
                                    color: ColorCodes.headerIconColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                            :
                        (Features.isPushNotification && !Features.ismultivendor) ?
                        ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation,
                            builder: (context, value, widget){
                              return VxBuilder<GroceStore>(
                                mutations: {SetUserData},
                                builder: (context,GroceStore store, status) {
                                  int _count = store.notificationCount ??= 0;
                                  if (_count <= 0)
                                    return Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        // color: Theme.of(context).buttonColor
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (value != S.of(context).not_available_location)
                                            if(!PrefUtils.prefs!.containsKey("apikey")){
                                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                            }else{
                                              Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.notify);

                                            }
                                        },
                                        child:
                                        Image.asset(
                                          Images.header_Notification,
                                          height: 25,
                                          width: 25,
                                          color: ColorCodes.headerIconColor,
                                        ),
                                      ),
                                    );
                                  return Consumer<NotificationItemsList>(
                                    builder: (_, cart, ch) => Badge(
                                      child: ch!,
                                      color: ColorCodes.badgecolor,
                                      value: _count.toString(),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: 10, right: 10, bottom: 10),
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100)),
                                      // color: Theme.of(context).buttonColor),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (value != S.of(context).not_available_location)
                                            if(!PrefUtils.prefs!.containsKey("apikey")){
                                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                            }else{
                                              Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.notify);
                                              NotificationController(NotificationTYP.clear);
                                            }
                                        },
                                        child:
                                        Image.asset(
                                          Images.header_Notification,
                                          height: 25,
                                          width: 25,
                                          color: ColorCodes.headerIconColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }) : SizedBox.shrink();
                      }),
                  SizedBox(
                    width: 2,
                  ),
                  ValueListenableBuilder(
                      valueListenable: IConstants.currentdeliverylocation,
                      builder: (context, value, widget){return VxBuilder(
                          // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                          builder: (context, GroceStore box, index) {
                    return Consumer<CartCalculations>(
                      builder: (_, cart, ch) => Badge(
                        child: ch!,
                        color: ColorCodes.badgecolor,
                        value: CartCalculations.itemCount.toString(),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (value != S.of(context).not_available_location)
                            Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                          width: 27,
                          height: 27,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                           ),
                          child: Image.asset(
                            Features.ismultivendor?Images.MultivendorCart:Images.header_cart,
                                    height: 27,
                                    width: 27,
                                    color: ColorCodes.headerIconColor,
                                  ),
                                ),
                              ),);
                          },mutations: {SetCartItem},
                        );}),
                  SizedBox(width: 7),
                ],
              ),
              IConstants.isEnterprise && !Features.isWebTrail ?
              SizedBox(
                height: 5,
              ) :
              SizedBox(
                height: 0,
              ),
              IConstants.isEnterprise && !Features.ismultivendor?
              IConstants.isEnterprise && !Features.isWebTrail ?
              Container(
                height: 35,
                padding: EdgeInsets.only(left: 5,right: 5),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        PrefUtils.prefs!.setString("formapscreen", "homescreen");
                        Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                            qparms:{
                              "valnext": "",
                            });
                      },
                      child: Image.asset(Images.pickup_point, height:25, width: 25, color: ColorCodes.badgecolor)/*Icon(Icons.location_on,
                          color: ColorCodes.darkgreen, size: 33),*/
                    ),
                    VxBuilder(
                        mutations: {SetPrimeryLocation,Features.ismultivendor?HomeStoreScreenController:HomeScreenController},
                        builder: (context,GroceStore store,state){
                          String _deliverLocation = "";
                          String _deliveryLocmain = "";
                          String _deliverySubloc = "";
                          _deliverLocation = store.userData.area!=null?store.userData.area! : "";
                          if(_deliverLocation!=null ){
                            if(_deliverLocation.indexOf(' ') >= 0){
                              int idx = _deliverLocation.indexOf(" ");
                              _deliveryLocmain = _deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation.substring(idx+1).trim().toString();
                            } if(_deliverLocation.indexOf(',') >= 0) {
                              int idx = _deliverLocation.indexOf(",");
                              _deliveryLocmain = _deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation.substring(idx+1).trim().toString();
                            } else{
                              _deliveryLocmain = _deliverLocation;//_deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation;//_deliverLocation.substring(idx+1).trim().toString();
                            }

                          }
                          return Padding(
                            padding: const EdgeInsets.only(left:5.0),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                PrefUtils.prefs!.setString("formapscreen", "homescreen");
                                // Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                                //     qparms:{
                                //       "valnext": "",
                                //     });
                                Navigation(context, name:Routename.NewMapScreen,navigatore: NavigatoreTyp.Push,
                                    qparms:{
                                      "valnext": "",
                                    });
                              },
                              child: RichText(
                                maxLines: 3,
                                overflow:TextOverflow.ellipsis,
                                text: new TextSpan(
                                  children: <TextSpan>[
                                    new TextSpan(
                                      text: _deliveryLocmain + "\n",//_delLocation[0].trim()+"\n",
                                      //(_deliverLocation!=null)?_deliverLocation:"",
                                      style: TextStyle(
                                          color: ColorCodes.whiteColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    new TextSpan(
                                      text: _deliverySubloc,//_delLocation[1].trim(),//"Ambalapadi, Udupi, Karnataka...............",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9, color: ColorCodes.whiteColor ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                    Spacer(),
                    //SizedBox(width: 25.0),
                    Padding(
                      padding: const EdgeInsets.only(left:5.0),
                      child: ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation, builder: (context, value, widget){
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search);

                          },
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width / 1.7,
                            decoration: BoxDecoration(
                                color: ColorCodes.varcolor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ColorCodes.lightGreyWebColor)
                            ),
                            padding: EdgeInsets.only(left: 7,right: 10),

                            child: Row(
                              children: [
                                Icon(
                                    Icons.search,
                                    color: ColorCodes.primaryColor,
                                    size: 22
                                ),
                                SizedBox(width: 5),
                                Text(
                                  S.current.search_from_products,//" Search From 10,000+ products",
                                  style: TextStyle(
                                    color: ColorCodes.primaryColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                //SizedBox(width: MediaQuery.of(context).size.width),

                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              )
             /* ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation, builder: (context, value ,widget){
                return  Container(

                  height: 40,
                  decoration: BoxDecoration(
                      color: ColorCodes.searchColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ColorCodes.searchBoarder)
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 15,right: 15),

                  child: IntrinsicHeight(
                    child:
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (value != S.of(context).not_available_location)
                              Navigation(context, name:Routename.Category, navigatore: NavigatoreTyp.Push);
                          },
                          child: Image.asset(
                            Images.categoriesImg,
                            height: 24,
                            color: ColorCodes.whiteColor,
                          ),
                        ),
                        SizedBox(width: 4),
                        VerticalDivider(
                          color: ColorCodes.whiteColor,
                          endIndent: 8,
                          indent: 8,
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            // if (_isDelivering)
                            if (value != S.of(context).not_available_location)
                              Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.76,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.current.search_from_products,//" Search From 10,000+ products",
                                  style: TextStyle(
                                    color: ColorCodes.searchText,

                                  ),
                                ),
                                //SizedBox(width: MediaQuery.of(context).size.width),
                                Icon(
                                  Icons.search,
                                  color: ColorCodes.searchIcon,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              })*/
                  :
              Container(
                height: 35,
                padding: EdgeInsets.only(left: 5,right: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        PrefUtils.prefs!.setString("formapscreen", "homescreen");
                        Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                            qparms:{
                              "valnext": "",
                            });
                      },
                      child: Icon(Icons.location_on,
                          color: ColorCodes.darkgreen, size: 33),
                    ),
                    VxBuilder(
                        mutations: {SetPrimeryLocation,Features.ismultivendor?HomeStoreScreenController:HomeScreenController},
                        builder: (context,GroceStore store,state){
                          String _deliverLocation = "";
                          String _deliveryLocmain = "";
                          String _deliverySubloc = "";
                          _deliverLocation = store.userData.area!=null?store.userData.area! : "";
                          if(_deliverLocation!=null ){
                            if(_deliverLocation.indexOf(' ') >= 0){
                              int idx = _deliverLocation.indexOf(" ");
                              _deliveryLocmain = _deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation.substring(idx+1).trim().toString();
                            } if(_deliverLocation.indexOf(',') >= 0) {
                              int idx = _deliverLocation.indexOf(",");
                              _deliveryLocmain = _deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation.substring(idx+1).trim().toString();
                            } else{
                              _deliveryLocmain = _deliverLocation;//_deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation;//_deliverLocation.substring(idx+1).trim().toString();
                            }

                          }
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                PrefUtils.prefs!.setString("formapscreen", "homescreen");
                                Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                                    qparms:{
                                      "valnext": "",
                                    });
                              },
                              child: RichText(
                                maxLines: 3,
                                overflow:TextOverflow.ellipsis,
                                text: new TextSpan(
                                  children: <TextSpan>[
                                    new TextSpan(
                                      text: _deliveryLocmain + "\n",//_delLocation[0].trim()+"\n",
                                      //(_deliverLocation!=null)?_deliverLocation:"",
                                      style: TextStyle(
                                          color: ColorCodes.blackColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    new TextSpan(
                                      text: _deliverySubloc,//_delLocation[1].trim(),//"Ambalapadi, Udupi, Karnataka...............",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8, color: ColorCodes.grey ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                    SizedBox(width: 10.0),
                    ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation, builder: (context, value, widget){
                      return Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width / 1.7,
                        decoration: BoxDecoration(
                            color: ColorCodes.lightGreyWebColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ColorCodes.lightGreyWebColor)
                        ),
                        padding: EdgeInsets.only(left: 7,right: 10),

                        child: IntrinsicHeight(
                          child:
                          Row(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search);

                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons.search,
                                          color: ColorCodes.grey,
                                          size: 22
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        S.current.search_from_products,//" Search From 10,000+ products",
                                        style: TextStyle(
                                          color: ColorCodes.grey,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      //SizedBox(width: MediaQuery.of(context).size.width),

                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ):
              Container(
                height: 35,
                padding: EdgeInsets.only(left: 5,right: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        PrefUtils.prefs!.setString("formapscreen", "homescreen");
                        Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                            qparms:{
                              "valnext": "",
                            });
                      },
                      child: Icon(Icons.location_on,
                          color: Features.ismultivendor? ColorCodes.darkthemeColor : ColorCodes.darkgreen, size: 28),
                    ),
                    VxBuilder(
                        mutations: {SetPrimeryLocation,Features.ismultivendor?HomeStoreScreenController:HomeScreenController},
                        builder: (context,GroceStore store,state){
                          String _deliverLocation = "";
                          String _deliveryLocmain = "";
                          String _deliverySubloc = "";
                          _deliverLocation = store.userData.area!=null?store.userData.area! : Features.ismultivendor?PrefUtils.prefs!.containsKey("area")?PrefUtils.prefs!.getString("area")??"":"":"";
                          if(_deliverLocation!=null ){
                            if(_deliverLocation.indexOf(' ') >= 0){
                              int idx = _deliverLocation.indexOf(" ");
                              _deliveryLocmain = _deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation.substring(idx+1).trim().toString();
                            } if(_deliverLocation.indexOf(',') >= 0) {
                              int idx = _deliverLocation.indexOf(",");
                              _deliveryLocmain = _deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation.substring(idx+1).trim().toString();
                            } else{
                              _deliveryLocmain = _deliverLocation;//_deliverLocation.substring(0,idx).trim().toString();
                              _deliverySubloc = _deliverLocation;//_deliverLocation.substring(idx+1).trim().toString();
                            }

                          }
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                PrefUtils.prefs!.setString("formapscreen", "homescreen");
                                Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                                    qparms:{
                                      "valnext": "",
                                    });
                              },
                              child: RichText(
                                maxLines: 3,
                                overflow:TextOverflow.ellipsis,
                                text: new TextSpan(
                                  children: <TextSpan>[
                                    new TextSpan(
                                      text: _deliveryLocmain + "\n",//_delLocation[0].trim()+"\n",
                                      //(_deliverLocation!=null)?_deliverLocation:"",
                                      style: TextStyle(
                                          color: ColorCodes.darkthemeColor,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    new TextSpan(
                                      text: _deliverySubloc,//_delLocation[1].trim(),//"Ambalapadi, Udupi, Karnataka...............",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 8, color: ColorCodes.grey ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        PrefUtils.prefs!.setString("formapscreen", "homescreen");
                        Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
                            qparms:{
                              "valnext": "",
                            });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.keyboard_arrow_down_sharp,
                              color: Features.ismultivendor? ColorCodes.darkthemeColor : ColorCodes.darkgreen, size: 25),
                        ],
                      ),
                    ),
                    SizedBox(width: 5.0),
                    ValueListenableBuilder(valueListenable: IConstants.currentdeliverylocation, builder: (context, value, widget){
                      return Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width / 1.8,
                        //color: ColorCodes.grey,
                        decoration: BoxDecoration(
                            color: ColorCodes.lightGreyWebColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ColorCodes.lightGreyWebColor)
                        ),
                        padding: EdgeInsets.only(left: 7,right: 10),

                        child: IntrinsicHeight(
                          child:
                          Row(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  (Features.ismultivendor && IConstants.isEnterprise)?
                                  Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.SearchStore):
                                  Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search);
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons.search,
                                          color:  Features.ismultivendor ? ColorCodes.darkthemeColor : ColorCodes.grey,
                                          size: 22
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        Features.ismultivendor ? S.current.search_store_prouct/*"Search stores and products"*/ :  S.current.search_from_products,//" Search From 10,000+ products",
                                        style: TextStyle(
                                          color: Features.ismultivendor ?ColorCodes.darkthemeColor : ColorCodes.grey,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      //SizedBox(width: MediaQuery.of(context).size.width),

                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),

                  ],
                ),
              ),
              Spacer(),
              Container(
                height: 4,
                width: MediaQuery.of(context).size.width,
                color: IConstants.isEnterprise && !Features.ismultivendor?IConstants.isEnterprise && !Features.isWebTrail ? ColorCodes.primaryColor : ColorCodes.whiteColor:ColorCodes.whiteColor,
              ),
              // IConstants.isEnterprise && !Features.ismultivendor?
              // IConstants.isEnterprise && !Features.isWebTrail ?
              // Container(
              //     decoration: BoxDecoration(
              //       color: ColorCodes.whiteColor,
              //     ),
              //     width: MediaQuery.of(context).size.width,
              //     height: 32,
              //     child: Row(
              //         children: [
              //           SizedBox(
              //             width: 15,
              //           ),
              //           GestureDetector(
              //             behavior: HitTestBehavior.translucent,
              //             onTap: () async {
              //               PrefUtils.prefs!.setString("formapscreen", "homescreen");
              //               Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
              //                   qparms:{
              //                     "valnext": "",
              //                   });
              //             },
              //             child: Icon(Icons.location_on,
              //                 color: ColorCodes.deliveryLocation, size: 16),
              //           ),
              //           SizedBox(
              //             width: 5.0,
              //           ),
              //           VxBuilder(
              //             mutations: {SetPrimeryLocation,HomeScreenController},
              //             builder: (context,GroceStore store,state){
              //               return  Expanded(
              //                 child: GestureDetector(
              //                   behavior: HitTestBehavior.translucent,
              //                   onTap: () async {
              //                     PrefUtils.prefs!.setString("formapscreen", "homescreen");
              //                     Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push,
              //                         qparms:{
              //                           "valnext": "",
              //                         });
              //                   },
              //                   child: Text(
              //                     store.userData.area!=null?store.userData.area!:"",
              //                     maxLines: 1,
              //                     overflow: TextOverflow.ellipsis,
              //                     style: TextStyle(
              //                         color: ColorCodes.deliveryLocation,
              //                         fontSize: 16.0,
              //                         fontWeight: FontWeight.bold),
              //                   ),
              //                 ),
              //               );
              //             }
              //           ),
              //           SizedBox(
              //             width: 5,
              //           ),
              //           GestureDetector(
              //               behavior: HitTestBehavior.translucent,
              //               onTap: () async {
              //                 PrefUtils.prefs!.setString("formapscreen", "homescreen");
              //                 Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push);
              //                // Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
              //               },
              //               child: Text(
              //                 S.of(context).change,//"Change",
              //                 style: TextStyle(
              //                     color: ColorCodes.deliveryLocation,
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.bold),
              //               )),
              //           SizedBox(
              //             width: 15,
              //           )
              //         ])) :
              // SizedBox.shrink():SizedBox.shrink(),
            ]));
  }

  showSubCategory(String catid, String title, String description) {
    ProductController productController = ProductController();
    if(store.homescreen.data!.allCategoryDetails![store.homescreen.data!.allCategoryDetails!.indexWhere((element) => element.id == catid)].subCategory.isEmpty)
    productController.geSubtCategory(catid,onload:(bool status){});
      return VxBuilder(builder: (context, GroceStore store,state){

  int j=0;
  List<CategoryData> subcategoryData =[];
  final catlist = store.homescreen.data!.allCategoryDetails;
  if(catlist!=null) subcategoryData = store.homescreen.data!.allCategoryDetails![catlist.indexWhere((element) => element.id == catid)].subCategory;
  return Container(
    padding: EdgeInsets.only(left: 20,/*bottom:30*/),
    child: PopupMenuButton(
      tooltip: description,
      offset: const Offset(0, 50),
      onSelected: (String selectedValue) {setState(() {widget.onSubcatClick==null?
      Navigation(context, name: Routename.ItemScreen, navigatore: NavigatoreTyp.Push,
          qparms: {
            'maincategory': title.toString(),
            'catId': catid.toString(),
            'catTitle': title.toString(),
            'subcatId': selectedValue.toString(),
            'indexvalue': j.toString(),
            'prev': "category_item"
          })
          :widget.onSubcatClick!(catid,selectedValue,0,j);});},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child:Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        for (j=1;j<subcategoryData.length;j++)
          new PopupMenuItem<String>(
            height: 30,
            child: Text(subcategoryData[j].categoryName!,style: TextStyle(fontSize: 16),),
            value: subcategoryData[j].id,
          ),
      ],
    ),
  );
}, mutations: {ProductMutation});
  }
  Future<void> logout() async {
    PrefUtils.prefs!.remove('LoginStatus');
    try {
      if (PrefUtils.prefs!.getString('prevscreen') == 'signingoogle') {
        PrefUtils.prefs!.setString("photoUrl", "");
        await _googleSignIn.signOut();
      } else if (PrefUtils.prefs!.getString('prevscreen') == 'signinfacebook') {
        PrefUtils.prefs!.getString("FBAccessToken");
        var facebookSignIn = FacebookLoginWeb();
        final graphResponse = await http.delete(
            'https://graph.facebook.com/v2.12/me/permissions/?access_token=${PrefUtils.prefs!.getString("FBAccessToken")}&httpMethod=DELETE&ref=logout&destroy=true');
        PrefUtils.prefs!.setString("photoUrl", "");
        await facebookSignIn.logOut().then((value) {
        });
      }
    } catch (e) {
    }
    String branch = PrefUtils.prefs!.getString("branch")!;
    String _tokenId = PrefUtils.prefs!.getString("tokenid")!;
    String _ftokenId = PrefUtils.prefs!.getString("ftokenid")!;
    String _restaurant_location = PrefUtils.prefs!.getString("restaurant_location")!;
    String _deliverylocation = PrefUtils.prefs!.getString("deliverylocation")!;
    PrefUtils.prefs!.clear();
    PrefUtils.prefs!.setBool('introduction', true);
    PrefUtils.prefs!.setString("branch", branch);
    PrefUtils.prefs!.setString('skip', "yes");
    PrefUtils.prefs!.setString('ftokenid', _ftokenId);
    PrefUtils.prefs!.setString('tokenid', _tokenId);
    PrefUtils.prefs!.setString('restaurant_location', _restaurant_location);
    PrefUtils.prefs!.setString('deliverylocation', _deliverylocation);
    Navigation(context, /*name:Routename.Home,*/navigatore: NavigatoreTyp.homenav);

    setState(() {
      checkSkip = true;
    });
  }
}


class Debouncer {
  final int? milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}