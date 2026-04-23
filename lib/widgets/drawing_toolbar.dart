import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import 'grid_painter.dart';

/// Bottom toolbar for the Canvas screen.
/// Shows: tool selector row + actions row + zone type selector row.
class DrawingToolbar extends StatelessWidget {
  final DrawingTool            selectedTool;
  final int                    selectedZone;
  final ValueChanged<DrawingTool> onToolChanged;
  final ValueChanged<int>         onZoneChanged;
  final bool         canUndo;
  final bool         canRedo;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final bool         zoomEnabled;
  final VoidCallback? onZoomToggle;
  final VoidCallback? onResize;

  const DrawingToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedZone,
    required this.onToolChanged,
    required this.onZoneChanged,
    this.canUndo     = false,
    this.canRedo     = false,
    this.onUndo,
    this.onRedo,
    this.zoomEnabled = false,
    this.onZoomToggle,
    this.onResize,
  });

  static const List<(DrawingTool, IconData, String)> _tools = [
    (DrawingTool.pencil,    CupertinoIcons.pencil,                          'Draw'),
    (DrawingTool.rectangle, CupertinoIcons.rectangle,                       'Rect'),
    (DrawingTool.eraser,    CupertinoIcons.clear_circled,                   'Erase'),
    (DrawingTool.fill,      CupertinoIcons.paintbrush,                      'Fill'),
    (DrawingTool.move,      CupertinoIcons.arrow_up_left_arrow_down_right,  'Move'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool row
          SizedBox(
            height: 52,
            child: Row(
              children: _tools.map((t) {
                final active = t.$1 == selectedTool;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onToolChanged(t.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: active
                          ? AppColors.primary.withOpacity(0.15)
                          : const Color(0x00000000),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            t.$2,
                            size:  20,
                            color: active ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.$3,
                            style: AppTextStyles.label.copyWith(
                              color: active ? AppColors.primary : AppColors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(height: 0.5, color: AppColors.border),
          // Actions row: undo | redo | zoom | resize
          SizedBox(
            height: 36,
            child: Row(
              children: [
                _ActionBtn(
                  icon:    CupertinoIcons.arrow_counterclockwise,
                  label:   'Undo',
                  enabled: canUndo,
                  onTap:   canUndo ? onUndo : null,
                ),
                Container(width: 0.5, height: 20, color: AppColors.border),
                _ActionBtn(
                  icon:    CupertinoIcons.arrow_clockwise,
                  label:   'Redo',
                  enabled: canRedo,
                  onTap:   canRedo ? onRedo : null,
                ),
                Container(width: 0.5, height: 20, color: AppColors.border),
                _ActionBtn(
                  icon:    CupertinoIcons.search,
                  label:   zoomEnabled ? 'Draw' : 'Zoom',
                  enabled: true,
                  active:  zoomEnabled,
                  onTap:   onZoomToggle,
                ),
                Container(width: 0.5, height: 20, color: AppColors.border),
                _ActionBtn(
                  icon:    CupertinoIcons.crop,
                  label:   'Resize',
                  enabled: true,
                  onTap:   onResize,
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: AppColors.border),
          SizedBox(
            height: 58,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:         const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount:       8,
              itemBuilder:     (_, i) {
                final zoneIdx = i + 1;
                final active  = selectedZone == zoneIdx;
                return _ZoneChip(
                  zoneIdx: zoneIdx,
                  active:  active,
                  onTap:   () => onZoneChanged(zoneIdx),
                )
                    .animate()
                    .fadeIn(delay: (i * 40).ms, duration: 300.ms)
                    .slideX(begin: 0.2, end: 0, delay: (i * 40).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final int      zoneIdx;
  final bool     active;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.zoneIdx,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.zoneColor(zoneIdx);
    final emoji = AppConstants.zoneEmojis[zoneIdx] ?? '';
    final label = AppConstants.zoneLabels[zoneIdx] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:  const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        active ? color.withOpacity(0.25) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(
            color: active ? color : AppColors.border,
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label.length > 8 ? label.substring(0, 8) : label,
              style: AppTextStyles.label.copyWith(
                color:    active ? color : AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData      icon;
  final String        label;
  final bool          enabled;
  final bool          active;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? AppColors.border
        : active
            ? AppColors.primary
            : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: active
              ? AppColors.primary.withOpacity(0.15)
              : const Color(0x00000000),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color:    color,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
