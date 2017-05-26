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
    
    <xsl:output method="text" indent="yes" exclude-result-prefixes="rd c1 uuid"/>
    
    <!-- Number of items to generate for seed data -->
    <xsl:param name="numWorks">10</xsl:param>
    <xsl:param name="numWorkContainers">10</xsl:param>

    <!-- Number of items to generate for performances data -->
    <xsl:param name="numPerfMatchAxioms">10</xsl:param>
    <xsl:param name="numPerfManifestations">10</xsl:param>
    <xsl:param name="numPerfLearningObjectives">10</xsl:param>
    <xsl:param name="numPerfIdentifierAxioms">10</xsl:param>

    <xsl:param name="env">dev</xsl:param>
    <xsl:param name="outputFolder">generated-data</xsl:param>
    
    <!-- Seeds for random numbers -->
    <xsl:param name="numWorksSeed">5987907735</xsl:param>
    <xsl:param name="identifierSeed">7537059247</xsl:param>
               
    <xsl:template name="generateOutput">
        
        <!-- We generate an XML structure defining the document types to generate and the relationships between them -->
        <xsl:variable name="processingStructure">
            <documents>
 
                <xsl:variable name="hasPartCounts" select="rd:random-sequence($numWorkContainers)"/>
                <xsl:for-each select="1 to $numWorkContainers">
                    <xsl:variable name="uuid" select="uuid:randomUUID()"/>
                    <xsl:variable name="hasPartIndex" select="position()"/>
                    <xsl:variable name="hasPartCount" select="xs:integer(floor($hasPartCounts[$hasPartIndex] * 5) + 1)" as="xs:integer"/>
                    <document testSet="seedData" type="WorkContainer" uuid="{$uuid}" urn="urn:pearson:work:{$uuid}">
                        <relation IRI="http://schema.org/hasPart" shortName="hasPart">
                            <xsl:for-each select="1 to $hasPartCount">
                                <xsl:variable name="workUuid" select="uuid:randomUUID()"/>                                
                                <document testSet="seedData" type="Work" uuid="{$workUuid}" urn="urn:pearson:work:{$workUuid}"/>
                            </xsl:for-each>
                        </relation>
                    </document>
                </xsl:for-each>
               
                <xsl:variable name="workManifestationCounts" select="rd:random-sequence($numWorks, $numWorksSeed)"/>
                <!-- 20% of Manifestations will be given EPS IDs -->
                <xsl:variable name="includeEPSidentifierValues" select="rd:random-sequence($numWorks, $identifierSeed)" as="xs:double*"/>
                <xsl:for-each select="1 to $numWorks">
                    <xsl:variable name="uuid1" select="uuid:randomUUID()"/>
                    <xsl:variable name="uuid2" select="uuid:randomUUID()"/>
                    <xsl:variable name="workIndex" select="position()"/>
                    <xsl:variable name="workExampleCount" select="xs:integer(floor($workManifestationCounts[$workIndex] * 5))" as="xs:integer"/>
                    <!-- We output the Works to performanceData as the Works will be used to test workExample referencing seeded Manifestations -->
                    <document testSet="performanceData" type="Work" uuid="{$uuid1}" urn="urn:pearson:work:{$uuid1}" epsValue="{$includeEPSidentifierValues[$workIndex]}">
                        <xsl:if test="$workExampleCount > 0">
                            <relation IRI="http://schema.org/workExample" shortName="workExample">
                                <xsl:for-each select="1 to $workExampleCount">
                                   <xsl:variable name="manifestationUuid" select="uuid:randomUUID()"/>                                
                                    <document testSet="seedData" type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}">
                                       <xsl:if test="$includeEPSidentifierValues[$workIndex] &lt; 0.2">
                                           <relation IRI="https://schema.pearson.com/ns/xowl/identifiedBy" shortName="identifiedBy">
                                               <xsl:variable name="identifierAxiomUuid" select="uuid:randomUUID()"/>                                
                                               <document testSet="seedData" type="IdentifierAxiom" uuid="{$identifierAxiomUuid}" urn="urn:pearson:identifier:{$identifierAxiomUuid}"/>
                                           </relation>
                                       </xsl:if>
                                   </document>
                                </xsl:for-each>
                            </relation>
                        </xsl:if>
                    </document>
                    <!-- We'll create seedData Works referencing Manifestations too -->
                    <document testSet="seedData" type="Work" uuid="{$uuid2}" urn="urn:pearson:work:{$uuid2}" epsValue="{$includeEPSidentifierValues[$workIndex]}">
                        <xsl:if test="$workExampleCount > 0">
                            <relation IRI="http://schema.org/workExample" shortName="workExample">
                                <xsl:for-each select="1 to $workExampleCount">
                                    <xsl:variable name="manifestationUuid" select="uuid:randomUUID()"/>                                
                                    <document testSet="seedData" type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}"/>
                                </xsl:for-each>
                            </relation>
                        </xsl:if>
                    </document>
                </xsl:for-each>

                <!-- These are to test POSTing Manifestations to the API -->
                <xsl:for-each select="1 to $numPerfManifestations">
                    <xsl:variable name="manifestationUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}"/>                    
                </xsl:for-each>
                
                <!-- These are to test POSTing learning objectives to the API -->
                <xsl:for-each select="1 to $numPerfLearningObjectives">
                    <xsl:variable name="learningObjectiveUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="LearningObjective" uuid="{$learningObjectiveUuid}" urn="urn:pearson:educationalgoal:{$learningObjectiveUuid}"/>                    
                </xsl:for-each>
                
                <!-- These are to test POSTing IdentifierAxioms to the API -->
                <xsl:for-each select="1 to $numPerfIdentifierAxioms">
                    <xsl:variable name="identifierAxiomUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="IdentifierAxiom" uuid="{$identifierAxiomUuid}" urn="urn:pearson:identifier:{$identifierAxiomUuid}"/>                    
                </xsl:for-each>

                <!-- These are to test POSTing MatchAxioms to the API -->
                <xsl:for-each select="1 to $numPerfMatchAxioms">
                    <xsl:variable name="matchAxiomUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="MatchAxiom" uuid="{$matchAxiomUuid}" urn="urn:pearson:match:{$matchAxiomUuid}"/>                    
                </xsl:for-each>
                
            </documents>
        </xsl:variable>
        
        <!-- Every document must be in at least one test set -->
        <xsl:if test="$processingStructure//document[not(@testSet)]">
            <xsl:message terminate="yes">Nodes are missing test sets</xsl:message>
        </xsl:if>
        
        <!-- Now we process the generated structure to actually generate all the output grouping together for quads output -->
        <xsl:message select="count($processingStructure/documents/*)"/>
        <xsl:for-each-group select="$processingStructure/documents/*" group-adjacent="floor(position() div 1000)">
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                '[Y0001][M01][D01]')}/{$env}/nquads/{current-grouping-key()}.nq" method="text">
                <xsl:apply-templates select="current-group()">
                    <xsl:with-param name="outputFolder" tunnel="yes" select="$outputFolder"/>
                    <xsl:with-param name="env" tunnel="yes" select="$env"/>          
                </xsl:apply-templates>
                <!-- Add in named graph quads -->
                <xsl:for-each select="current-group()/descendant-or-self::document">
                    <xsl:variable name="url" select="concat('https://data.pearson.com/graph/', translate(substring-after(@urn, 'pearson:'), ':', '/'))"/>
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="$url"/>
                    <xsl:text>&gt; &lt;https://schema.pearson.com/ns/raf/latest&gt; "1"^^&lt;http://www.w3.org/2001/XMLSchema#int&gt; &lt;https://data.pearson.com/graph-metadata&gt; .&#10;</xsl:text>
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="$url"/>
                    <xsl:text>&gt; &lt;https://schema.pearson.com/ns/raf/checkedout&gt; "true"^^&lt;http://www.w3.org/2001/XMLSchema#boolean&gt; &lt;https://data.pearson.com/graph-metadata&gt; .&#10;</xsl:text>
                    <xsl:text>&lt;</xsl:text>
                    <xsl:value-of select="$url"/>
                    <xsl:text>&gt; &lt;https://schema.pearson.com/ns/raf/revision&gt; &lt;</xsl:text>
                    <xsl:value-of select="$url"/>
                    <xsl:text>/1&gt; &lt;https://data.pearson.com/graph-metadata&gt; .&#10;</xsl:text>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:for-each-group>
        
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/processing-structure.xml" method="xml">
            <xsl:copy-of select="$processingStructure"/>
        </xsl:result-document>
            
        <!-- We generate a CURL output so that all files can be loaded up automatically -->
        <xsl:for-each select="distinct-values($processingStructure//document/@testSet/tokenize(., ' '))">
            <xsl:variable name="testSet" select="."/>
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                '[Y0001][M01][D01]')}/{$env}/{$testSet}-curl-file.bat" method="text">
                <xsl:text>md results&#10;</xsl:text>
                <xsl:variable name="documentCount" select="count($processingStructure//document[contains(@testSet, $testSet)])"/>
                <xsl:for-each select="$processingStructure//document[contains(@testSet, $testSet)]">
                    <!-- We do the deepest children first because they get used by ancestors so need to be loaded into API first -->
                    <xsl:sort select="count(ancestor::*)" order="descending"/>
                    <xsl:text>timeout 1&#10;</xsl:text>
                    <xsl:text>echo </xsl:text>
                    <xsl:value-of select="concat(position(), ' of ', $documentCount)"/>
                    <xsl:text>&#10;curl -X POST -d @json/</xsl:text>
                    <xsl:value-of select="$testSet"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="lower-case(@type)"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="lower-case(@type)"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="@uuid"/>
                    <xsl:text>.json -H "Content-Type: application/json" -H "Authorization: Basic Ymx1ZWJlcnJ5OmVAQkhSTUF2M2V5S2xiT1VjS0tAWl56Q0ZhMDRtYw==" -H "X-Roles: LearningAdmin,ContentMetadataAdmin" -k https://develop-data.pearsoncms.net/api/api/thing?db=qa0 -o results/results-</xsl:text>
                    <xsl:value-of select="$testSet"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="lower-case(@type)"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="@uuid"/>
                    <xsl:text>.txt -i&#10;</xsl:text>
                </xsl:for-each>
            </xsl:result-document>  
        </xsl:for-each>
        
    </xsl:template>
 
    <xsl:template match="documents">
        <xsl:apply-templates select="document"/>
    </xsl:template>

    <xsl:template match="relation">
        <xsl:apply-templates select="document"/>
    </xsl:template>
    
</xsl:stylesheet>