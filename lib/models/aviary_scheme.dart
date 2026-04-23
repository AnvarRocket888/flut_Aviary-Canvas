import 'dart:convert';

/// An aviary design scheme: name, grid data, bird counts, metadata.
class AviaryScheme {
  final String            id;
  final String            name;
  final int               gridWidth;
  final int               gridHeight;
  final List<List<int>>   grid;        // 0 = empty, 1-8 = zone type
  final Map<String, int>  birdCounts;  // species → count
  final double            cellAreaM2;
  final DateTime          createdAt;
  final DateTime          updatedAt;

  const AviaryScheme({
    required this.id,
    required this.name,
    required this.gridWidth,
    required this.gridHeight,
    required this.grid,
    required this.birdCounts,
    required this.cellAreaM2,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Factory ───────────────────────────────────────────────

  factory AviaryScheme.empty({
    required String id,
    String name   = 'New Aviary',
    int    width  = 15,
    int    height = 15,
  }) {
    return AviaryScheme(
      id:         id,
      name:       name,
      gridWidth:  width,
      gridHeight: height,
      grid:       List.generate(height, (_) => List.filled(width, 0)),
      birdCounts: const {},
      cellAreaM2: 0.25,
      createdAt:  DateTime.now(),
      updatedAt:  DateTime.now(),
    );
  }

  // ── Computed properties ───────────────────────────────────

  int get totalBirds => birdCounts.values.fold(0, (a, b) => a + b);

  int get coveredCells {
    int n = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell != 0) n++;
      }
    }
    return n;
  }

  double get totalAreaM2 => coveredCells * cellAreaM2;

  double get coveragePercent {
    final total = gridWidth * gridHeight;
    if (total == 0) return 0;
    return coveredCells / total * 100;
  }

  Map<int, int> get zoneCellCounts {
    final counts = <int, int>{};
    for (final row in grid) {
      for (final cell in row) {
        if (cell != 0) counts[cell] = (counts[cell] ?? 0) + 1;
      }
    }
    return counts;
  }

  Set<int> get usedZoneTypes {
    final s = <int>{};
    for (final row in grid) {
      for (final cell in row) {
        if (cell != 0) s.add(cell);
      }
    }
    return s;
  }

  // ── CopyWith ──────────────────────────────────────────────

  AviaryScheme copyWith({
    String?           name,
    List<List<int>>?  grid,
    Map<String, int>? birdCounts,
    double?           cellAreaM2,
  }) {
    return AviaryScheme(
      id:         id,
      name:       name       ?? this.name,
      gridWidth:  gridWidth,
      gridHeight: gridHeight,
      grid:       grid       ?? this.grid,
      birdCounts: birdCounts ?? this.birdCounts,
      cellAreaM2: cellAreaM2 ?? this.cellAreaM2,
      createdAt:  createdAt,
      updatedAt:  DateTime.now(),
    );
  }

  // ── Serialisation ─────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'gridWidth':  gridWidth,
    'gridHeight': gridHeight,
    'grid':       grid.map((row) => row.toList()).toList(),
    'birdCounts': birdCounts,
    'cellAreaM2': cellAreaM2,
    'createdAt':  createdAt.toIso8601String(),
    'updatedAt':  updatedAt.toIso8601String(),
  };

  factory AviaryScheme.fromJson(Map<String, dynamic> j) => AviaryScheme(
    id:         j['id']         as String,
    name:       j['name']       as String,
    gridWidth:  j['gridWidth']  as int,
    gridHeight: j['gridHeight'] as int,
    grid:       (j['grid'] as List)
        .map((row) => List<int>.from(row as List))
        .toList(),
    birdCounts: Map<String, int>.from(j['birdCounts'] as Map? ?? {}),
    cellAreaM2: (j['cellAreaM2'] as num?)?.toDouble() ?? 0.25,
    createdAt:  DateTime.parse(j['createdAt'] as String),
    updatedAt:  DateTime.parse(j['updatedAt'] as String),
  );

  String toJsonString() => jsonEncode(toJson());

  factory AviaryScheme.fromJsonString(String s) =>
      AviaryScheme.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
