import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../constants/features.dart';
import 'package:velocity_x/velocity_x.dart';
import '../generated/l10n.dart';
import '../models/myordersfields.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../rought_genrator.dart';
import '../widgets/simmers/order_screen_shimmer.dart';
import 'package:provider/provider.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../utils/ResponsiveLayout.dart';
import '../providers/myorderitems.dart';
import '../screens/home_screen.dart';
import '../widgets/myorder_display.dart';
import '../assets/images.dart';
import '../assets/ColorCodes.dart';
import '../utils/prefUtils.dart';
import 'home_screen.dart';
import '../constants/IConstants.dart';

class MyorderScreen extends StatefulWidget {
  static const routeName = '/myorder-screen';
  String orderhistory  = "";
  Map<String,String>? myorder;


  MyorderScreen(Map<String, String> params){
    this.myorder= params;
    this.orderhistory = params["orderhistory"]??"" ;

  }
  @override
  _MyorderScreenState createState() => _MyorderScreenState();
}

class _MyorderScreenState extends State<MyorderScreen> with Navigations{
  var totalamount;
  var totlamount;
  var _isLoading = true;
  var _checkorders = false;
  var _address = "";
  MediaQueryData? queryData;
  double? wid;
  double? maxwid;
  bool iphonex = false;
  int startItem = 0;
  var myorderData;
  var _checkitem = false;
  bool endOfProduct = false;
  var load = true;
  bool _isOnScroll = false;
  ItemScrollController? _scrollController;
  Map<String, List<MyordersFields>>? groupByDate;

  List<List<MyordersFields>> myorders =[] ;



