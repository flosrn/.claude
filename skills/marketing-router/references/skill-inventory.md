# Marketing Skills — Full Inventory

Source: `coreyhaines31/marketingskills` plugin

All skills check for `.claude/product-marketing-context.md` before asking questions.

---

## 📝 Copy & Content

### copywriting
**When:** Write or rewrite marketing copy for any page — homepage, landing, pricing, feature, about, product pages.
**Triggers:** "write copy for," "improve this copy," "rewrite this page," "marketing copy," "headline help," "CTA copy"
**Cross-ref:** For email copy → `email-sequence`. For popup copy → `popup-cro`.
**Produces:** Page copy with headlines, CTAs, sections, social proof framing

### copy-editing
**When:** Edit, review, or improve existing marketing copy through systematic editing passes.
**Triggers:** "edit this copy," "review my copy," "copy feedback," "proofread," "polish this," "make this better," "copy sweep"
**Method:** Multiple focused passes (clarity, persuasion, voice, grammar)
**Cross-ref:** Different from `copywriting` — this improves existing copy, doesn't write from scratch

### content-strategy
**When:** Plan what content to create, decide topics, build content roadmap.
**Triggers:** "content strategy," "what should I write about," "content ideas," "blog strategy," "topic clusters," "content planning"
**Cross-ref:** For writing individual pieces → `copywriting`. For SEO audits → `seo-audit`.
**Produces:** Content roadmap, topic clusters, editorial calendar

### social-content
**When:** Create, schedule, or optimize social media content for any platform.
**Triggers:** "LinkedIn post," "Twitter thread," "social media," "content calendar," "social scheduling," "engagement," "viral content"
**Platforms:** LinkedIn, Twitter/X, Instagram, TikTok, Facebook
**Produces:** Platform-specific posts, content calendar, repurposing strategy

---

## 📈 CRO (Conversion Rate Optimization)

### page-cro
**When:** Optimize conversions on any marketing page — homepage, landing, pricing, feature, blog.
**Triggers:** "CRO," "conversion rate optimization," "this page isn't converting," "improve conversions," "why isn't this page working"
**Cross-ref:** For signup/registration → `signup-flow-cro`. For post-signup → `onboarding-cro`. For forms → `form-cro`. For popups → `popup-cro`.
**Produces:** Page audit, prioritized recommendations, experiment ideas

### signup-flow-cro
**When:** Optimize signup, registration, account creation, or trial activation flows.
**Triggers:** "signup conversions," "registration friction," "signup form optimization," "free trial signup," "reduce signup dropoff"
**Cross-ref:** For post-signup → `onboarding-cro`. For lead capture forms → `form-cro`.
**Covers:** Free trial, freemium, paid, waitlist, B2B vs B2C flows

### onboarding-cro
**When:** Optimize post-signup onboarding, activation, first-run experience, time-to-value.
**Triggers:** "onboarding flow," "activation rate," "user activation," "first-run experience," "empty states," "onboarding checklist," "aha moment"
**Cross-ref:** For signup forms → `signup-flow-cro`. For email sequences → `email-sequence`.
**Focus:** Getting users to "aha moment" as fast as possible

### form-cro
**When:** Optimize any form that is NOT signup/registration — lead capture, contact, demo, application, survey, checkout.
**Triggers:** "form optimization," "lead form conversions," "form friction," "form fields," "form completion rate," "contact form"
**Cross-ref:** For signup forms → `signup-flow-cro`. For popups with forms → `popup-cro`.

### popup-cro
**When:** Create or optimize popups, modals, overlays, slide-ins, banners.
**Triggers:** "exit intent," "popup conversions," "modal optimization," "lead capture popup," "email popup," "announcement banner"
**Cross-ref:** For forms outside popups → `form-cro`. For page-level CRO → `page-cro`.

### paywall-upgrade-cro
**When:** Create/optimize in-app paywalls, upgrade screens, upsell modals, feature gates.
**Triggers:** "paywall," "upgrade screen," "upsell," "feature gate," "convert free to paid," "freemium conversion," "trial expiration screen," "limit reached"
**Cross-ref:** Distinct from public pricing pages (→ `page-cro`). Focuses on in-product upgrade moments.

### ab-test-setup
**When:** Plan, design, or implement an A/B test or experiment.
**Triggers:** "A/B test," "split test," "experiment," "test this change," "variant copy," "multivariate test," "hypothesis"
**Cross-ref:** For tracking implementation → `analytics-tracking`.
**Produces:** Hypothesis, test design, sample size calculations, success criteria

---

## 🔍 SEO & Search

### seo-audit
**When:** Audit, review, or diagnose SEO issues on a site.
**Triggers:** "SEO audit," "technical SEO," "why am I not ranking," "SEO issues," "on-page SEO," "meta tags review," "SEO health check"
**Cross-ref:** For building pages at scale → `programmatic-seo`. For structured data → `schema-markup`.
**Includes:** AI writing detection patterns, AEO/GEO (answer engine optimization)

