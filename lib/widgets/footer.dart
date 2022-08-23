import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../assets/ColorCodes.dart';
import '../../controller/mutations/home_screen_mutation.dart';
import '../../widgets/simmers/home_screen_shimmer.dart';
import '../constants/features.dart';
import '../generated/l10n.dart';
import '../models/VxModels/VxStore.dart';
import '../rought_genrator.dart';
import '../widgets/CoustomeDailogs/slectlanguageDailogBox.dart';
import 'package:velocity_x/velocity_x.dart';
import '../blocs/sliderbannerBloc.dart';
import '../models/brandFiledModel.dart';
import '../screens/items_screen.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/IConstants.dart';
import '../utils/ResponsiveLayout.dart';
import '../providers/branditems.dart';
import '../providers/categoryitems.dart';
import '../screens/brands_screen.dart';
import '../screens/policy_screen.dart';
import '../assets/images.dart';
import '../utils/prefUtils.dart';

class Footer extends StatefulWidget {
  final String address;

  const
  Footer({
    Key? key,
    required this.address,
  }): super(key: key);

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> with Navigations{
  String brandsName = "";
  ItemScrollController? _scrollController;
  GroceStore store = VxState.store;
  bool checkskip = false;

  @override
  void initState() {
   /* Future.delayed(Duration.zero, () async {
      final brandsData = Provider.of<BrandItemsList>(context, listen: false);
      for (int i = 0; i < (brandsData.items.length > 6 ? 6 : brandsData.items.length); i++) {
        setState(() {
          if (i == 0) {
            brandsName = brandsData.items[i].title!;
          } else if (i == 5 || i == brandsData.items.length - 1) {
            brandsName = brandsName + brandsData.items[i].title!;
          } else {
            brandsName = brandsName + brandsData.items[i].title! + ", ";
          }
          if (PrefUtils.prefs!.containsKey("apikey")) {
            checkskip = true;
          } else {
            checkskip = false;
          }
        });
      }
    });*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ResponsiveLayout.isSmallScreen(context)
          ? createFooterForMobile()
          : createFooterForWeb(),
    );
  }

  createFooterForWeb() {
    // final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    // final brandsData = Provider.of<BrandItemsList>(context, listen: false);

    //var returns;
    return Column(
      children: [
       /* SizedBox(
          height: 70.0,
        ),*/
        Divider(),
        SizedBox(
          height: 30.0,
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(),
              flex: 10,
            ),
            if(Features.isCategory)
            Expanded(

              child: Container(
                padding: EdgeInsets.only(left: 20),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Text( S .of(context).categories, style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),),
                    VxBuilder(
                        mutations: {HomeScreenController},
                        builder: (ctx,store,VxStatus? state) {
                        final homedata = (store as GroceStore).homescreen;

                        if(VxStatus.success==state)
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: (homedata.data!.allCategoryDetails!.length > 6)
                                  ? 6
                                  : homedata.data!.allCategoryDetails!.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (_, i) =>
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      debugPrint("nooooo...." +
                                          homedata.data!.allCategoryDetails![i].id
                                              .toString());
                                      /* Navigator.of(context).pushNamed(
                                                  ItemsScreen.routeName, arguments: {
                                                'maincategory': store.homescreen.data!.allCategoryDetails![i].categoryName,
                                                'catId': store.homescreen.data!.allCategoryDetails![i].id,
                                                'catTitle': store.homescreen.data!.allCategoryDetails![i].categoryName,
                                                'subcatId': store.homescreen.data!.allCategoryDetails![i].id,
                                                'indexvalue': i.toString(),
                                                'prev': "category_item"
                                              });*/
                                      Navigation(context, name: Routename.ItemScreen,
                                          navigatore: NavigatoreTyp.Push,
                                          qparms: {
                                            // 'maincategory': store.homescreen.data!.allCategoryDetails![i].categoryName!,
                                            'catId': homedata.data!.allCategoryDetails![i]
                                                .id!,
                                            'catTitle': homedata.data!
                                                .allCategoryDetails![i].categoryName!,
                                            'subcatId': homedata.data!
                                                .allCategoryDetails![i].id!,
                                            'indexvalue': i.toString(),
                                            'prev': "footer_item"
                                          });
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                          homedata.data!.allCategoryDetails![i]
                                              .categoryName!,
                                          style: TextStyle(
                                              fontSize: 16.0, color: ColorCodes.footertitle),
                                        )
                                      ],
                                    ),
                                  ),
                            ),
                          );
                        else if(state==VxStatus.none){
                          print("error loading screen");
                          if((VxState.store as GroceStore).homescreen.toJson().isEmpty) {
                            HomeScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"), branch: PrefUtils.prefs!.getString("branch") ?? "999", rows: "0",);
                            return HomeScreenShimmer();
                          }else{
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: (homedata.data!.allCategoryDetails!.length > 6)
                                    ? 6
                                    : homedata.data!.allCategoryDetails!.length,
                                padding: EdgeInsets.zero,
                                itemBuilder: (_, i) =>
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        debugPrint("nooooo...." +
                                            homedata.data!.allCategoryDetails![i].id
                                                .toString());
                                        /* Navigator.of(context).pushNamed(
                                                  ItemsScreen.routeName, arguments: {
                                                'maincategory': store.homescreen.data!.allCategoryDetails![i].categoryName,
                                                'catId': store.homescreen.data!.allCategoryDetails![i].id,
                                                'catTitle': store.homescreen.data!.allCategoryDetails![i].categoryName,
                                                'subcatId': store.homescreen.data!.allCategoryDetails![i].id,
                                                'indexvalue': i.toString(),
                                                'prev': "category_item"
                                              });*/
                                        Navigation(context, name: Routename.ItemScreen,
                                            navigatore: NavigatoreTyp.Push,
                                            qparms: {
                                              // 'maincategory': store.homescreen.data!.allCategoryDetails![i].categoryName!,
                                              'catId': homedata.data!.allCategoryDetails![i]
                                                  .id!,
                                              'catTitle': homedata.data!
                                                  .allCategoryDetails![i].categoryName!,
                                              'subcatId': homedata.data!
                                                  .allCategoryDetails![i].id!,
                                              'indexvalue': i.toString(),
                                              'prev': "footer_item"
                                            });
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            homedata.data!.allCategoryDetails![i]
                                                .categoryName!,
                                            style: TextStyle(
                                                fontSize: 16.0, color: ColorCodes.footertitle),
                                          )
                                        ],
                                      ),
                                    ),
                              ),
                            );
                          }
                        }
                        return HomeScreenShimmer();

                    },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                 //   if(IConstants.restaurantTerms != "" || IConstants.returnsPolicy != "" || IConstants.refundPolicy != "" || IConstants.refundPolicy != "" || IConstants.walletPolicy != "" || PrefUtils.prefs!.getString("description") != "")
                    Text(
                     S .of(context).useful_link,
                      style:
                          TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    if(IConstants.restaurantTerms != "")
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                            'title': S .of(context).term_and_condition,  //"Terms & Conditions",
                            /*'body': IConstants.restaurantTerms,*/});
                        },
                        child: Text(
                          S .of(context).term_and_condition,
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                    if(IConstants.restaurantTerms != "")
                    SizedBox(
                      height: 16,
                    ),
                    if(PrefUtils.prefs!.getString("privacy") !="")
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                            'title' : S.of(context).privacy,
                            /*'body' : PrefUtils.prefs!.getString("privacy").toString(),*/});
                        },
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                    if(PrefUtils.prefs!.getString("privacy") !="")
                    SizedBox(
                      height: 16,
                    ),
                  if(IConstants.returnsPolicy != "")
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                            'title':  S.of(context).returns,  //"Return",
                            /*'body': IConstants.returnsPolicy,*/});
                        },
                        child: Text(
                          S .of(context).return_policy,
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                    if(IConstants.returnsPolicy != "")
                    SizedBox(
                      height: 16,
                    ),
                    if(IConstants.refundPolicy != "")
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                            'title': S.of(context).refund,  //"Refund",
                            /*'body': IConstants.refundPolicy,*/});
                        },
                        child: Text(
                          S .of(context).refund_policy,
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                    if(IConstants.refundPolicy != "")
                    SizedBox(
                      height: 16,
                    ),
                    if(IConstants.walletPolicy != "")
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                            'title': S .of(context).wallet,   //"Wallet",
                            /*'body': IConstants.walletPolicy,*/});
                        },
                        child: Text(
                          S .of(context).wallet_policy,
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                    if(IConstants.walletPolicy != "")
                    SizedBox(
                      height: 16,
                    ),
                    if(PrefUtils.prefs!.getString("description") != "")
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                            'title': S .of(context).about_us,   //"About Us",
                           /* 'body': PrefUtils.prefs!.getString("description").toString(),*/});
                        },
                        child: Text(
                          S .of(context).about_us,
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                    if(PrefUtils.prefs!.getString("description") != "")
                    SizedBox(
                      height: 16,
                    ),

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                          'title': "Contact Us",
                          /*'body': "",
                          'businessname': IConstants.restaurantName,
                          'address': PrefUtils.prefs!.getString("restaurant_address").toString(),
                          'contactnum': IConstants.primaryMobile,
                          'pemail': IConstants.primaryEmail,
                          'semail': IConstants.secondaryEmail,*/});
                        },
                        child: Text(
                          S .of(context).contact,
                          style: TextStyle(
                              fontSize: 16.0, color: ColorCodes.footertitle),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if(Features.isBrands) Text(
                      S .of(context).popular_brands,
                      style:
                          TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                    ),
                    if(Features.isBrands)SizedBox(height: 20,),
                    if(Features.isBrands)Container(
                      child:   VxBuilder(
                        // stream: bloc.brandfiledBloc,
                        mutations: {HomeScreenController},
                        builder: (ctx,store,VxStatus? state){
                          final homedata = (store as GroceStore).homescreen;
                          if(VxStatus.success==state)
                            if(homedata.data!.allBrands!=null){
                              String chunk = "";
                              String coma = "";
                              for(int i=0;i<homedata.data!.allBrands!.length;i++) {

                                chunk = chunk + coma + homedata.data!.allBrands![i].categoryName!;
                                coma=" , ";
                              }

                              return SizedBox(
                                height: 60,
                                child:  Column(
                                  children: [
                                    SizedBox(
                                      width: 10.0,
                                    ),

                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed(
                                              BrandsScreen.routeName,
                                              arguments: {
                                                'brandId': homedata.data!.allBrands![0]
                                                    .id,
                                                'indexvalue': 0.toString(),
                                              });
                                        },
                                        child: Text(
                                          chunk,
                                          maxLines: 5,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: ColorCodes.footertitle),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                  ],
                                ),

                              );}
                            /* if(snapshot.hasError){
                            return SizedBox.shrink();}*/
                            else return SizedBox.shrink();
                          else if(state==VxStatus.none){
                            print("error loading screen");
                            if((VxState.store as GroceStore).homescreen.toJson().isEmpty) {
                              HomeScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"), branch: PrefUtils.prefs!.getString("branch") ?? "999", rows: "0",);
                              return HomeScreenShimmer();
                            }else{
                              if(homedata.data!.allBrands!=null){
                                String chunk = "";
                                String coma = "";
                                for(int i=0;i<homedata.data!.allBrands!.length;i++) {

                                  chunk = chunk + coma + homedata.data!.allBrands![i].categoryName!;
                                  coma=" , ";
                                }

                                return SizedBox(
                                  height: 60,
                                  child:  Column(
                                    children: [
                                      SizedBox(
                                        width: 10.0,
                                      ),

                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushNamed(
                                                BrandsScreen.routeName,
                                                arguments: {
                                                  'brandId': homedata.data!.allBrands![0]
                                                      .id,
                                                  'indexvalue': 0.toString(),
                                                });
                                          },
                                          child: Text(
                                            chunk,
                                            maxLines: 5,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: ColorCodes.footertitle),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                    ],
                                  ),

                                );}
                              /* if(snapshot.hasError){
                            return SizedBox.shrink();}*/
                              else return SizedBox.shrink();
                            }
                          }
                          return HomeScreenShimmer();

                        },
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if(IConstants.androidId != "" || IConstants.appleId != "")
                      Text(
                        S .of(context).download_app,
                        style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    if(IConstants.androidId != "")
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: new InkWell(
                            onTap: () => launch("https://play.google.com/store/apps/details?id=" + IConstants.androidId),
                            child: Image.asset(Images.playstoreImg,height: 50,width: 150,)),
                      ),
                    if(IConstants.androidId != "")
                      SizedBox(
                        height: 4,
                      ),
                    if(IConstants.appleId != "")
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: new InkWell(
                          child: Image.asset(Images.appStroreImg,height: 50,width: 150,),
                          onTap: () => launch("https://apps.apple.com/us/app/grocbay/id" + IConstants.appleId),
                        ),
                      ),
                    if(IConstants.appleId != "")
                      SizedBox(
                        height: 8,
                      ),
                    if(IConstants.facebookUrl != "" || IConstants.twitterUrl != "" || IConstants.youtubeUrl != "" || IConstants.instagramUrl != "")
                      Text(
                        S .of(context).get_social_with_us,
                        style:
                        TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                      ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        if(IConstants.facebookUrl != "")
                          MouseRegion(
                            child: new InkWell(
                              child: Image.asset(Images.fbImg,
                                height: 30,
                                width: 30,),
                              onTap: () => launch(IConstants.facebookUrl),
                            ),
                          ),
                        if(IConstants.facebookUrl != "")
                          SizedBox(
                            width: 8.0,
                          ),
                        if(IConstants.twitterUrl != "")
                          MouseRegion(
                            child: new InkWell(
                              child: Image.asset(Images.twitterImg,height: 30,
                                width: 30,),
                              onTap: () => launch(IConstants.twitterUrl),
                            ),
                          ),
                        if(IConstants.twitterUrl != "")
                          SizedBox(
                            width: 8.0,
                          ),
                        if(IConstants.youtubeUrl != "")
                          MouseRegion(
                            child: new InkWell(
                              child:  Image.asset(Images.youtubeImg,height: 30,
                                width: 30,),
                              onTap: () =>launch(IConstants.youtubeUrl),
                            ),
                          ),
                        if(IConstants.youtubeUrl != "")
                          SizedBox(
                            width: 8.0,
                          ),
                        if(IConstants.instagramUrl != "")
                          MouseRegion(
                            child: new InkWell(
                              child:  Image.asset(Images.instaImg,height: 30,
                                width: 30,),
                              onTap: () =>launch(IConstants.instagramUrl),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S .of(context).payment_method,
                      style:
                          TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Image.asset(Images.paymentsImg),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      S .of(context).address,
                      style:
                          TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                    ),
                    Text(
                      IConstants.APP_NAME,
                      style:
                          TextStyle(fontSize: 17.0, color: ColorCodes.footertitle),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.address,
                      style:
                          TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if((VxState.store as GroceStore).language.languages.length > 1)
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showDialog(context: context, builder: (BuildContext context) => LanguageselectDailog(context));
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.language, size: 20, color: ColorCodes.footertext),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              S .current.language,
                              style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Icon(Icons.arrow_drop_down, size: 22,),

                          ],
                        ),
                      ),
                  ],
                ),
              ),
              flex: 30,
            ),
            Expanded(
              child: Container(),
              flex: 10,
            ),
          ],
        ),
        SizedBox(
          height: 50.0,
        ),
        Container(
          height: 96.0,
          color: ColorCodes.lightGreyWebColor,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
                S .of(context).copyright + IConstants.APP_NAME + ".",
            style: TextStyle(fontSize: 16.0, color: ColorCodes.borderdarkColor),
          )),
        )
      ],
    );
  }

  createFooterForMobile() {
    final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(Features.isCategory)Text(
                S .of(context).categories,
                style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
              ),
              if(Features.isCategory)ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: (categoriesData.items.length > 6)
                    ? 6
                    : categoriesData.items.length,
                padding: EdgeInsets.zero,
                itemBuilder: (_, i) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    /*Navigator.of(context)
                        .pushNamed(   ItemsScreen.routeName, arguments: {
    'maincategory': categoriesData.items[i].title,
    'catId': categoriesData.items[i].catid,
    'catTitle': categoriesData.items[i].title,
    'subcatId': categoriesData.items[i].catid,
    'indexvalue': i.toString(),
    'prev': "category_item"
    });*/
                    Navigation(context, name: Routename.ItemScreen, navigatore: NavigatoreTyp.Push,
                        parms: {
                          'maincategory': categoriesData.items[i].title!,
                          'catId': categoriesData.items[i].catid!,
                          'catTitle': categoriesData.items[i].title!,
                          'subcatId': categoriesData.items[i].catid!,
                          'indexvalue': i.toString(),
                          'prev': "footer_item"
                        });

                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        categoriesData.items[i].title!,
                        style:
                            TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
             // if(IConstants.restaurantTerms != "" || IConstants.returnsPolicy != "" || IConstants.refundPolicy != "" || IConstants.refundPolicy != "" || IConstants.walletPolicy != "" || PrefUtils.prefs!.getString("description") != "")
              Text(
                S .of(context).useful_link,
                style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
              ),
              SizedBox(
                height: 8,
              ),
              if(IConstants.restaurantTerms!= "")
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                    'title': S .of(context).term_and_condition,    //"Terms & Conditions",
                    /*'body': IConstants.restaurantTerms,*/});
                },
                child: Text(
                  S .of(context).term_and_condition,
                  style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if(IConstants.returnsPolicy!= "")
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                    'title': S .of(context).returns,  //"Return",
                    /*'body': IConstants.returnsPolicy,*/});
                },
                child: Text(
                  S .of(context).return_policy,
                  style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if(IConstants.refundPolicy!= "")
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                    'title': S .of(context).refund,   // "Refund",
                    /*'body': IConstants.refundPolicy,*/});
                },
                child: Text(
                  S .of(context).refund_policy,
                  style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if(IConstants.walletPolicy!= "")
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                    'title': S .of(context).wallet,   //"Wallet",
                    /*'body': IConstants.walletPolicy,*/});
                },
                child: Text(
                  S .of(context).wallet_policy,
                  style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              if(PrefUtils.prefs!.getString("description")!= "")
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                    'title':S .of(context).about_us,   // "About Us",
                   /* 'body': PrefUtils.prefs!.getString("description").toString(),*/});
                },
                child: Text(
                  S .of(context).about_us,
                  style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigation(context, name: Routename.Policy, navigatore: NavigatoreTyp.Push,parms: {
                    'title': S .of(context).contact_us,    //"Contact Us",
                   /* 'body': "PrefUtils.prefs!.getString(con",
                    'businessname':"" ,
                    'address': "",
                    'contactnum': "",
                    'pemail':"",
                    'semail': "",*/});
                },
                child: Text(
                  S .of(context).contact,
                  style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              if(Features.isBrands)Text(
                S .of(context).popular_brands,
                style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
              ),
              if(Features.isBrands)SizedBox(
                height: 16,
              ),
              if(Features.isBrands)Container(
                child:   StreamBuilder(
                  stream: bloc.brandfiledBloc,
                  builder: (context, AsyncSnapshot<List<BrandsFieldModel>> snapshot){
                    if(snapshot.hasData){
                      return SizedBox(
                        height: 60,
                        child: ListView.builder(
                          // physics: ScrollPhysics(parent: ClampingScrollPhysics()),
                          // itemScrollController: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                          (snapshot.data!.length>6)
                              ? 6
                              :
                          snapshot.data!.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              SizedBox(
                                width: 10.0,
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(BrandsScreen.routeName, arguments: {
                                      'brandId': snapshot.data![i].id,
                                      'indexvalue': i.toString(),
                                    });
                                  },
                                  child: Text(
                                    snapshot.data![i].categoryName !+ ", ",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                    style: TextStyle(
                                        fontSize: 16.0, color: ColorCodes.footertitle),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        ),

                      );}
                    if(snapshot.hasError){
                      return SizedBox.shrink();}
                    else return SizedBox.shrink();
                  },
                ),
              ),
              SizedBox(
                height: 16,
              ),
              if(IConstants.androidId != "" || IConstants.appleId != "")
                Text(
                  S .of(context).download_app,
                  style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                ),
              if(IConstants.androidId != "" || IConstants.appleId != "")
                SizedBox(
                  height: 8,
                ),
              if(IConstants.androidId != "")
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: new InkWell(
                      onTap: () => launch("https://play.google.com/store/apps/details?id=" + IConstants.androidId),
                      child: Image.asset(Images.playstoreImg,height: 50,width: 150,)),
                ),
              if(IConstants.androidId != "")
                SizedBox(
                  height: 4,
                ),
              if(IConstants.appleId != "")
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: new InkWell(
                    child: Image.asset(Images.appStroreImg,height: 50,width: 150,),
                    onTap: () => launch("https://apps.apple.com/us/app/grocbay/id" + IConstants.appleId),
                  ),
                ),
              if(IConstants.appleId != "")
                SizedBox(
                  height: 8,
                ),
              if(IConstants.facebookUrl != "" || IConstants.twitterUrl != "" || IConstants.youtubeUrl != "" || IConstants.instagramUrl != "")
                Text(
                  S .of(context).get_social_with_us,
                  style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
                ),
              if(IConstants.facebookUrl != "" || IConstants.twitterUrl != "" || IConstants.youtubeUrl != "" || IConstants.instagramUrl != "")
                SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  if(IConstants.facebookUrl != "")
                    MouseRegion(
                      child: new InkWell(
                        child: Image.asset(Images.fbImg,height: 30,
                          width: 30,),
                        onTap: () => launch(IConstants.facebookUrl),
                      ),
                    ),
                  if(IConstants.facebookUrl != "")
                    SizedBox(
                      width: 8.0,
                    ),
                  if(IConstants.twitterUrl != "")
                    MouseRegion(
                      child: new InkWell(
                        child: Image.asset(Images.twitterImg,height: 30,
                          width: 30,),
                        onTap: () => launch(IConstants.twitterUrl),
                      ),
                    ),
                  if(IConstants.twitterUrl != "")
                    SizedBox(
                      width: 8.0,
                    ),
                  if(IConstants.youtubeUrl != "")
                    MouseRegion(
                      child: new InkWell(
                        child: Image.asset(Images.youtubeImg, height: 30,
                          width: 30,),
                        onTap: () =>launch(IConstants.youtubeUrl),
                      ),
                    ),
                  if(IConstants.youtubeUrl != "")
                    SizedBox(
                      width: 8.0,
                    ),
                  if(IConstants.instagramUrl != "")
                    MouseRegion(
                      child: new InkWell(
                        child: Image.asset(Images.instaImg,height: 30,
                          width: 30,),
                        onTap: () =>launch(IConstants.instagramUrl),
                      ),
                    ),
                ],
              ),
              if(IConstants.facebookUrl != "" || IConstants.twitterUrl != "" || IConstants.youtubeUrl != "" || IConstants.instagramUrl != "")
                SizedBox(
                height: 16,
              ),
              Text(
                S .of(context).payment_method,
                style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
              ),
              SizedBox(
                height: 20.0,
              ),
              Image.asset(Images.paymentsImg),
              SizedBox(
                height: 20.0,
              ),
              Text(
                S .of(context).address,
                style: TextStyle(fontSize: 21.0, color: ColorCodes.footertext),
              ),
              Text(
                IConstants.APP_NAME,
                style: TextStyle(fontSize: 17.0, color: ColorCodes.footertitle),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                widget.address,
                style: TextStyle(fontSize: 16.0, color: ColorCodes.footertitle),
              ),
              SizedBox(
                height: 15,
              ),
              if(store.language.languages.length > 1)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  showDialog(context: context, builder: (BuildContext context) => LanguageselectDailog(context));
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.language, size: 22, color: ColorCodes.footertext),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      S .current.language,
                      style: TextStyle(fontSize: 20.0, color: ColorCodes.footertext),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Icon(Icons.arrow_drop_down, size: 22,),

                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 50.0,
        ),
        Container(
          height: 96.0,
          color: ColorCodes.lightGreyWebColor,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
            S .of(context).copyright + IConstants.APP_NAME + ".",
            style: TextStyle(fontSize: 16.0, color: ColorCodes.borderdarkColor),
          )),
        )
      ],
    );
  }
}
