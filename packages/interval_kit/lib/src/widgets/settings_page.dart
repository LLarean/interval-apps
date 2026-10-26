import 'package:flutter/material.dart';

import '../theme/interval_colors.dart';

/// The shell of a settings screen: back button, title and a scrolling list.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.title,
    required this.children,
    this.footer,
    super.key,
  });

  final String title;
  final List<Widget> children;

  /// Small print under the list, e.g. the app version.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: IntervalColors.muted,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            for (final child in children)
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Center(child: child),
              ),
            if (footer case final footer?)
              Align(
                alignment: Alignment.centerRight,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(color: IntervalColors.muted),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
