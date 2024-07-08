part of '../custom_dropdown.dart';

class _ValueNotifierList<T> extends ValueNotifier<List<T>> {
  _ValueNotifierList(super.value);

  void add(T valueToAdd) {
    value = [...value, valueToAdd];
  }

  void remove(T valueToRemove) {
    value = value.where((value) {
      return value is Groupable &&
          valueToRemove is Groupable &&
          value.id != valueToRemove.id;
    }).toList();
  }
}
