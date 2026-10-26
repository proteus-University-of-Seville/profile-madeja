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
       An association may have both attributes and roles as children: they
       are shown in two separate rows, "Attributes" (only if it has any) and
       "Roles", instead of a single "Contains" row, as in the default
       template. The template has priority="1" to override the default
       archetype template (any_archetype.xsl).
  -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' association ')]"
    name="association_template"
    priority="1"
  >
    <xsl:variable name="attributes" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' attribute ')]"/>
    <xsl:variable name="roles" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' role ')]"/>

    <xsl:variable name="children_rows">
      <xsl:if test="$attributes">
        <xsl:call-template name="renderChildrenListRow">
          <xsl:with-param name="children" select="$attributes"/>
          <xsl:with-param name="label_key" select="'xslt.attributes'"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$roles">
        <xsl:call-template name="renderChildrenListRow">
          <xsl:with-param name="children" select="$roles"/>
          <xsl:with-param name="label_key" select="'xslt.roles'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="extra_rows" select="$children_rows"/>
      <xsl:with-param name="show_children" select="false()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
