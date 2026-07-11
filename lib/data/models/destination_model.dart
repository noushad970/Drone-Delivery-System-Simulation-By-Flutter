import 'package:flutter/material.dart';

/// Represents a delivery location on the custom city map.
///
/// Positions are stored as fractions (0..1) of the map size so the layout
/// adapts to any screen dimension.
class DestinationModel {
  final String id;
  final String name;
  final String district;
  final IconData icon;
  final Color color;
  final double x; // 0..1 fraction of map width
  final double y; // 0..1 fraction of map height
  final double description;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.district,
    required this.icon,
    required this.color,
    required this.x,
    required this.y,
    this.description = 0,
  });

  Offset normalizedOffset() => Offset(x, y);

  /// Convert a normalized offset into screen-space pixels.
  Offset toScreen(Size mapSize) => Offset(x * mapSize.width, y * mapSize.height);
}