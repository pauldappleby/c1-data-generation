<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:__x="http://www.w3.org/1999/XSL/TransformAliasAlias"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:impl="urn:x-xspec:compile:xslt:impl"
                xmlns:xpf="http://www.w3.org/2005/xpath-functions"
                version="2.0">
   <xsl:import href="file:/C:/c-1/c1-data-generation/c1-data-generation-content.xsl"/>
   <xsl:import href="file:/C:/Oxygen%20XML%20Developer%2015/frameworks/xspec/src/compiler/generate-tests-utils.xsl"/>
   <xsl:namespace-alias stylesheet-prefix="__x" result-prefix="xsl"/>
   <xsl:variable name="x:stylesheet-uri"
                 as="xs:string"
                 select="'file:/C:/c-1/c1-data-generation/c1-data-generation-content.xsl'"/>
   <xsl:output name="x:report" method="xml" indent="yes"/>
   <xsl:template name="x:main">
      <xsl:message>
         <xsl:text>Testing with </xsl:text>
         <xsl:value-of select="system-property('xsl:product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:message>
      <xsl:result-document format="x:report">
         <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="file:/C:/Oxygen%20XML%20Developer%2015/frameworks/xspec/src/compiler/format-xspec-report.xsl"</xsl:processing-instruction>
         <x:report stylesheet="{$x:stylesheet-uri}" date="{current-dateTime()}">
            <xsl:call-template name="x:d5e2"/>
            <xsl:call-template name="x:d5e26"/>
            <xsl:call-template name="x:d5e35"/>
         </x:report>
      </xsl:result-document>
   </xsl:template>
   <xsl:template name="x:d5e2">
      <xsl:message>When generating a Manifestation</xsl:message>
      <x:scenario>
         <x:label>When generating a Manifestation</x:label>
         <x:context>
            <document type="Manifestation"
                      uuid="1b367165-2f72-4091-bf5a-1838e3bb26ad"
                      urn="urn:pearson:manifestation:1b367165-2f72-4091-bf5a-1838e3bb26ad"/>
         </x:context>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable name="impl:context-doc" as="document-node()">
               <xsl:document>
                  <document type="Manifestation"
                            uuid="1b367165-2f72-4091-bf5a-1838e3bb26ad"
                            urn="urn:pearson:manifestation:1b367165-2f72-4091-bf5a-1838e3bb26ad"/>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="impl:context" select="$impl:context-doc/node()"/>
            <xsl:apply-templates select="$impl:context"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e5">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e5">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>It should return an XML document</xsl:message>
      <xsl:variable name="impl:expected-doc" as="document-node()">
         <xsl:document>
            <xpf:map>
               <xpf:array key="@context">
                  <xsl:text>...</xsl:text>
               </xpf:array>
               <xpf:array key="type">
                  <xpf:string>
                     <xsl:text>Manifestation</xsl:text>
                  </xpf:string>
                  <xpf:string>
                     <xsl:text>...</xsl:text>
                  </xpf:string>
               </xpf:array>
               <xpf:string key="id">
                  <xsl:text>urn:pearson:manifestation:1b367165-2f72-4091-bf5a-1838e3bb26ad</xsl:text>
               </xpf:string>
               <xpf:map key="name">
                  <xpf:string key="en">
                     <xsl:text>The Serious back</xsl:text>
                  </xpf:string>
               </xpf:map>
               <xpf:array key="exampleOfWork">
                  <xpf:string>
                     <xsl:text>urn:pearson:work:b4fd4b29-af8d-48a7-82b1-3fe4d4a8d8b5</xsl:text>
                  </xpf:string>
               </xpf:array>
               <xpf:string key="dateCreated">
                  <xsl:text>...</xsl:text>
               </xpf:string>
               <xpf:string key="format">
                  <xsl:text>...</xsl:text>
               </xpf:string>
            </xpf:map>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="impl:expected" select="$impl:expected-doc/node()"/>
      <xsl:variable name="impl:successful"
                    as="xs:boolean"
                    select="test:deep-equal($impl:expected, $x:result, 2)"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{$impl:successful}">
         <x:label>It should return an XML document</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$impl:expected"/>
            <xsl:with-param name="wrapper-name" select="'x:expect'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e26">
      <xsl:message>When generating a document if a shortName relationship is defined on a relation</xsl:message>
      <x:scenario>
         <x:label>When generating a document if a shortName relationship is defined on a relation</x:label>
         <x:context select="/document" mode="AddRelationships">
            <document type="WorkContainer"
                      uuid="6604a040-06e6-4720-9844-fb327ec23670"
                      urn="urn:pearson:work:6604a040-06e6-4720-9844-fb327ec23670">
               <relation IRI="http://schema.org/hasPart"
                         shortName="hasPart"
                         reverseIRI="http://schema.org/isPartOf"
                         reverseShortName="isPartOf">
                  <document type="Work"
                            uuid="8788ba57-67da-4e67-a478-9c5338e3375a"
                            urn="urn:pearson:work:8788ba57-67da-4e67-a478-9c5338e3375a"/>
               </relation>
            </document>
         </x:context>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable name="impl:context-doc" as="document-node()">
               <xsl:document>
                  <document type="WorkContainer"
                            uuid="6604a040-06e6-4720-9844-fb327ec23670"
                            urn="urn:pearson:work:6604a040-06e6-4720-9844-fb327ec23670">
                     <relation IRI="http://schema.org/hasPart"
                               shortName="hasPart"
                               reverseIRI="http://schema.org/isPartOf"
                               reverseShortName="isPartOf">
                        <document type="Work"
                                  uuid="8788ba57-67da-4e67-a478-9c5338e3375a"
                                  urn="urn:pearson:work:8788ba57-67da-4e67-a478-9c5338e3375a"/>
                     </relation>
                  </document>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="impl:context" select="$impl:context-doc/(/document)"/>
            <xsl:apply-templates select="$impl:context" mode="AddRelationships"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e31">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e31">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>It should return an XML fragment containing that relationship</xsl:message>
      <xsl:variable name="impl:expected-doc" as="document-node()">
         <xsl:document>
            <xpf:array key="hasPart">
               <xpf:string>
                  <xsl:text>urn:pearson:work:8788ba57-67da-4e67-a478-9c5338e3375a</xsl:text>
               </xpf:string>
            </xpf:array>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="impl:expected" select="$impl:expected-doc/node()"/>
      <xsl:variable name="impl:successful"
                    as="xs:boolean"
                    select="test:deep-equal($impl:expected, $x:result, 2)"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{$impl:successful}">
         <x:label>It should return an XML fragment containing that relationship</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$impl:expected"/>
            <xsl:with-param name="wrapper-name" select="'x:expect'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e35">
      <xsl:message>When generating a document if a reverseShortName relationship is defined on a relation</xsl:message>
      <x:scenario>
         <x:label>When generating a document if a reverseShortName relationship is defined on a relation</x:label>
         <x:context select="/document/relation" mode="AddReverseRelationships">
            <document type="WorkContainer"
                      uuid="6604a040-06e6-4720-9844-fb327ec23670"
                      urn="urn:pearson:work:6604a040-06e6-4720-9844-fb327ec23670">
               <relation IRI="http://schema.org/hasPart"
                         shortName="hasPart"
                         reverseIRI="http://schema.org/isPartOf"
                         reverseShortName="isPartOf">
                  <document type="Work"
                            uuid="8788ba57-67da-4e67-a478-9c5338e3375a"
                            urn="urn:pearson:work:8788ba57-67da-4e67-a478-9c5338e3375a"/>
               </relation>
            </document>
         </x:context>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable name="impl:context-doc" as="document-node()">
               <xsl:document>
                  <document type="WorkContainer"
                            uuid="6604a040-06e6-4720-9844-fb327ec23670"
                            urn="urn:pearson:work:6604a040-06e6-4720-9844-fb327ec23670">
                     <relation IRI="http://schema.org/hasPart"
                               shortName="hasPart"
                               reverseIRI="http://schema.org/isPartOf"
                               reverseShortName="isPartOf">
                        <document type="Work"
                                  uuid="8788ba57-67da-4e67-a478-9c5338e3375a"
                                  urn="urn:pearson:work:8788ba57-67da-4e67-a478-9c5338e3375a"/>
                     </relation>
                  </document>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="impl:context" select="$impl:context-doc/(/document/relation)"/>
            <xsl:apply-templates select="$impl:context" mode="AddReverseRelationships"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e40">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e40">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>It should return an XML fragment containing that relationship</xsl:message>
      <xsl:variable name="impl:expected-doc" as="document-node()">
         <xsl:document>
            <xpf:array key="isPartOf">
               <xpf:string>
                  <xsl:text>urn:pearson:work:6604a040-06e6-4720-9844-fb327ec23670</xsl:text>
               </xpf:string>
            </xpf:array>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="impl:expected" select="$impl:expected-doc/node()"/>
      <xsl:variable name="impl:successful"
                    as="xs:boolean"
                    select="test:deep-equal($impl:expected, $x:result, 2)"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{$impl:successful}">
         <x:label>It should return an XML fragment containing that relationship</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$impl:expected"/>
            <xsl:with-param name="wrapper-name" select="'x:expect'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
</xsl:stylesheet>
