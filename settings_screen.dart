import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../services/export_service.dart';
import '../../../../services/notification_service.dart';
import '../../../tasks/application/task_controller.dart';
import '../../../tasks/domain/task_models.dart';
import '../../../tasks/presentation/widgets/task_widgets.dart';
import '../../application/settings_controller.dart';
import '../../domain/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsControllerProvider).asData?.value ?? const AppSettings();
    final tasks =
        ref.watch(tasksControllerProvider).asData?.value ?? const <Task>[];
    const exportService = ExportService();

    Future<void> exportCsv() async {
      final file = await exportService.exportCsv(tasks);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV saved to ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                final result = await exportService.openFile(file);
                if (context.mounted && result.type != ResultType.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open file: ${result.message}')),
                  );
                }
              },
            ),
          ),
        );
      }
    }

    Future<void> exportPdf() async {
      final file = await exportService.exportPdf(tasks);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                final result = await exportService.openFile(file);
                if (context.mounted && result.type != ResultType.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open file: ${result.message}')),
                  );
                }
              },
            ),
          ),
        );
      }
    }

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage appearance, alerts, and exports.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                if (stacked) ...<Widget>[
                  _ThemeCustomizationCard(settings: settings),
                  const SizedBox(height: 12),
                  _AlertsCard(settings: settings),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: _ThemeCustomizationCard(settings: settings),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _AlertsCard(settings: settings),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Export',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share your tasks in a simple format.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 360;
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              _ExportActionButton(
                                label: 'CSV',
                                icon: Icons.table_view_rounded,
                                onPressed: exportCsv,
                                compact: compact,
                              ),
                              _ExportActionButton(
                                label: 'PDF',
                                icon: Icons.picture_as_pdf_rounded,
                                onPressed: exportPdf,
                                compact: compact,
                              ),
                              _ExportActionButton(
                                label: 'Email',
                                icon: Icons.mail_outline_rounded,
                                onPressed: () => exportService.shareByEmail(tasks),
                                compact: compact,
                                emphasized: true,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExportActionButton extends StatelessWidget {
  const _ExportActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.compact,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = emphasized
        ? Colors.white
        : Theme.of(context).colorScheme.primary;
    final backgroundColor = emphasized
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white;

    return SizedBox(
      width: compact ? 112 : 126,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _ThemeCustomizationCard extends ConsumerWidget {
  const _ThemeCustomizationCard({
    required this.settings,
  });

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 560;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Flex(
                direction: stacked ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: stacked ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Theme',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: <Widget>[
                              SegmentToggle(
                                label: 'Light',
                                icon: Icons.light_mode_outlined,
                                selected: settings.themeMode != ThemeMode.dark,
                                onTap: () => ref
                                    .read(settingsControllerProvider.notifier)
                                    .updateThemeMode(ThemeMode.light),
                              ),
                              SegmentToggle(
                                label: 'Dark',
                                icon: Icons.dark_mode_outlined,
                                selected: settings.themeMode == ThemeMode.dark,
                                onTap: () => ref
                                    .read(settingsControllerProvider.notifier)
                                    .updateThemeMode(ThemeMode.dark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: stacked ? 0 : 28, height: stacked ? 24 : 0),
                  Expanded(
                    flex: stacked ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Accent Color',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: AppPalette.accentOptions.map((option) {
                            final selected =
                                option.key == settings.accentColorKey;
                            return InkWell(
                              onTap: () => ref
                                  .read(settingsControllerProvider.notifier)
                                  .updateAccentColor(option.key),
                              borderRadius: BorderRadius.circular(999),
                              child: Tooltip(
                                message: option.label,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: option.color,
                                    boxShadow: selected
                                        ? <BoxShadow>[
                                            BoxShadow(
                                              color: option.color.withValues(
                                                alpha: 0.22,
                                              ),
                                              blurRadius: 0,
                                              spreadRadius: 5,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlertsCard extends ConsumerWidget {
  const _AlertsCard({
    required this.settings,
  });

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Alerts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(settings.defaultSoundId),
            initialValue: settings.defaultSoundId,
            decoration: const InputDecoration(labelText: 'Sound Profile'),
            items: NotificationService.soundOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) {
                return;
              }
              await ref
                  .read(settingsControllerProvider.notifier)
                  .updateDefaultSound(value);
              await ref.read(tasksControllerProvider.notifier).syncNotifications();
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vibrate on Alerts'),
            value: settings.vibrateOnAlerts,
            onChanged: (value) async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .updateVibration(value);
              await ref.read(tasksControllerProvider.notifier).syncNotifications();
            },
          ),
        ],
      ),
    );
  }
}
