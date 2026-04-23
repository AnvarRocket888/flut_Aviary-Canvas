import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/aviary_scheme.dart';
import '../services/gamification_service.dart';
import '../services/storage_service.dart';
import '../services/appsflyer_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/scheme_card.dart';

/// List of all saved aviary schemes.
class SchemesScreen extends StatefulWidget {
  final void Function(AviaryScheme) onSchemeTap;
  const SchemesScreen({super.key, required this.onSchemeTap});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  List<AviaryScheme> _schemes  = [];
  bool               _loading  = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.instance.loadAllSchemes();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (!mounted) return;
    setState(() { _schemes = list; _loading = false; });
  }

  Future<void> _delete(AviaryScheme scheme) async {
    bool confirm = false;
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   Text('Delete "${scheme.name}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () { confirm = true; Navigator.pop(context); },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (!confirm || !mounted) return;
    await StorageService.instance.deleteScheme(scheme.id);
    AppsFlyerService.instance.trackSchemeDeleted({'id': scheme.id});
    await _load();
  }

  Future<void> _createNew() async {
    final ctrl = TextEditingController();
    String? name;
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title:   const Text('New Scheme'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child:   CupertinoTextField(
            controller:  ctrl,
            placeholder: 'My Aviary',
            autofocus:   true,
            style: const TextStyle(color: CupertinoColors.black),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () { name = ctrl.text.trim(); Navigator.pop(context); },
            child: const Text('Create'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (name == null || name!.isEmpty || !mounted) return;

    final scheme = AviaryScheme.empty(
      id:   DateTime.now().millisecondsSinceEpoch.toString(),
      name: name!,
    );
    await StorageService.instance.saveScheme(scheme);
    GamificationService.instance.onSchemeCreated(totalBirds: 0);
    AppsFlyerService.instance.trackSchemeCreated({'name': name});
    widget.onSchemeTap(scheme);
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    return Column(
      children: [
        SizedBox(height: safeTop),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child:   Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Schemes', style: AppTextStyles.heading2),
                  Text(
                    '${_schemes.length} aviar${_schemes.length == 1 ? 'y' : 'ies'}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const Spacer(),
              CupertinoButton(
                padding:   EdgeInsets.zero,
                onPressed: _createNew,
                child: Container(
                  padding:    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient:     const LinearGradient(
                      colors: [AppColors.primary, AppColors.gold],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.add, color: Color(0xFF0D1B2A), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'New',
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: const Color(0xFF0D1B2A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.1, end: 0),
        // List
        Expanded(
          child: _loading
              ? const Center(child: CupertinoActivityIndicator())
              : _schemes.isEmpty
                  ? _EmptyState(onCreate: _createNew)
                  : RefreshIndicator.adaptive(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding:     const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount:   _schemes.length,
                        itemBuilder: (_, i) => SchemeCard(
                          scheme:   _schemes[i],
                          index:    i,
                          onTap:    () => widget.onSchemeTap(_schemes[i]),
                          onDelete: () => _delete(_schemes[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪹', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin:    const Offset(1, 1),
                end:      const Offset(1.1, 1.1),
                duration: 1500.ms,
                curve:    Curves.easeInOut,
              ),
          const SizedBox(height: 20),
          Text('No schemes yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Create your first aviary layout\nto get started.',
            style:     AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color:     AppColors.primary,
            onPressed: onCreate,
            child:     const Text('Create First Scheme',
              style: TextStyle(color: CupertinoColors.black),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }
}
