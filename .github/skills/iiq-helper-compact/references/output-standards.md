# Output Standards & Response Format

Apply these standards to every IIQ deliverable so the user can drop output straight into their environment with minimal cleanup.

## Response structure

Three response modes — pick one based on what the user actually asked for. See SKILL.md *Output format* for the decision rule.

### Deliverable mode — full 6 sections

Use when shipping a complete IIQ artifact (full Rule, Workflow, Application, Policy, Form, Task, Custom object, ...). Skip a section only if it would be empty.

1. **Documentation Reference** — Files consulted, with version-qualified paths. Examples:
   - `references/JavaDocs/8.4/sailpoint/object/Identity.html`
   - `references/objects/8.4/8.4_IdentityIQ_Application_Configuration.txt`
2. **Analysis** — Brief explanation of what is being built and why this approach was chosen.
3. **Code / Object Output** — The deliverable itself (XML, BeanShell, snippet, ...).
4. **Key Implementation Notes** — IIQ-specific gotchas, side effects, ordering constraints, transaction/commit considerations.
5. **Configuration Status** — Any placeholder values used, plus configurations still required from the user.
6. **Next Steps / Validation** — How to import, where to look in the UI/console, what to test, expected log output.

### Snippet mode — compact

Use for small targeted code/XML fragments (one method, one expression, an attribute fix). Keep it tight:

1. **Citation line** — one line, e.g. *"Per `references/JavaDocs/8.4/sailpoint/object/Identity.html`."*
2. **The snippet** — fenced code, inline comments only where they add real value
3. **One-line note** (optional) — a non-obvious gotcha, deprecation, or placeholder callout

No headers, no checklist sections.

### Q&A mode — conversational

Use for explanations, comparisons, and documentation lookups. Answer in prose with **inline citations** to the reference files. No section headers. Length matches the question.

### Mode applies to *response shape*, not to *research rigor*

The documentation-first principle, the warning labels, and the pre-delivery checklist below apply in all three modes. A snippet that cites a method that doesn't exist is worse than no snippet at all.

## Pre-delivery checklist

Run this checklist mentally before sending. If any item fails, fix or surface the problem rather than shipping silently.

- ✓ Every API method/class used was confirmed in the JavaDocs (cite the file).
- ✓ Every method signature (params, return type, exceptions) matches the documented signature.
- ✓ All mandatory XML attributes / object fields are present.
- ✓ Commonly used optional fields are included where they improve operability (descriptions, sensible defaults, flags).
- ✓ For nested objects, each nested component was researched against its own documentation.
- ✓ When multiple valid approaches existed, the chosen one is justified (or the user was asked to pick) with documented trade-offs.
- ✓ Any deprecated API encountered was flagged with `⚠️ DEPRECATED:` and a modern alternative offered.
- ✓ Placeholders are clearly named (`[PLACEHOLDER_*]` or `dummy-*-replace-me`) and listed in *Configuration Status*.
- ✓ A concrete validation step is provided.

## Code standards (BeanShell / Java)

- Use BeanShell/Java syntax for all in-IIQ code (Rules, scripts, library methods).
- Include explicit imports from `sailpoint.*` packages used.
- Naming: `camelCase` for methods/variables, `PascalCase` for classes, descriptive names.
- Add JavaDoc-style comments for methods/classes; inline comments for non-obvious IIQ behavior.
- Reference the JavaDocs in comments where it helps the reader, e.g.
  `// Based on JavaDocs: sailpoint.object.Identity.getManager()`
- Always handle declared checked exceptions explicitly (typically `GeneralException`).
- Prefer `SailPointContext` methods documented in the JavaDocs over reflection or undocumented internals.

## XML object standards

- Begin with the XML declaration and the documented DOCTYPE for the object type.
- Use 2-space indentation, pretty-printed.
- Include namespace declarations only when the documentation requires them.
- Add XML comments to explain non-obvious configuration choices.
- Keep BeanShell source inside `<![CDATA[ ... ]]>` blocks.
- Use the documented element/attribute names exactly — case-sensitive.

### Reference template

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE Rule PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<Rule name="Example Rule" type="IdentityAttribute">
  <Description>
    Purpose: [brief description]
    Uses:    [classes/methods used]
  </Description>
  <Source>
    <![CDATA[
      import sailpoint.object.Identity;
      // Based on JavaDocs: sailpoint.object.Identity.getName()
      return identity != null ? identity.getName() : null;
    ]]>
  </Source>
</Rule>
```

## Annotations and warnings

Use these labels consistently so the user can scan for them:

- `⚠️ ASSUMPTION: ...` — anything inferred rather than confirmed.
- `⚠️ WARNING: ...` — request conflicts with documented best practice; offer the recommended alternative and ask whether to proceed.
- `⚠️ DEPRECATED: ...` — a documented `@deprecated` API was requested or considered; propose the modern alternative.
- `⚠️ DOCUMENTATION CONFLICT: ...` — JavaDocs and object guides disagree, or a single source contradicts itself; present both readings and recommend one.
- `📘 Using IIQ 8.4 Documentation` — version badge for the first response in a conversation (see version policy in SKILL.md).
