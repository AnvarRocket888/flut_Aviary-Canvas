import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full-screen help / tutorial reference for Aviary Canvas.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final safeTop    = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          SizedBox(height: safeTop),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                CupertinoButton(
                  padding:   EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.chevron_left,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 8),
                Text('How to Use', style: AppTextStyles.heading2),
              ],
            ),
          ),
          // Scrollable sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom + 24),
              children: const [
                _Section(
                  emoji: '🗺️',
                  title: 'Canvas — Drawing',
                  color: AppColors.secondary,
                  items: [
                    _Item('✏️  Pencil', 'Tap or drag to paint a zone one cell at a time.'),
                    _Item('▭  Rectangle', 'Drag to draw a filled rectangle — release to apply.'),
                    _Item('🪣  Fill', 'Tap any cell to flood-fill the connected area with the current zone.'),
                    _Item('🧹  Eraser', 'Drag to erase cells (set them back to empty).'),
                    _Item('↔  Move', 'Drag a painted cell to reposition it anywhere on the grid.'),
                  ],
                ),
                _Section(
                  emoji: '🔍',
                  title: 'Canvas — Zoom & Pan',
                  color: AppColors.accent,
                  items: [
                    _Item('Zoom button', 'Tap the 🔍 Zoom button in the toolbar to switch from Draw mode to Zoom/Pan mode. Your finger will now move and zoom the canvas instead of painting.'),
                    _Item('Switch back', 'Tap the same button again (now labelled "Draw") to return to drawing. The zoom level is reset automatically.'),
                    _Item('Two-finger pinch', 'In Zoom mode use a two-finger pinch to zoom in/out and drag with one finger to pan.'),
                  ],
                ),
                _Section(
                  emoji: '↩️',
                  title: 'Canvas — Undo & Redo',
                  color: AppColors.primary,
                  items: [
                    _Item('Undo (↩)', 'Tap the counter-clockwise arrow to step back one drawing action. Holds up to 50 steps.'),
                    _Item('Redo (↪)', 'Tap the clockwise arrow to re-apply an undone action.'),
                  ],
                ),
                _Section(
                  emoji: '📐',
                  title: 'Canvas — Grid Resize',
                  color: AppColors.gold,
                  items: [
                    _Item('Resize button', 'Tap the ✂ Crop icon in the toolbar to open the resize dialog.'),
                    _Item('Width / Height', 'Use ＋ / － to set the grid size from 5 to 50 cells in each direction. Existing painted cells are preserved.'),
                  ],
                ),
                _Section(
                  emoji: '🖼️',
                  title: 'Canvas — Export',
                  color: AppColors.accent,
                  items: [
                    _Item('Share as Image', 'Tap the export icon (↑ box) in the top bar → "Share as Image (PNG)" to render the full grid and send it via the iOS share sheet.'),
                    _Item('Share as Text', 'Choose "Share as Text" for a plain-text summary of zones, bird counts and area stats.'),
                  ],
                ),
                _Section(
                  emoji: '🧮',
                  title: 'Calculator',
                  color: AppColors.secondary,
                  items: [
                    _Item('1. Add bird species', 'Tap "+ Add Species" at the top. Type the species name and the number of birds. Repeat for each species in your aviary.'),
                    _Item('2. Set the area', 'Adjust "Total Area (m²)" to match your planned enclosure size.'),
                    _Item('3. Adjust zone counts', 'Set how many feeder cells, water cells, nest cells, and perch cells you have drawn on the canvas.'),
                    _Item('4. Run the calculator', 'Tap "Calculate Recommendations" to get a per-species analysis: space adequacy, feeder count, water count, nest count, and perch length.'),
                    _Item('Load from Scheme', 'Tap the tray-download icon in the header to pre-fill bird counts and zone counts directly from a saved canvas scheme.'),
                    _Item('Save as PDF', 'After running the calculator, tap "Save as PDF" to share results via the iOS share sheet.'),
                  ],
                ),
                _Section(
                  emoji: '📋',
                  title: 'Schemes',
                  color: AppColors.primary,
                  items: [
                    _Item('Create', 'Tap the orange "+ New" button to start a new named scheme.'),
                    _Item('Open', 'Tap any scheme card to open it on the canvas.'),
                    _Item('Delete', 'Swipe left on a scheme card (or tap the trash icon) to delete it.'),
                    _Item('Import JSON', 'Tap the ↓ tray icon to import a scheme from a JSON file via the Files app.'),
                    _Item('Backup', 'Tap the ↑ share icon to export all your schemes and profile as a JSON backup file.'),
                    _Item('Restore', 'Tap the ↺ icon to pick a backup JSON file and restore your data.'),
                  ],
                ),
                _Section(
                  emoji: '🏆',
                  title: 'Achievements & Profile',
                  color: AppColors.gold,
                  items: [
                    _Item('XP & Ranks', 'You earn XP every time you save a scheme, run a calculation, or export. Accumulate XP to advance through ranks from Egg 🥚 to Master Aviarist 🦅.'),
                    _Item('Streak', 'Open the app on consecutive days to grow your streak 🔥.'),
                    _Item('Trophies', 'Tap "Trophy Case" to see special trophies unlocked by completing specific milestones.'),
                    _Item('Achievements', 'Unlocked achievements pop up as toast notifications while you work.'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final Color  color;
  final List<_Item> items;

  const _Section({
    required this.emoji,
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:        color.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(title,
                      style: AppTextStyles.heading3.copyWith(color: color)),
                ],
              ),
            ),
            // Items
            ...items.asMap().entries.map((e) {
              final i    = e.key;
              final item = e.value;
              return Column(
                children: [
                  if (i > 0)
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(left: 16),
                      color:  AppColors.border,
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.label,
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(item.desc,
                                  style: AppTextStyles.bodySecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (i * 30).ms, duration: 300.ms),
                ],
              );
            }),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.05, end: 0),
    );
  }
}

// ── Item data ─────────────────────────────────────────────────────────────────

class _Item {
  final String label;
  final String desc;
  const _Item(this.label, this.desc);
}
