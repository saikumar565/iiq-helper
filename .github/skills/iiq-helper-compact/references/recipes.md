# IIQ 8.4 Recipes — verified canonical templates

These are minimal, working starting points for the most-requested IIQ artifacts. Every template here was confirmed against a real example in `references/objects/8.4/`. Copy, adapt for the user's specifics, and **always cite the listed source** in the deliverable's *Documentation Reference* section.

If the user's request doesn't match a recipe here, fall back to the standard lookup protocol in [SKILL.md](../SKILL.md).

---

## XML object header (every IIQ object)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE sailpoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <!-- object goes here -->
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_System_Configuration_p104-120.txt` p. 112; `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` p. 28.
> Note: DOCTYPE casing varies between guides (`SailPoint` vs `sailpoint`); both are accepted by the importer. Use lowercase `sailpoint` for new objects.

---

## 1. Rule — IdentityAttribute (Identity Attribute promotion)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE sailpoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <Rule language="beanshell" name="My Identity Attribute Rule" type="IdentityAttribute">
    <Description>Computes the value of a single identity attribute during refresh.</Description>
    <Signature returnType="String">
      <Inputs>
        <Argument name="log"/>
        <Argument name="context" type="sailpoint.api.SailPointContext"/>
        <Argument name="identity" type="sailpoint.object.Identity"/>
      </Inputs>
    </Signature>
    <Source><![CDATA[
      import sailpoint.object.Identity;
      // Returned value is stored as the identity attribute this rule is mapped to.
      if (identity == null) return null;
      return identity.getName();
    ]]></Source>
  </Rule>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_System_Configuration_p104-120.txt` p. 112 (Rule structure with `<Signature>` + `<Source>`).
> JavaDocs: `references/JavaDocs/8.4/sailpoint/object/Identity.html`, `sailpoint/api/SailPointContext.html`.

---

## 2. Rule — Correlation (identity / link correlation during aggregation)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE sailpoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <Rule language="beanshell" name="My Correlation Rule" type="Correlation">
    <Description>Returns a map identifying the IIQ identity that owns this account.</Description>
    <Signature returnType="Map">
      <Inputs>
        <Argument name="log"/>
        <Argument name="context" type="sailpoint.api.SailPointContext"/>
        <Argument name="environment" type="java.util.Map"/>
        <Argument name="application" type="sailpoint.object.Application"/>
        <Argument name="account" type="sailpoint.object.ResourceObject"/>
      </Inputs>
    </Signature>
    <Source><![CDATA[
      import java.util.HashMap;
      import java.util.Map;
      Map result = new HashMap();
      // Correlate on the account's "employeeId" attribute -> Identity.name
      String employeeId = (String) account.get("employeeId");
      if (employeeId != null) {
        result.put("identityAttributeName", "name");
        result.put("identityAttributeValue", employeeId);
      }
      return result;
    ]]></Source>
  </Rule>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Application_Management.txt` (correlation rules chapter — grep `_toc.md` for "Correlation").
> JavaDocs: `references/JavaDocs/8.4/sailpoint/object/ResourceObject.html`, `sailpoint/object/Application.html`.

---

## 3. Workflow header (Business Process)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE SailPoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <Workflow explicitTransitions="true"
            name="My Workflow"
            type="IdentityUpdate">
    <Variable name="identityName" required="true"/>
    <Step name="Start" icon="Start">
      <Transition to="End"/>
    </Step>
    <Step name="End" icon="Stop"/>
  </Workflow>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` p. 28 (Header + Workflow element attributes).
> Common `type` values: `IdentityUpdate`, `Provisioning`, `LCM`, `Approval`, `Event`, `Subprocess`, `StepLibrary`.
> Set `explicitTransitions="true"` unless you intentionally want fall-through sequencing.

---

## 4. Approval step (inside a Workflow)

```xml
<Step name="Manager Approval" icon="Approval"
      action="call:assembleApprovalSet">
  <Arg name="approvalScheme" value="manager"/>
  <Arg name="approvalSet" value="ref:approvalSet"/>
  <Arg name="approvalMode" value="serial"/>
  <Transition to="Provision"/>
</Step>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` p. 33–37 (Provisioning Step Library: "Account Approval" step).
> Use the `LCM Provisioning` workflow's `stepLibraries="Common,Provisioning"` attribute to make this step available in the Business Process Editor.

