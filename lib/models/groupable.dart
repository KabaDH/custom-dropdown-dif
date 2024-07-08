part of '../custom_dropdown.dart';
/// Базовый класс для объектов группировки (паттерн Composite).
///
/// Примешивание `CustomDropdownListFilter` позволяет использовать фильтрацию
/// в виджете.
abstract class Groupable with CustomDropdownListFilter {
  /// Базовый класс для объектов группировки (паттерн Composite).
  const Groupable();

  /// Идентификатор.
  int get id;

  /// Идентификатор группы.
  int get groupId;

  /// Отображаемое имя.
  String get name;

  /// Это группа?
  bool get isGroup;

  /// Выделено?
  bool get selected;

  /// Копирование.
  Groupable copyWith({bool? selected});

  /// Фильтрация.
  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

/// Листовой тип группировки (паттерн Composite).
class Item with CustomDropdownListFilter implements Groupable {
  /// Листовой тип группировки (паттерн Composite).
  const Item({
    required this.id,
    required this.groupId,
    required this.name,
    this.selected = false,
  });

  /// Идентификатор.
  @override
  final int id;

  /// Идентификатор группы.
  @override
  final int groupId;

  /// Отображаемое имя.
  @override
  final String name;

  /// Выделено?
  @override
  final bool selected;

  /// Это группа?
  @override
  bool get isGroup => false;

  @override
  Groupable copyWith({bool? selected}) {
    return Item(
      id: id,
      groupId: groupId,
      name: name,
      selected: selected ?? this.selected,
    );
  }

  @override
  bool operator ==(Object other) {
    return (super == other) ||
        ((other is Item) && (id == other.id) && (groupId == other.groupId));
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

/// Узловой тип группировки (паттерн Composite).
class Group with CustomDropdownListFilter implements Groupable {
  /// Узловой тип группировки (паттерн Composite).
  const Group({
    required this.id,
    required this.name,
    this.selected = false,
  });

  /// Идентификатор.
  @override
  final int id;

  /// Идентификатор группы.
  @override
  int get groupId => -1;

  /// Отображаемое имя.
  @override
  final String name;

  /// Выделено?
  @override
  final bool selected;

  /// Это группа?
  @override
  bool get isGroup => true;

  @override
  Groupable copyWith({bool? selected}) {
    return Group(
      id: id,
      name: name,
      selected: selected ?? this.selected,
    );
  }

  @override
  bool operator ==(Object other) {
    return (super == other) ||
        ((other is Group) && (id == other.id) && (groupId == other.groupId));
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
