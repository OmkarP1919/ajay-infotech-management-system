import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final settingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('institute_settings')
      .select('*')
      .order('key');
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Institute Settings',
          subtitle: 'Configure institute-wide preferences',
        ),
        Expanded(
          child: settingsAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString()),
            data: (settings) {
              // Initialize controllers
              for (final s in settings) {
                final key = s['key'] as String;
                if (!_controllers.containsKey(key)) {
                  _controllers[key] = TextEditingController(text: s['value'] ?? '');
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminCard(
                      title: 'General Settings',
                      child: Column(
                        children: settings.map((s) {
                          final key = s['key'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        key.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AdminColors.textMuted),
                                      ),
                                      if (s['description'] != null)
                                        Text(s['description'],
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AdminColors.textMuted)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _controllers[key],
                                    decoration: InputDecoration(
                                      hintText: s['value'] ?? '',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save_rounded, size: 16),
                          label: const Text('Save Settings'),
                          onPressed: _saving
                              ? null
                              : () => _saveSettings(settings),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveSettings(List<Map<String, dynamic>> settings) async {
    setState(() => _saving = true);
    try {
      for (final s in settings) {
        final key = s['key'] as String;
        final ctrl = _controllers[key];
        if (ctrl != null) {
          await Supabase.instance.client.from('institute_settings').update({
            'value': ctrl.text,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('key', key);
        }
      }
      ref.invalidate(settingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
