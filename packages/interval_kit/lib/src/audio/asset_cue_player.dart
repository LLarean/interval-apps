import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'cue.dart';
import 'cue_player.dart';

/// Plays the bundled cue sounds.
///
/// Each cue has its own preloaded player, so a cue starts without delay and
/// several cues may overlap. Cues duck other apps' audio instead of stopping
/// it, so the user's music keeps playing underneath.
final class AssetCuePlayer implements CuePlayer {
  AssetCuePlayer._(this._players);

  /// Loads every cue; await before the first [play].
  static Future<AssetCuePlayer> load() async {
    final cache = AudioCache(prefix: 'packages/interval_kit/assets/sounds/');
    final context = AudioContextConfig(
      focus: AudioContextConfigFocus.duckOthers,
    ).build();

    final players = <Cue, AudioPlayer>{};
    for (final cue in Cue.values) {
      final player = AudioPlayer()..audioCache = cache;
      await player.setAudioContext(context);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource('${cue.name}.mp3'));
      players[cue] = player;
    }
    return AssetCuePlayer._(players);
  }

  final Map<Cue, AudioPlayer> _players;

  @override
  Future<void> play(Cue cue) async {
    final player = _players[cue]!;
    await player.stop();
    await player.resume();
  }

  @override
  Future<void> dispose() async {
    await Future.wait(_players.values.map((player) => player.dispose()));
  }
}
