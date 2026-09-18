/// One attained competency from `POST /api/competencies`
/// (`data.competencies[]`). Plain model (no codegen).
class Competency {
  final int id;
  final String name;
  final String category; // may be empty
  final String? level; // usually null (numeric score instead)
  final num? score; // 0–100 for score type
  final String dateAttained; // ISO-8601
  final String description; // may be empty
  final String type; // 'score' | 'flag'
  final String typology; // 'skill' | 'knowledge' | ...

  const Competency({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.score,
    required this.dateAttained,
    required this.description,
    required this.type,
    required this.typology,
  });

  /// Flag competencies are pass/fail (attained), not scored out of 100.
  bool get isFlag => type == 'flag';

  factory Competency.fromJson(Map<String, dynamic> j) {
    num? asNum(dynamic v) => v is num ? v : null;
    return Competency(
      id: (asNum(j['id']) ?? asNum(j['id_competence']))?.toInt() ?? 0,
      name: j['name']?.toString() ?? '',
      category: j['category']?.toString() ?? '',
      level: j['level']?.toString(),
      score: asNum(j['score']) ?? asNum(j['score_got']),
      dateAttained: j['dateAttained']?.toString() ??
          j['last_assign_date']?.toString() ??
          '',
      description: j['description']?.toString() ?? '',
      type: (j['type']?.toString() ?? 'score').toLowerCase(),
      typology: (j['typology']?.toString() ?? '').toLowerCase(),
    );
  }
}
