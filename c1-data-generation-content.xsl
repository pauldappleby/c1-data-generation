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
    
    <xsl:template match="document[@type = 'Work Container']">
        <xsl:param name="keywordCount" select="xs:integer(floor(rd:random-sequence(1) * 5))" as="xs:integer?"/>
        <xsl:param name="subjectCount" select="xs:integer(floor(rd:random-sequence(1) * 5))" as="xs:integer?"/>
        <xpf:map>
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Work</xsl:with-param>
                <xsl:with-param name="baseTypeIRI">https://schema.pearson.com/ns/content/Work</xsl:with-param>
                <xsl:with-param name="extendedTypes" select="('Container')"/>
                <xsl:with-param name="extendedTypesIRIs" select="('https://schema.pearson.com/ns/content/Container')"/>
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>                 
            </xsl:call-template>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xpf:map key="name" IRI="http://schema.org/name" type="LanguageContainer">
                <xpf:string key="en" IRI="http://schema.org/name" language="en">
                    <xsl:value-of select="c1:getName(position())"/>
                </xpf:string>
            </xpf:map>
            <xsl:apply-templates select="relation" mode="AddRelationships"/>
            <xsl:call-template name="getDateCreated">
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>
            </xsl:call-template>
            <xsl:call-template name="getKeywords">
                <xsl:with-param name="keysCount" select="$keywordCount"/>
            </xsl:call-template>
            <xsl:call-template name="getSubjects">
                <xsl:with-param name="subjectCount" select="$subjectCount"/>               
            </xsl:call-template>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'Work']">
        <xsl:param name="randomNumbers" select="rd:random-sequence(2)"/>
        <xsl:param name="keywordCount" select="xs:integer(floor($randomNumbers[1] * 5))" as="xs:integer?"/>
        <xsl:param name="subjectCount" select="xs:integer(floor($randomNumbers[2] * 5))" as="xs:integer?"/>
        <xpf:map>
            <xsl:call-template name="getType">
                <xsl:with-param name="baseType">Work</xsl:with-param>
                <xsl:with-param name="baseTypeIRI">https://schema.pearson.com/ns/content/Work</xsl:with-param>
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>                 
            </xsl:call-template>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xpf:map key="name" IRI="http://schema.org/name" type="LanguageContainer">
                <xpf:string key="en" IRI="http://schema.org/name" language="en">
                    <xsl:value-of select="c1:getName(position())"/>
                </xpf:string>
            </xpf:map>
            <xsl:apply-templates select="parent::relation" mode="AddReverseRelationships"/>
            <xsl:apply-templates select="relation" mode="AddRelationships"/>
            <xsl:call-template name="getDateCreated">
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>
            </xsl:call-template>
            <xsl:call-template name="getKeywords">
                <xsl:with-param name="keysCount" select="$keywordCount"/>
            </xsl:call-template>
            <xsl:call-template name="getSubjects">
                <xsl:with-param name="subjectCount" select="$subjectCount"/>               
            </xsl:call-template>
            <!-- Generate a PATCH for this Work -->
            <xsl:apply-templates select="." mode="ProcessPatch"/>
        </xpf:map>
    </xsl:template>

    <!-- Output for a PATCH replacement -->
    <xsl:template match="document[@type = 'Work']" mode="PatchReplace">
        <xpf:map>
            <xpf:map key="@context">
                <xpf:string key="@language">en</xpf:string>
            </xpf:map>
            <xpf:string key="subject" IRI="https://schema.pearson.com/ns/changeset/subject" type="IRI">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:string key="predicate" IRI="https://schema.pearson.com/ns/changeset/predicate" type="IRI">http://schema.org/name</xpf:string>
            <xpf:string key="object" IRI="https://schema.pearson.com/ns/changeset/object">
                <xsl:value-of select="c1:getName(position() + 1)"/>                       
            </xpf:string>
        </xpf:map>
    </xsl:template>
    
    <xsl:template match="document[@type = 'Manifestation']">
        <xpf:map>
            <xsl:variable name="uuid" select="@uuid"/>
            <xsl:variable name="getTypes">
                <xsl:call-template name="getType">
                    <xsl:with-param name="baseType">Manifestation</xsl:with-param>
                    <xsl:with-param name="baseTypeIRI">https://schema.pearson.com/ns/content/Manifestation</xsl:with-param>
                    <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>                 
                </xsl:call-template>
            </xsl:variable>
            <xsl:copy-of select="$getTypes"/>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xpf:map key="name" IRI="http://schema.org/name" type="LanguageContainer">
                <xpf:string key="en" IRI="http://schema.org/name" language="en">
                    <xsl:value-of select="c1:getName(c1:seedFromUUID(@uuid))"/>
                </xpf:string>
            </xpf:map>
            <xsl:apply-templates select="parent::relation" mode="AddReverseRelationships"/>
            <xsl:apply-templates select="relation" mode="AddRelationships"/>
            <xsl:call-template name="getDateCreated">
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>
            </xsl:call-template>
            <!-- Exclude is for testing -->
            <xsl:if test="not(contains(@exclude, 'formats'))">
                <xsl:call-template name="getFormat">
                    <xsl:with-param name="types" select="$getTypes"/>
                    <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select="." mode="ProcessPatch"/>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'Manifestation']" mode="PatchReplace">
        <xpf:map>
            <xpf:map key="@context">
                <xpf:string key="@language">en</xpf:string>
            </xpf:map>
            <xpf:string key="subject" IRI="https://schema.pearson.com/ns/changeset/subject" type="IRI">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:string key="predicate" IRI="https://schema.pearson.com/ns/changeset/predicate" type="IRI">http://schema.org/name</xpf:string>
            <xpf:string key="object" IRI="https://schema.pearson.com/ns/changeset/object">
                <xsl:value-of select="c1:getName(c1:seedFromUUID(@uuid) + 1)"/>                       
            </xpf:string>
        </xpf:map>
    </xsl:template>
    
    <xsl:template match="document[@type = 'IdentifierAxiom']">
        <xpf:map>
            <xpf:array key="type">
                <xpf:string IRI="https://schema.pearson.com/ns/xowl/IdentifierAxiom">IdentifierAxiom</xpf:string>
            </xpf:array>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xpf:string key="idTerm" type="IRI" IRI="https://schema.pearson.com/ns/xowl/idTerm">https://schema.pearson.com/ns/system/epsID</xpf:string>
            <xpf:string key="idValue" type="IRI" IRI="https://schema.pearson.com/ns/xowl/idValue">urn:pearson:eps:<xsl:value-of select="uuid:randomUUID()"/></xpf:string>
            <xsl:apply-templates select="." mode="ProcessPatch"/>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'IdentifierAxiom']" mode="PatchReplace">
        <xpf:map>
            <xpf:string key="subject" IRI="https://schema.pearson.com/ns/changeset/subject" type="IRI">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:string key="predicate" IRI="https://schema.pearson.com/ns/changeset/predicate" type="IRI">https://schema.pearson.com/ns/xowl/idValue</xpf:string>
            <xpf:map key="object" IRI="https://schema.pearson.com/ns/changeset/object">
                <xpf:string key="id">urn:pearson:eps:<xsl:value-of select="uuid:randomUUID()"/></xpf:string>
            </xpf:map>
        </xpf:map>
    </xsl:template>
    
    <xsl:template match="document[@type = 'MatchAxiom']">
        <xpf:map>
            <xpf:array key="type">
                <xpf:string IRI="https://schema.pearson.com/ns/xkos/IdentifierAxiom">MatchAxiom</xpf:string>
            </xpf:array>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xsl:variable name="set" select="@testSet"/>
            <xsl:variable name="learningObjectives" select="//document[contains(@testSet, $set) and @type = 'EducationalGoal' and @urn]"/>
            <xsl:variable name="randomNumbers" select="rd:random-sequence(2, c1:seedFromUUID(@uuid))"/>
            <xsl:variable name="subjectLOindex" select="xs:integer($randomNumbers[1] * count($learningObjectives) + 1)" as="xs:integer?"/>
            <xsl:variable name="targetLOindex" select="xs:integer($randomNumbers[2] * count($learningObjectives) + 1)" as="xs:integer?"/>
            <xsl:variable name="subjectLO" select="$learningObjectives[$subjectLOindex]/@urn"/>                    
            <xsl:variable name="targetLO" select="$learningObjectives[$targetLOindex]/@urn"/>                    
            <xpf:string key="matchType" type="IRI" IRI="https://schema.pearson.com/ns/xkos/matchType">http://www.w3.org/2004/02/skos/core#exactMatch</xpf:string>
            <xpf:string key="matchSubject" type="IRI" IRI="https://schema.pearson.com/ns/xkos/matchSubject"><xsl:value-of select="$subjectLO"/></xpf:string>
            <xpf:string key="matchTarget" type="IRI" IRI="https://schema.pearson.com/ns/xkos/matchTarget"><xsl:value-of select="$targetLO"/></xpf:string>
            <xsl:apply-templates select="." mode="ProcessPatch"/>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'MatchAxiom']" mode="PatchReplace">
        <xpf:map>
            <xpf:string key="subject" IRI="https://schema.pearson.com/ns/changeset/subject" type="IRI">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:string key="predicate" IRI="https://schema.pearson.com/ns/changeset/predicate" type="IRI">https://schema.pearson.com/ns/xkos/matchType</xpf:string>
            <xpf:map key="object" IRI="https://schema.pearson.com/ns/changeset/object">
                <xpf:string key="id">http://www.w3.org/2004/02/skos/core#closeMatch</xpf:string>
            </xpf:map>
        </xpf:map>
    </xsl:template>
    
    <xsl:template match="document[@type = 'GoalFramework']">
        <xpf:map>
            <xpf:array key="type">
                <xpf:string IRI="https://schema.pearson.com/ns/learn/GoalFramework">GoalFramework</xpf:string>
            </xpf:array>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xsl:apply-templates select="relation" mode="AddRelationships"/>
        </xpf:map>
    </xsl:template>
    
    <xsl:template match="document[@type = 'EducationalGoal']">
        <xpf:map>
            <xpf:array key="type">
                <xpf:string IRI="https://schema.pearson.com/ns/learn/LearningObjective">LearningObjective</xpf:string>
            </xpf:array>
            <xsl:if test="@urn">
                <xpf:string key="id">
                    <xsl:value-of select="@urn"/>
                </xpf:string>
            </xsl:if>
            <xsl:call-template name="getLearningObjectiveDescription">
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>
            </xsl:call-template>
            <xsl:call-template name="getLearningDimension">
                <xsl:with-param name="seed" select="c1:seedFromUUID(@uuid)"/>
            </xsl:call-template>
            <xsl:apply-templates select="." mode="ProcessPatch"/>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document[@type = 'EducationalGoal']" mode="PatchReplace">
        <xpf:map>
            <xpf:string key="subject" IRI="https://schema.pearson.com/ns/changeset/subject" type="IRI">
                <xsl:value-of select="@urn"/>
            </xpf:string>
            <xpf:string key="predicate" IRI="https://schema.pearson.com/ns/changeset/predicate" type="IRI">https://schema.pearson.com/ns/learn/learningDimension</xpf:string>
            <xpf:map key="object" IRI="https://schema.pearson.com/ns/changeset/object">
                <xsl:variable name="dimensionIndex" select="
                    for $num in rd:random-sequence(1, c1:seedFromUUID(@uuid))
                    return
                    xs:integer(floor($num * count($learningDimension)))"/>
                <xpf:string key="id">
                    <xsl:value-of select="$learningDimension[$dimensionIndex]"/>
                </xpf:string>                  
            </xpf:map>
        </xpf:map>
    </xsl:template>

    <xsl:template match="document" mode="ProcessPatch">
        <xsl:if test="@patchSet">
            <xpf:array key="replacement" type="IRI" IRI="https://schema.pearson.com/ns/changeset/replacement" patchContent="true">
                <xsl:apply-templates select="." mode="PatchReplace"/>
            </xpf:array>
        </xsl:if>    
    </xsl:template>
    
    <!-- Generate eTag for a document -->
    <xsl:template match="document" mode="PatchEtags">
        <xpf:map>
            <xpf:string key="eTagResource"><xsl:value-of select="@urn"/></xpf:string>
            <xpf:string key="ifMatch">{{<xsl:value-of select="@uuid"/>}}</xpf:string>
        </xpf:map>
    </xsl:template>
    
    <!-- For patch elements, which are for bulk patches, we need to generate eTag information in the payload -->    
    <xsl:template match="patch">
        <xpf:array key="eTagInformation">
            <xsl:apply-templates select="document" mode="PatchEtags"/>
        </xpf:array>
        <xpf:array key="replacement" type="IRI" IRI="https://schema.pearson.com/ns/changeset/replacement" patchContent="true">
            <xsl:apply-templates select="document" mode="PatchReplace"/>
        </xpf:array>
    </xsl:template>
    
    <xsl:template match="relation" mode="AddRelationships">
        <xsl:variable name="relatedUrns" select="document/@urn"/>
        <xsl:if test="not(empty($relatedUrns))">
            <xsl:variable name="iri" select="@IRI"/>
            <xpf:array key="{@shortName}" IRI="{$iri}">
                <xsl:for-each select="$relatedUrns">
                    <xpf:string type="IRI" IRI="{$iri}">
                        <xsl:value-of select="."/>
                    </xpf:string>
                </xsl:for-each>
            </xpf:array>
        </xsl:if>
    </xsl:template>

    <xsl:template match="relation[@embed = 'true']" mode="AddRelationships">
        <xsl:variable name="relatedUrns" select="document"/>
        <xsl:if test="not(empty($relatedUrns))">
            <xsl:variable name="iri" select="@IRI"/>
            <xpf:array key="{@shortName}" IRI="{$iri}">
                <xsl:apply-templates select="*"/>
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