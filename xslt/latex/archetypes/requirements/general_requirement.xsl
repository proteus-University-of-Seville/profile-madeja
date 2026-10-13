<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : general_requirement.xsl                                             -->
<!-- Content : PROTEUS LaTeX XSLT for general-requirement                                 -->
<!-- Author  : Amador Durán Toro                                        -->
<!-- Date    : 2026/10/13                                               -->
<!-- Version : 1.0                                                      -->
<!-- ================================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- NOTE
       The children of the object are shown as a compact list inside its
       table (see renderChildrenItems in core/generate_table.xsl), as in the
       default template. The template has priority="1" to override the
       default archetype template (any_archetype.xsl).
  -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' general-requirement ')]"
    name="general_requirement_template"
    priority="1"
  >
    <xsl:call-template name="generate_table">
      <xsl:with-param name="children_style" select="'list'"/>
      <xsl:with-param name="children_position" select="'after_description'"/>
      <xsl:with-param name="children_label_key" select="'xslt.sub_requirements'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
