/*import 'package:drift/drift.dart';

part 'goal_settings_table.g.dart';


@DataClassName('GoalSettingData')
class GoalSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goal => text()();
  IntColumn get importance => integer().withDefault(const Constant(3))();
  IntColumn get impact => integer().withDefault(const Constant(3))();
  DateTimeColumn get limit => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get aiGeneratedTasks => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}
*/
import 'package:drift/drift.dart';

//part 'goal_settings_table.g.dart';

@DataClassName('GoalSettingData')
class GoalSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goal => text()();
  IntColumn get importance => integer().withDefault(const Constant(3))();
  IntColumn get impact => integer().withDefault(const Constant(3))();
  DateTimeColumn get limit => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get aiGeneratedTasks => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();


  //@override
  //Set<Column> get primaryKey => {id};
}
