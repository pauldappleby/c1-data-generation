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
    
    <xsl:template match="document[@type = 'https://schema.person.com/ns/content/Work']">
        <xsl:variable name="documentContent" as="element()">
            <xpf:map>
                <xsl:call-template name="getType">
                    <xsl:with-param name="baseType">Work</xsl:with-param>
                </xsl:call-template>
                <xpf:string key="id">
                    <xsl:value-of select="concat('urn:pearson:work:', @uuid)"/>
                </xpf:string>
                <xpf:map key="name">
                    <xpf:string key="en">
                        <xsl:value-of select="c1:getName()"/>
                    </xpf:string>
                </xpf:map>
                <xsl:variable name="manifestationUUIDs" select="relation[@shortName = 'workExample']/document/@uuid"/>
                <xsl:if test="not(empty($manifestationUUIDs))">
                    <xpf:array key="workExample">
                        <xsl:for-each select="$manifestationUUIDs">
                            <xpf:string>
                                <xsl:text>urn:pearson:manifestation:</xsl:text>
                                <xsl:value-of select="."/>
                            </xpf:string>
                        </xsl:for-each>
                    </xpf:array>
                </xsl:if>
                <xsl:call-template name="getDateCreated"/>
                <xsl:call-template name="getKeywords"/>
                <xsl:call-template name="getSubjects"/>
            </xpf:map>
        </xsl:variable>
        <xsl:call-template name="saveDocument">
            <xsl:with-param name="documentType" select="'Work'"/>
            <xsl:with-param name="documentUuid" select="@uuid"/>
            <xsl:with-param name="documentContent" select="$documentContent"/>
            <xsl:with-param name="outputFolder" select="$outputFolder"/>
            <xsl:with-param name="env" select="$env"/>
        </xsl:call-template>
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="document[@type = 'https://schema.person.com/ns/content/Manifestation']">
        <xsl:variable name="documentContent" as="element()">
            <xpf:map>
                <xsl:variable name="workUuid" select="parent::relation/parent::document/@uuid"/>
                <xsl:variable name="uuid" select="@uuid"/>
                <xsl:variable name="getTypes">
                    <xsl:call-template name="getType">
                        <xsl:with-param name="baseType">Manifestation</xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:copy-of select="$getTypes"/>
                <xpf:string key="id">
                    <xsl:value-of select="concat('urn:pearson:manifestation:', @uuid)"/>
                </xpf:string>
                <xpf:map key="name">
                    <xpf:string key="en">
                        <xsl:value-of select="c1:getName()"/>
                    </xpf:string>
                </xpf:map>
                <xsl:if test="$workUuid">
                    <xpf:string key="exampleOfWork">
                        <xsl:text>urn:pearson:work:</xsl:text>
                        <xsl:value-of select="$workUuid"/>
                    </xpf:string>
                </xsl:if>
                <xsl:call-template name="getDateCreated"/>
                <xsl:call-template name="getFormat">
                    <xsl:with-param name="types" select="$getTypes"/>
                </xsl:call-template>
            </xpf:map>
        </xsl:variable>
        <xsl:call-template name="saveDocument">
            <xsl:with-param name="documentType" select="'Manifestation'"/>
            <xsl:with-param name="documentUuid" select="@uuid"/>
            <xsl:with-param name="documentContent" select="$documentContent"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>