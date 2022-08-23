import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../assets/images.dart';
import '../../components/login_web.dart';
import '../../helper/custome_checker.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/repeateToppings.dart';
import '../../models/sellingitemsfields.dart';
import '../../providers/myorderitems.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../utils/facebook_app_events.dart';
import '../../utils/prefUtils.dart';
import '../../widgets/productWidget/item_variation.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../models/newmodle/cartModle.dart';
import '../../constants/IConstants.dart';
import '../assets/ColorCodes.dart';
import '../constants/api.dart';
import '../constants/features.dart';
import '../controller/mutations/cart_mutation.dart';
import '../generated/l10n.dart';
import '../models/newmodle/product_data.dart';
import '../models/newmodle/search_data.dart';
import '../providers/branditems.dart';

import 'package:provider/provider.dart';

import '../rought_genrator.dart';
import 'package:http/http.dart' as http;

enum StepperAlignment{
  Vertical,Horizontal
}

class CustomeStepper extends StatefulWidget {
  PriceVariation? priceVariation;
  PriceVariationSearch? priceVariationSearch;
  String? from;
  ItemData? itemdata;
  StoreSearchData? searchstoredata;
  bool? checkmembership;
  bool subscription;
  StepperAlignment alignmnt;
  final double? fontSize;
  final double height;
  final double width;
  Addon? addon;
  int index;
  String? issubscription;
 int? groupvalue;
  Function(int,int)? onChange;

  CustomeStepper({Key? key,this.priceVariation,this.priceVariationSearch,this.itemdata,this.searchstoredata,this.from,this.checkmembership,this.subscription = false,this.alignmnt = StepperAlignment.Vertical,required this.height ,this.width = double.infinity,this.addon,required this.index,this.issubscription,this.groupvalue,this.onChange,this.fontSize =12 }) : super(key: key);

  @override
  State<CustomeStepper> createState() => _CustomeStepperState();
}

class _CustomeStepperState extends State<CustomeStepper> with Navigations {

  bool loading = false;
  bool Toppingloading = false;
  //var _checkmembership = false;
  bool _isNotify = false;
  List<CartItem> productBox=[];
  List<Widget> stepperButtons = [];
  final item =(VxState.store as GroceStore).CartItemList;
  int toppings = 0;
  String? toppingscheck;
  int _groupValue = -1;
  StateSetter? setstate;
  late Future<List<RepeatToppings>> _futureNonavailable = Future.value([]);

  late StateSetter topupState;
  int? varId = 0;
  int? parentId = 0;

  var itemadd = {};
  List toppingsitem = [];

  List product = [];

  List addToppingsProduct = [];
  String? parentidforupdate = "";
  List<String> deliveries = [];

