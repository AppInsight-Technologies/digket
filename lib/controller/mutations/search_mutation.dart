import '../../constants/IConstants.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/search_data.dart';
import '../../repository/fetchdata/home_store_repo.dart';
import '../../repository/productandCategory/category_or_product.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../repository/fetchdata/searchRepo.dart';

class SearchStoreScreenController  extends VxMutation<GroceStore>{
  // HomePageRepo _homePagerepo;
  var itemname;
  var lat;
  var long;
  //var languageid;

  SearchStoreScreenController({this.itemname,this.lat,this.long});
  @override
  Future<bool> perform() async{
    // TODO: implement perform
    print("item name..."+itemname.toString()+",,,,");
    //ProductRepo _searchproductrepo = ProductRepo();
    store!.storesearch.data = await searchStorerepo.getStoreSearch(itemname,lat,long,);
    return Future.value(true);
  }}