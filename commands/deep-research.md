---
description: "Advanced autonomous web research agent with interactive clarification, iterative analysis, and comprehensive report generation"
allowed-tools:
  [
    "WebSearch(*)",
    "WebFetch(*)",
    "Write(*)",
    "Read(*)",
    "Edit(*)",
    "MultiEdit(*)",
  ]
---

# Claude Command: Deep Research

Advanced autonomous web research agent that conducts comprehensive, multi-source investigations with interactive query refinement, iterative analysis, and professional report generation.

## Usage

```
/deep-research "topic or description"         # Start interactive research session
/deep-research --quick "topic"                # Fast research (10-15 sources)
/deep-research --comprehensive "topic"        # Full research (50+ sources)
/deep-research --academic "topic"             # Academic-focused research
/deep-research --market "topic"               # Market analysis research
/deep-research --technical "topic"            # Technical deep-dive research
```

## Research Methodology

### Phase 1: Interactive Query Refinement

Before starting the research, the agent engages in a clarification dialogue to optimize research parameters:

#### Core Clarification Questions

1. **Research Scope & Depth**

   - "What specific aspects of [topic] are most important to you?"
   - "Are you looking for recent developments (last 6 months) or comprehensive historical analysis?"
   - "What level of technical detail do you need: overview, intermediate, or expert-level?"

2. **Information Sources & Perspective**

   - "Do you prefer academic sources, industry reports, user reviews, or a balanced mix?"
   - "Are there specific regions, markets, or demographics you want to focus on?"
   - "Should I include opposing viewpoints or focus on consensus information?"

3. **Output Format & Use Case**

   - "How will you use this research: decision-making, presentation, academic work, or general knowledge?"
   - "Do you need specific data formats: statistics, case studies, expert quotes, or technical specifications?"
   - "Are there any topics or sources you want me to avoid or prioritize?"

4. **Research Constraints & Priorities**
   - "What's your timeline: do you need preliminary findings quickly or can I do exhaustive research?"
   - "Are there specific questions you need answered or problems you're trying to solve?"
   - "Should I focus on credible mainstream sources or include emerging/alternative perspectives?"

### Phase 2: Autonomous Research Execution

#### Multi-Stage Search Strategy

```
Research Phases:
├── Initial Discovery (5-10 searches)
│   ├── Broad topic exploration
│   ├── Key terminology identification
│   └── Source credibility assessment
│
├── Deep Analysis (15-25 searches)
│   ├── Specific aspect investigation
│   ├── Cross-reference validation
│   └── Expert opinion gathering
│
├── Specialized Investigation (10-20 searches)
│   ├── Recent developments tracking
│   ├── Niche source exploration
│   └── Contradiction resolution
│
└── Verification & Synthesis (5-10 searches)
    ├── Fact-checking critical claims
    ├── Source reliability confirmation
    └── Gap identification and filling
```

#### Intelligent Source Diversification

- **Academic Sources**: Research papers, journals, institutional reports
- **Industry Sources**: Company reports, analyst studies, trade publications
- **News Sources**: Recent developments, breaking news, trend analysis
- **Community Sources**: Reddit discussions, forums, expert blogs
- **Official Sources**: Government data, regulatory information, standards
- **Multimedia Sources**: Video content, podcasts, webinars when relevant

### Phase 3: Iterative Report Building

#### Real-Time Report Updates

The research agent creates and continuously updates a comprehensive report file with:

```markdown
# Deep Research Report: [Topic]

_Generated on [Date] | Research Duration: [Time] | Sources Analyzed: [Count]_

## Executive Summary

[Real-time synthesis of key findings]

## Research Methodology

- **Scope**: [Defined research parameters]
- **Sources**: [Types and count of sources consulted]
- **Time Range**: [Period covered by research]
- **Limitations**: [Acknowledged constraints]

## Key Findings

### [Finding 1: Title]

[Detailed analysis with source citations]

### [Finding 2: Title]

[Detailed analysis with source citations]

## Detailed Analysis

[Comprehensive breakdown by subtopic]

## Source Analysis

[Credibility assessment and bias evaluation]

## Conclusions & Implications

[Synthesis and forward-looking insights]

## Research Timeline

[Chronological log of research activities]
```