---

## 5. Application + Schema (minimum viable)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE sailpoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <Application name="My JDBC App"
               connector="sailpoint.connector.JDBCConnector"
               type="JDBC">
    <Attributes>
      <Map>
        <entry key="url"      value="jdbc:postgresql://[PLACEHOLDER_HOST]:5432/[PLACEHOLDER_DB]"/>
        <entry key="driverClass" value="org.postgresql.Driver"/>
        <entry key="user"     value="[PLACEHOLDER_USER]"/>
        <entry key="password" value="[PLACEHOLDER_PASSWORD]"/>
      </Map>
    </Attributes>
    <Schemas>
      <Schema objectType="account"
              displayAttribute="username"
              identityAttribute="username"
              nativeObjectType="account">
        <AttributeDefinition name="username" type="string" required="true"/>
        <AttributeDefinition name="email"    type="string"/>
        <AttributeDefinition name="status"   type="string"/>
      </Schema>
    </Schemas>
  </Application>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Application_Configuration.txt` (Application Schemas chapter — see `_toc.md` for page).
> Required Schema attributes: `objectType`, plus at least one `<AttributeDefinition>`. `displayAttribute` and `identityAttribute` are documented best practice for `account` schemas.

---

## 6. TaskDefinition — Report (LiveReport)

Reports are TaskDefinitions of `type="LiveReport"` whose `report` attribute holds a `<LiveReport>` element with the data source and columns. The executor `sailpoint.reporting.LiveReportExecutor` is **always** used for any custom report.

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE sailpoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <TaskDefinition executor="sailpoint.reporting.LiveReportExecutor"
                  name="My Custom Report"
                  progressMode="Percentage"
                  resultAction="Rename"
                  subType="Identity and User Reports"
                  template="true"
                  type="LiveReport">
    <Description>One-line description shown in the Reports list.</Description>
    <RequiredRights>
      <Reference class="sailpoint.object.SPRight" name="FullAccessUncorrelatedIdentitiesReport"/>
    </RequiredRights>
    <Signature>
      <Inputs>
        <Argument name="resultScope"     type="Scope"/>
        <Argument name="emailIdentities" type="Identity" multi="true"/>
        <!-- report-specific inputs go here -->
      </Inputs>
    </Signature>
    <Attributes>
      <Map>
        <entry key="report">
          <value>
            <LiveReport title="My Custom Report">
              <DataSource type="Filter" objectType="sailpoint.object.Identity">
                <QueryParameters>
                  <Parameter argument="resultScope" property="assignedScope.id"/>
                </QueryParameters>
              </DataSource>
              <Columns>
                <ReportColumnConfig field="name"      header="rept_col_name"     property="name"     sortable="true"/>
                <ReportColumnConfig field="firstName" header="rept_col_first"    property="firstname" sortable="true"/>
                <ReportColumnConfig field="lastName"  header="rept_col_last"     property="lastname"  sortable="true"/>
              </Columns>
            </LiveReport>
          </value>
        </entry>
      </Map>
    </Attributes>
  </TaskDefinition>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Reports_p093-122.txt` p. 103–111 ("Reports in the IdentityIQ Object Model" — verbatim `TaskDefinition` + `LiveReport` structure).
> Required TaskDefinition attributes: `executor`, `name`, `type="LiveReport"`. Required nested: `<Attributes><Map><entry key="report"><value><LiveReport>...`.
> Always include `resultScope` and `emailIdentities` in the Signature — these appear on the Standard Properties screen and must be available on every report.
> `DataSource type` values: `Filter` (uses HQL Filter), `Hql` (raw HQL `<Query>` + optional `<QueryScript>`), `Java` (custom class implementing `JavaDataSource`).
> Subclass-style reuse: a customized report "instance" is its own TaskDefinition without `template="true"`, referencing the same report key but with different `<entry>` values pre-populated in the Attributes map (see same guide p. 106).

---

