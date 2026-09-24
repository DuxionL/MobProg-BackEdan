import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccountGroupType { normal, credit, debit }

class AccountGroup {
  final String id;
  final String name;
  final AccountGroupType type;
  final bool isProtected;
  final bool isDeleted;

  const AccountGroup({
    required this.id,
    required this.name,
    this.type = AccountGroupType.normal,
    this.isProtected = false,
    this.isDeleted = false,
  });

  String? get subtitle {
    switch (type) {
      case AccountGroupType.credit:
        return 'Card';
      case AccountGroupType.debit:
        return 'Debit Card';
      case AccountGroupType.normal:
        return null;
    }
  }

  AccountGroup copyWith({
    String? name,
    AccountGroupType? type,
    bool? isDeleted,
  }) {
    return AccountGroup(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      isProtected: isProtected,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'isProtected': isProtected,
      'isDeleted': isDeleted,
    };
  }

  factory AccountGroup.fromMap(Map<String, dynamic> map) {
    return AccountGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountGroupType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AccountGroupType.normal,
      ),
      isProtected: map['isProtected'] as bool? ?? false,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }
}

class AccountItem {
  final String id;
  final String groupId;
  final String name;
  final double amount;
  final String description;
  final bool isDeleted;
  final bool deletedByGroup;

  const AccountItem({
    required this.id,
    required this.groupId,
    required this.name,
    this.amount = 0,
    this.description = '',
    this.isDeleted = false,
    this.deletedByGroup = false,
  });

  AccountItem copyWith({
    String? groupId,
    String? name,
    double? amount,
    String? description,
    bool? isDeleted,
    bool? deletedByGroup,
  }) {
    return AccountItem(
      id: id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedByGroup: deletedByGroup ?? this.deletedByGroup,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'amount': amount,
      'description': description,
      'isDeleted': isDeleted,
      'deletedByGroup': deletedByGroup,
    };
  }

  factory AccountItem.fromMap(Map<String, dynamic> map) {
    return AccountItem(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num? ?? 0).toDouble(),
      description: map['description'] as String? ?? '',
      isDeleted: map['isDeleted'] as bool? ?? false,
      deletedByGroup: map['deletedByGroup'] as bool? ?? false,
    );
  }
}

class AccountStore {
  static const String _groupsKey = 'account_groups';
  static const String _itemsKey = 'account_items';

  static const List<AccountGroup> _defaultGroups = [
    AccountGroup(id: 'g_cash', name: 'Cash', isProtected: true),
    AccountGroup(id: 'g_accounts', name: 'Accounts', isProtected: true),
    AccountGroup(
      id: 'g_card',
      name: 'Card',
      type: AccountGroupType.credit,
      isProtected: true,
    ),
    AccountGroup(
      id: 'g_debit',
      name: 'Debit Card',
      type: AccountGroupType.debit,
      isProtected: true,
    ),
    AccountGroup(id: 'g_savings', name: 'Savings'),
    AccountGroup(id: 'g_topup', name: 'Top-Up/Prepaid'),
    AccountGroup(id: 'g_investments', name: 'Investments'),
    AccountGroup(id: 'g_overdrafts', name: 'Overdrafts'),
    AccountGroup(id: 'g_loan', name: 'Loan'),
    AccountGroup(id: 'g_insurance', name: 'Insurance'),
    AccountGroup(id: 'g_others', name: 'Others'),
  ];

  static const List<AccountItem> _defaultItems = [
    AccountItem(id: 'a_cash', groupId: 'g_cash', name: 'Cash'),
    AccountItem(id: 'a_accounts', groupId: 'g_accounts', name: 'Accounts'),
    AccountItem(id: 'a_card', groupId: 'g_card', name: 'Card'),
  ];

  static final ValueNotifier<List<AccountGroup>> groups =
      ValueNotifier<List<AccountGroup>>([]);
  static final ValueNotifier<List<AccountItem>> items =
      ValueNotifier<List<AccountItem>>([]);
  static bool _loaded = false;

  static List<AccountGroup> get visibleGroups =>
      groups.value.where((g) => !g.isDeleted).toList();