#### Iterative Enhancement Process

1. **Initial Framework**: Creates report structure based on clarification
2. **Progressive Enrichment**: Adds findings as research progresses
3. **Cross-Validation**: Verifies claims across multiple sources
4. **Synthesis Integration**: Connects disparate information into insights
5. **Final Refinement**: Polishes and structures final report

## Advanced Research Techniques

### Semantic Search Optimization

- **Context-Aware Queries**: Adapts search terms based on discovered information
- **Multi-Language Support**: Searches in relevant languages when appropriate
- **Technical Term Recognition**: Identifies and incorporates domain-specific terminology
- **Trend Analysis**: Tracks information evolution over time

### Source Credibility Assessment

```
Credibility Scoring System:
├── Authority (25%): Author expertise, institutional affiliation
├── Accuracy (25%): Fact-checking, citation quality
├── Objectivity (20%): Bias assessment, conflict of interest
├── Currency (15%): Publication date, information freshness
├── Coverage (15%): Comprehensiveness, depth of analysis
```

### Information Synthesis Methods

- **Triangulation**: Validates information across multiple independent sources
- **Pattern Recognition**: Identifies recurring themes and contradictions
- **Gap Analysis**: Discovers missing information and research opportunities
- **Perspective Integration**: Balances different viewpoints and methodologies

## Specialized Research Modes

### Academic Research Mode

- **Peer-Review Focus**: Prioritizes scholarly articles and academic sources
- **Citation Tracking**: Follows citation networks for comprehensive coverage
- **Methodology Analysis**: Evaluates research methods and statistical significance
- **Literature Review**: Synthesizes existing academic discourse

### Market Analysis Mode

- **Competitive Intelligence**: Analyzes market players and positioning
- **Financial Analysis**: Incorporates financial data and performance metrics
- **Consumer Insights**: Gathers user feedback and market sentiment
- **Trend Forecasting**: Projects future market developments

### Technical Deep-Dive Mode

- **Specification Analysis**: Detailed technical documentation review
- **Performance Benchmarking**: Comparative analysis of technical metrics
- **Implementation Guidance**: Practical application and best practices
- **Expert Commentary**: Technical expert opinions and recommendations

## Quality Assurance Framework

### Multi-Source Verification

- **Fact Triangulation**: Every major claim verified across 3+ sources
- **Source Diversity**: Ensures multiple perspectives and methodologies
- **Temporal Validation**: Confirms information currency and relevance
- **Expert Validation**: Seeks authoritative sources for specialized topics

### Bias Mitigation Strategies

- **Source Balance**: Includes diverse viewpoints and methodologies
- **Transparency**: Clear attribution and source quality indicators
- **Limitation Disclosure**: Explicitly states research constraints
- **Update Capability**: Acknowledges when information may be incomplete

### Error Detection and Correction

- **Automated Checks**: Identifies potential inconsistencies or errors
- **Cross-Reference Validation**: Verifies claims against multiple sources
- **Expert Opinion Integration**: Incorporates authoritative perspectives
- **Continuous Refinement**: Updates findings as new information emerges

## Output Formats

### Standard Research Report

- Comprehensive markdown document with citations
- Executive summary for quick overview
- Detailed analysis with supporting evidence
- Actionable insights and recommendations

### Data-Rich Analysis

- Statistical summaries and trend analysis
- Comparative tables and metrics
- Visual data representation suggestions
- Quantitative insights and projections

### Decision-Support Brief

- Focused recommendations for specific decisions
- Risk assessment and mitigation strategies
- Implementation roadmap and timelines
- Success metrics and monitoring approaches

