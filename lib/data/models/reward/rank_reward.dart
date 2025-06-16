import 'package:flutter/material.dart';

class RankReward {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredRank;
  final bool isVoucher;
  final String? voucherCode;
  final String? expiryDate;

  const RankReward({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredRank,
    this.isVoucher = false,
    this.voucherCode,
    this.expiryDate,
  });
}
