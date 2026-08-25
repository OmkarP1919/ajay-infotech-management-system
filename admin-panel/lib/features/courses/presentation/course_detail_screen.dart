import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final courseDetailAdminProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  final course = await Supabase.instance.client
      .from('courses')
      .select('*')
      .eq('id', id)
      .maybeSingle();
  if (course == null) return null;

  final modules = await Supabase.instance.client
      .from('course_modules')
      .select('*, lessons(*)')
      .eq('course_id', id)
      .order('sequence_order');

  final resources = await Supabase.instance.client
      .from('course_resources')
      .select('*')
      .eq('course_id', id);

  return {'course': course, 'modules': modules, 'resources': resources};
});

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(courseDetailAdminProvider(courseId));

    return dataAsync.when(
      loading: () => const Scaffold(body: AdminLoadingSpinner()),
      error: (e, _) => Scaffold(body: AdminErrorState(message: e.toString())),
      data: (data) {
        if (data == null) {
          return Scaffold(
            body: AdminEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Course not found',
              action: ElevatedButton(
                onPressed: () => context.go('/courses'),
                child: const Text('Back to Courses'),
              ),
            ),
          );
        }

        final course = data['course'] as Map<String, dynamic>;
        final modules =
            List<Map<String, dynamic>>.from(data['modules'] ?? []);
        final resources =
            List<Map<String, dynamic>>.from(data['resources'] ?? []);

        return Column(
          children: [
            AdminPageHeader(
              title: course['title'] ?? 'Course',
              subtitle: '${course['category'] ?? ''} · ${course['instructor'] ?? ''}',
              actions: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded, size: 14),
                  label: const Text('Back'),
                  onPressed: () => context.go('/courses'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: const Text('Add Module'),
                  onPressed: () => _showAddModuleDialog(context, ref, course['id']),
                ),
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modules list
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (modules.isEmpty)
                            const AdminEmptyState(
                              icon: Icons.view_module_rounded,
                              title: 'No modules yet',
                              subtitle: 'Add modules to build the curriculum',
                            )
                          else
                            ...modules.asMap().entries.map((entry) {
                              final mod = entry.value;
                              final lessons = List<Map<String, dynamic>>.from(
                                  mod['lessons'] ?? []);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AdminColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AdminColors.cardBorder),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    'Module ${entry.key + 1}: ${mod['title']}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                      '${lessons.length} lessons · ${mod['duration'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AdminColors.textMuted)),
                                  children: [
                                    ...lessons.map((l) => ListTile(
                                          dense: true,
                                          leading: const Icon(
                                              Icons.play_circle_outline_rounded,
                                              size: 18,
                                              color: AdminColors.primaryTeal),
                                          title: Text(l['title'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          subtitle: Text(l['duration'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          trailing: l['is_preview'] == true
                                              ? const AdminStatusBadge(
                                                  label: 'PREVIEW',
                                                  type: AdminBadgeType.info)
                                              : null,
                                        )),
                                    ListTile(
                                      dense: true,
                                      leading: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 18,
                                          color: AdminColors.gold),
                                      title: const Text('Add Lesson',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AdminColors.gold,
                                              fontWeight: FontWeight.w600)),
                                      onTap: () => _showAddLessonDialog(
                                          context, ref, mod['id']),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  // Resources sidebar
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: AdminCard(
                        title: 'Course Resources',
                        headerActions: [
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 18),
                            onPressed: () {},
                            tooltip: 'Add resource',
                          ),
                        ],
                        padding: EdgeInsets.zero,
                        child: resources.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: AdminEmptyState(
                                  icon: Icons.folder_outlined,
                                  title: 'No resources yet',
                                ),
                              )
                            : Column(
                                children: resources.map((r) {
                                  return ListTile(
                                    dense: true,
                                    leading: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AdminColors.infoBg,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          color: AdminColors.info,
                                          size: 14),
                                    ),
                                    title: Text(r['title'] ?? '',
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                        '${r['type']} · ${r['size']}',
                                        style: const TextStyle(
                                            fontSize: 10)),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddModuleDialog(
      BuildContext context, WidgetRef ref, String courseId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Module',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                decoration:
                    const InputDecoration(labelText: 'Module Title'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  final modules = await Supabase.instance.client
                      .from('course_modules')
                      .select('sequence_order')
                      .eq('course_id', courseId)
                      .order('sequence_order', ascending: false)
                      .limit(1);
                  final nextOrder = modules.isEmpty
                      ? 1
                      : (modules.first['sequence_order'] as int) + 1;
                  await Supabase.instance.client.from('course_modules').insert({
                    'course_id': courseId,
                    'title': ctrl.text.trim(),
                    'sequence_order': nextOrder,
                  });
                  ref.invalidate(courseDetailAdminProvider(courseId));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add Module'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLessonDialog(
      BuildContext context, WidgetRef ref, String moduleId) {
    final titleCtrl = TextEditingController();
    final videoCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Lesson',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Lesson Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: videoCtrl,
                decoration: const InputDecoration(
                    labelText: 'YouTube URL or Video URL'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationCtrl,
                decoration:
                    const InputDecoration(labelText: 'Duration (e.g. 45m)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final lessons = await Supabase.instance.client
                      .from('lessons')
                      .select('sequence_order')
                      .eq('module_id', moduleId)
                      .order('sequence_order', ascending: false)
                      .limit(1);
                  final nextOrder = lessons.isEmpty
                      ? 1
                      : (lessons.first['sequence_order'] as int) + 1;
                  await Supabase.instance.client.from('lessons').insert({
                    'module_id': moduleId,
                    'title': titleCtrl.text.trim(),
                    'video_url': videoCtrl.text.trim(),
                    'duration': durationCtrl.text.trim(),
                    'sequence_order': nextOrder,
                    'is_preview': false,
                  });
                  ref.invalidate(courseDetailAdminProvider(courseId));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add Lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
