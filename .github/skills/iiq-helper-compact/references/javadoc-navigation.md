# JavaDocs Navigation Guide (IIQ 8.4)

Authoritative source for **API code questions**: class/method signatures, parameters, return types, exceptions, inheritance.

Located at: `references/JavaDocs/8.4/`

## First stop: `_classes.md`

**Always grep `_classes.md` first when you have a class name.** It maps every one of the 793 classes/enums/interfaces to its exact relative path, so you get the destination in one tool call instead of guessing the package.

```bash
# Find any class
grep '`Identity`' references/JavaDocs/8.4/_classes.md
# -> | `Identity` | class | `sailpoint/object/Identity.html` |

# Fuzzy match (all classes starting with "Identity")
grep '| `Identity' references/JavaDocs/8.4/_classes.md
```

Only fall back to grepping the HTML tree directly when you have a **method name** (not a class) and don't know which class it lives on.

## Structure at a glance

| Path | Purpose |
|------|---------|
| `_classes.md` | **Manifest — grep this first.** Class → file path, plus a by-package breakdown. |
| `allclasses-noframe.html` | Raw HTML class list (source of `_classes.md`). |
| `index-all.html` | Master alphabetical index of every class, method, and field. Use for method-name lookups when the class is unknown. |
| `sailpoint/` | Core IIQ classes |
| `connector/` | Connector-specific classes |
| `openconnector/` | Open Connector framework classes |

Individual class pages follow Java convention: `sailpoint/<subpackage>/<ClassName>.html`
- Identity → `sailpoint/object/Identity.html`
- SailPointContext → `sailpoint/api/SailPointContext.html`

## Search workflow

1. **Class name in hand → grep `_classes.md`.** One tool call, exact path back. Skip to step 4.
2. **Method/field name in hand, class unknown** → grep the JavaDocs tree:
   - Example: `grep -rln "getProvisioningPlan" references/JavaDocs/8.4/sailpoint/`
   - Pick the most relevant class from the matches.
3. **Concept only (e.g. "how does IIQ correlate identities")** → this is an object-guide question first; see `object-guides.md` and `_toc.md`.
4. **Read the class page in full** before generating code:
   - Class description (top of page)
   - Inheritance tree / implemented interfaces
   - Field summary
   - Constructor summary
   - Method summary (note inherited methods are listed separately)
   - Method detail — full signatures with parameter names, return type, `throws` clauses, and any usage notes
   - `@deprecated` annotations

### Common packages (reference)

| Package | Contains |
|---------|----------|
| `sailpoint.object.*` | Core IIQ objects: Identity, Link, Application, Bundle, Configuration, Custom, ... |
| `sailpoint.api.*` | SailPointContext, Provisioner, ObjectUtil, Aggregator, ... |
| `sailpoint.connector.*` | Connector base classes and interfaces |
| `sailpoint.workflow.*` | WorkflowContext, Workflow, Variable, Step, libraries (IdentityLibrary, ApprovalLibrary, LCMLibrary, ...) |
| `sailpoint.task.*` | TaskSchedule, TaskDefinition, TaskResult |
| `sailpoint.policy.*` | Policy, PolicyViolation |
| `sailpoint.tools.*` | GeneralException, Util, Message |
| `sailpoint.server.*` | Server-side execution classes |
| `sailpoint.web.*` | UI bean classes (UtilBean, WorkItemBean, ...) |
| `sailpoint.plugin.*` | Plugin framework classes |
| `sailpoint.integration.*` | Integration framework classes |

> Note: There is **no `sailpoint.rule.*` package** in the JavaDocs. Rules are not Java classes — they are BeanShell scripts stored inside `Rule` XML objects. The `Rule` class itself lives at `sailpoint/object/Rule.html`. Inside a Rule's `<Source>` block, code uses regular `sailpoint.*` classes (typically `sailpoint.object.*`, `sailpoint.api.SailPointContext`, and `sailpoint.tools.GeneralException`).

## Cross-reference validation

Whenever code chains calls across multiple classes, verify the chain by opening each class page:

- If `Identity.getLinks()` returns `List<Link>`, open `references/JavaDocs/8.4/sailpoint/object/Link.html` to confirm the `Link` methods you intend to call.
- Confirm parameter types match exactly (e.g., `SailPointContext` vs `Resolver`).
- Confirm declared exceptions are handled or re-thrown.

## Citation format

When referencing the JavaDocs in a response, cite the exact file path with the full `references/...` prefix:

> Based on `references/JavaDocs/8.4/sailpoint/object/Identity.html`, `getManager()` returns `Identity` and throws no checked exceptions.

For multi-class code, cite each class consulted.

## When the JavaDocs are unclear or silent

- State exactly what was found and what is ambiguous.
- Cite the file and the section (e.g., "Method Detail → setAttribute").
- Offer the most likely interpretation and ask the user to confirm — never silently guess.
- If a class/method genuinely is not present in the JavaDocs, say so explicitly: *"I could not locate `<symbol>` in `references/JavaDocs/8.4/`."*

## Deprecated APIs

If a method's detail section contains `Deprecated.`, surface this in the response and propose the documented alternative:

> ⚠️ DEPRECATED: `Foo.bar()` per `references/JavaDocs/8.4/sailpoint/object/Foo.html` — use `Foo.baz()` instead.
