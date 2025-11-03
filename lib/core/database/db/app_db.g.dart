// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $QuizzesTable extends Quizzes with TableInfo<$QuizzesTable, Quizze> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizzesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _optionTypeMeta = const VerificationMeta(
    'optionType',
  );
  @override
  late final GeneratedColumn<int> optionType = GeneratedColumn<int>(
    'option_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _passRateMeta = const VerificationMeta(
    'passRate',
  );
  @override
  late final GeneratedColumn<int> passRate = GeneratedColumn<int>(
    'pass_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _enableScoresMeta = const VerificationMeta(
    'enableScores',
  );
  @override
  late final GeneratedColumn<bool> enableScores = GeneratedColumn<bool>(
    'enable_scores',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_scores" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    optionType,
    passRate,
    enableScores,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quizzes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Quizze> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('option_type')) {
      context.handle(
        _optionTypeMeta,
        optionType.isAcceptableOrUnknown(data['option_type']!, _optionTypeMeta),
      );
    }
    if (data.containsKey('pass_rate')) {
      context.handle(
        _passRateMeta,
        passRate.isAcceptableOrUnknown(data['pass_rate']!, _passRateMeta),
      );
    }
    if (data.containsKey('enable_scores')) {
      context.handle(
        _enableScoresMeta,
        enableScores.isAcceptableOrUnknown(
          data['enable_scores']!,
          _enableScoresMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quizze map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quizze(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      optionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}option_type'],
      )!,
      passRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_rate'],
      )!,
      enableScores: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_scores'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuizzesTable createAlias(String alias) {
    return $QuizzesTable(attachedDatabase, alias);
  }
}

