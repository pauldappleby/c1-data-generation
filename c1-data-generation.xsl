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
    
    <!-- XML to JSON convertor -->
    <xsl:import href="JSON-LD-API-XML-to-JSON.xsl"/>
    
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="rd c1 uuid"/>
    
    <xsl:param name="numWorks">10</xsl:param>
    <xsl:param name="numWorkContainers">0</xsl:param>
    <xsl:param name="env">dev</xsl:param>
    
    <xsl:variable name="outputFolder">test-metadata</xsl:variable>
    
    <xsl:variable name="envs">
        <env id="dev" schema="http://schema.pearson.com" data="https://data.pearson.com"/>
        <env id="test" schema="http://schema.pearson.com" data="https://data.pearson.com"/>
    </xsl:variable>
    
    <xsl:variable name="dataDomain" select="$envs/env[@id = $env]/@data"/>
    <xsl:variable name="schemaDomain" select="$envs/env[@id = $env]/@schema"/>
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
    
    <xsl:template name="saveDocument">
        <xsl:param name="documentType"/>
        <xsl:param name="documentUuid"/>
        <xsl:param name="documentContent"/>
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/xml/{lower-case($documentType)}/{lower-case($documentType)}-{$documentUuid}.xml">
            <xpf:map>
                <xsl:copy-of select="$context"/>
                <xsl:copy-of select="$documentContent/*"/>
            </xpf:map>
        </xsl:result-document>        
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/json/{lower-case($documentType)}/{lower-case($documentType)}-{$documentUuid}.json" method="text">
            <xsl:call-template name="jld:XML-to-JSON">
                <xsl:with-param name="XMLinput">
                    <xpf:map>
                        <xsl:copy-of select="$context"/>
                        <xsl:copy-of select="$documentContent/*"/>
                    </xpf:map>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>        
    </xsl:template>
    
    <xsl:template name="getType">
        <xsl:param name="baseType"/>
        <xsl:param name="isContainer" as="xs:boolean">false</xsl:param>
        <xsl:variable name="usableTypes" select="$type/type"/>
        <xsl:variable name="additionalType" select="for $num in rd:random-sequence(1) return
            xs:integer(floor($num * count($usableTypes)) + 1)"/>
        <xpf:array key="type">
            <xpf:string>
                <xsl:value-of select="$baseType"/>
            </xpf:string>
            <xpf:string>
                <xsl:value-of select="$usableTypes[$additionalType]/@short"/>
            </xpf:string>
            <xsl:if test="$isContainer">
                <xpf:string>Container</xpf:string>           
            </xsl:if>
        </xpf:array>
    </xsl:template>
   
    <xsl:function name="c1:getName" as="xs:string">
        <xsl:variable name="adjective" select="for $num in rd:random-sequence(1) return
            xs:integer(floor($num * count($words/adjectives/*)) + 1)"/>
        <xsl:variable name="noun" select="for $num in rd:random-sequence(1) return
            xs:integer(floor($num * count($words/nouns/*)) + 1)"/>
        <xsl:value-of>
            <xsl:text>The </xsl:text>
            <xsl:value-of select="$words/adjectives/adjective[$adjective]"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$words/nouns/noun[$noun]"/>
        </xsl:value-of>
    </xsl:function>
 
    <xsl:template name="getDateCreated">
        <!-- Paramaterised for testing -->
        <xsl:param name="day" select="xs:integer(floor(rd:random-sequence(1) * 28) + 1)" as="xs:integer"/>
        <xsl:param name="month" select="xs:integer(floor(rd:random-sequence(1) * 12) + 1)" as="xs:integer"/>
        <xsl:param name="hour" select="xs:integer(floor(rd:random-sequence(1) * 24))" as="xs:integer"/>
        <xsl:param name="minute" select="xs:integer(floor(rd:random-sequence(1) * 60))" as="xs:integer"/>
        <xpf:string key="dateCreated">
            <xsl:text>2016-</xsl:text>
            <xsl:if test="$month &lt; 10">0</xsl:if>
            <xsl:value-of select="$month"/>
            <xsl:text>-</xsl:text>
            <xsl:if test="$day &lt; 10">0</xsl:if>
            <xsl:value-of select="$day"/>
            <xsl:text>T</xsl:text> 
            <xsl:if test="$hour &lt; 10">0</xsl:if>
            <xsl:value-of select="$hour"/>
            <xsl:text>:</xsl:text>
            <xsl:if test="$minute &lt; 10">0</xsl:if>
            <xsl:value-of select="$minute"/>
            <xsl:text>:00Z</xsl:text>    
        </xpf:string>
    </xsl:template>

    <xsl:template name="getKeywords">
        <xsl:variable name="keysCount" select="xs:integer(floor(rd:random-sequence(1) * 5))"/>
        <xsl:if test="$keysCount > 0">
            <xsl:variable name="keys" select="
                for $num in rd:random-sequence($keysCount)
                return
                    xs:integer(floor($num * count($keywords)))" as="xs:integer*"/>
            <xpf:map key="keyword">
                <xpf:array key="en">
                    <xsl:for-each select="$keys">
                        <xpf:string>
                            <xsl:value-of select="$keywords[current()]"/>
                        </xpf:string>
                    </xsl:for-each>
                </xpf:array>
            </xpf:map>
        </xsl:if>
    </xsl:template>

    <xsl:template name="getSubjects">
        <xsl:variable name="subjectCount" select="xs:integer(floor(rd:random-sequence(1) * 5))"/>
        <xsl:if test="$subjectCount > 0">
            <xsl:variable name="subject" select="
                for $num in rd:random-sequence($subjectCount)
                return
                    xs:integer(floor($num * count($subjects)))"/>
            <xpf:array key="subject">
                <xsl:for-each select="$subject">
                    <xpf:string>
                        <xsl:value-of select="$subjects[current()]"/>
                    </xpf:string>
                </xsl:for-each>
            </xpf:array>
        </xsl:if>
    </xsl:template>
    
    <!-- Return a media type given a particular set of input types -->
    <xsl:template name="getFormat" as="element()*">
        <xsl:param name="types"/>
        <!-- Paramaterised for testing -->
        <xsl:param name="formatIndex" select="
            for $num in rd:random-sequence(1)
            return
                xs:integer(floor($num * count($formats/format[@type = $types//xpf:string])) + 1)" as="xs:integer"/>
        <xsl:if test="$formats/format[@type = $types//xpf:string][$formatIndex]">
            <xpf:string key="format">
                <xsl:value-of select="$formats/format[contains($types, @type)][$formatIndex]/@mimetype"/>
            </xpf:string>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="c1:getUUID" as="xs:string">
        <xsl:value-of select="uuid:randomUUID()"/>
    </xsl:function>
    
</xsl:stylesheet>