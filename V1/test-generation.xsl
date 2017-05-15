<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0" xmlns:uuid="java:java.util.UUID" xmlns:rd= "http://exslt.org/random" xmlns:c1="http://schema.pearson.com/ns/c1">    
    
    <xsl:output method="text"/>
    
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
    <xsl:variable name="words" select="document('words.xml')/words"/>
    <xsl:variable name="about" select="document('subjects.xml')/subjects"/>
    <xsl:variable name="contextText" select="unparsed-text('contextText.txt')"/>   
    <xsl:variable name="type" select="document('types.xml')/types"/>
    <xsl:variable name="formats" select="document('formats.xml')/formats"/>
    <xsl:variable name="keywords" select="$words/(adjectives | nouns)/*"/>
        
    <!-- Generate JSON-LD context -->
    <xsl:variable name="context">
        <xsl:value-of select="$contextText"/>
    </xsl:variable>

    <!-- Development template -->
    <xsl:template name="generateTestCorpus">
        <xsl:variable name="workExampleCount" select="xs:integer(floor(rd:random-sequence(1) * 3))" as="xs:integer"/>
        <xsl:variable name="manifestationUUIDs" as="xs:string*">
            <xsl:for-each select="1 to $workExampleCount">
                <xsl:value-of select="c1:getUUID()"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:call-template name="generateWorkDocument">    
            <xsl:with-param name="manifestationUUIDs" select="$manifestationUUIDs"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Template to actually generate output -->
    <xsl:template name="generateTestCorpusOutput">
        <xsl:for-each select="1 to $numWorks">
            <xsl:variable name="uuid" select="c1:getUUID()"/>
            <xsl:variable name="workExampleCount" select="xs:integer(floor(rd:random-sequence(1) * 3))" as="xs:integer"/>
            <xsl:variable name="manifestationUUIDs" as="xs:string*">
                <xsl:for-each select="1 to $workExampleCount">
                    <xsl:value-of select="c1:getUUID()"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(), '[Y0001][M01][D01]')}/{$env}/work/work-{$uuid}.json">
                <xsl:call-template name="generateWorkDocument">
                    <xsl:with-param name="uuid" select="$uuid"/>
                    <xsl:with-param name="manifestationUUIDs" select="$manifestationUUIDs"/>
                </xsl:call-template>
            </xsl:result-document>
            <xsl:message>Work: <xsl:value-of select="$uuid"/>; Manifestation count: <xsl:value-of select="$workExampleCount"/></xsl:message>
            <xsl:for-each select="$manifestationUUIDs">
                <xsl:variable name="id" select="."/>
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(), '[Y0001][M01][D01]')}/{$env}/manifestation/manifestation-{$id}.json">
                    <xsl:call-template name="generateManifestationDocument">
                        <xsl:with-param name="workUuid" select="$uuid"/>
                        <xsl:with-param name="uuid" select="$id"/>
                    </xsl:call-template>
                </xsl:result-document>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="1 to $numWorkContainers">
            <xsl:variable name="uuid" select="c1:getUUID()"/>
            <xsl:variable name="workPartCount" select="xs:integer(floor(rd:random-sequence(1) * 3))" as="xs:integer"/>
            <xsl:variable name="partUUIDs" as="xs:string*">
                <xsl:for-each select="1 to $workPartCount">
                    <xsl:value-of select="c1:getUUID()"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(), '[Y0001][M01][D01]')}/{$env}/work-container/work-{$uuid}.json">
                <xsl:call-template name="generateWorkContainerDocument">
                    <xsl:with-param name="uuid" select="$uuid"/>
                    <xsl:with-param name="partUUIDs" select="$partUUIDs"/>
                </xsl:call-template>
            </xsl:result-document>
            <xsl:message>Work container: <xsl:value-of select="$uuid"/>; Part count: <xsl:value-of select="$workPartCount"/></xsl:message>
            <xsl:for-each select="$partUUIDs">
                <xsl:variable name="id" select="."/>
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(), '[Y0001][M01][D01]')}/{$env}/work-part/work-{$id}.json">
                    <xsl:call-template name="generateWorkDocument">
                        <xsl:with-param name="uuid" select="$id"/>
                        <xsl:with-param name="isPartOf" select="$uuid"/>
                    </xsl:call-template>
                </xsl:result-document>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="generateCurl">
        <xsl:param name="manifestationUUIDs"/>
        <xsl:variable name="curlCommands" as="xs:string*">
            <xsl:for-each select="$manifestationUUIDs">
                <xsl:variable name="id" select="."/>
                <xsl:value-of>
                    <xsl:text>curl </xsl:text>
                    <xsl:value-of select="concat($outputFolder, '/generated-', format-date(current-date(), '[Y0001][M01][D01]'), '/', $env, '/manifestation/manifestation-', $id, '.json')"/>
                </xsl:value-of>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($curlCommands, '&#10;')"/>        
    </xsl:template>
    
    <xsl:template name="generateWorkContainerDocument">
        <xsl:param name="uuid" select="c1:getUUID()"/>
        <xsl:param name="partUUIDs"/>
        <xsl:variable name="getTypes">
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Work</xsl:with-param>
                <xsl:with-param name="isContainer">true</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" select="c1:genJson('id', concat('urn:pearson:work:', $uuid))"/>
        <xsl:variable name="sameAs" select="c1:genJson('sameAs', concat($dataDomain, '/work/', $uuid))"/>
        <xsl:variable name="uuid" select="c1:genJson('uuid', $uuid)"/>
        <xsl:variable name="name" select="c1:genLangJson('name', 'en', c1:getName())"/>
        <xsl:variable name="parts" as="xs:string*">
            <xsl:if test="not(empty($partUUIDs))">
                <xsl:value-of>
                    <xsl:text>"hasPart": [</xsl:text>
                    <xsl:variable name="partURNs" as="xs:string*">
                        <xsl:for-each select="$partUUIDs">
                            <xsl:value-of>
                                <xsl:text>"urn:pearson:work:</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:value-of>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="string-join($partURNs, ', ')"/>
                    <xsl:text>]</xsl:text>
                </xsl:value-of>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="dateCreated">
            <xsl:call-template name="getDateCreated"/>
        </xsl:variable>
        <xsl:variable name="keywordItems">
            <xsl:call-template name="getKeywords"/>
        </xsl:variable>
        <xsl:variable name="subjectItems">
            <xsl:call-template name="getSubjects"/>
        </xsl:variable>
        <xsl:text>{&#10;</xsl:text>
        <xsl:value-of select="string-join(($context, $id, $getTypes, $sameAs, $uuid, $name,
            $parts, $dateCreated, $keywordItems, $subjectItems), ',&#10;')"/>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>
    
    <xsl:template name="generateWorkDocument">
        <xsl:param name="uuid" select="c1:getUUID()"/>
        <xsl:param name="manifestationUUIDs"/>
        <xsl:param name="isPartOf" select="()"/>
        <xsl:variable name="getTypes">
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Work</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" select="c1:genJson('id', concat('urn:pearson:work:', $uuid))"/>
        <xsl:variable name="sameAs" select="c1:genJson('sameAs', concat($dataDomain, '/work/', $uuid))"/>
        <xsl:variable name="uuid" select="c1:genJson('uuid', $uuid)"/>
        <xsl:variable name="containers" as="xs:string*">
            <xsl:if test="not(empty($isPartOf))">
                <xsl:value-of>
                    <xsl:text>"isPartOf": [</xsl:text>
                    <xsl:variable name="isPartOfURNs" as="xs:string*">
                        <xsl:for-each select="$isPartOf">
                            <xsl:value-of>
                                <xsl:text>"urn:pearson:work:</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:value-of>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="string-join($isPartOfURNs, ', ')"/>
                    <xsl:text>]</xsl:text>
                </xsl:value-of>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="name" select="c1:genLangJson('name', 'en', c1:getName())"/>
        <xsl:variable name="manifestations" as="xs:string*">
            <xsl:if test="not(empty($manifestationUUIDs))">
                <xsl:value-of>
                    <xsl:text>"workExample": [</xsl:text>
                    <xsl:variable name="manifestationURNs" as="xs:string*">
                        <xsl:for-each select="$manifestationUUIDs">
                            <xsl:value-of>
                                <xsl:text>"urn:pearson:manifestation:</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>"</xsl:text>
                            </xsl:value-of>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="string-join($manifestationURNs, ', ')"/>
                    <xsl:text>]</xsl:text>
                </xsl:value-of>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="dateCreated">
            <xsl:call-template name="getDateCreated"/>
        </xsl:variable>
        <xsl:variable name="keywordItems" as="xs:string?">
            <xsl:call-template name="getKeywords"/>
        </xsl:variable>
        <xsl:variable name="subjectItems" as="xs:string?">
            <xsl:call-template name="getSubjects"/>
        </xsl:variable>
        <xsl:text>{&#10;</xsl:text>
        <xsl:value-of select="string-join(($context, $id, $getTypes, $sameAs, $uuid, $containers, $name,
            $manifestations, $dateCreated, $keywordItems, $subjectItems), ',&#10;')"/>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>

    <xsl:template name="generateManifestationDocument">
        <xsl:param name="workUuid" required="yes"/>
        <xsl:param name="uuid" select="c1:getUUID()"/>
        <xsl:variable name="getTypes">
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Manifestation</xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" select="c1:genJson('id', concat('urn:pearson:manifestation:', $uuid))"/>
        <!--<xsl:variable name="sameAs" select="c1:genJson('sameAs', concat($dataDomain, '/manifestation/', $uuid))"/>-->
        <xsl:variable name="uuid" select="c1:genJson('uuid', $uuid)"/>
        <xsl:variable name="name" select="c1:genLangJson('name', 'en', concat('Specialised ', c1:getName()))"/>
        <xsl:variable name="works" as="xs:string*">
            <xsl:if test="$workUuid">
                <xsl:value-of>
                    <xsl:text>"exampleOfWork": "urn:pearson:work:</xsl:text>
                    <xsl:value-of select="$workUuid"/>
                    <xsl:text>"</xsl:text>
                </xsl:value-of>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="dateCreated">
            <xsl:call-template name="getDateCreated"/>
        </xsl:variable>
        <xsl:variable name="format" as="xs:string*">
            <xsl:call-template name="getFormat">
                <xsl:with-param name="types" select="$getTypes"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>{&#10;</xsl:text>
        <xsl:value-of select="string-join(($context, $id, $getTypes, $uuid, $name, $works, $dateCreated, $format), ',&#10;')"/>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>
    
    <xsl:function name="c1:genLangJson" as="xs:string">
        <xsl:param name="prop"/>
        <xsl:param name="langs"/>
        <xsl:param name="content"/>
        <xsl:value-of>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$prop"/>
            <xsl:text>": {</xsl:text>
            <xsl:variable name="langArray">
                <xsl:for-each select="$langs">
                    <xsl:value-of>
                        <xsl:variable name="pos" select="position()"/>
                        <xsl:text>"</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>": "</xsl:text>
                        <xsl:value-of select="$content[$pos]"/>
                        <xsl:text>"</xsl:text>
                    </xsl:value-of>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="string-join($langArray, ',&#10;')"/>
            <xsl:text>}</xsl:text>
        </xsl:value-of>
    </xsl:function>
    
    <xsl:function name="c1:genJson" as="xs:string">
        <xsl:param name="prop"/>
        <xsl:param name="content"/>
        <xsl:value-of>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$prop"/>
            <xsl:text>": "</xsl:text>
            <xsl:value-of select="$content"/>
            <xsl:text>"</xsl:text>
        </xsl:value-of>
    </xsl:function>

    <!--<xsl:template name="getAssetType" as="xs:string">
        <xsl:variable name="usableTypes" select="$type/*[not(@context = 'true')]"/>
        <xsl:variable name="additionalType" select="for $num in rd:random-sequence(1) return
            xs:integer(floor($num * count($usableTypes)) + 1)"/>
        <xsl:value-of select="$usableTypes[$additionalType]/@short"/>
    </xsl:template>-->

    <xsl:template name="getFormat" as="xs:string*">
        <xsl:param name="types"/>
        <xsl:message>Format types: <xsl:value-of select="$types"/></xsl:message>
        <xsl:variable name="formatIndex" select="for $num in rd:random-sequence(1) return
            xs:integer(floor($num * count($formats/format[contains($types, @type)])) + 1)"/>
        <xsl:if test="$formats/format[contains($types, @type)][$formatIndex]">
            <xsl:value-of>
                <xsl:text>"format": "</xsl:text>
                <xsl:value-of select="$formats/format[contains($types, @type)][$formatIndex]/@mimetype"/>
                <xsl:text>"</xsl:text>
            </xsl:value-of>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="getType">
        <xsl:param name="baseType"/>
        <xsl:param name="isContainer" as="xs:boolean">false</xsl:param>
        <xsl:variable name="usableTypes" select="$type/*[not(@context = 'true')]"/>
        <xsl:variable name="additionalType" select="for $num in rd:random-sequence(1) return
            xs:integer(floor($num * count($usableTypes)) + 1)"/>
        <xsl:text>"type": [&#10;"</xsl:text>
        <xsl:value-of select="$baseType"/>
        <xsl:text>",&#10;</xsl:text>
        <xsl:if test="$isContainer">
            <xsl:text>"Container",&#10;</xsl:text>           
        </xsl:if>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$usableTypes[$additionalType]/@short"/>
        <xsl:text>"&#10;]</xsl:text>
    </xsl:template>

    <xsl:template name="getDateCreated">
        <xsl:text>"dateCreated": "</xsl:text>
        <xsl:variable name="day" select="xs:integer(floor(rd:random-sequence(1) * 28) + 1)" as="xs:integer"/>
        <xsl:variable name="month" select="xs:integer(floor(rd:random-sequence(1) * 12) + 1)" as="xs:integer"/>
        <xsl:variable name="hour" select="xs:integer(floor(rd:random-sequence(1) * 24))" as="xs:integer"/>
        <xsl:variable name="minute" select="xs:integer(floor(rd:random-sequence(1) * 60))" as="xs:integer"/>
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
        <xsl:text>:00Z"</xsl:text>        
    </xsl:template>

    <xsl:template name="getKeywords" as="xs:string?">
        <xsl:variable name="keysCount" select="xs:integer(floor(rd:random-sequence(1) * 5))"/>
        <xsl:message>Keyword count: <xsl:value-of select="$keysCount"/></xsl:message> 
        <xsl:if test="$keysCount > 0">
            <xsl:variable name="keys" select="for $num in rd:random-sequence($keysCount) return
            xs:integer(floor($num * count($keywords)))"/>
            <xsl:value-of>
                <xsl:text>"keyword": {"en": [&#10;</xsl:text>
                <xsl:for-each select="$keys">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$keywords[current()]"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="not(position() = last())">,&#10;</xsl:if>
                </xsl:for-each>
                <xsl:text>&#10;]&#10;}</xsl:text>
            </xsl:value-of>
        </xsl:if>
    </xsl:template>

    <xsl:template name="getSubjects" as="xs:string?">
        <xsl:variable name="subjectCount" select="xs:integer(floor(rd:random-sequence(1) * 5))"/>
        <xsl:if test="$subjectCount > 0">
            <xsl:variable name="subject" select="for $num in rd:random-sequence($subjectCount) return
                xs:integer(floor($num * count($about/*)))"/>
            <xsl:message>Subject count: <xsl:value-of select="$subjectCount"/></xsl:message>
            <xsl:value-of>
                <xsl:text>"subject": [&#10;</xsl:text>
                <xsl:for-each select="$subject">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$about/*[current()]/@resource"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="not(position() = last())">,&#10;</xsl:if>
                </xsl:for-each>
                <xsl:text>&#10;]</xsl:text>
            </xsl:value-of>
        </xsl:if>
    </xsl:template>

    <xsl:function name="c1:getUUID" as="xs:string">
        <xsl:value-of select="uuid:randomUUID()"/>
    </xsl:function>
    
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
    
</xsl:stylesheet>