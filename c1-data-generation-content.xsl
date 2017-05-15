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

    <xsl:import href="c1-data-generation-utils.xsl"/>
    
    <xsl:template match="document[@type = 'WorkContainer']">
        <xsl:param name="keywordCount" select="xs:integer(floor(rd:random-sequence(1) * 5))" as="xs:integer?"/>
        <xsl:param name="subjectCount" select="xs:integer(floor(rd:random-sequence(1) * 5))" as="xs:integer?"/>
        <xpf:map>
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Work</xsl:with-param>
                <xsl:with-param name="extendedTypes" select="('Container')"/>
            </xsl:call-template>
            <xpf:string key="id">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:map key="name">
                <xpf:string key="en">
                    <xsl:value-of select="c1:getName()"/>
                </xpf:string>
            </xpf:map>
            <xsl:apply-templates select="relation" mode="AddRelationships"/>
            <xsl:call-template name="getDateCreated"/>
            <xsl:call-template name="getKeywords">
                <xsl:with-param name="keysCount" select="$keywordCount"/>
            </xsl:call-template>
            <xsl:call-template name="getSubjects">
                <xsl:with-param name="subjectCount" select="$subjectCount"/>               
            </xsl:call-template>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'Work']">
        <xsl:param name="keywordCount" select="xs:integer(floor(rd:random-sequence(1) * 5))" as="xs:integer?"/>
        <xsl:param name="subjectCount" select="xs:integer(floor(rd:random-sequence(1) * 5))" as="xs:integer?"/>
        <xpf:map>
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Work</xsl:with-param>
            </xsl:call-template>
            <xpf:string key="id">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:map key="name">
                <xpf:string key="en">
                    <xsl:value-of select="c1:getName()"/>
                </xpf:string>
            </xpf:map>
            <xsl:apply-templates select="parent::relation" mode="AddReverseRelationships"/>
            <xsl:apply-templates select="relation" mode="AddRelationships"/>
            <xsl:call-template name="getDateCreated"/>
            <xsl:call-template name="getKeywords">
                <xsl:with-param name="keysCount" select="$keywordCount"/>
            </xsl:call-template>
            <xsl:call-template name="getSubjects">
                <xsl:with-param name="subjectCount" select="$subjectCount"/>               
            </xsl:call-template>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'Manifestation']">
        <xpf:map>
            <xsl:variable name="uuid" select="@uuid"/>
            <xsl:variable name="getTypes">
                <xsl:call-template name="getType">
                    <xsl:with-param name="baseType">Manifestation</xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <xsl:copy-of select="$getTypes"/>
            <xpf:string key="id">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:map key="name">
                <xpf:string key="en">
                    <xsl:value-of select="c1:getName()"/>
                </xpf:string>
            </xpf:map>
            <xsl:apply-templates select="parent::relation" mode="AddReverseRelationships"/>
            <xsl:call-template name="getDateCreated"/>
            <xsl:call-template name="getFormat">
                <xsl:with-param name="types" select="$getTypes"/>
            </xsl:call-template>
        </xpf:map>
    </xsl:template>
    
    <xsl:template match="relation" mode="AddRelationships">
        <xsl:variable name="relatedUrns" select="document/@urn"/>
        <xsl:if test="not(empty($relatedUrns))">
            <xpf:array key="{@shortName}">
                <xsl:for-each select="$relatedUrns">
                    <xpf:string>
                        <xsl:value-of select="."/>
                    </xpf:string>
                </xsl:for-each>
            </xpf:array>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="relation[@reverseShortName]" mode="AddReverseRelationships">
        <xpf:array key="{@reverseShortName}">
            <xpf:string>
                <xsl:value-of select="parent::document/@urn"/>
            </xpf:string>
        </xpf:array>
    </xsl:template>
    
</xsl:stylesheet>