  @override
  void initState() {

    _scrollController = ItemScrollController();
    Future.delayed(Duration.zero, () {
     /* Provider.of<MyorderList>(context, listen: false).Getorders().then((_) async {
        //prefs = await SharedPreferences.getInstance();
        _address = PrefUtils.prefs!.getString("restaurant_address");
        setState(() {
          _isLoading = false;
        });
      });*/
      endOfProduct = false;
      load = true;
      _checkorders = false;
      startItem = 0;
      Provider.of<MyorderList>(context, listen: false).GetSplitorders(startItem.toString(),"initialy").then((_) async {
        /*myorderData = Provider.of<MyorderList>(context, listen: false);
        startItem = myorderData.items.length;
        debugPrint("startItem........init"+"  "+startItem.toString());*/
        //prefs = await SharedPreferences.getInstance();
        debugPrint("spp......"+PrefUtils.prefs!.getString("restaurant_address")!);
        _address = PrefUtils.prefs!.getString("restaurant_address")!;
        setState(() {
          myorderData = Provider.of<MyorderList>(context, listen: false);
           groupByDate = groupBy(myorderData.items, (obj) => obj.reference_id!);
          groupByDate!.forEach((date, list) {
            // Header
            print("init...group..");
            print('group....'+groupByDate!.length.toString());

            // Group
            myorders.add(list);
            print("myorder darac"+myorders.length.toString());
            // day section divider
            print('\n');
          });



          startItem = myorderData.items.length;
          if (myorderData.items.length <= 0) {
            _checkorders = false;
          } else {
            _checkorders = true;
          }
          _isLoading = false;
          load = false;
          /*if (myorderData.items.length <= 0) {
            _checkorders = false;
          } else {
            _checkorders = true;
          }*/

        });

       /* Future.delayed(Duration.zero, () async {
          _scrollController.jumpTo(
            index: startItem,
            *//*duration: Duration(seconds: 1)*//*
          );
        });*/
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    queryData = MediaQuery.of(context);
    wid= queryData!.size.width;
    maxwid=wid!*0.90;
    return WillPopScope(
      onWillPop: () {
        // this is the block you need
       /* Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);*/
        if(/*routeArgs['orderhistory']*/widget.orderhistory == "orderhistoryScreen"){
          debugPrint("order confirm order history....1");
        /*  SchedulerBinding.instance?.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home-screen', (Route<dynamic> route) => false);
          });*/
        if (Vx.isWeb ) {
          debugPrint("clicked.....my");
          Navigation(context, navigatore: NavigatoreTyp.homenav);
         // Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
         else{
          Navigation(context, navigatore: NavigatoreTyp.homenav);
          /*Navigator.of(context).popUntil(ModalRoute.withName(
              HomeScreen.routeName));*/
        }
        //  Navigator.of(context).pushNamed(HomeScreen.routeName,);
        }else if(/*routeArgs['orderhistory']*/widget.orderhistory  == "web"){
          debugPrint("web.....1");
          Navigation(context, navigatore: NavigatoreTyp.homenav);
          //Navigator.of(context).pushNamed(HomeScreen.routeName,);
        }else{
          debugPrint("else....1");
         if (Vx.isWeb ){
           debugPrint("clicked.....myelse");
           Navigation(context, navigatore: NavigatoreTyp.homenav);
          // Navigator.pushReplacementNamed(context, HomeScreen.routeName, );
          /* Navigator.of(context).pop();*/
         }
         else{
           Navigation(context, navigatore: NavigatoreTyp.homenav);//Navigator.of(context).pop();
         }

        }
        return Future.value(false);
        /*Navigator.of(context).popUntil(ModalRoute.withName(
          HomeScreen.routeName));
        return Future.value(false);*/
      },
      child: Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context)
            ? gradientappbarmobile()
            : null,
        backgroundColor: ColorCodes.whiteColor,//Theme.of(context).backgroundColor,
        body: Column(
          children: <Widget>[
            if(Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
              _body(),
          ],
        ),
      ),
    );
  }

  _body() {
    // myorderData = Provider.of<MyorderList>(context, listen: false);
    // if (myorderData.items.length <= 0) {
    //   _checkorders = false;
    // } else {
    //   _checkorders = true;
    // }
       // startItem = 0;
    /*if(ResponsiveLayout.isExtraLargeScreen(context)){
      do {
        setState(() {
          startItem = myorderData.items.length ?? 0;
        });
        Provider.of<MyorderList>(context, listen: false)
            .GetSplitorders(
            startItem.toString(),
            "scrolling"
            )
            .then((_) {
          setState(() {
            // startItem = itemslistData.items.length;
            debugPrint("startItem........body"+"  "+startItem.toString());
            myorderData = Provider.of<MyorderList>(context, listen: false);
          });
          if (PrefUtils.prefs
              .getBool("endOfOrder")) {
            setState(() {
              startItem = 0;
              debugPrint("startItem........body1"+"  "+startItem.toString());
              _isOnScroll = false;
              endOfProduct = true;
            });
          } else {
            setState(() {
              _isOnScroll = false;
              endOfProduct = false;
            });

          }
        });
      }while(PrefUtils.prefs!.getBool("endOfOrder"));
    }*/



    return _checkorders
        ? Flexible(
      fit: FlexFit.loose,
      child: NotificationListener<
          ScrollNotification>(
        // ignore: missing_return
        onNotification:
            (ScrollNotification scrollInfo) {
          if (!endOfProduct) if (!_isOnScroll && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            setState(() {
              _isOnScroll = true;
            });
            Provider.of<MyorderList>(context, listen: false).GetSplitorders(startItem.toString(), "scrolling").then((_) {
              setState(() {
                debugPrint("startItem........body2"+"  "+startItem.toString());
                myorders.clear();
                //itemslistData = Provider.of<ItemsList>(context, listen: false);
                myorderData = Provider.of<MyorderList>(context, listen: false);

                int enditem = myorderData.items.length;
                print("enditem...."+enditem.toString());

                startItem = myorders.length +1;
                groupByDate = groupBy(myorderData.items, (obj) => obj.reference_id!);
                groupByDate!.forEach((date, list) {
                  myorders.add(list);
                  //myorders.insert(enditem,list);

                });
                startItem = myorderData.items.length;
                if (myorders.length <= 0) {
                  _checkorders = false;
                } else {
                  _checkorders = true;
                }
                debugPrint("startItem........body3"+"  "+startItem.toString());
                if (PrefUtils.prefs!
                    .getBool("endOfOrder")!) {
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
              _isLoading = true;
            });

          }
          return true;

        },

        child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                   if (myorderData.items.length > 0)
                  //   _isLoading
                  //       ? (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))? Center(
                  //     child: OrderScreenShimmer(),
                  //   ): Center(
                  //     child: OrderScreenShimmer(),
                  //   )
                  //       :
                    Column(
                          children: [


                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                //  constraints: (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                                  padding: EdgeInsets.only(left:(Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?18 : 0.0,right: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context)) ? 18 : 0.0),
                                  child: SizedBox(
                                   // height:MediaQuery.of(context).size.height-100,
                                    child: ListView.builder(
                                     // physics: NeverScrollableScrollPhysics(),
                                     // itemScrollController: _scrollController,
                                      shrinkWrap: true,
                                      controller: new ScrollController(keepScrollOffset:false),
                                      itemCount: myorders.length,
                                      itemBuilder: (_, i) => MyorderDisplay( myorders[i]),
                                    ),
                                  ),
                                ),
                              ),

                          ],
                        ),

                  if (endOfProduct)
                    Container(

                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                      margin: EdgeInsets.only(top: 10.0),
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        S .of(context).thats_all,
                        // "That's all folks!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),

                  if(!Vx.isWeb) Container(
                    height: _isOnScroll ? 50 : 0,
                    child: Center(
                      child: new CircularProgressIndicator(),
                    ),
                  ),

                  SizedBox(
                    height: 20.0,
                  ),
                  if (Vx.isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
                ],
              ),
            ),
          )
    )
        : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _isLoading
                    ? (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))? Center(
                        child:OrderScreenShimmer(),
                      ): Center(
                        child: OrderScreenShimmer(),
                      )
                      :
                      EmptyOrder(),
                      if (Vx.isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
                    ],
                  ),
                ),
              );
  }

