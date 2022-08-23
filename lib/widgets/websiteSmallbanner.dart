import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import '../../models/newmodle/home_page_modle.dart';
import '../../utils/prefUtils.dart';
import 'package:velocity_x/velocity_x.dart';
import '../providers/carouselitems.dart';
import '../rought_genrator.dart';
import '../screens/items_screen.dart';
import '../providers/categoryitems.dart';
import '../screens/subcategory_screen.dart';
import 'package:provider/provider.dart';
import '../assets/images.dart';
import '../screens/banner_product_screen.dart';
import '../screens/not_brand_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsiteSmallbanner extends StatefulWidget {
  HomePageData homedata;
  WebsiteSmallbanner(this.homedata);


  @override
  _WebsiteSmallbannerState createState() => _WebsiteSmallbannerState();
}

class _WebsiteSmallbannerState extends State<WebsiteSmallbanner> with Navigations{
  var _carauselslider = false;

  @override
  Widget build(BuildContext context) {
    final bannerData = Provider.of<CarouselItemsList>(context, listen: false);

    if(widget.homedata.data!.mainslider!=null)
    if (widget.homedata.data!.mainslider!.length > 0) {
      _carauselslider = true;
    } else {
      _carauselslider = false;
    }

    return _carauselslider&& widget.homedata.data!.mainslider!=null ? GFCarousel(
      autoPlay: false,
      viewportFraction: 1.0,
      //
      // width: 540.0,
      height: 280.0,
      aspectRatio: 1,
      pagination: false,
      passiveIndicator: Colors.white,
      activeIndicator: Theme.of(context).accentColor,
      autoPlayInterval: Duration(seconds: 8),
//        initialPage: 0,
//        enableInfiniteScroll: true,
//        reverse: false,
//        autoPlay: true,
//        autoPlayInterval: Duration(seconds: 3),
//        autoPlayAnimationDuration: Duration(milliseconds: 800),
//        pauseAutoPlayOnTouch: Duration(seconds: 10),
//        enlargeCenterPage: true,
//        scrollDirection: Axis.horizontal,
      items: <Widget>[
        for (var i = 0; i < widget.homedata.data!.mainslider!.length; i++)
          Builder(
            builder: (BuildContext context) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {


                  },
                  child: Container(
                    height: 280,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: new ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.homedata.data!.mainslider!.length,
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: (){
                            if (widget.homedata.data!.mainslider![i].bannerFor == "1") {
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              /*Navigator.of(context).pushNamed(
                                  BannerProductScreen.routeName,
                                  arguments: {
                                    "id" : widget.homedata.data!.mainslider![i].data,
                                    'type': "product"
                                  }
                              );*/
                              Navigation(context, name:Routename.BannerProduct,navigatore: NavigatoreTyp.Push,
                              qparms: {
                                "id" : widget.homedata.data!.mainslider![i].data,
                                'type': "product"
                              });
                            } else if (widget.homedata.data!.mainslider![i].bannerFor == "2") {
                              //Category
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              debugPrint("asdf2"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
                              String cattitle = "";
                              for (int j = 0; j < categoriesData.items.length; j++) {
                                if (widget.homedata.data!.mainslider![i].data == categoriesData.items[j].catid) {
                                  cattitle = categoriesData.items[j].title!;
                                }
                              }
                              String subTitle = "";
                            /*  Navigator.of(context)
                                  .pushNamed(SubcategoryScreen.routeName, arguments: {
                                'catId': widget.homedata.data!.mainslider![i].data,
                                'catTitle': cattitle,
                              });*/
                            /*  Navigation(context, name:Routename.SubcategoryScreen,navigatore: NavigatoreTyp.Push,
                                  parms:{
                                    'catId': widget.homedata.data!.mainslider![i].data.toString(),
                                    'catTitle': cattitle,
                                  });*/
                              Navigation(context, name: Routename.ItemScreen, navigatore: NavigatoreTyp.Push,
                                  qparms: {
                                    'maincategory' : subTitle.toString(),
                                    'catId' : widget.homedata.data!.mainslider![i].data!,
                                    'catTitle': subTitle.toString(),
                                    'subcatId' : widget.homedata.data!.mainslider![i].data!,
                                    'indexvalue' : "0",
                                    'prev' : "carousel"
                                  });
                            } else if (widget.homedata.data!.mainslider![i].bannerFor == "3") {
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              debugPrint("asdf3"+widget.homedata.data!.mainslider![i].id.toString());
                              String maincategory = "";
                              String catid = "";
                              String subTitle = "";
                              String index = "";

                              /*Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                                'maincategory': maincategory,
                                'catId': catid,
                                'catTitle': subTitle,
                                'subcatId': widget.homedata.data!.mainslider![i].data,
                                'indexvalue': index,
                                'prev': "advertise"

                              });*/
                              Navigation(context, name: Routename.ItemScreen, navigatore: NavigatoreTyp.PushReplacment,
                                  parms: {
                                    'maincategory': maincategory,
                                    'catId': catid,
                                    'catTitle': subTitle,
                                    'subcatId': widget.homedata.data!.mainslider![i].data.toString(),
                                    'indexvalue': index,
                                    'prev': "advertise"
                                  });
                            } else if(widget.homedata.data!.mainslider![i].bannerFor == "5") {
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              debugPrint("asdf4"+widget.homedata.data!.mainslider![i].id.toString());
                              //brands
                              Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.notifybrand,qparms:
                              {
                                'brandsId' : widget.homedata.data!.mainslider![i].data.toString(),
                                'fromScreen' : "Banner",
                                'notificationId' : "",
                                'notificationStatus': ""
                              });
                             /* Navigator.of(context).pushNamed(NotBrandScreen.routeName,
                                  arguments: {
                                    'brandsId' : widget.homedata.data!.mainslider![i].data,
                                    'fromScreen' : "Banner",
                                    'notificationId' : "",
                                    'notificationStatus': ""
                                  }
                              );*/
                            } else if(widget.homedata.data!.mainslider![i].bannerFor == "4") {
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              debugPrint("asdf5"+widget.homedata.data!.mainslider![i].id.toString());
                              //Subcategory and nested category
                             /* Navigator.of(context).pushNamed(BannerProductScreen.routeName,
                                  arguments: {
                                    'id' : widget.homedata.data!.mainslider![i].data,
                                    'type': "category"
                                  }
                              );*/
                              Navigation(context, name:Routename.BannerProduct,navigatore: NavigatoreTyp.Push,
                                  qparms: {
                                    'id' : widget.homedata.data!.mainslider![i].data,
                                    'type': "category"
                                  });
                            } else if(widget.homedata.data!.mainslider![i].bannerFor == "6") {
                              debugPrint("asdf1"+widget.homedata.data!.mainslider![i].bannerFor.toString());
                              String url = widget.homedata.data!.mainslider![i].click_link!;
                              if (canLaunch(url) != null)
                                launch(url);
                              else
                                // can't launch url, there is some error
                                throw "Could not launch $url";
                            } else if(widget.homedata.data!.mainslider![i].bannerFor == "17"){
                              if(!Vx.isWeb) {
                                PrefUtils.prefs!.containsKey("apikey") ?
                                Navigation(context, name: Routename.SignUpScreen,
                                    navigatore: NavigatoreTyp.Push) :
                                Navigation(context, name: Routename.Refer,
                                    navigatore: NavigatoreTyp.Push);
                              }
                            }else if(widget.homedata.data!.mainslider![i].bannerFor == "18"){
                              PrefUtils.prefs!.containsKey("apikey") ?
                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push) :
                              Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            width: 540.0,
                            height: 280.0,
                            margin: EdgeInsets.only(right: 10.0),
                            child: CachedNetworkImage(
                              imageUrl: widget.homedata.data!.mainslider![i].bannerImage,
                              width: 50.0,
                              height: 50.0,
                              placeholder: (context, url) => Image.asset(Images.defaultSliderImg),
                              errorWidget: (context, url, error) => Image.asset(Images.defaultSliderImg),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
      ],
    ) : Container() ;
  }
}