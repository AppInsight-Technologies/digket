import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/product_data.dart';
import '../../models/newmodle/search_data.dart';
import '../../models/sellingitemsfields.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/features.dart';

class Check{


  isOutofStock({double? maxstock,String? stocktype,String? qty, List<SellingItemsFields>?  itemData, PriceVariation? variation,PriceVariationSearch? searchvariation,String? screen}){
    double quantity =0;
    if( stocktype =="1") {
      itemData!.forEach((element) {
        print("qtys:${element.varQty }");
        quantity = quantity+ (element.varQty * element.weight!);
        print("qtys 1  :${ quantity}");
      });
      quantity = (screen == "search_screen" && Features.ismultivendor)?(quantity) + double.parse(searchvariation!.weight!):(quantity) + double.parse(variation!.weight!);
      //quantity = (quantity) * double.parse(variation.weight!);
      //print("checking the quantity0 $quantity} * ${(screen == "search_screen" && Features.ismultivendor)?double.parse(searchvariation!.weight!):double.parse(variation!.weight!)*double.parse(stocktype!)} == ${maxstock} type $stocktype");
      return quantity > maxstock!;
    } else {
      print("checking the quantity..."+qty.toString()+"  "+maxstock.toString());
      return double.parse(qty!) >= maxstock!;
    }
  }
  isOutofStockSingleProduct({PriceVariation? variation ,PriceVariationSearch? searchvariation,double? maxstock,String? stocktype,List<SellingItemsFields>?  itemData,String? screen}){
    double quantity =0;
    if( stocktype =="1") {
      print("ghjkl..${itemData!.length}");
      // double w = 0.00;
      itemData.forEach((element) {
        print("itemd///" + itemData.length.toString());
        //print("qtys:${element.varQty+1 }");
        print("check...." + element.varname.toString() + "..." + element.varQty.toString() + "...." + element.weight!.toString());
        quantity = quantity + (element.varQty * element.weight!);
        // w=element.weight!;
        print("qtys 2..:${quantity}");
      });
      print("quantity= " + quantity.toString() + "  " + variation!.weight!.toString());
      quantity = (screen == "search_screen" && Features.ismultivendor)?(quantity) + double.parse(searchvariation!.weight!):(quantity) + double.parse(variation.weight!);
      //quantity = (quantity+1) * double.parse(variation.weight!);
      //print("checking the quantity0 $quantity * ${double.parse(variation.weight!)*double.parse(stocktype!)} = ${(quantity*double.parse(variation.weight!))*double.parse(stocktype)} >= ${maxstock} type $stocktype");
      print("quantity=1 " + quantity.toString() + "  " + maxstock.toString());
      return quantity >= maxstock!;
    } else {
      print("checking the quantity ${variation!.quantity} * ${double.parse(variation.weight!)*double.parse(stocktype!)} == ${maxstock} type $stocktype");
      return double.parse(variation.quantity!.toString()) >= maxstock!;
    }
  }


 bool checkmembership(){
    bool _checkmembership = false;
    if (VxState.store.userData.membership! =="1") {
      _checkmembership=true;
    } else {
      _checkmembership = false;
      for (int i = 0; i < (VxState.store as GroceStore).CartItemList.length; i++) {
        if ((VxState.store as GroceStore).CartItemList[i].mode == "1") {
          _checkmembership=true;
        }
      }
    }
    return _checkmembership;
  }
}