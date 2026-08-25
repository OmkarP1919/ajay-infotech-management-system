import 'package:flutter_test/flutter_test.dart';
import 'package:ajay_infotech_admin/core/theme/admin_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AdminTheme configuration test', () {
    expect(AdminColors.primaryTeal.value, 0xFF0F3F47);
    expect(AdminColors.gold.value, 0xFFF2A710);
  });
}