### programmatic-seo
**When:** Create SEO-driven pages at scale using templates and data.
**Triggers:** "programmatic SEO," "template pages," "pages at scale," "directory pages," "location pages," "[keyword] + [city]," "integration pages"
**Cross-ref:** For auditing SEO issues → `seo-audit`. For adding schema → `schema-markup`.

### schema-markup
**When:** Add, fix, or optimize schema markup / structured data (JSON-LD).
**Triggers:** "schema markup," "structured data," "JSON-LD," "rich snippets," "schema.org," "FAQ schema," "product schema"
**Cross-ref:** For broader SEO → `seo-audit`.

### competitor-alternatives
**When:** Create competitor comparison or "alternative to" pages.
**Triggers:** "alternative page," "vs page," "competitor comparison," "[Product] vs [Product]," "[Product] alternative"
**Formats:** Singular alt, plural alts, you vs competitor, competitor vs competitor
**Produces:** SEO-optimized comparison pages with modular content architecture

---

## 💰 Strategy & Pricing

### pricing-strategy
**When:** Pricing decisions, packaging, monetization strategy.
**Triggers:** "pricing," "pricing tiers," "freemium," "free trial," "packaging," "price increase," "value metric," "Van Westendorp," "willingness to pay"
**Produces:** Tier structure, value metrics, pricing research methodology

### launch-strategy
**When:** Plan a product launch, feature announcement, or release.
**Triggers:** "launch," "Product Hunt," "feature release," "announcement," "go-to-market," "beta launch," "early access," "waitlist"
**Philosophy:** Launch isn't one moment — every feature is a launch opportunity
**Produces:** Phased launch plan, channel strategy, momentum playbook

### marketing-ideas
**When:** Need marketing inspiration or strategies.
**Triggers:** "marketing ideas," "growth ideas," "how to market," "marketing strategies," "marketing tactics," "ways to promote"
**Contains:** 139 proven marketing approaches organized by category

### marketing-psychology
**When:** Apply psychological principles or behavioral science to marketing.
**Triggers:** "psychology," "mental models," "cognitive bias," "persuasion," "behavioral science," "why people buy"
**Contains:** 70+ mental models for marketing application
**Usage:** Best as a **supporting skill** alongside others — adds depth to copy, CRO, pricing decisions

### product-marketing-context
**When:** Create or update foundational product marketing context.
**Triggers:** "product context," "marketing context," "set up context," "positioning"
**Produces:** `.claude/product-marketing-context.md` — referenced by ALL other marketing skills
**Priority:** Run this FIRST if it doesn't exist yet. Saves repeating context every time.

---

## 📣 Acquisition & Growth

### paid-ads
**When:** Help with paid advertising campaigns on any platform.
**Triggers:** "PPC," "paid media," "ad copy," "ad creative," "ROAS," "CPA," "ad campaign," "retargeting," "audience targeting"
**Platforms:** Google Ads, Meta (Facebook/Instagram), LinkedIn, Twitter/X
**Produces:** Campaign strategy, ad copy, audience targeting, optimization plan

### referral-program
**When:** Create or optimize referral, affiliate, or word-of-mouth programs.
**Triggers:** "referral," "affiliate," "ambassador," "word of mouth," "viral loop," "refer a friend," "partner program"
**Produces:** Program design, incentive structure, growth optimization

### free-tool-strategy
**When:** Plan or build a free tool for marketing (engineering as marketing).
**Triggers:** "engineering as marketing," "free tool," "marketing tool," "calculator," "generator," "interactive tool," "lead gen tool"
**Bridges:** Engineering and marketing — great for technical founders

---

## 📊 Analytics

### analytics-tracking
**When:** Set up, improve, or audit analytics tracking and measurement.
**Triggers:** "set up tracking," "GA4," "Google Analytics," "conversion tracking," "event tracking," "UTM parameters," "tag manager," "GTM"
**Cross-ref:** For A/B test measurement → `ab-test-setup`.
**Produces:** Tracking plan, event library, implementation guide

---

## 📧 Email

### email-sequence
**When:** Create or optimize email sequences, drip campaigns, lifecycle emails.
**Triggers:** "email sequence," "drip campaign," "nurture sequence," "onboarding emails," "welcome sequence," "re-engagement emails"
**Cross-ref:** For in-app onboarding → `onboarding-cro`.
**Types:** Welcome, nurture, re-engagement, post-purchase, event-based, educational, sales

---

## 🔧 Tool Integrations (30+)

The plugin includes integration guides for connecting marketing tools:

**Analytics:** GA4, Adobe Analytics, Amplitude, Mixpanel, PostHog, Segment
**Ads:** Google Ads, Meta Ads, LinkedIn Ads, TikTok Ads
**SEO:** Ahrefs, Semrush, Google Search Console
**Email:** Mailchimp, Resend, SendGrid, Customer.io, Kit
**CRM:** HubSpot, Salesforce
**Referral:** Rewardful, Tolt, Mention Me, Dub.co
**Commerce:** Stripe, Shopify
**Web:** Webflow, WordPress
**Automation:** Zapier

Located in: `tools/integrations/` directory of the plugin
