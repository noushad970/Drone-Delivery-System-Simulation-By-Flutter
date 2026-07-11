import 'package:flutter/material.dart';

import '../data/models/destination_model.dart';

/// Hand-crafted city layout used by the map screen and the mission
/// simulator. All positions are stored as fractions (0..1) of the map
/// size so they adapt to any screen resolution.
class CityMapData {
  CityMapData._();

  /// Pixel-to-kilometre conversion factor for the map's normalised
  /// coordinate space. Tuned so that every destination lands in the
  /// 1–3 km range from the home base (deliveries are short hops).
  static const double _pxPerKm = 380.0;

  /// Home base / hub location, stored as a normalised offset so it scales
  /// with the painted map.
  static const Offset homeBaseNormalized = Offset(0.50, 0.86);

  /// 10 hand-placed destinations around the city. All positions are
  /// deliberately placed close to the home base so every delivery is a
  /// short 1–3 km hop.
  static final List<DestinationModel> destinations = <DestinationModel>[
    DestinationModel(
      id: 'central_market',
      name: 'Central Market',
      district: 'OLD TOWN',
      icon: Icons.storefront_rounded,
      color: Color(0xFFFFB300),
      x: 0.42,
      y: 0.62,
    ),
    DestinationModel(
      id: 'skyline_hospital',
      name: 'Skyline Hospital',
      district: 'MEDICAL DISTRICT',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFEF5350),
      x: 0.66,
      y: 0.56,
    ),
    DestinationModel(
      id: 'bayview_apartments',
      name: 'Bayview Apartments',
      district: 'WATERFRONT',
      icon: Icons.apartment_rounded,
      color: Color(0xFF42A5F5),
      x: 0.24,
      y: 0.68,
    ),
    DestinationModel(
      id: 'riverside_park',
      name: 'Riverside Park',
      district: 'GREENBELT',
      icon: Icons.park_rounded,
      color: Color(0xFF66BB6A),
      x: 0.36,
      y: 0.50,
    ),
    DestinationModel(
      id: 'tech_park_tower',
      name: 'Tech Park Tower',
      district: 'DOWNTOWN',
      icon: Icons.business_rounded,
      color: Color(0xFF7E57C2),
      x: 0.72,
      y: 0.70,
    ),
    DestinationModel(
      id: 'stadium_district',
      name: 'Stadium District',
      district: 'SPORTS',
      icon: Icons.sports_soccer_rounded,
      color: Color(0xFFFF7043),
      x: 0.30,
      y: 0.78,
    ),
    DestinationModel(
      id: 'sunset_mall',
      name: 'Sunset Mall',
      district: 'COMMERCIAL',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC407A),
      x: 0.62,
      y: 0.78,
    ),
    DestinationModel(
      id: 'lakeside_cafe',
      name: 'Lakeside Cafe',
      district: 'LEISURE',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF8D6E63),
      x: 0.20,
      y: 0.56,
    ),
    DestinationModel(
      id: 'greenwood_school',
      name: 'Greenwood School',
      district: 'EDUCATION',
      icon: Icons.school_rounded,
      color: Color(0xFF26A69A),
      x: 0.48,
      y: 0.72,
    ),
    DestinationModel(
      id: 'airport_terminal',
      name: 'Airport Terminal',
      district: 'AVIATION',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF5C6BC0),
      x: 0.80,
      y: 0.58,
    ),
  ];

  /// Convert the stored normalised home base offset into screen pixels.
  static Offset homeBaseOn(Size mapSize) => Offset(
      homeBaseNormalized.dx * mapSize.width,
      homeBaseNormalized.dy * mapSize.height);

  /// Returns the screen-space offset for [destination] on a canvas of
  /// [mapSize].
  static Offset pointFor(DestinationModel destination, Size mapSize) =>
      destination.toScreen(mapSize);

  /// Approximate straight-line distance (in km) between the home base and
  /// [destination] using [_pxPerKm] as the conversion factor.
  static double distanceFromBaseTo(DestinationModel destination) {
    // Distance is computed in the same normalised coordinate space as the
    // map. We assume a 16:11 aspect so horizontal and vertical pixels are
    // weighted appropriately.
    const double aspect = 16 / 11;
    const double w = 1.0;
    final double h = w / aspect;
    final double dx = (destination.x - homeBaseNormalized.dx) * w;
    final double dy = (destination.y - homeBaseNormalized.dy) * h;
    // Multiply by 1000 so the units line up with [_pxPerKm] which assumes a
    // ~1000 px wide canvas. With the current layout every destination lands
    // between ~1 km and ~3 km from the base.
    final double pixels = (Offset(dx, dy).distance) * 1000.0;
    return pixels / _pxPerKm;
  }

  /// Approximate straight-line distance (in km) between two destinations.
  static double distanceBetween(DestinationModel from, DestinationModel to) {
    const double aspect = 16 / 11;
    const double w = 1.0;
    final double h = w / aspect;
    final double dx = (to.x - from.x) * w;
    final double dy = (to.y - from.y) * h;
    final double pixels = (Offset(dx, dy).distance) * 1000.0;
    return pixels / _pxPerKm;
  }

  /// Look up a destination by its id. Returns `null` when no match is
  /// found.
  static DestinationModel? findById(String id) {
    for (final DestinationModel d in destinations) {
      if (d.id == id) return d;
    }
    return null;
  }
}
