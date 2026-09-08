import 'package:uuid/uuid.dart';

import '../models/contact_info.dart';
import '../models/document.dart';
import '../models/letter.dart';
import '../models/resume.dart';

/// Placeholder resume and letters used to populate the app on first launch.
///
/// This is deliberately generic sample content ("Alex Doe" at fictional
/// companies). Replace it in the app's editors, or edit this file, to make it
/// your own.
class SeedData {
  static const _uuid = Uuid();

  static const contact = ContactInfo(
    name: 'Alex Doe',
    title: 'Software Engineer',
    portfolioUrl: 'https://alex-doe.example.com',
    phone: '+1 555 0100',
    email: 'alex.doe@example.com',
    githubUrl: 'https://github.com/example',
    githubLabel: 'example',
    linkedinUrl: 'https://linkedin.com/in/example',
    linkedinLabel: 'Alex Doe',
  );

  static ResumeData resume() => ResumeData(
    contact: contact,
    summary:
        'Full-stack software engineer with a Bachelor of Science in Computer '
        'Science and a track record of taking production systems from design to '
        'deployment. Comfortable across the stack — REST APIs, React/Next.js, '
        'Python, Kotlin (Android), Java/Spring Boot — and extending into '
        'infrastructure and automation with Docker, Linux, and CI/CD. Has '
        'independently led production releases including a customer-facing '
        'billing platform and a modular reporting suite, and built internal '
        'tooling now used team-wide. Experience spans fintech, embedded/ML '
        'systems, and web platforms, with a bias for clean, maintainable, '
        'user-centric software.',
    experience: [
      ExperienceEntry(
        role: 'Software Engineer',
        organization: 'Acme Corp',
        startDate: 'Oct 2025',
        endDate: 'Present',
        bullets: [
          'Led development of a customer-facing billing dashboard used by '
              '10k+ monthly users.',
          'Shipped 15+ production web and mobile reports, resolving sync, '
              'validation, and data-integrity bugs.',
          'Built an internal support tool (UI, API, auth) and integrated it '
              'with the existing notification pipeline.',
          'Deployed service instances and background jobs for multiple '
              'internal projects.',
          'Migrated production infrastructure between cloud providers, '
              'including TLS setup and data verification.',
          'Automated deployments and built CI/CD workflows using Docker and '
              'GitHub Actions.',
          'Designed and built a documentation site now used team-wide.',
        ],
      ),
      ExperienceEntry(
        role: 'Associate Software Engineer',
        organization: 'Globex Corporation',
        startDate: 'Jan 2025',
        endDate: 'Sept 2025',
        bullets: [
          'Contributed to development and testing of an Android and web '
              'application suite.',
          'Built and debugged reporting modules, messaging workflows, and '
              'data-validation logic.',
          'Configured and tested a local integration server for end-to-end '
              'testing.',
          'Set up devices, credentials, and local development environments for '
              'the QA team.',
          'Debugged offline sync, scheduling, and reporting inconsistencies.',
          'Supported releases, user training, and technical support.',
        ],
      ),
      ExperienceEntry(
        role: 'Software Engineering Intern',
        organization: 'Initech',
        startDate: 'June 2023',
        endDate: 'Sept 2023',
        bullets: [
          'Learned core machine learning concepts, including data preprocessing '
              'and model evaluation.',
          'Prototyped a smart irrigation controller in Python and TensorFlow to '
              'optimize water usage.',
          'Integrated sensor data into an embedded system for real-time '
              'decision-making.',
          'Gained practical experience in embedded systems, networking, Python, '
              'and machine learning.',
        ],
      ),
      ExperienceEntry(
        role: 'Data Engineering Intern',
        organization: 'Umbrella Systems',
        startDate: 'August 2024',
        endDate: 'Oct 2024',
        bullets: [
          'Analyzed project data and produced summaries that supported team '
              'decision-making.',
          'Cleaned and transformed raw datasets to ensure data quality for '
              'downstream analysis.',
          'Built backend services in JavaScript, improving server performance '
              'and scalability.',
          'Designed REST APIs and implemented secure database integrations.',
        ],
      ),
      ExperienceEntry(
        role: 'Frontend Developer Intern',
        organization: 'Hooli',
        startDate: 'June 2022',
        endDate: 'Sept 2022',
        bullets: [
          'Built UI components for a school management system using React.',
          'Implemented interactive features that improved usability and '
              'performance.',
          'Collaborated with the team to optimize frontend code and rendering '
              'performance.',
          'Authored and managed product content to improve accessibility and '
              'clarity for end users.',
        ],
      ),
    ],
    skills: [
      SkillCategory(
        label: 'Programming Languages',
        items: ['Java', 'Kotlin', 'Python', 'JavaScript', 'TypeScript', 'SQL'],
      ),
      SkillCategory(
        label: 'Frontend',
        items: ['React.js', 'Next.js', 'Bootstrap', 'Tailwind CSS'],
      ),
      SkillCategory(
        label: 'Backend',
        items: ['Django', 'Spring Boot', 'Express.js', 'FastAPI'],
      ),
      SkillCategory(
        label: 'Mobile App Development',
        items: ['Kotlin', 'Java', 'Flutter'],
      ),
      SkillCategory(
        label: 'Databases',
        items: ['MySQL', 'PostgreSQL', 'MongoDB'],
      ),
      SkillCategory(
        label: 'DevOps & Infrastructure',
        items: [
          'Docker',
          'GitHub Actions (CI/CD)',
          'Linux',
          'AWS',
          'On-prem Deployments',
        ],
      ),
      SkillCategory(
        label: 'Tools',
        items: [
          'Git',
          'GitHub',
          'Figma',
          'Office Suite',
          'Design tools',
        ],
      ),
      SkillCategory(
        label: 'Practices',
        items: [
          'REST API design',
          'Automated testing',
          'Code review',
          'Agile / Scrum',
          'Technical writing',
        ],
      ),
    ],
    softSkills: [
      'Problem-Solving',
      'Adaptability',
      'Communication',
      'Teamwork',
      'Time Management',
      'Quick Learner',
    ],
    education: [
      EducationEntry(
        qualification: 'Bachelor of Science in Computer Science',
        institution: 'State University',
      ),
      EducationEntry(
        qualification: 'High School Diploma',
        institution: 'Central High School',
      ),
      EducationEntry(
        qualification: 'Certificate in Web Development',
        institution: 'Online Learning Platform',
      ),
    ],
    projects: [
      ProjectEntry(
        name: 'Text-to-Speech Audio Generator',
        tech: 'Python, FastAPI, TTS, sox',
        description:
            'Built a web tool that generates 8kHz mono MP3 voice prompts from '
            'text across multiple TTS backends, supporting several languages. '
            'Designed single and batch CSV generation workflows with live '
            'progress via Server-Sent Events, a REST API, and a one-shot '
            'installer for local model setup.',
      ),
      ProjectEntry(
        name: 'Inventory Management System',
        tech: 'Kotlin, Spring Boot, PostgreSQL',
        description:
            'Developed and supported inventory workflows, reporting modules, '
            'and third-party integrations. Fixed production bugs, improved data '
            'accuracy, deployed updates to staging and production, and trained '
            'operations staff across multiple sites.',
      ),
      ProjectEntry(
        name: 'Voice-Controlled Wheelchair',
        tech: 'Python, Embedded Systems, TensorFlow',
        description:
            'Prototyped a voice-activated wheelchair system using speech '
            'recognition, enabling hands-free control for users with physical '
            'impairments — significantly improving accessibility.',
      ),
    ],
    references: [],
    referencesOnRequest: true,
    referencesNote: 'Names, contacts and emails available on request',
  );

