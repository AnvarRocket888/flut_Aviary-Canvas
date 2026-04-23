import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/aviary_scheme.dart';
import '../services/calculation_service.dart';
import '../services/gamification_service.dart';
import '../services/appsflyer_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/grid_painter.dart';

/// The main canvas screen for drawing aviary layouts.
class CanvasScreen extends StatefulWidget {
  final AviaryScheme?  initialScheme;
  final void Function(AviaryScheme)? onSchemeOpened;

  const CanvasScreen({
    super.key,
    this.initialScheme,
    this.onSchemeOpened,
  });

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late AviaryScheme _scheme;
  List<List<int>>   _grid         = [];
  DrawingTool       _tool         = DrawingTool.pencil;
  int               _currentZone  = 1;
  bool              _dirty        = false;

  @override
  void initState() {
    super.initState();
    _scheme = widget.initialScheme ??
        AviaryScheme.empty(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
    _grid = _scheme.grid.map((r) => List<int>.from(r)).toList();
  }

  @override
  void didUpdateWidget(CanvasScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialScheme != null &&
        widget.initialScheme!.id != _scheme.id) {
      setState(() {
        _scheme = widget.initialScheme!;
        _grid   = _scheme.grid.map((r) => List<int>.from(r)).toList();
        _dirty  = false;
      });
    }
  }

  // ── Persistence ───────────────────────────────────────────

  Future<void> _save() async {
    final updated = _scheme.copyWith(grid: _grid);
    await StorageService.instance.saveScheme(updated);
    setState(() { _scheme = updated; _dirty = false; });

    GamificationService.instance.onSchemeSaved(
      coveredCells: updated.coveredCells,
      zoneTypes:    updated.usedZoneTypes,
      birdCounts:   updated.birdCounts,
    );
    AppsFlyerService.instance.trackSchemeSaved({'id': updated.id});

    if (!mounted) return;
    _showSnack('Scheme saved ✓');
  }