  Widget EmptyOrder() {
    return Column(
      children: [
        Image.asset(Images.myorderImg),
        Text(
          S .of(context).start_shopping,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          S .of(context).lets_get_you_started,
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          height: 20.0,
        ),
        GestureDetector(
          onTap: () {
            /*Navigator.of(context).popUntil(ModalRoute.withName(
              HomeScreen.routeName,
            ));*/
            Navigation(context, navigatore: NavigatoreTyp.homenav);
          },
          child: Container(
            width: 120.0,
            height: 40.0,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(3.0),
                border: Border(
                  top: BorderSide(
                      width: 1.0, color: Theme.of(context).primaryColor),
                  bottom: BorderSide(
                      width: 1.0, color: Theme.of(context).primaryColor),
                  left: BorderSide(
                      width: 1.0, color: Theme.of(context).primaryColor),
                  right: BorderSide(
                    width: 1.0,
                    color: Theme.of(context).primaryColor,
                  ),
                )),
            child: Center(
                child: Text(
                  S .of(context).start_shopping,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                )),
          ),
        ),
      ],
    );
  }

  gradientappbarmobile() {
    final routeArgs =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: (IConstants.isEnterprise)?0:1,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: IConstants.isEnterprise && !Features.ismultivendor && !Features.isWebTrail?ColorCodes.menuColor:ColorCodes.iconColor),
          onPressed: () async {
            // this is the block you need
            /* Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);*/
            if(/*routeArgs['orderhistory']*/widget.orderhistory  == "orderhistoryScreen"){
              debugPrint("order confirm order history....1");
              /*  SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home-screen', (Route<dynamic> route) => false);
          });*/
              if (Vx.isWeb ) {
                debugPrint("clicked.....my");
                Navigation(context, navigatore: NavigatoreTyp.homenav);
                //Navigator.pushReplacementNamed(context, HomeScreen.routeName);
              }
              else{
                Navigator.of(context).pop();
              //  Navigation(context, navigatore: NavigatoreTyp.homenav);
                /*Navigator.of(context).popUntil(ModalRoute.withName(
                    HomeScreen.routeName));*/
              }
              //  Navigator.of(context).pushNamed(HomeScreen.routeName,);
            }else if(/*routeArgs['orderhistory']*/widget.orderhistory == "web"){
              debugPrint("web.....1");
              Navigator.of(context).pop();
             // Navigation(context, navigatore: NavigatoreTyp.homenav);
              //Navigator.of(context).pushNamed(HomeScreen.routeName,);
            }else{
              debugPrint("else....1");
              if (Vx.isWeb ){
                debugPrint("clicked.....myelse");
                Navigation(context, navigatore: NavigatoreTyp.homenav);
                //Navigator.pushReplacementNamed(context, HomeScreen.routeName, );
                /* Navigator.of(context).pop();*/
              }
              else{
                Navigator.of(context).pop();
                //Navigation(context, navigatore: NavigatoreTyp.homenav);
                //Navigation(context, navigatore: NavigatoreTyp.Pop);
                //Navigator.of(context).pop();
              }

            }
            return Future.value(false);
            /*Navigator.of(context).popUntil(ModalRoute.withName(
          HomeScreen.routeName));
        return Future.value(false);*/




          //  /* SchedulerBinding.instance.addPostFrameCallback((_) {
          //     Navigator.of(context).pushNamedAndRemoveUntil(
          //         '/home-screen', (Route<dynamic> route) => false);
          //   });*/
          // //  Navigator.of(context).pop();
          //
          //   if(routeArgs['orderhistory'] == "orderhistoryScreen"){
          //     debugPrint("order confirm order history....");
          //     Navigator.of(context).popUntil(ModalRoute.withName(
          //         HomeScreen.routeName));
          //    // Navigator.of(context).pushNamed(HomeScreen.routeName,);
          //   }else{
          //     debugPrint("esle....");
          //     Navigator.of(context).pop();
          //   }
          //   /*Navigator.of(context).popUntil(ModalRoute.withName(
          //       HomeScreen.routeName));*/

          }),
      titleSpacing: 0,
      title: Text(
        S .of(context).my_orders,
        style: TextStyle(color: ColorCodes.iconColor, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorCodes.appbarColor,
                  ColorCodes.appbarColor2
                ])),
      ),
    );
  }
}