  static LetterData coverLetter() => LetterData(
    contact: contact,
    kind: LetterKind.cover,
    recipientDept: 'Human Resources Department',
    companyName: '{{company}}',
    companyAddress: '123 Example Street, Springfield.',
    salutation: 'Dear Hiring Manager,',
    body: [
      'I am writing to express my interest in the {{position}} at {{company}}. '
          'With a Bachelor of Science in Computer Science and a solid foundation '
          'in software development, I am excited about the opportunity to '
          'contribute to your team.',
      'During my studies and internships, I have gained experience in '
          'programming languages such as Python and JavaScript. My strong '
          'foundation in object-oriented programming and hands-on experience in '
          'application design and testing align well with the requirements of '
          'this role.',
      'I have successfully collaborated with teams to develop and maintain '
          'software applications, ensuring their smooth operation and high '
          'performance. My familiarity with databases and SQL has enabled me to '
          'manage and manipulate data efficiently across a range of projects.',
      'I am a highly motivated individual with excellent problem-solving and '
          'analytical skills. My passion for technology and continuous learning '
          'drives me to stay updated with the latest industry trends and best '
          'practices. I am confident that my technical abilities, dedication, and '
          'collaborative nature will make me a valuable asset to the {{company}} '
          'team.',
      'Thank you for considering my application. I have attached my resume for '
          'your review and would welcome the opportunity to discuss my '
          'qualifications further in an interview.',
    ],
    closing: 'Sincerely,',
    signatureName: 'Alex Doe',
    placeholders: {'position': '', 'company': ''},
  );