## Integration Capabilities

### Knowledge Management

- **Research Archive**: Builds searchable knowledge base
- **Cross-Research Linking**: Connects related research topics
- **Update Notifications**: Alerts for new relevant information
- **Collaboration Support**: Enables team research coordination

### Workflow Integration

- **Project Management**: Links research to specific projects
- **Decision Trees**: Maps research findings to decision points
- **Action Planning**: Translates insights into actionable steps
- **Follow-up Research**: Identifies areas for additional investigation

### Export and Sharing

- **Multiple Formats**: PDF, Word, HTML export options
- **Citation Management**: BibTeX and reference format export
- **Presentation Ready**: Key findings formatted for presentations
- **API Integration**: Structured data for system integration

## Options

- `--quick`: Fast research mode (10-15 sources, 5-10 minutes)
- `--comprehensive`: Exhaustive research (50+ sources, 20-30 minutes)
- `--academic`: Focus on scholarly and peer-reviewed sources
- `--market`: Emphasize market analysis and business intelligence
- `--technical`: Deep technical analysis and specifications
- `--recent`: Focus on information from last 6 months
- `--historical`: Include comprehensive historical analysis
- `--local <region>`: Focus on specific geographic region
- `--language <lang>`: Include sources in specified language
- `--expert-only`: Prioritize authoritative expert sources
- `--no-social`: Exclude social media and forum sources
- `--update <filename>`: Update existing research report
- `--format <type>`: Specify output format (markdown, pdf, json)

## Advanced Features

### AI-Powered Insights

- **Pattern Recognition**: Identifies trends and relationships in data
- **Predictive Analysis**: Projects future developments based on current trends
- **Anomaly Detection**: Highlights unusual or contradictory information
- **Knowledge Synthesis**: Creates new insights from disparate information

### Continuous Learning

- **Research Optimization**: Improves methodology based on outcome quality
- **Source Quality Learning**: Develops better source selection over time
- **User Preference Adaptation**: Tailors approach to user needs and feedback
- **Domain Expertise Building**: Accumulates specialized knowledge in research areas

### Collaborative Research

- **Multi-Researcher Coordination**: Supports team research efforts
- **Research Handoffs**: Enables seamless continuation by other researchers
- **Peer Review Integration**: Incorporates feedback and validation processes
- **Knowledge Sharing**: Facilitates organization-wide research sharing

## Ethical Guidelines

### Information Integrity

- **Source Attribution**: Comprehensive citation and credit to original sources
- **Fact Verification**: Multiple-source confirmation for critical claims
- **Bias Acknowledgment**: Transparent disclosure of potential biases
- **Uncertainty Communication**: Clear indication of confidence levels

### Privacy and Respect

- **Data Privacy**: Respects privacy policies and data protection regulations
- **Copyright Compliance**: Adheres to fair use and copyright guidelines
- **Cultural Sensitivity**: Considers cultural context and sensitivities
- **Responsible Reporting**: Avoids amplification of harmful misinformation

## Success Metrics

### Research Quality Indicators

- **Source Diversity Score**: Measures breadth of source types and perspectives
- **Verification Rate**: Percentage of claims verified across multiple sources
- **Recency Score**: How current and up-to-date the information is
- **Depth Analysis**: Comprehensiveness of topic coverage

### User Satisfaction Metrics

- **Relevance Rating**: How well research addresses original query
- **Completeness Score**: Whether research answers intended questions
- **Actionability Index**: How useful findings are for intended purpose
- **Efficiency Measure**: Research quality relative to time invested

## Notes

- Operates autonomously after initial clarification phase
- Maintains transparent research methodology and source tracking
- Adapts research strategy based on findings and information quality
- Provides comprehensive citations and source credibility assessment
- Supports iterative refinement and follow-up research
- Scales from quick overviews to comprehensive academic-level analysis
- Respects intellectual property and fair use guidelines
- Maintains research audit trail for reproducibility and verification
