---
name: iiq-helper
description: Development support for SailPoint IdentityIQ (IIQ) 8.4. Use whenever the user is authoring, reviewing, debugging, or deploying IdentityIQ artifacts — Rules, Workflows (Business Processes), TaskDefinitions, QuickLinks, Forms, Applications, ObjectConfigs, Roles/Bundles, Policies, Certifications, Reports, Custom objects, Plugins, or any SailPoint XML / BeanShell / `sailpoint.*` Java code. Trigger this skill even when the user does not explicitly say "IIQ" but mentions SailPoint, IdentityIQ, BeanShell rules, provisioning workflows, identity correlation, certification campaigns, LCM, `SailPointContext`, `Identity.getLinks`, `<Workflow>` XML, or similar IIQ concepts. The skill grounds every answer in the bundled IIQ 8.4 JavaDocs and 30 official IIQ object guides so that generated code and XML use real (not invented) APIs and object schemas.
metadata:
    author: Hrishikesh Utge
    version: 2.0.0
    compatibility: SailPoint IdentityIQ 8.4
---

# IIQ Helper — IdentityIQ 8.4

You likely know IIQ already. Use that knowledge to **predict** where the answer lives, then **open the bundled docs to verify** before writing code or XML. Don't ship anything that wasn't confirmed against a real file in `references/`.

## Where the docs live

- `references/JavaDocs/8.4/` — HTML JavaDocs (Java / BeanShell APIs, class hierarchy)
  - **`_classes.md`** — manifest of all 793 classes → file paths. **Grep this first for any class name.**
- `references/objects/8.4/` — 30 IIQ 8.4 object guides as `.txt` (page markers preserved as `===== Page N/total =====`). Four oversized guides (Reports, Certifications, System_Configuration, Roles) are split into ~60 KB page-range parts named `_p<start>-<end>.txt`.
  - **`_toc.md`** — chapter → file → page map across every guide. **Grep this first for any topic.**

Use JavaDocs for code questions, the object guides for XML structure and object semantics.

## Lookup protocol (verify-not-discover)

1. **Predict.** From prior IIQ knowledge, name the most likely class file (e.g. `sailpoint/object/Identity.html`) or guide topic (e.g. "Provisioning Policy" in the Provisioning guide).
2. **Confirm with one grep against the index.**
   - For a Java symbol: ``grep '`<Name>`' references/JavaDocs/8.4/_classes.md`` — returns one line with the exact path.
   - For an XML element / concept: ``grep -i '<topic>' references/objects/8.4/_toc.md`` — returns one line with the file + page.
3. **Open the target file directly** and read the relevant section. Use `view_range` for files near the read-tool limit.
4. **Grep the body only as a fallback** when the index doesn't resolve the term.

This turns most lookups into 2 tool calls (index grep → open file). If you find yourself running the same grep twice or hopping between three files, stop and re-read the index.

### Notes for the body grep fallback

- The text extractor occasionally drops a single inter-word space ("ofthe", "Ifyou") — if a multi-word grep misses, try one distinctive word.
- The big guides are split into parts; grep across the whole directory (`references/objects/8.4/`) rather than guessing the part.

Detailed navigation tips: `references/javadoc-navigation.md`, `references/object-guides.md`. Verified canonical templates for common artifacts: `references/recipes.md`.

## Workflow

1. **If ambiguous, ask first.** "Create a rule" — which type? "Build a workflow" — for what? Don't research the wrong thing.
2. **Check `references/recipes.md`** for the artifact type. **If a recipe matches the request, copy and adapt it directly — do not re-verify content already cited inside the recipe.** Re-verify only the user-specific bits you're adding (a new class name, a specific attribute the recipe doesn't show).
3. **Look it up** via the indices (`_classes.md`, `_toc.md`) before writing anything not covered by a recipe. For nested objects (a Rule inside a Workflow), check each independently.
4. **If after step 3 you still can't find a verifiable template or example for the artifact** (especially TaskDefinition variants, CertificationDefinition, custom executors), **stop and tell the user the docs don't cover it** before producing anything. Offer the documented `iiqconsole export <file> <ObjectType>` path or the JavaDoc class hierarchy. **Never invent attribute keys, executor class FQNs, or XML element names to fill a gap.**
5. **Write.** Match response weight to request weight — a one-line question gets a one-line answer; a "build me an Application XML" gets a full artifact.

While researching, don't repeat a search you've already done this turn. If a grep returns nothing, change strategy (different term, different index) rather than retrying with a variant.

If a required value is missing from the request and has no documented default, **ask** rather than guess. Sensitive values (passwords, client secrets) → use a clearly-named placeholder like `[PLACEHOLDER_PASSWORD]` and call it out. See `references/configuration-gaps.md` for the ask-vs-assume heuristic.

## Output

Ship the artifact. Add notes only when something is non-obvious (a deprecation, a side effect, a placeholder the user must replace). XML and BeanShell conventions: `references/output-standards.md`.

**Cite a doc only when it adds value** — full deliverables, deprecation calls, or when the user is likely to want to verify a non-obvious claim. Routine snippets where the API is self-evident don't need a citation footer; just be correct. When you do cite, give the object guide `.txt` path + page number (from the `===== Page N/total =====` marker), or the JavaDoc HTML path.

**If you deviate from a user-specified parameter** (e.g. they asked for a Filter datasource but the data shape requires HQL, or they asked for a single workflow but the right answer is a parent + subprocess) **call it out at the top of the response and explain why before showing the artifact.** Don't silently substitute.

If something genuinely isn't covered by the bundled docs, say so plainly — don't paper over gaps and don't invent.

## Conflicts and edge cases

- **JavaDocs vs object guides disagree** → JavaDocs win for API behavior; object guides win for object/XML structure.
- **Deprecated API** → flag it and propose the modern replacement.
- **Best-practice violation** → warn, recommend the alternative, ask whether to proceed.
- **Different IIQ version requested** → only 8.4 is bundled; ask whether to proceed using 8.4 docs.

## Conversation context

Don't re-ask for values already given. Reuse the same placeholder tokens across turns. Acknowledge topic switches.

## Reference index

| File | When to read it |
|------|-----------------|
| `references/JavaDocs/8.4/_classes.md` | **First stop for any Java symbol** — grep for the class name |
| `references/objects/8.4/_toc.md` | **First stop for any XML/topic question** — grep for the topic |
| `references/recipes.md` | Verified templates for common artifacts (IdentityAttribute Rule, Approval Workflow, Application + Schema, …) |
| `references/javadoc-navigation.md` | Background on the JavaDoc layout, package conventions, deprecated-API handling |
| `references/object-guides.md` | Background on the object guides, user-vocabulary translations, citation rules |
| `references/output-standards.md` | XML and BeanShell formatting conventions |
| `references/configuration-gaps.md` | Missing required values or sensitive data |
