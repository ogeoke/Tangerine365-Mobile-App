import 'package:json_annotation/json_annotation.dart';

import 'enrollment.dart';

part 'recomended.g.dart';

@JsonSerializable()
class Recomended {
  Recomended({
    required this.success,
    this.enrollment,
    this.completed,
    this.recommended,
  });

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'enrollment')
  final Enrollment? enrollment;
  @JsonKey(name: 'completed')
  final Enrollment? completed;
  @JsonKey(name: 'recommended')
  final Enrollment? recommended;

  Map<String, dynamic> toJson() => _$RecomendedToJson(this);

  static Recomended fromJson(Map<String, dynamic> json) {
    // The backend serializes an EMPTY section as a JSON array `[]` (PHP empty
    // arrays) but a populated one as an object. Casting `[]` to a Map crashes
    // the whole parse and drops every recommendation section, so coerce any
    // non-object section to null before decoding.
    final sanitized = Map<String, dynamic>.from(json);
    for (final key in const ['enrollment', 'completed', 'recommended']) {
      if (sanitized[key] is! Map) sanitized[key] = null;
    }
    return _$RecomendedFromJson(sanitized);
  }
}
