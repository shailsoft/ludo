import 'models.dart';

abstract final class LudoBoard {
  static const trackLength = 52;
  static const finishProgress = 57;
  static const startOffsets = <PlayerColor, int>{
    PlayerColor.red: 0,
    PlayerColor.green: 13,
    PlayerColor.yellow: 26,
    PlayerColor.blue: 39,
  };

  static const defaultSafeSquares = <int>{0, 8, 13, 21, 26, 34, 39, 47};

  static int absoluteTrackIndex(PlayerColor color, int progress) {
    if (progress < 0 || progress >= trackLength) {
      throw RangeError.range(progress, 0, trackLength - 1, 'progress');
    }
    return (startOffsets[color]! + progress) % trackLength;
  }
}
