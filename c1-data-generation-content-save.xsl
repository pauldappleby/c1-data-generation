<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xpf="http://www.w3.org/2005/xpath-functions"
    xmlns:jld="https://example.com"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns:uuid="java:java.util.UUID"
    xmlns:rd="http://exslt.org/random"
    xmlns:c1="http://schema.pearson.com/ns/c1">    

    <xsl:template match="document[@type = ('GoalFramework', 'EducationalGoal', 'MatchAxiom', 'IdentifierAxiom', 'Manifestation', 'Work', 'Work Container')][not(parent::relation[@embed = 'true'])]"
        priority="100">
        <xsl:param name="outputFolder" tunnel="yes"/>
        <xsl:param name="env" tunnel="yes"/>
        <xsl:variable name="documentContent" as="element()">
            <xsl:next-match/>
        </xsl:variable>
        <xsl:call-template name="saveDocument">
            <xsl:with-param name="testSet" select="@testSet"/>
            <xsl:with-param name="documentType" select="@type"/>
            <xsl:with-param name="documentUuid" select="@uuid"/>
            <xsl:with-param name="documentURN" select="@urn"/>
            <xsl:with-param name="documentContent" select="$documentContent"/>
            <xsl:with-param name="outputFolder" select="$outputFolder"/>
            <xsl:with-param name="env" select="$env"/>
        </xsl:call-template>
        <xsl:apply-templates select="*[not(@embed = 'true')]"/>
    </xsl:template>

    <xsl:template match="patch" priority="100">
        <xsl:param name="outputFolder" tunnel="yes"/>
        <xsl:param name="env" tunnel="yes"/>
        <xsl:variable name="documentContent" as="element()+">
            <xsl:next-match/>
        </xsl:variable>
        <xsl:call-template name="savePatch">
            <xsl:with-param name="testSet" select="@testSet"/>
            <xsl:with-param name="patchUuid" select="@uuid"/>
            <xsl:with-param name="documentContent" select="$documentContent"/>
            <xsl:with-param name="outputFolder" select="$outputFolder"/>
            <xsl:with-param name="env" select="$env"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>