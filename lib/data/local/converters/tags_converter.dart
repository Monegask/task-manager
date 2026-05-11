import 'dart:convert';

import 'package:drift/drift.dart';

/// Хранит `List<String>` как JSON-массив в TEXT-колонке.
/// Пустой массив → '[]' (а не пустая строка, чтобы избежать двусмысленности).
class TagsConverter extends TypeConverter<List<String>, String>
    with JsonTypeConverter2<List<String>, String, List<dynamic>> {
  const TagsConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) {
      throw FormatException('Expected JSON array for tags, got: $fromDb');
    }
    return decoded.map((e) => e.toString()).toList(growable: false);
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);

  @override
  List<String> fromJson(List<dynamic> json) =>
      json.map((e) => e.toString()).toList(growable: false);

  @override
  List<dynamic> toJson(List<String> value) => value;
}
