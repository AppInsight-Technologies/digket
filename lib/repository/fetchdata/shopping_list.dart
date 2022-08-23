import 'dart:convert';

import '../../models/newmodle/product_data.dart';
import '../../repository/api.dart';
import '../../utils/prefUtils.dart';

class ShoppingList{
  List<ItemData> data = [];
 Future<List<ItemData>> get(itemid)async{
   print("id:");
   Api api = Api();
   final result = json.decode(await api.Geturl("get-shopping-list-item/$itemid/${PrefUtils.prefs!.getString("apikey")}",isv2: false));
   if(result!=null){
     result.asMap().forEach((index, value) => data.add(ItemData.fromJson(result[index])));
     return Future.value(data);
   }
   else{
     return [];
   }
  }
}