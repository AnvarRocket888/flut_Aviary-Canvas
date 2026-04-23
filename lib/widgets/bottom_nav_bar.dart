import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Custom animated bottom navigation bar.
/// Selected tab glows and scales up its icon.
class BottomNavBar extends StatelessWidget {
  final int          selectedIndex;
  final ValueChanged<int> onTabChanged;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: CupertinoIcons.square_grid_2x2, label: 'Canvas',  emoji: '🎨'),
    _NavItem(icon: CupertinoIcons.folder,          label: 'Schemes',  emoji: '📋'),
    _NavItem(icon: CupertinoIcons.chart_bar,        label: 'Calculate',emoji: '📐'),
    _NavItem(icon: CupertinoIcons.star,             label: 'Awards',   emoji: '🏆'),
    _NavItem(icon: CupertinoIcons.person,           label: 'Profile',  emoji: '🦅'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFF000000).withOpacity(0.4),
            blurRadius: 24,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:    () => onTabChanged(i),
              child:    _NavTab(
                item:     _items[i],
                selected: selected,
                index:    i,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String   label;
  final String   emoji;
  const _NavItem({required this.icon, required this.label, required this.emoji});
}

class _NavTab extends StatefulWidget {
  final _NavItem item;
  final bool     selected;
  final int      index;

  const _NavTab({
    required this.item,
    required this.selected,
    required this.index,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;
  late final Animation<double>   _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.25)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _glow  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.selected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavTab old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      widget.selected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder:   (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glow ring behind icon
            Stack(
              alignment: Alignment.center,
              children: [
                if (_glow.value > 0)
                  Container(
                    width:  40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape:   BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:      AppColors.primary.withOpacity(_glow.value * 0.45),
                          blurRadius: 16 * _glow.value,
                          spreadRadius: 2 * _glow.value,
                        ),
                      ],
                    ),
                  ),
                Transform.scale(
                  scale: _scale.value,
                  child: Icon(
                    widget.item.icon,
                    size:  22,
                    color: widget.selected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              widget.item.label,
              style: AppTextStyles.label.copyWith(
                color:    widget.selected ? AppColors.primary : AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


