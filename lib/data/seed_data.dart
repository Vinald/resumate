import 'package:uuid/uuid.dart';

import '../models/contact_info.dart';
import '../models/document.dart';
import '../models/letter.dart';
import '../models/resume.dart';

/// Vinald's real resume and letters, used to populate the app on first launch.
class SeedData {
  static const _uuid = Uuid();

  static const contact = ContactInfo(
    name: 'OKIROR SAMUEL VINALD',
    title: 'Computer Engineer',
    portfolioUrl: 'https://vinald.github.io',
    phone: '+256 746178844',
    email: 'okiror1vinald@gmail.com',
    githubUrl: 'https://github.com/vinald',
    githubLabel: 'Vinald',
    linkedinUrl: 'https://linkedin.com/in/vinald12',
    linkedinLabel: 'Okiror Samuel Vinald',
  );

  static ResumeData resume() => ResumeData(
    contact: contact,
    summary:
        'Full-stack Software Engineer with a Bachelor of Science in Computer '
        'Engineering and a track record of taking production systems from design '
        'to deployment. Comfortable across the stack — FastAPI, React/Next.js, '
        'Python (Django), Kotlin (Android), Java/Spring Boot — and extending into '
        'infrastructure and automation with Docker, Linux, and CI/CD. Has '
        'independently led production releases including a multi-language '
        'call-flow system and a 15+ module reporting suite, and built a '
        'documentation platform now used team-wide. Experience spans health-tech, '
        'embedded/ML systems, and web platforms, with a builder\'s instinct for '
        'clean, maintainable, user-centric software and a continued interest in '
        'cybersecurity and applied AI tooling.',
    experience: [
      ExperienceEntry(
        role: 'Junior Software Developer',
        organization: 'Infectious Diseases Institute (IDI)',
        startDate: 'Oct 2025',
        endDate: 'Present',
        bullets: [
          'Led production deployment of a multi-language (English/Luganda) '
              'IVR-based call flow system.',
          'Shipped 15+ production web and mobile reports, resolving sync, '
              'validation, and data-integrity bugs.',
          'Built the HASH AI agent\'s PBX system (UI, API, auth) and integrated '
              'TTS/STT into its IVR/AGI pipeline, pushing audio to AWS S3.',
          'Deployed CFL instances, call flows, and audio generation for multiple '
              'client projects.',
          'Migrated production infrastructure from AWS to on-premise, including '
              'SSL integration and data verification.',
          'Automated deployments and built CI/CD workflows using Docker and '
              'GitHub Actions.',
          'Designed and built a GitHub Pages documentation platform now used '
              'team-wide.',
        ],
      ),
      ExperienceEntry(
        role: 'Graduate Software Developer',
        organization: 'Infectious Diseases Institute (IDI)',
        startDate: 'Jan 2025',
        endDate: 'Sept 2025',
        bullets: [
          'Contributed to development and testing of an Android and web '
              'application suite.',
          'Built and debugged reporting modules, messaging workflows, and '
              'data-validation logic.',
          'Installed, configured, and tested a local Asterisk server for '
              'SIP-based call handling.',
          'Set up devices, credentials, and local development environments for '
              'field teams.',
          'Debugged offline sync, scheduling, and reporting inconsistencies.',
          'Supported deployments, user training, and on-site technical support.',
        ],
      ),
      ExperienceEntry(
        role: 'Software Developer Intern',
        organization: 'NetLabs!UG',
        startDate: 'June 2023',
        endDate: 'Sept 2023',
        bullets: [
          'Learned core machine learning concepts, including data preprocessing '
              'and model evaluation.',
          'Designed a smart irrigation system using Python and TensorFlow to '
              'optimize water usage.',
          'Integrated sensor data into an embedded system for real-time '
              'decision-making.',
          'Acquired practical experience in embedded systems, networking, '
              'Python, and machine learning.',
        ],
      ),
      ExperienceEntry(
        role: 'Junior Software Developer Intern',
        organization: 'Zidio',
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
        role: 'Software Developer Intern',
        organization: 'EvoTech Solutions',
        startDate: 'June 2022',
        endDate: 'Sept 2022',
        bullets: [
          'Built UI components for a school management system using React.',
          'Implemented interactive features that improved usability and '
              'performance.',
          'Collaborated with the team to optimize frontend code and rendering '
              'performance.',
          'Authored and managed system content to improve accessibility and '
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
          'Microsoft Office Suite',
          'Adobe (Illustrator, Photoshop)',
        ],
      ),
      SkillCategory(
        label: 'Domain Systems',
        items: [
          'OpenMRS',
          'VxNAID',
          'Call for Life (CFL)',
          'Asterisk/PBX/SIP/AGI',
          'IVR Design',
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
        qualification: 'Bachelor of Science in Computer Engineering',
        institution: 'Makerere University, Kampala, Uganda',
      ),
      EducationEntry(
        qualification: 'Uganda Advanced Certificate of Education',
        institution: "St. Peter's College, Tororo",
      ),
      EducationEntry(
        qualification: 'Uganda Certificate of Education',
        institution: "St. Peter's College, Tororo",
      ),
    ],
    projects: [
      ProjectEntry(
        name: 'Asterisk Audio Generator',
        tech: 'Python, FastAPI, Kokoro TTS, sox, Sunbird',
        description:
            'Built a web tool that generates Asterisk-compatible 8kHz mono MP3 '
            'prompts from text across three TTS backends (Kokoro, Sunbird AI, '
            'edge-tts), supporting English, Luganda, and Swahili. Designed single '
            'and batch CSV generation workflows with live progress via '
            'Server-Sent Events, a REST API, and a one-shot installer for local '
            'model setup.',
      ),
      ProjectEntry(
        name: 'VxNAID — Vaccine & Immunization Management System',
        tech: 'Kotlin, OpenMRS',
        description:
            'Developed and supported immunization workflows, reporting modules, '
            'and IVR integrations. Fixed production bugs, improved data accuracy, '
            'deployed updates to staging and production, and trained health '
            'workers across multiple facilities.',
      ),
      ProjectEntry(
        name: 'Voice-Controlled Wheelchair',
        tech: 'Python, Embedded Systems, TensorFlow',
        description:
            'Engineered a voice-activated wheelchair system using speech '
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
    companyAddress: 'Kampala, Uganda.',
    salutation: 'Dear Hiring Manager,',
    body: [
      'I am writing to express my interest in the {{position}} at {{company}}. '
          'With a Bachelor of Science in Computer Engineering from Makerere '
          'University and a solid foundation in software development, I am excited '
          'about the opportunity to contribute to your team.',
      'During my academic career and internships, I have gained experience in '
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
    signatureName: 'OKIROR SAMUEL VINALD',
    placeholders: {'position': '', 'company': ''},
  );

  static LetterData applicationLetter() => LetterData(
    contact: contact,
    kind: LetterKind.application,
    recipientDept: 'Human Resources Department',
    companyName: '{{company}}',
    companyAddress: 'Kampala, Uganda.',
    salutation: 'Dear Hiring Manager,',
    body: [
      'I am writing to express my keen interest in the {{position}} position at '
          '{{company}}. As a graduate with a Bachelor of Science in Computer '
          'Engineering from Makerere University, I possess a strong foundation in '
          'programming languages, web development frameworks, and a passion for '
          'applying technology to solve real-world problems.',
      'My academic journey and internship experiences have equipped me with a '
          'diverse skillset. I am proficient in Python (including Django and '
          'scikit-learn) and JavaScript (including React.js). This foundation '
          'extends to hardware experience through embedded systems, and I am '
          'comfortable with tools like Git, Linux, and various design software.',
      'My internships provided valuable hands-on experience, particularly in '
          'machine learning and data science. I designed and implemented a smart '
          'irrigation system using Python and TensorFlow, which optimised '
          'irrigation based on real-time sensor data. I also developed user '
          'interfaces for a school management system using React.js, '
          'demonstrating my ability to collaborate effectively on projects that '
          'improve user experience and functionality.',
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
    signatureName: 'OKIROR SAMUEL VINALD',
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
