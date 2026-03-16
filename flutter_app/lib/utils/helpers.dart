import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

double sw(BuildContext context, double size) {
  final width = MediaQuery.of(context).size.width;
  final effectiveWidth = width.clamp(320.0, 430.0);
  return effectiveWidth * (size / 390);
}

double sh(BuildContext context, double size) {
  final height = MediaQuery.of(context).size.height;
  final effectiveHeight = height.clamp(700.0, 900.0);
  return effectiveHeight * (size / 844);
}

class Helpers {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dateTime);
  }
}
