// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GoalSettingsTableTable extends GoalSettingsTable
    with TableInfo<$GoalSettingsTableTable, GoalSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
      'goal', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _importanceMeta =
      const VerificationMeta('importance');
  @override
  late final GeneratedColumn<int> importance = GeneratedColumn<int>(
      'importance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<int> impact = GeneratedColumn<int>(
      'impact', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _limitMeta = const VerificationMeta('limit');
  @override
  late final GeneratedColumn<DateTime> limit = GeneratedColumn<DateTime>(
      'limit', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _aiGeneratedTasksMeta =
      const VerificationMeta('aiGeneratedTasks');
  @override
  late final GeneratedColumn<String> aiGeneratedTasks = GeneratedColumn<String>(
      'ai_generated_tasks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        goal,
        importance,
        impact,
        limit,
        isCompleted,
        createdAt,
        aiGeneratedTasks,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<GoalSettingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
          _goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('importance')) {
      context.handle(
          _importanceMeta,
          importance.isAcceptableOrUnknown(
              data['importance']!, _importanceMeta));
    }
    if (data.containsKey('impact')) {
      context.handle(_impactMeta,
          impact.isAcceptableOrUnknown(data['impact']!, _impactMeta));
    }
    if (data.containsKey('limit')) {
      context.handle(
          _limitMeta, limit.isAcceptableOrUnknown(data['limit']!, _limitMeta));
    } else if (isInserting) {
      context.missing(_limitMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('ai_generated_tasks')) {
      context.handle(
          _aiGeneratedTasksMeta,
          aiGeneratedTasks.isAcceptableOrUnknown(
              data['ai_generated_tasks']!, _aiGeneratedTasksMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalSettingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal'])!,
      importance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}importance'])!,
      impact: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}impact'])!,
      limit: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}limit'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      aiGeneratedTasks: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ai_generated_tasks']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $GoalSettingsTableTable createAlias(String alias) {
    return $GoalSettingsTableTable(attachedDatabase, alias);
  }
}

class GoalSettingData extends DataClass implements Insertable<GoalSettingData> {
  final int id;
  final String goal;
  final int importance;
  final int impact;
  final DateTime limit;
  final bool isCompleted;
  final DateTime? createdAt;
  final String? aiGeneratedTasks;
  final DateTime? completedAt;
  const GoalSettingData(
      {required this.id,
      required this.goal,
      required this.importance,
      required this.impact,
      required this.limit,
      required this.isCompleted,
      this.createdAt,
      this.aiGeneratedTasks,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal'] = Variable<String>(goal);
    map['importance'] = Variable<int>(importance);
    map['impact'] = Variable<int>(impact);
    map['limit'] = Variable<DateTime>(limit);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || aiGeneratedTasks != null) {
      map['ai_generated_tasks'] = Variable<String>(aiGeneratedTasks);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  GoalSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return GoalSettingsTableCompanion(
      id: Value(id),
      goal: Value(goal),
      importance: Value(importance),
      impact: Value(impact),
      limit: Value(limit),
      isCompleted: Value(isCompleted),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      aiGeneratedTasks: aiGeneratedTasks == null && nullToAbsent
          ? const Value.absent()
          : Value(aiGeneratedTasks),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory GoalSettingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalSettingData(
      id: serializer.fromJson<int>(json['id']),
      goal: serializer.fromJson<String>(json['goal']),
      importance: serializer.fromJson<int>(json['importance']),
      impact: serializer.fromJson<int>(json['impact']),
      limit: serializer.fromJson<DateTime>(json['limit']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      aiGeneratedTasks: serializer.fromJson<String?>(json['aiGeneratedTasks']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goal': serializer.toJson<String>(goal),
      'importance': serializer.toJson<int>(importance),
      'impact': serializer.toJson<int>(impact),
      'limit': serializer.toJson<DateTime>(limit),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'aiGeneratedTasks': serializer.toJson<String?>(aiGeneratedTasks),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  GoalSettingData copyWith(
          {int? id,
          String? goal,
          int? importance,
          int? impact,
          DateTime? limit,
          bool? isCompleted,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<String?> aiGeneratedTasks = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent()}) =>
      GoalSettingData(
        id: id ?? this.id,
        goal: goal ?? this.goal,
        importance: importance ?? this.importance,
        impact: impact ?? this.impact,
        limit: limit ?? this.limit,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        aiGeneratedTasks: aiGeneratedTasks.present
            ? aiGeneratedTasks.value
            : this.aiGeneratedTasks,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  GoalSettingData copyWithCompanion(GoalSettingsTableCompanion data) {
    return GoalSettingData(
      id: data.id.present ? data.id.value : this.id,
      goal: data.goal.present ? data.goal.value : this.goal,
      importance:
          data.importance.present ? data.importance.value : this.importance,
      impact: data.impact.present ? data.impact.value : this.impact,
      limit: data.limit.present ? data.limit.value : this.limit,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      aiGeneratedTasks: data.aiGeneratedTasks.present
          ? data.aiGeneratedTasks.value
          : this.aiGeneratedTasks,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalSettingData(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('importance: $importance, ')
          ..write('impact: $impact, ')
          ..write('limit: $limit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('aiGeneratedTasks: $aiGeneratedTasks, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goal, importance, impact, limit,
      isCompleted, createdAt, aiGeneratedTasks, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalSettingData &&
          other.id == this.id &&
          other.goal == this.goal &&
          other.importance == this.importance &&
          other.impact == this.impact &&
          other.limit == this.limit &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.aiGeneratedTasks == this.aiGeneratedTasks &&
          other.completedAt == this.completedAt);
}

class GoalSettingsTableCompanion extends UpdateCompanion<GoalSettingData> {
  final Value<int> id;
  final Value<String> goal;
  final Value<int> importance;
  final Value<int> impact;
  final Value<DateTime> limit;
  final Value<bool> isCompleted;
  final Value<DateTime?> createdAt;
  final Value<String?> aiGeneratedTasks;
  final Value<DateTime?> completedAt;
  const GoalSettingsTableCompanion({
    this.id = const Value.absent(),
    this.goal = const Value.absent(),
    this.importance = const Value.absent(),
    this.impact = const Value.absent(),
    this.limit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.aiGeneratedTasks = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  GoalSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required String goal,
    this.importance = const Value.absent(),
    this.impact = const Value.absent(),
    required DateTime limit,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.aiGeneratedTasks = const Value.absent(),
    this.completedAt = const Value.absent(),
  })  : goal = Value(goal),
        limit = Value(limit);
  static Insertable<GoalSettingData> custom({
    Expression<int>? id,
    Expression<String>? goal,
    Expression<int>? importance,
    Expression<int>? impact,
    Expression<DateTime>? limit,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<String>? aiGeneratedTasks,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goal != null) 'goal': goal,
      if (importance != null) 'importance': importance,
      if (impact != null) 'impact': impact,
      if (limit != null) 'limit': limit,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (aiGeneratedTasks != null) 'ai_generated_tasks': aiGeneratedTasks,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  GoalSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? goal,
      Value<int>? importance,
      Value<int>? impact,
      Value<DateTime>? limit,
      Value<bool>? isCompleted,
      Value<DateTime?>? createdAt,
      Value<String?>? aiGeneratedTasks,
      Value<DateTime?>? completedAt}) {
    return GoalSettingsTableCompanion(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      importance: importance ?? this.importance,
      impact: impact ?? this.impact,
      limit: limit ?? this.limit,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      aiGeneratedTasks: aiGeneratedTasks ?? this.aiGeneratedTasks,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(importance.value);
    }
    if (impact.present) {
      map['impact'] = Variable<int>(impact.value);
    }
    if (limit.present) {
      map['limit'] = Variable<DateTime>(limit.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (aiGeneratedTasks.present) {
      map['ai_generated_tasks'] = Variable<String>(aiGeneratedTasks.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('importance: $importance, ')
          ..write('impact: $impact, ')
          ..write('limit: $limit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('aiGeneratedTasks: $aiGeneratedTasks, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES goal_settings_table (id)'));
  static const VerificationMeta _taskMeta = const VerificationMeta('task');
  @override
  late final GeneratedColumn<String> task = GeneratedColumn<String>(
      'task', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _importanceMeta =
      const VerificationMeta('importance');
  @override
  late final GeneratedColumn<int> importance = GeneratedColumn<int>(
      'importance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _limitMeta = const VerificationMeta('limit');
  @override
  late final GeneratedColumn<DateTime> limit = GeneratedColumn<DateTime>(
      'limit', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isAiGeneratedMeta =
      const VerificationMeta('isAiGenerated');
  @override
  late final GeneratedColumn<bool> isAiGenerated = GeneratedColumn<bool>(
      'is_ai_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_ai_generated" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        goalId,
        task,
        importance,
        difficulty,
        limit,
        isCompleted,
        isAiGenerated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(Insertable<TaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('task')) {
      context.handle(
          _taskMeta, task.isAcceptableOrUnknown(data['task']!, _taskMeta));
    } else if (isInserting) {
      context.missing(_taskMeta);
    }
    if (data.containsKey('importance')) {
      context.handle(
          _importanceMeta,
          importance.isAcceptableOrUnknown(
              data['importance']!, _importanceMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('limit')) {
      context.handle(
          _limitMeta, limit.isAcceptableOrUnknown(data['limit']!, _limitMeta));
    } else if (isInserting) {
      context.missing(_limitMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_ai_generated')) {
      context.handle(
          _isAiGeneratedMeta,
          isAiGenerated.isAcceptableOrUnknown(
              data['is_ai_generated']!, _isAiGeneratedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id'])!,
      task: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task'])!,
      importance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}importance'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      limit: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}limit'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isAiGenerated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_ai_generated'])!,
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TaskData extends DataClass implements Insertable<TaskData> {
  final int id;
  final int goalId;
  final String task;
  final int importance;
  final int difficulty;
  final DateTime limit;
  final bool isCompleted;
  final bool isAiGenerated;
  const TaskData(
      {required this.id,
      required this.goalId,
      required this.task,
      required this.importance,
      required this.difficulty,
      required this.limit,
      required this.isCompleted,
      required this.isAiGenerated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['task'] = Variable<String>(task);
    map['importance'] = Variable<int>(importance);
    map['difficulty'] = Variable<int>(difficulty);
    map['limit'] = Variable<DateTime>(limit);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_ai_generated'] = Variable<bool>(isAiGenerated);
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      id: Value(id),
      goalId: Value(goalId),
      task: Value(task),
      importance: Value(importance),
      difficulty: Value(difficulty),
      limit: Value(limit),
      isCompleted: Value(isCompleted),
      isAiGenerated: Value(isAiGenerated),
    );
  }

  factory TaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskData(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      task: serializer.fromJson<String>(json['task']),
      importance: serializer.fromJson<int>(json['importance']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      limit: serializer.fromJson<DateTime>(json['limit']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isAiGenerated: serializer.fromJson<bool>(json['isAiGenerated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'task': serializer.toJson<String>(task),
      'importance': serializer.toJson<int>(importance),
      'difficulty': serializer.toJson<int>(difficulty),
      'limit': serializer.toJson<DateTime>(limit),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isAiGenerated': serializer.toJson<bool>(isAiGenerated),
    };
  }

  TaskData copyWith(
          {int? id,
          int? goalId,
          String? task,
          int? importance,
          int? difficulty,
          DateTime? limit,
          bool? isCompleted,
          bool? isAiGenerated}) =>
      TaskData(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        task: task ?? this.task,
        importance: importance ?? this.importance,
        difficulty: difficulty ?? this.difficulty,
        limit: limit ?? this.limit,
        isCompleted: isCompleted ?? this.isCompleted,
        isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      );
  TaskData copyWithCompanion(TasksTableCompanion data) {
    return TaskData(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      task: data.task.present ? data.task.value : this.task,
      importance:
          data.importance.present ? data.importance.value : this.importance,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      limit: data.limit.present ? data.limit.value : this.limit,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isAiGenerated: data.isAiGenerated.present
          ? data.isAiGenerated.value
          : this.isAiGenerated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskData(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('task: $task, ')
          ..write('importance: $importance, ')
          ..write('difficulty: $difficulty, ')
          ..write('limit: $limit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isAiGenerated: $isAiGenerated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goalId, task, importance, difficulty,
      limit, isCompleted, isAiGenerated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskData &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.task == this.task &&
          other.importance == this.importance &&
          other.difficulty == this.difficulty &&
          other.limit == this.limit &&
          other.isCompleted == this.isCompleted &&
          other.isAiGenerated == this.isAiGenerated);
}

class TasksTableCompanion extends UpdateCompanion<TaskData> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<String> task;
  final Value<int> importance;
  final Value<int> difficulty;
  final Value<DateTime> limit;
  final Value<bool> isCompleted;
  final Value<bool> isAiGenerated;
  const TasksTableCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.task = const Value.absent(),
    this.importance = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.limit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isAiGenerated = const Value.absent(),
  });
  TasksTableCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required String task,
    this.importance = const Value.absent(),
    this.difficulty = const Value.absent(),
    required DateTime limit,
    this.isCompleted = const Value.absent(),
    this.isAiGenerated = const Value.absent(),
  })  : goalId = Value(goalId),
        task = Value(task),
        limit = Value(limit);
  static Insertable<TaskData> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<String>? task,
    Expression<int>? importance,
    Expression<int>? difficulty,
    Expression<DateTime>? limit,
    Expression<bool>? isCompleted,
    Expression<bool>? isAiGenerated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (task != null) 'task': task,
      if (importance != null) 'importance': importance,
      if (difficulty != null) 'difficulty': difficulty,
      if (limit != null) 'limit': limit,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isAiGenerated != null) 'is_ai_generated': isAiGenerated,
    });
  }

  TasksTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? goalId,
      Value<String>? task,
      Value<int>? importance,
      Value<int>? difficulty,
      Value<DateTime>? limit,
      Value<bool>? isCompleted,
      Value<bool>? isAiGenerated}) {
    return TasksTableCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      task: task ?? this.task,
      importance: importance ?? this.importance,
      difficulty: difficulty ?? this.difficulty,
      limit: limit ?? this.limit,
      isCompleted: isCompleted ?? this.isCompleted,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (task.present) {
      map['task'] = Variable<String>(task.value);
    }
    if (importance.present) {
      map['importance'] = Variable<int>(importance.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (limit.present) {
      map['limit'] = Variable<DateTime>(limit.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isAiGenerated.present) {
      map['is_ai_generated'] = Variable<bool>(isAiGenerated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('task: $task, ')
          ..write('importance: $importance, ')
          ..write('difficulty: $difficulty, ')
          ..write('limit: $limit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isAiGenerated: $isAiGenerated')
          ..write(')'))
        .toString();
  }
}

class $ScoresTableTable extends ScoresTable
    with TableInfo<$ScoresTableTable, ScoresTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoresTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalMinutesMeta =
      const VerificationMeta('totalMinutes');
  @override
  late final GeneratedColumn<int> totalMinutes = GeneratedColumn<int>(
      'total_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _concentrationLevelMeta =
      const VerificationMeta('concentrationLevel');
  @override
  late final GeneratedColumn<int> concentrationLevel = GeneratedColumn<int>(
      'concentration_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _goalNameMeta =
      const VerificationMeta('goalName');
  @override
  late final GeneratedColumn<String> goalName = GeneratedColumn<String>(
      'goal_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _evaluationModeMeta =
      const VerificationMeta('evaluationMode');
  @override
  late final GeneratedColumn<int> evaluationMode = GeneratedColumn<int>(
      'evaluation_mode', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalScoreMeta =
      const VerificationMeta('totalScore');
  @override
  late final GeneratedColumn<double> totalScore = GeneratedColumn<double>(
      'total_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isDraftMeta =
      const VerificationMeta('isDraft');
  @override
  late final GeneratedColumn<bool> isDraft = GeneratedColumn<bool>(
      'is_draft', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_draft" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _taskDataJsonMeta =
      const VerificationMeta('taskDataJson');
  @override
  late final GeneratedColumn<String> taskDataJson = GeneratedColumn<String>(
      'task_data_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _goodPointsMeta =
      const VerificationMeta('goodPoints');
  @override
  late final GeneratedColumn<String> goodPoints = GeneratedColumn<String>(
      'good_points', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _improvementPointsMeta =
      const VerificationMeta('improvementPoints');
  @override
  late final GeneratedColumn<String> improvementPoints =
      GeneratedColumn<String>('improvement_points', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _futurePlansMeta =
      const VerificationMeta('futurePlans');
  @override
  late final GeneratedColumn<String> futurePlans = GeneratedColumn<String>(
      'future_plans', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startedAt,
        endedAt,
        totalMinutes,
        concentrationLevel,
        goalId,
        goalName,
        evaluationMode,
        totalScore,
        isDraft,
        taskDataJson,
        goodPoints,
        improvementPoints,
        futurePlans
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scores_table';
  @override
  VerificationContext validateIntegrity(Insertable<ScoresTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('total_minutes')) {
      context.handle(
          _totalMinutesMeta,
          totalMinutes.isAcceptableOrUnknown(
              data['total_minutes']!, _totalMinutesMeta));
    } else if (isInserting) {
      context.missing(_totalMinutesMeta);
    }
    if (data.containsKey('concentration_level')) {
      context.handle(
          _concentrationLevelMeta,
          concentrationLevel.isAcceptableOrUnknown(
              data['concentration_level']!, _concentrationLevelMeta));
    } else if (isInserting) {
      context.missing(_concentrationLevelMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    }
    if (data.containsKey('goal_name')) {
      context.handle(_goalNameMeta,
          goalName.isAcceptableOrUnknown(data['goal_name']!, _goalNameMeta));
    }
    if (data.containsKey('evaluation_mode')) {
      context.handle(
          _evaluationModeMeta,
          evaluationMode.isAcceptableOrUnknown(
              data['evaluation_mode']!, _evaluationModeMeta));
    } else if (isInserting) {
      context.missing(_evaluationModeMeta);
    }
    if (data.containsKey('total_score')) {
      context.handle(
          _totalScoreMeta,
          totalScore.isAcceptableOrUnknown(
              data['total_score']!, _totalScoreMeta));
    } else if (isInserting) {
      context.missing(_totalScoreMeta);
    }
    if (data.containsKey('is_draft')) {
      context.handle(_isDraftMeta,
          isDraft.isAcceptableOrUnknown(data['is_draft']!, _isDraftMeta));
    }
    if (data.containsKey('task_data_json')) {
      context.handle(
          _taskDataJsonMeta,
          taskDataJson.isAcceptableOrUnknown(
              data['task_data_json']!, _taskDataJsonMeta));
    }
    if (data.containsKey('good_points')) {
      context.handle(
          _goodPointsMeta,
          goodPoints.isAcceptableOrUnknown(
              data['good_points']!, _goodPointsMeta));
    }
    if (data.containsKey('improvement_points')) {
      context.handle(
          _improvementPointsMeta,
          improvementPoints.isAcceptableOrUnknown(
              data['improvement_points']!, _improvementPointsMeta));
    }
    if (data.containsKey('future_plans')) {
      context.handle(
          _futurePlansMeta,
          futurePlans.isAcceptableOrUnknown(
              data['future_plans']!, _futurePlansMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScoresTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoresTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at'])!,
      totalMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_minutes'])!,
      concentrationLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}concentration_level'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id']),
      goalName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_name']),
      evaluationMode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}evaluation_mode'])!,
      totalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_score'])!,
      isDraft: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_draft'])!,
      taskDataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_data_json']),
      goodPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}good_points']),
      improvementPoints: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}improvement_points']),
      futurePlans: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}future_plans']),
    );
  }

  @override
  $ScoresTableTable createAlias(String alias) {
    return $ScoresTableTable(attachedDatabase, alias);
  }
}

class ScoresTableData extends DataClass implements Insertable<ScoresTableData> {
  final int id;
  final DateTime startedAt;
  final DateTime endedAt;
  final int totalMinutes;
  final int concentrationLevel;
  final int? goalId;
  final String? goalName;
  final int evaluationMode;
  final double totalScore;
  final bool isDraft;
  final String? taskDataJson;
  final String? goodPoints;
  final String? improvementPoints;
  final String? futurePlans;
  const ScoresTableData(
      {required this.id,
      required this.startedAt,
      required this.endedAt,
      required this.totalMinutes,
      required this.concentrationLevel,
      this.goalId,
      this.goalName,
      required this.evaluationMode,
      required this.totalScore,
      required this.isDraft,
      this.taskDataJson,
      this.goodPoints,
      this.improvementPoints,
      this.futurePlans});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['total_minutes'] = Variable<int>(totalMinutes);
    map['concentration_level'] = Variable<int>(concentrationLevel);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    if (!nullToAbsent || goalName != null) {
      map['goal_name'] = Variable<String>(goalName);
    }
    map['evaluation_mode'] = Variable<int>(evaluationMode);
    map['total_score'] = Variable<double>(totalScore);
    map['is_draft'] = Variable<bool>(isDraft);
    if (!nullToAbsent || taskDataJson != null) {
      map['task_data_json'] = Variable<String>(taskDataJson);
    }
    if (!nullToAbsent || goodPoints != null) {
      map['good_points'] = Variable<String>(goodPoints);
    }
    if (!nullToAbsent || improvementPoints != null) {
      map['improvement_points'] = Variable<String>(improvementPoints);
    }
    if (!nullToAbsent || futurePlans != null) {
      map['future_plans'] = Variable<String>(futurePlans);
    }
    return map;
  }

  ScoresTableCompanion toCompanion(bool nullToAbsent) {
    return ScoresTableCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      totalMinutes: Value(totalMinutes),
      concentrationLevel: Value(concentrationLevel),
      goalId:
          goalId == null && nullToAbsent ? const Value.absent() : Value(goalId),
      goalName: goalName == null && nullToAbsent
          ? const Value.absent()
          : Value(goalName),
      evaluationMode: Value(evaluationMode),
      totalScore: Value(totalScore),
      isDraft: Value(isDraft),
      taskDataJson: taskDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(taskDataJson),
      goodPoints: goodPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(goodPoints),
      improvementPoints: improvementPoints == null && nullToAbsent
          ? const Value.absent()
          : Value(improvementPoints),
      futurePlans: futurePlans == null && nullToAbsent
          ? const Value.absent()
          : Value(futurePlans),
    );
  }

  factory ScoresTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoresTableData(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      totalMinutes: serializer.fromJson<int>(json['totalMinutes']),
      concentrationLevel: serializer.fromJson<int>(json['concentrationLevel']),
      goalId: serializer.fromJson<int?>(json['goalId']),
      goalName: serializer.fromJson<String?>(json['goalName']),
      evaluationMode: serializer.fromJson<int>(json['evaluationMode']),
      totalScore: serializer.fromJson<double>(json['totalScore']),
      isDraft: serializer.fromJson<bool>(json['isDraft']),
      taskDataJson: serializer.fromJson<String?>(json['taskDataJson']),
      goodPoints: serializer.fromJson<String?>(json['goodPoints']),
      improvementPoints:
          serializer.fromJson<String?>(json['improvementPoints']),
      futurePlans: serializer.fromJson<String?>(json['futurePlans']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'totalMinutes': serializer.toJson<int>(totalMinutes),
      'concentrationLevel': serializer.toJson<int>(concentrationLevel),
      'goalId': serializer.toJson<int?>(goalId),
      'goalName': serializer.toJson<String?>(goalName),
      'evaluationMode': serializer.toJson<int>(evaluationMode),
      'totalScore': serializer.toJson<double>(totalScore),
      'isDraft': serializer.toJson<bool>(isDraft),
      'taskDataJson': serializer.toJson<String?>(taskDataJson),
      'goodPoints': serializer.toJson<String?>(goodPoints),
      'improvementPoints': serializer.toJson<String?>(improvementPoints),
      'futurePlans': serializer.toJson<String?>(futurePlans),
    };
  }

  ScoresTableData copyWith(
          {int? id,
          DateTime? startedAt,
          DateTime? endedAt,
          int? totalMinutes,
          int? concentrationLevel,
          Value<int?> goalId = const Value.absent(),
          Value<String?> goalName = const Value.absent(),
          int? evaluationMode,
          double? totalScore,
          bool? isDraft,
          Value<String?> taskDataJson = const Value.absent(),
          Value<String?> goodPoints = const Value.absent(),
          Value<String?> improvementPoints = const Value.absent(),
          Value<String?> futurePlans = const Value.absent()}) =>
      ScoresTableData(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        concentrationLevel: concentrationLevel ?? this.concentrationLevel,
        goalId: goalId.present ? goalId.value : this.goalId,
        goalName: goalName.present ? goalName.value : this.goalName,
        evaluationMode: evaluationMode ?? this.evaluationMode,
        totalScore: totalScore ?? this.totalScore,
        isDraft: isDraft ?? this.isDraft,
        taskDataJson:
            taskDataJson.present ? taskDataJson.value : this.taskDataJson,
        goodPoints: goodPoints.present ? goodPoints.value : this.goodPoints,
        improvementPoints: improvementPoints.present
            ? improvementPoints.value
            : this.improvementPoints,
        futurePlans: futurePlans.present ? futurePlans.value : this.futurePlans,
      );
  ScoresTableData copyWithCompanion(ScoresTableCompanion data) {
    return ScoresTableData(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      totalMinutes: data.totalMinutes.present
          ? data.totalMinutes.value
          : this.totalMinutes,
      concentrationLevel: data.concentrationLevel.present
          ? data.concentrationLevel.value
          : this.concentrationLevel,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      goalName: data.goalName.present ? data.goalName.value : this.goalName,
      evaluationMode: data.evaluationMode.present
          ? data.evaluationMode.value
          : this.evaluationMode,
      totalScore:
          data.totalScore.present ? data.totalScore.value : this.totalScore,
      isDraft: data.isDraft.present ? data.isDraft.value : this.isDraft,
      taskDataJson: data.taskDataJson.present
          ? data.taskDataJson.value
          : this.taskDataJson,
      goodPoints:
          data.goodPoints.present ? data.goodPoints.value : this.goodPoints,
      improvementPoints: data.improvementPoints.present
          ? data.improvementPoints.value
          : this.improvementPoints,
      futurePlans:
          data.futurePlans.present ? data.futurePlans.value : this.futurePlans,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoresTableData(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalMinutes: $totalMinutes, ')
          ..write('concentrationLevel: $concentrationLevel, ')
          ..write('goalId: $goalId, ')
          ..write('goalName: $goalName, ')
          ..write('evaluationMode: $evaluationMode, ')
          ..write('totalScore: $totalScore, ')
          ..write('isDraft: $isDraft, ')
          ..write('taskDataJson: $taskDataJson, ')
          ..write('goodPoints: $goodPoints, ')
          ..write('improvementPoints: $improvementPoints, ')
          ..write('futurePlans: $futurePlans')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      startedAt,
      endedAt,
      totalMinutes,
      concentrationLevel,
      goalId,
      goalName,
      evaluationMode,
      totalScore,
      isDraft,
      taskDataJson,
      goodPoints,
      improvementPoints,
      futurePlans);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoresTableData &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.totalMinutes == this.totalMinutes &&
          other.concentrationLevel == this.concentrationLevel &&
          other.goalId == this.goalId &&
          other.goalName == this.goalName &&
          other.evaluationMode == this.evaluationMode &&
          other.totalScore == this.totalScore &&
          other.isDraft == this.isDraft &&
          other.taskDataJson == this.taskDataJson &&
          other.goodPoints == this.goodPoints &&
          other.improvementPoints == this.improvementPoints &&
          other.futurePlans == this.futurePlans);
}

class ScoresTableCompanion extends UpdateCompanion<ScoresTableData> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> totalMinutes;
  final Value<int> concentrationLevel;
  final Value<int?> goalId;
  final Value<String?> goalName;
  final Value<int> evaluationMode;
  final Value<double> totalScore;
  final Value<bool> isDraft;
  final Value<String?> taskDataJson;
  final Value<String?> goodPoints;
  final Value<String?> improvementPoints;
  final Value<String?> futurePlans;
  const ScoresTableCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.totalMinutes = const Value.absent(),
    this.concentrationLevel = const Value.absent(),
    this.goalId = const Value.absent(),
    this.goalName = const Value.absent(),
    this.evaluationMode = const Value.absent(),
    this.totalScore = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.taskDataJson = const Value.absent(),
    this.goodPoints = const Value.absent(),
    this.improvementPoints = const Value.absent(),
    this.futurePlans = const Value.absent(),
  });
  ScoresTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    required DateTime endedAt,
    required int totalMinutes,
    required int concentrationLevel,
    this.goalId = const Value.absent(),
    this.goalName = const Value.absent(),
    required int evaluationMode,
    required double totalScore,
    this.isDraft = const Value.absent(),
    this.taskDataJson = const Value.absent(),
    this.goodPoints = const Value.absent(),
    this.improvementPoints = const Value.absent(),
    this.futurePlans = const Value.absent(),
  })  : startedAt = Value(startedAt),
        endedAt = Value(endedAt),
        totalMinutes = Value(totalMinutes),
        concentrationLevel = Value(concentrationLevel),
        evaluationMode = Value(evaluationMode),
        totalScore = Value(totalScore);
  static Insertable<ScoresTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? totalMinutes,
    Expression<int>? concentrationLevel,
    Expression<int>? goalId,
    Expression<String>? goalName,
    Expression<int>? evaluationMode,
    Expression<double>? totalScore,
    Expression<bool>? isDraft,
    Expression<String>? taskDataJson,
    Expression<String>? goodPoints,
    Expression<String>? improvementPoints,
    Expression<String>? futurePlans,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (totalMinutes != null) 'total_minutes': totalMinutes,
      if (concentrationLevel != null) 'concentration_level': concentrationLevel,
      if (goalId != null) 'goal_id': goalId,
      if (goalName != null) 'goal_name': goalName,
      if (evaluationMode != null) 'evaluation_mode': evaluationMode,
      if (totalScore != null) 'total_score': totalScore,
      if (isDraft != null) 'is_draft': isDraft,
      if (taskDataJson != null) 'task_data_json': taskDataJson,
      if (goodPoints != null) 'good_points': goodPoints,
      if (improvementPoints != null) 'improvement_points': improvementPoints,
      if (futurePlans != null) 'future_plans': futurePlans,
    });
  }

  ScoresTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? startedAt,
      Value<DateTime>? endedAt,
      Value<int>? totalMinutes,
      Value<int>? concentrationLevel,
      Value<int?>? goalId,
      Value<String?>? goalName,
      Value<int>? evaluationMode,
      Value<double>? totalScore,
      Value<bool>? isDraft,
      Value<String?>? taskDataJson,
      Value<String?>? goodPoints,
      Value<String?>? improvementPoints,
      Value<String?>? futurePlans}) {
    return ScoresTableCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      concentrationLevel: concentrationLevel ?? this.concentrationLevel,
      goalId: goalId ?? this.goalId,
      goalName: goalName ?? this.goalName,
      evaluationMode: evaluationMode ?? this.evaluationMode,
      totalScore: totalScore ?? this.totalScore,
      isDraft: isDraft ?? this.isDraft,
      taskDataJson: taskDataJson ?? this.taskDataJson,
      goodPoints: goodPoints ?? this.goodPoints,
      improvementPoints: improvementPoints ?? this.improvementPoints,
      futurePlans: futurePlans ?? this.futurePlans,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (totalMinutes.present) {
      map['total_minutes'] = Variable<int>(totalMinutes.value);
    }
    if (concentrationLevel.present) {
      map['concentration_level'] = Variable<int>(concentrationLevel.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (goalName.present) {
      map['goal_name'] = Variable<String>(goalName.value);
    }
    if (evaluationMode.present) {
      map['evaluation_mode'] = Variable<int>(evaluationMode.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<double>(totalScore.value);
    }
    if (isDraft.present) {
      map['is_draft'] = Variable<bool>(isDraft.value);
    }
    if (taskDataJson.present) {
      map['task_data_json'] = Variable<String>(taskDataJson.value);
    }
    if (goodPoints.present) {
      map['good_points'] = Variable<String>(goodPoints.value);
    }
    if (improvementPoints.present) {
      map['improvement_points'] = Variable<String>(improvementPoints.value);
    }
    if (futurePlans.present) {
      map['future_plans'] = Variable<String>(futurePlans.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoresTableCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalMinutes: $totalMinutes, ')
          ..write('concentrationLevel: $concentrationLevel, ')
          ..write('goalId: $goalId, ')
          ..write('goalName: $goalName, ')
          ..write('evaluationMode: $evaluationMode, ')
          ..write('totalScore: $totalScore, ')
          ..write('isDraft: $isDraft, ')
          ..write('taskDataJson: $taskDataJson, ')
          ..write('goodPoints: $goodPoints, ')
          ..write('improvementPoints: $improvementPoints, ')
          ..write('futurePlans: $futurePlans')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalSettingsTableTable goalSettingsTable =
      $GoalSettingsTableTable(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $ScoresTableTable scoresTable = $ScoresTableTable(this);
  late final GoalDao goalDao = GoalDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final ScoreDao scoreDao = ScoreDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [goalSettingsTable, tasksTable, scoresTable];
}

typedef $$GoalSettingsTableTableCreateCompanionBuilder
    = GoalSettingsTableCompanion Function({
  Value<int> id,
  required String goal,
  Value<int> importance,
  Value<int> impact,
  required DateTime limit,
  Value<bool> isCompleted,
  Value<DateTime?> createdAt,
  Value<String?> aiGeneratedTasks,
  Value<DateTime?> completedAt,
});
typedef $$GoalSettingsTableTableUpdateCompanionBuilder
    = GoalSettingsTableCompanion Function({
  Value<int> id,
  Value<String> goal,
  Value<int> importance,
  Value<int> impact,
  Value<DateTime> limit,
  Value<bool> isCompleted,
  Value<DateTime?> createdAt,
  Value<String?> aiGeneratedTasks,
  Value<DateTime?> completedAt,
});

final class $$GoalSettingsTableTableReferences extends BaseReferences<
    _$AppDatabase, $GoalSettingsTableTable, GoalSettingData> {
  $$GoalSettingsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTableTable, List<TaskData>>
      _tasksTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tasksTable,
              aliasName: $_aliasNameGenerator(
                  db.goalSettingsTable.id, db.tasksTable.goalId));

  $$TasksTableTableProcessedTableManager get tasksTableRefs {
    final manager = $$TasksTableTableTableManager($_db, $_db.tasksTable)
        .filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GoalSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GoalSettingsTableTable> {
  $$GoalSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get importance => $composableBuilder(
      column: $table.importance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get limit => $composableBuilder(
      column: $table.limit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiGeneratedTasks => $composableBuilder(
      column: $table.aiGeneratedTasks,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksTableRefs(
      Expression<bool> Function($$TasksTableTableFilterComposer f) f) {
    final $$TasksTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasksTable,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableTableFilterComposer(
              $db: $db,
              $table: $db.tasksTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GoalSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalSettingsTableTable> {
  $$GoalSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get importance => $composableBuilder(
      column: $table.importance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get limit => $composableBuilder(
      column: $table.limit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiGeneratedTasks => $composableBuilder(
      column: $table.aiGeneratedTasks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalSettingsTableTable> {
  $$GoalSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get importance => $composableBuilder(
      column: $table.importance, builder: (column) => column);

  GeneratedColumn<int> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<DateTime> get limit =>
      $composableBuilder(column: $table.limit, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get aiGeneratedTasks => $composableBuilder(
      column: $table.aiGeneratedTasks, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  Expression<T> tasksTableRefs<T extends Object>(
      Expression<T> Function($$TasksTableTableAnnotationComposer a) f) {
    final $$TasksTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasksTable,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableTableAnnotationComposer(
              $db: $db,
              $table: $db.tasksTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GoalSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalSettingsTableTable,
    GoalSettingData,
    $$GoalSettingsTableTableFilterComposer,
    $$GoalSettingsTableTableOrderingComposer,
    $$GoalSettingsTableTableAnnotationComposer,
    $$GoalSettingsTableTableCreateCompanionBuilder,
    $$GoalSettingsTableTableUpdateCompanionBuilder,
    (GoalSettingData, $$GoalSettingsTableTableReferences),
    GoalSettingData,
    PrefetchHooks Function({bool tasksTableRefs})> {
  $$GoalSettingsTableTableTableManager(
      _$AppDatabase db, $GoalSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> goal = const Value.absent(),
            Value<int> importance = const Value.absent(),
            Value<int> impact = const Value.absent(),
            Value<DateTime> limit = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> aiGeneratedTasks = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              GoalSettingsTableCompanion(
            id: id,
            goal: goal,
            importance: importance,
            impact: impact,
            limit: limit,
            isCompleted: isCompleted,
            createdAt: createdAt,
            aiGeneratedTasks: aiGeneratedTasks,
            completedAt: completedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String goal,
            Value<int> importance = const Value.absent(),
            Value<int> impact = const Value.absent(),
            required DateTime limit,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> aiGeneratedTasks = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
          }) =>
              GoalSettingsTableCompanion.insert(
            id: id,
            goal: goal,
            importance: importance,
            impact: impact,
            limit: limit,
            isCompleted: isCompleted,
            createdAt: createdAt,
            aiGeneratedTasks: aiGeneratedTasks,
            completedAt: completedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GoalSettingsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tasksTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksTableRefs) db.tasksTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksTableRefs)
                    await $_getPrefetchedData<GoalSettingData,
                            $GoalSettingsTableTable, TaskData>(
                        currentTable: table,
                        referencedTable: $$GoalSettingsTableTableReferences
                            ._tasksTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GoalSettingsTableTableReferences(db, table, p0)
                                .tasksTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.goalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GoalSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalSettingsTableTable,
    GoalSettingData,
    $$GoalSettingsTableTableFilterComposer,
    $$GoalSettingsTableTableOrderingComposer,
    $$GoalSettingsTableTableAnnotationComposer,
    $$GoalSettingsTableTableCreateCompanionBuilder,
    $$GoalSettingsTableTableUpdateCompanionBuilder,
    (GoalSettingData, $$GoalSettingsTableTableReferences),
    GoalSettingData,
    PrefetchHooks Function({bool tasksTableRefs})>;
typedef $$TasksTableTableCreateCompanionBuilder = TasksTableCompanion Function({
  Value<int> id,
  required int goalId,
  required String task,
  Value<int> importance,
  Value<int> difficulty,
  required DateTime limit,
  Value<bool> isCompleted,
  Value<bool> isAiGenerated,
});
typedef $$TasksTableTableUpdateCompanionBuilder = TasksTableCompanion Function({
  Value<int> id,
  Value<int> goalId,
  Value<String> task,
  Value<int> importance,
  Value<int> difficulty,
  Value<DateTime> limit,
  Value<bool> isCompleted,
  Value<bool> isAiGenerated,
});

final class $$TasksTableTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTableTable, TaskData> {
  $$TasksTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalSettingsTableTable _goalIdTable(_$AppDatabase db) =>
      db.goalSettingsTable.createAlias(
          $_aliasNameGenerator(db.tasksTable.goalId, db.goalSettingsTable.id));

  $$GoalSettingsTableTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager =
        $$GoalSettingsTableTableTableManager($_db, $_db.goalSettingsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get task => $composableBuilder(
      column: $table.task, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get importance => $composableBuilder(
      column: $table.importance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get limit => $composableBuilder(
      column: $table.limit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAiGenerated => $composableBuilder(
      column: $table.isAiGenerated, builder: (column) => ColumnFilters(column));

  $$GoalSettingsTableTableFilterComposer get goalId {
    final $$GoalSettingsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goalSettingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalSettingsTableTableFilterComposer(
              $db: $db,
              $table: $db.goalSettingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get task => $composableBuilder(
      column: $table.task, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get importance => $composableBuilder(
      column: $table.importance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get limit => $composableBuilder(
      column: $table.limit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAiGenerated => $composableBuilder(
      column: $table.isAiGenerated,
      builder: (column) => ColumnOrderings(column));

  $$GoalSettingsTableTableOrderingComposer get goalId {
    final $$GoalSettingsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.goalSettingsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalSettingsTableTableOrderingComposer(
              $db: $db,
              $table: $db.goalSettingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get task =>
      $composableBuilder(column: $table.task, builder: (column) => column);

  GeneratedColumn<int> get importance => $composableBuilder(
      column: $table.importance, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<DateTime> get limit =>
      $composableBuilder(column: $table.limit, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isAiGenerated => $composableBuilder(
      column: $table.isAiGenerated, builder: (column) => column);

  $$GoalSettingsTableTableAnnotationComposer get goalId {
    final $$GoalSettingsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.goalId,
            referencedTable: $db.goalSettingsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$GoalSettingsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.goalSettingsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TasksTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTableTable,
    TaskData,
    $$TasksTableTableFilterComposer,
    $$TasksTableTableOrderingComposer,
    $$TasksTableTableAnnotationComposer,
    $$TasksTableTableCreateCompanionBuilder,
    $$TasksTableTableUpdateCompanionBuilder,
    (TaskData, $$TasksTableTableReferences),
    TaskData,
    PrefetchHooks Function({bool goalId})> {
  $$TasksTableTableTableManager(_$AppDatabase db, $TasksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> goalId = const Value.absent(),
            Value<String> task = const Value.absent(),
            Value<int> importance = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<DateTime> limit = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isAiGenerated = const Value.absent(),
          }) =>
              TasksTableCompanion(
            id: id,
            goalId: goalId,
            task: task,
            importance: importance,
            difficulty: difficulty,
            limit: limit,
            isCompleted: isCompleted,
            isAiGenerated: isAiGenerated,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int goalId,
            required String task,
            Value<int> importance = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            required DateTime limit,
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isAiGenerated = const Value.absent(),
          }) =>
              TasksTableCompanion.insert(
            id: id,
            goalId: goalId,
            task: task,
            importance: importance,
            difficulty: difficulty,
            limit: limit,
            isCompleted: isCompleted,
            isAiGenerated: isAiGenerated,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TasksTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (goalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.goalId,
                    referencedTable:
                        $$TasksTableTableReferences._goalIdTable(db),
                    referencedColumn:
                        $$TasksTableTableReferences._goalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TasksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTableTable,
    TaskData,
    $$TasksTableTableFilterComposer,
    $$TasksTableTableOrderingComposer,
    $$TasksTableTableAnnotationComposer,
    $$TasksTableTableCreateCompanionBuilder,
    $$TasksTableTableUpdateCompanionBuilder,
    (TaskData, $$TasksTableTableReferences),
    TaskData,
    PrefetchHooks Function({bool goalId})>;
typedef $$ScoresTableTableCreateCompanionBuilder = ScoresTableCompanion
    Function({
  Value<int> id,
  required DateTime startedAt,
  required DateTime endedAt,
  required int totalMinutes,
  required int concentrationLevel,
  Value<int?> goalId,
  Value<String?> goalName,
  required int evaluationMode,
  required double totalScore,
  Value<bool> isDraft,
  Value<String?> taskDataJson,
  Value<String?> goodPoints,
  Value<String?> improvementPoints,
  Value<String?> futurePlans,
});
typedef $$ScoresTableTableUpdateCompanionBuilder = ScoresTableCompanion
    Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime> endedAt,
  Value<int> totalMinutes,
  Value<int> concentrationLevel,
  Value<int?> goalId,
  Value<String?> goalName,
  Value<int> evaluationMode,
  Value<double> totalScore,
  Value<bool> isDraft,
  Value<String?> taskDataJson,
  Value<String?> goodPoints,
  Value<String?> improvementPoints,
  Value<String?> futurePlans,
});

class $$ScoresTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScoresTableTable> {
  $$ScoresTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalMinutes => $composableBuilder(
      column: $table.totalMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get concentrationLevel => $composableBuilder(
      column: $table.concentrationLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalName => $composableBuilder(
      column: $table.goalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get evaluationMode => $composableBuilder(
      column: $table.evaluationMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalScore => $composableBuilder(
      column: $table.totalScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDraft => $composableBuilder(
      column: $table.isDraft, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskDataJson => $composableBuilder(
      column: $table.taskDataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goodPoints => $composableBuilder(
      column: $table.goodPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get improvementPoints => $composableBuilder(
      column: $table.improvementPoints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get futurePlans => $composableBuilder(
      column: $table.futurePlans, builder: (column) => ColumnFilters(column));
}

class $$ScoresTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoresTableTable> {
  $$ScoresTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalMinutes => $composableBuilder(
      column: $table.totalMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get concentrationLevel => $composableBuilder(
      column: $table.concentrationLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalName => $composableBuilder(
      column: $table.goalName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get evaluationMode => $composableBuilder(
      column: $table.evaluationMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalScore => $composableBuilder(
      column: $table.totalScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDraft => $composableBuilder(
      column: $table.isDraft, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskDataJson => $composableBuilder(
      column: $table.taskDataJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goodPoints => $composableBuilder(
      column: $table.goodPoints, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get improvementPoints => $composableBuilder(
      column: $table.improvementPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get futurePlans => $composableBuilder(
      column: $table.futurePlans, builder: (column) => ColumnOrderings(column));
}

class $$ScoresTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoresTableTable> {
  $$ScoresTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get totalMinutes => $composableBuilder(
      column: $table.totalMinutes, builder: (column) => column);

  GeneratedColumn<int> get concentrationLevel => $composableBuilder(
      column: $table.concentrationLevel, builder: (column) => column);

  GeneratedColumn<int> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get goalName =>
      $composableBuilder(column: $table.goalName, builder: (column) => column);

  GeneratedColumn<int> get evaluationMode => $composableBuilder(
      column: $table.evaluationMode, builder: (column) => column);

  GeneratedColumn<double> get totalScore => $composableBuilder(
      column: $table.totalScore, builder: (column) => column);

  GeneratedColumn<bool> get isDraft =>
      $composableBuilder(column: $table.isDraft, builder: (column) => column);

  GeneratedColumn<String> get taskDataJson => $composableBuilder(
      column: $table.taskDataJson, builder: (column) => column);

  GeneratedColumn<String> get goodPoints => $composableBuilder(
      column: $table.goodPoints, builder: (column) => column);

  GeneratedColumn<String> get improvementPoints => $composableBuilder(
      column: $table.improvementPoints, builder: (column) => column);

  GeneratedColumn<String> get futurePlans => $composableBuilder(
      column: $table.futurePlans, builder: (column) => column);
}

class $$ScoresTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScoresTableTable,
    ScoresTableData,
    $$ScoresTableTableFilterComposer,
    $$ScoresTableTableOrderingComposer,
    $$ScoresTableTableAnnotationComposer,
    $$ScoresTableTableCreateCompanionBuilder,
    $$ScoresTableTableUpdateCompanionBuilder,
    (
      ScoresTableData,
      BaseReferences<_$AppDatabase, $ScoresTableTable, ScoresTableData>
    ),
    ScoresTableData,
    PrefetchHooks Function()> {
  $$ScoresTableTableTableManager(_$AppDatabase db, $ScoresTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoresTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoresTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoresTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime> endedAt = const Value.absent(),
            Value<int> totalMinutes = const Value.absent(),
            Value<int> concentrationLevel = const Value.absent(),
            Value<int?> goalId = const Value.absent(),
            Value<String?> goalName = const Value.absent(),
            Value<int> evaluationMode = const Value.absent(),
            Value<double> totalScore = const Value.absent(),
            Value<bool> isDraft = const Value.absent(),
            Value<String?> taskDataJson = const Value.absent(),
            Value<String?> goodPoints = const Value.absent(),
            Value<String?> improvementPoints = const Value.absent(),
            Value<String?> futurePlans = const Value.absent(),
          }) =>
              ScoresTableCompanion(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            totalMinutes: totalMinutes,
            concentrationLevel: concentrationLevel,
            goalId: goalId,
            goalName: goalName,
            evaluationMode: evaluationMode,
            totalScore: totalScore,
            isDraft: isDraft,
            taskDataJson: taskDataJson,
            goodPoints: goodPoints,
            improvementPoints: improvementPoints,
            futurePlans: futurePlans,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime startedAt,
            required DateTime endedAt,
            required int totalMinutes,
            required int concentrationLevel,
            Value<int?> goalId = const Value.absent(),
            Value<String?> goalName = const Value.absent(),
            required int evaluationMode,
            required double totalScore,
            Value<bool> isDraft = const Value.absent(),
            Value<String?> taskDataJson = const Value.absent(),
            Value<String?> goodPoints = const Value.absent(),
            Value<String?> improvementPoints = const Value.absent(),
            Value<String?> futurePlans = const Value.absent(),
          }) =>
              ScoresTableCompanion.insert(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            totalMinutes: totalMinutes,
            concentrationLevel: concentrationLevel,
            goalId: goalId,
            goalName: goalName,
            evaluationMode: evaluationMode,
            totalScore: totalScore,
            isDraft: isDraft,
            taskDataJson: taskDataJson,
            goodPoints: goodPoints,
            improvementPoints: improvementPoints,
            futurePlans: futurePlans,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScoresTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScoresTableTable,
    ScoresTableData,
    $$ScoresTableTableFilterComposer,
    $$ScoresTableTableOrderingComposer,
    $$ScoresTableTableAnnotationComposer,
    $$ScoresTableTableCreateCompanionBuilder,
    $$ScoresTableTableUpdateCompanionBuilder,
    (
      ScoresTableData,
      BaseReferences<_$AppDatabase, $ScoresTableTable, ScoresTableData>
    ),
    ScoresTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalSettingsTableTableTableManager get goalSettingsTable =>
      $$GoalSettingsTableTableTableManager(_db, _db.goalSettingsTable);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$ScoresTableTableTableManager get scoresTable =>
      $$ScoresTableTableTableManager(_db, _db.scoresTable);
}
