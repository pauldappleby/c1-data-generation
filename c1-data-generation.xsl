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
    
    <!--
        This codes generates seed and performance data for MDS
        
        Unit tests are written in XSpec and accompany this code
        
        This code has been developed using Oxygen with embedded Saxon PE 9.5.1.3
        
    -->

    <xsl:import href="c1-data-generation-content.xsl"/>
    
    <!-- We break out the save features into a separate file to make testing possible -->
    <!-- Save templates have a higher priority ensuring they get executed. The lower priority templates are then testable -->
    <xsl:import href="c1-data-generation-content-save.xsl"/>
    
    <xsl:output method="text" indent="yes" exclude-result-prefixes="rd c1 uuid"/>
    
    <!-- Number of items to generate for seed data -->
    <xsl:param name="numWorks">100</xsl:param>
    <xsl:param name="numWorkContainers">10</xsl:param>

    <!-- Number of items to generate for performances data -->
    <!-- We generated additional works without relations to Manifestations to check raw Work performance -->
    <xsl:param name="numPerfWorks">10</xsl:param>
    <xsl:param name="numPerfGoalFrameworks">10</xsl:param>
    <xsl:param name="numPerfMatchAxioms">10</xsl:param>
    <xsl:param name="numPerfManifestations">10</xsl:param>
    <xsl:param name="numPerfLearningObjectives">10</xsl:param>
    <xsl:param name="numPerfIdentifierAxioms">10</xsl:param>
    <xsl:param name="numPerfMultipleManifestationUpdates">3</xsl:param>

    <!-- Value needs to match a name attribute from environmentURLs -->
    <xsl:param name="env">dev</xsl:param>
    <xsl:param name="outputFolder">generated-data</xsl:param>
    <!-- Development database to include in Curl queries -->
    <xsl:param name="devDB">qa0</xsl:param>
 
    <!-- Enviroment details -->
    <xsl:param name="environmentURLs" as="element()+">
        <env name="dev" authText="-H &quot;Authorization: Basic Ymx1ZWJlcnJ5OmVAQkhSTUF2M2V5S2xiT1VjS0tAWl56Q0ZhMDRtYw==&quot; -H &quot;X-Roles: LearningAdmin,ContentMetadataAdmin&quot;">https://develop-data.pearsoncms.net/api/api</env>
        <env name="test" authText="-H &quot;Authorization: Basic Ymx1ZWJlcnJ5OmVAQkhSTUF2M2V5S2xiT1VjS0tAWl56Q0ZhMDRtYw==&quot; -H &quot;X-Roles: LearningAdmin,ContentMetadataAdmin&quot;">https://test-data.pearsoncms.net/api/api</env>
    </xsl:param>
    
    <!-- Seeds for random numbers -->
    <xsl:param name="numWorksSeed">5987907735</xsl:param>
    <xsl:param name="identifierSeed">7537059247</xsl:param>
    <xsl:param name="numManifestationPatchesSeed">645982377</xsl:param>
    
    <xsl:template name="generateOutput">
        
        <!--
            We generate an XML structure defining the document types to generate and the relationships between them. The general structure is:
            
            <documents>
                <document>
                    <relation>
                </document>
              <patch>
                <document>
              </patch>
              ...
            </documents>
            
            We also include information for generating PATCHes for certain documents and also dedicated PATCH documents for bulk patching.
            The structure of this document is then saved as processing-structure.xml (for debugging purposes).
        -->
        <xsl:variable name="processingStructure">
            <documents>
                <!-- 
                    Work containers are Works that have Works as parts.
                    We generate the container documents and Works and relate them through the hasPart relationship.
                -->
                <xsl:variable name="hasPartCounts" select="rd:random-sequence($numWorkContainers)"/>
                <xsl:for-each select="1 to $numWorkContainers">
                    <xsl:variable name="uuid" select="uuid:randomUUID()"/>
                    <xsl:variable name="hasPartIndex" select="position()"/>
                    <xsl:variable name="hasPartCount" select="xs:integer(floor($hasPartCounts[$hasPartIndex] * 5) + 1)" as="xs:integer"/>
                    <document testSet="seedData" type="Work Container" uuid="{$uuid}" urn="urn:pearson:work:{$uuid}">
                        <relation IRI="http://schema.org/hasPart" shortName="hasPart">
                            <xsl:for-each select="1 to $hasPartCount">
                                <xsl:variable name="workUuid" select="uuid:randomUUID()"/>                                
                                <document testSet="seedData" type="Work" uuid="{$workUuid}" urn="urn:pearson:work:{$workUuid}"/>
                            </xsl:for-each>
                        </relation>
                    </document>
                </xsl:for-each>
               
                <!-- We generate nested Manifestation outputs. Nested beens we have other resources embedded in the payload -->
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
                    <!-- We'll create performance data Works with no URNs -->
                    <document testSet="performanceData" type="Work" uuid="{$uuid2}" epsValue="{$includeEPSidentifierValues[$workIndex]}"/>
                </xsl:for-each>

                <!-- These are to test POSTing Works with nested resources to the API -->
                <xsl:for-each select="1 to $numPerfWorks">
                    <xsl:variable name="workUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="Work" uuid="{$workUuid}" urn="urn:pearson:work:{$workUuid}" patchSet="performanceDataPATCH"/>                    
                    <document testSet="performanceDataPUT" type="Work" uuid="{$workUuid}" urn="urn:pearson:work:{$workUuid}"/>                    
                    <!-- We create nested Work examples -->
                    <xsl:variable name="uuid1" select="uuid:randomUUID()"/>
                    <xsl:variable name="uuid2" select="uuid:randomUUID()"/>
                    <xsl:variable name="workIndex" select="position()"/>
                    <xsl:variable name="workExampleCount" select="xs:integer(floor($workManifestationCounts[$workIndex] * 5))" as="xs:integer"/>
                    <!-- We output the Works to performanceData as the Works will be used to test workExample referencing seeded Manifestations -->
                    <document testSet="embeddedWork" type="Work" uuid="{$uuid1}" urn="urn:pearson:work:{$uuid1}" epsValue="{$includeEPSidentifierValues[$workIndex]}">
                        <xsl:if test="$workExampleCount > 0">
                            <!-- We indicate to emed -->
                            <relation IRI="http://schema.org/workExample" shortName="workExample" embed="true">
                                <xsl:for-each select="1 to $workExampleCount">
                                    <xsl:variable name="manifestationUuid" select="uuid:randomUUID()"/>                                
                                    <document testSet="embeddedWork" type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}">
                                        <xsl:if test="$includeEPSidentifierValues[$workIndex] &lt; 0.2">
                                            <relation IRI="https://schema.pearson.com/ns/xowl/identifiedBy" shortName="identifiedBy" embed="true">
                                                <xsl:variable name="identifierAxiomUuid" select="uuid:randomUUID()"/>                                
                                                <document testSet="embeddedWork" type="IdentifierAxiom" uuid="{$identifierAxiomUuid}" urn="urn:pearson:identifier:{$identifierAxiomUuid}"/>
                                            </relation>
                                        </xsl:if>
                                    </document>
                                </xsl:for-each>
                            </relation>
                        </xsl:if>
                    </document>
                </xsl:for-each>

                <xsl:for-each select="1 to $numPerfGoalFrameworks">
                    <xsl:variable name="goalframeworkUuid" select="uuid:randomUUID()"/>                                
                    <xsl:variable name="goalCount" select="xs:integer(floor(rd:random-sequence(1, c1:seedFromUUID($goalframeworkUuid)) * 50) + 1)" as="xs:integer"/>
                    <xsl:variable name="goalList" as="element()+">
                        <xsl:for-each select="1 to $goalCount">
                            <xsl:variable name="goalUuid" select="uuid:randomUUID()"/>                                
                            <document testSet="embeddedGoalFramework" type="EducationalGoal" uuid="{$goalUuid}" urn="urn:pearson:educationalgoal:{$goalUuid}"/>                                
                            <document type="EducationalGoal" uuid="{$goalUuid}" urn="urn:pearson:educationalgoal:{$goalUuid}"/>                                
                        </xsl:for-each>                            
                    </xsl:variable>
                    <!-- We output the Works to performanceData as the Works will be used to test workExample referencing seeded Manifestations -->
                    <document testSet="embeddedGoalFramework" type="GoalFramework" uuid="{$goalframeworkUuid}" urn="urn:pearson:goalframework:{$goalframeworkUuid}">
                        <relation IRI="https://schema.pearson.com/ns/learn/hasTopGoal" shortName="hasTopGoal" embed="true">
                            <xsl:copy-of select="$goalList[@testSet]"/>
                        </relation>
                    </document>
                    <xsl:variable name="patchUuid" select="uuid:randomUUID()"/>  
                    <!-- Generate a multiple resource update that updates all the LOs in this framework -->
                    <patch testSet="goalFrameworkPatch" uuid="{$patchUuid}" correspondingUrn="urn:pearson:goalframework{$goalframeworkUuid}">
                        <xsl:copy-of select="$goalList[not(@testSet)]"/>
                    </patch>
                </xsl:for-each>
                
                <!-- These are to test POSTing Manifestations to the API -->
                <xsl:variable name="perfManifestations" as="element()*">
                    <xsl:for-each select="1 to $numPerfManifestations">
                        <xsl:variable name="manifestationUuid" select="uuid:randomUUID()"/>                                
                        <document testSet="performanceData" type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}" patchSet="performanceDataPATCH"/>                    
                        <document testSet="performanceDataPUT" type="Manifestation" uuid="{$manifestationUuid}" urn="urn:pearson:manifestation:{$manifestationUuid}"/>                    
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:copy-of select="$perfManifestations"/>
                
                <xsl:for-each select="1 to $numPerfMultipleManifestationUpdates">
                    <xsl:variable name="listCount" select="xs:integer(floor(rd:random-sequence(1, $numManifestationPatchesSeed + position()) * $numPerfManifestations) + 1)"
                        as="xs:integer"/>
                    <xsl:message>List count: <xsl:value-of select="$listCount"/></xsl:message>
                    <xsl:variable name="patchUuid" select="uuid:randomUUID()"/>  
                    <patch testSet="multiManifestationPatch" uuid="{$patchUuid}">
                        <xsl:variable name="listIndexes" select="rd:random-sequence($listCount, $numManifestationPatchesSeed - position())" as="xs:double+"/>
                        <xsl:variable name="listIndexes" select="distinct-values(
                                for $listIndex in $listIndexes
                                return
                                    xs:integer(floor($listIndex * $numPerfManifestations) + 1)
                            )"
                            as="xs:integer+"/>
                        <xsl:message>List indexes: <xsl:value-of select="$listIndexes"/></xsl:message>
                        <xsl:copy-of select="$perfManifestations[@testSet = 'performanceData'][position() = $listIndexes]"/>
                    </patch>                   
                </xsl:for-each>

                <!-- These are to test POSTing Manifestations to the API with no URNs. Note we generate a UUID just to name the file -->
                <xsl:for-each select="1 to $numPerfManifestations">
                    <xsl:variable name="manifestationUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="Manifestation" uuid="{$manifestationUuid}"/>                    
                </xsl:for-each>
                
                <!-- These are to test POSTing learning objectives to the API -->
                <xsl:for-each select="1 to $numPerfLearningObjectives">
                    <xsl:variable name="learningObjectiveUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="EducationalGoal" uuid="{$learningObjectiveUuid}" urn="urn:pearson:educationalgoal:{$learningObjectiveUuid}" patchSet="performanceDataPATCH"/>                    
                    <document testSet="performanceDataPUT" type="EducationalGoal" uuid="{$learningObjectiveUuid}" urn="urn:pearson:educationalgoal:{$learningObjectiveUuid}"/>                    
                </xsl:for-each>
               
                <!-- These are to test POSTing IdentifierAxioms to the API -->
                <xsl:for-each select="1 to $numPerfIdentifierAxioms">
                    <xsl:variable name="identifierAxiomUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="IdentifierAxiom" uuid="{$identifierAxiomUuid}" urn="urn:pearson:identifier:{$identifierAxiomUuid}" patchSet="performanceDataPATCH"/>                    
                    <document testSet="performanceDataPUT" type="IdentifierAxiom" uuid="{$identifierAxiomUuid}" urn="urn:pearson:identifier:{$identifierAxiomUuid}"/>                    
                </xsl:for-each>

                <!-- These are to test POSTing IdentifierAxioms to the API with no URN -->
                <xsl:for-each select="1 to $numPerfIdentifierAxioms">
                    <xsl:variable name="identifierAxiomUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="IdentifierAxiom" uuid="{$identifierAxiomUuid}"/>                    
                </xsl:for-each>
                
                <!-- These are to test POSTing MatchAxioms to the API -->
                <xsl:for-each select="1 to $numPerfMatchAxioms">
                    <xsl:variable name="matchAxiomUuid" select="uuid:randomUUID()"/>                                
                    <document testSet="performanceData" type="MatchAxiom" uuid="{$matchAxiomUuid}" urn="urn:pearson:match:{$matchAxiomUuid}" patchSet="performanceDataPATCH"/>                    
                    <document testSet="performanceDataPUT" type="MatchAxiom" uuid="{$matchAxiomUuid}" urn="urn:pearson:match:{$matchAxiomUuid}"/>                    
                </xsl:for-each>
                
            </documents>
        </xsl:variable>
        
        <!-- Every document must be in at least one test set -->
        <xsl:if test="$processingStructure//document[not(@testSet) and not(ancestor::patch)]">
            <xsl:message terminate="yes">Nodes are missing test sets</xsl:message>
        </xsl:if>
        
        <!-- Now we process the generated structure to actually generate all the output grouping together for quads output -->
        <!-- Note in this instance we only include seed data -->
        <xsl:message select="count($processingStructure/documents/document)"/>
        <xsl:for-each-group select="$processingStructure/documents/document" group-adjacent="floor(position() div 1000)">
            <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                '[Y0001][M01][D01]')}/{$env}/nquads/{current-grouping-key()}.nq" method="text">
                <xsl:apply-templates select="current-group()">
                    <xsl:with-param name="outputFolder" tunnel="yes" select="$outputFolder"/>
                    <xsl:with-param name="env" tunnel="yes" select="$env"/>          
                </xsl:apply-templates>
                <!-- Add in named graph quads -->
                <xsl:for-each select="current-group()/descendant-or-self::document[contains(@testSet, 'seedData')]">
                    <xsl:call-template name="GenerateMetadataGraphQuads">
                        <xsl:with-param name="urn" select="@urn"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:for-each-group>
        
        <!-- Generate standalone large PATCH documents -->
        <xsl:apply-templates select="$processingStructure//patch">
            <xsl:with-param name="outputFolder" tunnel="yes" select="$outputFolder"/>
            <xsl:with-param name="env" tunnel="yes" select="$env"/>          
        </xsl:apply-templates>
  
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/processing-structure.xml" method="xml">
            <xsl:copy-of select="$processingStructure"/>
        </xsl:result-document>
            
        <!-- We generate a CURL output so that all files can be loaded up automatically -->
        <xsl:for-each select="distinct-values($processingStructure//document/@testSet/tokenize(., ' '))">
            <xsl:variable name="testSet" select="."/>
            <!-- We don't include certain test sets because they are designed for subsequent calls -->
            <xsl:if test="not($testSet = ('performanceDataPUT'))">
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                    '[Y0001][M01][D01]')}/{$env}/{$testSet}-urn-curl-file.bat" method="text">
                    <xsl:text>md results&#10;</xsl:text>
                    <xsl:variable name="documentCount" select="count($processingStructure//document[contains(@testSet, $testSet) and @urn])"/>
                    <xsl:for-each select="$processingStructure//document[contains(@testSet, $testSet) and @urn and not(parent::relation[@embed = 'true'])]">
                        <!-- We do the deepest children first because they get used by ancestors so need to be loaded into API first -->
                        <xsl:sort select="count(ancestor::*)" order="descending"/>
                        <xsl:text>timeout 1&#10;</xsl:text>
                        <xsl:text>echo </xsl:text>
                        <xsl:value-of select="concat(position(), ' of ', $documentCount)"/>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:call-template name="GenerateCurlWriteListEntry">
                            <xsl:with-param name="type" select="@type"/>
                            <xsl:with-param name="uuid" select="@uuid"/>
                            <xsl:with-param name="urn" select="@urn"/>
                            <xsl:with-param name="testSet" select="$testSet"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:result-document>
                <!-- And for no URN -->
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                    '[Y0001][M01][D01]')}/{$env}/{$testSet}-no-urn-curl-file.bat" method="text">
                    <xsl:text>md results&#10;</xsl:text>
                    <xsl:variable name="documentCount" select="count($processingStructure//document[contains(@testSet, $testSet) and not(@urn)])"/>
                    <xsl:for-each select="$processingStructure//document[contains(@testSet, $testSet) and not(@urn)]">
                        <!-- We do the deepest children first because they get used by ancestors so need to be loaded into API first -->
                        <xsl:sort select="count(ancestor::*)" order="descending"/>
                        <xsl:text>timeout 1&#10;</xsl:text>
                        <xsl:text>echo </xsl:text>
                        <xsl:value-of select="concat(position(), ' of ', $documentCount)"/>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:call-template name="GenerateCurlWriteListEntry">
                            <xsl:with-param name="type" select="@type"/>
                            <xsl:with-param name="uuid" select="@uuid"/>
                            <xsl:with-param name="urn" select="@urn"/>
                            <xsl:with-param name="testSet" select="$testSet"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>

        <!-- We generate a CURL output so that all files can be read automatically (if they have a pre-generated URN) -->
        <xsl:for-each select="distinct-values($processingStructure//document/@testSet/tokenize(., ' '))">
            <xsl:variable name="testSet" select="."/>
            <xsl:for-each select="distinct-values($processingStructure//document[contains(@testSet, $testSet)]/@type)">
                <xsl:variable name="type" select="."/>
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                '[Y0001][M01][D01]')}/{$env}/{$testSet}-{lower-case(translate($type, ' ', ''))}-read-curl-file.bat" method="text">
                    <xsl:text>md results&#10;</xsl:text>
                    <xsl:variable name="documentCount" select="count($processingStructure//document[contains(@testSet, $testSet) and @type = $type and @urn])"/>
                    <!-- We only include items that have a pre-generated URN -->
                    <xsl:for-each select="$processingStructure//document[contains(@testSet, $testSet) and @type = $type and @urn]">
                        <xsl:text>timeout 1&#10;</xsl:text>
                        <xsl:text>echo </xsl:text>
                        <xsl:value-of select="concat(position(), ' of ', $documentCount)"/>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:call-template name="GenerateCurlReadListEntry">
                            <xsl:with-param name="urn" select="@urn"/>
                            <xsl:with-param name="uuid" select="@uuid"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:result-document>  
            </xsl:for-each>
        </xsl:for-each>

        <!-- We generate a list of all URIs generated (for pre-generated URNs) -->
        <xsl:for-each select="distinct-values($processingStructure//document/@testSet/tokenize(., ' '))">
            <xsl:variable name="testSet" select="."/>
            <xsl:for-each select="distinct-values($processingStructure//document[contains(@testSet, $testSet)]/@type)">
                <xsl:variable name="type" select="."/>
                <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
                    '[Y0001][M01][D01]')}/{$env}/{$testSet}-{lower-case(translate($type, ' ', ''))}-uri-list.txt" method="text">
                    <xsl:variable name="documentCount" select="count($processingStructure//document[contains(@testSet, $testSet) and @type = $type and @urn])"/>
                    <!-- We only include items that have a pre-generated URN -->
                    <xsl:for-each select="$processingStructure//document[contains(@testSet, $testSet) and @type = $type and @urn]">
                        <xsl:call-template name="GenerateURIlistEntry">
                            <xsl:with-param name="urn" select="@urn"/>
                            <xsl:with-param name="uuid" select="@uuid"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:result-document>  
            </xsl:for-each>
        </xsl:for-each>

        <!-- We generate a list of all patch mappings to associate bulk patches with UUIDs -->
        <xsl:result-document href="{$outputFolder}/generated-{format-date(current-date(),
            '[Y0001][M01][D01]')}/{$env}/patch-crossref.txt" method="text">
            <xsl:for-each select="$processingStructure/*/patch">
                <xsl:value-of select="@uuid"/>
                <xsl:text>&#9;</xsl:text>
                <xsl:value-of select="@correspondingUrn"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>  
        
    </xsl:template>

    <xsl:template name="GenerateMetadataGraphQuads">
        <xsl:param name="urn" required="yes"/>
        <xsl:variable name="graphUrl" select="concat('https://data.pearson.com/graph/', translate(substring-after($urn, 'pearson:'), ':', '/'))"/>
        <xsl:variable name="metadataGraphUrl" select="concat('https://data.pearson.com/metadata/graph/', translate(substring-after($urn, 'pearson:'), ':', '/'))"/>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$graphUrl"/>
        <xsl:text>&gt; &lt;https://schema.pearson.com/ns/raf/latest&gt; "1"^^&lt;http://www.w3.org/2001/XMLSchema#int&gt; &lt;</xsl:text>
        <xsl:value-of select="$metadataGraphUrl"/>
        <xsl:text>&gt; .&#10;&lt;</xsl:text>
        <xsl:value-of select="$graphUrl"/>
        <xsl:text>&gt; &lt;https://schema.pearson.com/ns/raf/checkedout&gt; "true"^^&lt;http://www.w3.org/2001/XMLSchema#boolean&gt; &lt;</xsl:text>
        <xsl:value-of select="$metadataGraphUrl"/>
        <xsl:text>&gt; .&#10;&lt;</xsl:text>
        <xsl:value-of select="$graphUrl"/>
        <xsl:text>&gt; &lt;https://schema.pearson.com/ns/raf/revision&gt; &lt;</xsl:text>
        <xsl:value-of select="$graphUrl"/>
        <xsl:text>/1&gt; &lt;</xsl:text>
        <xsl:value-of select="$metadataGraphUrl"/>
        <xsl:text>&gt; .&#10;</xsl:text>         
    </xsl:template>
    
    <xsl:template name="GenerateCurlWriteListEntry">
        <xsl:param name="type" required="yes"/>
        <xsl:param name="uuid" required="yes"/>
        <xsl:param name="urn" required="yes"/>
        <xsl:param name="testSet"/>
        <xsl:text>curl -X POST -d @json/</xsl:text>
        <xsl:value-of select="$testSet"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="if (not($urn)) then 'no-urn/' else 'urn/'"/>
        <xsl:value-of select="lower-case(translate($type, ' ', ''))"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="lower-case(translate($type, ' ', ''))"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@uuid"/>
        <xsl:text>.json -H "Content-Type: application/json" </xsl:text>
        <xsl:value-of select="$environmentURLs[@name = $env]/@authText"/>
        <xsl:text> -k </xsl:text>
        <xsl:value-of select="$environmentURLs[@name = $env]"/>
        <xsl:text>/thing?db=</xsl:text>
        <xsl:value-of select="$devDB"/>
        <xsl:text> -o results/results-</xsl:text>
        <xsl:value-of select="$testSet"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="lower-case(translate($type, ' ', ''))"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="$uuid"/>
        <xsl:text>.txt -i&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template name="GenerateCurlReadListEntry">
        <xsl:param name="urn" required="yes"/>
        <xsl:param name="uuid" required="yes"/>
        <xsl:text>curl -H "Accept: application/ld+json" </xsl:text>
        <xsl:value-of select="$environmentURLs[@name = $env]/@authText"/>
        <xsl:text> -k </xsl:text>
        <xsl:value-of select="$environmentURLs[@name = $env]"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="substring-before(substring-after($urn, 'pearson:'), ':')"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="lower-case($uuid)"/>
        <xsl:text>?db=</xsl:text>
        <xsl:value-of select="$devDB"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template name="GenerateURIlistEntry">
        <xsl:param name="urn" required="yes"/>
        <xsl:param name="uuid" required="yes"/>
        <xsl:value-of select="$environmentURLs[@name = $env]"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="substring-before(substring-after($urn, 'pearson:'), ':')"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="lower-case($uuid)"/>
        <xsl:text>?db=</xsl:text>
        <xsl:value-of select="$devDB"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="documents">
        <xsl:apply-templates select="document"/>
    </xsl:template>

    <xsl:template match="relation">
        <xsl:apply-templates select="document"/>
    </xsl:template>
    
</xsl:stylesheet>