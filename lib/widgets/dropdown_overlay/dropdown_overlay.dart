part of '../../custom_dropdown.dart';

const _defaultOverlayIconUp = Icon(
  Icons.keyboard_arrow_up_rounded,
  size: 20,
);

const _defaultHeaderPadding = EdgeInsets.all(16.0);
const _overlayOuterPadding =
    EdgeInsetsDirectional.only(bottom: 12, start: 12, end: 12);
const _defaultOverlayShadowOffset = Offset(0, 6);
const _defaultListItemPadding =
    EdgeInsets.symmetric(vertical: 12, horizontal: 16);

class _DropdownOverlay<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final List<T> selectedItems;
  final Function(T) onItemSelect;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText, searchHintText, noResultFoundText;
  final bool excludeSelected, hideSelectedFieldWhenOpen, canCloseOutsideBounds;
  final _SearchType? searchType;
  final Future<List<T>> Function(String)? futureRequest;
  final Duration? futureRequestDelay;
  final int maxLines;
  final double? overlayHeight;
  final TextStyle? hintStyle, headerStyle, noResultFoundStyle, listItemStyle;
  final EdgeInsets? headerPadding, listItemPadding, itemsListPadding;
  final Widget? searchRequestLoadingIndicator;
  final _ListItemBuilder<T>? listItemBuilder;
  final _HeaderBuilder<T>? headerBuilder;
  final _HeaderListBuilder<T>? headerListBuilder;
  final _HintBuilder? hintBuilder;
  final _NoResultFoundBuilder? noResultFoundBuilder;
  final CustomDropdownDecoration? decoration;
  final _DropdownType dropdownType;
  final bool enabled;
  final bool closeDropDownOnClearFilterSearch;
  final bool autofocusOnSearchField;
  final bool canOpenOverlayTopSide;
  final VoidCallback resetSelection;
  final bool withApplyButton;
  final _ApplyButtonBuilder<T>? applyButtonBuilder;

  const _DropdownOverlay({
    Key? key,
    required this.items,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    required this.searchHintText,
    required this.selectedItem,
    required this.selectedItems,
    required this.excludeSelected,
    required this.onItemSelect,
    required this.noResultFoundText,
    required this.canCloseOutsideBounds,
    required this.maxLines,
    required this.overlayHeight,
    required this.dropdownType,
    required this.decoration,
    required this.hintStyle,
    required this.headerStyle,
    required this.listItemStyle,
    required this.noResultFoundStyle,
    required this.hideSelectedFieldWhenOpen,
    required this.searchRequestLoadingIndicator,
    required this.headerPadding,
    required this.itemsListPadding,
    required this.listItemPadding,
    required this.headerBuilder,
    required this.hintBuilder,
    required this.searchType,
    required this.futureRequest,
    required this.futureRequestDelay,
    required this.listItemBuilder,
    required this.headerListBuilder,
    required this.noResultFoundBuilder,
    required this.enabled,
    required this.closeDropDownOnClearFilterSearch,
    required this.resetSelection,
    required this.applyButtonBuilder,
    this.autofocusOnSearchField = false,
    this.canOpenOverlayTopSide = true,
    this.withApplyButton = false,
  });

  @override
  _DropdownOverlayState<T> createState() => _DropdownOverlayState<T>();
}

class _DropdownOverlayState<T> extends State<_DropdownOverlay<T>> {
  bool displayOverly = true, displayOverlayBottom = true;
  bool isSearchRequestLoading = false;
  bool? mayFoundSearchRequestResult;
  late List<T> items;
  late T? selectedItem;
  late List<T> selectedItems;
  final key1 = GlobalKey(), key2 = GlobalKey();
  final scrollController = ScrollController();

  void resetSelection() {
    setState(() {
      selectedItem = null;
      selectedItems = [];
      widget.resetSelection();
    });
  }

  Widget hintBuilder(BuildContext context) {
    return widget.hintBuilder != null
        ? widget.hintBuilder!(context, widget.hintText, widget.enabled)
        : defaultHintBuilder(context, widget.hintText);
  }

  Widget headerBuilder(BuildContext context) {
    return widget.headerBuilder != null
        ? widget.headerBuilder!(context, selectedItem as T, widget.enabled)
        : defaultHeaderBuilder(context, item: selectedItem);
  }

