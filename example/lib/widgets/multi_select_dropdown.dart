import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:animated_custom_dropdown_example/models/geo_element.dart';
import 'package:animated_custom_dropdown_example/models/job.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatelessWidget {
  const MultiSelectDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<Job>.multiSelect(
      items: jobItems,
      initialItems: jobItems.take(2).toList(),
      onListChanged: (value) {
        log('MultiSelectDropdown onChanged value: $value');
      },
    );
  }
}

/// Selection dropdown with categories.
///
/// You must provide the same instance of the Item both to the Item in the list,
/// and to the Item in the category. See an example in [GeoElement].
class MultiSelectGroupedDropdown extends StatelessWidget {
  const MultiSelectGroupedDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<GeoElement>.multiSelect(
      items: groupedCities,
      onListChanged: (value) {
        log('MultiSelectGroupedDropdown onChanged value: $value');
      },
      onListSelectionComplete: (items) {
        log('MultiSelectGroupedDropdown onListSelectionComplete value: $items');
      },
    );
  }
}
