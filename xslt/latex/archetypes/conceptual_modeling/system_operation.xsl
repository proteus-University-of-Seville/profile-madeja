<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : system_operation.xsl                                     -->
<!-- Content : PROTEUS LaTeX XSLT for system operation                  -->
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
       The children of a system operation are always parameters, so the row
       that lists them is labelled "Parameters" instead of "Contains", as in
       the default template. The template has priority="1" to override the
       default archetype template (any_archetype.xsl).
  -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' system-operation ')]"
    name="system_operation_template"
    priority="1"
  >
    <xsl:call-template name="generate_table">
      <xsl:with-param name="children_label_key" select="'xslt.parameters'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
