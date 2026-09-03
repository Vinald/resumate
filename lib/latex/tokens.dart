/// Catalogue of `<<TOKEN>>` placeholders understood by [LatexEngine],
/// shown in the LaTeX editor's reference panel.
class TokenDoc {
  const TokenDoc(this.token, this.description);
  final String token;
  final String description;
}

const resumeTokens = <TokenDoc>[
  TokenDoc('<<ACCENT_RGB>>', 'Accent colour as "R, G, B" (from Settings)'),
  TokenDoc('<<NAME>>', 'Full name'),
  TokenDoc('<<TITLE>>', 'Title / headline'),
  TokenDoc('<<PORTFOLIO_URL>>', 'Portfolio link'),
  TokenDoc('<<PHONE>>', 'Phone number'),
  TokenDoc('<<EMAIL>>', 'Email address'),
  TokenDoc('<<GITHUB_URL>>', 'GitHub profile URL'),
  TokenDoc('<<GITHUB_LABEL>>', 'GitHub link text'),
  TokenDoc('<<LINKEDIN_URL>>', 'LinkedIn profile URL'),
  TokenDoc('<<LINKEDIN_LABEL>>', 'LinkedIn link text'),
  TokenDoc('<<SUMMARY>>', 'Professional summary paragraph'),
  TokenDoc('<<EXPERIENCE_ITEMS>>', 'Generated employment blocks with tick bullets'),
  TokenDoc('<<SKILLS_ITEMS>>', 'Generated "Label: items" skill lines'),
  TokenDoc('<<SOFT_SKILLS>>', 'Soft skills separated by wide spaces'),
  TokenDoc('<<EDUCATION_ITEMS>>', 'Generated education entries'),
  TokenDoc('<<PROJECT_ITEMS>>', 'Generated project entries'),
  TokenDoc('<<REFERENCES>>', 'References list or on-request note'),
];

const letterTokens = <TokenDoc>[
  TokenDoc('<<ACCENT_RGB>>', 'Accent colour as "R, G, B" (from Settings)'),
  TokenDoc('<<NAME>>', 'Full name'),
  TokenDoc('<<TITLE>>', 'Title / headline'),
  TokenDoc('<<PORTFOLIO_URL>>', 'Portfolio link'),
  TokenDoc('<<PHONE>>', 'Phone number'),
  TokenDoc('<<EMAIL>>', 'Email address'),
  TokenDoc('<<GITHUB_URL>>', 'GitHub profile URL'),
  TokenDoc('<<GITHUB_LABEL>>', 'GitHub link text'),
  TokenDoc('<<LINKEDIN_URL>>', 'LinkedIn profile URL'),
  TokenDoc('<<LINKEDIN_LABEL>>', 'LinkedIn link text'),
  TokenDoc('<<DATE>>', r'Letter date, or \today when blank'),
  TokenDoc('<<RECIPIENT_DEPT>>', 'Recipient department line'),
  TokenDoc('<<COMPANY_NAME>>', 'Company name (placeholders resolved)'),
  TokenDoc('<<COMPANY_ADDRESS>>', 'Company address (placeholders resolved)'),
  TokenDoc('<<SALUTATION>>', 'Greeting line'),
  TokenDoc('<<BODY>>', 'Body paragraphs (placeholders resolved)'),
  TokenDoc('<<CLOSING>>', 'Closing line, e.g. Sincerely,'),
  TokenDoc('<<SIGNATURE_NAME>>', 'Typed name under the signature'),
];
