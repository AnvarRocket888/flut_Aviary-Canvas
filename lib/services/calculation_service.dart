import '../models/aviary_scheme.dart';
import '../utils/constants.dart';

// ── Result types ──────────────────────────────────────────────────────────────

class CalcResult {
  final bool   isOk;
  final String message;
  final String? recommendation;
  final double? actual;
  final double? recommended;

  const CalcResult({
    required this.isOk,
    required this.message,
    this.recommendation,
    this.actual,
    this.recommended,
  });
}

class PerchCalc {
  final double neededM;
  final double availableM;
  final double recommendedHeightM;
  final double recommendedSpacingM;
  final bool   isSufficient;

  const PerchCalc({
    required this.neededM,
    required this.availableM,
    required this.recommendedHeightM,
    required this.recommendedSpacingM,
    required this.isSufficient,
  });
}

class AviaryCalcBundle {
  final CalcResult        space;
  final CalcResult        feeders;
  final CalcResult        water;
  final CalcResult        nesting;
  final CalcResult        perch;
  final List<CalcResult>  conflicts;
  final PerchCalc?        perchDetails;

  const AviaryCalcBundle({
    required this.space,
    required this.feeders,
    required this.water,
    required this.nesting,
    required this.perch,
    required this.conflicts,
    this.perchDetails,
  });

  bool get allGreen =>
      space.isOk && feeders.isOk && water.isOk &&
      nesting.isOk && perch.isOk && conflicts.isEmpty;

  bool get hasConflicts => conflicts.isNotEmpty;
}

// ── Service ────────────────────────────────────────────────────────────────────

class CalculationService {
  static final CalculationService instance = CalculationService._();
  CalculationService._();

  /// Run all calculations for a saved scheme.
  AviaryCalcBundle calculate(AviaryScheme scheme) {
    final zones      = scheme.zoneCellCounts;
    final birds      = scheme.birdCounts;
    final totalBirds = scheme.totalBirds;

    return AviaryCalcBundle(
      space:        _space(scheme, birds, totalBirds),
      feeders:      _feeders(zones, birds, totalBirds),
      water:        _water(zones, totalBirds),
      nesting:      _nesting(zones, birds, totalBirds),
      perch:        _perch(zones, birds, totalBirds),
      conflicts:    _conflicts(scheme),
      perchDetails: _perchDetails(zones, birds),
    );
  }

  /// Run all calculations for arbitrary species+count map (Calculator screen).
  AviaryCalcBundle calculateStandalone({
    required Map<String, int> birdCounts,
    required double totalAreaM2,
    required int feederCells,
    required int waterCells,
    required int nestCells,
    required int perchCells,
  }) {
    final int totalBirds = birdCounts.values.fold(0, (a, b) => a + b);
    final zones = <int, int>{
      1: feederCells,
      2: waterCells,
      3: nestCells,
      4: perchCells,
    };

    // Build a fake scheme-like object for the checks
    double minSpace = 0;
    for (final e in birdCounts.entries) {
      minSpace += (AppConstants.minSpacePerBird[e.key] ?? 0.5) * e.value;
    }
    final spaceOk = totalAreaM2 >= minSpace;

    return AviaryCalcBundle(
      space:    CalcResult(
        isOk:           spaceOk,
        message:        spaceOk
            ? 'Space sufficient: ${totalAreaM2.toStringAsFixed(1)} m² for $totalBirds birds.'
            : 'Insufficient: ${totalAreaM2.toStringAsFixed(1)} m² available, ${minSpace.toStringAsFixed(1)} m² needed.',
        actual:      totalAreaM2,
        recommended: minSpace,
        recommendation: spaceOk ? null : 'Increase aviary size by at least ${(minSpace - totalAreaM2).toStringAsFixed(1)} m².',
      ),
      feeders:  _feeders(zones, birdCounts, totalBirds),
      water:    _water(zones, totalBirds),
      nesting:  _nesting(zones, birdCounts, totalBirds),
      perch:    _perch(zones, birdCounts, totalBirds),
      conflicts: [],
      perchDetails: _perchDetails(zones, birdCounts),
    );
  }

  // ── Private helpers ───────────────────────────────────────

  CalcResult _space(AviaryScheme s, Map<String, int> birds, int total) {
    if (total == 0) {
      return const CalcResult(
        isOk:           true,
        message:        'No birds added yet.',
        recommendation: 'Add species and counts to check space.',
      );
    }
    double min = 0;
    for (final e in birds.entries) {
      min += (AppConstants.minSpacePerBird[e.key] ?? 0.5) * e.value;
    }
    final area = s.totalAreaM2;
    final ok   = area >= min;
    return CalcResult(
      isOk:        ok,
      message:     ok
          ? 'Space sufficient: ${area.toStringAsFixed(1)} m² for $total birds.'
          : 'Insufficient space: ${area.toStringAsFixed(1)} m² available, ${min.toStringAsFixed(1)} m² needed.',
      actual:      area,
      recommended: min,
      recommendation: ok ? null
          : 'Add ${((min - area) / s.cellAreaM2).ceil()} more cells or reduce bird count.',
    );
  }

