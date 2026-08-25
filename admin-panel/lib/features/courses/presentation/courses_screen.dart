import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';

final coursesAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await Supabase.instance.client
      .from('courses')
      .select('*, course_modules(count)')
      .order('created_at', ascending: false);
});

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesAdminProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Courses',
          subtitle: 'Manage course catalog, modules, and lessons',
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Course'),
              onPressed: () => _showAddDialog(context, ref),
            ),
          ],
        ),
        Expanded(
          child: coursesAsync.when(
            loading: () => const AdminLoadingSpinner(),
            error: (e, _) => AdminErrorState(message: e.toString(),
                onRetry: () => ref.invalidate(coursesAdminProvider)),
            data: (courses) {
              if (courses.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'No courses yet',
                  action: ElevatedButton(
                    onPressed: () => _showAddDialog(context, ref),
                    child: const Text('Add First Course'),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: courses.length,
                itemBuilder: (_, i) => _CourseCard(
                  course: courses[i],
                  onTap: () => context.go('/courses/${courses[i]['id']}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddCourseDialog(onCreated: () => ref.invalidate(coursesAdminProvider)),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course['category'] ?? 'General',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.primaryTeal),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AdminColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              course['title'] ?? 'Untitled Course',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Instructor: ${course['instructor'] ?? '—'}',
              style: const TextStyle(
                  fontSize: 11, color: AdminColors.textMuted),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.book_rounded,
                    size: 12, color: AdminColors.textMuted),
                const SizedBox(width: 4),
                Text('${course['total_lessons'] ?? 0} lessons',
                    style: const TextStyle(
                        fontSize: 11, color: AdminColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCourseDialog extends StatefulWidget {
  final VoidCallback onCreated;
  const _AddCourseDialog({required this.onCreated});

  @override
  State<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<_AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('courses').insert({
        'title': _titleCtrl.text.trim(),
        'category': _categoryCtrl.text.trim(),
        'instructor': _instructorCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'total_lessons': 0,
      });
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add New Course',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Course Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                    labelText: 'Category (e.g. Full Stack, Flutter)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _instructorCtrl,
                decoration: const InputDecoration(labelText: 'Instructor Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _create,
                    child: _isLoading
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Course'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
