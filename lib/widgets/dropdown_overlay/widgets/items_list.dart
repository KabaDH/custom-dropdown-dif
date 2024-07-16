part of '../../../custom_dropdown.dart';

class _ItemsList<T> extends StatefulWidget {
  final ScrollController scrollController;
  final T? selectedItem;
  final List<T> items, selectedItems;
  final Function(T) onItemSelect;
  final bool excludeSelected;
  final EdgeInsets itemsListPadding, listItemPadding;
  final _ListItemBuilder<T> listItemBuilder;
  final ListItemDecoration? decoration;
  final _DropdownType dropdownType;

  const _ItemsList({
    super.key,
    required this.scrollController,
    required this.selectedItem,
    required this.items,
    required this.onItemSelect,
    required this.excludeSelected,
    required this.itemsListPadding,
    required this.listItemPadding,
    required this.listItemBuilder,
    required this.selectedItems,
    required this.decoration,
    required this.dropdownType,
  });

  @override
  State<_ItemsList<T>> createState() => _ItemsListState<T>();
}

class _ItemsListState<T> extends State<_ItemsList<T>> {
  double lastScrollOffset = 0;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(onScrollChanged);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(onScrollChanged);
    super.dispose();
  }

  void onScrollChanged() {
    final sc = widget.scrollController;
    if (sc.hasClients &&
        sc.positions.isNotEmpty &&
        sc.offset != lastScrollOffset) {
      FocusScope.of(context).requestFocus(focusNode);
      lastScrollOffset = sc.offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: widget.scrollController,
      child: ListView.builder(
        controller: widget.scrollController,
        shrinkWrap: true,
        padding: widget.itemsListPadding,
        itemCount: widget.items.length,
        itemBuilder: (_, index) {
          final selected = switch (widget.dropdownType) {
            _DropdownType.singleSelect => !widget.excludeSelected &&
                widget.selectedItem == widget.items[index],
            _DropdownType.multipleSelect =>
              widget.selectedItems.contains(widget.items[index])
          };
          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: widget.decoration?.splashColor ??
                  ListItemDecoration._defaultSplashColor,
              highlightColor: widget.decoration?.highlightColor ??
                  ListItemDecoration._defaultHighlightColor,
              onTap: () {
                FocusScope.of(context).requestFocus(focusNode);
                widget.onItemSelect(widget.items[index]);
              },
              child: Ink(
                color: selected
                    ? (widget.decoration?.selectedColor ??
                        ListItemDecoration._defaultSelectedColor)
                    : Colors.transparent,
                padding: widget.listItemPadding,
                child: widget.listItemBuilder(
                  context,
                  widget.items[index],
                  selected,
                  () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    widget.onItemSelect(widget.items[index]);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