## 6b. TaskDefinition — non-report tasks (Identity Refresh, Aggregation, etc.)

**Bundled docs do not contain XML examples for built-in non-report task executors.** Class names like `sailpoint.task.IdentityRefreshExecutor` and the specific attribute keys (`refreshIdentityAttributes`, `refreshAssignedRoles`, etc.) are **not** in the object guides or the JavaDocs (only `AbstractTaskExecutor` is documented).

When the user asks for one of these:

1. **State the gap upfront.** Don't invent the executor FQN or attribute keys.
2. **Point them at the documented extraction path.** From `references/objects/8.4/8.4_IdentityIQ_Reports_p093-122.txt` p. 103: any installed IIQ instance can export its built-in TaskDefinitions via
   ```
   iiqconsole> export taskDefs.xml TaskDefinition
   ```
   The user can then send you the exported XML for their specific task type as a verified starting point.
3. **Offer to generate the wrapper** — the surrounding `<sailpoint><TaskDefinition .../></sailpoint>` and the Description/Signature shape are the same as recipe 6 — but flag every executor-specific field as `[VERIFY_FROM_EXPORT]`.

> Source: `references/objects/8.4/8.4_IdentityIQ_Reports_p093-122.txt` p. 103 (`iiqconsole export` command).
> Negative source: no `executor="sailpoint.task."` matches anywhere in `references/objects/8.4/` (verified via grep).

---

## 6c. TaskDefinition — Report with HQL DataSource

When the user explicitly asks for HQL **or** when the report requires aggregation (`count`, `sum`, `group by`) or a subselect that a `Filter` DataSource can't express, switch the DataSource block in recipe 6 to `type="Hql"`. The rest of the TaskDefinition wrapper is identical to recipe 6.

```xml
<DataSource type="Hql">
  <Query>from ManagedAttribute m where group=true</Query>
  <QueryParameters>
    <Parameter argument="application" property="application_id"/>
  </QueryParameters>
  <QueryScript>
    <Source>
      import java.util.*;
      List applications = args.get("application.id");
      if (applications != null &amp;&amp; !applications.isEmpty()) {
        query = query + " and application.id in (:application_id) ";
      }
      return query;
    </Source>
  </QueryScript>
</DataSource>
<Columns>
  <ReportColumnConfig field="accountGroupName"        header="rept_col_name"    property="value"            sortable="true"/>
  <ReportColumnConfig field="accountGroupDisplayName" header="rept_col_display" property="displayName"      sortable="true"/>
  <ReportColumnConfig field="application"             header="rept_col_app"     property="application.name" sortable="true"/>
  <!-- Calculated column via subselect — cannot be sortable -->
  <ReportColumnConfig field="total" header="rept_col_members"
    property="(select count(*) from IdentityEntitlement ie where ie.value = m.value and ie.application = m.application and ie.name = m.attribute and ie.aggregationState = &apos;Connected&apos;)"/>
</Columns>
```

Key differences from the Filter DataSource (recipe 6):
- `<Query>` **must** contain the `from <Entity> <alias>` clause; the `objectType` attribute is ignored on HQL.
- `<QueryParameters>` here only provides named-variable substitution into the query string (`:application_id`) — it doesn't add filter conditions on its own.
- `<QueryScript>` mutates the `query` string variable (not the args map) and returns the final string. `args` is the task argument map.
- A column with a subselect in `property=` is allowed but **cannot be marked `sortable="true"`**.

> Source: `references/objects/8.4/8.4_IdentityIQ_Reports_p123-149.txt` p. 124–126 ("HQL DataSource" — Account Group Membership Totals Report verbatim example, Query / QueryParameters / QueryScript semantics, and the calculated-column rule).

---