class Quizze extends DataClass implements Insertable<Quizze> {
  final String id;
  final String title;
  final String description;
  final int optionType;
  final int passRate;
  final bool enableScores;
  final int createdAt;
  final int updatedAt;
  const Quizze({
    required this.id,
    required this.title,
    required this.description,
    required this.optionType,
    required this.passRate,
    required this.enableScores,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['option_type'] = Variable<int>(optionType);
    map['pass_rate'] = Variable<int>(passRate);
    map['enable_scores'] = Variable<bool>(enableScores);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  QuizzesCompanion toCompanion(bool nullToAbsent) {
    return QuizzesCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      optionType: Value(optionType),
      passRate: Value(passRate),
      enableScores: Value(enableScores),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Quizze.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quizze(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      optionType: serializer.fromJson<int>(json['optionType']),
      passRate: serializer.fromJson<int>(json['passRate']),
      enableScores: serializer.fromJson<bool>(json['enableScores']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'optionType': serializer.toJson<int>(optionType),
      'passRate': serializer.toJson<int>(passRate),
      'enableScores': serializer.toJson<bool>(enableScores),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Quizze copyWith({
    String? id,
    String? title,
    String? description,
    int? optionType,
    int? passRate,
    bool? enableScores,
    int? createdAt,
    int? updatedAt,
  }) => Quizze(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    optionType: optionType ?? this.optionType,
    passRate: passRate ?? this.passRate,
    enableScores: enableScores ?? this.enableScores,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Quizze copyWithCompanion(QuizzesCompanion data) {
    return Quizze(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      optionType: data.optionType.present
          ? data.optionType.value
          : this.optionType,
      passRate: data.passRate.present ? data.passRate.value : this.passRate,
      enableScores: data.enableScores.present
          ? data.enableScores.value
          : this.enableScores,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quizze(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('optionType: $optionType, ')
          ..write('passRate: $passRate, ')
          ..write('enableScores: $enableScores, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    optionType,
    passRate,
    enableScores,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quizze &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.optionType == this.optionType &&
          other.passRate == this.passRate &&
          other.enableScores == this.enableScores &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuizzesCompanion extends UpdateCompanion<Quizze> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> optionType;
  final Value<int> passRate;
  final Value<bool> enableScores;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const QuizzesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.optionType = const Value.absent(),
    this.passRate = const Value.absent(),
    this.enableScores = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizzesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.optionType = const Value.absent(),
    this.passRate = const Value.absent(),
    this.enableScores = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Quizze> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? optionType,
    Expression<int>? passRate,
    Expression<bool>? enableScores,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (optionType != null) 'option_type': optionType,
      if (passRate != null) 'pass_rate': passRate,
      if (enableScores != null) 'enable_scores': enableScores,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizzesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? optionType,
    Value<int>? passRate,
    Value<bool>? enableScores,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuizzesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      optionType: optionType ?? this.optionType,
      passRate: passRate ?? this.passRate,
      enableScores: enableScores ?? this.enableScores,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (optionType.present) {
      map['option_type'] = Variable<int>(optionType.value);
    }
    if (passRate.present) {
      map['pass_rate'] = Variable<int>(passRate.value);
    }
    if (enableScores.present) {
      map['enable_scores'] = Variable<bool>(enableScores.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizzesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('optionType: $optionType, ')
          ..write('passRate: $passRate, ')
          ..write('enableScores: $enableScores, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  @override
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
    'quiz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quizzes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionTypeMeta = const VerificationMeta(
    'questionType',
  );
  @override
  late final GeneratedColumn<int> questionType = GeneratedColumn<int>(
    'question_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _numberOfOptionsMeta = const VerificationMeta(
    'numberOfOptions',
  );
  @override
  late final GeneratedColumn<int> numberOfOptions = GeneratedColumn<int>(
    'number_of_options',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswerIdsMeta = const VerificationMeta(
    'correctAnswerIds',
  );
  @override
  late final GeneratedColumn<String> correctAnswerIds = GeneratedColumn<String>(
    'correct_answer_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quizId,
    questionType,
    numberOfOptions,
    content,
    correctAnswerIds,
    score,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Question> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(
        _quizIdMeta,
        quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
        _questionTypeMeta,
        questionType.isAcceptableOrUnknown(
          data['question_type']!,
          _questionTypeMeta,
        ),
      );
    }
    if (data.containsKey('number_of_options')) {
      context.handle(
        _numberOfOptionsMeta,
        numberOfOptions.isAcceptableOrUnknown(
          data['number_of_options']!,
          _numberOfOptionsMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('correct_answer_ids')) {
      context.handle(
        _correctAnswerIdsMeta,
        correctAnswerIds.isAcceptableOrUnknown(
          data['correct_answer_ids']!,
          _correctAnswerIdsMeta,
        ),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quizId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiz_id'],
      )!,
      questionType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_type'],
      )!,
      numberOfOptions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_options'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      correctAnswerIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer_ids'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final String id;
  final String quizId;
  final int questionType;
  final int numberOfOptions;
  final String content;
  final String correctAnswerIds;
  final int score;
  final int orderIndex;
  const Question({
    required this.id,
    required this.quizId,
    required this.questionType,
    required this.numberOfOptions,
    required this.content,
    required this.correctAnswerIds,
    required this.score,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    map['question_type'] = Variable<int>(questionType);
    map['number_of_options'] = Variable<int>(numberOfOptions);
    map['content'] = Variable<String>(content);
    map['correct_answer_ids'] = Variable<String>(correctAnswerIds);
    map['score'] = Variable<int>(score);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      questionType: Value(questionType),
      numberOfOptions: Value(numberOfOptions),
      content: Value(content),
      correctAnswerIds: Value(correctAnswerIds),
      score: Value(score),
      orderIndex: Value(orderIndex),
    );
  }

  factory Question.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quizId']),
      questionType: serializer.fromJson<int>(json['questionType']),
      numberOfOptions: serializer.fromJson<int>(json['numberOfOptions']),
      content: serializer.fromJson<String>(json['content']),
      correctAnswerIds: serializer.fromJson<String>(json['correctAnswerIds']),
      score: serializer.fromJson<int>(json['score']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quizId': serializer.toJson<String>(quizId),
      'questionType': serializer.toJson<int>(questionType),
      'numberOfOptions': serializer.toJson<int>(numberOfOptions),
      'content': serializer.toJson<String>(content),
      'correctAnswerIds': serializer.toJson<String>(correctAnswerIds),
      'score': serializer.toJson<int>(score),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Question copyWith({
    String? id,
    String? quizId,
    int? questionType,
    int? numberOfOptions,
    String? content,
    String? correctAnswerIds,
    int? score,
    int? orderIndex,
  }) => Question(
    id: id ?? this.id,
    quizId: quizId ?? this.quizId,
    questionType: questionType ?? this.questionType,
    numberOfOptions: numberOfOptions ?? this.numberOfOptions,
    content: content ?? this.content,
    correctAnswerIds: correctAnswerIds ?? this.correctAnswerIds,
    score: score ?? this.score,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      numberOfOptions: data.numberOfOptions.present
          ? data.numberOfOptions.value
          : this.numberOfOptions,
      content: data.content.present ? data.content.value : this.content,
      correctAnswerIds: data.correctAnswerIds.present
          ? data.correctAnswerIds.value
          : this.correctAnswerIds,
      score: data.score.present ? data.score.value : this.score,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('questionType: $questionType, ')
          ..write('numberOfOptions: $numberOfOptions, ')
          ..write('content: $content, ')
          ..write('correctAnswerIds: $correctAnswerIds, ')
          ..write('score: $score, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quizId,
    questionType,
    numberOfOptions,
    content,
    correctAnswerIds,
    score,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.questionType == this.questionType &&
          other.numberOfOptions == this.numberOfOptions &&
          other.content == this.content &&
          other.correctAnswerIds == this.correctAnswerIds &&
          other.score == this.score &&
          other.orderIndex == this.orderIndex);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<int> questionType;
  final Value<int> numberOfOptions;
  final Value<String> content;
  final Value<String> correctAnswerIds;
  final Value<int> score;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.questionType = const Value.absent(),
    this.numberOfOptions = const Value.absent(),
    this.content = const Value.absent(),
    this.correctAnswerIds = const Value.absent(),
    this.score = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String id,
    required String quizId,
    this.questionType = const Value.absent(),
    this.numberOfOptions = const Value.absent(),
    required String content,
    this.correctAnswerIds = const Value.absent(),
    this.score = const Value.absent(),
    required int orderIndex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quizId = Value(quizId),
       content = Value(content),
       orderIndex = Value(orderIndex);
  static Insertable<Question> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<int>? questionType,
    Expression<int>? numberOfOptions,
    Expression<String>? content,
    Expression<String>? correctAnswerIds,
    Expression<int>? score,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (questionType != null) 'question_type': questionType,
      if (numberOfOptions != null) 'number_of_options': numberOfOptions,
      if (content != null) 'content': content,
      if (correctAnswerIds != null) 'correct_answer_ids': correctAnswerIds,
      if (score != null) 'score': score,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? quizId,
    Value<int>? questionType,
    Value<int>? numberOfOptions,
    Value<String>? content,
    Value<String>? correctAnswerIds,
    Value<int>? score,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionType: questionType ?? this.questionType,
      numberOfOptions: numberOfOptions ?? this.numberOfOptions,
      content: content ?? this.content,
      correctAnswerIds: correctAnswerIds ?? this.correctAnswerIds,
      score: score ?? this.score,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<int>(questionType.value);
    }
    if (numberOfOptions.present) {
      map['number_of_options'] = Variable<int>(numberOfOptions.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (correctAnswerIds.present) {
      map['correct_answer_ids'] = Variable<String>(correctAnswerIds.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('questionType: $questionType, ')
          ..write('numberOfOptions: $numberOfOptions, ')
          ..write('content: $content, ')
          ..write('correctAnswerIds: $correctAnswerIds, ')
          ..write('score: $score, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizOptionsTable extends QuizOptions
    with TableInfo<$QuizOptionsTable, QuizOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, questionId, textValue, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    } else if (isInserting) {
      context.missing(_textValueMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $QuizOptionsTable createAlias(String alias) {
    return $QuizOptionsTable(attachedDatabase, alias);
  }
}

class QuizOption extends DataClass implements Insertable<QuizOption> {
  final String id;
  final String questionId;
  final String textValue;
  final int orderIndex;
  const QuizOption({
    required this.id,
    required this.questionId,
    required this.textValue,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['text_value'] = Variable<String>(textValue);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  QuizOptionsCompanion toCompanion(bool nullToAbsent) {
    return QuizOptionsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      textValue: Value(textValue),
      orderIndex: Value(orderIndex),
    );
  }

  factory QuizOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizOption(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      textValue: serializer.fromJson<String>(json['textValue']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'textValue': serializer.toJson<String>(textValue),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  QuizOption copyWith({
    String? id,
    String? questionId,
    String? textValue,
    int? orderIndex,
  }) => QuizOption(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    textValue: textValue ?? this.textValue,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  QuizOption copyWithCompanion(QuizOptionsCompanion data) {
    return QuizOption(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizOption(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('textValue: $textValue, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, textValue, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizOption &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.textValue == this.textValue &&
          other.orderIndex == this.orderIndex);
}

class QuizOptionsCompanion extends UpdateCompanion<QuizOption> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<String> textValue;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const QuizOptionsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.textValue = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizOptionsCompanion.insert({
    required String id,
    required String questionId,
    required String textValue,
    required int orderIndex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questionId = Value(questionId),
       textValue = Value(textValue),
       orderIndex = Value(orderIndex);
  static Insertable<QuizOption> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<String>? textValue,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (textValue != null) 'text_value': textValue,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? questionId,
    Value<String>? textValue,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return QuizOptionsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      textValue: textValue ?? this.textValue,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizOptionsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('textValue: $textValue, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeRunsTable extends PracticeRuns
    with TableInfo<$PracticeRunsTable, PracticeRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  @override
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
    'quiz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, quizId, startedAt, endedAt, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(
        _quizIdMeta,
        quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quizId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiz_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
    );
  }

  @override
  $PracticeRunsTable createAlias(String alias) {
    return $PracticeRunsTable(attachedDatabase, alias);
  }
}

class PracticeRun extends DataClass implements Insertable<PracticeRun> {
  final String id;
  final String quizId;
  final int startedAt;
  final int? endedAt;
  final int score;
  const PracticeRun({
    required this.id,
    required this.quizId,
    required this.startedAt,
    this.endedAt,
    required this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['score'] = Variable<int>(score);
    return map;
  }

  PracticeRunsCompanion toCompanion(bool nullToAbsent) {
    return PracticeRunsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      score: Value(score),
    );
  }

  factory PracticeRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeRun(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quizId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      score: serializer.fromJson<int>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quizId': serializer.toJson<String>(quizId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'score': serializer.toJson<int>(score),
    };
  }

  PracticeRun copyWith({
    String? id,
    String? quizId,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    int? score,
  }) => PracticeRun(
    id: id ?? this.id,
    quizId: quizId ?? this.quizId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    score: score ?? this.score,
  );
  PracticeRun copyWithCompanion(PracticeRunsCompanion data) {
    return PracticeRun(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeRun(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, quizId, startedAt, endedAt, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeRun &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.score == this.score);
}

class PracticeRunsCompanion extends UpdateCompanion<PracticeRun> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> score;
  final Value<int> rowid;
  const PracticeRunsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeRunsCompanion.insert({
    required String id,
    required String quizId,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quizId = Value(quizId),
       startedAt = Value(startedAt);
  static Insertable<PracticeRun> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? score,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (score != null) 'score': score,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? quizId,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<int>? score,
    Value<int>? rowid,
  }) {
    return PracticeRunsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      score: score ?? this.score,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeRunsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeAnswersTable extends PracticeAnswers
    with TableInfo<$PracticeAnswersTable, PracticeAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chosenOptionsMeta = const VerificationMeta(
    'chosenOptions',
  );
  @override
  late final GeneratedColumn<String> chosenOptions = GeneratedColumn<String>(
    'chosen_options',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    questionId,
    chosenOptions,
    isCorrect,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('chosen_options')) {
      context.handle(
        _chosenOptionsMeta,
        chosenOptions.isAcceptableOrUnknown(
          data['chosen_options']!,
          _chosenOptionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chosenOptionsMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      chosenOptions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chosen_options'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $PracticeAnswersTable createAlias(String alias) {
    return $PracticeAnswersTable(attachedDatabase, alias);
  }
}

class PracticeAnswer extends DataClass implements Insertable<PracticeAnswer> {
  final String id;
  final String runId;
  final String questionId;
  final String chosenOptions;
  final bool isCorrect;
  final int answeredAt;
  const PracticeAnswer({
    required this.id,
    required this.runId,
    required this.questionId,
    required this.chosenOptions,
    required this.isCorrect,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['run_id'] = Variable<String>(runId);
    map['question_id'] = Variable<String>(questionId);
    map['chosen_options'] = Variable<String>(chosenOptions);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['answered_at'] = Variable<int>(answeredAt);
    return map;
  }

  PracticeAnswersCompanion toCompanion(bool nullToAbsent) {
    return PracticeAnswersCompanion(
      id: Value(id),
      runId: Value(runId),
      questionId: Value(questionId),
      chosenOptions: Value(chosenOptions),
      isCorrect: Value(isCorrect),
      answeredAt: Value(answeredAt),
    );
  }

  factory PracticeAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeAnswer(
      id: serializer.fromJson<String>(json['id']),
      runId: serializer.fromJson<String>(json['runId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      chosenOptions: serializer.fromJson<String>(json['chosenOptions']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      answeredAt: serializer.fromJson<int>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'runId': serializer.toJson<String>(runId),
      'questionId': serializer.toJson<String>(questionId),
      'chosenOptions': serializer.toJson<String>(chosenOptions),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'answeredAt': serializer.toJson<int>(answeredAt),
    };
  }

  PracticeAnswer copyWith({
    String? id,
    String? runId,
    String? questionId,
    String? chosenOptions,
    bool? isCorrect,
    int? answeredAt,
  }) => PracticeAnswer(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    questionId: questionId ?? this.questionId,
    chosenOptions: chosenOptions ?? this.chosenOptions,
    isCorrect: isCorrect ?? this.isCorrect,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  PracticeAnswer copyWithCompanion(PracticeAnswersCompanion data) {
    return PracticeAnswer(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      chosenOptions: data.chosenOptions.present
          ? data.chosenOptions.value
          : this.chosenOptions,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswer(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('questionId: $questionId, ')
          ..write('chosenOptions: $chosenOptions, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, runId, questionId, chosenOptions, isCorrect, answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeAnswer &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.questionId == this.questionId &&
          other.chosenOptions == this.chosenOptions &&
          other.isCorrect == this.isCorrect &&
          other.answeredAt == this.answeredAt);
}

class PracticeAnswersCompanion extends UpdateCompanion<PracticeAnswer> {
  final Value<String> id;
  final Value<String> runId;
  final Value<String> questionId;
  final Value<String> chosenOptions;
  final Value<bool> isCorrect;
  final Value<int> answeredAt;
  final Value<int> rowid;
  const PracticeAnswersCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.chosenOptions = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeAnswersCompanion.insert({
    required String id,
    required String runId,
    required String questionId,
    required String chosenOptions,
    this.isCorrect = const Value.absent(),
    required int answeredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       runId = Value(runId),
       questionId = Value(questionId),
       chosenOptions = Value(chosenOptions),
       answeredAt = Value(answeredAt);
  static Insertable<PracticeAnswer> custom({
    Expression<String>? id,
    Expression<String>? runId,
    Expression<String>? questionId,
    Expression<String>? chosenOptions,
    Expression<bool>? isCorrect,
    Expression<int>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (questionId != null) 'question_id': questionId,
      if (chosenOptions != null) 'chosen_options': chosenOptions,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeAnswersCompanion copyWith({
    Value<String>? id,
    Value<String>? runId,
    Value<String>? questionId,
    Value<String>? chosenOptions,
    Value<bool>? isCorrect,
    Value<int>? answeredAt,
    Value<int>? rowid,
  }) {
    return PracticeAnswersCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      questionId: questionId ?? this.questionId,
      chosenOptions: chosenOptions ?? this.chosenOptions,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (chosenOptions.present) {
      map['chosen_options'] = Variable<String>(chosenOptions.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeAnswersCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('questionId: $questionId, ')
          ..write('chosenOptions: $chosenOptions, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $QuizzesTable quizzes = $QuizzesTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $QuizOptionsTable quizOptions = $QuizOptionsTable(this);
  late final $PracticeRunsTable practiceRuns = $PracticeRunsTable(this);
  late final $PracticeAnswersTable practiceAnswers = $PracticeAnswersTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    quizzes,
    questions,
    quizOptions,
    practiceRuns,
    practiceAnswers,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quizzes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('questions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_options', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$QuizzesTableCreateCompanionBuilder =
    QuizzesCompanion Function({
      required String id,
      required String title,
      Value<String> description,
      Value<int> optionType,
      Value<int> passRate,
      Value<bool> enableScores,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$QuizzesTableUpdateCompanionBuilder =
    QuizzesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<int> optionType,
      Value<int> passRate,
      Value<bool> enableScores,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$QuizzesTableReferences
    extends BaseReferences<_$AppDb, $QuizzesTable, Quizze> {
  $$QuizzesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestionsTable, List<Question>>
  _questionsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.questions,
    aliasName: $_aliasNameGenerator(db.quizzes.id, db.questions.quizId),
  );

  $$QuestionsTableProcessedTableManager get questionsRefs {
    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.quizId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_questionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuizzesTableFilterComposer extends Composer<_$AppDb, $QuizzesTable> {
  $$QuizzesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get optionType => $composableBuilder(
    column: $table.optionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passRate => $composableBuilder(
    column: $table.passRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableScores => $composableBuilder(
    column: $table.enableScores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questionsRefs(
    Expression<bool> Function($$QuestionsTableFilterComposer f) f,
  ) {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.quizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuizzesTableOrderingComposer extends Composer<_$AppDb, $QuizzesTable> {
  $$QuizzesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get optionType => $composableBuilder(
    column: $table.optionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passRate => $composableBuilder(
    column: $table.passRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableScores => $composableBuilder(
    column: $table.enableScores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizzesTableAnnotationComposer
    extends Composer<_$AppDb, $QuizzesTable> {
  $$QuizzesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get optionType => $composableBuilder(
    column: $table.optionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passRate =>
      $composableBuilder(column: $table.passRate, builder: (column) => column);

  GeneratedColumn<bool> get enableScores => $composableBuilder(
    column: $table.enableScores,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> questionsRefs<T extends Object>(
    Expression<T> Function($$QuestionsTableAnnotationComposer a) f,
  ) {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.quizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuizzesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $QuizzesTable,
          Quizze,
          $$QuizzesTableFilterComposer,
          $$QuizzesTableOrderingComposer,
          $$QuizzesTableAnnotationComposer,
          $$QuizzesTableCreateCompanionBuilder,
          $$QuizzesTableUpdateCompanionBuilder,
          (Quizze, $$QuizzesTableReferences),
          Quizze,
          PrefetchHooks Function({bool questionsRefs})
        > {
  $$QuizzesTableTableManager(_$AppDb db, $QuizzesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizzesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizzesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizzesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> optionType = const Value.absent(),
                Value<int> passRate = const Value.absent(),
                Value<bool> enableScores = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizzesCompanion(
                id: id,
                title: title,
                description: description,
                optionType: optionType,
                passRate: passRate,
                enableScores: enableScores,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<int> optionType = const Value.absent(),
                Value<int> passRate = const Value.absent(),
                Value<bool> enableScores = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuizzesCompanion.insert(
                id: id,
                title: title,
                description: description,
                optionType: optionType,
                passRate: passRate,
                enableScores: enableScores,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuizzesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (questionsRefs) db.questions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionsRefs)
                    await $_getPrefetchedData<Quizze, $QuizzesTable, Question>(
                      currentTable: table,
                      referencedTable: $$QuizzesTableReferences
                          ._questionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$QuizzesTableReferences(db, table, p0).questionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.quizId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$QuizzesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $QuizzesTable,
      Quizze,
      $$QuizzesTableFilterComposer,
      $$QuizzesTableOrderingComposer,
      $$QuizzesTableAnnotationComposer,
      $$QuizzesTableCreateCompanionBuilder,
      $$QuizzesTableUpdateCompanionBuilder,
      (Quizze, $$QuizzesTableReferences),
      Quizze,
      PrefetchHooks Function({bool questionsRefs})
    >;
typedef $$QuestionsTableCreateCompanionBuilder =
    QuestionsCompanion Function({
      required String id,
      required String quizId,
      Value<int> questionType,
      Value<int> numberOfOptions,
      required String content,
      Value<String> correctAnswerIds,
      Value<int> score,
      required int orderIndex,
      Value<int> rowid,
    });
typedef $$QuestionsTableUpdateCompanionBuilder =
    QuestionsCompanion Function({
      Value<String> id,
      Value<String> quizId,
      Value<int> questionType,
      Value<int> numberOfOptions,
      Value<String> content,
      Value<String> correctAnswerIds,
      Value<int> score,
      Value<int> orderIndex,
      Value<int> rowid,
    });

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDb, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuizzesTable _quizIdTable(_$AppDb db) => db.quizzes.createAlias(
    $_aliasNameGenerator(db.questions.quizId, db.quizzes.id),
  );

  $$QuizzesTableProcessedTableManager get quizId {
    final $_column = $_itemColumn<String>('quiz_id')!;

    final manager = $$QuizzesTableTableManager(
      $_db,
      $_db.quizzes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quizIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QuizOptionsTable, List<QuizOption>>
  _quizOptionsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.quizOptions,
    aliasName: $_aliasNameGenerator(db.questions.id, db.quizOptions.questionId),
  );

  $$QuizOptionsTableProcessedTableManager get quizOptionsRefs {
    final manager = $$QuizOptionsTableTableManager(
      $_db,
      $_db.quizOptions,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quizOptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDb, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfOptions => $composableBuilder(
    column: $table.numberOfOptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswerIds => $composableBuilder(
    column: $table.correctAnswerIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$QuizzesTableFilterComposer get quizId {
    final $$QuizzesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizzesTableFilterComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> quizOptionsRefs(
    Expression<bool> Function($$QuizOptionsTableFilterComposer f) f,
  ) {
    final $$QuizOptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizOptions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizOptionsTableFilterComposer(
            $db: $db,
            $table: $db.quizOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDb, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfOptions => $composableBuilder(
    column: $table.numberOfOptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswerIds => $composableBuilder(
    column: $table.correctAnswerIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuizzesTableOrderingComposer get quizId {
    final $$QuizzesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizzesTableOrderingComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDb, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionType => $composableBuilder(
    column: $table.questionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numberOfOptions => $composableBuilder(
    column: $table.numberOfOptions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get correctAnswerIds => $composableBuilder(
    column: $table.correctAnswerIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$QuizzesTableAnnotationComposer get quizId {
    final $$QuizzesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizzesTableAnnotationComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> quizOptionsRefs<T extends Object>(
    Expression<T> Function($$QuizOptionsTableAnnotationComposer a) f,
  ) {
    final $$QuizOptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizOptions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuizOptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.quizOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $QuestionsTable,
          Question,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (Question, $$QuestionsTableReferences),
          Question,
          PrefetchHooks Function({bool quizId, bool quizOptionsRefs})
        > {
  $$QuestionsTableTableManager(_$AppDb db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> quizId = const Value.absent(),
                Value<int> questionType = const Value.absent(),
                Value<int> numberOfOptions = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> correctAnswerIds = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                quizId: quizId,
                questionType: questionType,
                numberOfOptions: numberOfOptions,
                content: content,
                correctAnswerIds: correctAnswerIds,
                score: score,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String quizId,
                Value<int> questionType = const Value.absent(),
                Value<int> numberOfOptions = const Value.absent(),
                required String content,
                Value<String> correctAnswerIds = const Value.absent(),
                Value<int> score = const Value.absent(),
                required int orderIndex,
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion.insert(
                id: id,
                quizId: quizId,
                questionType: questionType,
                numberOfOptions: numberOfOptions,
                content: content,
                correctAnswerIds: correctAnswerIds,
                score: score,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({quizId = false, quizOptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (quizOptionsRefs) db.quizOptions],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (quizId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.quizId,
                                referencedTable: $$QuestionsTableReferences
                                    ._quizIdTable(db),
                                referencedColumn: $$QuestionsTableReferences
                                    ._quizIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quizOptionsRefs)
                    await $_getPrefetchedData<
                      Question,
                      $QuestionsTable,
                      QuizOption
                    >(
                      currentTable: table,
                      referencedTable: $$QuestionsTableReferences
                          ._quizOptionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$QuestionsTableReferences(
                            db,
                            table,
                            p0,
                          ).quizOptionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.questionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $QuestionsTable,
      Question,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (Question, $$QuestionsTableReferences),
      Question,
      PrefetchHooks Function({bool quizId, bool quizOptionsRefs})
    >;
typedef $$QuizOptionsTableCreateCompanionBuilder =
    QuizOptionsCompanion Function({
      required String id,
      required String questionId,
      required String textValue,
      required int orderIndex,
      Value<int> rowid,
    });
typedef $$QuizOptionsTableUpdateCompanionBuilder =
    QuizOptionsCompanion Function({
      Value<String> id,
      Value<String> questionId,
      Value<String> textValue,
      Value<int> orderIndex,
      Value<int> rowid,
    });

final class $$QuizOptionsTableReferences
    extends BaseReferences<_$AppDb, $QuizOptionsTable, QuizOption> {
  $$QuizOptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDb db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.quizOptions.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<String>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuizOptionsTableFilterComposer
    extends Composer<_$AppDb, $QuizOptionsTable> {
  $$QuizOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizOptionsTableOrderingComposer
    extends Composer<_$AppDb, $QuizOptionsTable> {
  $$QuizOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizOptionsTableAnnotationComposer
    extends Composer<_$AppDb, $QuizOptionsTable> {
  $$QuizOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuizOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $QuizOptionsTable,
          QuizOption,
          $$QuizOptionsTableFilterComposer,
          $$QuizOptionsTableOrderingComposer,
          $$QuizOptionsTableAnnotationComposer,
          $$QuizOptionsTableCreateCompanionBuilder,
          $$QuizOptionsTableUpdateCompanionBuilder,
          (QuizOption, $$QuizOptionsTableReferences),
          QuizOption,
          PrefetchHooks Function({bool questionId})
        > {
  $$QuizOptionsTableTableManager(_$AppDb db, $QuizOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> textValue = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizOptionsCompanion(
                id: id,
                questionId: questionId,
                textValue: textValue,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questionId,
                required String textValue,
                required int orderIndex,
                Value<int> rowid = const Value.absent(),
              }) => QuizOptionsCompanion.insert(
                id: id,
                questionId: questionId,
                textValue: textValue,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuizOptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$QuizOptionsTableReferences
                                    ._questionIdTable(db),
                                referencedColumn: $$QuizOptionsTableReferences
                                    ._questionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuizOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $QuizOptionsTable,
      QuizOption,
      $$QuizOptionsTableFilterComposer,
      $$QuizOptionsTableOrderingComposer,
      $$QuizOptionsTableAnnotationComposer,
      $$QuizOptionsTableCreateCompanionBuilder,
      $$QuizOptionsTableUpdateCompanionBuilder,
      (QuizOption, $$QuizOptionsTableReferences),
      QuizOption,
      PrefetchHooks Function({bool questionId})
    >;
typedef $$PracticeRunsTableCreateCompanionBuilder =
    PracticeRunsCompanion Function({
      required String id,
      required String quizId,
      required int startedAt,
      Value<int?> endedAt,
      Value<int> score,
      Value<int> rowid,
    });
typedef $$PracticeRunsTableUpdateCompanionBuilder =
    PracticeRunsCompanion Function({
      Value<String> id,
      Value<String> quizId,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<int> score,
      Value<int> rowid,
    });

class $$PracticeRunsTableFilterComposer
    extends Composer<_$AppDb, $PracticeRunsTable> {
  $$PracticeRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quizId => $composableBuilder(
    column: $table.quizId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PracticeRunsTableOrderingComposer
    extends Composer<_$AppDb, $PracticeRunsTable> {
  $$PracticeRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quizId => $composableBuilder(
    column: $table.quizId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeRunsTableAnnotationComposer
    extends Composer<_$AppDb, $PracticeRunsTable> {
  $$PracticeRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quizId =>
      $composableBuilder(column: $table.quizId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);
}

class $$PracticeRunsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $PracticeRunsTable,
          PracticeRun,
          $$PracticeRunsTableFilterComposer,
          $$PracticeRunsTableOrderingComposer,
          $$PracticeRunsTableAnnotationComposer,
          $$PracticeRunsTableCreateCompanionBuilder,
          $$PracticeRunsTableUpdateCompanionBuilder,
          (
            PracticeRun,
            BaseReferences<_$AppDb, $PracticeRunsTable, PracticeRun>,
          ),
          PracticeRun,
          PrefetchHooks Function()
        > {
  $$PracticeRunsTableTableManager(_$AppDb db, $PracticeRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> quizId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeRunsCompanion(
                id: id,
                quizId: quizId,
                startedAt: startedAt,
                endedAt: endedAt,
                score: score,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String quizId,
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeRunsCompanion.insert(
                id: id,
                quizId: quizId,
                startedAt: startedAt,
                endedAt: endedAt,
                score: score,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $PracticeRunsTable,
      PracticeRun,
      $$PracticeRunsTableFilterComposer,
      $$PracticeRunsTableOrderingComposer,
      $$PracticeRunsTableAnnotationComposer,
      $$PracticeRunsTableCreateCompanionBuilder,
      $$PracticeRunsTableUpdateCompanionBuilder,
      (PracticeRun, BaseReferences<_$AppDb, $PracticeRunsTable, PracticeRun>),
      PracticeRun,
      PrefetchHooks Function()
    >;
typedef $$PracticeAnswersTableCreateCompanionBuilder =
    PracticeAnswersCompanion Function({
      required String id,
      required String runId,
      required String questionId,
      required String chosenOptions,
      Value<bool> isCorrect,
      required int answeredAt,
      Value<int> rowid,
    });
typedef $$PracticeAnswersTableUpdateCompanionBuilder =
    PracticeAnswersCompanion Function({
      Value<String> id,
      Value<String> runId,
      Value<String> questionId,
      Value<String> chosenOptions,
      Value<bool> isCorrect,
      Value<int> answeredAt,
      Value<int> rowid,
    });

class $$PracticeAnswersTableFilterComposer
    extends Composer<_$AppDb, $PracticeAnswersTable> {
  $$PracticeAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chosenOptions => $composableBuilder(
    column: $table.chosenOptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PracticeAnswersTableOrderingComposer
    extends Composer<_$AppDb, $PracticeAnswersTable> {
  $$PracticeAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chosenOptions => $composableBuilder(
    column: $table.chosenOptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeAnswersTableAnnotationComposer
    extends Composer<_$AppDb, $PracticeAnswersTable> {
  $$PracticeAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chosenOptions => $composableBuilder(
    column: $table.chosenOptions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$PracticeAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $PracticeAnswersTable,
          PracticeAnswer,
          $$PracticeAnswersTableFilterComposer,
          $$PracticeAnswersTableOrderingComposer,
          $$PracticeAnswersTableAnnotationComposer,
          $$PracticeAnswersTableCreateCompanionBuilder,
          $$PracticeAnswersTableUpdateCompanionBuilder,
          (
            PracticeAnswer,
            BaseReferences<_$AppDb, $PracticeAnswersTable, PracticeAnswer>,
          ),
          PracticeAnswer,
          PrefetchHooks Function()
        > {
  $$PracticeAnswersTableTableManager(_$AppDb db, $PracticeAnswersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> runId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> chosenOptions = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeAnswersCompanion(
                id: id,
                runId: runId,
                questionId: questionId,
                chosenOptions: chosenOptions,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String runId,
                required String questionId,
                required String chosenOptions,
                Value<bool> isCorrect = const Value.absent(),
                required int answeredAt,
                Value<int> rowid = const Value.absent(),
              }) => PracticeAnswersCompanion.insert(
                id: id,
                runId: runId,
                questionId: questionId,
                chosenOptions: chosenOptions,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $PracticeAnswersTable,
      PracticeAnswer,
      $$PracticeAnswersTableFilterComposer,
      $$PracticeAnswersTableOrderingComposer,
      $$PracticeAnswersTableAnnotationComposer,
      $$PracticeAnswersTableCreateCompanionBuilder,
      $$PracticeAnswersTableUpdateCompanionBuilder,
      (
        PracticeAnswer,
        BaseReferences<_$AppDb, $PracticeAnswersTable, PracticeAnswer>,
      ),
      PracticeAnswer,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$QuizzesTableTableManager get quizzes =>
      $$QuizzesTableTableManager(_db, _db.quizzes);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$QuizOptionsTableTableManager get quizOptions =>
      $$QuizOptionsTableTableManager(_db, _db.quizOptions);
  $$PracticeRunsTableTableManager get practiceRuns =>
      $$PracticeRunsTableTableManager(_db, _db.practiceRuns);
  $$PracticeAnswersTableTableManager get practiceAnswers =>
      $$PracticeAnswersTableTableManager(_db, _db.practiceAnswers);
}
