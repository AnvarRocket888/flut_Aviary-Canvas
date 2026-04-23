import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/calculation_service.dart';
import '../services/gamification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';

/// Standalone aviary calculator – no grid required.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final Map<String, int> _birdCounts  = {};
  double _totalAreaM2     = 10.0;
  int    _feederCells     = 3;
  int    _waterCells      = 2;
  int    _nestCells       = 2;
  int    _perchCells      = 4;
  AviaryCalcBundle? _result;
  bool   _ran             = false;

  void _run() {
    final r = CalculationService.instance.calculateStandalone(
      birdCounts:  _birdCounts,
      totalAreaM2: _totalAreaM2,
      feederCells: _feederCells,
      waterCells:  _waterCells,
      nestCells:   _nestCells,
      perchCells:  _perchCells,
    );
    setState(() { _result = r; _ran = true; });

    GamificationService.instance.onCalculationRun(
      allGreen:     r.allGreen,
      hasPerchCalc: r.perchDetails != null,
      hadConflict:  r.hasConflicts,
    );
  }

  void _reset() => setState(() {
    _birdCounts.clear();
    _totalAreaM2 = 10.0;
    _feederCells = 3;
    _waterCells  = 2;
    _nestCells   = 2;
    _perchCells  = 4;
    _result      = null;
    _ran         = false;
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top:    safeTop,
        bottom: 20,
        left:   16,
        right:  16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calculator', style: AppTextStyles.heading2),
                    Text('Aviary requirement estimator', style: AppTextStyles.caption),
                  ],
                ),
                const Spacer(),
                CupertinoButton(
                  padding:   EdgeInsets.zero,
                  onPressed: _reset,
                  child: const Icon(CupertinoIcons.refresh, color: AppColors.textMuted),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Bird counts
          _Section(
            title: '🐦 Bird Species & Counts',
            child: Column(
              children: AppConstants.allSpecies.map((sp) {
                final c = _birdCounts[sp] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child:   Row(
                    children: [
                      Expanded(child: Text(sp, style: AppTextStyles.body)),
                      _Stepper(
                        value:  c,
                        onDec:  c > 0 ? () => setState(() {
                          if (c - 1 == 0) _birdCounts.remove(sp);
                          else _birdCounts[sp] = c - 1;
                        }) : null,
                        onInc: () => setState(() => _birdCounts[sp] = c + 1),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 12),

          // Dimensions
          _Section(
            title: '📐 Aviary Dimensions',
            child: Column(
              children: [
                _SliderRow(
                  label: 'Total area',
                  value: _totalAreaM2,
                  unit:  'm²',
                  min:   1,
                  max:   200,
                  onChanged: (v) => setState(() => _totalAreaM2 = v),
                ),
                _SliderRow(
                  label: 'Feeder cells',
                  value: _feederCells.toDouble(),
                  unit:  '',
                  min:   0,
                  max:   30,
                  onChanged: (v) => setState(() => _feederCells = v.round()),
                ),
                _SliderRow(
                  label: 'Water cells',
                  value: _waterCells.toDouble(),
                  unit:  '',
                  min:   0,
                  max:   20,
                  onChanged: (v) => setState(() => _waterCells = v.round()),
                ),
                _SliderRow(
                  label: 'Nest cells',
                  value: _nestCells.toDouble(),
                  unit:  '',
                  min:   0,
                  max:   20,
                  onChanged: (v) => setState(() => _nestCells = v.round()),
                ),
                _SliderRow(
                  label: 'Perch cells',
                  value: _perchCells.toDouble(),
                  unit:  '',
                  min:   0,
                  max:   30,
                  onChanged: (v) => setState(() => _perchCells = v.round()),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Calculate button
          Center(
            child: CupertinoButton(
              onPressed: _run,
              padding:   EdgeInsets.zero,
              child: Container(
                width:      double.infinity,
                padding:    const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient:     const LinearGradient(
                    colors: [AppColors.primary, AppColors.gold],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:      AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🧮  Calculate',
                    style: AppTextStyles.button.copyWith(
                      color: const Color(0xFF0D1B2A),
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          // Results
          if (_ran && _result != null) ...[
            const SizedBox(height: 24),
            _ResultsSection(result: _result!)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color:        AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppColors.border),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _Stepper extends StatelessWidget {
  final int           value;
  final VoidCallback? onDec;
  final VoidCallback  onInc;
  const _Stepper({required this.value, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CupertinoButton(
        padding:   EdgeInsets.zero,
        onPressed: onDec,
        child: Icon(
          CupertinoIcons.minus_circle,
          color: onDec != null ? AppColors.error : AppColors.border,
          size:  22,
        ),
      ),
      SizedBox(
        width: 36,
        child: Text(
          '$value',
          style:     AppTextStyles.heading3,
          textAlign: TextAlign.center,
        ),
      ),
      CupertinoButton(
        padding:   EdgeInsets.zero,
        onPressed: onInc,
        child: const Icon(
          CupertinoIcons.plus_circle,
          color: AppColors.secondary,
          size:  22,
        ),
      ),
    ],
  );
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min, max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.bodySecondary),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(unit == 'm²' ? 1 : 0)}$unit',
              style: AppTextStyles.xpValue,
            ),
          ],
        ),
        CupertinoSlider(
          value:        value,
          min:          min,
          max:          max,
          activeColor:  AppColors.primary,
          onChanged:    onChanged,
        ),
      ],
    ),
  );
}

class _ResultsSection extends StatelessWidget {
  final AviaryCalcBundle result;
  const _ResultsSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('Space',    result.space),
      ('Feeders',  result.feeders),
      ('Water',    result.water),
      ('Nesting',  result.nesting),
      ('Perch',    result.perch),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Results', style: AppTextStyles.heading2),
            const SizedBox(width: 10),
            Container(
              padding:    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:        result.allGreen
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.allGreen ? '✅ All Good' : '⚠️ Issues Found',
                style: AppTextStyles.caption.copyWith(
                  color: result.allGreen ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...checks.asMap().entries.map((e) => _ResultRow(
          label:  e.value.$1,
          result: e.value.$2,
          index:  e.key,
        )),
        if (result.perchDetails != null) ...[
          const SizedBox(height: 12),
          _PerchDetailsCard(calc: result.perchDetails!),
        ],
        if (result.conflicts.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ConflictCard(conflicts: result.conflicts),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String     label;
  final CalcResult result;
  final int        index;
  const _ResultRow({required this.label, required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        result.isOk
            ? AppColors.success.withOpacity(0.08)
            : AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(
          color: result.isOk ? AppColors.success.withOpacity(0.4) : AppColors.error.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.isOk ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.achievementTitle.copyWith(
                    color: result.isOk ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(result.message, style: AppTextStyles.achievementDesc),
                if (result.recommendation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 ${result.recommendation}',
                    style: AppTextStyles.achievementDesc.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 80).ms, duration: 350.ms)
        .slideX(begin: 0.1, end: 0, delay: (index * 80).ms);
  }
}

class _PerchDetailsCard extends StatelessWidget {
  final PerchCalc calc;
  const _PerchDetailsCard({required this.calc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.zonePerch.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.zonePerch.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🪵 Perch Calculator', style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          _Row('Perch length needed',    '${calc.neededM.toStringAsFixed(2)} m'),
          _Row('Perch length available', '${calc.availableM.toStringAsFixed(2)} m'),
          _Row('Recommended height',     '${calc.recommendedHeightM} m above floor'),
          _Row('Recommended spacing',    '${(calc.recommendedSpacingM * 100).round()} cm between perches'),
          _Row('Sufficient',             calc.isSufficient ? '✅ Yes' : '❌ No'),
        ],
      ),
    );
  }

  Widget _Row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(child: Text(k, style: AppTextStyles.bodySecondary)),
        Text(v, style: AppTextStyles.body),
      ],
    ),
  );
}

class _ConflictCard extends StatelessWidget {
  final List<CalcResult> conflicts;
  const _ConflictCard({required this.conflicts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️ Conflicts Detected', style: AppTextStyles.heading3.copyWith(color: AppColors.error)),
          const SizedBox(height: 10),
          ...conflicts.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.message, style: AppTextStyles.body),
                if (c.recommendation != null)
                  Text('💡 ${c.recommendation}', style: AppTextStyles.achievementDesc.copyWith(color: AppColors.gold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
