import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../assets/ColorCodes.dart';

import 'package:shimmer/shimmer.dart';

class SubscriptionShimmer extends StatelessWidget {
  const SubscriptionShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorCodes.baseColor,
      highlightColor: ColorCodes.lightGreyWebColor,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.image,size: 200,),
              SizedBox(width: 10,),
              Column(
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10,),
          Padding(padding: const EdgeInsets.all(8.0), child: Container( height: 80, decoration: BoxDecoration(color: Colors.black, ),),),
          Divider(),
          Padding(padding: const EdgeInsets.all(8.0), child: Container( height: 80, decoration: BoxDecoration(color: Colors.black, ),),),
          Divider(),
          Padding(padding: const EdgeInsets.all(8.0), child: Container( height: 80, decoration: BoxDecoration(color: Colors.black, ),),),
          Divider(),
          Padding(padding: const EdgeInsets.all(8.0), child: Container( height: 80, decoration: BoxDecoration(color: Colors.black, ),),),
          Divider(),
          Padding(padding: const EdgeInsets.all(8.0), child: Container( height: 80, decoration: BoxDecoration(color: Colors.black, ),),),

        ],
      ),
    );
  }
}