  static List<AccountItem> get visibleItems =>
      items.value.where((i) => !i.isDeleted).toList();

  static List<AccountGroup> get deletedGroups =>
      groups.value.where((g) => g.isDeleted).toList();

  static List<AccountItem> get deletedItems =>
      items.value.where((i) => i.isDeleted && !i.deletedByGroup).toList();

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final prefs = await SharedPreferences.getInstance();
    final rawGroups = prefs.getString(_groupsKey);
    final rawItems = prefs.getString(_itemsKey);

    if (rawGroups == null) {
      groups.value = List.of(_defaultGroups);
      items.value = List.of(_defaultItems);
      await _save();
      return;
    }

    groups.value = (jsonDecode(rawGroups) as List<dynamic>)
        .map((e) => AccountGroup.fromMap(e as Map<String, dynamic>))
        .toList();
    items.value = rawItems == null
        ? []
        : (jsonDecode(rawItems) as List<dynamic>)
              .map((e) => AccountItem.fromMap(e as Map<String, dynamic>))
              .toList();
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _groupsKey,
      jsonEncode(groups.value.map((g) => g.toMap()).toList()),
    );
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.value.map((i) => i.toMap()).toList()),
    );
  }

  static Future<void> addGroup(String name, AccountGroupType type) async {
    groups.value = [
      ...groups.value,
      AccountGroup(id: _newId(), name: name, type: type),
    ];
    await _save();
  }

  static Future<void> updateGroup(
    String id,
    String name,
    AccountGroupType type,
  ) async {
    groups.value = groups.value
        .map((g) => g.id == id ? g.copyWith(name: name, type: type) : g)
        .toList();
    await _save();
  }

  static Future<void> deleteGroup(String id) async {
    groups.value = groups.value
        .map((g) => g.id == id ? g.copyWith(isDeleted: true) : g)
        .toList();
    items.value = items.value
        .map(
          (i) => i.groupId == id && !i.isDeleted
              ? i.copyWith(isDeleted: true, deletedByGroup: true)
              : i,
        )
        .toList();
    await _save();
  }

  static Future<void> restoreGroup(String id) async {
    groups.value = groups.value
        .map((g) => g.id == id ? g.copyWith(isDeleted: false) : g)
        .toList();
    items.value = items.value
        .map(
          (i) => i.groupId == id && i.deletedByGroup
              ? i.copyWith(isDeleted: false, deletedByGroup: false)
              : i,
        )
        .toList();
    await _save();
  }

  static Future<void> permanentlyDeleteGroup(String id) async {
    groups.value = groups.value.where((g) => g.id != id).toList();
    items.value = items.value.where((i) => i.groupId != id).toList();
    await _save();
  }

  static Future<void> reorderGroups(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final visible = visibleGroups;
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);
    groups.value = [...visible, ...groups.value.where((g) => g.isDeleted)];
    await _save();
  }

  static Future<void> addItem({
    required String groupId,
    required String name,
    required double amount,
    required String description,
  }) async {
    items.value = [
      ...items.value,
      AccountItem(
        id: _newId(),
        groupId: groupId,
        name: name,
        amount: amount,
        description: description,
      ),
    ];
    await _save();
  }

  static Future<void> updateItem(AccountItem item) async {
    items.value = items.value.map((i) => i.id == item.id ? item : i).toList();
    await _save();
  }

  static Future<void> deleteItem(String id) async {
    items.value = items.value
        .map((i) => i.id == id ? i.copyWith(isDeleted: true) : i)
        .toList();
    await _save();
  }

  static Future<bool> restoreItem(String id) async {
    final item = items.value.firstWhere((i) => i.id == id);
    final groupDeleted = groups.value.any(
      (g) => g.id == item.groupId && g.isDeleted,
    );
    if (groupDeleted) return false;

    items.value = items.value
        .map(
          (i) => i.id == id
              ? i.copyWith(isDeleted: false, deletedByGroup: false)
              : i,
        )
        .toList();
    await _save();
    return true;
  }

  static Future<void> permanentlyDeleteItem(String id) async {
    items.value = items.value.where((i) => i.id != id).toList();
    await _save();
  }
}
