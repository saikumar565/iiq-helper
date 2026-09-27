# Object Guides Navigation (IIQ 8.4)

Authoritative source for **object structure, XML format, configuration options, functional workflows, and best practices**.

Located at: `references/objects/8.4/` (30 pre-extracted text guides named `8.4_IdentityIQ_<Topic>.txt` and `8.4_Lifecycle_Manager*.txt`; four oversized guides — Reports, Certifications, System_Configuration, Role_Group_and_Population_Management — are split into page-range parts named `_p<start>-<end>.txt`. See `_toc.md` for a chapter → file map).

These guides are organized by **functional area**, not per object type — a single guide typically covers many related objects, configurations, and processes.

The `8.4/` subfolder mirrors the `JavaDocs/8.4/` layout so future versions (8.5, 9.0, ...) can be added in parallel as `references/objects/8.5/`, `references/JavaDocs/8.5/`, etc.

## First stop: `_toc.md`

**Always grep `_toc.md` first when you have a topic or XML element name.** It maps every chapter from every guide to its file and starting page number, so you get the destination in one tool call instead of grepping a multi-hundred-KB book.

```bash
# Find any chapter / topic
grep -i 'ProvisioningPolicy' references/objects/8.4/_toc.md
# -> | Provisioning Policies | `8.4_IdentityIQ_Application_Configuration.txt` | 32 |

# Find which split part covers a topic in a big guide
grep -i 'Targeted' references/objects/8.4/_toc.md
# -> | Targeted Access Reviews | `8.4_IdentityIQ_Certifications_and_Access_Reviews_p001-028.txt` | 26 |
```

Only fall back to grepping the body `.txt` files directly when the topic isn't represented in `_toc.md` (e.g. you're hunting a specific attribute name like `correlationKey` that appears mid-chapter).

## When to use object guides vs JavaDocs

| Question is about... | Use |
|---|---|
| XML element structure, attributes, allowed values | Object guides |
| Functional behavior, configuration semantics, best practices | Object guides |
| Method signatures, class hierarchy, return types, exceptions | JavaDocs |
| API call sequencing in BeanShell/Java | JavaDocs (cross-check with object guides for object semantics) |

Most non-trivial requests need both: object guides for the *shape* of the object, JavaDocs for the *code* inside it.

## Object → guide mapping

