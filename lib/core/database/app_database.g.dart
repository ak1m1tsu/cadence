// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, colorHex, iconCodePoint];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String colorHex;
  final int iconCodePoint;
  const Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconCodePoint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      iconCodePoint: Value(iconCodePoint),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? colorHex,
    int? iconCodePoint,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconCodePoint: $iconCodePoint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, iconCodePoint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.iconCodePoint == this.iconCodePoint);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<int> iconCodePoint;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String colorHex,
    required int iconCodePoint,
  }) : name = Value(name),
       colorHex = Value(colorHex),
       iconCodePoint = Value(iconCodePoint);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<int>? iconCodePoint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<int>? iconCodePoint,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconCodePoint: $iconCodePoint')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billingCycleMeta = const VerificationMeta(
    'billingCycle',
  );
  @override
  late final GeneratedColumn<String> billingCycle = GeneratedColumn<String>(
    'billing_cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodIntervalMeta = const VerificationMeta(
    'periodInterval',
  );
  @override
  late final GeneratedColumn<int> periodInterval = GeneratedColumn<int>(
    'period_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconTypeMeta = const VerificationMeta(
    'iconType',
  );
  @override
  late final GeneratedColumn<String> iconType = GeneratedColumn<String>(
    'icon_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('avatar'),
  );
  static const VerificationMeta _iconIdentifierMeta = const VerificationMeta(
    'iconIdentifier',
  );
  @override
  late final GeneratedColumn<String> iconIdentifier = GeneratedColumn<String>(
    'icon_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconColorHexMeta = const VerificationMeta(
    'iconColorHex',
  );
  @override
  late final GeneratedColumn<String> iconColorHex = GeneratedColumn<String>(
    'icon_color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _reminderLeadDaysMeta = const VerificationMeta(
    'reminderLeadDays',
  );
  @override
  late final GeneratedColumn<int> reminderLeadDays = GeneratedColumn<int>(
    'reminder_lead_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trialPeriodIntervalMeta =
      const VerificationMeta('trialPeriodInterval');
  @override
  late final GeneratedColumn<int> trialPeriodInterval = GeneratedColumn<int>(
    'trial_period_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trialPeriodUnitMeta = const VerificationMeta(
    'trialPeriodUnit',
  );
  @override
  late final GeneratedColumn<String> trialPeriodUnit = GeneratedColumn<String>(
    'trial_period_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    name,
    price,
    currencyCode,
    billingCycle,
    periodInterval,
    startDate,
    iconType,
    iconIdentifier,
    iconColorHex,
    notes,
    isActive,
    reminderLeadDays,
    reminderHour,
    reminderMinute,
    trialPeriodInterval,
    trialPeriodUnit,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('billing_cycle')) {
      context.handle(
        _billingCycleMeta,
        billingCycle.isAcceptableOrUnknown(
          data['billing_cycle']!,
          _billingCycleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_billingCycleMeta);
    }
    if (data.containsKey('period_interval')) {
      context.handle(
        _periodIntervalMeta,
        periodInterval.isAcceptableOrUnknown(
          data['period_interval']!,
          _periodIntervalMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('icon_type')) {
      context.handle(
        _iconTypeMeta,
        iconType.isAcceptableOrUnknown(data['icon_type']!, _iconTypeMeta),
      );
    }
    if (data.containsKey('icon_identifier')) {
      context.handle(
        _iconIdentifierMeta,
        iconIdentifier.isAcceptableOrUnknown(
          data['icon_identifier']!,
          _iconIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('icon_color_hex')) {
      context.handle(
        _iconColorHexMeta,
        iconColorHex.isAcceptableOrUnknown(
          data['icon_color_hex']!,
          _iconColorHexMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('reminder_lead_days')) {
      context.handle(
        _reminderLeadDaysMeta,
        reminderLeadDays.isAcceptableOrUnknown(
          data['reminder_lead_days']!,
          _reminderLeadDaysMeta,
        ),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('trial_period_interval')) {
      context.handle(
        _trialPeriodIntervalMeta,
        trialPeriodInterval.isAcceptableOrUnknown(
          data['trial_period_interval']!,
          _trialPeriodIntervalMeta,
        ),
      );
    }
    if (data.containsKey('trial_period_unit')) {
      context.handle(
        _trialPeriodUnitMeta,
        trialPeriodUnit.isAcceptableOrUnknown(
          data['trial_period_unit']!,
          _trialPeriodUnitMeta,
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
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      billingCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_cycle'],
      )!,
      periodInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_interval'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      )!,
      iconType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_type'],
      )!,
      iconIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_identifier'],
      )!,
      iconColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_color_hex'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      reminderLeadDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_lead_days'],
      ),
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      ),
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      ),
      trialPeriodInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trial_period_interval'],
      ),
      trialPeriodUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trial_period_unit'],
      ),
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
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String name;
  final double price;
  final String currencyCode;
  final String billingCycle;
  final int periodInterval;
  final int startDate;
  final String iconType;
  final String iconIdentifier;
  final String? iconColorHex;
  final String? notes;
  final int isActive;
  final int? reminderLeadDays;
  final int? reminderHour;
  final int? reminderMinute;
  final int? trialPeriodInterval;
  final String? trialPeriodUnit;
  final int createdAt;
  final int updatedAt;
  const Payment({
    required this.id,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.billingCycle,
    required this.periodInterval,
    required this.startDate,
    required this.iconType,
    required this.iconIdentifier,
    this.iconColorHex,
    this.notes,
    required this.isActive,
    this.reminderLeadDays,
    this.reminderHour,
    this.reminderMinute,
    this.trialPeriodInterval,
    this.trialPeriodUnit,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['currency_code'] = Variable<String>(currencyCode);
    map['billing_cycle'] = Variable<String>(billingCycle);
    map['period_interval'] = Variable<int>(periodInterval);
    map['start_date'] = Variable<int>(startDate);
    map['icon_type'] = Variable<String>(iconType);
    map['icon_identifier'] = Variable<String>(iconIdentifier);
    if (!nullToAbsent || iconColorHex != null) {
      map['icon_color_hex'] = Variable<String>(iconColorHex);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<int>(isActive);
    if (!nullToAbsent || reminderLeadDays != null) {
      map['reminder_lead_days'] = Variable<int>(reminderLeadDays);
    }
    if (!nullToAbsent || reminderHour != null) {
      map['reminder_hour'] = Variable<int>(reminderHour);
    }
    if (!nullToAbsent || reminderMinute != null) {
      map['reminder_minute'] = Variable<int>(reminderMinute);
    }
    if (!nullToAbsent || trialPeriodInterval != null) {
      map['trial_period_interval'] = Variable<int>(trialPeriodInterval);
    }
    if (!nullToAbsent || trialPeriodUnit != null) {
      map['trial_period_unit'] = Variable<String>(trialPeriodUnit);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      currencyCode: Value(currencyCode),
      billingCycle: Value(billingCycle),
      periodInterval: Value(periodInterval),
      startDate: Value(startDate),
      iconType: Value(iconType),
      iconIdentifier: Value(iconIdentifier),
      iconColorHex: iconColorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(iconColorHex),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      reminderLeadDays: reminderLeadDays == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderLeadDays),
      reminderHour: reminderHour == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderHour),
      reminderMinute: reminderMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinute),
      trialPeriodInterval: trialPeriodInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(trialPeriodInterval),
      trialPeriodUnit: trialPeriodUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(trialPeriodUnit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      billingCycle: serializer.fromJson<String>(json['billingCycle']),
      periodInterval: serializer.fromJson<int>(json['periodInterval']),
      startDate: serializer.fromJson<int>(json['startDate']),
      iconType: serializer.fromJson<String>(json['iconType']),
      iconIdentifier: serializer.fromJson<String>(json['iconIdentifier']),
      iconColorHex: serializer.fromJson<String?>(json['iconColorHex']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<int>(json['isActive']),
      reminderLeadDays: serializer.fromJson<int?>(json['reminderLeadDays']),
      reminderHour: serializer.fromJson<int?>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int?>(json['reminderMinute']),
      trialPeriodInterval: serializer.fromJson<int?>(
        json['trialPeriodInterval'],
      ),
      trialPeriodUnit: serializer.fromJson<String?>(json['trialPeriodUnit']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'billingCycle': serializer.toJson<String>(billingCycle),
      'periodInterval': serializer.toJson<int>(periodInterval),
      'startDate': serializer.toJson<int>(startDate),
      'iconType': serializer.toJson<String>(iconType),
      'iconIdentifier': serializer.toJson<String>(iconIdentifier),
      'iconColorHex': serializer.toJson<String?>(iconColorHex),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<int>(isActive),
      'reminderLeadDays': serializer.toJson<int?>(reminderLeadDays),
      'reminderHour': serializer.toJson<int?>(reminderHour),
      'reminderMinute': serializer.toJson<int?>(reminderMinute),
      'trialPeriodInterval': serializer.toJson<int?>(trialPeriodInterval),
      'trialPeriodUnit': serializer.toJson<String?>(trialPeriodUnit),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? name,
    double? price,
    String? currencyCode,
    String? billingCycle,
    int? periodInterval,
    int? startDate,
    String? iconType,
    String? iconIdentifier,
    Value<String?> iconColorHex = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? isActive,
    Value<int?> reminderLeadDays = const Value.absent(),
    Value<int?> reminderHour = const Value.absent(),
    Value<int?> reminderMinute = const Value.absent(),
    Value<int?> trialPeriodInterval = const Value.absent(),
    Value<String?> trialPeriodUnit = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Payment(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    currencyCode: currencyCode ?? this.currencyCode,
    billingCycle: billingCycle ?? this.billingCycle,
    periodInterval: periodInterval ?? this.periodInterval,
    startDate: startDate ?? this.startDate,
    iconType: iconType ?? this.iconType,
    iconIdentifier: iconIdentifier ?? this.iconIdentifier,
    iconColorHex: iconColorHex.present ? iconColorHex.value : this.iconColorHex,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    reminderLeadDays: reminderLeadDays.present
        ? reminderLeadDays.value
        : this.reminderLeadDays,
    reminderHour: reminderHour.present ? reminderHour.value : this.reminderHour,
    reminderMinute: reminderMinute.present
        ? reminderMinute.value
        : this.reminderMinute,
    trialPeriodInterval: trialPeriodInterval.present
        ? trialPeriodInterval.value
        : this.trialPeriodInterval,
    trialPeriodUnit: trialPeriodUnit.present
        ? trialPeriodUnit.value
        : this.trialPeriodUnit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      billingCycle: data.billingCycle.present
          ? data.billingCycle.value
          : this.billingCycle,
      periodInterval: data.periodInterval.present
          ? data.periodInterval.value
          : this.periodInterval,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      iconType: data.iconType.present ? data.iconType.value : this.iconType,
      iconIdentifier: data.iconIdentifier.present
          ? data.iconIdentifier.value
          : this.iconIdentifier,
      iconColorHex: data.iconColorHex.present
          ? data.iconColorHex.value
          : this.iconColorHex,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      reminderLeadDays: data.reminderLeadDays.present
          ? data.reminderLeadDays.value
          : this.reminderLeadDays,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      trialPeriodInterval: data.trialPeriodInterval.present
          ? data.trialPeriodInterval.value
          : this.trialPeriodInterval,
      trialPeriodUnit: data.trialPeriodUnit.present
          ? data.trialPeriodUnit.value
          : this.trialPeriodUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('periodInterval: $periodInterval, ')
          ..write('startDate: $startDate, ')
          ..write('iconType: $iconType, ')
          ..write('iconIdentifier: $iconIdentifier, ')
          ..write('iconColorHex: $iconColorHex, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('reminderLeadDays: $reminderLeadDays, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('trialPeriodInterval: $trialPeriodInterval, ')
          ..write('trialPeriodUnit: $trialPeriodUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    price,
    currencyCode,
    billingCycle,
    periodInterval,
    startDate,
    iconType,
    iconIdentifier,
    iconColorHex,
    notes,
    isActive,
    reminderLeadDays,
    reminderHour,
    reminderMinute,
    trialPeriodInterval,
    trialPeriodUnit,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.currencyCode == this.currencyCode &&
          other.billingCycle == this.billingCycle &&
          other.periodInterval == this.periodInterval &&
          other.startDate == this.startDate &&
          other.iconType == this.iconType &&
          other.iconIdentifier == this.iconIdentifier &&
          other.iconColorHex == this.iconColorHex &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.reminderLeadDays == this.reminderLeadDays &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.trialPeriodInterval == this.trialPeriodInterval &&
          other.trialPeriodUnit == this.trialPeriodUnit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> price;
  final Value<String> currencyCode;
  final Value<String> billingCycle;
  final Value<int> periodInterval;
  final Value<int> startDate;
  final Value<String> iconType;
  final Value<String> iconIdentifier;
  final Value<String?> iconColorHex;
  final Value<String?> notes;
  final Value<int> isActive;
  final Value<int?> reminderLeadDays;
  final Value<int?> reminderHour;
  final Value<int?> reminderMinute;
  final Value<int?> trialPeriodInterval;
  final Value<String?> trialPeriodUnit;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.periodInterval = const Value.absent(),
    this.startDate = const Value.absent(),
    this.iconType = const Value.absent(),
    this.iconIdentifier = const Value.absent(),
    this.iconColorHex = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.reminderLeadDays = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.trialPeriodInterval = const Value.absent(),
    this.trialPeriodUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String name,
    required double price,
    required String currencyCode,
    required String billingCycle,
    this.periodInterval = const Value.absent(),
    required int startDate,
    this.iconType = const Value.absent(),
    this.iconIdentifier = const Value.absent(),
    this.iconColorHex = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.reminderLeadDays = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.trialPeriodInterval = const Value.absent(),
    this.trialPeriodUnit = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price),
       currencyCode = Value(currencyCode),
       billingCycle = Value(billingCycle),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<String>? currencyCode,
    Expression<String>? billingCycle,
    Expression<int>? periodInterval,
    Expression<int>? startDate,
    Expression<String>? iconType,
    Expression<String>? iconIdentifier,
    Expression<String>? iconColorHex,
    Expression<String>? notes,
    Expression<int>? isActive,
    Expression<int>? reminderLeadDays,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<int>? trialPeriodInterval,
    Expression<String>? trialPeriodUnit,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (periodInterval != null) 'period_interval': periodInterval,
      if (startDate != null) 'start_date': startDate,
      if (iconType != null) 'icon_type': iconType,
      if (iconIdentifier != null) 'icon_identifier': iconIdentifier,
      if (iconColorHex != null) 'icon_color_hex': iconColorHex,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (reminderLeadDays != null) 'reminder_lead_days': reminderLeadDays,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (trialPeriodInterval != null)
        'trial_period_interval': trialPeriodInterval,
      if (trialPeriodUnit != null) 'trial_period_unit': trialPeriodUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? price,
    Value<String>? currencyCode,
    Value<String>? billingCycle,
    Value<int>? periodInterval,
    Value<int>? startDate,
    Value<String>? iconType,
    Value<String>? iconIdentifier,
    Value<String?>? iconColorHex,
    Value<String?>? notes,
    Value<int>? isActive,
    Value<int?>? reminderLeadDays,
    Value<int?>? reminderHour,
    Value<int?>? reminderMinute,
    Value<int?>? trialPeriodInterval,
    Value<String?>? trialPeriodUnit,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      billingCycle: billingCycle ?? this.billingCycle,
      periodInterval: periodInterval ?? this.periodInterval,
      startDate: startDate ?? this.startDate,
      iconType: iconType ?? this.iconType,
      iconIdentifier: iconIdentifier ?? this.iconIdentifier,
      iconColorHex: iconColorHex ?? this.iconColorHex,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      trialPeriodInterval: trialPeriodInterval ?? this.trialPeriodInterval,
      trialPeriodUnit: trialPeriodUnit ?? this.trialPeriodUnit,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<String>(billingCycle.value);
    }
    if (periodInterval.present) {
      map['period_interval'] = Variable<int>(periodInterval.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (iconType.present) {
      map['icon_type'] = Variable<String>(iconType.value);
    }
    if (iconIdentifier.present) {
      map['icon_identifier'] = Variable<String>(iconIdentifier.value);
    }
    if (iconColorHex.present) {
      map['icon_color_hex'] = Variable<String>(iconColorHex.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (reminderLeadDays.present) {
      map['reminder_lead_days'] = Variable<int>(reminderLeadDays.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (trialPeriodInterval.present) {
      map['trial_period_interval'] = Variable<int>(trialPeriodInterval.value);
    }
    if (trialPeriodUnit.present) {
      map['trial_period_unit'] = Variable<String>(trialPeriodUnit.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('periodInterval: $periodInterval, ')
          ..write('startDate: $startDate, ')
          ..write('iconType: $iconType, ')
          ..write('iconIdentifier: $iconIdentifier, ')
          ..write('iconColorHex: $iconColorHex, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('reminderLeadDays: $reminderLeadDays, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('trialPeriodInterval: $trialPeriodInterval, ')
          ..write('trialPeriodUnit: $trialPeriodUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentCategoriesTable extends PaymentCategories
    with TableInfo<$PaymentCategoriesTable, PaymentCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [paymentId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {paymentId, categoryId};
  @override
  PaymentCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentCategory(
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $PaymentCategoriesTable createAlias(String alias) {
    return $PaymentCategoriesTable(attachedDatabase, alias);
  }
}

class PaymentCategory extends DataClass implements Insertable<PaymentCategory> {
  final String paymentId;
  final int categoryId;
  const PaymentCategory({required this.paymentId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['payment_id'] = Variable<String>(paymentId);
    map['category_id'] = Variable<int>(categoryId);
    return map;
  }

  PaymentCategoriesCompanion toCompanion(bool nullToAbsent) {
    return PaymentCategoriesCompanion(
      paymentId: Value(paymentId),
      categoryId: Value(categoryId),
    );
  }

  factory PaymentCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentCategory(
      paymentId: serializer.fromJson<String>(json['paymentId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'paymentId': serializer.toJson<String>(paymentId),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  PaymentCategory copyWith({String? paymentId, int? categoryId}) =>
      PaymentCategory(
        paymentId: paymentId ?? this.paymentId,
        categoryId: categoryId ?? this.categoryId,
      );
  PaymentCategory copyWithCompanion(PaymentCategoriesCompanion data) {
    return PaymentCategory(
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentCategory(')
          ..write('paymentId: $paymentId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(paymentId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentCategory &&
          other.paymentId == this.paymentId &&
          other.categoryId == this.categoryId);
}

class PaymentCategoriesCompanion extends UpdateCompanion<PaymentCategory> {
  final Value<String> paymentId;
  final Value<int> categoryId;
  final Value<int> rowid;
  const PaymentCategoriesCompanion({
    this.paymentId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentCategoriesCompanion.insert({
    required String paymentId,
    required int categoryId,
    this.rowid = const Value.absent(),
  }) : paymentId = Value(paymentId),
       categoryId = Value(categoryId);
  static Insertable<PaymentCategory> custom({
    Expression<String>? paymentId,
    Expression<int>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (paymentId != null) 'payment_id': paymentId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentCategoriesCompanion copyWith({
    Value<String>? paymentId,
    Value<int>? categoryId,
    Value<int>? rowid,
  }) {
    return PaymentCategoriesCompanion(
      paymentId: paymentId ?? this.paymentId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentCategoriesCompanion(')
          ..write('paymentId: $paymentId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrencyRatesCacheTable extends CurrencyRatesCache
    with TableInfo<$CurrencyRatesCacheTable, CurrencyRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrencyRatesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCurrencyMeta = const VerificationMeta(
    'targetCurrency',
  );
  @override
  late final GeneratedColumn<String> targetCurrency = GeneratedColumn<String>(
    'target_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    baseCurrency,
    targetCurrency,
    rate,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currency_rates_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurrencyRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('target_currency')) {
      context.handle(
        _targetCurrencyMeta,
        targetCurrency.isAcceptableOrUnknown(
          data['target_currency']!,
          _targetCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCurrencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {baseCurrency, targetCurrency};
  @override
  CurrencyRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrencyRate(
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      targetCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_currency'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CurrencyRatesCacheTable createAlias(String alias) {
    return $CurrencyRatesCacheTable(attachedDatabase, alias);
  }
}

class CurrencyRate extends DataClass implements Insertable<CurrencyRate> {
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final int fetchedAt;
  const CurrencyRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base_currency'] = Variable<String>(baseCurrency);
    map['target_currency'] = Variable<String>(targetCurrency);
    map['rate'] = Variable<double>(rate);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  CurrencyRatesCacheCompanion toCompanion(bool nullToAbsent) {
    return CurrencyRatesCacheCompanion(
      baseCurrency: Value(baseCurrency),
      targetCurrency: Value(targetCurrency),
      rate: Value(rate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CurrencyRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrencyRate(
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      targetCurrency: serializer.fromJson<String>(json['targetCurrency']),
      rate: serializer.fromJson<double>(json['rate']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'targetCurrency': serializer.toJson<String>(targetCurrency),
      'rate': serializer.toJson<double>(rate),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  CurrencyRate copyWith({
    String? baseCurrency,
    String? targetCurrency,
    double? rate,
    int? fetchedAt,
  }) => CurrencyRate(
    baseCurrency: baseCurrency ?? this.baseCurrency,
    targetCurrency: targetCurrency ?? this.targetCurrency,
    rate: rate ?? this.rate,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CurrencyRate copyWithCompanion(CurrencyRatesCacheCompanion data) {
    return CurrencyRate(
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      targetCurrency: data.targetCurrency.present
          ? data.targetCurrency.value
          : this.targetCurrency,
      rate: data.rate.present ? data.rate.value : this.rate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyRate(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('targetCurrency: $targetCurrency, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(baseCurrency, targetCurrency, rate, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrencyRate &&
          other.baseCurrency == this.baseCurrency &&
          other.targetCurrency == this.targetCurrency &&
          other.rate == this.rate &&
          other.fetchedAt == this.fetchedAt);
}

class CurrencyRatesCacheCompanion extends UpdateCompanion<CurrencyRate> {
  final Value<String> baseCurrency;
  final Value<String> targetCurrency;
  final Value<double> rate;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const CurrencyRatesCacheCompanion({
    this.baseCurrency = const Value.absent(),
    this.targetCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrencyRatesCacheCompanion.insert({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : baseCurrency = Value(baseCurrency),
       targetCurrency = Value(targetCurrency),
       rate = Value(rate),
       fetchedAt = Value(fetchedAt);
  static Insertable<CurrencyRate> custom({
    Expression<String>? baseCurrency,
    Expression<String>? targetCurrency,
    Expression<double>? rate,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (targetCurrency != null) 'target_currency': targetCurrency,
      if (rate != null) 'rate': rate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrencyRatesCacheCompanion copyWith({
    Value<String>? baseCurrency,
    Value<String>? targetCurrency,
    Value<double>? rate,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CurrencyRatesCacheCompanion(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (targetCurrency.present) {
      map['target_currency'] = Variable<String>(targetCurrency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyRatesCacheCompanion(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('targetCurrency: $targetCurrency, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PaymentCategoriesTable paymentCategories =
      $PaymentCategoriesTable(this);
  late final $CurrencyRatesCacheTable currencyRatesCache =
      $CurrencyRatesCacheTable(this);
  late final CategoriesDao categoriesDao = CategoriesDao(this as AppDatabase);
  late final PaymentsDao paymentsDao = PaymentsDao(this as AppDatabase);
  late final PaymentCategoriesDao paymentCategoriesDao = PaymentCategoriesDao(
    this as AppDatabase,
  );
  late final CurrencyCacheDao currencyCacheDao = CurrencyCacheDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    payments,
    paymentCategories,
    currencyRatesCache,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String colorHex,
      required int iconCodePoint,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> colorHex,
      Value<int> iconCodePoint,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                iconCodePoint: iconCodePoint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String colorHex,
                required int iconCodePoint,
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                iconCodePoint: iconCodePoint,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String name,
      required double price,
      required String currencyCode,
      required String billingCycle,
      Value<int> periodInterval,
      required int startDate,
      Value<String> iconType,
      Value<String> iconIdentifier,
      Value<String?> iconColorHex,
      Value<String?> notes,
      Value<int> isActive,
      Value<int?> reminderLeadDays,
      Value<int?> reminderHour,
      Value<int?> reminderMinute,
      Value<int?> trialPeriodInterval,
      Value<String?> trialPeriodUnit,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> price,
      Value<String> currencyCode,
      Value<String> billingCycle,
      Value<int> periodInterval,
      Value<int> startDate,
      Value<String> iconType,
      Value<String> iconIdentifier,
      Value<String?> iconColorHex,
      Value<String?> notes,
      Value<int> isActive,
      Value<int?> reminderLeadDays,
      Value<int?> reminderHour,
      Value<int?> reminderMinute,
      Value<int?> trialPeriodInterval,
      Value<String?> trialPeriodUnit,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodInterval => $composableBuilder(
    column: $table.periodInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconType => $composableBuilder(
    column: $table.iconType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconIdentifier => $composableBuilder(
    column: $table.iconIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconColorHex => $composableBuilder(
    column: $table.iconColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderLeadDays => $composableBuilder(
    column: $table.reminderLeadDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trialPeriodInterval => $composableBuilder(
    column: $table.trialPeriodInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trialPeriodUnit => $composableBuilder(
    column: $table.trialPeriodUnit,
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
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodInterval => $composableBuilder(
    column: $table.periodInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconType => $composableBuilder(
    column: $table.iconType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconIdentifier => $composableBuilder(
    column: $table.iconIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconColorHex => $composableBuilder(
    column: $table.iconColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderLeadDays => $composableBuilder(
    column: $table.reminderLeadDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trialPeriodInterval => $composableBuilder(
    column: $table.trialPeriodInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trialPeriodUnit => $composableBuilder(
    column: $table.trialPeriodUnit,
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

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodInterval => $composableBuilder(
    column: $table.periodInterval,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get iconType =>
      $composableBuilder(column: $table.iconType, builder: (column) => column);

  GeneratedColumn<String> get iconIdentifier => $composableBuilder(
    column: $table.iconIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconColorHex => $composableBuilder(
    column: $table.iconColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get reminderLeadDays => $composableBuilder(
    column: $table.reminderLeadDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trialPeriodInterval => $composableBuilder(
    column: $table.trialPeriodInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trialPeriodUnit => $composableBuilder(
    column: $table.trialPeriodUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> billingCycle = const Value.absent(),
                Value<int> periodInterval = const Value.absent(),
                Value<int> startDate = const Value.absent(),
                Value<String> iconType = const Value.absent(),
                Value<String> iconIdentifier = const Value.absent(),
                Value<String?> iconColorHex = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int?> reminderLeadDays = const Value.absent(),
                Value<int?> reminderHour = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<int?> trialPeriodInterval = const Value.absent(),
                Value<String?> trialPeriodUnit = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                name: name,
                price: price,
                currencyCode: currencyCode,
                billingCycle: billingCycle,
                periodInterval: periodInterval,
                startDate: startDate,
                iconType: iconType,
                iconIdentifier: iconIdentifier,
                iconColorHex: iconColorHex,
                notes: notes,
                isActive: isActive,
                reminderLeadDays: reminderLeadDays,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                trialPeriodInterval: trialPeriodInterval,
                trialPeriodUnit: trialPeriodUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double price,
                required String currencyCode,
                required String billingCycle,
                Value<int> periodInterval = const Value.absent(),
                required int startDate,
                Value<String> iconType = const Value.absent(),
                Value<String> iconIdentifier = const Value.absent(),
                Value<String?> iconColorHex = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int?> reminderLeadDays = const Value.absent(),
                Value<int?> reminderHour = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<int?> trialPeriodInterval = const Value.absent(),
                Value<String?> trialPeriodUnit = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                name: name,
                price: price,
                currencyCode: currencyCode,
                billingCycle: billingCycle,
                periodInterval: periodInterval,
                startDate: startDate,
                iconType: iconType,
                iconIdentifier: iconIdentifier,
                iconColorHex: iconColorHex,
                notes: notes,
                isActive: isActive,
                reminderLeadDays: reminderLeadDays,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                trialPeriodInterval: trialPeriodInterval,
                trialPeriodUnit: trialPeriodUnit,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$PaymentCategoriesTableCreateCompanionBuilder =
    PaymentCategoriesCompanion Function({
      required String paymentId,
      required int categoryId,
      Value<int> rowid,
    });
typedef $$PaymentCategoriesTableUpdateCompanionBuilder =
    PaymentCategoriesCompanion Function({
      Value<String> paymentId,
      Value<int> categoryId,
      Value<int> rowid,
    });

class $$PaymentCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentCategoriesTable> {
  $$PaymentCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentCategoriesTable> {
  $$PaymentCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get paymentId => $composableBuilder(
    column: $table.paymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentCategoriesTable> {
  $$PaymentCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get paymentId =>
      $composableBuilder(column: $table.paymentId, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );
}

class $$PaymentCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentCategoriesTable,
          PaymentCategory,
          $$PaymentCategoriesTableFilterComposer,
          $$PaymentCategoriesTableOrderingComposer,
          $$PaymentCategoriesTableAnnotationComposer,
          $$PaymentCategoriesTableCreateCompanionBuilder,
          $$PaymentCategoriesTableUpdateCompanionBuilder,
          (
            PaymentCategory,
            BaseReferences<
              _$AppDatabase,
              $PaymentCategoriesTable,
              PaymentCategory
            >,
          ),
          PaymentCategory,
          PrefetchHooks Function()
        > {
  $$PaymentCategoriesTableTableManager(
    _$AppDatabase db,
    $PaymentCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> paymentId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentCategoriesCompanion(
                paymentId: paymentId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String paymentId,
                required int categoryId,
                Value<int> rowid = const Value.absent(),
              }) => PaymentCategoriesCompanion.insert(
                paymentId: paymentId,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentCategoriesTable,
      PaymentCategory,
      $$PaymentCategoriesTableFilterComposer,
      $$PaymentCategoriesTableOrderingComposer,
      $$PaymentCategoriesTableAnnotationComposer,
      $$PaymentCategoriesTableCreateCompanionBuilder,
      $$PaymentCategoriesTableUpdateCompanionBuilder,
      (
        PaymentCategory,
        BaseReferences<_$AppDatabase, $PaymentCategoriesTable, PaymentCategory>,
      ),
      PaymentCategory,
      PrefetchHooks Function()
    >;
typedef $$CurrencyRatesCacheTableCreateCompanionBuilder =
    CurrencyRatesCacheCompanion Function({
      required String baseCurrency,
      required String targetCurrency,
      required double rate,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$CurrencyRatesCacheTableUpdateCompanionBuilder =
    CurrencyRatesCacheCompanion Function({
      Value<String> baseCurrency,
      Value<String> targetCurrency,
      Value<double> rate,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$CurrencyRatesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $CurrencyRatesCacheTable> {
  $$CurrencyRatesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetCurrency => $composableBuilder(
    column: $table.targetCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrencyRatesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrencyRatesCacheTable> {
  $$CurrencyRatesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetCurrency => $composableBuilder(
    column: $table.targetCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrencyRatesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrencyRatesCacheTable> {
  $$CurrencyRatesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetCurrency => $composableBuilder(
    column: $table.targetCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CurrencyRatesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrencyRatesCacheTable,
          CurrencyRate,
          $$CurrencyRatesCacheTableFilterComposer,
          $$CurrencyRatesCacheTableOrderingComposer,
          $$CurrencyRatesCacheTableAnnotationComposer,
          $$CurrencyRatesCacheTableCreateCompanionBuilder,
          $$CurrencyRatesCacheTableUpdateCompanionBuilder,
          (
            CurrencyRate,
            BaseReferences<
              _$AppDatabase,
              $CurrencyRatesCacheTable,
              CurrencyRate
            >,
          ),
          CurrencyRate,
          PrefetchHooks Function()
        > {
  $$CurrencyRatesCacheTableTableManager(
    _$AppDatabase db,
    $CurrencyRatesCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrencyRatesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrencyRatesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrencyRatesCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> baseCurrency = const Value.absent(),
                Value<String> targetCurrency = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrencyRatesCacheCompanion(
                baseCurrency: baseCurrency,
                targetCurrency: targetCurrency,
                rate: rate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String baseCurrency,
                required String targetCurrency,
                required double rate,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CurrencyRatesCacheCompanion.insert(
                baseCurrency: baseCurrency,
                targetCurrency: targetCurrency,
                rate: rate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurrencyRatesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrencyRatesCacheTable,
      CurrencyRate,
      $$CurrencyRatesCacheTableFilterComposer,
      $$CurrencyRatesCacheTableOrderingComposer,
      $$CurrencyRatesCacheTableAnnotationComposer,
      $$CurrencyRatesCacheTableCreateCompanionBuilder,
      $$CurrencyRatesCacheTableUpdateCompanionBuilder,
      (
        CurrencyRate,
        BaseReferences<_$AppDatabase, $CurrencyRatesCacheTable, CurrencyRate>,
      ),
      CurrencyRate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PaymentCategoriesTableTableManager get paymentCategories =>
      $$PaymentCategoriesTableTableManager(_db, _db.paymentCategories);
  $$CurrencyRatesCacheTableTableManager get currencyRatesCache =>
      $$CurrencyRatesCacheTableTableManager(_db, _db.currencyRatesCache);
}

mixin _$CategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  CategoriesDaoManager get managers => CategoriesDaoManager(this);
}

class CategoriesDaoManager {
  final _$CategoriesDaoMixin _db;
  CategoriesDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
}

mixin _$PaymentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PaymentsTable get payments => attachedDatabase.payments;
  PaymentsDaoManager get managers => PaymentsDaoManager(this);
}

class PaymentsDaoManager {
  final _$PaymentsDaoMixin _db;
  PaymentsDaoManager(this._db);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db.attachedDatabase, _db.payments);
}

mixin _$PaymentCategoriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PaymentCategoriesTable get paymentCategories =>
      attachedDatabase.paymentCategories;
  $CategoriesTable get categories => attachedDatabase.categories;
  PaymentCategoriesDaoManager get managers => PaymentCategoriesDaoManager(this);
}

class PaymentCategoriesDaoManager {
  final _$PaymentCategoriesDaoMixin _db;
  PaymentCategoriesDaoManager(this._db);
  $$PaymentCategoriesTableTableManager get paymentCategories =>
      $$PaymentCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.paymentCategories,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
}

mixin _$CurrencyCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrencyRatesCacheTable get currencyRatesCache =>
      attachedDatabase.currencyRatesCache;
  CurrencyCacheDaoManager get managers => CurrencyCacheDaoManager(this);
}

class CurrencyCacheDaoManager {
  final _$CurrencyCacheDaoMixin _db;
  CurrencyCacheDaoManager(this._db);
  $$CurrencyRatesCacheTableTableManager get currencyRatesCache =>
      $$CurrencyRatesCacheTableTableManager(
        _db.attachedDatabase,
        _db.currencyRatesCache,
      );
}
