<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : association.xsl                                           -->
<!-- Content : PROTEUS default XSLT for conceptual modeling archetypes                  -->
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

  <!-- ================================================================== -->
  <!-- association template                                              -->
  <!-- ================================================================== -->

  <!-- An association is named after a verb, so that "role1 name role2"  -->
  <!-- reads as a sentence of the problem domain. Its header shows it as -->
  <!-- name( role1, role2, ..., roleN ).                                 -->
  <!-- An association may have both attributes and roles as children:    -->
  <!-- they are shown in two separate rows, "Attributes" (only if it has -->
  <!-- any) and "Roles", instead of a single "Contains" row. Each role   -->
  <!-- is shown as name : Type (lower bound, upper bound).               -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' association ')]"
    name="association_template"
    priority="1"
  >
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
      <xsl:call-template name="renderChildren">
        <xsl:with-param name="children" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' attribute ')]"/>
        <xsl:with-param name="style" select="'list'"/>
        <xsl:with-param name="label_key" select="'xslt.attributes'"/>
      </xsl:call-template>
      <xsl:if test="$roles">
        <tr class="children_row">
          <th>
            <xsl:value-of select="proteus-utils:i18n('xslt.roles')"/>
          </th>
          <td class="children_column">
            <ul class="children_list">
              <xsl:for-each select="$roles">
                <xsl:call-template name="association_role"/>
              </xsl:for-each>
            </ul>
          </td>
        </tr>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="name" select="string($name)"/>
      <xsl:with-param name="extra_rows" select="$children_rows"/>
      <xsl:with-param name="show_children" select="false()"/>
    </xsl:call-template>

  </xsl:template>

  <!-- ================================================================== -->
  <!-- Role of an association: name : Type (lower bound, upper bound),    -->
  <!-- followed by "{ordered}" if it is ordered and by its description,   -->
  <!-- if any. The type links to its entity class. The bounds are only    -->
  <!-- shown if at least one of them is set.                              -->
  <!-- current() is a role                                                -->
  <!-- ================================================================== -->

  <xsl:template name="association_role">
    <xsl:variable name="type" select="//object[@id = current()/properties/traceProperty[@name='type']/trace/@target][1]"/>
    <xsl:variable name="lower" select="normalize-space(properties/*[@name='multiplicity-lower-bound'])"/>
    <xsl:variable name="upper" select="normalize-space(properties/*[@name='multiplicity-upper-bound'])"/>
    <xsl:variable name="description" select="properties/*[@name='description']"/>

    <li id="{@id}" data-proteus-id="{@id}">
      <strong class="child_name">
        <xsl:value-of select="properties/*[@name=':Proteus-name']"/>
      </strong>
      <xsl:if test="$type">
        <xsl:text> : </xsl:text>
        <a href="#{$type/@id}" onclick="selectAndNavigate(`{$type/@id}`, event)">
          <xsl:value-of select="$type/properties/*[@name=':Proteus-name']"/>
        </a>
      </xsl:if>
      <xsl:if test="$lower != '' or $upper != ''">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$lower"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$upper"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="properties/*[@name='ordered'] = 'true'">
        <xsl:text> </xsl:text>
        <xsl:value-of select="proteus-utils:i18n('xslt.role_ordered')"/>
      </xsl:if>
      <xsl:if test="normalize-space($description) != ''">
        <xsl:text>: </xsl:text>
        <xsl:call-template name="generate_markdown">
          <xsl:with-param name="content" select="$description"/>
        </xsl:call-template>
      </xsl:if>
    </li>
  </xsl:template>

</xsl:stylesheet>