| Object / Topic | Primary guide(s) |
|---|---|
| Applications | `8.4_IdentityIQ_Application_Configuration.txt`, `8.4_IdentityIQ_Application_Management.txt` |
| Workflows / Business Processes | `8.4_IdentityIQ_Business_Processes.txt` |
| Rules | `8.4_IdentityIQ_Business_Processes.txt` (plus the functional guide for the rule's domain) |
| Policies | `8.4_IdentityIQ_Policy_Management.txt` |
| Forms | `8.4_IdentityIQ_Forms.txt` |
| Tasks | `8.4_IdentityIQ_Tasks.txt`, `8.4_IdentityIQ_System_Administration.txt` |
| Certifications & Access Reviews | `8.4_IdentityIQ_Certifications_and_Access_Reviews_p*-*.txt` (4 parts) |
| Identities | `8.4_IdentityIQ_Identity_Management.txt` |
| Roles / Groups / Populations | `8.4_IdentityIQ_Role_Group_and_Population_Management_p*-*.txt` (4 parts) |
| Provisioning | `8.4_IdentityIQ_Provisioning.txt` |
| Custom Objects / Configuration | `8.4_IdentityIQ_System_Configuration_p*-*.txt` (4 parts) |
| Plugins | `8.4_IdentityIQ_Plugins.txt` |
| Reports | `8.4_IdentityIQ_Reports_p*-*.txt` (5 parts) |
| LCM (request flows, password mgmt, etc.) | `8.4_Lifecycle_Manager.txt`, `8.4_Lifecycle_Manager_Activation.txt`, `8.4_IdentityIQ_Password_Management.txt` |
| Risk Scoring | `8.4_IdentityIQ_Risk_Scoring.txt` |
| Classifications | `8.4_IdentityIQ_Classifications.txt` |
| Access History | `8.4_IdentityIQ_AccessHistory.txt` |
| Advanced Analytics | `8.4_IdentityIQ_Advanced_Analytics.txt` |
| Privileged Account Mgmt | `8.4_IdentityIQ_Privileged_Account_Management.txt` |
| Console / CLI | `8.4_IdentityIQ_Console.txt` |
| Work Items | `8.4_IdentityIQ_Work_Items.txt` |
| Rapid Setup | `8.4_IdentityIQ_Rapid_Setup.txt` |
| Microsoft Teams integration | `8.4_IdentityIQ_Microsoft_Teams.txt` |
| Cloud Access Management integration | `8.4_IdentityIQ_Cloud_Access_Management_Integration.txt` |
| Installation | `8.4_IdentityIQ_Installation_Guide.txt` |
| Release notes / what's new | `8.4_IdentityIQ_Release_Notes.txt` |
| First-time orientation | `8.4_IdentityIQ_Getting_Started.txt` |
| **Connectors (JDBC, SAP, AD, Azure AD, ServiceNow, generic)** | `8.4_IdentityIQ_Application_Configuration.txt`, `8.4_IdentityIQ_Application_Management.txt` (cross-ref the dedicated guide for SAP HR / Microsoft Teams / PAM if relevant) |
| **Web Services connector (REST endpoints called *by* IIQ as a target system)** | `8.4_IdentityIQ_Application_Configuration.txt` (Web Services connector chapter) |
| **IIQ REST API / SCIM (calling *into* IIQ from outside)** | ⚠️ Not covered by the bundled object guides. The bundled JavaDocs are the *internal Java* API (`sailpoint.api.*`), not the external REST/SCIM surface. State this gap explicitly and point the user to SailPoint's online "IdentityIQ Web Services" / Compass docs. |
| **Logging / log4j2 / debugging / troubleshooting** | `8.4_IdentityIQ_System_Administration.txt` (operations chapters), `8.4_IdentityIQ_Console.txt` (`iiq` CLI for inspecting state) |
| **Performance, threading, JVM tuning** | `8.4_IdentityIQ_System_Administration.txt`, `8.4_IdentityIQ_Installation_Guide.txt` |
| **Database schema / Hibernate / upgrade** | `8.4_IdentityIQ_Installation_Guide.txt`, `8.4_IdentityIQ_System_Configuration_p*-*.txt` |

### User vocabulary → IIQ vocabulary

Real users describe things in their domain language. Translate before searching:

| User says... | IIQ object / class to search for |
|---|---|
| "AD group", "AD security group", "entitlement group" | `ManagedAttribute` (often with `type=group`) — `sailpoint/object/ManagedAttribute.html` |
| "AD user", "the user's account on X" | `Link` — `sailpoint/object/Link.html` |
| "user", "person", "employee" | `Identity` — `sailpoint/object/Identity.html` |
| "role", "job role", "business role" | `Bundle` — `sailpoint/object/Bundle.html` |
| "system", "target", "endpoint", "connector" | `Application` — `sailpoint/object/Application.html` |
| "approval", "request", "access request" | `WorkItem` (UI side), `IdentityRequest` (LCM model), `Workflow` step (process side) |
| "campaign", "review", "recert" | `Certification`, `CertificationItem`, `CertificationEntity` |
| "SOD violation", "policy hit" | `PolicyViolation` |
| "audit event", "log event" | `AuditEvent` (functional audit, not log4j system logs) |
| "gMSA", "msDS-*", "sAMAccountName", "userPrincipalName", or any vendor-specific schema attribute | These live in the **connector's schema chapter** in `8.4_IdentityIQ_Application_Configuration.txt` (or the connector-specific guide if one exists). Search the guide for the attribute name itself. |
| "REST API", "SCIM endpoint", "calling IIQ from outside" | ⚠️ Not in bundled refs (those cover the internal Java API). Say so and point at SailPoint's Compass / online Web Services docs. Don't confuse with `sailpoint.api.*` internal classes. |

If the request involves an external system the IIQ docs don't cover (SAP JCo, log4j2 internals, Oracle JDBC driver behaviour, custom Java libraries), say so explicitly **and bridge to the IIQ-side hook**: "JCo itself is not in our references, but the SAP connector's documented extensibility points in `8.4_IdentityIQ_Application_Configuration.txt` are X / Y / Z." Don't refuse silently — point to where IIQ exposes the boundary.

## Search workflow

1. **Identify the functional area** the request belongs to — what is the user actually trying to achieve (provision, certify, build a workflow, define a policy, ...)?
2. **Pick the primary guide(s)** from the table. Many tasks need 2–3 guides cross-referenced.
3. **Within the guide, look for**:
   - XML examples and structural definitions
   - Attribute tables (attribute name, type, required/optional, default)
   - Configuration option enumerations
   - Documented best practices and naming conventions
   - **Commonly used optional fields** — production-quality objects include sensible optional attributes (descriptions, defaults, flags), not just the mandatory minimum.
4. **For nested objects** (a Rule embedded in a Workflow Step, a Form inside an Application provisioning policy, a sub-Workflow called from a parent), consult the documentation for **each component independently**. The parent's section rarely re-documents the child's full schema.
5. **Cross-reference related guides** when the object has dependencies:
   - Workflow that invokes Rules → Business Processes covers both
   - Application that uses Forms → Application Configuration + Forms
   - Certification campaign with custom schedule → Certifications + System Administration
   - Provisioning workflow → Provisioning + Business Processes
   - Custom Object referenced by a Form → System Configuration + Forms

## Citation format

Always cite the specific guide with its full `references/...` path (and section/chapter when known):

> Based on `references/objects/8.4/8.4_IdentityIQ_Application_Configuration.txt`, the `<Schema>` element requires `objectType` and at least one `<AttributeDefinition>`.

For multi-guide answers:

> Cross-referenced `references/objects/8.4/8.4_IdentityIQ_Provisioning.txt` (provisioning policy structure) and `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` (workflow step wiring).

## Reading the guides

Each guide is a pre-extracted text file in `references/objects/8.4/`. Page boundaries from the original PDF are preserved as `===== Page N/total =====` markers, so citations can still reference page numbers.

**Search the `.txt` files directly with grep — no script needed.**

```bash
# Find every mention of a term in one guide
grep -n "ProvisioningPolicy" references/objects/8.4/8.4_IdentityIQ_Provisioning.txt

# Search across all guides at once
grep -rln "Correlation Rule" references/objects/8.4/

# Once you have line numbers, open the .txt with the read tool around that line
```

Include the page number from the nearest `===== Page N/total =====` marker when citing:

> Per `references/objects/8.4/8.4_IdentityIQ_Provisioning.txt` p. 23, the `<ProvisioningPolicy>` element supports the `type` attribute with values `Create | Update | Delete | ...`.

Do **not** fabricate XML structure from training data — the entire purpose of the bundled guides is to ground the answer in IIQ 8.4 specifics.

## When a guide is unclear or silent

- State what was found and what is ambiguous.
- Offer the most likely interpretation, or ask the user to choose between documented options — never silently guess.
- If the topic genuinely isn't covered, say so explicitly: *"I could not locate documented guidance for `<X>` in the IIQ 8.4 object guides."*
