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

  <!-- An association may have both attributes and roles as children:    -->
  <!-- they are shown in two separate rows, "Attributes" (only if it has -->
  <!-- any) and "Roles", instead of a single "Contains" row.             -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' association ')]"
    name="association_template"
    priority="1"
  >
    <xsl:variable name="children_rows">
      <xsl:call-template name="renderChildren">
        <xsl:with-param name="children" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' attribute ')]"/>
        <xsl:with-param name="style" select="'list'"/>
        <xsl:with-param name="label_key" select="'xslt.attributes'"/>
      </xsl:call-template>
      <xsl:call-template name="renderChildren">
        <xsl:with-param name="children" select="children/object[contains(concat(' ', normalize-space(@classes), ' '),' role ')]"/>
        <xsl:with-param name="style" select="'list'"/>
        <xsl:with-param name="label_key" select="'xslt.roles'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="extra_rows" select="$children_rows"/>
      <xsl:with-param name="show_children" select="false()"/>
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>
