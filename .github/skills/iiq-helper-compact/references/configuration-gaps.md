# Configuration Gap Management

Real requests rarely arrive with every value filled in. The goal is to (a) never silently invent sensitive values, (b) never block the user when a sensible default exists, and (c) never make the user guess what is still missing.

## The three-step protocol

### 1. Identify gaps

Before producing the deliverable, enumerate every configuration the deliverable needs and classify each one:

- **Required vs Optional** — would the object/code fail to load, run, or function without it?
- **Sensitive vs Non-sensitive** — does it contain secrets, internal hostnames, account identifiers, client IDs, tokens, or anything an org would not paste into a public chat?

Sensitive examples: passwords, API keys/secrets, OAuth client IDs, service-account names, server hostnames/IPs, database connection strings, certificate contents.

### 2. Communicate clearly

For each gap, state:

- **Configuration name**
- **Purpose** — why it is needed
- **Expected format / type** (and allowed values when documented)
- **Sensitive?** — yes/no

### 3. Offer placeholders for sensitive data

For anything sensitive, **explicitly flag it with the phrase "This appears to be sensitive information"** and offer to substitute a clearly-named placeholder. Use one of:

- `[PLACEHOLDER_PASSWORD]`
- `[PLACEHOLDER_API_KEY]`
- `dummy-client-id-replace-me`
- `https://[PLACEHOLDER_HOST]/api`

Always also list every placeholder used in the response's *Configuration Status* section so the user has a single checklist of what to replace before deploying.

## Request template

When asking for missing information, prefer this layout — it minimizes round-trips:

```
I need the following to complete this <object/code>:

Required Configurations:
1. <Name>: <purpose> — Please provide.
2. <Name>: <purpose> — Options: <list if known>.

Sensitive Configurations (placeholders available):
3. <Name>: <purpose> — Use placeholder?
4. <Name>: <purpose> — Use placeholder?

Optional Configurations (sensible defaults available):
5. <Name>: <purpose> — Default I'll use unless you say otherwise: <value>.

How would you like to proceed?
```

## When to ask vs assume

**Ask** when:
- A required value has no documented default.
- The request is ambiguous (e.g., "create a rule" — which type?).
- Multiple valid approaches exist with meaningful trade-offs.
- The user's request appears to violate a documented best practice.

**Proceed with a labeled assumption** when:
- An optional value has a sensible documented default.
- A standard naming convention applies.
- Context strongly implies the common interpretation.
- The cost of being wrong is low and easily reversed.

Always label assumptions inline:

> ⚠️ ASSUMPTION: Using `disabled=false` on the new Application since the request did not specify; the documented default is `false`.

## Question format

- Be **specific**, not open-ended.
- Offer choices when possible: *"Should this rule run as A) IdentityAttribute or B) IdentityCorrelation?"*
- **Group** related questions into a single message.
- Briefly **explain why** each piece of information is needed — it helps the user answer accurately.
