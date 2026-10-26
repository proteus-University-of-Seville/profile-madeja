<?xml version="1.0" encoding="utf-8"?>

<!-- ================================================================== -->
<!-- File    : entity_class.xsl                                         -->
<!-- Content : PROTEUS LaTeX XSLT for entity class                      -->
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
       The children of an entity class are always attributes, so the row
       that lists them is labelled "Attributes" instead of "Contains", as
       in the default template. Abstract classes are marked in the header
       instead of a row: the name in italics, as in UML, followed by
       "(abstract)". The template has priority="1" to override the default
       archetype template (any_archetype.xsl).
  -->
  <xsl:template
    match="object[contains(concat(' ', normalize-space(@classes), ' '),' entity-class ')]"
    name="entity_class_template"
    priority="1"
  >
    <xsl:variable name="is_abstract" select="properties/*[@name='is-abstract'] = 'true'"/>

    <xsl:call-template name="generate_table">
      <xsl:with-param name="children_label_key" select="'xslt.attributes'"/>
      <xsl:with-param name="name_italic" select="$is_abstract"/>
      <xsl:with-param name="postfix">
        <xsl:if test="$is_abstract">
          <xsl:value-of select="proteus-utils:i18n('xslt.entity_abstract')"/>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="excluded_properties" select="',:Proteus-name,:Proteus-code,:Proteus-date,version,authors,sources,is-abstract,'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
