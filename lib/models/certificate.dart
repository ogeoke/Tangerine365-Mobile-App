/// One earned certificate from `POST /api/certificates` (`data.certificates[]`).
///
/// Plain model (no codegen) — the list is small and the render payload is
/// consumed as a raw map by the preview screen.
class Certificate {
  final int id; // certificate id (e.g. 2007)
  final int courseId; // owning course id (e.g. 7039)
  final String course; // course name
  final String title; // certificate title, e.g. "Certificate of Achievement"
  final String identifier; // short code, e.g. "COA"
  final String issueDate; // ISO-8601
  final String completionDate; // ISO-8601
  final bool downloadable;

  /// Server flag (`generated`); older responses omit it.
  final bool? generatedFlag;

  const Certificate({
    required this.id,
    required this.courseId,
    required this.course,
    required this.title,
    required this.identifier,
    required this.issueDate,
    required this.completionDate,
    required this.downloadable,
    this.generatedFlag,
  });

  /// The LMS issues (generates) a certificate before it can be downloaded; an
  /// un-issued certificate comes back with a null/empty `issueDate`.
  bool get generated => generatedFlag ?? issueDate.trim().isNotEmpty;

  factory Certificate.fromJson(Map<String, dynamic> j) => Certificate(
        id: (j['id'] as num?)?.toInt() ?? 0,
        courseId: (j['courseId'] as num?)?.toInt() ?? 0,
        course: j['course']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        identifier: j['identifier']?.toString() ?? '',
        issueDate: j['issueDate']?.toString() ?? '',
        completionDate: j['completionDate']?.toString() ?? '',
        downloadable: j['downloadable'] == true,
        generatedFlag: j['generated'] is bool ? j['generated'] as bool : null,
      );
}
