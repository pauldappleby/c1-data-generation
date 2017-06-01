<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jld="https://example.com"
    xmlns:sem="http://marklogic.com/semantics"
    xmlns:xpf="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">   
   
    <xsl:template name="jld:xml-to-quads">
        <xsl:param name="XMLinput"/>
        <xsl:apply-templates select="$XMLinput" mode="xml-to-quads"/>
    </xsl:template>
    
    <xsl:template match="*" mode="xml-to-quads">
        <xsl:param name="resource" tunnel="yes"/>
        <xsl:param name="graph" tunnel="yes"/>
        <xsl:variable name="newResource" select="xpf:string[@key = 'id']"/>
        <xsl:variable name="newGraph" select="concat('&lt;https://data.pearson.com/graph/', translate(substring-after(xpf:string[@key = 'id'], 'pearson:'), ':', '/'), '&gt;')"/>
        <xsl:apply-templates select="*" mode="#current">
            <xsl:with-param name="resource" select="if ($newResource) then $newResource else $resource" tunnel="yes"/>
            <xsl:with-param name="graph" select="if ($newResource) then $newGraph else $graph" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[@key = ('@context', 'id')]" mode="xml-to-quads" priority="100"/>

    <xsl:template match="xpf:array[@key = 'type']/xpf:string" mode="xml-to-quads">
        <xsl:param name="resource" tunnel="yes"/>
        <xsl:param name="graph" tunnel="yes"/>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$resource"/>
        <xsl:text>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; </xsl:text>        
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="@IRI"/>
        <xsl:text>&gt; </xsl:text>   
        <xsl:value-of select="$graph"/>
        <xsl:text> .&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="xpf:string" mode="xml-to-quads">
        <xsl:param name="resource" tunnel="yes"/>
        <xsl:param name="graph" tunnel="yes"/>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="$resource"/>
        <xsl:text>&gt; &lt;</xsl:text>
        <xsl:value-of select="@IRI"/>
        <xsl:text>&gt; </xsl:text>
        <xsl:choose>
            <xsl:when test="@type = 'IRI'">
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>&gt;</xsl:text>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text>                
                <xsl:value-of select="."/>
                <xsl:text>"</xsl:text> 
                <xsl:choose>
                    <xsl:when test="@language">
                        <xsl:text>@</xsl:text>
                        <xsl:value-of select="@language"/>                        
                    </xsl:when>
                    <xsl:when test="@type">
                        <xsl:text>^^&lt;</xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text>&gt;</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$graph"/>
        <xsl:text> .&#10;</xsl:text>
    </xsl:template>
    
    
</xsl:stylesheet>
