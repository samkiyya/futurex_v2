import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class RatingSection extends StatelessWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;

  const RatingSection({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rate the course:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RatingStars(
            axis: Axis.horizontal,
            value: initialRating,
            onValueChanged: onRatingChanged,
            starCount: 5,
            starSize: 20,
            valueLabelColor: const Color(0xff9b9b9b),
            valueLabelTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 12.0,
            ),
            valueLabelRadius: 10,
            maxValue: 5,
            starSpacing: 2,
            maxValueVisibility: true,
            valueLabelVisibility: true,
            animationDuration: const Duration(milliseconds: 1000),
            valueLabelPadding:
                const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
            valueLabelMargin: const EdgeInsets.only(right: 8),
            starOffColor: const Color(0xffe7e8ea),
            starColor: const Color.fromARGB(255, 244, 111, 3),
            angle: 12,
          ),
        ],
      ),
    );
  }
}
