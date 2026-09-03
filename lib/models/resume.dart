import 'contact_info.dart';

/// A single job / internship entry.
class ExperienceEntry {
  ExperienceEntry({
    this.role = '',
    this.organization = '',
    this.startDate = '',
    this.endDate = '',
    List<String>? bullets,
  }) : bullets = bullets ?? <String>[];

  String role;
  String organization;
  String startDate;
  String endDate;
  List<String> bullets;

  String get dateRange {
    if (startDate.isEmpty && endDate.isEmpty) return '';
    if (endDate.isEmpty) return startDate;
    if (startDate.isEmpty) return endDate;
    return '$startDate — $endDate';
  }

  ExperienceEntry copy() => ExperienceEntry(
    role: role,
    organization: organization,
    startDate: startDate,
    endDate: endDate,
    bullets: List<String>.from(bullets),
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'organization': organization,
    'startDate': startDate,
    'endDate': endDate,
    'bullets': bullets,
  };

  factory ExperienceEntry.fromJson(Map<String, dynamic> json) => ExperienceEntry(
    role: json['role'] as String? ?? '',
    organization: json['organization'] as String? ?? '',
    startDate: json['startDate'] as String? ?? '',
    endDate: json['endDate'] as String? ?? '',
    bullets:
        (json['bullets'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
  );
}

/// A labelled group of skills, e.g. "Programming Languages: Java, Python".
class SkillCategory {
  SkillCategory({this.label = '', List<String>? items})
    : items = items ?? <String>[];

  String label;
  List<String> items;

  SkillCategory copy() =>
      SkillCategory(label: label, items: List<String>.from(items));

  Map<String, dynamic> toJson() => {'label': label, 'items': items};

  factory SkillCategory.fromJson(Map<String, dynamic> json) => SkillCategory(
    label: json['label'] as String? ?? '',
    items:
        (json['items'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
  );
}

class EducationEntry {
  EducationEntry({
    this.qualification = '',
    this.institution = '',
    this.dates = '',
  });

  String qualification;
  String institution;
  String dates;

  EducationEntry copy() => EducationEntry(
    qualification: qualification,
    institution: institution,
    dates: dates,
  );

  Map<String, dynamic> toJson() => {
    'qualification': qualification,
    'institution': institution,
    'dates': dates,
  };

  factory EducationEntry.fromJson(Map<String, dynamic> json) => EducationEntry(
    qualification: json['qualification'] as String? ?? '',
    institution: json['institution'] as String? ?? '',
    dates: json['dates'] as String? ?? '',
  );
}

class ProjectEntry {
  ProjectEntry({this.name = '', this.tech = '', this.description = ''});

  String name;
  String tech;
  String description;

  ProjectEntry copy() =>
      ProjectEntry(name: name, tech: tech, description: description);

  Map<String, dynamic> toJson() => {
    'name': name,
    'tech': tech,
    'description': description,
  };

  factory ProjectEntry.fromJson(Map<String, dynamic> json) => ProjectEntry(
    name: json['name'] as String? ?? '',
    tech: json['tech'] as String? ?? '',
    description: json['description'] as String? ?? '',
  );
}

class ReferenceEntry {
  ReferenceEntry({
    this.name = '',
    this.organization = '',
    this.email = '',
    this.phone = '',
  });

  String name;
  String organization;
  String email;
  String phone;

  ReferenceEntry copy() => ReferenceEntry(
    name: name,
    organization: organization,
    email: email,
    phone: phone,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'organization': organization,
    'email': email,
    'phone': phone,
  };

  factory ReferenceEntry.fromJson(Map<String, dynamic> json) => ReferenceEntry(
    name: json['name'] as String? ?? '',
    organization: json['organization'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
  );
}

/// The full content of a resume.
class ResumeData {
  ResumeData({
    ContactInfo? contact,
    this.summary = '',
    List<ExperienceEntry>? experience,
    List<SkillCategory>? skills,
    List<String>? softSkills,
    List<EducationEntry>? education,
    List<ProjectEntry>? projects,
    List<ReferenceEntry>? references,
    this.referencesOnRequest = true,
    this.referencesNote = 'Names, contacts and emails available on request',
  }) : contact = contact ?? const ContactInfo(),
       experience = experience ?? <ExperienceEntry>[],
       skills = skills ?? <SkillCategory>[],
       softSkills = softSkills ?? <String>[],
       education = education ?? <EducationEntry>[],
       projects = projects ?? <ProjectEntry>[],
       references = references ?? <ReferenceEntry>[];

  ContactInfo contact;
  String summary;
  List<ExperienceEntry> experience;
  List<SkillCategory> skills;
  List<String> softSkills;
  List<EducationEntry> education;
  List<ProjectEntry> projects;
  List<ReferenceEntry> references;
  bool referencesOnRequest;
  String referencesNote;

  ResumeData copy() => ResumeData(
    contact: contact.copyWith(),
    summary: summary,
    experience: experience.map((e) => e.copy()).toList(),
    skills: skills.map((e) => e.copy()).toList(),
    softSkills: List<String>.from(softSkills),
    education: education.map((e) => e.copy()).toList(),
    projects: projects.map((e) => e.copy()).toList(),
    references: references.map((e) => e.copy()).toList(),
    referencesOnRequest: referencesOnRequest,
    referencesNote: referencesNote,
  );

  Map<String, dynamic> toJson() => {
    'contact': contact.toJson(),
    'summary': summary,
    'experience': experience.map((e) => e.toJson()).toList(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'softSkills': softSkills,
    'education': education.map((e) => e.toJson()).toList(),
    'projects': projects.map((e) => e.toJson()).toList(),
    'references': references.map((e) => e.toJson()).toList(),
    'referencesOnRequest': referencesOnRequest,
    'referencesNote': referencesNote,
  };

  factory ResumeData.fromJson(Map<String, dynamic> json) => ResumeData(
    contact: ContactInfo.fromJson(
      (json['contact'] as Map?)?.cast<String, dynamic>() ?? const {},
    ),
    summary: json['summary'] as String? ?? '',
    experience:
        (json['experience'] as List<dynamic>? ?? const [])
            .map((e) => ExperienceEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
    skills:
        (json['skills'] as List<dynamic>? ?? const [])
            .map((e) => SkillCategory.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
    softSkills:
        (json['softSkills'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
    education:
        (json['education'] as List<dynamic>? ?? const [])
            .map((e) => EducationEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
    projects:
        (json['projects'] as List<dynamic>? ?? const [])
            .map((e) => ProjectEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
    references:
        (json['references'] as List<dynamic>? ?? const [])
            .map((e) => ReferenceEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
    referencesOnRequest: json['referencesOnRequest'] as bool? ?? true,
    referencesNote:
        json['referencesNote'] as String? ??
        'Names, contacts and emails available on request',
  );
}
