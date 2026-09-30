<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : use_case.xsl                                             -->
<!-- Content : PROTEUS default XSLT for use-case                        -->
<!-- Author  : Amador Durán Toro                                        -->
<!-- Date    : 2026/09/30                                               -->
<!-- Version : 2.0                                                      -->
<!-- ================================================================== -->
<!-- Version 2.0: evolved use case metamodel (Durán et al. 2004):       -->
<!--   - steps typed by action (system, actor-system, actor-actor,      -->
<!--     use case) with an optional condition,                          -->
<!--   - non-recursive conditional branches with termination,           -->
<!--   - exceptions with one or more actions and termination.           -->
<!-- ================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- ================================================================== -->
  <!-- use-case template                                                  -->
  <!-- ================================================================== -->

  <!-- Description (which includes the triggering event in its           -->
  <!-- linguistic pattern), precondition, the step-by-step "ordinary      -->
  <!-- sequence",                                                         -->
  <!-- postcondition and exceptions are shown in that fixed order (not    -->
  <!-- their declaration order in the archetype), with everything else    -->
  <!-- (importance, urgency, ...) following as usual.                     -->
  <!-- The card uses two value sub-columns (span=2) so the step tables    -->
  <!-- can show a "Step" and an "Action" column side by side.             -->

  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' use-case ')]"
    name="use_case_template"
    priority="1"
  >
    <xsl:variable name="episodes" select="children/object"/>
    <xsl:variable name="branches" select="$episodes[contains(concat(' ', normalize-space(@classes), ' '),' conditional-branch ')]"/>
    <xsl:variable name="exceptions" select="$episodes/descendant-or-self::object[contains(concat(' ', normalize-space(@classes), ' '),' use-case-exception ')]"/>

    <xsl:variable name="use_case_rows">
      <!-- Description -->
      <xsl:for-each select="properties/*[@name='description']">
        <xsl:call-template name="generate_property_row">
          <xsl:with-param name="span" select="2"/>
        </xsl:call-template>
      </xsl:for-each>

      <!-- Precondition -->
      <xsl:for-each select="properties/*[@name='precondition']">
        <xsl:call-template name="generate_property_row">
          <xsl:with-param name="span" select="2"/>
        </xsl:call-template>
      </xsl:for-each>

      <!-- Ordinary sequence: one row per episode, plus one row per step  -->
      <!-- inside a branch and one ending row per non-resuming branch.    -->
      <!-- The label cell spans all of them via rowspan.                  -->
      <xsl:if test="$episodes">
        <xsl:variable name="rows" select="1 + count($episodes) + count($branches/children/object) + count($branches[properties/*[@name='termination'] != 'resumes'])"/>
        <tr>
          <th rowspan="{$rows}">
            <xsl:value-of select="proteus-utils:i18n('xslt.ordinary_sequence')"/>
          </th>
          <th class="step_number_column">
            <xsl:value-of select="proteus-utils:i18n('xslt.step')"/>
          </th>
          <th class="step_action_column">
            <xsl:value-of select="proteus-utils:i18n('xslt.action')"/>
          </th>
        </tr>
        <xsl:for-each select="$episodes">
          <xsl:choose>
            <xsl:when test="contains(concat(' ', normalize-space(@classes), ' '),' conditional-branch ')">
              <xsl:call-template name="use_case_branch_rows"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="use_case_step_row"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:if>

      <!-- Postcondition -->
      <xsl:for-each select="properties/*[@name='postcondition']">
        <xsl:call-template name="generate_property_row">
          <xsl:with-param name="span" select="2"/>
        </xsl:call-template>
      </xsl:for-each>

      <!-- Exceptions, rendered like conditional branches: per exception a -->
      <!-- condition row numbered after its step, one row per action and  -->
      <!-- a termination row. The label cell spans all of them.           -->
      <xsl:if test="$exceptions">
        <tr>
          <th rowspan="{1 + 2 * count($exceptions) + count($exceptions/children/object) + count($exceptions[not(children/object)])}">
            <xsl:value-of select="proteus-utils:i18n('xslt.exceptions')"/>
          </th>
          <th class="step_number_column">
            <xsl:value-of select="proteus-utils:i18n('xslt.step')"/>
          </th>
          <th class="step_action_column">
            <xsl:value-of select="proteus-utils:i18n('xslt.action')"/>
          </th>
        </tr>
        <xsl:for-each select="$exceptions">
          <xsl:call-template name="use_case_exception_rows"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>

    <!-- Abstract use cases are marked in the header instead of a row -->
    <xsl:variable name="postfix">
      <xsl:if test="properties/*[@name='is-abstract'] = 'true'">
        <xsl:value-of select="proteus-utils:i18n('xslt.uc_abstract')"/>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="span" select="2"/>
      <xsl:with-param name="postfix" select="string($postfix)"/>
      <!-- A frequency of 0 means "to be determined": like other empty  -->
      <!-- properties, it is not shown                                  -->
      <xsl:with-param name="excluded_properties">
        <xsl:text>,:Proteus-name,:Proteus-code,:Proteus-date,version,authors,sources,precondition,description,postcondition,is-abstract,</xsl:text>
        <xsl:if test="not(number(properties/*[@name='frequency']/value) &gt; 0)">frequency,</xsl:if>
      </xsl:with-param>
      <xsl:with-param name="extra_rows_before" select="$use_case_rows"/>
      <xsl:with-param name="show_children" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Step number: "3" in the ordinary sequence, "3.2" inside a branch   -->
  <!-- ================================================================== -->

  <!-- current() is a step -->
  <xsl:template name="use_case_step_number">
    <xsl:variable name="parent" select="../.."/>
    <xsl:if test="contains(concat(' ', normalize-space($parent/@classes), ' '),' conditional-branch ')">
      <xsl:value-of select="count($parent/preceding-sibling::object) + 1"/>
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:value-of select="count(preceding-sibling::object) + 1"/>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Ordinary sequence rows                                             -->
  <!-- ================================================================== -->

  <!-- current() is a step. Steps inside a branch are indented and their -->
  <!-- second-level number (4.1, 4.2, ...) is shown in the action cell,  -->
  <!-- leaving the step number column for first-level numbers only.      -->
  <xsl:template name="use_case_step_row">
    <xsl:variable name="in_branch" select="contains(concat(' ', normalize-space(../../@classes), ' '),' conditional-branch ')"/>
    <tr id="{@id}" data-proteus-id="{@id}">
      <xsl:if test="$in_branch">
        <xsl:attribute name="class">use_case_branch_step</xsl:attribute>
      </xsl:if>
      <th class="step_number">
        <xsl:if test="not($in_branch)">
          <xsl:call-template name="use_case_step_number"/>
        </xsl:if>
      </th>
      <td class="step_action_column">
        <xsl:if test="$in_branch">
          <span class="use_case_branch_step_number">
            <xsl:call-template name="use_case_step_number"/>
          </span>
        </xsl:if>
        <xsl:call-template name="use_case_step_text"/>
      </td>
    </tr>
  </xsl:template>

  <!-- current() is a conditional branch -->
  <xsl:template name="use_case_branch_rows">
    <xsl:variable name="termination" select="properties/*[@name='termination']"/>

    <!-- Branch header: "3 | If <condition>:" -->
    <tr id="{@id}" data-proteus-id="{@id}" class="use_case_branch">
      <th class="step_number">
        <xsl:value-of select="count(preceding-sibling::object) + 1"/>
      </th>
      <td class="step_action_column">
        <xsl:value-of select="proteus-utils:i18n('xslt.uc_if')"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_markdown_or_tbd">
          <xsl:with-param name="content" select="properties/*[@name='condition']"/>
        </xsl:call-template>
        <xsl:text>:</xsl:text>
      </td>
    </tr>

    <!-- Branch steps: "3.1", "3.2", ... -->
    <xsl:for-each select="children/object">
      <xsl:call-template name="use_case_step_row"/>
    </xsl:for-each>

    <!-- Ending row, only for branches that end the use case. It is -->
    <!-- numbered as the next second-level step: "3.<n+1>"          -->
    <xsl:if test="$termination != 'resumes'">
      <tr class="use_case_termination">
        <th class="step_number"></th>
        <td class="step_action_column">
          <span class="use_case_branch_step_number">
            <xsl:value-of select="count(preceding-sibling::object) + 1"/>
            <xsl:text>.</xsl:text>
            <xsl:value-of select="count(children/object) + 1"/>
          </span>
          <xsl:choose>
            <xsl:when test="$termination = 'ok-ending'">
              <xsl:value-of select="proteus-utils:i18n('xslt.uc_ends_ok')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="proteus-utils:i18n('xslt.uc_ends_failure')"/>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Exception rows                                                     -->
  <!-- ================================================================== -->

  <!-- current() is an exception. Same layout as a conditional branch:   -->
  <!--   "2 | If <condition>:"                                            -->
  <!--   "  | 2.1 <action>", "  | 2.2 <action>", ...                      -->
  <!--   "  | 2.<n+1> This use case continues / ends with failure."       -->
  <xsl:template name="use_case_exception_rows">
    <xsl:variable name="termination" select="properties/*[@name='termination']"/>
    <xsl:variable name="actions" select="children/object"/>
    <xsl:variable name="step_number">
      <xsl:for-each select="../..">
        <xsl:call-template name="use_case_step_number"/>
      </xsl:for-each>
    </xsl:variable>

    <!-- Condition row, numbered after the step of the exception -->
    <tr id="{@id}" data-proteus-id="{@id}" class="use_case_exception">
      <th class="step_number">
        <xsl:value-of select="$step_number"/>
      </th>
      <td class="step_action_column">
        <xsl:value-of select="proteus-utils:i18n('xslt.uc_if')"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_markdown_or_tbd">
          <xsl:with-param name="content" select="properties/*[@name='condition']"/>
        </xsl:call-template>
        <xsl:text>:</xsl:text>
      </td>
    </tr>

    <!-- One row per action: "2.1", "2.2", ... -->
    <xsl:for-each select="$actions">
      <tr id="{@id}" data-proteus-id="{@id}" class="use_case_branch_step">
        <th class="step_number"></th>
        <td class="step_action_column">
          <span class="use_case_branch_step_number">
            <xsl:value-of select="concat($step_number, '.', position())"/>
          </span>
          <xsl:call-template name="use_case_action_text"/>
        </td>
      </tr>
    </xsl:for-each>

    <!-- An exception needs at least one action: show it as TBD -->
    <xsl:if test="not($actions)">
      <tr class="use_case_branch_step">
        <th class="step_number"></th>
        <td class="step_action_column">
          <span class="use_case_branch_step_number">
            <xsl:value-of select="concat($step_number, '.1')"/>
          </span>
          <span class="tbd">
            <xsl:value-of select="proteus-utils:i18n('xslt.tbd_expanded')"/>
          </span>
        </td>
      </tr>
    </xsl:if>

    <!-- Termination row: "2.<n+1>" -->
    <tr class="use_case_termination">
      <th class="step_number"></th>
      <td class="step_action_column">
        <span class="use_case_branch_step_number">
          <xsl:value-of select="concat($step_number, '.', count($actions) + 1 + number(not($actions)))"/>
        </span>
        <xsl:choose>
          <xsl:when test="$termination = 'failure-ending'">
            <xsl:value-of select="proteus-utils:i18n('xslt.uc_ends_failure')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="proteus-utils:i18n('xslt.uc_continues')"/>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Step and action texts                                              -->
  <!-- ================================================================== -->

  <!-- current() is a step: "[If <condition>, ]<action text>" -->
  <xsl:template name="use_case_step_text">
    <xsl:variable name="condition" select="properties/*[@name='condition']"/>
    <xsl:variable name="has_condition" select="string-length(normalize-space($condition)) &gt; 0"/>

    <xsl:if test="$has_condition">
      <xsl:value-of select="proteus-utils:i18n('xslt.uc_if')"/>
      <xsl:text> </xsl:text>
      <xsl:call-template name="generate_markdown">
        <xsl:with-param name="content" select="$condition"/>
      </xsl:call-template>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:call-template name="use_case_action_text">
      <xsl:with-param name="capitalized" select="not($has_condition)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- current() is a step or an exception action -->
  <xsl:template name="use_case_action_text">
    <xsl:param name="capitalized" select="true()"/>
    <xsl:variable name="classes" select="concat(' ', normalize-space(@classes), ' ')"/>
    <xsl:variable name="suffix">
      <xsl:if test="$capitalized">_capitalized</xsl:if>
    </xsl:variable>

    <xsl:choose>
      <!-- System action: "The system <description> (Performance: ...)" -->
      <xsl:when test="contains($classes, ' system-action ')">
        <xsl:value-of select="proteus-utils:i18n(concat('xslt.uc_the_system', $suffix))"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_markdown_or_tbd">
          <xsl:with-param name="content" select="properties/*[@name='description']"/>
        </xsl:call-template>
        <xsl:variable name="performance" select="properties/*[@name='performance']"/>
        <xsl:if test="string-length(normalize-space($performance)) &gt; 0">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="proteus-utils:i18n('xslt.uc_performance')"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$performance"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Actor action: "Actor <actor> <description> [(with actor <secondary>)]" -->
      <xsl:when test="contains($classes, ' actor-action ')">
        <xsl:value-of select="proteus-utils:i18n(concat('xslt.uc_actor', $suffix))"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_trace_link">
          <xsl:with-param name="trace" select="properties/*[@name='actor']"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_markdown_or_tbd">
          <xsl:with-param name="content" select="properties/*[@name='description']"/>
        </xsl:call-template>
        <xsl:if test="contains($classes, ' actor-actor-action ')">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="proteus-utils:i18n('xslt.uc_with_actor')"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="use_case_trace_link">
            <xsl:with-param name="trace" select="properties/*[@name='secondary-actor']"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Use case action: "Use case <use case> is performed" -->
      <xsl:when test="contains($classes, ' use-case-action-type ')">
        <xsl:value-of select="proteus-utils:i18n(concat('xslt.uc_use_case', $suffix))"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_trace_link">
          <xsl:with-param name="trace" select="properties/*[@name='use-case']"/>
        </xsl:call-template>
        <xsl:variable name="is_performed" select="proteus-utils:i18n('xslt.uc_is_performed')"/>
        <xsl:if test="string-length($is_performed) &gt; 0">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$is_performed"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Frequency: "10 times/day"; 0 means to be determined                -->
  <!-- ================================================================== -->

  <!-- More specific than the generic unitProperty template (properties.xsl), -->
  <!-- so it is used by the generic property rows of use cases.              -->
  <xsl:template match="object[contains(concat(' ', normalize-space(@classes), ' '),' use-case ')]/properties/unitProperty[@name='frequency']">
    <xsl:choose>
      <xsl:when test="number(value) &gt; 0">
        <xsl:value-of select="format-number(value, '#.###')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="proteus-utils:i18n('xslt.uc_times')"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="proteus-utils:i18n(concat('archetype.enum_units.', unit))"/>
      </xsl:when>
      <xsl:otherwise>
        <span class="tbd">
          <xsl:value-of select="proteus-utils:i18n('xslt.tbd_expanded')"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Helpers                                                            -->
  <!-- ================================================================== -->

  <!-- Markdown content, or "To Be Determined" if empty -->
  <xsl:template name="use_case_markdown_or_tbd">
    <xsl:param name="content"/>
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($content)) &gt; 0">
        <xsl:call-template name="generate_markdown">
          <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <span class="tbd">
          <xsl:value-of select="proteus-utils:i18n('xslt.tbd_expanded')"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Inline link "[CODE] Name" to the (single) target of a trace, or   -->
  <!-- "To Be Determined" if the trace has no (existing) target          -->
  <xsl:template name="use_case_trace_link">
    <xsl:param name="trace"/>
    <xsl:variable name="target_id" select="$trace/trace[1]/@target"/>
    <xsl:variable name="target_object" select="//object[@id=$target_id]"/>
    <xsl:choose>
      <xsl:when test="$target_object">
        <a href="#{$target_id}" onclick="selectAndNavigate(`{$target_id}`, event)">
          <xsl:variable name="target_code" select="$target_object/properties/*[@name=':Proteus-code']"/>
          <xsl:if test="$target_code">[<xsl:value-of select="$target_code"/>] </xsl:if>
          <xsl:value-of select="$target_object/properties/*[@name=':Proteus-name']"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="tbd">
          <xsl:value-of select="proteus-utils:i18n('xslt.tbd_expanded')"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
