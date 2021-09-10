import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class DetailSlider extends StatefulWidget {
  final String sellID;

  const DetailSlider({Key? key, required this.sellID}) : super(key: key);

  @override
  _DetailSliderState createState() => _DetailSliderState();
}

class _DetailSliderState extends State<DetailSlider> {
  var logger = Logger();

  CollectionReference SellList = FirebaseFirestore.instance.collection('sellList');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: SellList.doc(widget.sellID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("오류 : 앱을 다시 실행해주세요."));
        }
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          var imageList = [];
          imageList.addAll(data['images']);

          return Stack(
            children: [
              CarouselSlider(
                  options: CarouselOptions(
                    height: 250,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 1.0,
                  ),
                  items: imageList.asMap().entries.map((img) {
                    return GestureDetector(
                      // onTap: () => Get.to(ImageView(imagesUrl: img.value)),
                      onTap: () {
                        logger.i('${img.key}, ${img.value}');
                        // Get.to(ImageView(imagesUrl: imageList, initPageIndex: img.key));
                      },
                      child: Container(
                        width: Get.width,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              filterQuality: FilterQuality.low,
                              imageUrl: img.value,
                              placeholder: (context, url) => Container(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(('${img.key + 1} / ${imageList.length}').toString(),style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()
                  // carouselController: _controller,
                  ),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data! as Map<String, dynamic>;
          logger.i(data);
          // var sellDetail = data['sellDetail'];
          return Center(child: Text("data 있음"));
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
