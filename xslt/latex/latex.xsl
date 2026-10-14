<?xml version="1.0" encoding="utf-8"?>

<!-- ======================================================== -->
<!-- File    : latex.xsl                                      -->
<!-- Content : PROTEUS LaTeX XSLT template (entry point)      -->
<!-- Author  : Amador Durán Toro                              -->
<!-- Date    : 2026/10/07                                     -->
<!-- Version : 1.0                                            -->
<!-- ======================================================== -->
<!-- LaTeX counterpart of the default template. It has the    -->
<!-- same structure (core modules and one module per          -->
<!-- archetype) and generates a LaTeX document that uses      -->
<!-- resources/proteus.sty, the counterpart of default.css.   -->
<!--                                                          -->
<!-- Every text taken from the project must be escaped with   -->
<!-- the 'tex' named template (proteus-utils:latex_escape)    -->
<!-- and Markdown must be converted with generate_markdown    -->
<!-- (proteus-utils:markdown_to_latex). Labels and hyperlinks -->
<!-- use the object ids.                                      -->
<!-- ======================================================== -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:proteus="http://proteus.us.es"
  xmlns:proteus-utils="http://proteus.us.es/utils"
>
  <!-- Output: plain text (LaTeX source) -->
  <xsl:output method="text" encoding="utf-8"/>
  <xsl:strip-space elements="*"/>

  <!-- Core modules -->
  <xsl:include href="core/utilities.xsl" />
  <xsl:include href="core/generate_table.xsl" />
  <xsl:include href="core/properties.xsl" />
  <xsl:include href="core/cover.xsl" />
  <xsl:include href="core/document.xsl" />

  <!-- Archetype modules, grouped by the same category folders used in -->
  <!-- archetypes/<lang>/objects/. Only archetypes with a custom HTML  -->
  <!-- rendering have a module; the rest use the default property card -->
  <!-- (any_archetype.xsl) with the accent colour of their class.      -->

  <!-- 00_general -->
  <xsl:include href="archetypes/general/section.xsl" />
  <xsl:include href="archetypes/general/appendix.xsl" />
  <xsl:include href="archetypes/general/paragraph.xsl" />
  <xsl:include href="archetypes/general/comment.xsl" />
  <xsl:include href="archetypes/general/glossary_item.xsl" />
  <xsl:include href="archetypes/general/bibliography_item.xsl" />
  <xsl:include href="archetypes/general/figure.xsl" />
  <xsl:include href="archetypes/general/symbolic_link.xsl" />
  <xsl:include href="archetypes/general/meeting.xsl" />

  <!-- 01_business_analysis -->
  <xsl:include href="archetypes/business_analysis/business_objective.xsl" />

  <!-- 02_requirements -->
  <xsl:include href="archetypes/requirements/general_requirement.xsl" />
  <xsl:include href="archetypes/requirements/information_requirement.xsl" />
  <xsl:include href="archetypes/requirements/system_actor.xsl" />
  <xsl:include href="archetypes/requirements/use_case.xsl" />

  <!-- 03_conceptual_modeling -->
  <xsl:include href="archetypes/conceptual_modeling/enumeration.xsl" />

  <!-- 04_req_management -->
  <xsl:include href="archetypes/req_management/traceability_matrix.xsl" />

  <!-- Default archetype module -->
  <xsl:include href="archetypes/any_archetype.xsl" />

  <!-- It matches the XML root (project) and applies templates to the current document -->
  <xsl:template match="project">
    <xsl:variable name="currentDocumentId" select="proteus-utils:current_document()"/>
    <xsl:apply-templates select="documents/object[@id=$currentDocumentId]"/>
  </xsl:template>

</xsl:stylesheet>
