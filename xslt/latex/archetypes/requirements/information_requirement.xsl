<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : information_requirement.xsl                              -->
<!-- Content : PROTEUS LaTeX XSLT for information-requirement           -->
<!-- Author  : Amador Durán Toro                                        -->
<!-- Date    : 2026/10/08                                               -->
<!-- Version : 1.0                                                      -->
<!-- ================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- ================================================================== -->
  <!-- information-requirement template                                   -->
  <!-- ================================================================== -->

  <!-- As in the default template, its specific-data children are shown   -->
  <!-- as a compact bulleted list ("name: description" per item) in a row -->
  <!-- right after the description, instead of nested cards.              -->

  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' information-requirement ')]"
    name="information_requirement_template"
    priority="1"
  >
    <xsl:variable name="description_and_specific_data_rows">
      <!-- Description -->
      <xsl:for-each select="properties/*[@name='description']">
        <xsl:call-template name="generate_property_row"/>
      </xsl:for-each>

      <!-- Specific data -->
      <xsl:if test="children/*">
        <xsl:call-template name="label">
          <xsl:with-param name="key" select="'xslt.specific_data'"/>
        </xsl:call-template>
        <xsl:text> &amp; </xsl:text>
        <xsl:call-template name="renderChildrenItems">
          <xsl:with-param name="children" select="children/*"/>
        </xsl:call-template>
        <xsl:text> \\ \hline&#10;</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="excluded_properties" select="',:Proteus-name,:Proteus-code,:Proteus-date,version,authors,sources,description,'"/>
      <xsl:with-param name="extra_rows_before" select="$description_and_specific_data_rows"/>
      <xsl:with-param name="show_children" select="false()"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
