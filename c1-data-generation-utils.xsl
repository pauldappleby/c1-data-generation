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

    <xsl:import href="XML-to-Quads.xsl"/>
    
    <xsl:variable name="words" select="document('seed-data/words.xml')/words"/>
    <xsl:variable name="subjects" select="document('seed-data/subject.xml')/rdf:RDF/rdf:Description[rdf:type/@rdf:resource = 'http://www.w3.org/2004/02/skos/core#Concept']/@rdf:about" as="xs:string+"/>
    <xsl:variable name="context" select="document('context.xml')"/>   
    <xsl:variable name="type" select="document('seed-data/types.xml')/types"/>
    <xsl:variable name="formats" select="document('seed-data/formats.xml')/formats"/>
    <xsl:variable name="keywords" select="$words/(adjectives | nouns)/*"/>
    <!-- This data comes from a sample using the migrated CMT data -->
    <xsl:variable name="learningObjectiveDescription" select="tokenize(unparsed-text('seed-data/learning-objective.txt'), '&#13;&#10;')" as="xs:string+"/>   
    <!-- This data comes from a sample using the migrated CMT data -->
    <xsl:variable name="learningDimension" select="tokenize(unparsed-text('seed-data/learning-dimension.txt'), '&#13;&#10;')" as="xs:string+"/>   
    
    <xsl:template name="saveDocument">
        <xsl:param name="testSet"/>
        <xsl:param name="documentType"/>
        <xsl:param name="documentUuid"/>
        <xsl:param name="documentURN"/>
        <xsl:param name="documentContent"/>
        <xsl:param name="outputFolder" required="yes"/>
        <xsl:param name="env" required="yes"/>
        <xsl:for-each select="tokenize($testSet, ' ')">
            <xsl:variable name="set" select="."/>
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                '[Y0001][M01][D01]')}/{$env}/xml/{$set}/{if (not($documentURN)) then 'no-urn/' else 'urn/'}{lower-case(translate($documentType, ' ', ''))}/{lower-case(translate($documentType, ' ', ''))}-{$documentUuid}.xml" method="xml">
                <xpf:map>
                    <xsl:copy-of select="$context"/>
                    <xsl:copy-of select="$documentContent/*[not(@patchContent)]"/>
                </xpf:map>
            </xsl:result-document>  
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                '[Y0001][M01][D01]')}/{$env}/json/{$set}/{if (not($documentURN)) then 'no-urn/' else 'urn/'}{lower-case(translate($documentType, ' ', ''))}/{lower-case(translate($documentType, ' ', ''))}-{$documentUuid}.json" method="text">
                <xsl:call-template name="jld:XML-to-JSON">
                    <xsl:with-param name="XMLinput">
                        <xpf:map>
                            <xsl:copy-of select="$context"/>
                            <xsl:copy-of select="$documentContent/*[not(@patchContent)]"/>
                        </xpf:map>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:result-document>
            <!-- Is there a PATCH document? -->
            <xsl:if test="$documentContent/*[@patchContent]">
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                    '[Y0001][M01][D01]')}/{$env}/json/performanceDataPATCH/{lower-case(translate($documentType, ' ', ''))}/{lower-case(translate($documentType, ' ', ''))}-{$documentUuid}.json" method="text">
                    <xsl:call-template name="jld:XML-to-JSON">
                        <xsl:with-param name="XMLinput">
                            <xpf:map>
                                <xsl:copy-of select="$context"/>
                                <xsl:copy-of select="$documentContent/*[@patchContent]"/>
                            </xpf:map>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:result-document>
            </xsl:if>
            <xsl:if test="contains($testSet, 'seedData')">
                <xsl:if test="$documentURN = ''">
                    <xsl:message terminate="yes">No URN on seed data item</xsl:message>
                </xsl:if>
                <xsl:call-template name="jld:xml-to-quads">
                    <xsl:with-param name="XMLinput">
                        <xpf:map>
                            <xsl:copy-of select="$context"/>
                            <xsl:variable name="url" select="concat('https://data.pearson.com/', translate(substring-after($documentURN, 'pearson:'), ':', '/'))"/>
                            <xpf:string key="sameAs" type="IRI" IRI="http://www.w3.org/2002/07/owl#sameAs">
                                <xsl:value-of select="$url"/>
                            </xpf:string>
                            <xpf:string key="isDefinedBy" type="IRI" IRI="http://www.w3.org/2000/01/rdf-schema#isDefinedBy">
                                <xsl:value-of select="$url"/>
                                <xsl:text>/metadata</xsl:text>
                            </xpf:string>
                            <xpf:string key="uuid" IRI="https://schema.pearson.com/ns/content/uuid">
                                <xsl:value-of select="$documentUuid"/>
                            </xpf:string>
                            <xsl:copy-of select="$documentContent/*"/>
                        </xpf:map>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="getType">
        <xsl:param name="baseType" required="yes"/>
        <xsl:param name="baseTypeIRI" required="yes"/>
        <xsl:param name="extendedTypes" as="xs:string*"/>
        <xsl:param name="extendedTypesIRIs" as="xs:string*"/>
        <xsl:param name="seed"/>
        <xsl:variable name="usableTypes" select="$type/type"/>
        <xsl:variable name="additionalType" select="for $num in rd:random-sequence(1, $seed) return
            xs:integer(floor($num * count($usableTypes)) + 1)"/>
        <xpf:array key="type">
            <xpf:string IRI="{$baseTypeIRI}">
                <xsl:value-of select="$baseType"/>
            </xpf:string>
            <xpf:string IRI="{$usableTypes[$additionalType]}">
                <xsl:value-of select="$usableTypes[$additionalType]/@short"/>
            </xpf:string>
            <xsl:for-each select="$extendedTypes">
                <xsl:variable name="position" select="position()"/>
                <xpf:string IRI="{$extendedTypesIRIs[$position]}"><xsl:value-of select="."/></xpf:string>
            </xsl:for-each>
        </xpf:array>
    </xsl:template>
   
    <xsl:function name="c1:getName" as="xs:string">
        <xsl:param name="seed"/>
        <xsl:variable name="adjective" select="for $num in rd:random-sequence(1, $seed) return
            xs:integer(floor($num * count($words/adjectives/*)) + 1)"/>
        <xsl:variable name="noun" select="for $num in rd:random-sequence(1, $seed) return
            xs:integer(floor($num * count($words/nouns/*)) + 1)"/>
        <xsl:value-of>
            <xsl:text>The </xsl:text>
            <xsl:value-of select="$words/adjectives/adjective[$adjective]"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$words/nouns/noun[$noun]"/>
        </xsl:value-of>
    </xsl:function>

    <xsl:function name="c1:seedFromUUID" as="xs:double">
        <xsl:param name="uuid"/>
        <xsl:value-of select="xs:double(translate($uuid, 'abcdefghijklmnopqrstuvwxyz-', ''))"/>
    </xsl:function>
    
    <xsl:template name="getDateCreated">
        <xsl:param name="seed"/>
        <!-- Paramaterised for testing -->
        <xsl:param name="day" select="xs:integer(floor(rd:random-sequence(1, $seed) * 28) + 1)" as="xs:integer"/>
        <xsl:param name="month" select="xs:integer(floor(rd:random-sequence(1, $seed) * 12) + 1)" as="xs:integer"/>
        <xsl:param name="hour" select="xs:integer(floor(rd:random-sequence(1, $seed) * 24))" as="xs:integer"/>
        <xsl:param name="minute" select="xs:integer(floor(rd:random-sequence(1, $seed) * 60))" as="xs:integer"/>
        <xpf:string key="dateCreated" IRI="http://schema.org/dateCreated" type="http://www.w3.org/2001/XMLSchema#dateTime">
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
        <xsl:param name="keysCount" as="xs:integer?"/>
        <xsl:if test="$keysCount > 0">
            <xsl:variable name="keys" select="
                for $num in rd:random-sequence($keysCount)
                return
                    xs:integer(floor($num * count($keywords)))" as="xs:integer*"/>
            <xpf:map key="keyword" IRI="https://schema.pearson.com/ns/content/keyword" type="LanguageContainer">
                <xpf:array key="en">
                    <xsl:for-each select="$keys">
                        <xpf:string language="en" IRI="https://schema.pearson.com/ns/content/keyword">
                            <xsl:value-of select="$keywords[current()]"/>
                        </xpf:string>
                    </xsl:for-each>
                </xpf:array>
            </xpf:map>
        </xsl:if>
    </xsl:template>

    <xsl:template name="getLearningObjectiveDescription">
        <xsl:param name="seed"/>
        <xsl:variable name="descriptionIndex" select="
            for $num in rd:random-sequence(1, $seed)
            return
            xs:integer(floor($num * count($learningObjectiveDescription)))"/>
        <xpf:map key="description" IRI="http://schema.org/description">
            <xpf:string key="en" language="en" type="LangString" IRI="http://schema.org/description">
                <xsl:value-of select="$learningObjectiveDescription[$descriptionIndex]"/>
            </xpf:string>
        </xpf:map>
    </xsl:template>

    <xsl:template name="getLearningDimension">
        <xsl:param name="seed"/>
        <xsl:variable name="dimensionIndex" select="
            for $num in rd:random-sequence(1, $seed)
            return
            xs:integer(floor($num * count($learningDimension)))"/>
        <xpf:array key="learningDimension" IRI="https://schema.pearson.com/ns/learn/learningDimension">
            <xpf:string type="IRI" IRI="https://schema.pearson.com/ns/learn/learningDimension">
                <xsl:value-of select="$learningDimension[$dimensionIndex]"/>
            </xpf:string>
        </xpf:array>
    </xsl:template>
    
    <xsl:template name="getSubjects">
        <xsl:param name="subjectCount" as="xs:integer?"/>
        <xsl:if test="$subjectCount > 0">
            <xsl:variable name="subject" select="
                for $num in rd:random-sequence($subjectCount)
                return
                    xs:integer(floor($num * count($subjects)) + 1)"/>
            <xpf:array key="subject" IRI="http://purl.org/dc/terms/subject">
                <xsl:for-each select="$subject">
                    <xpf:string type="IRI" IRI="http://purl.org/dc/terms/subject">
                        <xsl:value-of select="$subjects[current()]"/>
                    </xpf:string>
                </xsl:for-each>
            </xpf:array>
        </xsl:if>
    </xsl:template>
    
    <!-- Return a media type given a particular set of input types -->
    <xsl:template name="getFormat" as="element()*">
        <xsl:param name="types"/>
        <xsl:param name="seed"/>
        <!-- Paramaterised for testing -->
        <xsl:param name="formatIndex" select="
            for $num in rd:random-sequence(1, $seed)
            return
                xs:integer(floor($num * count($formats/format[@type = $types//xpf:string])) + 1)" as="xs:integer?"/>
        <xsl:if test="$formats/format[@type = $types//xpf:string][$formatIndex]">
            <xpf:string key="format" IRI="http://schema.org/fileFormat">
                <xsl:value-of select="$formats/format[contains($types, @type)][$formatIndex]/@mimetype"/>
            </xpf:string>
        </xsl:if>
    </xsl:template>
    
    <!--<xsl:function name="c1:getUUID" as="xs:string">
        <xsl:value-of select="uuid:randomUUID()"/>
    </xsl:function>-->
    
</xsl:stylesheet>