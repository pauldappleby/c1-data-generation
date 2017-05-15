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

    <xsl:import href="c1-data-generation-content.xsl"/>
    
    <!-- We break out the save features into a separate file to make testing possible -->
    <!-- Save templates have a higher priority ensuring they get executed. The lower priority templates are then testable -->
    <xsl:import href="c1-data-generation-content-save.xsl"/>
    
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="rd c1 uuid"/>
    
    <xsl:param name="numWorks">10</xsl:param>
    <xsl:param name="numWorkContainers">10</xsl:param>
    <xsl:param name="env">dev</xsl:param>
    <xsl:param name="outputFolder">generated-data</xsl:param>
               
    <xsl:template name="generateOutput">
        
        <!-- We generate an XML structure defining the document types to generate and the relationships between them -->
        <xsl:variable name="processingStructure" as="element()">
            <documents>
 
                <xsl:variable name="hasPartCounts" select="rd:random-sequence($numWorkContainers)"/>
                <xsl:for-each select="1 to $numWorkContainers">
                    <xsl:variable name="uuid" select="c1:getUUID()"/>
                    <xsl:variable name="hasPartIndex" select="position()"/>
                    <xsl:variable name="hasPartCount" select="xs:integer(floor($hasPartCounts[$hasPartIndex] * 5) + 1)" as="xs:integer"/>
                    <document type="WorkContainer" uuid="{$uuid}" urn="urn:pearson:work:{$uuid}">
                        <relation IRI="http://schema.org/hasPart" shortName="hasPart" reverseIRI="http://schema.org/isPartOf" reverseShortName="isPartOf">
                            <xsl:for-each select="1 to $hasPartCount">
                                <xsl:variable name="workUuid" select="c1:getUUID()"/>                                
                                <document type="Work" uuid="{$workUuid}" urn="urn:pearson:work:{$workUuid}"/>
                            </xsl:for-each>
                        </relation>
                    </document>
                </xsl:for-each>
               
                <xsl:variable name="workManifestationCounts" select="rd:random-sequence($numWorks)"/>
                <xsl:for-each select="1 to $numWorks">
                    <xsl:variable name="uuid" select="c1:getUUID()"/>
                    <xsl:variable name="workIndex" select="position()"/>
                    <xsl:variable name="workExampleCount" select="xs:integer(floor($workManifestationCounts[$workIndex] * 5))" as="xs:integer"/>
                    <document type="Work" uuid="{$uuid}" urn="urn:pearson:work:{$uuid}">
                        <relation IRI="http://schema.org/workExample" shortName="workExample" reverseIRI="http://schema.org/exampleOfWork" reverseShortName="exampleOfWork">
                           <xsl:for-each select="1 to $workExampleCount">
                               <xsl:variable name="manifestationUuid" select="c1:getUUID()"/>                                
                               <document type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}"/>
                            </xsl:for-each>
                        </relation>
                    </document>
                </xsl:for-each>

            </documents>
        </xsl:variable>
        
        <xsl:apply-templates select="$processingStructure">
            <xsl:with-param name="outputFolder" tunnel="yes" select="$outputFolder"/>
            <xsl:with-param name="env" tunnel="yes" select="$env"/>          
        </xsl:apply-templates>

        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/processing-structure.xml" method="xml">
            <xsl:copy-of select="$processingStructure"/>
        </xsl:result-document>
            
        <!-- We generate a CURL output so that all files can be loaded up automatically -->
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/curl-file.bat" method="text">
            <xsl:text>md results&#10;</xsl:text>
            <xsl:variable name="documentCount" select="count($processingStructure//document)"/>
            <xsl:for-each select="$processingStructure//document">
                <xsl:text>timeout 1&#10;</xsl:text>
                <xsl:text>echo </xsl:text>
                <xsl:value-of select="concat(position(), ' of ', $documentCount)"/>
                <xsl:text>&#10;curl -X POST -d @json/</xsl:text>
                <xsl:value-of select="lower-case(@type)"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="lower-case(@type)"/>
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