## 7. Form (provisioning policy)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE SailPoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <Form name="My Create Account Form" type="Create">
    <Section name="account" label="Account Details">
      <Field displayName="Username"
             name="username"
             required="true"
             type="string"/>
      <Field displayName="Email"
             name="email"
             type="string"/>
    </Section>
  </Form>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Forms.txt` p. 537+ (Form element with sections and fields).
> `type` choices: `Create`, `Update`, `Delete`, `CreateIdentity`, `Workflow`.

---

## 8. Custom object (typed config holder)

```xml
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE sailpoint PUBLIC "sailpoint.dtd" "sailpoint.dtd">
<sailpoint>
  <Custom name="My App Config">
    <Attributes>
      <Map>
        <entry key="targetSystemUrl" value="https://[PLACEHOLDER_HOST]/api"/>
        <entry key="batchSize"       value="500"/>
        <entry key="featureFlags">
          <value>
            <List>
              <String>enableX</String>
              <String>enableY</String>
            </List>
          </value>
        </entry>
      </Map>
    </Attributes>
  </Custom>
</sailpoint>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_System_Configuration_p001-034.txt` (Custom objects in System Setup — grep `_toc.md` for "Custom").
> JavaDocs: `references/JavaDocs/8.4/sailpoint/object/Custom.html`.

---

## 9. Common BeanShell imports inside `<Source>`

```java
import sailpoint.object.Identity;
import sailpoint.object.Link;
import sailpoint.object.Application;
import sailpoint.object.Bundle;
import sailpoint.api.SailPointContext;
import sailpoint.api.ObjectUtil;
import sailpoint.tools.GeneralException;
import sailpoint.tools.Util;
```

> All confirmed via `references/JavaDocs/8.4/_classes.md`. Use the manifest to look up any other class before writing `import` lines.

---

## 10. Logging inside a Rule

```java
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

private static final Log log = LogFactory.getLog("rule.MyIdentityAttribute");

log.debug("Processing identity: " + identity.getName());
```

> The `log` argument passed into Rules by IIQ is a `commons-logging` Log. Configure verbosity via `WEB-INF/classes/log4j2.properties` (see `references/objects/8.4/8.4_IdentityIQ_System_Administration.txt`).

---

## 11. Workflow step actions (call / rule / subprocess)

A `<Step>` does work through its `action` attribute or a nested `<WorkflowRef>`. All three forms are interchangeable in the step body — the only difference is what runs.

```xml
<!-- (a) call a workflow library method -->
<Step action="call:refreshIdentity" icon="Task" name="Refresh Identity">
  <Arg name="identityName"          value="ref:identityName"/>
  <Arg name="correlateEntitlements" value="string:true"/>
  <Transition to="Notify"/>
</Step>

<!-- (b) invoke a Rule object by name -->
<Step action="rule:WFRule_verifyIdentity" icon="Task" name="Verify Identity">
  <Arg name="identityName" value="ref:identityName"/>
  <Transition to="End"/>
</Step>

<!-- (c) call a subprocess (another Workflow) -->
<Step icon="Task" name="Initialize">
  <Arg name="flow"           value="ref:flow"/>
  <Arg name="identityName"   value="ref:identityName"/>
  <Return name="project"     to="project"/>
  <Return name="approvalSet" to="approvalSet" merge="true"/>
  <WorkflowRef>
    <Reference class="sailpoint.object.Workflow" name="Identity Request Initialize"/>
  </WorkflowRef>
  <Transition to="end"/>
</Step>
```

**Capturing the result of a step's script/call into a workflow variable** — use the `resultVariable` attribute on the `<Step>`:

```xml
<Step name="Build Plan" resultVariable="provisioningPlan">
  <Script><Source>
    import sailpoint.object.ProvisioningPlan;
    ProvisioningPlan plan = new ProvisioningPlan();
    // ... build plan ...
    return plan;
  </Source></Script>
  <Transition to="Execute"/>
</Step>

<Step action="call:provisionProject" name="Execute">
  <Arg name="project" value="ref:provisioningPlan"/>
  <Transition to="End"/>
