import 'package:flutter/material.dart';
import '../../assets/ColorCodes.dart';
import 'package:shimmer/shimmer.dart';

class SingelItemOfList extends StatelessWidget {
  const SingelItemOfList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: /*Color(0xffd3d3d3)*/Colors.grey[200]!,
      highlightColor: ColorCodes.lightGreyWebColor,
      child: Column(children: [

        Icon(Icons.image,size: 60,),
        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 80, height: 8, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
          SizedBox(height: 10,),
        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 40, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
        Padding(padding: const EdgeInsets.all(12.0), child: Container( height: 30, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
        Padding(padding: const EdgeInsets.all(12.0), child: Container( height: 35, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
        Padding(padding: const EdgeInsets.all(12.0), child: Container( height: 20, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),

      ],),
    );
  }
}
