library responsive_text_field;

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ResponsiveTextField extends StatefulWidget {
  const ResponsiveTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    required this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    required this.maxLines,
    required this.minLines,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    required this.availableWidth,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.onTap,
    this.buildCounter,
    this.scrollPhysics,
  })  : assert(textAlign != null),
        assert(autofocus != null),
        assert(obscureText != null),
        assert(autocorrect != null),
        assert(maxLengthEnforced != null),
        assert(scrollPadding != null),
        assert(dragStartBehavior != null),
        assert(maxLines != null && maxLines > 1),
        assert(minLines != null && minLines > 0),
        assert(
          (maxLines != null) && (minLines != null) && (maxLines >= minLines),
          'minLines can\'t be greater than maxLines',
        ),
        assert(maxLength == null ||
            maxLength == ResponsiveTextField.noMaxLength ||
            maxLength > 0),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        super(key: key);
  final TextEditingController? controller;
  final double availableWidth;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final int? maxLines;
  final int? minLines;
  static const int noMaxLength = -1;
  final int? maxLength;
  final bool maxLengthEnforced;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final DragStartBehavior dragStartBehavior;
  bool get selectionEnabled {
    return enableInteractiveSelection ?? !obscureText;
  }

  final GestureTapCallback? onTap;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;

  @override
  _ResponsiveTextFieldState createState() => _ResponsiveTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'controller', controller,
        defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
        defaultValue: null));
    properties
        .add(DiagnosticsProperty<bool>('enabled', enabled, defaultValue: null));
    properties.add(DiagnosticsProperty<InputDecoration>(
        'decoration', decoration,
        defaultValue: const InputDecoration()));
    properties.add(DiagnosticsProperty<TextInputType>(
        'keyboardType', keyboardType,
        defaultValue: TextInputType.text));
    properties.add(
        DiagnosticsProperty<TextStyle>('style', style, defaultValue: null));
    properties.add(
        DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText,
        defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('autocorrect', autocorrect,
        defaultValue: true));
    properties.add(IntProperty('maxLines', maxLines, defaultValue: 1));
    properties.add(IntProperty('minLines', minLines, defaultValue: null));
    properties.add(IntProperty('maxLength', maxLength, defaultValue: null));
    properties.add(FlagProperty('maxLengthEnforced',
        value: maxLengthEnforced,
        defaultValue: true,
        ifFalse: 'maxLength not enforced'));
    properties.add(EnumProperty<TextInputAction>(
        'textInputAction', textInputAction,
        defaultValue: null));
    properties.add(EnumProperty<TextCapitalization>(
        'textCapitalization', textCapitalization,
        defaultValue: TextCapitalization.none));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: TextAlign.start));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties
        .add(DoubleProperty('cursorWidth', cursorWidth, defaultValue: 2.0));
    properties.add(DiagnosticsProperty<Radius>('cursorRadius', cursorRadius,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Color>('cursorColor', cursorColor,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Brightness>(
        'keyboardAppearance', keyboardAppearance,
        defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'scrollPadding', scrollPadding,
        defaultValue: const EdgeInsets.all(20.0)));
    properties.add(FlagProperty('selectionEnabled',
        value: selectionEnabled,
        defaultValue: true,
        ifFalse: 'selection disabled'));
    properties.add(DiagnosticsProperty<ScrollPhysics>(
        'scrollPhysics', scrollPhysics,
        defaultValue: null));
  }
}

