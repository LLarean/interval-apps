import 'package:flutter/material.dart';
import 'package:interval_kit/interval_kit.dart';
import 'package:interval_media/interval_media.dart';

import '../../l10n/generated/app_localizations.dart';

/// The tracks played during one pace, with buttons to add and remove them.
class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({
    required this.library,
    required this.intensity,
    required this.title,
    super.key,
  });

  final MusicLibrary library;
  final Intensity intensity;
  final String title;

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  var _adding = false;

  Future<void> _add() async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).musicAddFailed;
    setState(() => _adding = true);
    try {
      await widget.library.choose(widget.intensity);
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.library,
      builder: (context, _) {
        final tracks = widget.library.value[widget.intensity];

        return SettingsPage(
          title: widget.title,
          children: [
            if (tracks.isEmpty)
              Text(
                l10n.musicEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: IntervalColors.of(context).muted),
              )
            else
              Column(
                spacing: 8,
                children: [
                  for (final track in tracks)
                    _TrackPlate(
                      track: track,
                      removeLabel: l10n.musicRemove(track.title),
                      onRemove: () =>
                          widget.library.remove(widget.intensity, track),
                    ),
                ],
              ),
            if (_adding)
              const CircularProgressIndicator()
            else
              FlatTextButton(label: l10n.musicAdd, onPressed: _add),
          ],
        );
      },
    );
  }
}

class _TrackPlate extends StatelessWidget {
  const _TrackPlate({
    required this.track,
    required this.removeLabel,
    required this.onRemove,
  });

  final Track track;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = IntervalColors.of(context);

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surface,
        shape: const StadiumBorder(),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 8),
          child: Row(
            children: [
              Icon(Icons.music_note_outlined, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  track.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 24, semanticLabel: removeLabel),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