  @override
  Widget build(BuildContext context) {
    print("stepper,......");
    productBox=  (VxState.store as GroceStore).CartItemList;
    deliveries.clear();
    if(widget.from == "search_screen" && Features.ismultivendor){
      if (widget.searchstoredata!.subscriptionSlot!.length > 0) {
        deliveries.addAll(
            (widget.searchstoredata!.subscriptionSlot![0].deliveries!.split(",")));
      }
    }else {
      if (widget.itemdata!.subscriptionSlot!.length > 0) {
        deliveries.addAll(
            (widget.itemdata!.subscriptionSlot![0].deliveries!.split(",")));
      }
    }
    //debugPrint("deliveries...."+deliveries.toString());
    product.clear();
    for( int i = 0;i < productBox.length ;i++){
      if(widget.from == "search_screen" && Features.ismultivendor) {
        if (productBox[i].itemId == widget.searchstoredata!.id &&
            productBox[i].toppings == "0") {
          product.add(productBox[i].quantity);
        }
      }
      else {
        if (productBox[i].itemId == widget.itemdata!.id &&
            productBox[i].toppings == "0") {
          product.add(productBox[i].quantity);
        }
      }

      /* if(box[i].itemId == widget.itemdata!.id && box[i].toppings =="0"){
                      debugPrint("true...1");
                      quantity = quantity +  int.parse(box
                          .where((element) =>
                      element.itemId == widget.itemdata!.id)
                          .first
                          .quantity!);
                      weight = weight + double.parse(box
                          .where((element) =>
                      element.itemId == widget.itemdata!.id)
                          .first
                          .weight!);
                    }*/
    }

    List maxQantity = [];
    List maxWeight = [];
    int quantityTotal = 0;
    double weightTotal = 0;
    debugPrint("weightTotal...");

    if(widget.from == "search_screen" && Features.ismultivendor){
      if(widget.searchstoredata!.type == "1"){
        debugPrint("Single sku....");
        for(int i =0; i< productBox.where((element) => element.itemId == widget.searchstoredata!.id).length ;i++){
          maxWeight.add(productBox[i].weight);
        }
        debugPrint("weightTotal...1"+maxWeight.toString());
        for(int j = 0; j < maxWeight.length; j++){
          weightTotal = weightTotal + double.parse(maxWeight[j]);
        }
        debugPrint("weightTotal...1"+weightTotal.toString());
      }
      else {
        debugPrint("multi sku....");
        for (int i = 0; i < productBox
            .where((element) => element.itemId == widget.searchstoredata!.id)
            .length; i++) {
          maxQantity.add(productBox[i].quantity);
        }
        debugPrint("maxQantity...1" + maxQantity.toString());
        for (int j = 0; j < maxQantity.length; j++) {
          quantityTotal = quantityTotal + int.parse(maxQantity[j]);
        }
        debugPrint("maxQantity...2" + quantityTotal.toString());
      }
    }
    else{
    if(widget.itemdata!.type == "1"){
      debugPrint("Single sku....");
      for(int i =0; i< productBox.where((element) => element.itemId == widget.itemdata!.id).length ;i++){
        maxWeight.add(productBox[i].weight);
      }
      debugPrint("weightTotal...1"+maxWeight.toString());
      for(int j = 0; j < maxWeight.length; j++){
        weightTotal = weightTotal + double.parse(maxWeight[j]);
      }
      debugPrint("weightTotal...1"+weightTotal.toString());
    }
    else {
      debugPrint("multi sku....");
      for (int i = 0; i < productBox
          .where((element) => element.itemId == widget.itemdata!.id)
          .length; i++) {
        maxQantity.add(productBox[i].quantity);
      }
      debugPrint("maxQantity...1" + maxQantity.toString());
      for (int j = 0; j < maxQantity.length; j++) {
        quantityTotal = quantityTotal + int.parse(maxQantity[j]);
      }
      debugPrint("maxQantity...2" + quantityTotal.toString());
    }
    }
    updateCart(int qty,double weight,CartStatus cart,String varid, String parent_id, String toppings, String toppings_id){
      print("parent odddd..." + parent_id.toString());
      //debugPrint("decrement"+qty.toString());
      switch(cart){
        case CartStatus.increment:
          print("varid....initial"+varid.toString());
          print("groupvalue....initial"+widget.groupvalue.toString());
        // print("qunty and stock"+qty.toString()+"...."+widget.priceVariation!.stock.toString()+",,,"+widget.priceVariation!.maxItem.toString());
        // if(qty <double.parse(widget.priceVariation!.stock.toString())) {
        //   if(qty <double.parse(widget.priceVariation!.maxItem.toString())) {
        //     cartcontroller.update((done) {
        //       print("done value in calling update " + done.toString());
        //       setState(() {
        //         loading = !done;
        //         print("value of loading in update cart increment case: " +
        //             loading.toString());
        //       });
        //     }, price: widget.priceVariation!.price.toString(),
        //         quantity: (qty + 1).toString(),
        //         var_id: varid);
        // }else {
        //     Fluttertoast.showToast(
        //         msg:
        //         S.of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
        //         fontSize: MediaQuery.of(context).textScaleFactor *13,
        //         backgroundColor: Colors.black87,
        //         textColor: Colors.white);
        //   }
        // }else{
        //   Fluttertoast.showToast(
        //       msg: S
        //           .of(context)
        //           .sorry_outofstock, //"Sorry, Out of Stock!",
        //       fontSize: MediaQuery
        //           .of(context)
        //           .textScaleFactor * 13,
        //       backgroundColor: Colors.black87,
        //       textColor: Colors.white);
        // }
        if(widget.from == "search_screen" && Features.ismultivendor){
          if(widget.searchstoredata!.type=="1"){
            print("qunty and stock"+qty.toString()+"...."+widget.searchstoredata!.stock.toString()+",,,"+widget.searchstoredata!.maxItem.toString());
            if((productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ?weightTotal:double.parse(weight.toString()))
                < double.parse(widget.searchstoredata!.stock.toString())) {
              if((productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ?weightTotal: double.parse(weight.toString()))
                  <(double.parse(widget.searchstoredata!.maxItem!)*double.parse(widget.searchstoredata!.increament!))) {
                cartcontroller.update((done) {
                  print("done value in calling update " + done.toString());
                  setState(() {
                    loading = !done;
                    print("value of loading in update cart increment case: " +
                        loading.toString());
                  });
                }, price: widget.searchstoredata!.price.toString(),
                    quantity: qty.toString(),
                    type: widget.searchstoredata!.type,
                    weight: (weight+double.parse(widget.searchstoredata!.increament!)).toString(),
                    var_id: varid,
                    increament: widget.searchstoredata!.increament,
                    cart_id: parent_id,
                    toppings: toppings,
                    topping_id: toppings_id

                );
              }
              else {
                debugPrint("cant_add_more_item......1");
                Fluttertoast.showToast(
                    msg:
                    S.of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
                    fontSize: MediaQuery.of(context).textScaleFactor *13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              }
            }else{
              debugPrint("sorry_outofstock.....1");
              Fluttertoast.showToast(
                  msg: S
                      .of(context)
                      .sorry_outofstock, //"Sorry, Out of Stock!",
                  fontSize: MediaQuery
                      .of(context)
                      .textScaleFactor * 13,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white);
            }
          }
          else {

            if (Features.btobModule) {
              if ((productBox
                  .where((element) => element.itemId == widget.searchstoredata!.id)
                  .length > 1 ? quantityTotal : qty) <
                  double.parse(
                      widget.priceVariationSearch!.maxItem!)) {
                print("max item reach... 1");
                print("max item reach... if");
                cartcontroller.update((done) {
                  print(
                      "done value in calling update " + done.toString());
                  setState(() {
                    loading = !done;
                    print(
                        "value of loading in update cart increment case: " +
                            loading.toString());
                    widget.onChange!(widget.groupvalue!,(productBox
                        .where((element) => element.itemId == widget.searchstoredata!.id)
                        .length > 1 ?(int.parse(productBox
                        .where((element) => element.itemId == widget.searchstoredata!.id).first.quantity!)):(int.parse(productBox
                        .where((element) => element.itemId == widget.searchstoredata!.id).first.quantity!))));

                  });
                }, price: widget.priceVariationSearch!.price.toString(),
                    quantity: (qty + 1).toString(),
                    type: widget.searchstoredata!.type,
                    weight: "1",
                    var_id: varid,
                    increament: widget.searchstoredata!.increament,
                    cart_id: parent_id,
                    toppings: toppings,
                    topping_id: toppings_id
                );
              }
              else {
                print("max item reach... 2");
                print("max item reach... else");
                if (productBox
                    .where((element) => element.itemId == widget.searchstoredata!.id)
                    .length > 1) {
                  print("max item reach... else...if");
                }
                else {
                  print("max item reach... 3");
                  print("max item reach... else...else");
                  var varIdold = varid;
                  var varminitemold = widget.priceVariationSearch!.minItem;
                  var varpriceold = widget.priceVariationSearch!.price;
                  print("max item reach... else...else2 qty...."+qty.toString()+"variation...max item.."+widget.priceVariationSearch!.maxItem.toString()+"var min "+widget.priceVariationSearch!.minItem.toString());
                  if (int.parse(
                      widget.priceVariationSearch!.minItem!) < qty &&
                      int.parse(
                          widget.priceVariationSearch!.maxItem!) >
                          qty){
                    print("max item reach... 4");
                    print("max item reach... else...else1");
                    print("groupvalue....3" + widget.groupvalue.toString() +
                        "....");

                    print("varid...." + varid + "..." + varIdold.toString());
                    print("var min item...." +
                        widget.priceVariationSearch!.minItem.toString() + "..." +
                        varminitemold.toString());
                    print("var max item...." +
                        widget.priceVariationSearch!.price.toString() + "..." +
                        varpriceold.toString());
                    // i++;
                    /* print(
                          "if......i value/...ater increment" +
                              i.toString());
                      widget.groupvalue = i++;*/

                    print(
                        "clicked grp value....before....exceed" +
                            varid.toString()+"group value..."+widget.groupvalue.toString()+"qty.."+qty.toString()+"max item////"+widget.priceVariationSearch!.maxItem.toString());
                    varid = widget.priceVariationSearch!.id!;
                    if ((productBox
                        .where((element) =>
                    element.itemId == widget.searchstoredata!.id)
                        .length > 1 ? quantityTotal : qty) <
                        double.parse(
                            widget.priceVariationSearch!.maxItem!)){
                      print("max item reach... 5");
                      print("max item reach... else...else1 if");
                    }
                    else{
                      print("max item reach... 6");
                      print("max item reach... else...else1 else");
                      print("groupvalue....2" + widget.groupvalue.toString() +
                          "...." );
                      var varIdold = varid;
                      var varminitemold = widget.priceVariationSearch!.minItem;
                      var varpriceold = widget.priceVariationSearch!.price;
                      /* print(
                            "if......i value/...ater increment" +
                                i.toString());
                        widget.groupvalue = i++;*/
                      cartcontroller.update((done) {
                        print("done value in calling update 1" + done
                            .toString()+"widget grouvalue..."+widget.groupvalue.toString());
                        setState(() {
                          /*qty = int.parse(
                                widget.priceVariationSearch!.minItem!);*/
                          loading = !done;
                          /*cartcontroller.addtoCart(itemdata: widget.itemdata!,
                                onload: (isloading) {
                                  setState(() {
                                    debugPrint("add to cart......1");
                                    loading = isloading;
                                    //onload(true);
                                    //onload(isloading);
                                    print("value of loading in add cart fn " +
                                        loading.toString());
                                  });
                                },
                                topping_type: "",
                                varid: varid,
                                toppings: "",
                                newproduct: "",
                                parent_id: parent_id,
                                toppingsList: addToppingsProduct,
                                itembody: widget.priceVariation!,
                                context: context);
                            print(
                                "value of loading in update cart increment case: " +
                                    loading.toString());*/


                        });
                      }, price: widget.priceVariationSearch!.price.toString(),//varpriceold.toString(),
                          quantity: (qty + 1).toString(),
                          type: widget.searchstoredata!.type,
                          weight: "1",
                          var_id: varid,//varIdold,
                          increament: widget.searchstoredata!.increament,
                          cart_id: parent_id,
                          toppings: toppings,
                          topping_id: toppings_id
                      );

                    }

                  }
                  else {
                    print("max item reach... 7");
                    print("max item reach... else...else2");

                    var varIdold = varid;
                    print("max item reach... else...else2 variation..." +
                        varIdold.toString() + "qty.." + qty.toString() +
                        "variation id..." +
                        widget.priceVariationSearch!.id.toString());
                    var varminitemold = widget.priceVariationSearch!.minItem;
                    var varpriceold = widget.priceVariationSearch!.price;

                    for (int i = widget.groupvalue!; i <
                        widget.searchstoredata!.priceVariation!.length; i++) {
                      print("max item reach... else...else2 group value11" +
                          "i value....." + i.toString() + "..." +
                          widget.groupvalue.toString() + "id..." +
                          widget.searchstoredata!.priceVariation![i].id.toString());
                      if (int.parse(productBox
                          .where((element) =>
                      element.varId == widget.priceVariation!.id)
                          .last
                          .varId
                          .toString()) ==
                          widget.searchstoredata!.priceVariation![i].id) {
                        print("max item reach... 10");
                        print("equal variation");
                        print("max item reach... else...else2 group value11" +
                            widget.groupvalue.toString() + "id..." + widget
                            .searchstoredata!.priceVariation![i].id.toString());
                        widget.groupvalue = widget.groupvalue! + 1;
                        print("max item reach... else...else2 group value1" +
                            widget.groupvalue.toString());
                      }
                      else {
                        if (int.parse(
                            widget.searchstoredata!.priceVariation![i].maxItem
                                .toString()) > qty) {
                          print("max item reach... 8 multi...");
                          print("groupvalue....2 8" + widget.groupvalue
                              .toString() +
                              "...."+widget.searchstoredata!.priceVariation![i].id!.toString()+"id..."+ widget.priceVariation!.id.toString());
                          print("max item reach... else...else2 if....");
                          cartcontroller.update((done) {
                            print("done value in calling update 1" + done
                                .toString() + "widget grouvalue..." +
                                widget.groupvalue.toString());
                            setState(() {
                              /*qty = int.parse(
                                widget.priceVariation!.minItem!);*/
                              loading = !done;
                              widget.onChange!(widget.groupvalue!,qty + 1);
                            });
                          }, price: widget.priceVariationSearch!.price.toString(),//varpriceold.toString(),
                              quantity: (qty + 1).toString(),
                              type: widget.searchstoredata!.type,
                              weight: "1",
                              var_id: widget.searchstoredata!.priceVariation![i].id!,//varIdold,
                              increament: widget.searchstoredata!.increament,
                              cart_id: parent_id,
                              toppings: toppings,
                              topping_id: toppings_id
                          );
                        }
                        else {
                          print("max item reach... 9");
                          print("max item reach... else...else2 else...."+widget.searchstoredata!.priceVariation!.length.toString()+"else else..."+widget.searchstoredata!.priceVariation![widget.searchstoredata!.priceVariation!.length -1].maxItem
                              .toString()+"qty.."+qty.toString());

                          debugPrint("cant_add_more_item......4");
                          if(int.parse(
                              widget.searchstoredata!.priceVariation![widget.searchstoredata!.priceVariation!.length -1].maxItem
                                  .toString()) <= qty) {
                            debugPrint("cant_add_more_item......if");
                            Fluttertoast.showToast(
                                msg:
                                S
                                    .of(context)
                                    .cant_add_more_item,
                                //"Sorry, you can\'t add more of this item!",
                                fontSize: MediaQuery
                                    .of(context)
                                    .textScaleFactor * 13,
                                backgroundColor: Colors.black87,
                                textColor: Colors.white);
                          }
                        }
                      }

                      widget.groupvalue = widget.groupvalue! + 1;
                      print("group value ..at end ....." +
                          widget.groupvalue.toString());
                      break;

                    }

                  }
                }
              }
            }
            else {
              List<SellingItemsFields> list = [];
              item.forEach((element) {
                debugPrint(
                    "ggggg....22..." + element.itemId.toString() + "..." +
                        widget.searchstoredata!.id.toString() + ".." +
                        element.quantity!);
                if (element.itemId == widget.searchstoredata!.id) {
                  //fetchItemData = Provider.of<ItemsList>(context, listen: false).fetchItems();
                  for (int i = 0; i <
                      widget.searchstoredata!.priceVariation!.length; i++) {
                    if (widget.searchstoredata!.priceVariation![i].id ==
                        element.varId) {
                      list.add(SellingItemsFields(weight: double.parse(
                          widget.searchstoredata!.priceVariation![i].weight!),
                          varQty: int.parse(element.quantity.toString())));
                    }
                  }
                }
              });
              print("increment to : ${widget.priceVariationSearch!
                  .minItem}....${widget
                  .priceVariationSearch!.maxItem}");
              print("increment to : ${widget.priceVariationSearch!
                  .quantity}....${widget
                  .priceVariationSearch!.stock}");
              if (Features.btobModule ? Check().isOutofStock(
                  maxstock: double.parse(
                      widget.priceVariationSearch!.stock.toString()),
                  stocktype: widget.searchstoredata!.type!,
                  qty: (productBox
                      .where((element) =>
                  element.itemId == widget.searchstoredata!.id)
                      .length > 1) ? quantityTotal.toString() : qty.toString(),
                  itemData: [],
                  searchvariation: widget.priceVariationSearch!,
                  screen: "search_screen")
                  : Check().isOutofStock(
                maxstock: double.parse(
                    widget.priceVariationSearch!.stock.toString()),
                stocktype: widget.searchstoredata!.type!,
                qty: (productBox
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id)
                    .length > 1) ? quantityTotal.toString() : qty.toString(),
                itemData: list,
                searchvariation: widget.priceVariationSearch!,)) {
                debugPrint("sorry_outofstock.....2");
                Fluttertoast.showToast(
                    msg: S
                        .of(context)
                        .sorry_outofstock,
                    //"Sorry, Out of Stock!",
                    fontSize: MediaQuery
                        .of(context)
                        .textScaleFactor * 13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              } else {
                if ((productBox
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id)
                    .length > 1 ? quantityTotal : qty) <
                    double.parse(widget.priceVariationSearch!.maxItem!)) {
                  cartcontroller.update((done) {
                    print("done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print("value of loading in update cart increment case: " +
                          loading.toString());
                    });
                  }, price: widget.priceVariationSearch!.price.toString(),
                      quantity: (qty + 1).toString(),
                      type: widget.searchstoredata!.type,
                      weight: "1",
                      var_id: varid,
                      increament: widget.searchstoredata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id
                  );
                } else {
                  debugPrint("cant_add_more_item......2");
                  Fluttertoast.showToast(
                      msg:
                      S
                          .of(context)
                          .cant_add_more_item,
                      //"Sorry, you can\'t add more of this item!",
                      fontSize: MediaQuery
                          .of(context)
                          .textScaleFactor * 13,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                }
              }
            }
          }
        }
        else {
          if (widget.itemdata!.type == "1") {
           debugPrint("wight stock..."+weight.toString()+"..."+widget.itemdata!.stock.toString());
            if ((productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1 ?weightTotal: double.parse(weight.toString())) <
                double.parse(widget.itemdata!.stock.toString())) {
              if (double.parse(weight.toString()) <
                  (double.parse(widget.itemdata!.maxItem!) *
                      double.parse(widget.itemdata!.increament!))) {
                cartcontroller.update((done) {
                  print("done value in calling update " + done.toString());
                  setState(() {
                    loading = !done;
                    print("value of loading in update cart increment case: " +
                        loading.toString());
                  });
                }, price: widget.itemdata!.price.toString(),
                    quantity: qty.toString(),
                    type: widget.itemdata!.type,
                    weight: (weight +
                        double.parse(widget.itemdata!.increament!)).toString(),
                    var_id: varid,
                    increament: widget.itemdata!.increament,
                    cart_id: parent_id,
                    toppings: toppings,
                    topping_id: toppings_id,
                    item_id: widget.itemdata!.id.toString()

                );
              } else {
                debugPrint("cant_add_more_item......3");
                Fluttertoast.showToast(
                    msg:
                    S
                        .of(context)
                        .cant_add_more_item,
                    //"Sorry, you can\'t add more of this item!",
                    fontSize: MediaQuery
                        .of(context)
                        .textScaleFactor * 13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              }
            } else {
              debugPrint("sorry_outofstock.....3");
              Fluttertoast.showToast(
                  msg: S
                      .of(context)
                      .sorry_outofstock, //"Sorry, Out of Stock!",
                  fontSize: MediaQuery
                      .of(context)
                      .textScaleFactor * 13,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white);
            }
          }
          else {
            List<SellingItemsFields> list = [];
            item.forEach((element) {
              debugPrint("ggggg....22..." + element.itemId.toString() + "..." +
                  widget.itemdata!.id.toString() + ".." + element.quantity!);
              if (element.itemId == widget.itemdata!.id) {
                //fetchItemData = Provider.of<ItemsList>(context, listen: false).fetchItems();
                for (int i = 0; i < widget.itemdata!.priceVariation!.length; i++) {
                  if (widget.itemdata!.priceVariation![i].id == element.varId) {
                    list.add(SellingItemsFields(weight: double.parse(
                        widget.itemdata!.priceVariation![i].weight!),
                        varQty: int.parse(element.quantity.toString())));
                  }
                }
              }
            });
            print("increment to : ${widget.priceVariation!.minItem}....${widget
                .priceVariation!.maxItem}");
            print("increment to : ${widget.priceVariation!.quantity}....${widget
                .priceVariation!.stock}");
            if (Features.btobModule ? Check().isOutofStock(
                maxstock: double.parse(widget.priceVariation!.stock.toString()),
               stocktype:  widget.itemdata!.type!,
                qty: (productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1)?quantityTotal.toString() :qty.toString(),
                itemData: [],
                variation: widget.priceVariation!)
                : Check().isOutofStock(
              maxstock: double.parse(widget.priceVariation!.stock.toString()),
              stocktype: widget.itemdata!.type!,
                qty: (productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1)?quantityTotal.toString() :qty.toString(),
              itemData: list, variation: widget.priceVariation!,
            )) {
              debugPrint("sorry_outofstock.....4");
              Fluttertoast.showToast(
                  msg: S
                      .of(context)
                      .sorry_outofstock,
                  //"Sorry, Out of Stock!",
                  fontSize: MediaQuery
                      .of(context)
                      .textScaleFactor * 13,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white);
            } else {
              debugPrint("qty...."+quantityTotal.toString());
              debugPrint("qty...." + quantityTotal.toString());
              List addToppingsProduct = [];
              if (Features.btobModule) {
                if ((productBox
                    .where((element) => element.itemId == widget.itemdata!.id)
                    .length > 1 ? quantityTotal : qty) <
                    double.parse(
                        widget.priceVariation!.maxItem!)) {
                  print("max item reach... 1");
                  print("max item reach... if");
                  cartcontroller.update((done) {
                    print(
                        "done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print(
                          "value of loading in update cart increment case: " +
                              loading.toString());
                      widget.onChange!(widget.groupvalue!,(productBox
                          .where((element) => element.itemId == widget.itemdata!.id)
                      .length > 1 ?(int.parse(productBox
                          .where((element) => element.itemId == widget.itemdata!.id).first.quantity!)):(int.parse(productBox
                          .where((element) => element.itemId == widget.itemdata!.id).first.quantity!))));

                    });
                  }, price: widget.priceVariation!.price.toString(),
                      quantity: (qty + 1).toString(),
                      type: widget.itemdata!.type,
                      weight: "1",
                      var_id: varid,
                      increament: widget.itemdata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id,
                    item_id: widget.itemdata!.id.toString()
                  );
                }
                else {
                  print("max item reach... 2");
                  print("max item reach... else");
                  if (productBox
                      .where((element) => element.itemId == widget.itemdata!.id)
                      .length > 1) {
                    print("max item reach... else...if");
                  }
                  else {
                    print("max item reach... 3");
                    print("max item reach... else...else");
                    var varIdold = varid;
                    var varminitemold = widget.priceVariation!.minItem;
                    var varpriceold = widget.priceVariation!.price;
                    print("max item reach... else...else2 qty...."+qty.toString()+"variation...max item.."+widget.priceVariation!.maxItem.toString()+"var min "+widget.priceVariation!.minItem.toString());
                    if (int.parse(
                        widget.priceVariation!.minItem!) < qty &&
                        int.parse(
                            widget.priceVariation!.maxItem!) >
                            qty){
                      print("max item reach... 4");
                      print("max item reach... else...else1");
                      print("groupvalue....3" + widget.groupvalue.toString() +
                          "....");

                      print("varid...." + varid + "..." + varIdold.toString());
                      print("var min item...." +
                          widget.priceVariation!.minItem.toString() + "..." +
                          varminitemold.toString());
                      print("var max item...." +
                          widget.priceVariation!.price.toString() + "..." +
                          varpriceold.toString());
                      // i++;
                      /* print(
                          "if......i value/...ater increment" +
                              i.toString());
                      widget.groupvalue = i++;*/

                      print(
                          "clicked grp value....before....exceed" +
                              varid.toString()+"group value..."+widget.groupvalue.toString()+"qty.."+qty.toString()+"max item////"+widget.priceVariation!.maxItem.toString());
                      varid = widget.priceVariation!.id!;
                      if ((productBox
                          .where((element) =>
                      element.itemId == widget.itemdata!.id)
                          .length > 1 ? quantityTotal : qty) <
                          double.parse(
                              widget.priceVariation!.maxItem!)){
                        print("max item reach... 5");
                        print("max item reach... else...else1 if");
                      }
                      else{
                        print("max item reach... 6");
                        print("max item reach... else...else1 else");
                        print("groupvalue....2" + widget.groupvalue.toString() +
                            "...." );
                        var varIdold = varid;
                        var varminitemold = widget.priceVariation!.minItem;
                        var varpriceold = widget.priceVariation!.price;
                        /* print(
                            "if......i value/...ater increment" +
                                i.toString());
                        widget.groupvalue = i++;*/
                        cartcontroller.update((done) {
                          print("done value in calling update 1" + done
                              .toString()+"widget grouvalue..."+widget.groupvalue.toString());
                          setState(() {
                            /*qty = int.parse(
                                widget.priceVariation!.minItem!);*/
                            loading = !done;
                            /*cartcontroller.addtoCart(itemdata: widget.itemdata!,
                                onload: (isloading) {
                                  setState(() {
                                    debugPrint("add to cart......1");
                                    loading = isloading;
                                    //onload(true);
                                    //onload(isloading);
                                    print("value of loading in add cart fn " +
                                        loading.toString());
                                  });
                                },
                                topping_type: "",
                                varid: varid,
                                toppings: "",
                                newproduct: "",
                                parent_id: parent_id,
                                toppingsList: addToppingsProduct,
                                itembody: widget.priceVariation!,
                                context: context);
                            print(
                                "value of loading in update cart increment case: " +
                                    loading.toString());*/


                          });
                        }, price: widget.priceVariation!.price.toString(),//varpriceold.toString(),
                            quantity: (qty + 1).toString(),
                            type: widget.itemdata!.type,
                            weight: "1",
                            var_id: varid,//varIdold,
                            increament: widget.itemdata!.increament,
                            cart_id: parent_id,
                            toppings: toppings,
                            topping_id: toppings_id,
                            item_id: widget.itemdata!.id.toString()
                        );

                      }

                    }
                    else {
                      print("max item reach... 7");
                      print("max item reach... else...else2");

                      var varIdold = varid;
                      print("max item reach... else...else2 variation..." +
                          varIdold.toString() + "qty.." + qty.toString() +
                          "variation id..." +
                          widget.priceVariation!.id.toString()+"price length.."+widget.itemdata!.priceVariation!.length.toString());
                      var varminitemold = widget.priceVariation!.minItem;
                      var varpriceold = widget.priceVariation!.price;
                      print("max item reach... else...else2 variation...before...");
                      for (int i = widget.groupvalue!; i <
                          widget.itemdata!.priceVariation!.length; i++) {
                        print("max item reach... else...else2 variation...before...");
                        print("max item reach... else...else2 group value11" +
                            "i value....." + i.toString() + "..." +
                            widget.groupvalue.toString() + "id..." +
                            widget.itemdata!.priceVariation![i].id.toString());
                        if (int.parse(productBox
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .last
                            .varId
                            .toString()) ==
                            widget.itemdata!.priceVariation![i].id) {
                          print("max item reach... 10");
                          print("equal variation");
                          print("max item reach... else...else2 group value11" +
                              widget.groupvalue.toString() + "id..." + widget
                              .itemdata!.priceVariation![i].id.toString());
                          widget.groupvalue = widget.groupvalue! + 1;
                          print("max item reach... else...else2 group value1" +
                              widget.groupvalue.toString());
                        }
                        else {
                          if (int.parse(
                              widget.itemdata!.priceVariation![i].maxItem
                                  .toString()) > qty) {
                            print("max item reach... 8 not multi....");
                            print("groupvalue....2" + widget.groupvalue
                                .toString() +
                                "....");
                            print("max item reach... else...else2 if...." + widget.itemdata!.priceVariation![i].id! + "..varid.."
                            + varid + "..varidold.." + varIdold);
                            cartcontroller.update((done) {
                              print("done value in calling update 1" + done
                                  .toString() + "widget grouvalue..." +
                                  widget.groupvalue.toString());
                              setState(() {
                                /*qty = int.parse(
                                widget.priceVariation!.minItem!);*/
                                loading = !done;
                                widget.onChange!(widget.groupvalue!,qty + 1);
                              });
                            }, price: widget.itemdata!.priceVariation![i].price!,//varpriceold.toString(),
                                quantity: (qty + 1).toString(),
                                type: widget.itemdata!.type,
                                weight: "1",
                                var_id: /*widget.itemdata!.priceVariation![i].id!,*/varid,//varIdold,
                                increament: widget.itemdata!.increament,
                                cart_id: parent_id,
                                toppings: toppings,
                                topping_id: toppings_id,
                                item_id: widget.itemdata!.id.toString()
                            );
                          }
                          else {
                            print("max item reach... 9");
                            print("max item reach... else...else2 else...."+widget.itemdata!.priceVariation!.length.toString()+"else else..."+widget.itemdata!.priceVariation![widget.itemdata!.priceVariation!.length -1].maxItem
                                .toString()+"qty.."+qty.toString());

                            debugPrint("cant_add_more_item......4");
                            if(int.parse(
                                widget.itemdata!.priceVariation![widget.itemdata!.priceVariation!.length -1].maxItem
                                    .toString()) <= qty) {
                              debugPrint("cant_add_more_item......if");
                              Fluttertoast.showToast(
                                  msg:
                                  S
                                      .of(context)
                                      .cant_add_more_item,
                                  //"Sorry, you can\'t add more of this item!",
                                  fontSize: MediaQuery
                                      .of(context)
                                      .textScaleFactor * 13,
                                  backgroundColor: Colors.black87,
                                  textColor: Colors.white);
                            }
                          }
                        }

                        widget.groupvalue = widget.groupvalue! + 1;
                        print("group value ..at end ....." +
                            widget.groupvalue.toString());
                        break;

                      }

                    }
                  }
                }
              }
              else {
                if ((productBox
                    .where((element) => element.itemId == widget.itemdata!.id)
                    .length > 1 ? quantityTotal : qty) <
                    double.parse(widget.priceVariation!.maxItem!)) {
                  cartcontroller.update((done) {
                    print("done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print("value of loading in update cart increment case: " +
                          loading.toString());
                    });
                  }, price: widget.priceVariation!.price.toString(),
                      quantity: (qty + 1).toString(),
                      type: widget.itemdata!.type,
                      weight: "1",
                      var_id: varid,
                      increament: widget.itemdata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id,
                      item_id: widget.itemdata!.id.toString()
                  );
                }
                else {
                  debugPrint("cant_add_more_item......4");
                  Fluttertoast.showToast(
                      msg:
                      S
                          .of(context)
                          .cant_add_more_item,
                      //"Sorry, you can\'t add more of this item!",
                      fontSize: MediaQuery
                          .of(context)
                          .textScaleFactor * 13,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                }
              }
            }
          }
        }
          // TODO: Handle this case.
          break;
        case CartStatus.remove:
          cartcontroller.update((done){
            setState(() {
              loading = !done;
              print("value of loading in remove cart remove case: "+loading.toString());
            });
          },
              price: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type=="1"?widget.searchstoredata!.price.toString():widget.searchstoredata!.price.toString():
          widget.itemdata!.type=="1"?widget.itemdata!.price.toString():widget.priceVariationSearch!.price.toString(),
              quantity:"0",weight:"0",var_id: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type=="1"?widget.searchstoredata!.id!:varid:widget.itemdata!.type=="1"?widget.itemdata!.id!:varid,
              type: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type:widget.itemdata!.type,
              increament:widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.increament: widget.itemdata!.increament,cart_id: parent_id,toppings: toppings,
              topping_id: toppings_id,
              item_id: widget.itemdata!.id.toString()
          );
          // TODO: Handle this case.
          break;
        case CartStatus.decrement:
          print("addddddd,,,,,"+weight.toString()+"...."+(double.parse(widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.minItem!:widget.itemdata!.minItem!)*double.parse(widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.increament!:widget.itemdata!.increament!)).toString());
          if (Features.btobModule) {
            if ((productBox
                .where((element) => element.itemId == widget.itemdata!.id)
                .length > 1 ? quantityTotal : qty) <
                double.parse(
                    widget.priceVariation!.maxItem!)) {
              print("max item reach... 1 dec");
              print("max item reach... if dec");
              cartcontroller.update((done) {
                setState(() {
                  loading = !done;
                  print("value of loading in decrement cart decrement case: " +
                      loading.toString());
                  widget.onChange!(widget.groupvalue!,qty - 1);
                });
              },
                  price: widget.from == "search_screen" && Features.ismultivendor
                  ? widget.searchstoredata!.type == "1" ? widget.searchstoredata!
                  .price.toString() : widget.priceVariationSearch!.price
                  .toString()
                  : widget.itemdata!.type == "1" ? widget.itemdata!.price
                  .toString() : widget.priceVariation!.price.toString(),
                  quantity: widget.from == "search_screen" &&
                      Features.ismultivendor ?
                  widget.searchstoredata!.type == "1" ? ((weight) <=
                      (double.parse(widget.searchstoredata!.minItem!) *
                          double.parse(widget.searchstoredata!.increament!)))
                      ? "0"
                      : (qty).toString() : ((qty) <=
                      int.parse(widget.priceVariationSearch!.minItem!))
                      ? "0"
                      : (qty - 1).toString() :
                  widget.itemdata!.type == "1" ? ((weight) <=
                      (double.parse(widget.itemdata!.minItem!) *
                          double.parse(widget.itemdata!.increament!)))
                      ? "0"
                      : (qty).toString() : ((qty) <=
                      int.parse(widget.priceVariation!.minItem!)) ? "0" : (qty -
                      1).toString(),
                  weight: widget.from == "search_screen" && Features.ismultivendor
                      ?
                  widget.searchstoredata!.type == "1" ? ((weight) <=
                      (double.parse(widget.searchstoredata!.minItem!) *
                          double.parse(widget.searchstoredata!.increament!)))
                      ? "0"
                      : (weight -
                      double.parse(widget.searchstoredata!.increament!))
                      .toString() : "0"
                      : widget.itemdata!.type == "1" ? ((weight) <=
                      (double.parse(widget.itemdata!.minItem!) *
                          double.parse(widget.itemdata!.increament!)))
                      ? "0"
                      : (weight - double.parse(widget.itemdata!.increament!))
                      .toString() : "0",
                  var_id: widget.from == "search_screen" && Features.ismultivendor
                      ? widget.searchstoredata!.type == "1" ? widget
                      .searchstoredata!.id! : varid
                      : widget.itemdata!.type == "1"
                      ? widget.itemdata!.id!
                      : varid,
                  type: widget.from == "search_screen" && Features.ismultivendor
                      ? widget.searchstoredata!.type
                      : widget.itemdata!.type,
                  increament: widget.from == "search_screen" &&
                      Features.ismultivendor
                      ? widget.searchstoredata!.increament
                      : widget.itemdata!.increament,
                  cart_id: parent_id,
                  toppings: toppings,
                  topping_id: toppings_id,
                  item_id: widget.itemdata!.id.toString()
              );
            }
            else {
              print("max item reach... 2 dec");
              print("max item reach... else");
              if (productBox
                  .where((element) => element.itemId == widget.itemdata!.id)
                  .length > 1) {
                print("max item reach... else...if dec");
              }
              else {
                print("max item reach... 3");
                print("max item reach... else...else dec");
                var varIdold = varid;
                var varminitemold = widget.priceVariation!.minItem;
                var varpriceold = widget.priceVariation!.price;
                print("max item reach... else...else2 qty....dec"+qty.toString()+"variation...max item.."+widget.priceVariation!.maxItem.toString()+"var min "+widget.priceVariation!.minItem.toString());
                /*if (int.parse(
                    widget.priceVariation!.minItem!) < qty &&
                    int.parse(
                        widget.priceVariation!.maxItem!) >
                        qty){
                  print("max item reach... 4");
                  print("max item reach... else...else1");
                  print("groupvalue....3" + widget.groupvalue.toString() +
                      "....");

                  print("varid...." + varid + "..." + varIdold.toString());
                  print("var min item...." +
                      widget.priceVariation!.minItem.toString() + "..." +
                      varminitemold.toString());
                  print("var max item...." +
                      widget.priceVariation!.price.toString() + "..." +
                      varpriceold.toString());
                  // i++;
                  *//* print(
                          "if......i value/...ater increment" +
                              i.toString());
                      widget.groupvalue = i++;*//*

                  print(
                      "clicked grp value....before....exceed" +
                          varid.toString()+"group value..."+widget.groupvalue.toString()+"qty.."+qty.toString()+"max item////"+widget.priceVariation!.maxItem.toString());
                  varid = widget.priceVariation!.id!;
                  if ((productBox
                      .where((element) =>
                  element.itemId == widget.itemdata!.id)
                      .length > 1 ? quantityTotal : qty) <
                      double.parse(
                          widget.priceVariation!.minItem!)){
                    print("max item reach... 5");
                    print("max item reach... else...else1 if");
                  }
                  else{
                    print("max item reach... 6");
                    print("max item reach... else...else1 else");
                    print("groupvalue....2" + widget.groupvalue.toString() +
                        "...." );
                    var varIdold = varid;
                    var varminitemold = widget.priceVariation!.minItem;
                    var varpriceold = widget.priceVariation!.price;
                    *//* print(
                            "if......i value/...ater increment" +
                                i.toString());
                        widget.groupvalue = i++;*//*
                    cartcontroller.update((done) {
                      setState(() {
                        loading = !done;
                        print("value of loading in decrement cart decrement case: " +
                            loading.toString());
                      });
                    }, price: widget.from == "search_screen" && Features.ismultivendor
                        ? widget.searchstoredata!.type == "1" ? widget.searchstoredata!
                        .price.toString() : widget.priceVariationSearch!.price
                        .toString()
                        : widget.itemdata!.type == "1" ? widget.itemdata!.price
                        .toString() : widget.priceVariation!.price.toString(),
                        quantity: widget.from == "search_screen" &&
                            Features.ismultivendor ?
                        widget.searchstoredata!.type == "1" ? ((weight) <=
                            (double.parse(widget.searchstoredata!.minItem!) *
                                double.parse(widget.searchstoredata!.increament!)))
                            ? "0"
                            : (qty).toString() : ((qty) <=
                            int.parse(widget.priceVariationSearch!.minItem!))
                            ? "0"
                            : (qty - 1).toString() :
                        widget.itemdata!.type == "1" ? ((weight) <=
                            (double.parse(widget.itemdata!.minItem!) *
                                double.parse(widget.itemdata!.increament!)))
                            ? "0"
                            : (qty).toString() : ((qty) <=
                            int.parse(widget.priceVariation!.minItem!)) ? "0" : (qty -
                            1).toString(),
                        weight: widget.from == "search_screen" && Features.ismultivendor
                            ?
                        widget.searchstoredata!.type == "1" ? ((weight) <=
                            (double.parse(widget.searchstoredata!.minItem!) *
                                double.parse(widget.searchstoredata!.increament!)))
                            ? "0"
                            : (weight -
                            double.parse(widget.searchstoredata!.increament!))
                            .toString() : "0"
                            : widget.itemdata!.type == "1" ? ((weight) <=
                            (double.parse(widget.itemdata!.minItem!) *
                                double.parse(widget.itemdata!.increament!)))
                            ? "0"
                            : (weight - double.parse(widget.itemdata!.increament!))
                            .toString() : "0",
                        var_id: widget.from == "search_screen" && Features.ismultivendor
                            ? widget.searchstoredata!.type == "1" ? widget
                            .searchstoredata!.id! : varid
                            : widget.itemdata!.type == "1"
                            ? widget.itemdata!.id!
                            : varIdold*//*varid*//*,
                        type: widget.from == "search_screen" && Features.ismultivendor
                            ? widget.searchstoredata!.type
                            : widget.itemdata!.type,
                        increament: widget.from == "search_screen" &&
                            Features.ismultivendor
                            ? widget.searchstoredata!.increament
                            : widget.itemdata!.increament,
                        cart_id: parent_id,
                        toppings: toppings,
                        topping_id: toppings_id
                    );

                  }

                }*/
                /*else{*/
                  print("max item reach... 7 dec");
                  print("max item reach... else...else2 dec");

                 /* var varIdold = varid;
                  print("max item reach... else...else2 variation..."+varIdold.toString()+"qty.."+qty.toString()+"variation id..."+widget.priceVariation!.id.toString());
                  var varminitemold = widget.priceVariation!.minItem;
                  var varpriceold = widget.priceVariation!.price;*/

                  for (int i = widget.groupvalue!; i <
                      widget.itemdata!.priceVariation!.length; i++) {
                    print("max item reach... else...else2 group value11 dec" +"i value....."+i.toString() + "..."+widget.groupvalue.toString()+"id..."+widget.itemdata!.priceVariation![i].id.toString());
                    // if(int.parse(productBox
                    //     .where((element) => element.varId == widget.priceVariation!.id)
                    //     .last.varId.toString())== widget.itemdata!.priceVariation![i].id){
                    //   print("max item reach... 10");
                    //   print("equal variation");
                    //   print("max item reach... else...else2 group value11" +widget.groupvalue.toString()+"id..."+widget.itemdata!.priceVariation![i].id.toString());
                    //
                    //   print("max item reach... else...else2 group value1" +widget.groupvalue.toString());
                    //
                    //
                    // }
                    // else{
                    if (int.parse(
                        widget.itemdata!.priceVariation![0].minItem
                            .toString()) <= qty) {
                      print("max item reach... 8 dec");
                      print("groupvalue....2" + widget.groupvalue.toString() +
                          "....");
                      print("max item reach... else...else2 if....dec");
                      cartcontroller.update((done) {
                        setState(() {
                          loading = !done;
                          print("value of loading in decrement cart decrement case: " +
                              loading.toString() + "groupvalue..."+widget.groupvalue.toString());
                          widget.onChange!(widget.groupvalue!,qty - 1);
                        });
                      }, price: widget.from == "search_screen" && Features.ismultivendor
                          ? widget.searchstoredata!.type == "1" ? widget.searchstoredata!
                          .price.toString() : widget.priceVariationSearch!.price
                          .toString()
                          : widget.itemdata!.type == "1" ? widget.itemdata!.price
                          .toString() : /*varpriceold.toString()*/widget.priceVariation!.price.toString(),
                          quantity: widget.from == "search_screen" &&
                              Features.ismultivendor ?
                          widget.searchstoredata!.type == "1" ? ((weight) <=
                              (double.parse(widget.searchstoredata!.minItem!) *
                                  double.parse(widget.searchstoredata!.increament!)))
                              ? "0"
                              : (qty).toString() : ((qty) <=
                              int.parse(widget.priceVariationSearch!.minItem!))
                              ? "0"
                              : (qty - 1).toString() :
                          widget.itemdata!.type == "1" ? ((weight) <=
                              (double.parse(widget.itemdata!.minItem!) *
                                  double.parse(widget.itemdata!.increament!)))
                              ? "0"
                              : (qty).toString() : ((qty) <=
                              int.parse(widget.priceVariation!.minItem!)) ? "0" : (qty -
                              1).toString(),
                          weight: widget.from == "search_screen" && Features.ismultivendor
                              ?
                          widget.searchstoredata!.type == "1" ? ((weight) <=
                              (double.parse(widget.searchstoredata!.minItem!) *
                                  double.parse(widget.searchstoredata!.increament!)))
                              ? "0"
                              : (weight -
                              double.parse(widget.searchstoredata!.increament!))
                              .toString() : "0"
                              : widget.itemdata!.type == "1" ? ((weight) <=
                              (double.parse(widget.itemdata!.minItem!) *
                                  double.parse(widget.itemdata!.increament!)))
                              ? "0"
                              : (weight - double.parse(widget.itemdata!.increament!))
                              .toString() : "0",
                          var_id: widget.from == "search_screen" && Features.ismultivendor
                              ? widget.searchstoredata!.type == "1" ? widget
                              .searchstoredata!.id! : varid
                              : widget.itemdata!.type == "1"
                              ? widget.itemdata!.id!
                              : varIdold/*varid*/,
                          type: widget.from == "search_screen" && Features.ismultivendor
                              ? widget.searchstoredata!.type
                              : widget.itemdata!.type,
                          increament: widget.from == "search_screen" &&
                              Features.ismultivendor
                              ? widget.searchstoredata!.increament
                              : widget.itemdata!.increament,
                          cart_id: parent_id,
                          toppings: toppings,
                          topping_id: toppings_id,
                          item_id: widget.itemdata!.id.toString()
                      );
                    }
                    else {
                      print("max item reach... 9 dec");
                      print("max item reach... else...else2 else....dec");

                      debugPrint("cant_add_more_item......4 dec");
                      Fluttertoast.showToast(
                          msg:
                          S
                              .of(context)
                              .cant_add_more_item,
                          //"Sorry, you can\'t add more of this item!",
                          fontSize: MediaQuery
                              .of(context)
                              .textScaleFactor * 13,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white);

                    }
                    // }

                    print("group value ..at end .....decrement before"+widget.groupvalue.toString()+ "i value..."+i.toString());
                    print("group value ..at end .....decrement before price variation..."+widget.groupvalue.toString()+ "i value..."+widget.itemdata!.priceVariation![i].minItem
                        .toString());
                    if(int.parse(
                        widget.itemdata!.priceVariation![i].minItem
                            .toString()) == qty) {
                      if (widget.groupvalue! > 1) {
                        setState(() {
                          widget.groupvalue = widget.groupvalue! - 1;
                          widget.onChange!(widget.groupvalue!,qty-1);
                        });
                      }
                      else {
                        widget.groupvalue = 0;
                        widget.onChange!(widget.groupvalue!,qty -1);
                      }
                    }
                    print("group value ..at end .....decrement"+widget.groupvalue.toString()+ "i value..."/*+i.toString()*/);
                    break;
                  }


                }
              //}
            }
          }
          else {
            cartcontroller.update((done) {
              setState(() {
                loading = !done;
                print("value of loading in decrement cart decrement case: " +
                    loading.toString());
              });
            }, price: widget.from == "search_screen" && Features.ismultivendor
                ? widget.searchstoredata!.type == "1" ? widget.searchstoredata!
                .price.toString() : widget.priceVariationSearch!.price
                .toString()
                : widget.itemdata!.type == "1" ? widget.itemdata!.price
                .toString() : widget.priceVariation!.price.toString(),
                quantity: widget.from == "search_screen" &&
                    Features.ismultivendor ?
                widget.searchstoredata!.type == "1" ? ((weight) <=
                    (double.parse(widget.searchstoredata!.minItem!) *
                        double.parse(widget.searchstoredata!.increament!)))
                    ? "0"
                    : (qty).toString() : ((qty) <=
                    int.parse(widget.priceVariationSearch!.minItem!))
                    ? "0"
                    : (qty - 1).toString() :
                widget.itemdata!.type == "1" ? ((weight) <=
                    (double.parse(widget.itemdata!.minItem!) *
                        double.parse(widget.itemdata!.increament!)))
                    ? "0"
                    : (qty).toString() : ((qty) <=
                    int.parse(widget.priceVariation!.minItem!)) ? "0" : (qty -
                    1).toString(),
                weight: widget.from == "search_screen" && Features.ismultivendor
                    ?
                widget.searchstoredata!.type == "1" ? ((weight) <=
                    (double.parse(widget.searchstoredata!.minItem!) *
                        double.parse(widget.searchstoredata!.increament!)))
                    ? "0"
                    : (weight -
                    double.parse(widget.searchstoredata!.increament!))
                    .toString() : "0"
                    : widget.itemdata!.type == "1" ? ((weight) <=
                    (double.parse(widget.itemdata!.minItem!) *
                        double.parse(widget.itemdata!.increament!)))
                    ? "0"
                    : (weight - double.parse(widget.itemdata!.increament!))
                    .toString() : "0",
                var_id: widget.from == "search_screen" && Features.ismultivendor
                    ? widget.searchstoredata!.type == "1" ? widget
                    .searchstoredata!.id! : varid
                    : widget.itemdata!.type == "1"
                    ? widget.itemdata!.id!
                    : varid,
                type: widget.from == "search_screen" && Features.ismultivendor
                    ? widget.searchstoredata!.type
                    : widget.itemdata!.type,
                increament: widget.from == "search_screen" &&
                    Features.ismultivendor
                    ? widget.searchstoredata!.increament
                    : widget.itemdata!.increament,
                cart_id: parent_id,
                toppings: toppings,
                topping_id: toppings_id,
                item_id: widget.itemdata!.id.toString()
            );
          }
          // TODO: Handle this case.
          break;
      }
    }

    addToCart(String topping_type, String varid, String toppings, String? parent_id, String? newproduct,List addToppings ) async {
      debugPrint("add to cart......"+toppings);
     if(widget.from == "search_screen" && Features.ismultivendor) {
       if (widget.searchstoredata!.type == "1") {

         debugPrint("add to cart......type 1");
         cartcontroller.addtoCart( storeSearchData: widget.searchstoredata!,
             onload: (isloading) {
           setState(() {
             debugPrint("add to cart......1");
             loading = isloading;
             //onload(isloading);
             //onload(true);
             // Toppingloading = true;
             print("value of loading in add cart fn " + loading.toString());
           });
         },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings,fromScreen: "search_screen",context: context);
         if(Features.isfacebookappevent)
           FaceBookAppEvents.facebookAppEvents.logAddToCart(id: int.parse(widget.searchstoredata!.id!).toString(), type: widget.searchstoredata!.itemName!, currency: IConstants.currencyFormat, price: widget.searchstoredata!.type=="1"?double.parse(widget.searchstoredata!.price.toString()):double.parse(widget.priceVariationSearch!.price.toString()));

         //onload(false);
       }
       else {
         debugPrint("add to cart......type 2");
         cartcontroller.addtoCart(storeSearchData: widget.searchstoredata!, onload: (isloading) {
           setState(() {
             debugPrint("add to cart......1");
             loading = isloading;
             //onload(true);
             //onload(isloading);
             print("value of loading in add cart fn " + loading.toString());
           });
         },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!, toppingsList: addToppings,itembodysearch: widget.priceVariationSearch!,fromScreen: "search_screen",context: context);
         //onload(false);
       }
     }
     else{
       if (widget.itemdata!.type == "1") {

         debugPrint("add to cart......type 1");
         cartcontroller.addtoCart(itemdata: widget.itemdata!, onload: (isloading) {
           setState(() {
             debugPrint("add to cart......1");
             loading = isloading;
             //onload(isloading);
             //onload(true);
             // Toppingloading = true;
             print("value of loading in add cart fn " + loading.toString());
           });
         },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings,context: context);
         //onload(false);
       }
       else {
         debugPrint("add to cart......type 2");
         if(Features.btobModule){
           cartcontroller.addtoCart(itemdata: widget.itemdata!, onload: (isloading) {
             setState(() {
               debugPrint("add to cart......1");
               loading = isloading;
               //onload(true);
               //onload(isloading);
               print("value of loading in add cart fn " + loading.toString());
               widget.onChange!(widget.groupvalue!,(productBox
                   .where((element) => element.itemId == widget.itemdata!.id)
                   .length > 1 ?(int.parse(productBox
                   .where((element) => element.itemId == widget.itemdata!.id).first.quantity!)):1));
             });
           },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings, itembody: widget.priceVariation!,context: context);
         }
         else{
           cartcontroller.addtoCart(itemdata: widget.itemdata!, onload: (isloading) {
             setState(() {
               debugPrint("add to cart......1");
               loading = isloading;
               //onload(true);
               //onload(isloading);
               print("value of loading in add cart fn " + loading.toString());
             });
           },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings, itembody: widget.priceVariation!,context: context);
           //onload(false);
         }

       }
       if(Features.isfacebookappevent)
         FaceBookAppEvents.facebookAppEvents.logAddToCart(id: int.parse(widget.itemdata!.id!).toString(), type: widget.itemdata!.itemName!, currency: IConstants.currencyFormat, price: widget.itemdata!.type=="1"?double.parse(widget.itemdata!.price.toString()):double.parse(widget.priceVariation!.price.toString()));
     }




    }

    toppingsExistance(varid, productid, List checktoppings, List addToppings, ) async {
      List<SellingItemsFields> list = [];
    if(widget.itemdata!.type != "1") {
      item.forEach((element) {
        debugPrint("ggggg....22..hh..." + element.itemId.toString() + "..." +
            widget.itemdata!.id.toString() + ".." + element.quantity!);
        if (element.itemId == widget.itemdata!.id) {
          //fetchItemData = Provider.of<ItemsList>(context, listen: false).fetchItems();
          for (int i = 0; i <
              widget.itemdata!.priceVariation!.length; i++) {
            if (widget.itemdata!.priceVariation![i].id == element.varId) {
              list.add(SellingItemsFields(weight: double.parse(
                  widget.itemdata!.priceVariation![i].weight!),
                  varQty: int.parse(element.quantity.toString())));
            }
          }
          debugPrint("list...."+list.toString());
        }
      });
    }

      debugPrint("varid...product...checktoppings..."+varid.toString()+"...."+productid.toString()+"....."+checktoppings.toString());
      Map<String, String> resBody = {};
      resBody["id"] = (!PrefUtils.prefs!.containsKey("apikey")) ? PrefUtils.prefs!.getString("tokenid")! : PrefUtils.prefs!.getString('apikey')!;
      resBody["product"] = productid;
      resBody["variation"] = varid;
      if(checktoppings.length > 0) {
        for (int i = 0; i < checktoppings.length; i++) {
          resBody["toppings[" + i.toString() + "][id]"] =
          checktoppings[i]["id"];

        }
      }else{
        resBody["toppings[" "][id]"] = "[]";
      }
      debugPrint("resBody....viewToppingsExistingDetails...."+resBody.toString());
      var url = Api.viewToppingsExistingDetails ;
      final response = await http.post(url, body: resBody
      );

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("responseJson....viewToppingsExistingDetails...."+responseJson.toString());
      debugPrint("quantityTotal....viewToppingsExistingDetails...."+quantityTotal.toString());
      debugPrint("weightTotal....viewToppingsExistingDetails...."+weightTotal.toString());
      if((widget.itemdata!.type == "1")?
      (weightTotal < double.parse(widget.itemdata!.stock.toString()))
      :
     !( Check().isOutofStock(
        maxstock: double.parse(widget.priceVariation!.stock.toString()),
        stocktype: widget.itemdata!.type!,
        qty: quantityTotal.toString() ,
        itemData: list,
        variation: widget.priceVariation!,
      ))) {
        debugPrint("isOutofStock...");
        if ((widget.itemdata!.type == "1") ? (weightTotal <
            (double.parse(widget.itemdata!.maxItem!) *
                double.parse(widget.itemdata!.increament!))) : (quantityTotal <
            double.parse(widget.priceVariation!.maxItem!))) {
          if (responseJson['status'].toString() == "400") {
            //add to cart
            debugPrint("add.....");
            if (addToppings.length > 0) {
              await addToCart(
                addToppingsProduct[0]["Toppings_type"],
                addToppingsProduct[0]["varId"],
                addToppingsProduct[0]["toppings"],
                "",
                addToppingsProduct[0]["newproduct"],
                addToppings,
              );
              debugPrint("add toppings data...." + addToppings.toString());
            } else {
              await addToCart(
                  addToppingsProduct[0]["Toppings_type"],
                  addToppingsProduct[0]["varId"],
                  addToppingsProduct[0]["toppings"],
                  "",
                  addToppingsProduct[0]["newproduct"],
                  addToppings
              );
            }
          }
          else if (responseJson['status'].toString() == "200") {
            //update cart
            final box = (VxState.store as GroceStore).CartItemList;
            (widget.from == "search_screen" && Features.ismultivendor) ?
            updateCart(
                widget.searchstoredata!.type == "1" ? int.parse(box
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!) :
                int.parse(box
                    .where((element) =>
                element.varId ==
                    widget.priceVariationSearch!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!),
                widget.searchstoredata!.type == "1" ? double.parse(box
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!) : double.parse(box
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!),
                CartStatus.increment,
                widget.searchstoredata!.type == "1"
                    ? widget.searchstoredata!.id!
                    : widget.priceVariationSearch!.id!,
                productBox.last.parent_id!,
                "0",
                "") :
            updateCart(
                widget.itemdata!.type == "1" ? int.parse(box
                    .where((element) =>
                element.itemId == widget.itemdata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!) :
                int.parse(box
                    .where((element) =>
                element.varId ==
                    widget.priceVariation!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!),
                widget.itemdata!.type == "1" ? double.parse(box
                    .where((element) =>
                element.itemId == widget.itemdata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!) : double.parse(box
                    .where((element) =>
                element.itemId == widget.itemdata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!),
                CartStatus.increment,
                widget.itemdata!.type == "1" ? widget.itemdata!.id! : widget
                    .priceVariation!.id!,
                responseJson['parent_id'].toString(),
                "0",
                "");
          }
          else {
            Fluttertoast.showToast(
              msg: "Something went wrong",
              fontSize: MediaQuery
                  .of(context)
                  .textScaleFactor * 13,
              backgroundColor: ColorCodes.blackColor,
              textColor: ColorCodes.whiteColor,);
          }
        }
        else {
          Fluttertoast.showToast(
              msg:
              S
                  .of(context)
                  .cant_add_more_item,
              //"Sorry, you can\'t add more of this item!",
              fontSize: MediaQuery
                  .of(context)
                  .textScaleFactor * 13,
              backgroundColor: Colors.black87,
              textColor: Colors.white);
        }
      }else{
        Fluttertoast.showToast(
            msg:
            S
                .of(context)
                .sorry_outofstock,
            fontSize: MediaQuery
                .of(context)
                .textScaleFactor * 13,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }

    }

    Widget _myRadioButton({ String? title,  int? value,  Function(int?)? onChanged}) {
      return RadioListTile<int>(
        controlAffinity: ListTileControlAffinity.trailing,
        value: value!,
        groupValue: _groupValue,
        onChanged: onChanged!,
        title: Text(title!),
      );
    }

    dialogforToppings(BuildContext context){
      List addToppings = [];
      List checktoppings = [];
      List checktoppings1 =[];
      return
        showModalBottomSheet(
            shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            context: context,
            builder: ( context) {
              return WillPopScope(
                onWillPop: (){
                  return Future.value(true);
                },
                child: Wrap(
                    children: [
                      StatefulBuilder(builder: (context, setState1)
                      {
                        return Container(
                          decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(25.0),
                                  topRight: const Radius.circular(25.0))),
                          padding: EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Text(
                                (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.itemName!:widget.itemdata!.itemName!, style: TextStyle(fontSize: 22,
                                  color: ColorCodes.blackColor,
                                  fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10,),
                              Divider(
                                thickness: 1, color: ColorCodes.greyColor, height: 1,),
                              SizedBox(height: 10,),
                              Text(
                                "Customize", style: TextStyle(fontSize: 18,
                                  color: ColorCodes.blackColor,
                                  fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5,),
                              (widget.addon!.type == "1")?
                              Column(
                                children: [
                                  SingleChildScrollView(
                                    child: ListView.builder(
                                      //scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount:widget.addon!.list!.length,
                                        itemBuilder: (_, i) {

                                          return

                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap:(){

                                                    setState1((){

                                                      for(int j =0; j< widget.addon!.list!.length; j++){
                                                        if(i == j){
                                                          widget.addon!.list![j].isSelected = true;
                                                          varId = j;
                                                          addToppings.clear();
                                                         /* item1["\"toppings_id\""] = "\""+ widget.addon!.list![varId!].id!+"\"";
                                                          item1["\"toppings_name\""] = "\""+ widget.addon!.list![varId!].name!+"\"";
                                                          item1["\"toppings_price\""] = "\""+ widget.addon!.list![varId!].price!+"\"";
                                                         addToppings.add(item1);*/
                                                          addToppings.add({"Toppings_type":"1","toppings_id":  widget.addon!.list![varId!].id!,/*"toppings":"1", "parent_id":  productBox.last.parent_id!,newproduct":"0",*/ "toppings_name":widget.addon!.list![varId!].name,"toppings_price":widget.addon!.list![varId!].price});
                                                        }else{
                                                          widget.addon!.list![j].isSelected = false;
                                                        }
                                                      }

                                                    });

                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(width: 20,),
                                                      Container(
                                                        child: Text(
                                                          widget.addon!.list![i].name!+" - "+IConstants.currencyFormat + widget.addon!.list![i].price!,
                                                          style: TextStyle(color: (widget.addon!.list![i].isSelected == true) ?ColorCodes.greenColor:ColorCodes.blackColor,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      handler(widget.addon!.list![i].isSelected),
                                                      SizedBox(width: 20,),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height:20,)
                                              ],
                                            );
                                        }),
                                  ),
                                  SizedBox(height: 20,),
                                  Row(
                                    children: [
                                      Text(((widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.type == "1" : widget.itemdata!.type=="1")?(widget.from == "search_screen" && Features.ismultivendor)?IConstants.currencyFormat + widget.searchstoredata!.price.toString():IConstants.currencyFormat + widget.itemdata!.price.toString(): (widget.from == "search_screen" && Features.ismultivendor)?IConstants.currencyFormat+widget.priceVariationSearch!.price.toString():IConstants.currencyFormat + widget.priceVariation!.price.toString()
                                        , style: TextStyle(fontSize: 20,
                                            color: ColorCodes.blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 10,),
                                      (widget.from == "search_screen" && Features.ismultivendor)?Text((widget.searchstoredata!.type=="1")? (widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.searchstoredata!.mrp.toString():"":(widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariationSearch!.mrp.toString():"",
                                        style: TextStyle(fontSize: 14,
                                          color: ColorCodes.greyColor,
                                        ),
                                      ):
                                      Text((widget.itemdata!.type=="1")? (widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.itemdata!.mrp.toString():"":(widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariation!.mrp.toString():"",
                                        style: TextStyle(fontSize: 14,
                                          color: ColorCodes.greyColor,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () async {
                                          // if(toppingscheck == "yes") {
                                          debugPrint("varid toppings...."+varId.toString()+"..."+parentId.toString());
                                          // addToCart("1",varId!,"1",parentId,"0");
                                          // addToCart("1",widget.addon!.list![varId!].id!,"1",productBox.last.parent_id!,"0");
                                          if(addToppings.length > 0){
                                            checktoppings1.clear();
                                            for(int i =0; i< addToppings.length; i++){
                                              debugPrint("addToppings[i]...."+addToppings[i]["toppings_id"]);
                                              checktoppings1.add(addToppings[i]["toppings_id"]);
                                            }
                                            debugPrint("checktopping....1"+checktoppings1.toString());
                                          }

                                          if(checktoppings1.length > 1){
                                            checktoppings1.sort();
                                          }
                                          debugPrint("after sort checktopping...."+checktoppings1.toString());
                                          checktoppings.clear();
                                          for(int j =0; j< checktoppings1.length; j++){

                                            checktoppings.add({"id":checktoppings1[j]});
                                            debugPrint("checktopping...."+checktoppings.toString());
                                          }
                                          toppingsExistance((widget.itemdata!.type=="1")?addToppingsProduct[0]["productid"] :addToppingsProduct[0]["varId"],addToppingsProduct[0]["productid"],checktoppings,addToppings);

                                          /*for(int i = 0; i< addToppingsProduct.length; i++){
                                            if(addToppings.length > 0){
                                              for(int j = 0; j < addToppings.length; j++) {
                                                await addToCart(
                                                    addToppingsProduct[i]["Toppings_type"],
                                                    addToppingsProduct[i]["varId"],
                                                    addToppingsProduct[i]["toppings"],
                                                    "",
                                                    addToppingsProduct[i]["newproduct"],
                                                    addToppings,

                                                );
                                              }
                                            }else {
                                              await addToCart(
                                                  addToppingsProduct[i]["Toppings_type"],
                                                  addToppingsProduct[i]["varId"],
                                                  addToppingsProduct[i]["toppings"],
                                                  "",
                                                  addToppingsProduct[i]["newproduct"],
                                                  addToppings,

                                              );
                                            }
                                          }*/
                                          for (int i = 0; i <
                                              widget.addon!.list!.length; i++)
                                            widget.addon!.list![i].isSelected = false;
                                          Navigator.of(context).pop();

                                          /* }else{
                                    Fluttertoast.showToast(msg: "Please select any toppings" ,
                                        fontSize: MediaQuery.of(context).textScaleFactor *13,
                                        backgroundColor:
                                        Colors.black87,
                                        textColor: Colors.white);
                                  }*/
                                          //addToCart("", "", "0");
                                        },
                                        child: Container(
                                          width: 150,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                                width: 1, color: ColorCodes.primaryColor),
                                          ),
                                          child: Center(
                                            child: Text("ADD ITEMS",style: TextStyle(fontSize: 16,
                                                color: ColorCodes.primaryColor,
                                                fontWeight: FontWeight.bold), ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              ):
                              Column(
                                children: [
                                  SingleChildScrollView(
                                    child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: widget.addon!.list!.length,
                                        itemBuilder: (_, i) {

                                          return GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: (){

                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              margin: EdgeInsets.symmetric(vertical: 5),
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(

                                                children: [
                                                  Checkbox(
                                                    value: widget.addon!.list![i].isSelected,
                                                    checkColor: ColorCodes.whiteColor,
                                                    activeColor: ColorCodes.primaryColor,
                                                    onChanged: (bool? val) {
                                                      setState1(() {
                                                        debugPrint("val..."+val.toString());
                                                        widget.addon!.list![i].isSelected = val!;

                                                      });
                                                      // addToppings.clear();
                                                      debugPrint("val..."+widget.addon!.list![i].isSelected.toString()+"......"+widget.index.toString()+"..."+i.toString());
                                                      //  debugPrint("parent id...."+productBox.last.parent_id.toString());

                                                      if (widget.addon!.list![i].isSelected == true) {
                                                        /*item1["\"toppings_id\""] = "\""+ widget.addon!.list![i].id!+"\"";
                                                        item1["\"toppings_name\""] = "\""+ widget.addon!.list![i].name!+"\"";
                                                        item1["\"toppings_price\""] = "\""+ widget.addon!.list![i].price!+"\"";
                                                        addToppings.add(item1);*/

                                                        addToppings.add({"Toppings_type": "0","toppings_id":  widget.addon!.list![i].id!,/*"toppings":"1", "parent_id":  "","newproduct":"0",*/"toppings_name":widget.addon!.list![i].name,"toppings_price":widget.addon!.list![i].price});
                                                        debugPrint("addToppings..."+addToppings.toString()+"...."+addToppings.length.toString());
                                                      }else{
                                                        for(int i = 0; i< addToppings.length; i++){
                                                          addToppings.removeAt(i);
                                                        }
                                                        debugPrint("addToppings...1"+addToppings.toString()+"...."+addToppings.length.toString());
                                                      }

                                                      if(widget.addon!.list![i].isSelected == true) {
                                                        toppingscheck = "yes";
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Text( widget.addon!.list![i].name!+" - "+IConstants.currencyFormat + widget.addon!.list![i].price!, style: TextStyle(fontSize: 16,
                                                      color: ColorCodes.greyColor,
                                                      fontWeight: FontWeight.bold),)
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                  SizedBox(height: 20,),
                                  Row(
                                    children: [
                                      (widget.from == "search_screen" && Features.ismultivendor)?
                                      Text((widget.searchstoredata!.type=="1")?IConstants.currencyFormat + widget.searchstoredata!.price.toString(): IConstants.currencyFormat + widget.priceVariationSearch!.price.toString()
                                        , style: TextStyle(fontSize: 20,
                                            color: ColorCodes.blackColor,
                                            fontWeight: FontWeight.bold),
                                      ):
                                      Text((widget.itemdata!.type=="1")?IConstants.currencyFormat + widget.itemdata!.price.toString(): IConstants.currencyFormat + widget.priceVariation!.price.toString()
                                        , style: TextStyle(fontSize: 20,
                                            color: ColorCodes.blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 10,),
                                      (widget.from == "search_screen" && Features.ismultivendor)?
                                      Text((widget.searchstoredata!.type=="1")? (widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.searchstoredata!.mrp.toString():"":(widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariationSearch!.mrp.toString():"",
                                        style: TextStyle(fontSize: 14,
                                          color: ColorCodes.greyColor,
                                        ),
                                      ):
                                      Text((widget.itemdata!.type=="1")? (widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.itemdata!.mrp.toString():"":(widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariation!.mrp.toString():"",
                                        style: TextStyle(fontSize: 14,
                                          color: ColorCodes.greyColor,
                                        ),
                                      ),
                                      Spacer(),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () async {
                                          debugPrint("addToppingsProduct...."+addToppingsProduct.length.toString()+"  "+addToppings.length.toString());
                                          bool _isProductAdded = false;
                                        /*  for(int i = 0; i< addToppingsProduct.length; i++){
                                            await addToCart(addToppingsProduct[i]["Toppings_type"],
                                                addToppingsProduct[i]["varId"], addToppingsProduct[i]["toppings"],
                                                "", addToppingsProduct[i]["newproduct"],(isloading) {
                                                  setState(() {
                                                    debugPrint("isloading..true..or..false.."+isloading.toString());
                                                    Toppingloading = isloading;
                                                    print("loading is false.."+addToppings.length.toString()+"  "+Toppingloading.toString());
                                                    if(!Toppingloading && !_isProductAdded){
                                                      _isProductAdded = true;
                                                      for (int j = 0; j < addToppings.length; j++) {
                                                        print("loading is 1 false..i");
                                                        addToCart(
                                                            addToppings[j]["Toppings_type"],
                                                            addToppings[j]["varId"],
                                                            addToppings[j]["toppings"],
                                                            productBox.last
                                                                .parent_id,
                                                            addToppings[j]["newproduct"],
                                                                (isloading) {
                                                              setState(() {
                                                                //Toppingloading = isloading;
                                                              });
                                                            }
                                                        );
                                                      }
                                                    }
                                                  });
                                                });
                                          }*/

                                           if(addToppings.length > 0){
                                             checktoppings.clear();
                                             for(int i =0; i< addToppings.length; i++){
                                               debugPrint("addToppings[i]...."+addToppings[i]["toppings_id"]);
                                               checktoppings.add({"id":addToppings[i]["toppings_id"]});
                                               debugPrint("checktopping...."+checktoppings.toString());
                                             }
                                           }

                                          toppingsExistance((widget.itemdata!.type=="1")?addToppingsProduct[0]["productid"] :addToppingsProduct[0]["varId"],addToppingsProduct[0]["productid"],checktoppings,addToppings);

                                        /*  for(int i = 0; i< addToppingsProduct.length; i++){
                                            if(addToppings.length > 0){
                                              await addToCart(
                                                addToppingsProduct[i]["Toppings_type"],
                                                addToppingsProduct[i]["varId"],
                                                addToppingsProduct[i]["toppings"],
                                                "",
                                                addToppingsProduct[i]["newproduct"],
                                                addToppings,
                                              );
                                              debugPrint("add toppings data...."+addToppings.toString());
                                            }else {
                                              await addToCart(
                                                  addToppingsProduct[i]["Toppings_type"],
                                                  addToppingsProduct[i]["varId"],
                                                  addToppingsProduct[i]["toppings"],
                                                  "",
                                                  addToppingsProduct[i]["newproduct"],
                                                  addToppings
                                              );
                                            }
                                          }*/

                                          debugPrint("loading....after product add.."+Toppingloading.toString());

                                          for (int i = 0; i < widget.addon!.list!.length; i++) {
                                            widget.addon!.list![i].isSelected = false;
                                          }
                                          Navigator.of(context).pop();

                                        },
                                        child: Container(
                                          width: 150,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                                width: 1, color: ColorCodes.primaryColor),
                                          ),
                                          child: Center(
                                            child: Text("ADD ITEMS",style: TextStyle(fontSize: 16,
                                                color: ColorCodes.primaryColor,
                                                fontWeight: FontWeight.bold), ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10,)
                                ],
                              ),

                            ],
                          ),
                        );
                      }),]),
              );
            }
        );
    }

    dialogforUpdateToppings(BuildContext context) async {
      (widget.from == "search_screen" && Features.ismultivendor)?
      MyorderList().GetRepeateToppings((widget.searchstoredata!.type == "1")?
      widget.searchstoredata!.id!:
      widget.priceVariationSearch!.id!,
          widget.searchstoredata!.id!).then((value) {
        print("topupstate"+value!.length.toString());
        topupState(() {
          _futureNonavailable = Future.value(value);

        });
        _futureNonavailable.then((value) {
          parentidforupdate = value.first.parent_id!;
          print("value.." + value.first.data!.first.name.toString()+"  "+parentidforupdate.toString());
        });

      }):
      MyorderList().GetRepeateToppings((widget.itemdata!.type == "1")?
      widget.itemdata!.id!:
      widget.priceVariation!.id!,
          widget.itemdata!.id!).then((value) {
        print("topupstate"+value!.length.toString());
        topupState(() {
          _futureNonavailable = Future.value(value);

        });
        _futureNonavailable.then((value) {
          parentidforupdate = value.first.parent_id!;
          print("value.." + value.first.data!.first.name.toString()+"  "+parentidforupdate.toString());
        });


      });

      return
        showModalBottomSheet(
            shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            context: context,
            builder: ( context) {
              return Wrap(
                  children: [
                    StatefulBuilder(builder: (context, setState1)
                    {
                      topupState = setState1;
                      return Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(25.0),
                                topRight: const Radius.circular(25.0))),
                        padding: EdgeInsets.only(left: 20, right: 20),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              /*decoration: BoxDecoration(
                                color: ColorCodes.secondaryColor,
                              ),*/
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (widget.from == "search_screen" && Features.ismultivendor)?"   "+widget.searchstoredata!.itemName!: "   "+ widget.itemdata!.itemName!, style: TextStyle(fontSize: 20,
                                      color: ColorCodes.blackColor,
                                      fontWeight: FontWeight.bold),
                                  ),
                                  /*SizedBox(height: 3,),
                                  Text(
                                   "   "+ IConstants.currencyFormat + widget.itemdata!.price!+"-"+IConstants.currencyFormat + widget.itemdata!.mrp!
                                    , style: TextStyle(fontSize: 12,
                                      color: ColorCodes.blackColor,
                                      fontWeight: FontWeight.bold),
                                  ),*/
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            Divider(
                              thickness: 1, color: ColorCodes.greyColor, height: 1,),
                            SizedBox(height: 10,),
                            Text(
                              "Your Previous customization", style: TextStyle(fontSize: 18,
                                color: ColorCodes.blackColor,
                                fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 5,),
                            FutureBuilder<List<RepeatToppings>>(
                              future: _futureNonavailable,
                              builder: (BuildContext context,AsyncSnapshot<List<RepeatToppings>> snapshot){
                                final RepeatToppings = snapshot.data;
                                // if(promoData!.length > 0)
                                if (RepeatToppings!=null)
                                  return
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        // scrollDirection: Axis.horizontal,
                                        itemCount: RepeatToppings.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Text(RepeatToppings[index].data![index].name!);
                                        });
                                else
                                  return SizedBox.shrink();

                              },
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: (){
                                    Navigator.of(context).pop();
                                    //addToCart("", "", "0",/*productBox[widget.index].parent_id*/"","1");
                                    addToppingsProduct.clear();
                                    addToppingsProduct.add({"Toppings_type":"","varId":  (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,"toppings":"0", "parent_id":  "","newproduct":"1","productid":widget.itemdata!.id}); //adding product
                                    debugPrint("add Toppings product..."+addToppingsProduct.toString());
                                    dialogforToppings(context);
                                    //addToCart("", "", "0");
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1, color: ColorCodes.primaryColor),
                                    ),
                                    child: Center(
                                      child: Text("I'LL CHOOSE",style: TextStyle(fontSize: 16,
                                          color: ColorCodes.primaryColor,
                                          fontWeight: FontWeight.bold), ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: ()   {
                                    final box = (VxState.store as GroceStore).CartItemList;

                                    Navigator.of(context).pop();
                                    (widget.from == "search_screen" && Features.ismultivendor)?
                                    updateCart(
                                        widget.searchstoredata!.type == "1"? int.parse(box
                                            .where((element) =>
                                        element.itemId == widget.searchstoredata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .quantity! ):
                                        int.parse(box
                                            .where((element) =>
                                        element.varId ==
                                            widget.priceVariationSearch!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .quantity!),
                                        widget.searchstoredata!.type == "1"?  double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.searchstoredata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!): double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.searchstoredata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!),
                                        CartStatus.increment,
                                        widget.searchstoredata!.type == "1"? widget.searchstoredata!.id!:widget.priceVariationSearch!.id!,
                                        parentidforupdate.toString(),
                                        "0",
                                        ""):
                                    updateCart(
                                       widget.itemdata!.type == "1"? int.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id && element.parent_id! == parentidforupdate.toString())
                                        .first
                                        .quantity!):
                                       int.parse(box
                                           .where((element) =>
                                       element.varId ==
                                           widget.priceVariation!.id && element.parent_id! == parentidforupdate.toString())
                                           .first
                                           .quantity!),
                                       widget.itemdata!.type == "1"?  double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.itemdata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!): double.parse(box
                                           .where((element) =>
                                       element.itemId == widget.itemdata!.id && element.parent_id! == parentidforupdate.toString())
                                           .first
                                           .weight!),
                                        CartStatus.increment,
                                       widget.itemdata!.type == "1"? widget.itemdata!.id!:widget.priceVariation!.id!,
                                        parentidforupdate.toString(),
                                        "0",
                                        "");
                                   // toppingsExistance(addToppingsProduct[0]["varId"],addToppingsProduct[0]["productid"],checktoppings,addToppings);

                                  },
                                  child: Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1, color: ColorCodes.primaryColor),
                                    ),
                                    child: Center(
                                      child: Text("REPEAT",style: TextStyle(fontSize: 16,
                                          color: ColorCodes.primaryColor,
                                          fontWeight: FontWeight.bold), ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      );
                    }),]);
            }
        );
    }

    dialogforDeleteToppings(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
            child: Container(
              height: 150,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Center(child:

                  Text("Remove item from cart", style: TextStyle(fontSize: 20),)
                  ),
                  SizedBox(height: 10,),
                  Text("This item has multiple customization added, Proceed to cart to remove item?",style: TextStyle(fontSize: 14),),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: ColorCodes.greenColor),
                          ),
                          width: 60,
                          height: 30,
                          child: Center(
                            child: Text(
                              S.of(context).yes,style: TextStyle(color: ColorCodes.greenColor), //'yes'
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: ColorCodes.greenColor),
                          ),
                          child: Center(
                            child: Text(
                              S.of(context).no,style: TextStyle(color: ColorCodes.greenColor), //'no'
                            ),
                          ),
                        ),
                      )

                    ],
                  )
                ],
              ),
            ),

          );
        },
      );
    }


    _notifyMe() async {
      setState(() {
        _isNotify = true;
      });
      //_notifyMe();
      debugPrint("resposne........1");
      int resposne = await Provider.of<BrandItemsList>(context, listen: false).notifyMe((widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.id.toString():widget.itemdata!.id.toString(),(widget.from == "search_screen" && Features.ismultivendor)?widget.priceVariationSearch!.id.toString():widget.priceVariation!.id.toString(),(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.type!:widget.itemdata!.type!);
      debugPrint("resposne........"+resposne.toString());
      if(resposne == 200) {
        setState(() {
          _isNotify = false;
        });
        //_isWeb?_Toast("You will be notified via SMS/Push notification, when the product is available"):
        Fluttertoast.showToast(msg: S .of(context).you_will_notify,//"You will be notified via SMS/Push notification, when the product is available" ,
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor:
            Colors.black87,
            textColor: Colors.white);

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

    return widget.from == "search_screen" && Features.ismultivendor?
    widget.searchstoredata!.type == "1" ? VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context,GroceStore store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          stepperButtons.clear();
          if (widget.searchstoredata!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize!,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe")  stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize!,
                  from_screen: "search_screen",
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.searchstoredata!.id,
                              "itemname": widget.searchstoredata!.itemName,
                              "itemimg": widget.searchstoredata!.itemFeaturedImage,
                              "varname": /*widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!*/widget.searchstoredata!.itemName,
                              "varmrp":widget.searchstoredata!.mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.searchstoredata!.membershipPrice.toString()
                                  :widget.searchstoredata!.discointDisplay! ?widget.searchstoredata!.price.toString()
                                  :widget.searchstoredata!.mrp.toString(),
                              "paymentMode": widget.searchstoredata!.paymentMode,
                              "cronTime": widget.searchstoredata!.subscriptionSlot![0].cronTime,
                              "name": widget.searchstoredata!.subscriptionSlot![0].name,
                              "varid":widget.searchstoredata!.id,
                              "brand": widget.searchstoredata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {
                print("add 1........");
                if (box
                    .where((element) => element.itemId == widget.searchstoredata!.id && element.type == widget.searchstoredata!.type)
                    .length <= 0 || double.parse(box
                    .where((element) => element.itemId == widget.searchstoredata!.id)
                    .first
                    .weight!) <= 0){
                  print("add 1........if");
                  stepperButtons.add(AddItemSteppr(
                      context, fontSize: widget.fontSize!,
                      alignmnt: widget.alignmnt,
                      onTap: () {
                        if (widget.addon == null) {
                          addToCart("", "", "0", "", "0", []);
                        } else {
                          // addToCart("", "", "0","","0");
                          addToppingsProduct.clear();
                          addToppingsProduct.add({
                            "Toppings_type": "",
                            "varId":  (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,
                            "toppings": "0",
                            "parent_id": "",
                            "newproduct": "0",
                            "productid":widget.itemdata!.id
                          });
                          debugPrint("add Toppings product..." +
                              addToppingsProduct.toString());
                          dialogforToppings(context);
                        }
                        // addToCart();
                      },
                      isloading: loading));}
                else {
                  print("add 1........else");
                  int quantity = 0;
                  double weight = 0.0;
                  //  if(box.where((element) => element.itemId == widget.itemdata!.id).count() >= 1){
                  for (int i = 0; i < box.length; i++) {
                    if (box[i].itemId == widget.searchstoredata!.id &&
                        box[i].toppings == "0") {
                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }
                  }

                  stepperButtons.add(
                      UpdateItemSteppr(context,
                          quantity: (box.where((element) => element.itemId ==
                              widget.searchstoredata!.id && element.toppings == "0")
                              .count() > 1) ?
                          quantity
                              : (widget.addon != null) ? (box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .length * int.parse(box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .quantity!)) : int.parse(box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .quantity!),
                          weight: (box.where((element) =>
                          element.itemId == widget.searchstoredata!.id &&
                              element.toppings == "0")
                              .count() > 1) ?
                          weight
                              : (widget.addon != null) ?
                          /*double.parse((box.where((element) => element.itemId == widget.itemdata!.id).map((e) => e.weight).count() *  double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!)).toString())*/totalWeight()
                              : double.parse(box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .weight!),
                          fontSize: widget.fontSize!,
                          skutype: box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .type!,
                          unit: widget.searchstoredata!.unit ?? "kg",
                          onTap: (cartStatus) {
                            if (cartStatus == CartStatus.increment) {
                              if (widget.addon == null) {
                                print("here......1");
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.searchstoredata!.id!,
                                  productBox.last.id!,
                                  "0",
                                  "",);
                              }
                              else {
                                dialogforUpdateToppings(context);
                              }
                            } else {
                              if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                                dialogforDeleteToppings(context);
                              }else {
                                print("here......2");
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.searchstoredata!.id!,
                                  productBox.last.id!,
                                  "0",
                                  "",);
                              }
                            }
                          },
                          alignmnt: widget.alignmnt,
                          isloading: loading));
                }
              }

            }
            else {
              print("add 2........");
              if (box
                  .where((element) => element.itemId == widget.searchstoredata!.id && element.type == widget.searchstoredata!.type )
                  .length <= 0 || int.parse(box
                  .where((element) => element.itemId == widget.searchstoredata!.id)
                  .first
                  .quantity!) <= 0)
                stepperButtons.add(AddItemSteppr(
                    context, fontSize: widget.fontSize!,
                    alignmnt: widget.alignmnt,
                    onTap: () {
                      //addToCart();
                      if (widget.addon == null) {
                        addToCart("", "", "0", "", "0",[]);
                      } else {
                        //addToCart("", "", "0", "", "0");
                        addToppingsProduct.clear();
                        addToppingsProduct.add({"Toppings_type":"","varId":   (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,"toppings":"0", "parent_id":  "","newproduct":"0","productid":widget.itemdata!.id});
                        debugPrint("add Toppings product..."+addToppingsProduct.toString());
                        dialogforToppings(context);
                      }
                    },
                    isloading: loading));
              else
              {
                print("add 2........else");

                debugPrint("gh....2.."+(box.where((element) => element.itemId == widget.searchstoredata!.id).count().toString()));
                int quantity = 0;
                double weight = 0.0;
                if(box.where((element) => element.itemId == widget.searchstoredata!.id).count() >= 1){
                  for( int i = 0;i < box.length ;i++){
                    if(box[i].itemId == widget.searchstoredata!.id && box[i].toppings =="0"){
                      debugPrint("true...1");
                      /* quantity = quantity +  int.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .quantity!);*/
                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }

                  }
                }
                debugPrint("weight....2.."+weight.toString());

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity: (box.where((element) => element.itemId == widget.searchstoredata!.id && element.toppings == "0").count() > 1
                    )?
                    quantity
                        :(widget.addon != null)?(box.where((element) => element.itemId == widget.searchstoredata!.id).length * int.parse(box
                        .where((element) =>
                    element.itemId == widget.searchstoredata!.id)
                        .first
                        .quantity!)):int.parse(box
                        .where((element) =>
                    element.itemId == widget.searchstoredata!.id)
                        .first
                        .quantity!),

                        weight: (box.where((element) => element.itemId == widget.searchstoredata!.id && element.toppings == "0").count() >= 1
                            /* && box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/)?
                        weight
                            : (widget.addon != null)?/*double.parse((box.where((element) => element.itemId == widget.itemdata!.id).count()
                                * double.parse(box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .weight!)).toString())*/totalWeight():
                        double.parse(box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .weight!)/*weight*/,

                        fontSize: widget.fontSize!,
                        skutype: box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .type!,
                        unit: widget.searchstoredata!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {
                            if (widget.addon == null) {
                              print("here......3");
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.searchstoredata!.id!,
                                productBox.last.id!,
                                "0",
                                "",);
                            }
                            else
                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              print("here......4");
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.searchstoredata!.id!,
                                productBox.last.id!,
                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }


              stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize!,
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        /*      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand
                            });*/
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        })
        :
    VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context,GroceStore store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          stepperButtons.clear();
          if (widget.priceVariationSearch!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize!,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe") stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize!,
                  from_screen: "search_screen",
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.searchstoredata!.id,
                              "itemname": widget.searchstoredata!.itemName,
                              "itemimg": widget.searchstoredata!.itemFeaturedImage,
                              "varname": widget.searchstoredata!.priceVariation![0].variationName !+ widget.searchstoredata!.priceVariation![0].unit!,
                              "varmrp":widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.searchstoredata!.priceVariation![0].membershipPrice.toString()
                                  :widget.searchstoredata!.priceVariation![0].discointDisplay! ?widget.searchstoredata!.priceVariation![0].price.toString()
                                  :widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.searchstoredata!.paymentMode,
                              "cronTime": widget.searchstoredata!.subscriptionSlot![0].cronTime,
                              "name": widget.searchstoredata!.subscriptionSlot![0].name,
                              "varid":widget.searchstoredata!.priceVariation![0].id,
                              "brand": widget.searchstoredata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {
                print("add 3........");
                if (box
                    .where((element) =>
                element.varId == widget.priceVariationSearch!.id)
                    .length <= 0 || int.parse(box
                    .where((element) =>
                element.varId == widget.priceVariationSearch!.id).first
                    .quantity!) <= 0){
                  print("add 3........if");
                  stepperButtons.add(AddItemSteppr(
                      context, fontSize: widget.fontSize!,
                      alignmnt: widget.alignmnt,
                      onTap: () {
                        //  addToCart();
                        if (widget.addon == null) {
                          addToCart("", "", "0", "", "0", []);
                        } else {
                          //addToCart("", "", "0","","0");
                          addToppingsProduct.clear();
                          addToppingsProduct.add({
                            "Toppings_type": "",
                            "varId":  (widget.searchstoredata!.type! =="1")?"":widget.priceVariationSearch!.id!,
                            "toppings": "0",
                            "parent_id": "",
                            "newproduct": "0",
                            "productid":widget.searchstoredata!.id
                          });
                          debugPrint("add Toppings product..." +
                              addToppingsProduct.toString());
                          dialogforToppings(context);
                        }
                      },
                      isloading: loading));}
                else {
                  print("add 3........else");
                  debugPrint("gh....3.." +
                      (box.where((element) => element.varId ==
                          widget.priceVariationSearch!.id)
                          .count()
                          .toString()));
                  int quantity = 0;
                  double weight = 0.0;

                  for (int i = 0; i < box.length; i++) {
                    debugPrint("sss....");
                    if (box[i].varId == widget.priceVariationSearch!.id &&
                        box[i].toppings == "0") {
                      debugPrint("true...1");

                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }
                  }

                  stepperButtons.add(
                      UpdateItemSteppr(context,
                          quantity: (box.where((element) => element.varId ==
                              widget.priceVariationSearch!.id &&
                              element.toppings == "1")).count() >= 1 ?
                          quantity
                              : (widget.addon != null) ? /*(box.where((element) => element.varId == widget.priceVariation!.id).length * int.parse(box
                          .where((element) =>
                      element.varId == widget.priceVariation!.id)
                          .first
                          .quantity!))*/totalquantity()
                              : int.parse(box
                              .where((element) =>
                          element.varId == widget.priceVariationSearch!.id)
                              .first
                              .quantity!),
                          weight: ((box.where((element) =>
                          element.itemId == widget.searchstoredata!.id &&
                              element.toppings == "0")
                              .count()) > 1
                              /*&& box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/)
                              ?
                          weight
                              : (widget.addon != null) ? double.parse(
                              (box.where((element) =>
                              element.itemId == widget.searchstoredata!.id).count() *
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!)).toString()) : double.parse(
                              box
                                  .where((element) =>
                              element.itemId == widget.searchstoredata!.id)
                                  .first
                                  .weight!),
                          fontSize: widget.fontSize!,
                          skutype: box
                              .where((element) =>
                          element.varId == widget.priceVariationSearch!.id)
                              .first
                              .type!,
                          unit: widget.priceVariationSearch!.unit!,
                          onTap: (cartStatus) {
                            if (cartStatus == CartStatus.increment) {
                              if (widget.addon == null) {
                                print("here......5");
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.varId ==
                                      widget.priceVariationSearch!.id)
                                      .first
                                      .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.priceVariationSearch!.id!,
                                  productBox.last.id!,
                                  "0",
                                  "",);
                              }
                              else
                                dialogforUpdateToppings(context);
                            } else {
                              if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                                dialogforDeleteToppings(context);
                              }else {
                                print("here......6");
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.varId ==
                                      widget.priceVariationSearch!.id)
                                      .first
                                      .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.priceVariationSearch!.id!,
                                  productBox.last.id!,
                                  "0",
                                  "",);
                              }
                            }
                          },
                          alignmnt: widget.alignmnt,
                          isloading: loading));
                }
              }
            }
            else{
              print("add 4........");
              if (box.where((element) => element.varId == widget.priceVariationSearch!.id).length <= 0 || int.parse(box.where((element) => element.varId == widget.priceVariationSearch!.id).first.quantity!) <= 0)
               {
                 print("add 4........if");
                 stepperButtons.add(AddItemSteppr(
                    context, fontSize: widget.fontSize!,alignmnt: widget.alignmnt,onTap: () {
                  // addToCart();
                  if(widget.addon == null) {
                    addToCart("", "", "0","","0",[]);
                  }else {
                    // addToCart("", "", "0","","0");
                    addToppingsProduct.clear();
                    addToppingsProduct.add({"Toppings_type":"","varId":   (widget.searchstoredata!.type! =="1")?"":widget.priceVariationSearch!.id!,"toppings":"0", "parent_id":  "","newproduct":"0","productid":widget.itemdata!.id});
                    debugPrint("add Toppings product..."+addToppingsProduct.toString());
                    dialogforToppings(context);
                  }
                },isloading: loading));}
              else {
                print("add 4........else");
                debugPrint("gh....4.."+(box.where((element) => element.varId == widget.priceVariationSearch!.id).count().toString()));
                int quantity = 0;
                double weight = 0.0;

                for( int i = 0;i < box.length ;i++){
                  if(box[i].varId == widget.priceVariationSearch!.id && box[i].toppings =="0") {
                    debugPrint("true...1");

                    quantity = quantity + int.parse(box[i].quantity!);
                    weight = weight + double.parse(box
                        .where((element) =>
                    element.itemId == widget.priceVariationSearch!.id)
                        .first
                        .weight!);
                  }

                }

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity:  (box.where((element) =>  element.varId == widget.priceVariationSearch!.id && element.toppings == "1")).count() >= 1?
                    quantity
                        :(widget.addon != null)?/*(box.where((element) => element.varId == widget.priceVariation!.id).length * int.parse(box
                          .where((element) =>
                      element.varId == widget.priceVariation!.id)
                          .first
                          .quantity!))*/totalquantity():int.parse(box
                        .where((element) =>
                    element.varId == widget.priceVariationSearch!.id)
                        .first
                        .quantity!),
                        weight: (box.where((element) => element.itemId == widget.searchstoredata!.id && element.toppings == "0").count()> 1
                            /*&& box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/) ?
                        weight
                            :(widget.addon != null)?double.parse((box.where((element) => element.itemId == widget.searchstoredata!.id).count() *  double.parse(box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .weight!)).toString()): double.parse(box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .weight!),
                        fontSize: widget.fontSize!,
                        skutype: box
                            .where((element) =>
                        element.varId == widget.priceVariationSearch!.id)
                            .first
                            .type!,
                        unit: widget.priceVariationSearch!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {
                            if (widget.addon == null) {
                              print("here......7");
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.varId == widget.priceVariationSearch!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariationSearch!.id!,
                                productBox.last.id!,
                                "0",
                                "",);
                            }
                            else
                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              print("here......8");
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.varId ==
                                    widget.priceVariationSearch!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariationSearch!.id!,
                                productBox.last.id!,
                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }

              stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize!,
                  from_screen: "search_screen",
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.searchstoredata!.id,
                              "itemname": widget.searchstoredata!.itemName,
                              "itemimg": widget.searchstoredata!.itemFeaturedImage,
                              "varname": widget.searchstoredata!.priceVariation![0].variationName !+ widget.searchstoredata!.priceVariation![0].unit!,
                              "varmrp":widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.searchstoredata!.priceVariation![0].membershipPrice.toString()
                                  :widget.searchstoredata!.priceVariation![0].discointDisplay! ?widget.searchstoredata!.priceVariation![0].price.toString()
                                  :widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.searchstoredata!.paymentMode,
                              "cronTime": widget.searchstoredata!.subscriptionSlot![0].cronTime,
                              "name": widget.searchstoredata!.subscriptionSlot![0].name,
                              "varid":widget.searchstoredata!.priceVariation![0].id,
                              "brand": widget.searchstoredata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                            });
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        })
        :
      widget.itemdata!.type == "1" ? Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: VxBuilder(
            mutations: {SetCartItem},
            // valueListenable: Hive.box<Product>(productBoxName).listenable(),
            builder: (context,GroceStore store, index) {
              final box = (VxState.store as GroceStore).CartItemList;
              // if(loading){
              //   print("inside loading");
              //   stepperButtons.clear();
              //stepperButtons.add(Loading(context));
              // stepperButtons.add(Expanded(
              //     flex: 1,
              //     child: SizedBox.shrink())) ;
              // }else{
              stepperButtons.clear();
              if (widget.itemdata!.stock! <= 0){
                if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                    context, alignmnt: widget.alignmnt,
                    fontsize: widget.fontSize!,
                    onTap: () {

                      if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                        LoginWeb(context,result: (sucsess){
                          if(sucsess){
                            Navigator.of(context).pop();
                            Navigation(context, navigatore: NavigatoreTyp.homenav);
                            /* Navigator.pushNamedAndRemoveUntil(
                              context, HomeScreen.routeName, (route) => false);*/
                          }else{
                            Navigator.of(context).pop();
                          }
                        });
                      }
                      else{
                        if (!PrefUtils.prefs!.containsKey("apikey")) {
                          Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                        }
                        else {
                          _notifyMe();
                        }
                      }
                    }, isnotify: _isNotify));
              }
              else{
                print("ellide..." + widget.issubscription.toString() + "...." + widget.itemdata!.itemName!);
                if(widget.alignmnt == StepperAlignment.Vertical) {
                  if(widget.issubscription == "Subscribe")  stepperButtons.add(AddSubsciptionStepper(
                      context, itemdata: widget.itemdata!,
                      alignmnt: widget.alignmnt,
                      fontsize: widget.fontSize!,
                      onTap: () {

                        if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                          LoginWeb(context,result: (sucsess){
                            if(sucsess){
                              Navigator.of(context).pop();
                              Navigation(context, navigatore: NavigatoreTyp.homenav);
                              /* Navigator.pushNamedAndRemoveUntil(
                              context, HomeScreen.routeName, (route) => false);*/
                            }else{
                              Navigator.of(context).pop();
                            }
                          });
                        }
                        else{
                          if (!PrefUtils.prefs!.containsKey("apikey")) {
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                          }
                          else {
                            Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                                qparms: {
                                  "itemid": widget.itemdata!.id,
                                  "itemname": widget.itemdata!.itemName,
                                  "itemimg": widget.itemdata!.itemFeaturedImage,
                                  "varname": /*widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!*/widget.itemdata!.itemName,
                                  "varmrp":widget.itemdata!.mrp.toString(),
                                  "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.membershipPrice.toString()
                                      :widget.itemdata!.discointDisplay! ?widget.itemdata!.price.toString()
                                      :widget.itemdata!.mrp.toString(),
                                  "paymentMode": widget.itemdata!.paymentMode,
                                  "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                  "name": widget.itemdata!.subscriptionSlot![0].name,
                                  "varid":widget.itemdata!.id,
                                  "brand": widget.itemdata!.brand,
                                  "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                                  "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                                  "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                                  "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                                  "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                                  "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                                  "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                                  "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                                  "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                                });
                          }
                        }


                      }));
                  if(widget.issubscription == "Add") {
                    print("add 5........if");
                    if (box.where((element) => element.itemId == widget.itemdata!.id && element.type == widget.itemdata!.type).length <= 0 ||
                        double.parse(box.where((element) => element.itemId == widget.itemdata!.id).first.weight!) <= 0)
                      stepperButtons.add(AddItemSteppr(
                          context, fontSize: widget.fontSize!,
                          alignmnt: widget.alignmnt,
                          onTap: () {
                            if (widget.addon == null) {
                              addToCart("", "", "0", "", "0", []);
                            } else {
                              // addToCart("", "", "0","","0");
                              addToppingsProduct.clear();
                              addToppingsProduct.add({
                                "Toppings_type": "",
                                "varId":  (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,
                                "toppings": "0",
                                "parent_id": "",
                                "newproduct": "0",
                                "productid":widget.itemdata!.id
                              });
                              debugPrint("add Toppings product..." +
                                  addToppingsProduct.toString());
                              dialogforToppings(context);
                            }
                            // addToCart();
                          },
                          isloading: loading));
                    else {
                      print("add 5........else");
                      debugPrint("gh....1.." +
                          (box.where((element) => element.itemId ==
                              widget.itemdata!.id).count().toString()));

                      int quantity = 0;
                      double weight = 0.0;
                      //  if(box.where((element) => element.itemId == widget.itemdata!.id).count() >= 1){
                      for (int i = 0; i < box.length; i++) {
                        debugPrint("ttttt....." + box[i].itemId! + "  " +
                            widget.itemdata!.id! + "  " + box[i].toppings! + "   " +
                            box.length.toString());
                        if (box[i].itemId == widget.itemdata!.id &&
                            box[i].toppings == "0") {
                          debugPrint("true...1" + quantity.toString() + "..." +
                              box[i].quantity!.toString());

                          quantity = quantity + int.parse(box[i].quantity!);
                          weight = weight + double.parse(box[i].weight!);
                        }
                      }

                      if(VxState.store.userData.membership! == "1"){
                        widget.checkmembership = true;
                      } else {
                        widget.checkmembership = false;
                        for (int i = 0; i < productBox.length; i++) {
                          if (productBox[i].mode == "1") {
                            widget.checkmembership = true;
                          }
                        }
                      }
                      debugPrint("C......" + weight.toString() + "   " +
                          (box.where((element) => element.itemId ==
                              widget.itemdata!.id && element.toppings == "0")
                              .count()
                              .toString()) + "..." +
                          (box.where((element) => element.itemId ==
                              widget.itemdata!.id).map((e) =>
                          e.quantity).count().toString()));

                      stepperButtons.add(
                          UpdateItemSteppr(context,
                              quantity: (box.where((element) => element.itemId ==
                                  widget.itemdata!.id && element.toppings == "0")
                                  .count() > 1) ?
                              quantity
                                  : (widget.addon != null) ? (box
                                  .where((element) =>
                              element.itemId == widget.itemdata!.id)
                                  .length * int.parse(box
                                  .where((element) =>
                              element.itemId == widget.itemdata!.id)
                                  .first
                                  .quantity!)) : int.parse(box
                                  .where((element) =>
                              element.itemId == widget.itemdata!.id)
                                  .first
                                  .quantity!),


                              weight: (box.where((element) =>
                              element.itemId == widget.itemdata!.id &&
                                  element.toppings == "1")
                                  .count() >= 1) ?
                              weight
                                  : (widget.addon != null) ?
                              totalWeight()
                                  : double.parse(box
                                  .where((element) =>
                              element.itemId == widget.itemdata!.id)
                                  .first
                                  .weight!),
                              fontSize: widget.fontSize!,
                              skutype: box
                                  .where((element) =>
                              element.itemId == widget.itemdata!.id)
                                  .first
                                  .type!,
                              unit: widget.itemdata!.unit ?? "kg",
                              maxItem: widget.itemdata!.maxItem,
                              minItem: widget.itemdata!.minItem,
                              count: widget.itemdata!.increament,
                              price: widget.checkmembership!?widget.itemdata!.membershipDisplay!?double.parse(widget.itemdata!.membershipPrice!):double.parse(widget.itemdata!.price!):double.parse(widget.itemdata!.price!),
                              varid: widget.itemdata!.id,
                              incvalue: widget.itemdata!.increament,
                              Cart_id: box.last.parent_id,

                              onTap: (cartStatus) {
                                if (cartStatus == CartStatus.increment) {
                                  if (widget.addon == null) {
                                    print("here......9");
                                    updateCart(
                                        int.parse(box
                                            .where((element) =>
                                        element.itemId == widget.itemdata!.id)
                                            .first
                                            .quantity!),
                                        double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.itemdata!.id)
                                            .first
                                            .weight!),
                                        cartStatus,
                                        widget.itemdata!.id!,
                                        productBox.last.id!,
                                        "0",
                                        "",);
                                  }
                                  else {
                                    dialogforUpdateToppings(context);
                                  }
                                } else {
                                  if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                                    dialogforDeleteToppings(context);
                                  }else {
                                    print("here......10");
                                    updateCart(
                                      int.parse(box
                                          .where((element) =>
                                      element.itemId == widget.itemdata!.id)
                                          .first
                                          .quantity!),

                                      double.parse(box
                                          .where((element) =>
                                      element.itemId == widget.itemdata!.id)
                                          .first
                                          .weight!),

                                      cartStatus,
                                      widget.itemdata!.id!,
                                      Features.btobModule || widget.itemdata!.type! =="1" ?
                                      box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                          : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                      "0",
                                      "",);
                                  }
                                }
                              },
                              alignmnt: widget.alignmnt,
                              isloading: loading));
                    }
                  }

                }
                else {
                  print("add 5........if");
                  if (box
                      .where((element) => element.itemId == widget.itemdata!.id && element.type == widget.itemdata!.type)
                      .length <= 0 || int.parse(box
                      .where((element) => element.itemId == widget.itemdata!.id)
                      .first
                      .quantity!) <= 0) {
                    print("add 5........if");
                    stepperButtons.add(AddItemSteppr(
                        context, fontSize: widget.fontSize!,
                        alignmnt: widget.alignmnt,
                        onTap: () {
                          //addToCart();
                          if (widget.addon == null) {
                            addToCart("", "", "0", "", "0", []);
                          } else {
                            //addToCart("", "", "0", "", "0");
                            addToppingsProduct.clear();
                            addToppingsProduct.add(
                                {
                                  "Toppings_type": "",
                                  "varId": (widget.itemdata!.type! == "1")
                                      ? ""
                                      : widget.priceVariation!.id!,
                                  "toppings": "0",
                                  "parent_id": "",
                                  "newproduct": "0",
                                  "productid": widget.itemdata!.id
                                });
                            debugPrint("add Toppings product..." +
                                addToppingsProduct.toString());
                            dialogforToppings(context);
                          }
                        },
                        isloading: loading));
                  }
                  else
                  {
                    print("add 5........else");
                    debugPrint("d......");
                    int quantity = 0;
                    double weight = 0.0;
                    if(box.where((element) => element.itemId == widget.itemdata!.id).count() >= 1){
                      for( int i = 0;i < box.length ;i++){
                        if(box[i].itemId == widget.itemdata!.id && box[i].toppings =="0"){
                          debugPrint("true...1");
                          /* quantity = quantity +  int.parse(box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .quantity!);*/
                          quantity = quantity + int.parse(box[i].quantity!);
                          weight = weight + double.parse(box[i].weight!);
                        }

                      }
                    }
                    debugPrint("weight....2.."+weight.toString());

                    stepperButtons.add(
                        UpdateItemSteppr(context, quantity: (box.where((element) => element.itemId == widget.itemdata!.id && element.toppings == "0").count() > 1
                        )?
                        quantity
                            :(widget.addon != null)?(box.where((element) => element.itemId == widget.itemdata!.id).length * int.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .quantity!)):int.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .quantity!),

                            weight: (box.where((element) => element.itemId == widget.itemdata!.id && element.toppings == "1").count() >= 1
                                /* && box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/)?
                            weight
                                : (widget.addon != null)?/*double.parse((box.where((element) => element.itemId == widget.itemdata!.id).count()
                                    * double.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!)).toString())*/totalWeight():
                            double.parse(box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .weight!)/*weight*/,

                            fontSize: widget.fontSize!,
                            skutype: box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .type!,
                            unit: widget.itemdata!.unit!,
                            onTap: (cartStatus) {
                              if (cartStatus == CartStatus.increment) {
                                if (widget.addon == null) {
                                  print("here......11");
                                  updateCart(
                                    int.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .quantity!),
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!),
                                    cartStatus,
                                    widget.itemdata!.id!,
                                    Features.btobModule || widget.itemdata!.type! =="1" ?
                                    box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                        : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                    "0",
                                    "",);
                                }
                                else
                                  dialogforUpdateToppings(context);
                              } else {
                                if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                                  dialogforDeleteToppings(context);
                                }else {
                                  print("here......12");
                                  updateCart(
                                    int.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .quantity!),
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!),
                                    cartStatus,
                                    widget.itemdata!.id!,
                                    Features.btobModule || widget.itemdata!.type! =="1" ?
                                    box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                        : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                    "0",
                                    "",);
                                }
                              }
                            },
                            alignmnt: widget.alignmnt,
                            isloading: loading));
                  }


                  stepperButtons.add(AddSubsciptionStepper(
                      context, itemdata: widget.itemdata!,
                      alignmnt: widget.alignmnt,
                      fontsize: widget.fontSize!,
                      onTap: () {
                        if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                          LoginWeb(context,result: (sucsess){
                            if(sucsess){
                              Navigator.of(context).pop();
                              Navigation(context, navigatore: NavigatoreTyp.homenav);
                              /* Navigator.pushNamedAndRemoveUntil(
                              context, HomeScreen.routeName, (route) => false);*/
                            }else{
                              Navigator.of(context).pop();
                            }
                          });
                        }
                        else{
                          if (!PrefUtils.prefs!.containsKey("apikey")) {
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                          }
                          else {
                            /*      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                                qparms: {
                                  "itemid": widget.itemdata!.id,
                                  "itemname": widget.itemdata!.itemName,
                                  "itemimg": widget.itemdata!.itemFeaturedImage,
                                  "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                                  "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                                  "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                      :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                      :widget.itemdata!.priceVariation![0].mrp.toString(),
                                  "paymentMode": widget.itemdata!.paymentMode,
                                  "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                                  "name": widget.itemdata!.subscriptionSlot![0].name,
                                  "varid":widget.itemdata!.priceVariation![0].id,
                                  "brand": widget.itemdata!.brand
                                });*/
                          }
                        }


                      }));
                }

              }
              //}
              print("height"+widget.height.toString());
              return widget.alignmnt == StepperAlignment.Vertical
                  ? SizedBox(
                //height: widget.priceVariation!.stock!<=0?33:widget.height,
                  height: widget.height,
                  width: widget.width,
                  child:Column(
                    children: stepperButtons,
                  ))
                  : Container(
                  height: widget.height,
                  width: widget.width,
                  child:
                  Row(
                    children: stepperButtons,

                  ));
            }),
        ),
      ):
    VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context,GroceStore store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          print("height 1........"+widget.height.toString());
          stepperButtons.clear();
          if (widget.priceVariation!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize!,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe") stepperButtons.add(AddSubsciptionStepper(
                  context, itemdata: widget.itemdata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize!,
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {
                print("add 6........if");

                if(Features.btobModule){
                  if (box
                      .where((element) =>
                  element.itemId == widget.itemdata!.id &&
                      element.type == widget.itemdata!.type)
                      .length <= 0 ||
                      int.parse(box
                          .where((element) =>
                      element.itemId == widget.itemdata!.id)
                          .first
                          .quantity!) <= 0) {
                    //print("var 6....."+widget.priceVariation!.id.toString()+"price var cart..."+(box.where((element) => element.varId == widget.priceVariation!.id).first.quantity!).toString());
                    print(
                        "inside if...." + "...." + widget.itemdata!.itemName!);
                    print("add 6........if");
                    stepperButtons.add(AddItemSteppr(
                        context, fontSize: widget.fontSize!,
                        alignmnt: widget.alignmnt,
                        onTap: () {
                          //  addToCart();
                          if (widget.addon == null) {
                            addToCart("", "", "0", "", "0", []);
                          } else {
                            //addToCart("", "", "0","","0");
                            addToppingsProduct.clear();
                            addToppingsProduct.add({
                              "Toppings_type": "",
                              "varId": (widget.itemdata!.type! == "1")
                                  ? ""
                                  : widget.priceVariation!.id!,
                              "toppings": "0",
                              "parent_id": "",
                              "newproduct": "0",
                              "productid": widget.itemdata!.id
                            });
                            debugPrint("add Toppings product..." +
                                addToppingsProduct.toString());
                            dialogforToppings(context);
                          }
                        },
                        isloading: loading));
                  }
                  else {
                    print("add 6........else");
                    print(
                        "inside if....1" + "...." + widget.itemdata!.itemName!);
                    debugPrint("gh....3.." +
                        (box.where((element) =>
                        element.itemId ==
                            widget.itemdata!.id)
                            .count()
                            .toString()));
                    int quantity = 0;
                    double weight = 0.0;

                    for (int i = 0; i < box.length; i++) {
                      debugPrint("sss....");
                      if (box[i].varId == widget.priceVariation!.id &&
                          box[i].toppings == "0") {
                        debugPrint("true...1");

                        quantity = quantity + int.parse(box[i].quantity!);
                        weight = weight + double.parse(box[i].weight!);
                      }
                    }

                    stepperButtons.add(
                        UpdateItemSteppr(context,
                            quantity: (box.where((element) =>
                            element.itemId ==
                                widget.itemdata!.id &&
                                element.toppings == "1")).count() >= 1 ?
                            quantity
                                : (widget.addon != null) ? totalquantity()
                                : int.parse(box
                                .where((element) =>
                            element.itemId ==
                                widget.itemdata!.id)
                                .first
                                .quantity!),

                            weight: ((box.where((element) =>
                            element.itemId == widget.itemdata!.id &&
                                element.toppings == "0")
                                .count()) > 1)
                                ?
                            weight
                                : (widget.addon != null) ? double.parse(
                                (box.where((element) =>
                                element.itemId == widget.itemdata!.id).count() *
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!)).toString()) : double.parse(
                                box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                            fontSize: widget.fontSize!,
                            skutype: box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .type!,
                            unit: widget.priceVariation!.unit!,
                            onTap: (cartStatus) {
                              if (cartStatus == CartStatus.increment) {
                                if (widget.addon == null) {
                                  print("here......13.." + productBox.last.id!);
                                  updateCart(
                                    int.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .quantity!),
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!),
                                    cartStatus,
                                    widget.priceVariation!.id!,
                                    Features.btobModule ||
                                        widget.itemdata!.type! == "1" ?
                                    box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .parent_id!
                                        : box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .parent_id!,
                                    "0",
                                    "",);
                                }
                                else
                                  dialogforUpdateToppings(context);
                              } else {
                                if (box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .length > 1) {
                                  dialogforDeleteToppings(context);
                                } else {
                                  print("here......14.." + productBox.last.id!);
                                  updateCart(
                                    int.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .quantity!),
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!),
                                    cartStatus,
                                    widget.priceVariation!.id!,
                                    Features.btobModule ||
                                        widget.itemdata!.type! == "1" ?
                                    box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .parent_id!
                                        : box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .parent_id!,
                                    "0",
                                    "",);
                                }
                              }
                            },
                            alignmnt: widget.alignmnt,
                            isloading: loading));
                  }
                }
                else {
                  if (box
                      .where((element) =>
                  element.varId == widget.priceVariation!.id &&
                      element.type == widget.itemdata!.type)
                      .length <= 0 ||
                      int.parse(box
                          .where((element) =>
                      element.varId == widget.priceVariation!.id)
                          .first
                          .quantity!) <= 0) {
                    //print("var 6....."+widget.priceVariation!.id.toString()+"price var cart..."+(box.where((element) => element.varId == widget.priceVariation!.id).first.quantity!).toString());
                    print(
                        "inside if...." + "...." + widget.itemdata!.itemName!);
                    print("add 6........if");
                    stepperButtons.add(AddItemSteppr(
                        context, fontSize: widget.fontSize!,
                        alignmnt: widget.alignmnt,
                        onTap: () {
                          //  addToCart();
                          if (widget.addon == null) {
                            addToCart("", "", "0", "", "0", []);
                          } else {
                            //addToCart("", "", "0","","0");
                            addToppingsProduct.clear();
                            addToppingsProduct.add({
                              "Toppings_type": "",
                              "varId": (widget.itemdata!.type! == "1")
                                  ? ""
                                  : widget.priceVariation!.id!,
                              "toppings": "0",
                              "parent_id": "",
                              "newproduct": "0",
                              "productid": widget.itemdata!.id
                            });
                            debugPrint("add Toppings product..." +
                                addToppingsProduct.toString());
                            dialogforToppings(context);
                          }
                        },
                        isloading: loading));
                  }
                  else {
                    print("add 6........else");
                    print(
                        "inside if....1" + "...." + widget.itemdata!.itemName!);
                    debugPrint("gh....3.." +
                        (box.where((element) =>
                        element.varId ==
                            widget.priceVariation!.id)
                            .count()
                            .toString()));
                    int quantity = 0;
                    double weight = 0.0;

                    for (int i = 0; i < box.length; i++) {
                      debugPrint("sss....");
                      if (box[i].varId == widget.priceVariation!.id &&
                          box[i].toppings == "0") {
                        debugPrint("true...1");

                        quantity = quantity + int.parse(box[i].quantity!);
                        weight = weight + double.parse(box[i].weight!);
                      }
                    }

                    stepperButtons.add(
                        UpdateItemSteppr(context,
                            quantity: (box.where((element) =>
                            element.varId ==
                                widget.priceVariation!.id &&
                                element.toppings == "1")).count() >= 1 ?
                            quantity
                                : (widget.addon != null) ? totalquantity()
                                : int.parse(box
                                .where((element) =>
                            element.varId == widget.priceVariation!.id)
                                .first
                                .quantity!),

                            weight: ((box.where((element) =>
                            element.itemId == widget.itemdata!.id &&
                                element.toppings == "0")
                                .count()) > 1)
                                ?
                            weight
                                : (widget.addon != null) ? double.parse(
                                (box.where((element) =>
                                element.itemId == widget.itemdata!.id).count() *
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!)).toString()) : double.parse(
                                box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                            fontSize: widget.fontSize!,
                            skutype: box
                                .where((element) =>
                            element.varId == widget.priceVariation!.id)
                                .first
                                .type!,
                            unit: widget.priceVariation!.unit!,
                            onTap: (cartStatus) {
                              if (cartStatus == CartStatus.increment) {
                                if (widget.addon == null) {
                                  print("here......13.." + productBox.last.id!);
                                  updateCart(
                                    int.parse(box
                                        .where((element) =>
                                    element.varId == widget.priceVariation!.id)
                                        .first
                                        .quantity!),
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!),
                                    cartStatus,
                                    widget.priceVariation!.id!,
                                    Features.btobModule ||
                                        widget.itemdata!.type! == "1" ?
                                    box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .parent_id!
                                        : box
                                        .where((element) =>
                                    element.varId == widget.priceVariation!.id)
                                        .first
                                        .parent_id!,
                                    "0",
                                    "",);
                                }
                                else
                                  dialogforUpdateToppings(context);
                              } else {
                                if (box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .length > 1) {
                                  dialogforDeleteToppings(context);
                                } else {
                                  print("here......14.." + productBox.last.id!);
                                  updateCart(
                                    int.parse(box
                                        .where((element) =>
                                    element.varId == widget.priceVariation!.id)
                                        .first
                                        .quantity!),
                                    double.parse(box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .weight!),
                                    cartStatus,
                                    widget.priceVariation!.id!,
                                    Features.btobModule ||
                                        widget.itemdata!.type! == "1" ?
                                    box
                                        .where((element) =>
                                    element.itemId == widget.itemdata!.id)
                                        .first
                                        .parent_id!
                                        : box
                                        .where((element) =>
                                    element.varId == widget.priceVariation!.id)
                                        .first
                                        .parent_id!,
                                    "0",
                                    "",);
                                }
                              }
                            },
                            alignmnt: widget.alignmnt,
                            isloading: loading));
                  }
                }
              }
            }
            else{
              print("add 7........if");
              if (box.where((element) => element.varId == widget.priceVariation!.id).length <= 0 || int.parse(box.where((element) => element.varId == widget.priceVariation!.id).first.quantity!) <= 0)
                stepperButtons.add(AddItemSteppr(
                    context, fontSize: widget.fontSize!,alignmnt: widget.alignmnt,onTap: () {
                  // addToCart();
                  if(widget.addon == null) {
                    addToCart("", "", "0","","0",[]);
                  }else {
                    // addToCart("", "", "0","","0");
                    addToppingsProduct.clear();
                    addToppingsProduct.add({"Toppings_type":"","varId":   (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,"toppings":"0", "parent_id":  "","newproduct":"0","productid":widget.itemdata!.id});
                    debugPrint("add Toppings product..."+addToppingsProduct.toString());
                    dialogforToppings(context);
                  }
                },isloading: loading));
              else {
                print("add 7........else");
                debugPrint("gh....4.."+(box.where((element) => element.varId == widget.priceVariation!.id).count().toString()));
                int quantity = 0;
                double weight = 0.0;

                for( int i = 0;i < box.length ;i++){
                  if(box[i].varId == widget.priceVariation!.id && box[i].toppings =="0") {
                    debugPrint("true...1");

                    quantity = quantity + int.parse(box[i].quantity!);
                    weight = weight + double.parse(box
                        .where((element) =>
                    element.itemId == widget.itemdata!.id)
                        .first
                        .weight!);
                  }

                }

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity:  (box.where((element) =>  element.varId == widget.priceVariation!.id && element.toppings == "1")).count() >= 1?
                    quantity
                        :(widget.addon != null)?totalquantity()
                        :int.parse(box
                        .where((element) =>
                    element.varId == widget.priceVariation!.id)
                        .first
                        .quantity!),
                        weight: (box.where((element) => element.itemId == widget.itemdata!.id && element.toppings == "0").count()> 1) ?
                        weight
                            :(widget.addon != null)?double.parse((box.where((element) => element.itemId == widget.itemdata!.id).count() *  double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!)).toString()): double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!),
                        fontSize: widget.fontSize!,
                        skutype: box
                            .where((element) =>
                        element.varId == widget.priceVariation!.id)
                            .first
                            .type!,
                        unit: widget.priceVariation!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {
                            if (widget.addon == null) {
                              print("here......15");
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.varId == widget.priceVariation!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariation!.id!,
                                productBox.last.id!,
                                "0",
                                "",);
                            }
                            else
                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              print("here......16");
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.varId == widget.priceVariation!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariation!.id!,
                                productBox.last.id!,
                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }

              stepperButtons.add(AddSubsciptionStepper(
                  context, itemdata: widget.itemdata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize!,
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                            });
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        });
  }

  double totalWeight() {
    double totalWeight = 0.0;
    List<double> weight = [];
    weight.clear();
    (widget.from == "search_screen" && Features.ismultivendor)?
    debugPrint("weight..."+productBox.where((element) => element.itemId == widget.searchstoredata!.id).map((e) =>  double.parse(e.weight!)).toString()):
    debugPrint("weight..."+productBox.where((element) => element.itemId == widget.itemdata!.id).map((e) =>  double.parse(e.weight!)).toString());
    (widget.from == "search_screen" && Features.ismultivendor)?
    weight.addAll(productBox.where((element) => element.itemId == widget.searchstoredata!.id).map((e) =>  double.parse(e.weight!))):
    weight.addAll(productBox.where((element) => element.itemId == widget.itemdata!.id).map((e) =>  double.parse(e.weight!)));
    debugPrint("weight list...."+weight.toString());
    for(int i = 0;i<weight.length; i++){
      totalWeight = totalWeight + weight[i];
    }
    debugPrint("totalWeight...."+totalWeight.toString());
    return totalWeight;
  }

  int totalquantity() {
    int totalquantity = 0;
    List<int> Lisquantity = [];
    Lisquantity.clear();
    (widget.from == "search_screen" && Features.ismultivendor)?
    debugPrint("weight..."+productBox.where((element) => element.varId == widget.priceVariationSearch!.id).map((e) =>  int.parse(e.quantity!)).toString()):
    debugPrint("weight..."+productBox.where((element) => element.varId == widget.priceVariation!.id).map((e) =>  int.parse(e.quantity!)).toString());
    (widget.from == "search_screen" && Features.ismultivendor)?
    Lisquantity.addAll(productBox.where((element) => element.varId == widget.priceVariationSearch!.id).map((e) =>  int.parse(e.quantity!))):
    Lisquantity.addAll(productBox.where((element) => element.varId == widget.priceVariation!.id).map((e) =>  int.parse(e.quantity!)));
    debugPrint("quantity list...."+Lisquantity.toString());
    for(int i = 0;i< Lisquantity.length; i++){
      totalquantity = totalquantity + Lisquantity[i];
    }
    debugPrint("totalquantity...."+totalquantity.toString());
    return totalquantity;
  }

  bool compare(List<Map<String, dynamic>> toppindfrombackend, List addToppings) {
    bool ismapequal = true;
    addToppings.forEach((element) {
      if(!toppindfrombackend.contains(element)){
        ismapequal = false;
      }
    });
    debugPrint("ismapequal....."+ismapequal.toString());
    return ismapequal;
  }

}
Widget handler(bool? isSelected) {
  debugPrint("isselected..."+isSelected.toString());
  return (isSelected == true )  ?
  Container(
    width: 20.0,
    height: 20.0,
    decoration: BoxDecoration(
      color: ColorCodes.whiteColor,
      border: Border.all(
        color: ColorCodes.greenColor,
      ),
      shape: BoxShape.circle,
    ),
    child: Container(
      margin: EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color:ColorCodes.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check,
          color: ColorCodes.greenColor,
          size: 15.0),
    ),
  )
      :
  Icon(
      Icons.radio_button_off_outlined,
      color: ColorCodes.blackColor,
      size: 20.0
  );
}

