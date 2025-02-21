import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProfileScreen extends StatelessWidget {
  const ShimmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isWideScreen = screenWidth > 600;
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: CircleAvatar(
                        radius: isWideScreen ? 50 : 46,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShimmerColumn(),
                          _buildShimmerColumn(),
                          _buildShimmerColumn(),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        child: Container(
                          height: screenHeight * 0.02,
                          width: screenWidth * 0.4,
                          color: Colors.white,
                        ),
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Shimmer.fromColors(
                        child: Container(
                          height: screenHeight * 0.02,
                          width: screenWidth * 0.7,
                          color: Colors.white,
                        ),
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: screenHeight * 0.05,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(20)),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShimmerColumn() {
    return Expanded(
      child: Column(
        children: [
          Shimmer.fromColors(
              child: Container(
                height: 20,
                width: 40,
                color: Colors.white,
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!),
          const SizedBox(
            height: 3,
          ),
          Shimmer.fromColors(
              child: Container(
                height: 20,
                width: 40,
                color: Colors.white,
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!)
        ],
      ),
    );
  }
}