class _ResponsiveTextFieldState extends State<ResponsiveTextField>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<EditableTextState> _editableTextKey =
      GlobalKey<EditableTextState>();
  Set<InteractiveInkFeature>? _splashes;
  InteractiveInkFeature? _currentSplash;
  int? lines;
  TextEditingController? _controller;
  TextEditingController? get _effectiveController =>
      widget.controller ?? _controller;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  bool get needsCounter =>
      widget.maxLength != null &&
      widget.decoration != null &&
      widget.decoration!.counterText == null;

  InputDecoration _getEffectiveDecoration() {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final InputDecoration effectiveDecoration =
        (widget.decoration ?? const InputDecoration())
            .applyDefaults(themeData.inputDecorationTheme)
            .copyWith(
              enabled: widget.enabled,
              hintMaxLines: widget.decoration?.hintMaxLines ?? widget.maxLines,
            );

    // No need to build anything if counter or counterText were given directly.
    if (effectiveDecoration.counter != null ||
        effectiveDecoration.counterText != null) return effectiveDecoration;

    // If buildCounter was provided, use it to generate a counter widget.
    Widget counter;
    final int currentLength = _effectiveController!.value.text.runes.length;
    if (effectiveDecoration.counter == null &&
        effectiveDecoration.counterText == null &&
        widget.buildCounter != null) {
      final bool isFocused = _effectiveFocusNode.hasFocus;
      counter = Semantics(
        container: true,
        liveRegion: isFocused,
        child: widget.buildCounter!(
          context,
          currentLength: currentLength,
          maxLength: widget.maxLength,
          isFocused: isFocused,
        ),
      );
      return effectiveDecoration.copyWith(counter: counter);
    }

    if (widget.maxLength == null)
      return effectiveDecoration; // No counter widget

    String counterText = '$currentLength';
    String semanticCounterText = '';

    // Handle a real maxLength (positive number)
    if (widget.maxLength! > 0) {
      // Show the maxLength in the counter
      counterText += '/${widget.maxLength}';
      final int remaining =
          (widget.maxLength! - currentLength).clamp(0, widget.maxLength!);
      semanticCounterText =
          localizations.remainingTextFieldCharacterCount(remaining);

      // Handle length exceeds maxLength
      if (_effectiveController!.value.text.runes.length > widget.maxLength!) {
        return effectiveDecoration.copyWith(
          errorText: effectiveDecoration.errorText ?? '',
          counterStyle: effectiveDecoration.errorStyle ??
              themeData.textTheme.caption!.copyWith(color: themeData.errorColor),
          counterText: counterText,
          semanticCounterText: semanticCounterText,
        );
      }
    }

    return effectiveDecoration.copyWith(
      counterText: counterText,
      semanticCounterText: semanticCounterText,
    );
  }

  Function(String)? onChanged;
  @override
  void initState() {
    super.initState();
    lines = widget.minLines;
    onChanged = (s) {
      _checkSize(s);
      if (widget.onChanged != null) widget.onChanged!(s);
    };
    if (widget.controller == null) _controller = TextEditingController();
  }

  void _checkSize(final String s) {
    final String zs = s.trim();
    final TextSpan tp = TextSpan(text: zs, style: widget.style);
    if (_textFits(tp, lines)) {
      if (lines! > (widget.minLines ?? 1)) {
        if (_textFits(tp, lines! - 1)) {
          setState(() {
            if(lines != null){
              lines = lines! - 1;
            }
          });
        }
      }
    } else {
      if (lines! < (widget.maxLines ?? double.maxFinite.toInt())) {
        setState(() {
          if(lines != null){
            lines = lines! + 1;
          }
        });
      }
    }
  }

  bool _textFits(TextSpan text, int? lines) {
    var tp = TextPainter(
      text: text,
      textAlign: widget.textAlign ?? TextAlign.left,
      textDirection: widget.textDirection ?? TextDirection.ltr,
      textScaleFactor: 1,
      maxLines: lines,
    );
    tp.layout(maxWidth: widget.availableWidth - 4);
    return !(tp.didExceedMaxLines || tp.width > widget.availableWidth);
  }

  @override
  void didUpdateWidget(ResponsiveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null)
      _controller = TextEditingController.fromValue(oldWidget.controller!.value);
    else if (widget.controller != null && oldWidget.controller == null)
      _controller = null;
    final bool isEnabled = widget.enabled ?? widget.decoration?.enabled ?? true;
    final bool wasEnabled =
        oldWidget.enabled ?? oldWidget.decoration?.enabled ?? true;
    if (wasEnabled && !isEnabled) {
      _effectiveFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  void _requestKeyboard() {
    _editableTextKey.currentState?.requestKeyboard();
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    // iOS cursor doesn't move via a selection handle. The scroll happens
    // directly from new text selection changes.
    if(Theme.of(context).platform == TargetPlatform.iOS){
      if (cause == SelectionChangedCause.longPress) {
        _editableTextKey.currentState?.bringIntoView(selection.base);
      }
    }
  }

  InteractiveInkFeature _createInkFeature(Offset globalPosition) {
    final MaterialInkController inkController = Material.of(context)!;
    final ThemeData themeData = Theme.of(context);
    final BuildContext editableContext = _editableTextKey.currentContext!;
    final RenderBox referenceBox =
        InputDecorator.containerOf(editableContext) ??
            editableContext.findRenderObject() as RenderBox;
    final Offset position = referenceBox.globalToLocal(globalPosition);
    final Color color = themeData.splashColor;

    InteractiveInkFeature? splash;
    void handleRemoved() {
      if (_splashes != null) {
        assert(_splashes!.contains(splash));
        _splashes!.remove(splash);
        if (_currentSplash == splash) _currentSplash = null;
        updateKeepAlive();
      } // else we're probably in deactivate()
    }

    splash = themeData.splashFactory.create(
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: true,
      // TODO(hansmuller): splash clip borderRadius should match the input decorator's border.
      borderRadius: BorderRadius.zero,
      onRemoved: handleRemoved,
      textDirection: Directionality.of(context),
    );

    return splash;
  }

  RenderEditable get _renderEditable =>
      _editableTextKey.currentState!.renderEditable;

  void _handleTapDown(TapDownDetails details) {
    _renderEditable.handleTapDown(details);
    _startSplash(details.globalPosition);
  }

  void _handleForcePressStarted(ForcePressDetails details) {
    if (widget.selectionEnabled) {
      _renderEditable.selectWordsInRange(
        from: details.globalPosition,
        cause: SelectionChangedCause.forcePress,
      );
      _editableTextKey.currentState!.showToolbar();
    }
  }

  void _handleSingleTapUp(TapUpDetails details) {
    if (widget.selectionEnabled) {
      switch (Theme.of(context).platform) {
        case TargetPlatform.iOS:
          _renderEditable.selectWordEdge(cause: SelectionChangedCause.tap);
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          _renderEditable.selectPosition(cause: SelectionChangedCause.tap);
          break;
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
      }
    }
    _requestKeyboard();
    _confirmCurrentSplash();
    if (widget.onTap != null) widget.onTap!();
  }

  void _handleSingleTapCancel() {
    _cancelCurrentSplash();
  }

  void _handleSingleLongTapStart(LongPressStartDetails details) {
    if (widget.selectionEnabled) {
      switch (Theme.of(context).platform) {
        case TargetPlatform.iOS:
          _renderEditable.selectPositionAt(
            from: details.globalPosition,
            cause: SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          _renderEditable.selectWord(cause: SelectionChangedCause.longPress);
          Feedback.forLongPress(context);
          break;
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
      }
    }
    _confirmCurrentSplash();
  }

  void _handleSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (widget.selectionEnabled) {
      switch (Theme.of(context).platform) {
        case TargetPlatform.iOS:
          _renderEditable.selectPositionAt(
            from: details.globalPosition,
            cause: SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          _renderEditable.selectWordsInRange(
            from: details.globalPosition - details.offsetFromOrigin,
            to: details.globalPosition,
            cause: SelectionChangedCause.longPress,
          );
          break;
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
      }
    }
  }

  void _handleSingleLongTapEnd(LongPressEndDetails details) {
    _editableTextKey.currentState!.showToolbar();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    if (widget.selectionEnabled) {
      _renderEditable.selectWord(cause: SelectionChangedCause.doubleTap);
      _editableTextKey.currentState!.showToolbar();
    }
  }

  void _handleMouseDragSelectionStart(DragStartDetails details) {
    _renderEditable.selectPositionAt(
      from: details.globalPosition,
      cause: SelectionChangedCause.drag,
    );
    _startSplash(details.globalPosition);
  }

  void _handleMouseDragSelectionUpdate(
    DragStartDetails startDetails,
    DragUpdateDetails updateDetails,
  ) {
    _renderEditable.selectPositionAt(
      from: startDetails.globalPosition,
      to: updateDetails.globalPosition,
      cause: SelectionChangedCause.drag,
    );
  }

  void _startSplash(Offset globalPosition) {
    if (_effectiveFocusNode.hasFocus) return;
    final InteractiveInkFeature splash = _createInkFeature(globalPosition);
    _splashes ??= HashSet<InteractiveInkFeature>();
    _splashes!.add(splash);
    _currentSplash = splash;
    updateKeepAlive();
  }

  void _confirmCurrentSplash() {
    _currentSplash?.confirm();
    _currentSplash = null;
  }

  void _cancelCurrentSplash() {
    _currentSplash?.cancel();
  }

  @override
  bool get wantKeepAlive => _splashes != null && _splashes!.isNotEmpty;

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveInkFeature> splashes = _splashes!;
      _splashes = null;
      for (InteractiveInkFeature splash in splashes) splash.dispose();
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    assert(debugCheckHasMaterial(context));
    // TODO(jonahwilliams): uncomment out this check once we have migrated tests.
    // assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    assert(
      !(widget.style != null &&
          widget.style.inherit == false &&
          (widget.style.fontSize == null || widget.style.textBaseline == null)),
      'inherit false style must supply fontSize and textBaseline',
    );

    final ThemeData themeData = Theme.of(context);
    final TextStyle style = themeData.textTheme.subtitle1!.merge(widget.style);
    final Brightness keyboardAppearance =
        widget.keyboardAppearance ?? themeData.primaryColorBrightness;
    final TextEditingController? controller = _effectiveController;
    final FocusNode focusNode = _effectiveFocusNode;
    final List<TextInputFormatter> formatters =
        widget.inputFormatters ?? <TextInputFormatter>[];
    if (widget.maxLength != null && widget.maxLengthEnforced)
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));

    late bool forcePressEnabled;
    TextSelectionControls? textSelectionControls;
    late bool paintCursorAboveText;
    late bool cursorOpacityAnimates;
    Offset? cursorOffset;
    Color? cursorColor = widget.cursorColor;
    Radius? cursorRadius = widget.cursorRadius;

    switch (themeData.platform) {
      case TargetPlatform.iOS:
        forcePressEnabled = true;
        textSelectionControls = cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        cursorColor ??= CupertinoTheme.of(context).primaryColor;
        cursorRadius ??= const Radius.circular(2.0);
        // An eyeballed value that moves the cursor slightly left of where it is
        // rendered for text on Android so its positioning more accurately matches the
        // native iOS text cursor positioning.
        //
        // This value is in device pixels, not logical pixels as is typically used
        // throughout the codebase.
        const int _iOSHorizontalOffset = -2;
        cursorOffset = Offset(
            _iOSHorizontalOffset / MediaQuery.of(context).devicePixelRatio, 0);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        forcePressEnabled = false;
        textSelectionControls = materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        cursorColor ??= themeData.cursorColor;
        break;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
    }

    Widget child = RepaintBoundary(
      child: EditableText(
        key: _editableTextKey,
        controller: controller!,
        focusNode: focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign!,
        textDirection: widget.textDirection,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        maxLines: lines,
        minLines: widget.minLines,
        expands: false,
        selectionColor: themeData.textSelectionColor,
        selectionControls:
            widget.selectionEnabled ? textSelectionControls : null,
        onChanged: onChanged,
        onSelectionChanged: _handleSelectionChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: formatters,
        rendererIgnoresPointer: true,
        cursorWidth: widget.cursorWidth,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor == null ? CupertinoTheme.of(context).primaryColor: cursorColor!,
        cursorOpacityAnimates: cursorOpacityAnimates,
        cursorOffset: cursorOffset,
        paintCursorAboveText: paintCursorAboveText,
        backgroundCursorColor: CupertinoColors.inactiveGray,
        scrollPadding: widget.scrollPadding,
        keyboardAppearance: keyboardAppearance,
        enableInteractiveSelection: widget.enableInteractiveSelection ?? true,
        dragStartBehavior: widget.dragStartBehavior,
        scrollPhysics: widget.scrollPhysics,
      ),
    );

    if (widget.decoration != null) {
      child = AnimatedBuilder(
        animation: Listenable.merge(<Listenable?>[focusNode, controller]),
        builder: (BuildContext context, Widget? child) {
          return InputDecorator(
            decoration: _getEffectiveDecoration(),
            baseStyle: widget.style,
            textAlign: widget.textAlign,
            isFocused: focusNode.hasFocus,
            isEmpty: controller.value.text.isEmpty,
            expands: false,
            child: child,
          );
        },
        child: child,
      );
    }

    return Semantics(
      onTap: () {
        if (!_effectiveController!.selection.isValid)
          _effectiveController!.selection =
              TextSelection.collapsed(offset: _effectiveController!.text.length);
        _requestKeyboard();
      },
      child: IgnorePointer(
        ignoring: !(widget.enabled ?? widget.decoration?.enabled ?? true),
        child: TextSelectionGestureDetector(
          onTapDown: _handleTapDown,
          onForcePressStart:
              forcePressEnabled ? _handleForcePressStarted : null,
          onSingleTapUp: _handleSingleTapUp,
          onSingleTapCancel: _handleSingleTapCancel,
          onSingleLongTapStart: _handleSingleLongTapStart,
          onSingleLongTapMoveUpdate: _handleSingleLongTapMoveUpdate,
          onSingleLongTapEnd: _handleSingleLongTapEnd,
          onDoubleTapDown: _handleDoubleTapDown,
          onDragSelectionStart: _handleMouseDragSelectionStart,
          onDragSelectionUpdate: _handleMouseDragSelectionUpdate,
          behavior: HitTestBehavior.translucent,
          child: child,
        ),
      ),
    );
  }
}
