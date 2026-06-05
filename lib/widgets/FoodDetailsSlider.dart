import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FoodDetailsSlider extends StatelessWidget {
  final String slideImage1;
  final String? slideImage2;
  final String? slideImage3;

  const FoodDetailsSlider({
    Key? key,
    required this.slideImage1,
    this.slideImage2,
    this.slideImage3,
  }) : super(key: key);

  Widget buildImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/placeholder.jpeg', // fallback
          fit: BoxFit.cover,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> images = [
      buildImage(slideImage1),
      if (slideImage2 != null) buildImage(slideImage2!),
      if (slideImage3 != null) buildImage(slideImage3!),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: CarouselSlider(
        items: images,
        options: CarouselOptions(
          height: 250,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 2),
          viewportFraction: 1.0,
        ),
      ),
    );
  }
}
