<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : system_actor.xsl                                           -->
<!-- Content : PROTEUS default XSLT for requirements archetypes                  -->
<!-- Author  : Amador Durán Toro                                        -->
<!-- Date    : 2026/09/23                                               -->
<!-- Version : 1.0                                                      -->
<!-- ================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- ================================================================ -->
  <!-- NOTE #1
       match expression gets rid of leading and trailing spaces in the
       @classes attribute, and adds a space at the beginning and end of
       the class name to avoid matching substrings. This way, we can
       check if a class name is present in the @classes attribute by
       using contains().

       NOTE #2
       This template has priority="1" to avoid being overridden by
       templates of potential subclasses. Subclasses should have their own
       templates with higher priority, and they should call the superclass
       template by name if they want to reuse it.
  -->
  <!-- ================================================================== -->

  <!--
    Uncomment and modify this template as needed. The default behavior for
    all Proteus objects is generating a table.
  -->

  <!-- ================================================================== -->
  <!-- Participation of a system actor in the use cases                   -->
  <!-- ================================================================== -->

  <!-- A system actor participates in the use cases that:                  -->
  <!-- - the user declared in its participates-in property;                -->
  <!-- - have a step (at any depth, e.g. in an exception) whose actor or   -->
  <!--   secondary actor is the actor: deduced from the steps;             -->
  <!-- - one of the actors it inherits from (inherits-from, transitively)  -->
  <!--   participates in, if they are not already any of the above:        -->
  <!--   inherited.                                                        -->

  <!-- Use cases by the actors of their steps -->
  <xsl:key name="use_case_by_actor"
    match="object[contains(concat(' ', normalize-space(@classes), ' '), ' use-case ')]"
    use="descendant::properties/traceProperty[@name='actor' or @name='secondary-actor']/trace/@target"
  />

  <!-- Ids, between commas, of the visited actors and of all the actors  -->
  <!-- they inherit from. The visited ones are not visited again, which  -->
  <!-- stops the cycles.                                                  -->
  <xsl:template name="actor_ancestor_ids">
    <xsl:param name="actors"/>
    <xsl:param name="visited"/>

    <xsl:variable name="parents"
      select="//object[@id = $actors/properties/traceProperty[@name='inherits-from']/trace/@target][not(contains($visited, concat(',', @id, ',')))]"
    />
    <xsl:choose>
      <xsl:when test="$parents">
        <xsl:variable name="all_visited">
          <xsl:value-of select="$visited"/>
          <xsl:for-each select="$parents"><xsl:value-of select="@id"/>,</xsl:for-each>
        </xsl:variable>
        <xsl:call-template name="actor_ancestor_ids">
          <xsl:with-param name="actors" select="$parents"/>
          <xsl:with-param name="visited" select="string($all_visited)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$visited"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->
  <!-- system-actor template                                              -->
  <!-- ================================================================== -->

  <!-- The use cases it participates in are shown in the participates-in  -->
  <!-- row, after the other properties: the ones declared by the user,    -->
  <!-- without a mark, the ones deduced from the steps of the use cases   -->
  <!-- and the ones inherited from other actors, with their origin.       -->

  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' system-actor ')]"
    name="system_actor_template"
    priority="1"
  >
    <xsl:variable name="participation_row">
      <xsl:call-template name="actor_participation_row"/>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="excluded_properties" select="',:Proteus-name,:Proteus-code,:Proteus-date,version,authors,sources,participates-in,'"/>
      <xsl:with-param name="extra_rows" select="$participation_row"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Row with the use cases the actor participates in, if there are any -->
  <xsl:template name="actor_participation_row">
    <xsl:variable name="self_id" select="@id"/>

    <!-- Declared by the user and deduced from the steps -->
    <xsl:variable name="declared"
      select="//object[@id = current()/properties/traceProperty[@name='participates-in']/trace/@target]"
    />
    <xsl:variable name="deduced" select="key('use_case_by_actor', $self_id)"/>
    <xsl:variable name="own" select="$declared | $deduced"/>

    <!-- Inherited from the actors it inherits from, if they are not its own -->
    <xsl:variable name="visited_ids">
      <xsl:call-template name="actor_ancestor_ids">
        <xsl:with-param name="actors" select="."/>
        <xsl:with-param name="visited" select="concat(',', $self_id, ',')"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ancestors"
      select="//object[@id != $self_id][contains(string($visited_ids), concat(',', @id, ','))]"
    />
    <xsl:variable name="ancestors_use_cases"
      select="//object[@id = $ancestors/properties/traceProperty[@name='participates-in']/trace/@target]
              | key('use_case_by_actor', $ancestors/@id)"
    />
    <xsl:variable name="inherited" select="$ancestors_use_cases[not(@id = $own/@id)]"/>

    <xsl:if test="$own or $inherited">
      <tr>
        <th><xsl:value-of select="proteus-utils:i18n('archetype.prop_name.participates-in')"/></th>
        <td colspan="1">
          <ul class="traces">
            <xsl:for-each select="$own | $inherited">
              <xsl:sort select="properties/*[@name=':Proteus-code']"/>
              <xsl:sort select="properties/*[@name=':Proteus-name']"/>
              <xsl:variable name="use_case" select="."/>
              <li>
                <xsl:call-template name="trace_target_link">
                  <xsl:with-param name="target_object" select="."/>
                </xsl:call-template>
                <xsl:choose>
                  <!-- Declared by the user: no mark -->
                  <xsl:when test="@id = $declared/@id"/>
                  <xsl:when test="@id = $deduced/@id">
                    <xsl:text> </xsl:text>
                    <span class="trace_origin">(<xsl:value-of select="proteus-utils:i18n('xslt.trace_derived')"/>)</span>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text> </xsl:text>
                    <span class="trace_origin">
                      <xsl:text>(</xsl:text>
                      <xsl:value-of select="proteus-utils:i18n('xslt.trace_inherited')"/>
                      <xsl:text> </xsl:text>
                      <xsl:for-each select="$ancestors[properties/traceProperty[@name='participates-in']/trace/@target = $use_case/@id or key('use_case_by_actor', @id)[@id = $use_case/@id]]">
                        <xsl:if test="position() > 1">, </xsl:if>
                        <xsl:call-template name="trace_target_link">
                          <xsl:with-param name="target_object" select="."/>
                        </xsl:call-template>
                      </xsl:for-each>
                      <xsl:text>)</xsl:text>
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </xsl:for-each>
          </ul>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