</Step>
```

> Source: `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` p. 39–45 (Action types: Call, Rule, Subprocess; `<Arg>` / `<Return>` / `resultVariable` attributes).
> `Arg value` prefixes: `string:` (default), `ref:<workflowVar>`, `script:<beanshell>`, `rule:<RuleName>`, `call:<libraryMethod>`.
> Default libraries (always available when `libraries=` is unset): Identity, Role, PolicyViolation, Lifecycle Manager.

---

## 12. Workflow loop (iterate over a List variable)

Loops are not a first-class construct in IIQ workflows — they're built from a counter variable and a transition that goes back to the loop body. The pattern below is verified against the iteration examples in the Business Processes guide.

```xml
<Workflow explicitTransitions="true" name="Iterate Identities" type="Subprocess">
  <Variable input="true" name="identityNames"/>      <!-- List<String> -->
  <Variable name="loopIndex" initializer="string:0"/>
  <Variable name="currentIdentity"/>

  <Step name="Start" icon="Start">
    <Transition to="Loop Check"/>
  </Step>

  <Step name="Loop Check" resultVariable="hasMore">
    <Script><Source>
      int i = Integer.parseInt(loopIndex);
      return identityNames != null &amp;&amp; i &lt; identityNames.size();
    </Source></Script>
    <Transition to="Pick Current" when="script:hasMore"/>
    <Transition to="End"/>
  </Step>

  <Step name="Pick Current" resultVariable="currentIdentity">
    <Script><Source>
      return identityNames.get(Integer.parseInt(loopIndex));
    </Source></Script>
    <Transition to="Refresh Current"/>
  </Step>

  <Step action="call:refreshIdentity" name="Refresh Current">
    <Arg name="identityName" value="ref:currentIdentity"/>
    <Transition to="Increment"/>
  </Step>

  <Step name="Increment" resultVariable="loopIndex">
    <Script><Source>
      return String.valueOf(Integer.parseInt(loopIndex) + 1);
    </Source></Script>
    <Transition to="Loop Check"/>
  </Step>

  <Step name="End" icon="Stop"/>
</Workflow>
```

> Source pattern: `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` p. 42–46 (transitions with `when="script:..."` and `resultVariable` capture).
> Conditional transition: `when="script:<expr>"` evaluates a BeanShell expression and follows the transition only if true. The first transition whose `when` is true (or that has no `when`) is taken.

---

## 13. Workflow email step (insert into an existing Workflow)

**This is a `<Step>` fragment, not a standalone artifact.** Drop it inside a `<Workflow>` built from recipe 3 — sending an email is almost always part of a larger flow (provisioning, approval, refresh). Do not wrap this in its own `<sailpoint><Workflow>...</Workflow></sailpoint>` and ship as a one-off; if that's truly what the user wants, ask first.

The `sendEmail` library method (Email workflow library) is the standard way to send a notification from a step. The library is included in the default libraries set, so no `libraries="Email"` attribute is needed on the parent workflow.

```xml
<Step action="call:sendEmail" icon="Email" name="Notify Requester">
  <Arg name="identityName"  value="ref:identityName"/>
  <Arg name="template"      value="string:My Email Template"/>
  <!-- template variables — anything named here is exposed as $variable in the template body -->
  <Arg name="requestId"     value="ref:identityRequestId"/>
  <Transition to="End"/>
</Step>
```

For `<Approval>` notifications (separate from a step-level email), use a nested `<NotificationEmailTemplateRef>`. The `owner=` script needs an Identity in scope — if the parent workflow doesn't declare `<Variable name="identity" type="Identity"/>`, look it up explicitly:

```xml
<Approval mode="serial"
          owner="script:context.getObjectByName(sailpoint.object.Identity.class, identityName).getManager().getName()">
  <NotificationEmailTemplateRef>
    <Reference class="sailpoint.object.EmailTemplate" name="Access Request Approval"/>
  </NotificationEmailTemplateRef>
