<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : use_case.xsl                                             -->
<!-- Content : PROTEUS LaTeX XSLT for use-case                          -->
<!-- Author  : Amador Durán Toro                                        -->
<!-- Date    : 2026/10/08                                               -->
<!-- Version : 1.0                                                      -->
<!-- ================================================================== -->
<!-- LaTeX counterpart of the use case module of the default template   -->
<!-- (evolved use case metamodel, Durán et al. 2004):                   -->
<!--   - steps typed by action (system, actor-system, actor-actor,      -->
<!--     use case) with an optional condition,                          -->
<!--   - non-recursive conditional branches with termination,           -->
<!--   - exceptions with one or more actions and termination.           -->
<!--                                                                    -->
<!-- The HTML card has a third column for step numbers and a label cell -->
<!-- spanning all the rows of a sequence (rowspan). Here every step is  -->
<!-- a row of the card, so that long sequences break across pages; the  -->
<!-- label is written in the first row only, the rows of a sequence are -->
<!-- separated by \cline{2-2} and the value cell shows the step number  -->
<!-- and the action with \ProteusStep and \ProteusSubStep (proteus.sty). -->
<!-- ================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- ================================================================== -->
  <!-- use-case template                                                  -->
  <!-- ================================================================== -->

  <!-- Description, precondition, ordinary sequence, postcondition and   -->
  <!-- exceptions are shown in that fixed order, with everything else     -->
  <!-- (importance, urgency, ...) following as usual.                     -->

  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' use-case ')]"
    name="use_case_template"
    priority="1"
  >
    <xsl:variable name="episodes" select="children/object"/>
    <xsl:variable name="exceptions" select="$episodes/descendant-or-self::object[contains(concat(' ', normalize-space(@classes), ' '),' use-case-exception ')]"/>

    <xsl:variable name="use_case_rows">
      <!-- Description -->
      <xsl:for-each select="properties/*[@name='description']">
        <xsl:call-template name="generate_property_row"/>
      </xsl:for-each>

      <!-- Precondition -->
      <xsl:for-each select="properties/*[@name='precondition']">
        <xsl:call-template name="generate_property_row"/>
      </xsl:for-each>

      <!-- Ordinary sequence: one row per episode, plus one row per step -->
      <!-- inside a branch and one ending row per non-resuming branch    -->
      <xsl:if test="$episodes">
        <xsl:call-template name="use_case_sequence_header">
          <xsl:with-param name="key" select="'xslt.ordinary_sequence'"/>
        </xsl:call-template>
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
        <xsl:text>\hline&#10;</xsl:text>
      </xsl:if>

      <!-- Postcondition -->
      <xsl:for-each select="properties/*[@name='postcondition']">
        <xsl:call-template name="generate_property_row"/>
      </xsl:for-each>

      <!-- Exceptions, rendered like conditional branches: per exception a -->
      <!-- condition row numbered after its step, one row per action and  -->
      <!-- a termination row                                              -->
      <xsl:if test="$exceptions">
        <xsl:call-template name="use_case_sequence_header">
          <xsl:with-param name="key" select="'xslt.exceptions'"/>
        </xsl:call-template>
        <xsl:for-each select="$exceptions">
          <xsl:call-template name="use_case_exception_rows"/>
        </xsl:for-each>
        <xsl:text>\hline&#10;</xsl:text>
      </xsl:if>
    </xsl:variable>

    <!-- Abstract use cases are marked in the header instead of a row -->
    <xsl:variable name="postfix">
      <xsl:if test="properties/*[@name='is-abstract'] = 'true'">
        <xsl:value-of select="proteus-utils:i18n('xslt.uc_abstract')"/>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="generate_table">
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
  <!-- Sequence rows                                                      -->
  <!-- ================================================================== -->

  <!-- First row of a sequence: "<label> | Step  Action". The rows of the -->
  <!-- sequence follow, each one preceded by \cline{2-2}, and the caller  -->
  <!-- closes the sequence with \hline.                                   -->
  <xsl:template name="use_case_sequence_header">
    <xsl:param name="key"/>
    <xsl:call-template name="label"><xsl:with-param name="key" select="$key"/></xsl:call-template>
    <xsl:text> &amp; \ProteusStepHeader{</xsl:text>
    <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.step'"/></xsl:call-template>
    <xsl:text>}{</xsl:text>
    <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.action'"/></xsl:call-template>
    <xsl:text>} \\&#10;</xsl:text>
  </xsl:template>

  <!-- A row of a sequence. 'number' is a first-level step number (or    -->
  <!-- empty); 'sub_number', if any, is the second-level number of steps -->
  <!-- of a branch, actions of an exception and ending rows (3.1, 3.2).  -->
  <!-- 'content' is LaTeX text.                                          -->
  <xsl:template name="use_case_sequence_row">
    <xsl:param name="number"/>
    <xsl:param name="sub_number"/>
    <xsl:param name="content"/>
    <xsl:param name="id"/>

    <xsl:text>\cline{2-2}&#10; &amp; \ProteusStep{</xsl:text>
    <xsl:value-of select="$number"/>
    <xsl:text>}{</xsl:text>
    <!-- The paragraph must start before the anchor (\phantomsection):  -->
    <!-- in vertical mode it would be an empty first line of the action -->
    <!-- minipage, which is aligned with the step number by that line   -->
    <xsl:if test="$id">
      <xsl:text>\leavevmode</xsl:text>
      <xsl:call-template name="anchor"><xsl:with-param name="id" select="$id"/></xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="string-length($sub_number) &gt; 0">
        <xsl:text>\ProteusSubStep{</xsl:text>
        <xsl:value-of select="$sub_number"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="$content"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>} \\&#10;</xsl:text>
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

  <!-- current() is a step. Steps inside a branch leave the step number  -->
  <!-- column empty and show their second-level number (4.1, 4.2, ...)   -->
  <!-- next to the action, as in the HTML view.                          -->
  <xsl:template name="use_case_step_row">
    <xsl:variable name="in_branch" select="contains(concat(' ', normalize-space(../../@classes), ' '),' conditional-branch ')"/>
    <xsl:variable name="number">
      <xsl:call-template name="use_case_step_number"/>
    </xsl:variable>

    <xsl:call-template name="use_case_sequence_row">
      <xsl:with-param name="id" select="@id"/>
      <xsl:with-param name="number">
        <xsl:if test="not($in_branch)"><xsl:value-of select="$number"/></xsl:if>
      </xsl:with-param>
      <xsl:with-param name="sub_number">
        <xsl:if test="$in_branch"><xsl:value-of select="$number"/></xsl:if>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:call-template name="use_case_step_text"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- current() is a conditional branch -->
  <xsl:template name="use_case_branch_rows">
    <xsl:variable name="termination" select="properties/*[@name='termination']"/>
    <xsl:variable name="branch_number" select="count(preceding-sibling::object) + 1"/>

    <!-- Branch header: "3 | If <condition>:" -->
    <xsl:call-template name="use_case_sequence_row">
      <xsl:with-param name="id" select="@id"/>
      <xsl:with-param name="number" select="$branch_number"/>
      <xsl:with-param name="content">
        <xsl:call-template name="use_case_condition"/>
      </xsl:with-param>
    </xsl:call-template>

    <!-- Branch steps: "3.1", "3.2", ... -->
    <xsl:for-each select="children/object">
      <xsl:call-template name="use_case_step_row"/>
    </xsl:for-each>

    <!-- Ending row, only for branches that end the use case. It is -->
    <!-- numbered as the next second-level step: "3.<n+1>"          -->
    <xsl:if test="$termination != 'resumes'">
      <xsl:call-template name="use_case_sequence_row">
        <xsl:with-param name="sub_number" select="concat($branch_number, '.', count(children/object) + 1)"/>
        <xsl:with-param name="content">
          <xsl:text>\emph{</xsl:text>
          <xsl:choose>
            <xsl:when test="$termination = 'ok-ending'">
              <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_ends_ok'"/></xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_ends_failure'"/></xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>}</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
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
    <xsl:call-template name="use_case_sequence_row">
      <xsl:with-param name="id" select="@id"/>
      <xsl:with-param name="number" select="$step_number"/>
      <xsl:with-param name="content">
        <xsl:call-template name="use_case_condition"/>
      </xsl:with-param>
    </xsl:call-template>

    <!-- One row per action: "2.1", "2.2", ... -->
    <xsl:for-each select="$actions">
      <xsl:call-template name="use_case_sequence_row">
        <xsl:with-param name="id" select="@id"/>
        <xsl:with-param name="sub_number" select="concat($step_number, '.', position())"/>
        <xsl:with-param name="content">
          <xsl:call-template name="use_case_action_text"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

    <!-- An exception needs at least one action: show it as TBD -->
    <xsl:if test="not($actions)">
      <xsl:call-template name="use_case_sequence_row">
        <xsl:with-param name="sub_number" select="concat($step_number, '.1')"/>
        <xsl:with-param name="content">
          <xsl:call-template name="tbd"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Termination row: "2.<n+1>" -->
    <xsl:call-template name="use_case_sequence_row">
      <xsl:with-param name="sub_number" select="concat($step_number, '.', count($actions) + 1 + number(not($actions)))"/>
      <xsl:with-param name="content">
        <xsl:text>\emph{</xsl:text>
        <xsl:choose>
          <xsl:when test="$termination = 'failure-ending'">
            <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_ends_failure'"/></xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_continues'"/></xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- Step and action texts                                              -->
  <!-- ================================================================== -->

  <!-- current() is a branch or an exception: "If <condition>:" -->
  <xsl:template name="use_case_condition">
    <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_if'"/></xsl:call-template>
    <xsl:text> </xsl:text>
    <xsl:call-template name="use_case_markdown_or_tbd">
      <xsl:with-param name="content" select="properties/*[@name='condition']"/>
    </xsl:call-template>
    <xsl:text>:</xsl:text>
  </xsl:template>

  <!-- current() is a step: "[If <condition>, ]<action text>" -->
  <xsl:template name="use_case_step_text">
    <xsl:variable name="condition" select="properties/*[@name='condition']"/>
    <xsl:variable name="has_condition" select="string-length(normalize-space($condition)) &gt; 0"/>

    <xsl:if test="$has_condition">
      <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_if'"/></xsl:call-template>
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
        <xsl:call-template name="label"><xsl:with-param name="key" select="concat('xslt.uc_the_system', $suffix)"/></xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_markdown_or_tbd">
          <xsl:with-param name="content" select="properties/*[@name='description']"/>
        </xsl:call-template>
        <xsl:variable name="performance" select="properties/*[@name='performance']"/>
        <xsl:if test="string-length(normalize-space($performance)) &gt; 0">
          <xsl:text> (</xsl:text>
          <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_performance'"/></xsl:call-template>
          <xsl:text>: </xsl:text>
          <xsl:call-template name="tex"><xsl:with-param name="text" select="$performance"/></xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Actor action: "Actor <actor> <description> [(with actor <secondary>)]" -->
      <xsl:when test="contains($classes, ' actor-action ')">
        <xsl:call-template name="label"><xsl:with-param name="key" select="concat('xslt.uc_actor', $suffix)"/></xsl:call-template>
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
          <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_with_actor'"/></xsl:call-template>
          <xsl:text> </xsl:text>
          <xsl:call-template name="use_case_trace_link">
            <xsl:with-param name="trace" select="properties/*[@name='secondary-actor']"/>
          </xsl:call-template>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- Use case action: "Use case <use case> is performed" -->
      <xsl:when test="contains($classes, ' use-case-action-type ')">
        <xsl:call-template name="label"><xsl:with-param name="key" select="concat('xslt.uc_use_case', $suffix)"/></xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="use_case_trace_link">
          <xsl:with-param name="trace" select="properties/*[@name='use-case']"/>
        </xsl:call-template>
        <xsl:variable name="is_performed" select="proteus-utils:i18n('xslt.uc_is_performed')"/>
        <xsl:if test="string-length($is_performed) &gt; 0">
          <xsl:text> </xsl:text>
          <xsl:call-template name="tex"><xsl:with-param name="text" select="$is_performed"/></xsl:call-template>
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
        <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.uc_times'"/></xsl:call-template>
        <xsl:text>/</xsl:text>
        <xsl:call-template name="label"><xsl:with-param name="key" select="concat('archetype.enum_units.', unit)"/></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="tbd"/>
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
        <xsl:call-template name="tbd"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- "[CODE] Name" of the (single) target of a trace, linked if it is  -->
  <!-- in the document (trace_target, core/properties.xsl), or "To Be    -->
  <!-- Determined" if the trace has no (existing) target                 -->
  <xsl:template name="use_case_trace_link">
    <xsl:param name="trace"/>
    <xsl:variable name="target_object" select="//object[@id=$trace/trace[1]/@target]"/>
    <xsl:choose>
      <xsl:when test="$target_object">
        <xsl:call-template name="trace_target">
          <xsl:with-param name="target_object" select="$target_object"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="tbd"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