  Future<void> _newScheme() async {
    final ok = await _confirmDiscard();
    if (!ok) return;

    final name = await _askName();
    if (name == null || name.isEmpty) return;

    final scheme = AviaryScheme.empty(
      id:   DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    GamificationService.instance.onSchemeCreated(totalBirds: 0);
    AppsFlyerService.instance.trackSchemeCreated({'name': name});
    setState(() {
      _scheme = scheme;
      _grid   = scheme.grid.map((r) => List<int>.from(r)).toList();
      _dirty  = false;
    });
    widget.onSchemeOpened?.call(scheme);
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    bool confirm = false;
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () { confirm = true; Navigator.pop(context); },
            child: const Text('Discard'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return confirm;
  }

  Future<String?> _askName() async {
    final ctrl = TextEditingController();
    String? result;
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Scheme Name'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child:   CupertinoTextField(
            controller:  ctrl,
            placeholder: 'My Aviary',
            autofocus:   true,
            style:        const TextStyle(color: CupertinoColors.black),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () { result = ctrl.text.trim(); Navigator.pop(context); },
            child: const Text('Create'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: _scheme.name);
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('Rename Scheme'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child:   CupertinoTextField(
            controller:  ctrl,
            autofocus:   true,
            style: const TextStyle(color: CupertinoColors.black),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isNotEmpty) setState(() => _scheme = _scheme.copyWith(name: n));
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ── Bird counts ───────────────────────────────────────────

  void _showBirdSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _BirdCountSheet(
        birdCounts: Map.from(_scheme.birdCounts),
        onSave:     (updated) {
          setState(() {
            _scheme = _scheme.copyWith(birdCounts: updated);
            _dirty  = true;
          });
        },
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────

  AviaryCalcBundle get _calcs =>
      CalculationService.instance.calculate(
        _scheme.copyWith(grid: _grid),
      );

  // ── Export ────────────────────────────────────────────────

  Future<void> _export() async {
    final s     = _scheme.copyWith(grid: _grid);
    final zones = s.zoneCellCounts;
    final buf   = StringBuffer();
    buf.writeln('=== ${s.name} ===');
    buf.writeln('Grid: ${s.gridWidth}×${s.gridHeight}  (${s.cellAreaM2} m² per cell)');
    buf.writeln('Total area covered: ${s.totalAreaM2.toStringAsFixed(2)} m²');
    buf.writeln('Coverage: ${s.coveragePercent.toStringAsFixed(1)}%');
    buf.writeln('');
    buf.writeln('--- Bird counts ---');
    s.birdCounts.forEach((k, v) => buf.writeln('  $k: $v'));
    buf.writeln('Total: ${s.totalBirds} birds');
    buf.writeln('');
    buf.writeln('--- Zone breakdown ---');
    zones.forEach((t, c) {
      buf.writeln(
        '  ${AppConstants.zoneEmojis[t]} ${AppConstants.zoneLabels[t]}: $c cells'
        '  (${(c * s.cellAreaM2).toStringAsFixed(2)} m²)',
      );
    });
    buf.writeln('');
    buf.writeln('Generated by Aviary Canvas');

    GamificationService.instance.onSchemeExported();
    AppsFlyerService.instance.trackSchemeExported({'id': s.id});

    if (!mounted) return;
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => _ExportSheet(text: buf.toString()),
    );
  }

  void _showSnack(String msg) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CupertinoAlertDialog(
        content: Text(msg, style: AppTextStyles.body),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        SizedBox(height: safeTop),
        // Top bar
        _TopBar(
          name:       _scheme.name,
          dirty:      _dirty,
          onNew:      _newScheme,
          onSave:     _save,
          onExport:   _export,
          onBirds:    _showBirdSheet,
          onRename:   _editName,
        ).animate().fadeIn(duration: 400.ms),
        // Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child:   GridCanvas(
              scheme:         _scheme.copyWith(grid: _grid),
              tool:           _tool,
              currentZone:    _currentZone,
              onGridChanged:  (g) => setState(() { _grid = g; _dirty = true; }),
            ),
          ),
        ),
        // Quick stats bar
        _StatsBar(scheme: _scheme.copyWith(grid: _grid))
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms),
        // Toolbar
        DrawingToolbar(
          selectedTool:  _tool,
          selectedZone:  _currentZone,
          onToolChanged: (t) => setState(() => _tool = t),
          onZoneChanged: (z) => setState(() => _currentZone = z),
        ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOut),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String     name;
  final bool       dirty;
  final VoidCallback onNew, onSave, onExport, onBirds, onRename;

  const _TopBar({
    required this.name,
    required this.dirty,
    required this.onNew,
    required this.onSave,
    required this.onExport,
    required this.onBirds,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color:       AppColors.surface.withOpacity(0.85),
      child: Row(
        children: [
          // Title
          Expanded(
            child: GestureDetector(
              onTap: onRename,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style:    AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (dirty)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Actions
          _IconBtn(icon: CupertinoIcons.add,            onTap: onNew),
          _IconBtn(icon: CupertinoIcons.bird,            onTap: onBirds),
          _IconBtn(icon: CupertinoIcons.square_arrow_up, onTap: onExport),
          CupertinoButton(
            padding:   EdgeInsets.zero,
            onPressed: onSave,
            child: Container(
              padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color:        dirty ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Save',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: dirty ? const Color(0xFF0D1B2A) : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding:   EdgeInsets.zero,
    onPressed: onTap,
    child: Icon(icon, color: AppColors.textSecondary, size: 22),
  );
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final AviaryScheme scheme;
  const _StatsBar({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:     42,
      color:      AppColors.surface.withOpacity(0.7),
      padding:    const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _Stat('🐦', '${scheme.totalBirds} birds'),
          _div(),
          _Stat('📐', '${scheme.totalAreaM2.toStringAsFixed(1)} m²'),
          _div(),
          _Stat('🎨', '${scheme.coveredCells} cells'),
          _div(),
          _Stat('📊', '${scheme.coveragePercent.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _div() => Container(
    width:  0.5,
    height: 20,
    color:  AppColors.border,
    margin: const EdgeInsets.symmetric(horizontal: 10),
  );
}

class _Stat extends StatelessWidget {
  final String emoji, value;
  const _Stat(this.emoji, this.value);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 4),
      Text(value, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
    ],
  );
}

// ── Bird count bottom sheet ───────────────────────────────────────────────────

class _BirdCountSheet extends StatefulWidget {
  final Map<String, int>              birdCounts;
  final void Function(Map<String, int>) onSave;

  const _BirdCountSheet({required this.birdCounts, required this.onSave});

  @override
  State<_BirdCountSheet> createState() => _BirdCountSheetState();
}

class _BirdCountSheetState extends State<_BirdCountSheet> {
  late Map<String, int> _counts;

  @override
  void initState() {
    super.initState();
    _counts = Map.from(widget.birdCounts);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:    400,
      padding:   const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 32),
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('🐦 Bird Counts', style: AppTextStyles.heading3),
              const Spacer(),
              CupertinoButton(
                padding:   EdgeInsets.zero,
                onPressed: () { widget.onSave(_counts); Navigator.pop(context); },
                child: const Text('Done'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: AppConstants.allSpecies.map((species) {
                final count = _counts[species] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child:   Row(
                    children: [
                      Expanded(
                        child: Text(species, style: AppTextStyles.body),
                      ),
                      CupertinoButton(
                        padding:   EdgeInsets.zero,
                        onPressed: count > 0
                            ? () => setState(() {
                                if (count - 1 == 0) {
                                  _counts.remove(species);
                                } else {
                                  _counts[species] = count - 1;
                                }
                              })
                            : null,
                        child: const Icon(
                          CupertinoIcons.minus_circle,
                          color: AppColors.error,
                          size:  22,
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$count',
                          style:     AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      CupertinoButton(
                        padding:   EdgeInsets.zero,
                        onPressed: () => setState(
                          () => _counts[species] = count + 1,
                        ),
                        child: const Icon(
                          CupertinoIcons.plus_circle,
                          color: AppColors.secondary,
                          size:  22,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Export bottom sheet ───────────────────────────────────────────────────────

class _ExportSheet extends StatelessWidget {
  final String text;
  const _ExportSheet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  480,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('📋 Export Scheme', style: AppTextStyles.heading3),
              const Spacer(),
              CupertinoButton(
                padding:   EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child:     const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding:    const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        AppColors.gridBackground,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: AppTextStyles.caption.copyWith(
                    fontFamily: 'Courier',
                    color:      AppColors.textSecondary,
                    height:     1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
