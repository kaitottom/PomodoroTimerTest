/*import 'package:drift/drift.dart';
//import 'goal_settings_table.dart';
import 'package:pomo_timer/data/database/tables/goal_settings_table.dart';

part 'task_table.g.dart';

@DataClassName('TaskData')
class TasksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(GoalSettingsTable, #id)();
  TextColumn get task => text()();
  IntColumn get difficulty => integer().withDefault(const Constant(3))();
  IntColumn get impact => integer().withDefault(const Constant(3))();
  DateTimeColumn get limit => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isAiGenerated => boolean().withDefault(const Constant(false))();
}
*/

import 'package:drift/drift.dart';
import 'goal_settings_table.dart';

//part 'task_table.g.dart';

@DataClassName('TaskData')
class TasksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(GoalSettingsTable, #id)();
  TextColumn get task => text()();
  IntColumn get difficulty => integer().withDefault(const Constant(3))();
  IntColumn get impact => integer().withDefault(const Constant(3))();
  DateTimeColumn get limit => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isAiGenerated => boolean().withDefault(const Constant(false))();

  //@override
  //Set<Column> get primaryKey => {id};
}