  Widget headerListBuilder(BuildContext context) {
    return widget.headerListBuilder != null
        ? widget.headerListBuilder!(
            context,
            selectedItems,
            widget.enabled,
            resetSelection,
          )
        : defaultHeaderBuilder(
            context,
            items: selectedItems,
            resetSelection: resetSelection,
          );
  }

  Widget applyButtonBuilder(BuildContext context) {
    return widget.applyButtonBuilder != null
        ? widget.applyButtonBuilder!(context, widget.hideOverlay, selectedItems)
        : defaultApplyButtonBuilder(context, widget.hideOverlay);
  }

  Widget noResultFoundBuilder(BuildContext context) {
    return widget.noResultFoundBuilder != null
        ? widget.noResultFoundBuilder!(context, widget.noResultFoundText)
        : defaultNoResultFoundBuilder(context, widget.noResultFoundText);
  }

  Widget defaultApplyButtonBuilder(
    BuildContext context,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Apply'),
    );
  }

  Widget defaultListItemBuilder(
    BuildContext context,
    T result,
    bool isSelected,
    VoidCallback onItemSelect,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            result.toString(),
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: widget.listItemStyle ??
                TextStyle(
                    fontSize: 16,
                    fontWeight: (result is CustomDropdownGroupable &&
                            result.children.isNotEmpty)
                        ? FontWeight.w900
                        : FontWeight.w400),
          ),
        ),
        if (widget.dropdownType == _DropdownType.multipleSelect)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12.0),
            child: Checkbox(
              onChanged: (_) => onItemSelect(),
              value: isSelected,
              activeColor:
                  widget.decoration?.listItemDecoration?.selectedIconColor,
              side: widget.decoration?.listItemDecoration?.selectedIconBorder,
              shape: widget.decoration?.listItemDecoration?.selectedIconShape,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
            ),
          ),
      ],
    );
  }

  Widget defaultHeaderBuilder(BuildContext context,
      {T? item, List<T>? items, VoidCallback? resetSelection}) {
    final itemsToBuild = <T>[];
    if ((items ?? []).isNotEmpty) {
      for (final e in items!) {
        if (e is CustomDropdownGroupable) {
          if (e.children.isEmpty) itemsToBuild.add(e);
        } else {
          itemsToBuild.add(e);
        }
      }
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            itemsToBuild.isNotEmpty ? itemsToBuild.join(', ') : item.toString(),
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: widget.headerStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        if (resetSelection != null)
          GestureDetector(
            onTap: resetSelection,
            child: const Icon(
              Icons.close,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget defaultHintBuilder(BuildContext context, String hint) {
    return Text(
      hint,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.hintStyle ??
          const TextStyle(
            fontSize: 16,
            color: Color(0xFFA7A7A7),
          ),
    );
  }

  Widget defaultNoResultFoundBuilder(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          text,
          style: widget.noResultFoundStyle ?? const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final render1 = key1.currentContext?.findRenderObject() as RenderBox;
      final render2 = key2.currentContext?.findRenderObject() as RenderBox;
      final screenHeight = MediaQuery.of(context).size.height;
      double y = render1.localToGlobal(Offset.zero).dy;
      if (screenHeight - y < render2.size.height &&
          widget.canOpenOverlayTopSide) {
        setState(() {
          displayOverlayBottom = false;
        });
      }
    });

    selectedItem = widget.selectedItem;
    selectedItems = widget.selectedItems;

    if (widget.excludeSelected &&
        widget.items.length > 1 &&
        selectedItem != null) {
      T value = selectedItem as T;
      items = widget.items.where((item) => item != value).toList();
    } else {
      items = widget.items;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onItemSelect(T value) {
    widget.onItemSelect(value);
    if (widget.dropdownType == _DropdownType.multipleSelect) {
      // We got grouped items
      if (value is CustomDropdownGroupable<T>) {
        // Click on group
        if (value.children.isNotEmpty) {
          if (selectedItems.contains(value as T)) {
            selectedItems.remove(value as T);
            for (final child in value.children) {
              selectedItems.remove(child);
              widget.onItemSelect(child);
            }
          } else {
            selectedItems.add(value as T);
            for (final child in value.children) {
              if (!selectedItems.contains(child)) {
                selectedItems.add(child);
                widget.onItemSelect(child);
              }
            }
          }
        } else {
          if (selectedItems.contains(value as T)) {
            selectedItems.remove(value as T);
          } else {
            selectedItems.add(value as T);
          }
          CustomDropdownGroupable<T>? group;
          for (final e in items) {
            final itemWithChildren = e as CustomDropdownGroupable<T>;
            for (final child in itemWithChildren.children) {
              if (child == value) {
                group = e;
                break;
              }
            }
          }
          // Click on Item inside the group
          if (group != null) {
            // TODO(ivn): Can do better seek
            if (group.children.every((e) => selectedItems.contains(e))) {
              if (!selectedItems.contains(group as T)) {
                selectedItems.add(group as T);
                widget.onItemSelect(group as T);
              }
            } else {
              if (selectedItems.contains(group as T)) {
                widget.onItemSelect(group as T);
              }
              selectedItems.remove(group as T);
            }
          }
        }
        setState(() {});
        return;
      }

      setState(() {
        // We got groupable items without group
        if (selectedItems.contains(value)) {
          selectedItems.remove(value);
        } else {
          selectedItems.add(value);
        }
      });
      return;
    }
    // We got non-groupable items
    if (selectedItems.contains(value)) {
      selectedItems.remove(value);
    } else {
      selectedItems.add(value);
    }
    setState(() => displayOverly = false);
  }

  void closeDropDown() => setState(() => displayOverly = false);

  @override
  Widget build(BuildContext context) {
    // decoration
    final decoration = widget.decoration;

    // search availability check
    final onSearch = widget.searchType != null;

    // overlay offset
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 64);

    // list padding
    final listPadding =
        onSearch ? const EdgeInsets.only(top: 8) : EdgeInsets.zero;

    // items list
    final list = items.isNotEmpty
        ? _ItemsList<T>(
            scrollController: scrollController,
            listItemBuilder: widget.listItemBuilder ?? defaultListItemBuilder,
            excludeSelected: items.length > 1 ? widget.excludeSelected : false,
            selectedItem: selectedItem,
            selectedItems: selectedItems,
            items: items,
            itemsListPadding: widget.itemsListPadding ?? listPadding,
            listItemPadding: widget.listItemPadding ?? _defaultListItemPadding,
            onItemSelect: onItemSelect,
            decoration: decoration?.listItemDecoration,
            dropdownType: widget.dropdownType,
          )
        : (mayFoundSearchRequestResult != null &&
                    !mayFoundSearchRequestResult!) ||
                widget.searchType == _SearchType.onListData
            ? noResultFoundBuilder(context)
            : const SizedBox(height: 12);

    final child = Stack(
      children: [
        Positioned(
          width: widget.size.width + 24,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            followerAnchor:
                displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: Container(
              key: key1,
              padding: _overlayOuterPadding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: decoration?.expandedFillColor ??
                      CustomDropdownDecoration._defaultFillColor,
                  border: decoration?.expandedBorder,
                  borderRadius:
                      decoration?.expandedBorderRadius ?? _defaultBorderRadius,
                  boxShadow: decoration?.expandedShadow ??
                      [
                        BoxShadow(
                          blurRadius: 24.0,
                          color: Colors.black.withOpacity(.08),
                          offset: _defaultOverlayShadowOffset,
                        ),
                      ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: _AnimatedSection(
                    animationDismissed: widget.hideOverlay,
                    expand: displayOverly,
                    axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                    child: SizedBox(
                      key: key2,
                      height: items.length > 4
                          ? widget.overlayHeight ?? (onSearch ? 270 : 225)
                          : null,
                      child: ClipRRect(
                        borderRadius: decoration?.expandedBorderRadius ??
                            _defaultBorderRadius,
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: decoration
                                      ?.overlayScrollbarDecoration ??
                                  ScrollbarThemeData(
                                    thumbVisibility: WidgetStateProperty.all(
                                      true,
                                    ),
                                    thickness: WidgetStateProperty.all(5),
                                    radius: const Radius.circular(4),
                                    thumbColor: WidgetStateProperty.all(
                                      Colors.grey[300],
                                    ),
                                  ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!widget.hideSelectedFieldWhenOpen)
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setState(() => displayOverly = false);
                                    },
                                    child: Padding(
                                      padding: widget.headerPadding ??
                                          _defaultHeaderPadding,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: switch (
                                                widget.dropdownType) {
                                              _DropdownType.singleSelect =>
                                                selectedItem != null
                                                    ? headerBuilder(context)
                                                    : hintBuilder(context),
                                              _DropdownType.multipleSelect =>
                                                selectedItems.isNotEmpty
                                                    ? headerListBuilder(context)
                                                    : hintBuilder(context),
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          decoration?.expandedSuffixIcon ??
                                              _defaultOverlayIconUp,
                                        ],
                                      ),
                                    ),
                                  ),
                                if (onSearch &&
                                    widget.searchType == _SearchType.onListData)
                                  if (!widget.hideSelectedFieldWhenOpen)
                                    _SearchField<T>.forListData(
                                      items: widget.items,
                                      searchHintText: widget.searchHintText,
                                      onSearchedItems: (val) {
                                        setState(() => items = val);
                                      },
                                      decoration:
                                          decoration?.searchFieldDecoration,
                                      closeDropDownOnClearFilterSearch: widget
                                          .closeDropDownOnClearFilterSearch,
                                      closeDropDown: closeDropDown,
                                      autofocusOnSearchField:
                                          widget.autofocusOnSearchField,
                                    )
                                  else
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() => displayOverly = false);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          top: 12.0,
                                          start: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  _SearchField<T>.forListData(
                                                items: widget.items,
                                                searchHintText:
                                                    widget.searchHintText,
                                                onSearchedItems: (val) {
                                                  setState(() => items = val);
                                                },
                                                decoration: decoration
                                                    ?.searchFieldDecoration,
                                                closeDropDownOnClearFilterSearch:
                                                    widget
                                                        .closeDropDownOnClearFilterSearch,
                                                closeDropDown: closeDropDown,
                                                autofocusOnSearchField: widget
                                                    .autofocusOnSearchField,
                                              ),
                                            ),
                                            decoration?.expandedSuffixIcon ??
                                                _defaultOverlayIconUp,
                                            const SizedBox(width: 14),
                                          ],
                                        ),
                                      ),
                                    )
                                else if (onSearch &&
                                    widget.searchType ==
                                        _SearchType.onRequestData)
                                  if (!widget.hideSelectedFieldWhenOpen)
                                    _SearchField<T>.forRequestData(
                                      items: widget.items,
                                      searchHintText: widget.searchHintText,
                                      onFutureRequestLoading: (val) {
                                        setState(() {
                                          isSearchRequestLoading = val;
                                        });
                                      },
                                      futureRequest: widget.futureRequest,
                                      futureRequestDelay:
                                          widget.futureRequestDelay,
                                      onSearchedItems: (val) {
                                        setState(() => items = val);
                                      },
                                      mayFoundResult: (val) =>
                                          mayFoundSearchRequestResult = val,
                                      decoration:
                                          decoration?.searchFieldDecoration,
                                      closeDropDownOnClearFilterSearch: widget
                                          .closeDropDownOnClearFilterSearch,
                                      closeDropDown: closeDropDown,
                                      autofocusOnSearchField:
                                          widget.autofocusOnSearchField,
                                    )
                                  else
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() => displayOverly = false);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          top: 12.0,
                                          start: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _SearchField<
                                                  T>.forRequestData(
                                                items: widget.items,
                                                searchHintText:
                                                    widget.searchHintText,
                                                onFutureRequestLoading: (val) {
                                                  setState(() {
                                                    isSearchRequestLoading =
                                                        val;
                                                  });
                                                },
                                                futureRequest:
                                                    widget.futureRequest,
                                                futureRequestDelay:
                                                    widget.futureRequestDelay,
                                                onSearchedItems: (val) {
                                                  setState(() => items = val);
                                                },
                                                mayFoundResult: (val) =>
                                                    mayFoundSearchRequestResult =
                                                        val,
                                                decoration: decoration
                                                    ?.searchFieldDecoration,
                                                closeDropDownOnClearFilterSearch:
                                                    widget
                                                        .closeDropDownOnClearFilterSearch,
                                                closeDropDown: closeDropDown,
                                                autofocusOnSearchField: widget
                                                    .autofocusOnSearchField,
                                              ),
                                            ),
                                            decoration?.expandedSuffixIcon ??
                                                _defaultOverlayIconUp,
                                            const SizedBox(width: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                if (isSearchRequestLoading)
                                  widget.searchRequestLoadingIndicator ??
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20.0,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      )
                                else
                                  items.length > 4
                                      ? Expanded(child: list)
                                      : list,
                                if (widget.withApplyButton) ...[
                                  applyButtonBuilder(context),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.canCloseOutsideBounds) {
      return Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => displayOverly = false),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),
          child,
        ],
      );
    }

    return child;
  }
}
