import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../models/aviary_scheme.dart';
import '../theme/app_colors.dart';

/// Drawing tools available on the canvas.
enum DrawingTool { pencil, rectangle, eraser, fill, move }

/// CustomPainter that renders the aviary grid.
/// Draws zone fills, grid lines, optional rectangle preview.
class GridPainter extends CustomPainter {
  final List<List<int>>  grid;
  final int              gridWidth;
  final int              gridHeight;
  final (int, int)?      rectStart;
  final (int, int)?      rectEnd;
  final int              previewZone;

  const GridPainter({
    required this.grid,
    required this.gridWidth,
    required this.gridHeight,
    this.rectStart,
    this.rectEnd,
    this.previewZone = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width  / gridWidth;
    final cellH = size.height / gridHeight;

    final bgPaint   = Paint()..color = AppColors.gridBackground;
    final linePaint = Paint()
      ..color       = AppColors.gridLine
      ..strokeWidth = 0.5
      ..style       = PaintingStyle.stroke;

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Zone fills
    for (int row = 0; row < gridHeight; row++) {
      for (int col = 0; col < gridWidth; col++) {
        final zoneType = grid[row][col];
        if (zoneType == 0) continue;
        final rect = Rect.fromLTWH(
          col * cellW, row * cellH, cellW, cellH,
        );
        canvas.drawRect(
          rect,
          Paint()..color = AppColors.zoneColor(zoneType).withOpacity(0.85),
        );
      }
    }

    // Rectangle preview
    if (rectStart != null && rectEnd != null) {
      final minR = min(rectStart!.$1, rectEnd!.$1);
      final maxR = max(rectStart!.$1, rectEnd!.$1);
      final minC = min(rectStart!.$2, rectEnd!.$2);
      final maxC = max(rectStart!.$2, rectEnd!.$2);
      final previewRect = Rect.fromLTWH(
        minC * cellW, minR * cellH,
        (maxC - minC + 1) * cellW,
        (maxR - minR + 1) * cellH,
      );
      canvas.drawRect(
        previewRect,
        Paint()
          ..color = AppColors.zoneColor(previewZone).withOpacity(0.45)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        previewRect,
        Paint()
          ..color       = AppColors.zoneColor(previewZone)
          ..strokeWidth = 2
          ..style       = PaintingStyle.stroke,
      );
    }

    // Grid lines (columns)
    for (int col = 0; col <= gridWidth; col++) {
      final x = col * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    // Grid lines (rows)
    for (int row = 0; row <= gridHeight; row++) {
      final y = row * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Outer border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color       = AppColors.border
        ..strokeWidth = 1.5
        ..style       = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(GridPainter old) =>
      old.grid != grid ||
      old.rectStart != rectStart ||
      old.rectEnd != rectEnd;
}

// ── Grid canvas widget ────────────────────────────────────────────────────────

class GridCanvas extends StatefulWidget {
  final AviaryScheme           scheme;
  final DrawingTool            tool;
  final int                    currentZone;
  final void Function(List<List<int>>) onGridChanged;
  final void Function(bool canUndo, bool canRedo)? onUndoRedoChanged;

  const GridCanvas({
    super.key,
    required this.scheme,
    required this.tool,
    required this.currentZone,
    required this.onGridChanged,
    this.onUndoRedoChanged,
  });

  @override
  GridCanvasState createState() => GridCanvasState();
}

class GridCanvasState extends State<GridCanvas> {
  late List<List<int>> _grid;
  (int, int)? _rectStart;
  (int, int)? _rectEnd;
  (int, int)? _lastCell;

  // Undo / redo stacks (max 50 snapshots each)
  final List<List<List<int>>> _undoStack = [];
  final List<List<List<int>>> _redoStack = [];

  // Move-tool state
  int         _movingZone  = 0;
  (int, int)? _moveLastCell;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _grid = _copyGrid(widget.scheme.grid);
  }

  @override
  void didUpdateWidget(GridCanvas old) {
    super.didUpdateWidget(old);
    if (old.scheme.id != widget.scheme.id) {
      setState(() {
        _grid = _copyGrid(widget.scheme.grid);
        _undoStack.clear();
        _redoStack.clear();
      });
      widget.onUndoRedoChanged?.call(false, false);
      return;
    }
    // Grid size changed from outside (resize)
    if (old.scheme.gridWidth  != widget.scheme.gridWidth ||
        old.scheme.gridHeight != widget.scheme.gridHeight) {
      setState(() => _grid = _copyGrid(widget.scheme.grid));
    }
  }

  List<List<int>> _copyGrid(List<List<int>> src) =>
      src.map((r) => List<int>.from(r)).toList();

  // ── Undo / redo ───────────────────────────────────────────
  void _pushUndo() {
    _undoStack.add(_copyGrid(_grid));
    if (_undoStack.length > 50) _undoStack.removeAt(0);
    _redoStack.clear();
    widget.onUndoRedoChanged?.call(canUndo, canRedo);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_copyGrid(_grid));
    setState(() => _grid = _undoStack.removeLast());
    widget.onGridChanged(_grid);
    widget.onUndoRedoChanged?.call(canUndo, canRedo);
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_copyGrid(_grid));
    setState(() => _grid = _redoStack.removeLast());
    widget.onGridChanged(_grid);
    widget.onUndoRedoChanged?.call(canUndo, canRedo);
  }

  (int, int)? _cellAt(Offset pos, Size size) {
    final cw = size.width  / widget.scheme.gridWidth;
    final ch = size.height / widget.scheme.gridHeight;
    final col = (pos.dx / cw).floor();
    final row = (pos.dy / ch).floor();
    if (row < 0 || row >= widget.scheme.gridHeight) return null;
    if (col < 0 || col >= widget.scheme.gridWidth)  return null;
    return (row, col);
  }

  void _paint((int, int) cell) {
    final r = cell.$1, c = cell.$2;
    final newVal = widget.tool == DrawingTool.eraser ? 0 : widget.currentZone;
    if (_grid[r][c] == newVal) return;
    setState(() => _grid[r][c] = newVal);
    widget.onGridChanged(_grid);
  }

  void _floodFill((int, int) start) {
    final target = _grid[start.$1][start.$2];
    final replace = widget.currentZone;
    if (target == replace) return;
    final queue  = [start];
    final visited = <(int, int)>{};
    while (queue.isNotEmpty) {
      final cell = queue.removeLast();
      if (visited.contains(cell)) continue;
      if (cell.$1 < 0 || cell.$1 >= widget.scheme.gridHeight) continue;
      if (cell.$2 < 0 || cell.$2 >= widget.scheme.gridWidth)  continue;
      if (_grid[cell.$1][cell.$2] != target) continue;
      visited.add(cell);
      _grid[cell.$1][cell.$2] = replace;
      queue.add((cell.$1 - 1, cell.$2));
      queue.add((cell.$1 + 1, cell.$2));
      queue.add((cell.$1, cell.$2 - 1));
      queue.add((cell.$1, cell.$2 + 1));
    }
    setState(() {});
    widget.onGridChanged(_grid);
  }

  void _fillRect((int, int) a, (int, int) b) {
    final minR = min(a.$1, b.$1), maxR = max(a.$1, b.$1);
    final minC = min(a.$2, b.$2), maxC = max(a.$2, b.$2);
    for (int r = minR; r <= maxR; r++) {
      for (int c = minC; c <= maxC; c++) {
        _grid[r][c] = widget.currentZone;
      }
    }
    setState(() {});
    widget.onGridChanged(_grid);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onPanStart: (d) {
          final cell = _cellAt(d.localPosition, size);
          if (cell == null) return;
          _pushUndo();
          if (widget.tool == DrawingTool.fill) {
            _floodFill(cell);
          } else if (widget.tool == DrawingTool.rectangle) {
            setState(() { _rectStart = cell; _rectEnd = cell; });
          } else if (widget.tool == DrawingTool.move) {
            _movingZone  = _grid[cell.$1][cell.$2];
            _moveLastCell = cell;
            setState(() => _grid[cell.$1][cell.$2] = 0);
            widget.onGridChanged(_grid);
          } else {
            _lastCell = cell;
            _paint(cell);
          }
        },
        onPanUpdate: (d) {
          final cell = _cellAt(d.localPosition, size);
          if (cell == null) return;
          if (widget.tool == DrawingTool.rectangle) {
            setState(() => _rectEnd = cell);
          } else if (widget.tool == DrawingTool.move) {
            if (cell != _moveLastCell && _movingZone != 0) {
              setState(() {
                if (_moveLastCell != null) {
                  _grid[_moveLastCell!.$1][_moveLastCell!.$2] = 0;
                }
                _grid[cell.$1][cell.$2] = _movingZone;
                _moveLastCell = cell;
              });
              widget.onGridChanged(_grid);
            }
          } else if (widget.tool != DrawingTool.fill) {
            if (cell != _lastCell) {
              _lastCell = cell;
              _paint(cell);
            }
          }
        },
        onPanEnd: (_) {
          if (widget.tool == DrawingTool.rectangle &&
              _rectStart != null && _rectEnd != null) {
            _fillRect(_rectStart!, _rectEnd!);
          }
          setState(() {
            _rectStart    = null;
            _rectEnd      = null;
            _lastCell     = null;
            _moveLastCell = null;
            _movingZone   = 0;
          });
        },
        child: CustomPaint(
          painter: GridPainter(
            grid:        _grid,
            gridWidth:   widget.scheme.gridWidth,
            gridHeight:  widget.scheme.gridHeight,
            rectStart:   _rectStart,
            rectEnd:     _rectEnd,
            previewZone: widget.currentZone,
          ),
          child: const SizedBox.expand(),
        ),
      );
    });
  }
}
