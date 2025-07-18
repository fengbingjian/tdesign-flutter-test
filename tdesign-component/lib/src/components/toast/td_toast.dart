import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../tdesign_flutter.dart';
import '../../util/auto_size.dart';
import '../../util/context_extension.dart';

enum IconTextDirection {
  horizontal, //横向
  vertical //竖向
}

class TDToast {
  /// 普通文本Toast
  static void showText(String? text,
      {required BuildContext context,
      Duration duration = TDToast._defaultDisPlayDuration,
      int? maxLines,
      BoxConstraints? constraints,
      bool? preventTap,
      Widget? customWidget,
      Color? backgroundColor}) {
    _showOverlay(
        _TDTextToast(text: text, maxLines: maxLines, constraints: constraints, customWidget: customWidget,),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 带图标的Toast
  static void showIconText(String? text,
      {IconData? icon,
      IconTextDirection direction = IconTextDirection.horizontal,
      required BuildContext context,
      Duration duration = TDToast._defaultDisPlayDuration,
      bool? preventTap,
      Color? backgroundColor,
      int? maxLines}) {
    _showOverlay(
        _TDIconTextToast(
          text: text,
          iconData: icon,
          iconTextDirection: direction,
          maxLines: maxLines,
        ),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 成功提示Toast
  static void showSuccess(String? text,
      {IconTextDirection direction = IconTextDirection.horizontal,
      required BuildContext context,
      Duration duration = TDToast._defaultDisPlayDuration,
      bool? preventTap,
      Color? backgroundColor,
      int? maxLines}) {
    _showOverlay(
        _TDIconTextToast(
          text: text,
          iconData: TDIcons.check_circle,
          iconTextDirection: direction,
          maxLines: maxLines,
        ),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 警告Toast
  static void showWarning(String? text,
      {IconTextDirection direction = IconTextDirection.horizontal,
      required BuildContext context,
      Duration duration = TDToast._defaultDisPlayDuration,
      bool? preventTap,
      Color? backgroundColor,
      int? maxLines}) {
    _showOverlay(
        _TDIconTextToast(
          text: text,
          iconData: TDIcons.error_circle,
          iconTextDirection: direction,
          maxLines: maxLines,
        ),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 失败提示Toast
  static void showFail(String? text,
      {IconTextDirection direction = IconTextDirection.horizontal,
      required BuildContext context,
      Duration duration = TDToast._defaultDisPlayDuration,
      bool? preventTap,
      Color? backgroundColor,
      int? maxLines}) {
    _showOverlay(
        _TDIconTextToast(
          text: text,
          iconData: TDIcons.close_circle,
          iconTextDirection: direction,
          maxLines: maxLines,
        ),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 带文案的加载Toast
  static void showLoading(
      {required BuildContext context,
        String? text,
        Duration duration = TDToast._infiniteDuration,
        bool? preventTap,
        Widget? customWidget,
        Color? backgroundColor}) {
    _showOverlay(
        _TDToastLoading(
          text: text,
          customWidget: customWidget,
        ),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 不带文案的加载Toast
  static void showLoadingWithoutText(
      {required BuildContext context,
        String? text,
        Duration duration = TDToast._infiniteDuration,
        bool? preventTap,
        Color? backgroundColor}) {
    _showOverlay(
        const _TDToastLoadingWithoutText(),
        context: context,
        duration: duration,
        preventTap: preventTap,
        backgroundColor: backgroundColor);
  }

  /// 关闭加载Toast
  static void dismissLoading() {
    _cancel();
  }

  static void _showOverlay(Widget? widget,
      {required BuildContext context,
        Duration duration = TDToast._defaultDisPlayDuration,
        bool? preventTap,
        Color? backgroundColor}) {
    _cancel();
    _showing = true;
    var overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
        builder: (BuildContext context) => Center(
          child: AnimatedOpacity(
            opacity: _showing ? 1.0 : 0.0,
            duration: _showing ? const Duration(milliseconds: 100) : const Duration(milliseconds: 200),
            child: widget,
          ),
        ));

    if(preventTap ?? false) {
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            child: Container(
              color: backgroundColor,
              child: Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: _showing ? 1.0 : 0.0,
                  duration: _showing ? const Duration(milliseconds: 100) : const Duration(milliseconds: 200),
                  child: widget,
                ),
              ),
            ),
          ),
      );
    }
    if (_overlayEntry != null) {
      overlayState?.insert(_overlayEntry!);
    }
    _startTimer(duration);
  }

  static void _cancel() {
    _timer?.cancel();
    _timer = null;
    _disposeTimer?.cancel();
    _disposeTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showing = false;
  }

  static void _startTimer(Duration duration) {
    _timer?.cancel();
    _disposeTimer?.cancel();
    _timer = Timer(duration, () {
      _showing = false;
      _overlayEntry?.markNeedsBuild();
      _timer = null;
      _disposeTimer = Timer(const Duration(milliseconds: 200), () {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _disposeTimer = null;
      });
    });
  }

  static OverlayEntry? _overlayEntry;
  static bool _showing = false;
  static Timer? _timer;
  static Timer? _disposeTimer;
  static const Duration _defaultDisPlayDuration = Duration(milliseconds: 3000);
  static const Duration _infiniteDuration = Duration(seconds: 99999999);
}

class _TDIconTextToast extends StatelessWidget {
  final String? text;
  final IconData? iconData;
  final IconTextDirection iconTextDirection;
  final int? maxLines;

  const _TDIconTextToast({this.text, this.iconData, this.iconTextDirection = IconTextDirection.horizontal, this.maxLines});

  Widget buildHorizontalWidgets(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 191, maxHeight: 94),
      child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          decoration: BoxDecoration(
            color: TDTheme.of(context).fontGyColor1,
            borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 24,
                color: TDTheme.of(context).whiteColor1,
              ),
              const SizedBox(
                width: 8,
              ),
              TDText(
                text ?? '',
                font: TDTheme.of(context).fontBodyMedium,
                fontWeight: FontWeight.w400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textColor: TDTheme.of(context).whiteColor1,
              )
            ],
          )),
    );
  }

  Widget buildVerticalWidgets(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 136),
        child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TDTheme.of(context).fontGyColor1,
              borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  size: 32,
                  color: TDTheme.of(context).whiteColor1,
                ),
                const SizedBox(
                  height: 8,
                ),
                TDText(
                  text ?? '',
                  font: TDTheme.of(context).fontBodyMedium,
                  fontWeight: FontWeight.w400,
                  maxLines: maxLines ?? 1,
                  overflow: TextOverflow.ellipsis,
                  textColor: TDTheme.of(context).whiteColor1,
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return iconTextDirection == IconTextDirection.horizontal
        ? buildHorizontalWidgets(context)
        : buildVerticalWidgets(context);
  }
}

class _TDToastLoading extends StatelessWidget {
  final String? text;