  static LetterData applicationLetter() => LetterData(
    contact: contact,
    kind: LetterKind.application,
    recipientDept: 'Human Resources Department',
    companyName: '{{company}}',
    companyAddress: '123 Example Street, Springfield.',
    salutation: 'Dear Hiring Manager,',
    body: [
      'I am writing to express my keen interest in the {{position}} position at '
          '{{company}}. As a graduate with a Bachelor of Science in Computer '
          'Science, I possess a strong foundation in programming languages, web '
          'development frameworks, and a passion for applying technology to '
          'solve real-world problems.',
      'My studies and internship experiences have equipped me with a diverse '
          'skillset. I am proficient in Python (including Django and '
          'scikit-learn) and JavaScript (including React.js). This foundation '
          'extends to hardware experience through embedded systems, and I am '
          'comfortable with tools like Git, Linux, and various design software.',
      'My internships provided valuable hands-on experience, particularly in '
          'machine learning and data science. I prototyped a smart irrigation '
          'system using Python and TensorFlow, which optimised irrigation based '
          'on real-time sensor data. I also developed user interfaces for a '
          'school management system using React.js, demonstrating my ability to '
          'collaborate effectively on projects that improve user experience and '
          'functionality.',
      'I am a highly motivated individual with a strong work ethic and a thirst '
          'for continuous learning. I am eager to contribute my skills and '
          'adaptability to a dynamic and challenging environment at {{company}}. '
          'I am confident that my technical abilities, problem-solving skills, '
          'and collaborative nature will make me a valuable asset to your team.',
      'Thank you for your time and consideration. I have attached my resume for '
          'your review and welcome the opportunity to discuss my qualifications '
          'further in an interview.',
    ],
    closing: 'Sincerely,',
    signatureName: 'Alex Doe',
    placeholders: {'position': '', 'company': ''},
  );

  static List<GeneratedDocument> initialDocuments() {
    final now = DateTime.now();
    return [
      GeneratedDocument(
        id: _uuid.v4(),
        type: DocumentType.resume,
        title: 'My Resume',
        updatedAt: now,
        resume: resume(),
      ),
      GeneratedDocument(
        id: _uuid.v4(),
        type: DocumentType.coverLetter,
        title: 'Cover Letter',
        updatedAt: now.subtract(const Duration(minutes: 1)),
        letter: coverLetter(),
      ),
      GeneratedDocument(
        id: _uuid.v4(),
        type: DocumentType.applicationLetter,
        title: 'Application Letter',
        updatedAt: now.subtract(const Duration(minutes: 2)),
        letter: applicationLetter(),
      ),
    ];
  }
}