  CalcResult _feeders(Map<int, int> zones, Map<String, int> birds, int total) {
    if (total == 0) return const CalcResult(isOk: true, message: 'No birds added yet.');
    final cells = zones[1] ?? 0;
    if (cells == 0) {
      return const CalcResult(
        isOk: false,
        message: 'No feeding areas designated.',
        recommendation: 'Add at least one Feeding Area zone.',
      );
    }
    int min = 0;
    for (final e in birds.entries) {
      final ratio = AppConstants.feedersPerBirds[e.key] ?? 10;
      min += (e.value / ratio).ceil();
    }
    final ok = cells >= min;
    return CalcResult(
      isOk:        ok,
      message:     ok
          ? 'Feeding adequate: $cells cells for $total birds.'
          : 'Insufficient feeders: $cells cells, $min needed.',
      actual:      cells.toDouble(),
      recommended: min.toDouble(),
      recommendation: ok ? null : 'Add ${min - cells} more Feeding Area cells.',
    );
  }

  CalcResult _water(Map<int, int> zones, int total) {
    if (total == 0) return const CalcResult(isOk: true, message: 'No birds added yet.');
    final cells = zones[2] ?? 0;
    if (cells == 0) {
      return const CalcResult(
        isOk: false,
        message: 'No water sources designated.',
        recommendation: 'Add at least one Water Source zone.',
      );
    }
    final min = (total / 15).ceil();
    final ok  = cells >= min;
    return CalcResult(
      isOk:        ok,
      message:     ok
          ? 'Water adequate: $cells cells for $total birds.'
          : 'Insufficient water: $cells cells, $min needed.',
      actual:      cells.toDouble(),
      recommended: min.toDouble(),
      recommendation: ok ? null : 'Add ${min - cells} more Water Source cells.',
    );
  }

  CalcResult _nesting(Map<int, int> zones, Map<String, int> birds, int total) {
    final nestingBirds = birds.entries
        .where((e) => !['Duck', 'Goose'].contains(e.key))
        .fold(0, (s, e) => s + e.value);
    if (nestingBirds == 0) {
      return const CalcResult(isOk: true, message: 'No nesting birds in scheme.');
    }
    final cells = zones[3] ?? 0;
    if (cells == 0) {
      return const CalcResult(
        isOk: false,
        message: 'No nesting boxes designated.',
        recommendation: 'Add Nesting Box zones for egg-laying birds.',
      );
    }
    final min = (nestingBirds / 4).ceil();
    final ok  = cells >= min;
    return CalcResult(
      isOk:        ok,
      message:     ok
          ? 'Nesting adequate: $cells cells for $nestingBirds birds.'
          : 'Insufficient nesting: $cells cells, $min needed.',
      actual:      cells.toDouble(),
      recommended: min.toDouble(),
      recommendation: ok ? null : 'Add ${min - cells} more Nesting Box cells.',
    );
  }

  CalcResult _perch(Map<int, int> zones, Map<String, int> birds, int total) {
    double needed = 0;
    bool   hasPerching = false;
    for (final e in birds.entries) {
      final l = AppConstants.perchLengthPerBird[e.key] ?? 0.2;
      if (l > 0) { needed += l * e.value; hasPerching = true; }
    }
    if (!hasPerching || total == 0) {
      return const CalcResult(isOk: true, message: 'No perching birds in scheme.');
    }
    final available = (zones[4] ?? 0) * 0.5;
    final ok        = available >= needed;
    return CalcResult(
      isOk:        ok,
      message:     ok
          ? 'Perch space adequate: ${available.toStringAsFixed(1)} m available, ${needed.toStringAsFixed(1)} m needed.'
          : 'Insufficient perch: ${available.toStringAsFixed(1)} m available, ${needed.toStringAsFixed(1)} m needed.',
      actual:      available,
      recommended: needed,
      recommendation: ok ? null
          : 'Add ${((needed - available) / 0.5).ceil()} more Perch cells.',
    );
  }

  List<CalcResult> _conflicts(AviaryScheme scheme) {
    final list  = <CalcResult>[];
    final birds = scheme.birdCounts;

    final raptors    = birds.keys.any((k) => k == 'Falcon' || k == 'Pheasant');
    final smallBirds = birds.keys.any((k) => k == 'Canary' || k == 'Quail');
    if (raptors && smallBirds) {
      list.add(const CalcResult(
        isOk:           false,
        message:        'Predator/prey conflict: raptors and small birds together.',
        recommendation: 'Separate Falcon/Pheasant from Canary/Quail.',
      ));
    }

    final zones = scheme.zoneCellCounts;
    if ((zones[8] ?? 0) == 0 && scheme.totalBirds > 0) {
      list.add(const CalcResult(
        isOk:           false,
        message:        'No Entry/Exit zone defined.',
        recommendation: 'Add an Entry/Exit zone for practical management.',
      ));
    }
    return list;
  }

  PerchCalc? _perchDetails(Map<int, int> zones, Map<String, int> birds) {
    double needed = 0;
    bool   any    = false;
    for (final e in birds.entries) {
      final l = AppConstants.perchLengthPerBird[e.key] ?? 0.2;
      if (l > 0) { needed += l * e.value; any = true; }
    }
    if (!any) return null;
    final avail = (zones[4] ?? 0) * 0.5;
    return PerchCalc(
      neededM:              needed,
      availableM:           avail,
      recommendedHeightM:   1.2,
      recommendedSpacingM:  0.35,
      isSufficient:         avail >= needed,
    );
  }
}