Widget Loading(BuildContext context) {
  return  Container(
    decoration: BoxDecoration(color: (Features.isSubscription)? ColorCodes.whiteColor:ColorCodes.whiteColor,
      // border: Border(
      //   //right: BorderSide(width: 1.0, color: ColorCodes.darkgreen,),
      //   bottom: BorderSide(width: 1.0, color: ColorCodes.varcolor),
      //   top: BorderSide(width: 1.0, color: ColorCodes.varcolor),
      // ),
    ),
    height: 60,
    width:35,
    child: Center(
      child: SizedBox(
          width: 15.0,
          height: 15.0,
          child: new CircularProgressIndicator(
            color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.stepperColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
            strokeWidth: 2.0,
            valueColor: new AlwaysStoppedAnimation<Color>(/*Theme.of(context).primaryColor*/(Features.isSubscription)?IConstants.isEnterprise?ColorCodes.stepperColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
          )
      ),
    ),
  );
}

Widget AddItemSteppr(BuildContext context,{required double fontSize,required Function() onTap, required StepperAlignment alignmnt, isloading}) {
  debugPrint("testing..." + isloading.toString());
  return (Features.isSubscription)?
  Expanded(
    flex: 1,
    child: GestureDetector(
      onTap: ()=>onTap(),
      child: Padding(
        padding: EdgeInsets.only(/*left:alignmnt == StepperAlignment.Horizontal?10:0,*/bottom: alignmnt == StepperAlignment.Vertical?0:0),
        child: Container(
          margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?40:40:40.0,
          /* decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor,
              borderRadius:
              new BorderRadius
                  .all(
                const Radius.circular(
                    2.0),
              )),*/
          decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              border: Border.all(color: ColorCodes.darkgreen/*Theme
                  .of(context)
                  .primaryColor*/),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight:
                const Radius.circular(5),
                bottomLeft:
                const Radius.circular(5),
                bottomRight:
                const Radius.circular(5),
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isloading?
              /*CircularProgressIndicator(
                color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.whiteColor),
              )*/ Center(
                child: SizedBox(
                    width: 15.0,
                    height: 15.0,
                    child: new CircularProgressIndicator(
                      color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                      strokeWidth: 2.0,
                      valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.greenColor),
                    )
                ),
              )
                  : Row(
                children: [
                  Icon(Icons.add,color: ColorCodes.darkgreen,size: 18,),
                  SizedBox(width:2),
                  Text(
                    S.current.add,
                    style:
                    TextStyle(
                        color: ColorCodes.darkgreen,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold

                    ),

                    textAlign:
                    TextAlign
                        .center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  )
      :Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: ()=>onTap(),
        child: Padding(
          padding: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          child: Container(
            //width: MediaQuery.of(context).size.width / 2.9,
            height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:40.0,
            // margin:  EdgeInsets.symmetric(horizontal: 8),
            //padding: EdgeInsets.only(left:8),
            decoration: new BoxDecoration(
                color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                border: Border.all(color: ColorCodes.darkgreen/*Theme
                  .of(context)
                  .primaryColor*/),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(5),
                  topRight:
                  const Radius.circular(5),
                  bottomLeft:
                  const Radius.circular(5),
                  bottomRight:
                  const Radius.circular(5),
                )),
            child:
            isloading?
            /*CircularProgressIndicator(
                color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.whiteColor),
              )*/ Center(
              child: SizedBox(
                  width: 15.0,
                  height: 15.0,
                  child: new CircularProgressIndicator(
                    color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                    strokeWidth: 2.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.greenColor),
                  )
              ),
            )
                :Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add,color: ColorCodes.darkgreen,size: 20,),
                SizedBox(width:2),
                Text(
                  S.current.add,//'ADD',
                  style: TextStyle(
                      color: ColorCodes.darkgreen, /*Theme.of(context)
                          .buttonColor*/
                      fontSize: fontSize, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                // Spacer(),
                // Container(
                //   height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:40.0,
                //   width: 25,
                //   decoration: BoxDecoration(
                //     color:IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor,
                //
                //   ),
                //   child: Icon(
                //     Icons.add,
                //     size: 12,
                //     color: Colors.white,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      )
  );
}

Widget UpdateItemSteppr(BuildContext context,{required int quantity,required double weight,required double fontSize,required String skutype,required String unit,required Function(CartStatus) onTap,required StepperAlignment alignmnt,isloading,String? maxItem,String? minItem,String? count,double? price ,String? varid,String? incvalue, String? Cart_id }) {
  debugPrint("skutype..."+skutype+"..."+weight.toString()+"  "+quantity.toString()+"min.."+minItem.toString()+"max.."+maxItem.toString()+"count..."+count.toString());
  return  Expanded(
    flex: 1,
    child: Container(
      margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
        border: Border(
          right: BorderSide(width: 1.0, color: ColorCodes.varcolor,),
          left: BorderSide(width: 1.0, color: ColorCodes.varcolor,),
          bottom: BorderSide(width: 1.0, color: ColorCodes.varcolor),
          top: BorderSide(width: 1.0, color: ColorCodes.varcolor),
        ),),
      height: (Features.isSubscription)?60:30,
      padding: EdgeInsets.only(/*left:alignmnt == StepperAlignment.Horizontal?10:0,*/top:alignmnt == StepperAlignment.Vertical?Features.isSubscription?0:0:0,bottom: alignmnt == StepperAlignment.Vertical?(Features.isSubscription)?0:0:0),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () =>onTap(CartStatus.decrement),
            child: Container(
               margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
                width: Features.btobModule?alignmnt == StepperAlignment.Vertical?skutype=="1"?15:30:skutype=="1"?25:30:alignmnt == StepperAlignment.Vertical?skutype=="1"?15:30:skutype=="1"?25:35,
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?60:40:30,

                // decoration: new BoxDecoration(
                //   color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                //   border: Border(
                //     left: BorderSide(width: 1.0, color: ColorCodes.varcolor,),
                //     bottom: BorderSide(width: 1.0, color: ColorCodes.varcolor),
                //     top: BorderSide(width: 1.0, color: ColorCodes.varcolor),
                //   ),),
                child: Center(
                  child:
                  Text(
                    "-",
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    TextStyle(
                      fontSize: 18,
                      color: (Features.isSubscription)?ColorCodes.darkgreen :ColorCodes.darkgreen,
                    ),
                  ),
                )),
          ),
          Features.btobModule?
          (isloading)? Loading(context)
              :Container(
              color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              // decoration: new BoxDecoration(
              //   color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              //   border: Border(
              //     // left: BorderSide(width: 1.0, color: ColorCodes.darkgreen,),
              //     bottom: BorderSide(width: 1.0, color: ColorCodes.varcolor),
              //     top: BorderSide(width: 1.0, color: ColorCodes.varcolor),
              //   // ),
              // ),
              width: Features.btobModule?alignmnt == StepperAlignment.Vertical?skutype=="1"?15:40:skutype=="1"?25:35:alignmnt == StepperAlignment.Vertical?skutype=="1"?15:30:skutype=="1"?25:35,
              height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?60:40:30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      skutype=="1"? weight.toString()+" "+unit:quantity.toStringAsFixed(0),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: skutype=="1"?11:13,
                        color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.stepperColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor, ),
                    ),
                  ),
                  skutype=="1"?
                  GestureDetector(
                      onTap: (){
                        showoptions1(context,count!,minItem!,maxItem!,weight,isloading,skutype,price!,varid,Cart_id,quantity,unit);
                      },
                      child: Icon(Icons.keyboard_arrow_down,color: ColorCodes.darkgreen,size: 20,))
                      :SizedBox.shrink()
                ],
              )):
          Expanded(
            child:(isloading)? Loading(context)
                :Container(
                color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                // decoration: new BoxDecoration(
                  //color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                  // border: Border(
                  //   // left: BorderSide(width: 1.0, color: ColorCodes.darkgreen,),
                  //   bottom: BorderSide(width: 1.0, color: ColorCodes.varcolor),
                  //   top: BorderSide(width: 1.0, color: ColorCodes.varcolor),
                  // ),
                // ),
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?60:40:30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        skutype=="1"? weight.toString()+" "+unit:quantity.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: skutype=="1"?11:13,
                          color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.stepperColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor, ),
                      ),
                    ),
                    skutype=="1"?
                GestureDetector(
                  onTap: (){
                    showoptions1(context,count!,minItem!,maxItem!,weight,isloading,skutype,price!,varid,Cart_id,quantity,unit);
                  },
                    child: Icon(Icons.keyboard_arrow_down,color: ColorCodes.darkgreen,size: 20,))
                        :SizedBox.shrink()
                  ],
                )),
          ),
          GestureDetector(
            onTap: () {
              // dialogforUpdateToppings(context);
              onTap(CartStatus.increment);
            },
            child: Container(
                width: Features.btobModule?alignmnt == StepperAlignment.Vertical?skutype=="1"?15:30:skutype=="1"?25:35:alignmnt == StepperAlignment.Vertical?skutype=="1"?15:30:skutype=="1"?25:35,
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?60:40:30,
                decoration: new BoxDecoration(
                  color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                  // border: Border(
                  //   right: BorderSide(width: 1.0, color: ColorCodes.varcolor,),
                  //   bottom: BorderSide(width: 1.0, color: ColorCodes.varcolor),
                  //   top: BorderSide(width: 1.0, color: ColorCodes.varcolor),
                  // ),
                ),
                child: Center(
                  child: Text(
                    "+",
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    TextStyle(
                      fontSize: 18,
                      color: (Features.isSubscription)?ColorCodes.darkgreen :ColorCodes.darkgreen,
                    ),
                  ),
                )),
          ),
        ],
      ),

    ),

  );
}



