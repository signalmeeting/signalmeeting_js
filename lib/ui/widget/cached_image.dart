import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedImage(String url, {double width = 90.0, double height = 90.0, double radius = 8.0}) {
  if (url == null) return Center(child: CircularProgressIndicator());
  return CachedNetworkImage(
      placeholder: (context, url) => Container(width: width, height: height),
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                )),
          ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.asset(
            'assets/empty_person.png',
            fit: BoxFit.fitWidth,
            color: Colors.white,
          ),
        ),
      ));
}
