import 'package:flutter/material.dart';

import '../../constants/image_paths.dart';
import '../../constants/texts.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: const AssetImage(bijouCafeLogo),
            height: size.height * 0.2,
          ),
          const SizedBox(height: 20),
          Text(
            loginSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