Widget AddSubsciptionStepper(BuildContext context,{required StepperAlignment alignmnt, ItemData? itemdata,required Function() onTap,required double fontsize, StoreSearchData? search,String? from_screen}) {
  return (Features.isSubscription)?
  from_screen == "search_screen" && Features.ismultivendor?
      search!.eligibleForSubscription =="0" ?
      Expanded(
        flex: 1,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: ()=>onTap(),
            child: Padding(
              padding:  EdgeInsets.only(left:alignmnt == StepperAlignment.Horizontal?10:0,top: alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?15:0),
              child: Container(
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:30.0,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                    // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                  ),
                  color: ColorCodes.varcolor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 3),
                    Image.asset(Images.subscribeImg,
                      height: 10.0,
                      width: 10.0,
                      color: ColorCodes.primaryColor,),
                    SizedBox(width: 3),
                    Text(

                      S.current.subscribe,
                      style: TextStyle(
                          fontSize: fontsize,
                          color: ColorCodes.darkgreen/*Theme.of(context)
          .primaryColor*/,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 5),
                  ],
                ) ,
              ),
            ),
          ),
        ),
      ):alignmnt == StepperAlignment.Vertical?Expanded(
          flex: 1,
          child: SizedBox.shrink()):SizedBox.shrink():
  itemdata!.eligibleForSubscription =="0" ?
  Expanded(
    flex: 1,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: ()=>onTap(),
        child: Padding(
          padding:  EdgeInsets.only(left:alignmnt == StepperAlignment.Horizontal?20:0,top: alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?15:0),
          child: Container(
            height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:30.0,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 3.0, color: ColorCodes.darkgreen),
                // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
              ),
              color: ColorCodes.varcolor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 4),
                Image.asset(Images.subscribeImg,
                  height: 12.0,
                  width: 12.0,
                color: ColorCodes.primaryColor,),
                SizedBox(width: 3),
                Text(

                  S.current.subscribe,
                  style: TextStyle(
                      fontSize: fontsize,
                      color: ColorCodes.darkgreen/*Theme.of(context)
          .primaryColor*/,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
               SizedBox(width: 2),
              ],
            ) ,
          ),
        ),
      ),
    ),
  ):alignmnt == StepperAlignment.Vertical?Expanded(
      flex: 1,
      child: SizedBox.shrink()):SizedBox.shrink():SizedBox.shrink();
}

