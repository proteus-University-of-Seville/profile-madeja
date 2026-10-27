<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : association.xsl                                          -->
<!-- Content : PROTEUS LaTeX XSLT for association                       -->
<!-- Author  : Amador Durán Toro                                        -->
<!-- Date    : 2026/10/26                                               -->
<!-- Version : 1.0                                                      -->
<!-- ================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- NOTE
       An association is named after a verb, so that "role1 name role2"
       reads as a sentence of the problem domain. Its header shows it as
       name( role1, role2, ..., roleN ).
       An association may have both attributes and roles as children: they
       are shown in two separate rows, "Attributes" (only if it has any) and
       "Roles", instead of a single "Contains" row, as in the default
       template. Each role is shown as name : Type (lower bound, upper
       bound). The template has priority="1" to override the default
       archetype template (any_archetype.xsl).
  -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' association ')]"
    name="association_template"
    priority="1"
  >
    <xsl:variable name="attributes" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' attribute ')]"/>
    <xsl:variable name="roles" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' role ')]"/>

    <xsl:variable name="name">
      <xsl:value-of select="properties/*[@name=':Proteus-name']"/>
      <xsl:text>( </xsl:text>
      <xsl:for-each select="$roles">
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:value-of select="properties/*[@name=':Proteus-name']"/>
      </xsl:for-each>
      <xsl:text> )</xsl:text>
    </xsl:variable>

    <xsl:variable name="children_rows">
      <xsl:if test="$attributes">
        <xsl:call-template name="renderChildrenListRow">
          <xsl:with-param name="children" select="$attributes"/>
          <xsl:with-param name="label_key" select="'xslt.attributes'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$roles">
        <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.roles'"/></xsl:call-template>
        <xsl:text> &amp; \begin{itemize}&#10;</xsl:text>
        <xsl:for-each select="$roles">
          <xsl:call-template name="association_role"/>
        </xsl:for-each>
        <xsl:text>\end{itemize} \\ \hline&#10;</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="name" select="string($name)"/>
      <xsl:with-param name="extra_rows" select="$children_rows"/>
      <xsl:with-param name="show_children" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Role of an association: name : Type (lower bound, upper bound),    -->
  <!-- followed by "{ordered}" if it is ordered and by its description,   -->
  <!-- if any, as an item of a list (see                                  -->
  <!-- renderChildrenItems). The type links to its entity class if it is  -->
  <!-- in the rendered document. The bounds are only shown if at least    -->
  <!-- one of them is set. current() is a role.                           -->
  <xsl:template name="association_role">
    <xsl:variable name="type" select="//object[@id = current()/properties/traceProperty[@name='type']/trace/@target][1]"/>
    <xsl:variable name="type_in_document"
      select="$type/ancestor::object[contains(concat(' ', normalize-space(@classes), ' '), ' :Proteus-document ')]/@id = proteus-utils:current_document()"/>
    <xsl:variable name="lower" select="normalize-space(properties/*[@name='multiplicity-lower-bound'])"/>
    <xsl:variable name="upper" select="normalize-space(properties/*[@name='multiplicity-upper-bound'])"/>
    <xsl:variable name="description" select="properties/*[@name='description']"/>

    <!-- The paragraph must start before the anchor (\phantomsection), -->
    <!-- or it adds an empty line above the item                       -->
    <xsl:text>\item\leavevmode</xsl:text>
    <xsl:call-template name="anchor"/>
    <xsl:text>\textbf{</xsl:text>
    <xsl:call-template name="tex">
      <xsl:with-param name="text" select="properties/*[@name=':Proteus-name']"/>
    </xsl:call-template>
    <xsl:text>}</xsl:text>
    <xsl:if test="$type">
      <xsl:text> : </xsl:text>
      <xsl:if test="$type_in_document">
        <xsl:text>\hyperref[</xsl:text>
        <xsl:value-of select="$type/@id"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text>{</xsl:text>
      <xsl:call-template name="tex">
        <xsl:with-param name="text" select="$type/properties/*[@name=':Proteus-name']"/>
      </xsl:call-template>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="$lower != '' or $upper != ''">
      <xsl:text> (</xsl:text>
      <xsl:call-template name="tex"><xsl:with-param name="text" select="$lower"/></xsl:call-template>
      <xsl:text>, </xsl:text>
      <xsl:call-template name="tex"><xsl:with-param name="text" select="$upper"/></xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:if test="properties/*[@name='ordered'] = 'true'">
      <xsl:text> </xsl:text>
      <xsl:call-template name="label"><xsl:with-param name="key" select="'xslt.role_ordered'"/></xsl:call-template>
    </xsl:if>
    <xsl:if test="normalize-space($description) != ''">
      <xsl:text>: </xsl:text>
      <xsl:call-template name="generate_markdown">
        <xsl:with-param name="content" select="$description"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
