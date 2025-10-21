// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get myTasks => 'My Tasks';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get enterTaskName => 'Введите название задачи';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get editTaskName => 'Edit task name';

  @override
  String get editDescription => 'Edit description';

  @override
  String get taskAdded => 'Задача успешно добавлена!';

  @override
  String get taskEdited => 'Task edited successfully';

  @override
  String get taskDeleted => 'Task deleted successfully!';

  @override
  String get taskStatusUpdated => 'Task status updated successfully!';

  @override
  String errorAddingTask(Object error) {
    return 'Error adding task: $error';
  }

  @override
  String errorEditingTask(Object error) {
    return 'Error editing task: $error';
  }

  @override
  String errorDeletingTask(Object error) {
    return 'Error deleting task: $error';
  }

  @override
  String errorUpdatingStatus(Object error) {
    return 'Error updating status: $error';
  }
}