Widget NotificationStepper(BuildContext context,{required StepperAlignment alignmnt,required Function() onTap, required double fontsize,required bool isnotify}) {
  return Features.isSubscription?Expanded(
    flex: 1,
    child:
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:40.0,
          decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              border: Border.all(color: ColorCodes.darkgreen/*Theme
    .of(context)
    .primaryColor*/),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight:
                const Radius.circular(5),
                bottomLeft:
                const Radius.circular(5),
                bottomRight:
                const Radius.circular(5),
              )),
          child: isnotify ?
          Center(
            child: SizedBox(
                width: 15.0,
                height: 15.0,
                child: new CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: new AlwaysStoppedAnimation<
                      Color>(Colors.green),)),
          ):
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: Text(S.current.notify_me,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ColorCodes.darkgreen,/*Colors
              .white,*/
                        fontSize: fontsize),
                    textAlign: TextAlign.center,)),
              /*    Spacer(),
                    Container(
                      height: 30,
                      width: 25,
                      decoration: BoxDecoration(
                        color:Features.isSubscription?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor:
                        IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor,

                      ),
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),*/
            ],
          ),
        ),
      ),),
  ):Expanded(
    flex: 1,
    child:
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          //height: 30.0,
          // decoration: new BoxDecoration(
          //   // border: Border.all(
          //   //     color:  (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor),
          //     color:  (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor:IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
          //     borderRadius:
          //     new BorderRadius.all(const Radius.circular(3.0),)),
          decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              border: Border.all(color: ColorCodes.darkgreen/*Theme
         .of(context)
         .primaryColor*/),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight:
                const Radius.circular(5),
                bottomLeft:
                const Radius.circular(5),
                bottomRight:
                const Radius.circular(5),
              )),
          child:
          isnotify ?
          Center(
            child: SizedBox(
                width: 15.0,
                height: 15.0,
                child: new CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: new AlwaysStoppedAnimation<
                      Color>(Colors.green),)),
          ):
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 10,
              ),
              Center(
                  child: Text(S.current.notify_me,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ColorCodes.darkgreen,
                        fontSize: fontsize),
                    textAlign: TextAlign.center,)),
              /*Spacer(),
              Container(
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:40.0,
                width: 25,
                decoration: BoxDecoration(
                  color:Features.isSubscription?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor:
                  IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor,

                ),
                child: Icon(
                  Icons.add,
                  size: 12,
                  color: Colors.white,
                ),
              ),*/
            ],
          ),
        ),
      ),

    ),

  );
}

