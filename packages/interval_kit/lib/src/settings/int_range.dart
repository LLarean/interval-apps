/// Inclusive bounds of an integer setting.
final class IntRange {
  const IntRange(this.min, this.max) : assert(min <= max, 'min must be <= max');

  final int min;
  final int max;

  int clamp(int value) => value.clamp(min, max);

  /// [value] moved by [delta], or `null` if that would leave the range.
  int? step(int value, int delta) {
    final next = value + delta;
    return next < min || next > max ? null : next;
  }
}
