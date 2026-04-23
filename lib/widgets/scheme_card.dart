import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/aviary_scheme.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';

/// Card displayed in the Schemes list.
class SchemeCard extends StatelessWidget {
  final AviaryScheme scheme;
  final int          index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SchemeCard({
    super.key,
    required this.scheme,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:  const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color:      AppColors.background.withOpacity(0.6),
              blurRadius: 8,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mini grid preview
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: _GridPreview(scheme: scheme),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child:   Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.name,
                      style:    AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${scheme.gridWidth}×${scheme.gridHeight} grid  •  '
                      '${scheme.coveragePercent.toStringAsFixed(0)}% covered',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('🐦 ', style: TextStyle(fontSize: 12)),
                        Text(
                          '${scheme.totalBirds} birds',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('📐 ', style: TextStyle(fontSize: 12)),
                        Text(
                          '${scheme.totalAreaM2.toStringAsFixed(1)} m²',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(scheme.updatedAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
            // Delete button
            CupertinoButton(
              padding: const EdgeInsets.all(14),
              onPressed: onDelete,
              child: const Icon(
                CupertinoIcons.trash,
                color: AppColors.error,
                size:  18,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (index * 60).ms, duration: 350.ms)
          .slideY(begin: 0.1, end: 0, delay: (index * 60).ms, curve: Curves.easeOut),
    );
  }

  String _formatDate(DateTime d) {
    final now  = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _GridPreview extends StatelessWidget {
  final AviaryScheme scheme;
  const _GridPreview({required this.scheme});

  @override
  Widget build(BuildContext context) {
    const previewSize = 80.0;
    final cw = previewSize / scheme.gridWidth;
    final ch = previewSize / scheme.gridHeight;

    return SizedBox(
      width:  previewSize,
      height: previewSize,
      child:  CustomPaint(
        painter: _MiniGridPainter(scheme.grid, cw, ch),
      ),
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  final List<List<int>> grid;
  final double          cw, ch;

  const _MiniGridPainter(this.grid, this.cw, this.ch);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.gridBackground,
    );
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final t = grid[r][c];
        if (t == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(c * cw, r * ch, cw, ch),
          Paint()..color = AppColors.zoneColor(t).withOpacity(0.9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MiniGridPainter old) => old.grid != grid;
}
