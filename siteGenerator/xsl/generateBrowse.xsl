<xsl:stylesheet  
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:x="http://www.w3.org/1999/xhtml"  
    xmlns:saxon="http://saxon.sf.net/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:local="http://syriaca.org/ns" 
    exclude-result-prefixes="xs t x saxon local" version="3.0">

 <!-- ================================================================== 
      Adapted for eGedsh - generateBrowseL.xsl
       
       Generate Static Browse HTML pages 
       
       code by: 
        + Winona Salesky (wsalesky@gmail.com)
          
       
       ================================================================== -->

    <xsl:output name="html" encoding="UTF-8" method="xhtml" indent="no" omit-xml-declaration="yes"/>    
 
    <!-- =================================================================== -->
    <!-- Parameters for tei2HTML -->
    <!-- =================================================================== -->
    
    <!--
    Examples for converting the syriaca application to Gaddel    
    <xsl:param name="applicationPath" select="'/Users/wsalesky/syriaca/syriaca/syriaca'"/>
    <xsl:param name="staticSitePath" select="'/Users/wsalesky/syriaca/syriaca/syriacaStatic'"/>
    <xsl:param name="dataPath" select="'/Users/wsalesky/syriaca/syriaca/syriaca-data-test/data/'"/>
    <xsl:param name="applicationPath" select="'../../'"/>
    <xsl:param name="staticSitePath" select="'../../'"/>
    <xsl:param name="convert" select="'true'"/>
    -->
    
    <xsl:param name="applicationPath" select="'/Users/wsalesky/syriaca/translations/translations-app'"/>
    <xsl:param name="staticSitePath" select="'/Users/wsalesky/syriaca/translations/translations-app'"/>
    <xsl:param name="dataPath" select="'/Users/wsalesky/syriaca/translations/translations-data/tei'"/>
    <!-- Find repo-config to find collection style values and page stubs -->
    <xsl:variable name="configPath">
        <xsl:choose>
            <xsl:when test="$applicationPath != ''">
                <xsl:value-of select="concat($staticSitePath, '/siteGenerator/components/repo-config.xml')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'../components/repo-config.xml'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Get configuration file.  -->
    <xsl:variable name="config">
        <xsl:if test="doc-available(xs:anyURI($configPath))">
            <xsl:sequence select="document(xs:anyURI($configPath))"/>
        </xsl:if>
    </xsl:variable>
   
    <xsl:variable name="collectionValues" select="$config/descendant::*:collection[1]"/>        
    <xsl:variable name="collectionTemplate">
        <xsl:message>Find generic page.html template</xsl:message>
        <xsl:variable name="templatePath" select="replace(concat($staticSitePath,'/siteGenerator/components/page.html'),'//','/')"/>
        <xsl:if test="doc-available(xs:anyURI($templatePath))">
            <xsl:sequence select="document(xs:anyURI($templatePath))"/>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="collection" select="$collectionValues/@name"/>
    
    <xsl:variable name="template">
        <xsl:choose>
            <xsl:when test="$collectionTemplate/child::*">
                <xsl:sequence select="$collectionTemplate"/> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Error Can not find matching template for HTML page </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:result-document href="{concat($staticSitePath,'/browse.html')}">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <!-- Header -->
                <xsl:choose>
                    <xsl:when test="$template/descendant::*:head">
                        <xsl:copy-of select="$template/descendant::*:head"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:message>No template found for html:head element</xsl:message></xsl:otherwise>
                </xsl:choose>
                <body id="body">
                    <script src="/resources/js/navbar-search.js"></script>
                    <div id="navbar-container"></div>
                    <div class="main-content-block">
                        <h1>Browse Entries</h1>
                        <!-- Browse Content -->        
                        <div class="container">
                            <xsl:for-each select="collection(concat($dataPath,'/.?select=*.xml'))">
                                <xsl:sort select="normalize-space(descendant::t:title[1])"></xsl:sort>
                                <xsl:variable name="fileName" select="substring-before(tokenize(document-uri(.),'/')[last()],'.')"/>
                                <xsl:variable name="title" select="descendant::t:titleStmt/t:title"/>
                                <div xmlns="http://www.w3.org/1999/xhtml">
                                    <span class="sort-title">  
                                        <a href="/data/{$fileName}.html"><xsl:value-of select="string-join(descendant::t:titleStmt/t:title,': ')"/>
                                            <xsl:if test="descendant::t:titleStmt/t:title[@ref]">
                                                [<xsl:value-of select="descendant::t:titleStmt/t:title/@ref"/>]
                                            </xsl:if></a>
                                    </span>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="recSummary">
        <xsl:param name="nodes"/>
        
    </xsl:template>
</xsl:stylesheet>