showoptions1(BuildContext context,String count,String minItem,String maxItem,double weightsku,bool loading, String skutype, double price,String? varid,String? cart_id,int qty, String unit) {
  List weight = [];
double total_weight = 0.0;
double total_min = 0.0;
double total_max = 0.0;
int? selectedIndex;


  List<double> Listweight = [];
  weight.clear();
  for( int i = int.parse(minItem);i <= int.parse(maxItem);i++){
    weight.add(i);
    selectedIndex = 0;
    total_min = double.parse(minItem) ;/** double.parse(count)*/;
    total_max = double.parse(maxItem) ;/** double.parse(count)*/;
    total_weight = total_min;
  }

  print("count value...." +count.toString());
  Listweight.clear();
  //for (int j = 0; j< weight.length;j++){
    for(int k = total_min.toInt() ; k <= total_max.toInt(); k++) {
      if(k == total_min.toInt()) {
        total_weight =
            total_min * double.parse(count);
      }
      else{
        total_weight =
            total_weight + (double.parse(count));
      }
    //}
    Listweight.add(total_weight);
  }

  (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState1) {
          return  Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
            child: Container(
              width: MediaQuery.of(context).size.width / 2.5,
              //height: 200,
              padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
              child:
              SingleChildScrollView(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: weight.length,
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (){

                          Navigator.of(context).pop();
                          setState1((){
                            //loading = true;
                            selectedIndex = i;

                          });

                          (loading)? Loading(context)
                              :
                          cartcontroller.update((done) {
                            setState1(() {
                              loading = !done;
                            });
                          }, price: price.toString(),
                              quantity: qty.toString(),
                              type: skutype.toString(),
                              weight: Listweight[i].toString(),
                              var_id: varid!,
                              increament: count,
                              cart_id: cart_id!,
                              toppings: "",
                              topping_id: "",

                          );  },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                           decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(6),
                                   color: selectedIndex==i?ColorCodes.fill:ColorCodes.whiteColor,
                                   border: Border.all(color: ColorCodes.lightGreyColor),
                                 ),
                          child: Row(

                            children: [
                              handlerweight(i,selectedIndex!),
                              SizedBox(width:5),
                              Text(Listweight[i].toString() + unit.toString()),
                              Spacer(),
                              Text(  Features.iscurrencyformatalign?
                              (Listweight[i]*price).toStringAsFixed(2) + " " + IConstants.currencyFormat:
                              IConstants.currencyFormat + " " + (Listweight[i]*price).toStringAsFixed(2),),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ),
          );
        });
      })
      /*.then((_) => setstate(){}) */:

      showModalBottomSheet<dynamic>(
      isScrollControlled: true,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0),topRight: Radius.circular(15.0)),
          ),
      context: context,
      builder: (context) {
        return StatefulBuilder(

          builder: (BuildContext context, void Function(void Function()) setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left:8.0,right:8,top:15,bottom: 15),
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: weight.length,
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (){
                          Navigator.of(context).pop();
                          setState((){
                            //loading = true;
                            selectedIndex = i;

                          });

                          (loading)? Loading(context)
                              :
                          cartcontroller.update((done) {
                           setState(() {
                            loading = !done;
                            });
                          }, price: price.toString(),
                              quantity: qty.toString(),
                              type: skutype.toString(),
                              weight: Listweight[i].toString(),
                              var_id: varid!,
                              increament: count,
                              cart_id: cart_id!,
                              toppings: "",
                              topping_id: "",

                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10,),
                          margin: EdgeInsets.symmetric(vertical: 8,),
                          child: Row(

                            children: [
                              handlerweight(i,selectedIndex!),
                              SizedBox(width:5),
                              Text(Listweight[i].toString() + unit.toString()),
                              Spacer(),

                              Text(
                                Features.iscurrencyformatalign?
                                (Listweight[i]*price).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit)+
                                    " " + IConstants.currencyFormat :
                                IConstants.currencyFormat +
                                    " " +
                                    (Listweight[i]*price).toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                                // style: TextStyle(
                                //     color: (walletbalance == "0")? ColorCodes.grey : ColorCodes.greenColor,
                                //     fontSize: 18.0,
                                //     fontWeight: FontWeight.bold),
                              ),
                              //Text((Listweight[i]*price).toStringAsFixed(2)),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            );
          },
        );
      });
}

Widget handlerweight(int i, int selectedIndex) {
    return (selectedIndex == i) ?
    Icon(
        Icons.radio_button_checked_outlined,
        color: ColorCodes.greenColor)
        :
    Icon(
        Icons.radio_button_off_outlined,
        color: ColorCodes.greenColor);

}