</Approval>
```

> Source (sendEmail library method): `references/objects/8.4/8.4_IdentityIQ_Business_Processes.txt` p. 56 ("Email Library — `public Object sendEmail` Sends an email message").
> Source (`NotificationEmailTemplateRef`): same guide, approval-step examples around p. 52–56.
> JavaDocs: `references/JavaDocs/8.4/sailpoint/object/EmailTemplate.html`, `sailpoint/workflow/StandardWorkflowHandler.EmailArgument.html`.

---

## 14. Certification creation (gap note)

**Bundled docs do not contain XML examples for `<Certification>` or `<CertificationDefinition>` objects.** The Certifications and Access Reviews guide is UI-driven (Setup → Certifications → New Certification…). The Java API for programmatic creation exists — see `references/JavaDocs/8.4/sailpoint/object/CertificationDefinition.html` and its many inner classes (`NotificationConfig`, `EscalationConfig`, `CertifierSelectionType`, etc.) — but there are no XML templates to copy.

When the user asks for a certification XML:

1. **State the gap.** Don't fabricate XML elements or attribute names.
2. **Offer the documented alternatives:**
   - For UI scheduling, point at `references/objects/8.4/8.4_IdentityIQ_Certifications_and_Access_Reviews_p062-089.txt` ("Scheduling a Non-Targeted Certification", "Scheduling a Targeted Certification").
   - For programmatic creation, point at the `CertificationDefinition` JavaDoc and offer BeanShell against `sailpoint.api.Certificationer` (verify the API class name in `_classes.md` first; if not present, say so).
   - For an exported XML, use the same `iiqconsole export` command from recipe 6b.

> Negative source: no `<Certification`, `<CertificationDefinition`, or `executor=` matches related to certifications anywhere in `references/objects/8.4/` (verified via grep).
> JavaDoc class hierarchy: `references/JavaDocs/8.4/_classes.md` — grep `Certification` returns ~40 classes/enums under `sailpoint/object/`.

---

## 15. ProvisioningPlan + Provisioner (BeanShell)

Build and execute a provisioning plan directly from BeanShell (rule, workflow `<Script>`, or plugin). All three operation enums are verified in the JavaDocs.

```java
import sailpoint.api.Provisioner;
import sailpoint.api.SailPointContext;
import sailpoint.object.Application;
import sailpoint.object.Identity;
import sailpoint.object.ProvisioningPlan;
import sailpoint.object.ProvisioningPlan.AccountRequest;
import sailpoint.object.ProvisioningPlan.AttributeRequest;

Identity target = context.getObjectByName(Identity.class, identityName);
Application app  = context.getObjectByName(Application.class, "[PLACEHOLDER_APP_NAME]");

ProvisioningPlan plan = new ProvisioningPlan();
plan.setIdentity(target);

AccountRequest acct = new AccountRequest();
acct.setApplication(app.getName());
acct.setOperation(AccountRequest.Operation.Modify);   // or Create / Delete / Disable / Enable / Lock / Unlock
acct.setNativeIdentity("[PLACEHOLDER_NATIVE_ID]");    // omit for Create on apps that generate IDs

AttributeRequest attr = new AttributeRequest();
attr.setName("memberOf");
attr.setOperation(ProvisioningPlan.Operation.Add);    // Set / Add / Remove / Revoke
attr.setValue("CN=Sales,OU=Groups,DC=example,DC=com");
acct.add(attr);

plan.add(acct);

Provisioner p = new Provisioner(context);
p.setSource(sailpoint.object.Source.Rule);            // tells history WHO triggered this
p.setRequester("spadmin");                            // optional, defaults to current user
p.compile(plan);
p.execute();
```

From inside a workflow `<Step>`, prefer the `provisionProject` library call (see recipe 11) — it routes through the standard LCM lifecycle (policy checks, approvals, audit). Use the direct `Provisioner` API only when you need to bypass the workflow layer (custom rule, scheduled task, plugin).

> Source (Provisioner): `references/JavaDocs/8.4/sailpoint/api/Provisioner.html` — constructor `Provisioner(SailPointContext)`, `compile(ProvisioningPlan)`, `execute()`, `setSource(Source)`, `setRequester(String)`.
> Source (operation enums, both real): `references/JavaDocs/8.4/sailpoint/object/ProvisioningPlan.AccountRequest.Operation.html` (Create, Modify, Delete, Disable, Enable, Lock, Unlock), `sailpoint/object/ProvisioningPlan.Operation.html` (Set, Add, Remove, Revoke for AttributeRequest), `sailpoint/object/ProvisioningPlan.ObjectOperation.html` (used internally by AbstractRequest.setOp).
> Source (Source enum for audit): `references/JavaDocs/8.4/sailpoint/object/Source.html`.
> Cross-reference: `references/objects/8.4/8.4_IdentityIQ_Provisioning.txt` (LCM Requests, p. 4 — workflow-layer alternative).
