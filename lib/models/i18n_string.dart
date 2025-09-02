/// 多语言名称
class I18NString {
  final String chinese;
  final String english;
  final String japanese;

  const I18NString({
    required this.chinese,
    required this.english,
    required this.japanese,
  });

  factory I18NString.fromJson(Map<String, dynamic> json) {
    return I18NString(
      chinese: json['chinese'] ?? '',
      english: json['english'] ?? '',
      japanese: json['japanese'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chinese': chinese,
      'english': english,
      'japanese': japanese,
    };
  }

  @override
  String toString() => chinese.isNotEmpty ? chinese : english;
}
