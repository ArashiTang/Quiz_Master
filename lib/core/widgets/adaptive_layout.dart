import 'package:flutter/widgets.dart';

/// Responsive layout helper that adjusts to parent constraints instead of
/// relying only on screen size.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.builder,
    this.mediumBreakpoint = 640,
    this.expandedBreakpoint = 1024,
    this.maxContentWidth = 1100,
    this.padding,
  });

  /// Builder invoked with the computed layout data.
  final Widget Function(BuildContext context, AdaptiveLayoutData layout) builder;

  /// Width (from parent constraints) above which the layout switches to medium.
  final double mediumBreakpoint;

  /// Width (from parent constraints) above which the layout switches to expanded.
  final double expandedBreakpoint;

  /// Maximum readable width when the layout is expanded.
  final double maxContentWidth;

  /// Optional custom padding. If null, sensible defaults based on breakpoints
  /// are used.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseLayout = _resolve(constraints);
        final resolvedPadding = padding ?? baseLayout.pagePadding;
        final layout = baseLayout.copyWith(pagePadding: resolvedPadding);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxWidth),
            child: Padding(
              padding: resolvedPadding,
              child: builder(context, layout),
            ),
          ),
        );
      },
    );
  }

  AdaptiveLayoutData _resolve(BoxConstraints constraints) {
    final width = constraints.maxWidth;

    final size = width < mediumBreakpoint
        ? AdaptiveLayoutSize.compact
        : width < expandedBreakpoint
        ? AdaptiveLayoutSize.medium
        : AdaptiveLayoutSize.expanded;

    final gutter = switch (size) {
      AdaptiveLayoutSize.compact => 12.0,
      AdaptiveLayoutSize.medium => 16.0,
      AdaptiveLayoutSize.expanded => 20.0,
    };

    final pagePadding = switch (size) {
      AdaptiveLayoutSize.compact => const EdgeInsets.symmetric(horizontal: 12),
      AdaptiveLayoutSize.medium => const EdgeInsets.symmetric(horizontal: 20),
      AdaptiveLayoutSize.expanded => const EdgeInsets.symmetric(horizontal: 28),
    };

    return AdaptiveLayoutData(
      size: size,
      maxWidth: size == AdaptiveLayoutSize.expanded ? maxContentWidth : width,
      pagePadding: pagePadding,
      gutter: gutter,
      constraints: constraints,
    );
  }
}

enum AdaptiveLayoutSize { compact, medium, expanded }

class AdaptiveLayoutData {
  const AdaptiveLayoutData({
    required this.size,
    required this.maxWidth,
    required this.pagePadding,
    required this.gutter,
    required this.constraints,
  });

  final AdaptiveLayoutSize size;
  final double maxWidth;
  final EdgeInsets pagePadding;
  final double gutter;
  final BoxConstraints constraints;

  bool get isCompact => size == AdaptiveLayoutSize.compact;
  bool get isMedium => size == AdaptiveLayoutSize.medium;
  bool get isExpanded => size == AdaptiveLayoutSize.expanded;

  AdaptiveLayoutData copyWith({
    AdaptiveLayoutSize? size,
    double? maxWidth,
    EdgeInsets? pagePadding,
    double? gutter,
    BoxConstraints? constraints,
  }) {
    return AdaptiveLayoutData(
      size: size ?? this.size,
      maxWidth: maxWidth ?? this.maxWidth,
      pagePadding: pagePadding ?? this.pagePadding,
      gutter: gutter ?? this.gutter,
      constraints: constraints ?? this.constraints,
    );
  }
}