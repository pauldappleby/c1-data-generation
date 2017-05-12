<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jld="https://example.com"
    xmlns:sem="http://marklogic.com/semantics"
    xmlns:xpf="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">   
   
    <xsl:template name="jld:XML-to-JSON">
        <xsl:param name="XMLinput"/>
        <xsl:apply-templates select="$XMLinput" mode="xml-to-json"/>
    </xsl:template>
    
    <xsl:template match="xpf:array[not(@key)]" mode="xml-to-json">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="*" mode="#current"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>

    <xsl:template match="xpf:array[@key]" mode="xml-to-json">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="if (@compactKey != '') then @compactKey else @key"/>
        <xsl:text>": [</xsl:text>
        <xsl:apply-templates select="*" mode="#current"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>

    <xsl:template match="xpf:map[not(@key)]" mode="xml-to-json">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="*" mode="#current"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>
    
    <xsl:template match="xpf:map[@key]" mode="xml-to-json">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="if (@compactKey != '') then @compactKey else @key"/>
        <xsl:text>": {</xsl:text>
        <xsl:apply-templates select="*" mode="#current"/>
        <xsl:text>}</xsl:text>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>

    <xsl:template match="xpf:string[@key]" mode="xml-to-json">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="if (@compactKey != '') then @compactKey else @key"/>
        <xsl:text>": "</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>
    
    <!-- Will be strings in arrays -->
    <xsl:template match="xpf:string[not(@key)]" mode="xml-to-json">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
