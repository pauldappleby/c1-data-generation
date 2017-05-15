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
    <xsl:import href="c1-data-generation-content.xsl"/>
    
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="rd c1 uuid"/>
    
    <xsl:param name="numWorks">10</xsl:param>
    <xsl:param name="numWorkContainers">0</xsl:param>
    <xsl:param name="env">dev</xsl:param>
    <xsl:param name="outputFolder">generated-data</xsl:param>
    
    <xsl:variable name="envs">
        <env id="dev" schema="http://schema.pearson.com" data="https://data.pearson.com"/>
        <env id="test" schema="http://schema.pearson.com" data="https://data.pearson.com"/>
    </xsl:variable>
    
    <xsl:variable name="words" select="document('seed-data/words.xml')/words"/>
    <xsl:variable name="subjects" select="document('seed-data/subject.xml')/rdf:RDF/rdf:Description[rdf:type/@rdf:resource = 'http://www.w3.org/2004/02/skos/core#Concept']/@rdf:about" as="xs:string+"/>
    <xsl:variable name="context" select="document('context.xml')"/>   
    <xsl:variable name="type" select="document('seed-data/types.xml')/types"/>
    <xsl:variable name="formats" select="document('seed-data/formats.xml')/formats"/>
    <xsl:variable name="keywords" select="$words/(adjectives | nouns)/*"/>
        
    <xsl:template name="generateOutput">
        <xsl:variable name="workManifestationCounts" select="rd:random-sequence($numWorks)"/>
        <xsl:variable name="processingStructure" as="element()">
            <documents>
                <xsl:for-each select="1 to $numWorks">
                    <xsl:variable name="uuid" select="c1:getUUID()"/>
                    <xsl:variable name="workIndex" select="position()"></xsl:variable>
                    <xsl:variable name="workExampleCount" select="xs:integer(floor($workManifestationCounts[$workIndex] * 5))" as="xs:integer"/>
                    <document shortType="Work" type="https://schema.person.com/ns/content/Work" uuid="{$uuid}">
                        <relation IRI="https://schema.org/workExample" shortName="workExample">
                           <xsl:for-each select="1 to $workExampleCount">
                               <document shortType="Manifestation" type="https://schema.person.com/ns/content/Manifestation" uuid="{c1:getUUID()}"/>
                            </xsl:for-each>
                        </relation>
                    </document>
                </xsl:for-each>
            </documents>
        </xsl:variable>
        <xsl:apply-templates select="$processingStructure"/>
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/curl-file.bat" method="text">
            <xsl:text>md results&#10;</xsl:text>
            <xsl:variable name="documentCount" select="count($processingStructure//document)"/>
            <xsl:for-each select="$processingStructure//document">
                <xsl:text>timeout 1&#10;</xsl:text>
                <xsl:text>echo </xsl:text>
                <xsl:value-of select="concat(position(), ' of ', $documentCount)"/>
                <xsl:text>&#10;curl -X POST -d @json/</xsl:text>
                <xsl:value-of select="lower-case(@shortType)"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="lower-case(@shortType)"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="@uuid"/>
                <xsl:text>.json -H "Content-Type: application/json" -H "Authorization: Basic Ymx1ZWJlcnJ5OmVAQkhSTUF2M2V5S2xiT1VjS0tAWl56Q0ZhMDRtYw==" -H "X-Roles: LearningAdmin,ContentMetadataAdmin" -k https://develop-data.pearsoncms.net/api/api/thing?db=qa0 -o results/results-</xsl:text>
                <xsl:value-of select="@uuid"/>
                <xsl:text>.txt -i&#10;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>                
    </xsl:template>
    
    <xsl:template match="documents">
        <xpf:map>
            <xsl:apply-templates select="document"/>
        </xpf:map>
    </xsl:template>

    <xsl:template match="relation">
        <xsl:apply-templates select="document"/>
    </xsl:template>
    
</xsl:stylesheet>