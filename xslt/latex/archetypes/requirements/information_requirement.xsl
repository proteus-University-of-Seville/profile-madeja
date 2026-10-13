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

  <!-- Its specific-data children are shown as a compact list ("name:     -->
  <!-- description" per item) in a row right after the description,      -->
  <!-- instead of the default nested-card rendering, since each specific -->
  <!-- datum is just a short name/description pair, not a full object    -->
  <!-- worth a card of its own.                                          -->

  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' information-requirement ')]"
    name="information_requirement_template"
    priority="1"
  >
    <xsl:call-template name="generate_table">
      <xsl:with-param name="children_style" select="'list'"/>
      <xsl:with-param name="children_position" select="'after_description'"/>
      <xsl:with-param name="children_label_key" select="'xslt.specific_data'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
