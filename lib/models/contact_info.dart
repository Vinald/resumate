/// Personal / contact details shared by resumes and letters.
class ContactInfo {
  const ContactInfo({
    this.name = '',
    this.title = '',
    this.portfolioUrl = '',
    this.phone = '',
    this.email = '',
    this.githubUrl = '',
    this.githubLabel = '',
    this.linkedinUrl = '',
    this.linkedinLabel = '',
  });

  final String name;
  final String title;
  final String portfolioUrl;
  final String phone;
  final String email;
  final String githubUrl;
  final String githubLabel;
  final String linkedinUrl;
  final String linkedinLabel;

  ContactInfo copyWith({
    String? name,
    String? title,
    String? portfolioUrl,
    String? phone,
    String? email,
    String? githubUrl,
    String? githubLabel,
    String? linkedinUrl,
    String? linkedinLabel,
  }) {
    return ContactInfo(
      name: name ?? this.name,
      title: title ?? this.title,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      githubUrl: githubUrl ?? this.githubUrl,
      githubLabel: githubLabel ?? this.githubLabel,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      linkedinLabel: linkedinLabel ?? this.linkedinLabel,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'title': title,
    'portfolioUrl': portfolioUrl,
    'phone': phone,
    'email': email,
    'githubUrl': githubUrl,
    'githubLabel': githubLabel,
    'linkedinUrl': linkedinUrl,
    'linkedinLabel': linkedinLabel,
  };

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    name: json['name'] as String? ?? '',
    title: json['title'] as String? ?? '',
    portfolioUrl: json['portfolioUrl'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    githubUrl: json['githubUrl'] as String? ?? '',
    githubLabel: json['githubLabel'] as String? ?? '',
    linkedinUrl: json['linkedinUrl'] as String? ?? '',
    linkedinLabel: json['linkedinLabel'] as String? ?? '',
  );
}
