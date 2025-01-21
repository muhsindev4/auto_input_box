import 'package:flutter/material.dart';

class AutoInputBox<T> extends StatefulWidget {
  /// The text editing controller to manage the input field's text.
  final TextEditingController textEditingController;

  /// The input decoration for the text field.
  final InputDecoration inputDecoration;

  /// The text style for the text field.
  final TextStyle textStyle;

  /// The debounce time (in milliseconds) for filtering suggestions as the user types.
  final int debounceTime;

  /// The list of suggestions to be displayed.
  final List<T> suggestions;

  /// A function to convert a suggestion object into a displayable string.
  final String Function(T) toDisplayString;

  /// A callback triggered when a suggestion is selected.
  final ValueChanged<T>? onItemSelected;

  /// A custom widget for a text input field with auto-completion functionality.
  /// This widget displays suggestions in a dropdown list based on the user's input.
  ///
  /// [T] is the type of the items in the suggestion list. You can pass any type
  /// of object, and the widget will use the `toDisplayString` function to determine
  /// the text to display for each item.
  const AutoInputBox({
    super.key,
    required this.textEditingController,
    this.inputDecoration = const InputDecoration(),
    this.textStyle = const TextStyle(),
    this.debounceTime = 300,
    required this.suggestions,
    required this.toDisplayString,
    this.onItemSelected,
  });

  @override
  _AutoInputBoxState<T> createState() => _AutoInputBoxState<T>();
}

class _AutoInputBoxState<T> extends State<AutoInputBox<T>> {
  /// The overlay entry for displaying the suggestions dropdown.
  late OverlayEntry _overlayEntry;

  /// A link to position the overlay relative to the text field.
  final LayerLink _layerLink = LayerLink();

  /// The filtered list of suggestions based on user input.
  List<T> _filteredSuggestions = [];

  /// A flag to track if the overlay is currently visible.
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to clear the overlay when the text field is cleared.
    widget.textEditingController.addListener(_onEditorListener);
  }

  /// Called when the text in the text field changes.
  void _onTextChanged(String text) {
    if (text.isEmpty) {
      _removeOverlay();
      return;
    }

    // Filter suggestions based on the user's input.
    _filteredSuggestions = widget.suggestions
        .where((item) => widget
            .toDisplayString(item)
            .toLowerCase()
            .contains(text.toLowerCase()))
        .toList();

    if (_filteredSuggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  /// Called when the text field's text is cleared.
  void _onEditorListener() {
    if (widget.textEditingController.text.isEmpty) {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    if (_isOverlayVisible) _removeOverlay(); // Remove the overlay if visible.
    super.dispose();
  }

  /// Displays the suggestions dropdown overlay.
  void _showOverlay() {
    if (_isOverlayVisible) _removeOverlay(); // Remove any existing overlay.

    _overlayEntry = _createOverlayEntry(); // Create a new overlay entry.
    Overlay.of(context)
        .insert(_overlayEntry); // Insert the overlay into the view.
    _isOverlayVisible = true;
  }

  /// Removes the suggestions dropdown overlay.
  void _removeOverlay() {
    if (_isOverlayVisible) {
      _overlayEntry.remove();
      _isOverlayVisible = false;
    }
  }

  /// Creates the overlay entry for the suggestions dropdown.
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 2,
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    title: Text(widget.toDisplayString(suggestion)),
                    onTap: () {
                      // Update the text field with the selected suggestion.
                      widget.textEditingController.text =
                          widget.toDisplayString(suggestion);

                      // Trigger the item selected callback.
                      widget.onItemSelected?.call(suggestion);

                      // Remove the overlay.
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.textEditingController,
        decoration: widget.inputDecoration,
        style: widget.textStyle,
        onChanged: _onTextChanged, // Add text changes to the debounce stream.
      ),
    );
  }
}
