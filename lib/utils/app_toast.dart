
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  static void success({
    required String title,
    String? description,
  }) {
    _show(
      icon: Icons.check_circle_outline,
      title: title,
      description: description,
    );
  }

  static void error({
    required String title,
    String? description,
  }) {
    _show(
      icon: Icons.error_outline,
      title: title,
      description: description,
    );
  }

  static void _show({
    required IconData icon,
    required String title,
    String? description,
  }) {
    toastification.showCustom(
      autoCloseDuration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      builder: (context, toast) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Container(
          width: screenWidth - 32,
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    if (description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}