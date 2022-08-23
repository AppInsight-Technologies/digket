

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as shimmer;

class HomeScreenShimmer extends StatefulWidget {

  const HomeScreenShimmer({Key? key}) : super(key: key);

  @override
  _ColorLoaderState createState() => _ColorLoaderState();
}

class _ColorLoaderState extends State<HomeScreenShimmer> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          shimmer.Shimmer.fromColors(child: Column(
            children:  [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(height: 40,color: Colors.black,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(height: 100,color: Colors.black,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(height: 250,color: Colors.black,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 30),
                    child: Column(
                      children:  [
                        const Icon(Icons.image,size: 100,),
                        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
                        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 30),
                    child: Column(
                      children:  [
                        const Icon(Icons.image,size: 100,),
                        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
                        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 30),
                    child: Column(
                      children:  [
                        const Icon(Icons.image,size: 100,),
                        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),
                        Padding(padding: const EdgeInsets.all(8.0), child: Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16),),),),

                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
            baseColor: Colors.grey.shade100,
            highlightColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
