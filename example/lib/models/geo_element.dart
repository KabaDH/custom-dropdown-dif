import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

final cities = [
  GeoElement('Madrid', Icons.location_city, 'Spain'),
  GeoElement('Barcelona', Icons.location_city, 'Spain'),
  GeoElement('Valencia', Icons.location_city, 'Spain'),
  GeoElement('Rome', Icons.location_city, 'Italy'),
  GeoElement('Milan', Icons.location_city, 'Italy'),
];

final groupedCities = () {
  final categories = cities.map((e) => e.groupBy).toSet();
  final output = <GeoElement>[];
  for (final e in categories) {
    if (e.isEmpty) continue;
    final children = cities.where((el) => el.groupBy == e);
    output.add(GeoElement(e, Icons.flag)..children.addAll(children));
    output.addAll(children);
  }
  return output;
}();

/// Country, City
class GeoElement
    with CustomDropdownListFilter, CustomDropdownGroupable<GeoElement> {
  final String name;
  final IconData icon;
  final String groupBy;

  GeoElement(this.name, this.icon, [this.groupBy = '']);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
