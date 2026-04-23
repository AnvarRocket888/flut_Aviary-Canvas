import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import 'grid_painter.dart';

/// Bottom toolbar for the Canvas screen.
/// Shows: tool selector row + zone type selector row.
class DrawingToolbar extends StatelessWidget {
  final DrawingTool            selectedTool;
  final int                    selectedZone;
  final ValueChanged<DrawingTool> onToolChanged;
  final ValueChanged<int>         onZoneChanged;

  const DrawingToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedZone,
    required this.onToolChanged,
    required this.onZoneChanged,
  });

  static const List<(DrawingTool, IconData, String)> _tools = [
    (DrawingTool.pencil,    CupertinoIcons.pencil,         'Draw'),
    (DrawingTool.rectangle, CupertinoIcons.rectangle,      'Rect'),
    (DrawingTool.eraser,    CupertinoIcons.clear_circled,  'Erase'),
    (DrawingTool.fill,      CupertinoIcons.paintbrush,     'Fill'),
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
          // Zone selector
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