  final Widget? customWidget;

  const _TDToastLoading({this.text, this.customWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TDTheme.of(context).fontGyColor1,
          borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            TDCircleIndicator(
              color: TDTheme.of(context).whiteColor1,
              size: 26,
              lineWidth: 4,
            ),
            const SizedBox(
              height: 8,
            ),
            customWidget ?? TDText(
              text ?? context.resource.loadingWithPoint,
              font: TDTheme.of(context).fontBodyMedium,
              fontWeight: FontWeight.w400,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textColor: TDTheme.of(context).whiteColor1,
            )
          ],
        ));
  }
}

class _TDToastLoadingWithoutText extends StatelessWidget {
  const _TDToastLoadingWithoutText();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: TDTheme.of(context).fontGyColor1,
          borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
        ),
        child: TDCircleIndicator(
          color: TDTheme.of(context).whiteColor1,
          size: 26,
          lineWidth: 4,
        ));
  }
}

class _TDTextToast extends StatelessWidget {
  final String? text;

  final int? maxLines;

  final BoxConstraints? constraints;

  final Widget? customWidget;

  const _TDTextToast({this.text, this.maxLines, this.constraints, this.customWidget});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints ?? BoxConstraints(maxWidth: 191.scale),
      child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            color: TDTheme.of(context).fontGyColor1,
            borderRadius: BorderRadius.circular(TDTheme.of(context).radiusDefault),
          ),
          child: customWidget ?? TDText(
            text ?? '',
            font: TDTheme.of(context).fontBodyMedium,
            fontWeight: FontWeight.w400,
            maxLines: maxLines ?? 3,
            overflow: TextOverflow.ellipsis,
            textColor: TDTheme.of(context).whiteColor1,
          )),
    );
  }
}
