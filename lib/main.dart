import 'package:muzia/app/app.dart';
import 'package:muzia/features/library/presentation/library_view_model.dart';

void main() {
  runMuziaApp(libraryViewModel: LibraryViewModel.persistent());
}
