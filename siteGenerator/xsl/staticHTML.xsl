<xsl:stylesheet  
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:t="http://www.tei-c.org/ns/1.0" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:x="http://www.w3.org/1999/xhtml" 
    xmlns:srophe="https://srophe.app" 
    xmlns:saxon="http://saxon.sf.net/" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:local="http://syriaca.org/ns" 
    exclude-result-prefixes="xs t x saxon local" version="3.0">

 <!-- ================================================================== 
      staticHTML.xsl
       
       Generate Static HTML pages for TEI display 
       Code can be used to convert from an old Srophe based application. Or to start an entierly new application.
       
       To convert an existing Srophe application:
       1. Include the path to the existing application under @applicationPath
       2. Include path to new app location, to copy @staticSitePath
       3. Set @convert parameter to 'true'
       
       
       To start a new application:
       1. Set @convert parameter to 'false'
       2. Run TEI through xslt. Make sure there are matching HTML templates in the ../components directory 
          for each collection that has been declared in your repo-config.xml 
       
       
        
       code by: 
        + Winona Salesky (wsalesky@gmail.com)
          
       funding provided by:
        + National Endowment for the Humanities (http://www.neh.gov). Any 
          views, findings, conclusions, or recommendations expressed in 
          this code do not necessarily reflect those of the National 
          Endowment for the Humanities.
       
       ================================================================== -->
 <!-- =================================================================== -->
 <!-- import component stylesheets for HTML page portions -->
 <!-- =================================================================== -->
    <xsl:import href="tei/html/html.xsl"/>
    <xsl:import href="custom.xsl"/>
<!--    <xsl:import href="tei2html.xsl"/>-->
<!--    <xsl:import href="helper-functions.xsl"/>-->
<!--    <xsl:import href="maps.xsl"/>-->
<!--    <xsl:import href="json.xsl"/>-->
<!--    <xsl:import href="relationships.xsl"/>-->
    
 <!-- =================================================================== -->
 <!-- set output so we get (mostly) indented HTML -->
 <!-- =================================================================== -->
    <xsl:output name="html" encoding="UTF-8" method="xhtml" indent="no" omit-xml-declaration="yes"/>    
    
    <!-- 
    Step 1: 
    create HTML page outline
        include header
        include nav for submodule
        transform HTML
        Add Footer
        
        Add dynamic (javascript calls to RDF or other related items)
        
        -->
 
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
    <xsl:param name="dataPath" select="'/Users/wsalesky/syriaca/translations/translations-data'"/>
    <!-- <xsl:param name="dataPath" select="'/Users/wsalesky/syriaca/syriaca/syriaca-data/data/'"/> -->
    
    <!-- Example: generate new index.html page for places collection -->
    <xsl:param name="convert" select="'true'"/>
    <xsl:param name="outputFile" select="''"/>
    <xsl:param name="outputCollection" select="''"/>
    
    <!-- Generate new TEI page, run over any TEI. 
    <xsl:param name="outputFile" select="''"/>
    <xsl:param name="outputCollection" select="''"/>
    -->
    
    <!-- Find repo-config to find collection style values and page stubs -->
    <xsl:variable name="configPath">
        <xsl:value-of select="'../components/repo-config.xml'"/>
        <!-- 
        <xsl:choose>
            <xsl:when test="$applicationPath != ''">
                <xsl:value-of select="concat($applicationPath, '/siteGenerator/components/repo-config.xml')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'../components/repo-config.xml'"/>
            </xsl:otherwise>
        </xsl:choose>
        -->
    </xsl:variable>
    
    <!-- Get configuration file.  -->
    <xsl:variable name="config">
        <xsl:choose>
            <xsl:when test="doc-available(xs:anyURI($configPath))">
                <xsl:sequence select="document(xs:anyURI($configPath))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No config file: <xsl:value-of select="$configPath"/></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
      
    <!-- Root of app for building dynamic links. Default is eXist app root -->
    <!-- Not needed? -->
    <xsl:variable name="nav-base" select="'/'"/>
    
    <!-- Base URI for identifiers in app data -->
    <xsl:variable name="base-uri">
        <xsl:choose>
            <xsl:when test="$config/descendant::*:base_uri">
                <xsl:value-of select="$config/descendant::*:base_uri"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No config file base uri</xsl:message>
                <xsl:value-of select="'http://syriaca.org'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Hard coded values-->
    <xsl:param name="normalization">NFKC</xsl:param>
    
    <!-- Variables for building HTML from TEI records -->
    <!-- Repository Title -->
    <xsl:variable name="repository-title">
        <xsl:choose>
            <xsl:when test="$config/child::*">
                <xsl:value-of select="$config/descendant::*:title[1]"/>
            </xsl:when>
            <xsl:otherwise>The Gaddel Application</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="collection-title">
        <xsl:value-of select="$repository-title"/>
    </xsl:variable>
    <!-- Resource title -->
    <xsl:variable name="resource-title">
        <xsl:choose>
            <xsl:when test="/descendant::t:text/t:body[descendant::*[@srophe:tags = '#syriaca-headword']]">
                <xsl:apply-templates select="/descendant::t:text/t:body[descendant::*[@srophe:tags = '#syriaca-headword']][@xml:lang = 'en']/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="/descendant-or-self::t:titleStmt/t:title[1]"/>                
            </xsl:otherwise>            
        </xsl:choose>
    </xsl:variable>
    
    <!-- Resource id -->
    <xsl:variable name="resource-path" select="substring-after(document-uri(.),':')"/>
        
    
    <!-- Figure out if document is HTML or TEI -->
    <xsl:template match="/">
        <xsl:variable name="documentURI" select="document-uri(.)"/>
        <!-- File type for conversion or creation -->
        <xsl:variable name="fileType">
            <xsl:choose>
                <xsl:when test="$convert = 'false' and $outputFile != ''">HTML</xsl:when>
                <xsl:when test="/html:div[@data-template-with]">HTML</xsl:when>
                <xsl:when test="/t:TEI">TEI</xsl:when>
                <xsl:when test="/rdf:RDF">RDF</xsl:when>
                <xsl:otherwise>OTHER: <xsl:value-of select="name(root(.))"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Filename for new HTML file -->
        <xsl:variable name="filename">
            <xsl:choose>
                <!-- For generating a new file using the templates defined in the components directory.  -->
                <xsl:when test="$convert = 'false' and $outputFile != ''">
                    <xsl:variable name="collectionPath">
                        <xsl:if test="$outputCollection != ''">
                            <xsl:value-of select="$config/descendant::*:collection[@name = $outputCollection]/@app-root"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$outputCollection != ''">
                            <xsl:value-of select="concat($config/descendant::*:collection[@name = $outputCollection]/@app-root,'',$outputFile)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('/',$outputFile)"/>        
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(tokenize($documentURI,'/')[last()],'.xml','.html')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="path">
            <xsl:choose>
                <xsl:when test="$convert = 'false' and $outputFile != '' and $fileType = 'HTML'">
                    <path><xsl:value-of select="concat($staticSitePath,'/',$filename)"/></path>
                </xsl:when>
                <xsl:when test="$fileType = 'HTML'">
                    <!--<path idno=""><xsl:value-of select="concat($staticSitePath,replace($resource-path,$applicationPath,''))"/></path>-->
                    <path><xsl:value-of select="concat($staticSitePath,replace($resource-path,$applicationPath,''))"/></path>
                </xsl:when>
                <xsl:when test="$fileType = 'TEI'">
                    <xsl:variable name="idno">
                        <xsl:choose>
                            <xsl:when test="descendant-or-self::t:publicationStmt/t:idno[@type='URI']"><xsl:value-of select="replace(/descendant-or-self::t:publicationStmt/t:idno[@type='URI'],'/tei','')"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="replace(tokenize($documentURI,'/')[last()],'.xml','')"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <path idno="/Users/wsalesky/syriaca/translations/translations-app/data/test.xml"><xsl:value-of select="concat('/Users/wsalesky/syriaca/translations/translations-app/data/',$filename)"/></path>
                   <!--  <path idno="/Users/wsalesky/syriaca/translations/translations-app/data/test.xml">/Users/wsalesky/syriaca/translations/translations-app/data/test.html</path> -->
<!--                    <path idno="{$idno}"><xsl:value-of select="concat(replace($idno,$base-uri,concat($staticSitePath,'/')),'.html')"/></path>-->
                </xsl:when>
                <xsl:when test="$fileType = 'RDF'">
                    <!-- Output a page for each rdf:Description (with http://syriaca.org/taxonomy/) -->
                    <xsl:for-each select="//rdf:Description[starts-with(@rdf:about,'http://syriaca.org/taxonomy/')]">
                        <xsl:if test="replace(@rdf:about,'http://syriaca.org/taxonomy/','') != ''">
                            <xsl:variable name="idno" select="@rdf:about"/>
                            <xsl:choose>
                                <xsl:when test="$idno = 'http://syriaca.org/taxonomy/syriac-taxonomy'">
                                    <path idno="{$idno}"><xsl:value-of select="concat($staticSitePath,'/taxonomy/browse.html')"/></path>
                                </xsl:when>
                                <xsl:otherwise>
                                    <path idno="{$idno}"><xsl:value-of select="concat(replace($idno,$base-uri,concat($staticSitePath,'entry/')),'.html')"/></path>        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:for-each>                    
                </xsl:when>
                <xsl:otherwise><xsl:message>Unrecognizable file type <xsl:value-of select="$fileType"/> [<xsl:value-of select="$documentURI"/>]</xsl:message></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="nodes" select="//t:TEI | //rdf:RDF | *"/>
        <xsl:for-each-group select="$path/child::*" group-by=".">
            <xsl:message>Path: <xsl:value-of select="$path"/></xsl:message>
            <xsl:result-document href="{replace(.,'.xml','.html')}">
                <xsl:choose>
                    <xsl:when test="$fileType = 'HTML'">
                        <xsl:call-template name="htmlPage">
                            <xsl:with-param name="pageType" select="'HTML'"/>
                            <xsl:with-param name="nodes" select="$nodes"/>
                            <xsl:with-param name="idno" select="''"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$fileType = 'TEI'">
                        <xsl:call-template name="htmlPage">
                            <xsl:with-param name="pageType" select="'TEI'"/>
                            <xsl:with-param name="nodes" select="$nodes"/>
                            <xsl:with-param name="idno" select="@idno"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$fileType = 'RDF'">
                        <xsl:call-template name="htmlPage">
                            <xsl:with-param name="pageType" select="'RDF'"/>
                            <xsl:with-param name="nodes" select="$nodes"/>
                            <xsl:with-param name="idno" select="@idno"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>Unrecognizable file type <xsl:value-of select="$fileType"/></xsl:message>
                    </xsl:otherwise>    
                </xsl:choose>
            </xsl:result-document>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template name="htmlPage">
        <xsl:param name="pageType"/>
        <xsl:param name="nodes"/>
        <xsl:param name="idno"/>
        <xsl:variable name="root">
            <xsl:choose>
                <xsl:when test="$nodes/descendant::t:idno[@type='front'] or $nodes/descendant::t:idno[@type='back']">
                    <xsl:sequence select="$nodes/descendant-or-self::t:idno[@type='URI'][. = $idno]/parent::t:ab/parent::t:div[@type][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$nodes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Collection variables from repo-config -->
        <xsl:variable name="collectionURIPattern">
            <xsl:if test="$idno != ''">
                <xsl:for-each select="tokenize($idno,'/')">
                    <xsl:if test="position() != last()"><xsl:value-of select="concat(.,'/')"/></xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="collectionValues" select="$config/descendant::*:collection[@record-URI-pattern = $collectionURIPattern][1]"/>        
        <xsl:variable name="collectionTemplate">
            <xsl:choose>
                <xsl:when test="$idno != ''">
                    <xsl:message> TEI record with an idno: <xsl:value-of select="$idno"/></xsl:message>
                    <xsl:variable name="templatePath" select="'../components/page.html'"/>
<!--                    <xsl:variable name="templatePath" select="concat($staticSitePath,'/siteGenerator/components/page.html')"/>-->
                    <xsl:if test="doc-available(xs:anyURI($templatePath))">
                        <xsl:sequence select="document(xs:anyURI($templatePath))"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$convert = 'false' and $outputFile != ''">
<!--                    <xsl:message>Generate new HTML page</xsl:message>-->
                    <xsl:variable name="templatePath">
                        <xsl:choose>
                            <xsl:when test="$config/descendant::*:collection[@name = $outputCollection]/@template">
                                <xsl:value-of select="concat($config/descendant::*:collection[@name = $outputCollection]/@template,'.html')"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'page.html'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="fullTemplatePath"><xsl:value-of select="concat($staticSitePath,'/', replace($templatePath,'templates/','siteGenerator/components/'))"/></xsl:variable>
                    <xsl:if test="doc-available($fullTemplatePath)">
                        <xsl:sequence select="document($fullTemplatePath)"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$nodes/@data-template-with != ''">
<!--                    <xsl:message>Convert HTML from old format </xsl:message>-->
                    <xsl:variable name="templatePath" select="concat($staticSitePath,'/siteGenerator/components/page.html')"/>
                    <xsl:if test="doc-available(xs:anyURI($templatePath))">
                        <xsl:sequence select="document(xs:anyURI($templatePath))"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
<!--                    <xsl:message>Find generic page.html template</xsl:message>-->
                    <xsl:variable name="templatePath" select="'../components/page.html'"/>
                    <xsl:if test="doc-available(xs:anyURI($templatePath))">
                        <xsl:sequence select="document(xs:anyURI($templatePath))"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="collection" select="$collectionValues/@name"/>
        <!-- <xsl:apply-templates/> -->
        <html xmlns="http://www.w3.org/1999/xhtml">
            <!-- HTML Header, use templates as already estabilished, if no template exists, use generic 'page.html' -->
            <xsl:variable name="template">
                <xsl:choose>
                    <xsl:when test="$pageType = 'HTML'">
                        <xsl:choose>
                            <xsl:when test="$collectionTemplate/child::*">
                                <xsl:sequence select="$collectionTemplate"/> 
                            </xsl:when>
                            <xsl:otherwise><xsl:message>Error Can not find matching template for HTML page <xsl:value-of select="replace(concat($staticSitePath,'/siteGenerator/components/',string($collectionValues/@template),'.html'),'//','/')"/></xsl:message></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$pageType = 'TEI'">
                        <xsl:choose>
                            <xsl:when test="$collectionTemplate/child::*">
                                <xsl:sequence select="$collectionTemplate"/> 
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="templatePath" select="'../components/page.html'"/>
                                <xsl:message>Error Can not find matching template for TEI page <xsl:value-of select="replace(concat($staticSitePath,'/siteGenerator/components/',string($collectionValues/@template),'.html'),'//','/')"/></xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$pageType = 'RDF'">
                        <xsl:choose>
                            <xsl:when test="$collectionTemplate/child::*">
                                <xsl:sequence select="$collectionTemplate"/> 
                            </xsl:when>
                            <xsl:otherwise><xsl:message>Error Can not find matching template for TEI page <xsl:value-of select="replace(concat($staticSitePath,'/siteGenerator/components/',string($collectionValues/@template),'.html'),'//','/')"/></xsl:message></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$template/descendant::*:head">
                        <xsl:choose>
                            <xsl:when test="$template/descendant::*:head">
                                <xsl:choose>
                                    <xsl:when test="$pageType = 'TEI'">
                                            <!--<xsl:sequence select="$collectionTemplate"/>-->
                                            <head xmlns="http://www.w3.org/1999/xhtml">
                                                <!--<xsl:sequence select="$collectionTemplate"/>-->
                                                <xsl:for-each select="$collectionTemplate/descendant::*:head/child::*">
                                                    <xsl:choose>
                                                        <xsl:when test="local-name() = 'title'">
                                                            <title xmlns="http://www.w3.org/1999/xhtml">
                                                                <xsl:choose>
                                                                    <xsl:when test="$nodes/descendant::t:body[descendant::*[@srophe:tags = '#syriaca-headword']]">
                                                                        <xsl:value-of select="$nodes/descendant::t:body/descendant::*[@srophe:tags = '#syriaca-headword'][@xml:lang = 'en']"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                       <xsl:value-of select="$nodes/descendant-or-self::t:titleStmt/t:title[1]"/>                
                                                                    </xsl:otherwise>            
                                                                </xsl:choose> 
                                                            </title> 
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:copy-of select="."/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:for-each>
                                            </head> 
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="$template/descendant::*:head"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise><xsl:message>Error in template, check template for html:head </xsl:message></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise><xsl:message>No template found for html:head element</xsl:message></xsl:otherwise>
                </xsl:choose>
            <body id="body">
                <script src="/resources/js/navbar-search.js"></script>
                <div id="navbar-container"></div>
                <xsl:choose>
                    <xsl:when test="$pageType = 'HTML'">
                        <xsl:copy-of select="$nodes"/>
                    </xsl:when>
                    <xsl:when test="$pageType = 'RDF'">
                        <xsl:apply-templates select="$nodes/rdf:Description[@rdf:about = $idno]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="main-content-block">
                            <xsl:variable name="leftMenu">
                                <xsl:call-template name="toggleOptions">
                                    <xsl:with-param name="nodes" select="$nodes"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <div class="interior-content">
                                <div class="row">
                                    <xsl:if test="$leftMenu != ''">
                                        <div class="col-md-2">
                                            <xsl:call-template name="toggleOptions">
                                                <xsl:with-param name="nodes" select="$nodes"/>
                                            </xsl:call-template>
                                        </div>
                                    </xsl:if>
                                    <div>
                                        <xsl:choose>
                                            <xsl:when test="$leftMenu != ''">
                                                <xsl:attribute name="class">col-md-6</xsl:attribute>
                                            </xsl:when>
                                            <xsl:otherwise><xsl:attribute name="class">col-md-8</xsl:attribute></xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:apply-templates select="$nodes/descendant::t:teiHeader">
                                            <xsl:with-param name="collection" select="$collection"/>
                                            <xsl:with-param name="idno" select="$idno"/>
                                        </xsl:apply-templates>
                                        <br/>
                                        <xsl:apply-templates select="$nodes/descendant::t:text">
                                            <xsl:with-param name="collection" select="$collection"/>
                                            <xsl:with-param name="idno" select="$idno"/>
                                        </xsl:apply-templates>
                                    </div>
                                    <div class="col-md-4">
                                        <!--
                                        <xsl:call-template name="otherDataFormats">
                                            <xsl:with-param name="node" select="t:TEI"/>
                                            <xsl:with-param name="idno" select="$idno"/>
                                            <xsl:with-param name="formats" select="'email,ghIssue,ghCode,tei,print'"/>
                                        </xsl:call-template>
                                        <br/>
                                        -->
                                        <xsl:call-template name="moreInfo">
                                            <xsl:with-param name="nodes" select="$nodes"/>
                                        </xsl:call-template>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="doc-available(xs:anyURI(concat($staticSitePath,'/siteGenerator/components/footer.html')))">
                    <xsl:copy-of select="document(xs:anyURI(concat($staticSitePath,'/siteGenerator/components/footer.html')))"/>
                </xsl:if>
                <script type="text/javascript">
                    $('html').click(function() {
                    $('#footnoteDisplay').hide();
                    $('#footnoteDisplay div.content').empty();
                    })
                    
                    $('.footnote-ref a').click(function(e) {
                    e.stopPropagation();
                    e.preventDefault();
                    var link = $(this);
                    var href = $(this).attr('href');
                    var content = $(href).html()
                    $('#footnoteDisplay').css('display','block');
                    $('#footnoteDisplay').css({'top':e.pageY-50,'left':e.pageX+25, 'position':'absolute'});
                    $('#footnoteDisplay div.content').html( content );    
                    });
                </script>
            </body>
            <xsl:if test="$template/child::*[1]/html:script">
                <xsl:copy-of select="$template/child::*[1]/html:script"/>
            </xsl:if>  
        </html>
    </xsl:template>
    
    <xsl:template name="otherDataFormats">
        <xsl:param name="node"/>
        <xsl:param name="formats"/>
        <xsl:param name="idno"/>
        <xsl:variable name="shelfMark" select="$node/descendant::t:fileDesc/t:sourceDesc/t:msDesc/t:msIdentifier/t:altIdentifier/t:idno[@type='BL-Shelfmark']"/>
        <xsl:variable name="url" select="$node/descendant::t:fileDesc/t:sourceDesc/t:msDesc/t:msIdentifier/t:idno[@type='URI']"/>
        <xsl:variable name="teiRec" select="document-uri(root($node))"/>
        <xsl:variable name="dataPath" select="substring-before(concat($staticSitePath,'/',replace($resource-path,$dataPath,'')),'.xml')"></xsl:variable>
        <xsl:if test="$formats != ''">
            <div class="container otherFormats" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:for-each select="tokenize($formats,',')">
                    <xsl:choose>
                        <!--                         
                    else if($f = 'rdf') then
                        (<a href="{concat(replace($id,$config:base-uri,$config:nav-base),'.rdf')}" data-toggle="tooltip" title="Click to view the RDF-XML data for this record." >
                            <img src="{$config:nav-base}/resources/images/sw-rdf-blue.png" height="26px"/>
                        </a>, '&#160;')
                        -->
                        <!--
                        <xsl:when test=". = 'geojson'">
                            <a href="{concat($dataPath,'.geojson')}" class="btn btn-default btn-xs" id="geojsonBtn" data-toggle="tooltip" title="Click to view the GeoJSON data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> GeoJSON
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'json'">
                            <a href="{concat($dataPath,'.json')}" class="btn btn-default btn-xs" id="jsonBtn" data-toggle="tooltip" title="Click to view the GeoJSON data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> JSON-LD
                            </a><xsl:text>&#160;</xsl:text> 
                        </xsl:when>
                        <xsl:when test=". = 'kml'">
                            <xsl:if test="$node/descendant::t:location/t:geo">
                                <a href="{concat($dataPath,'.kml')}" class="btn btn-default btn-xs" id="kmmlBtn" data-toggle="tooltip" title="Click to view the KML data for this record." >
                                    <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> KML
                                </a><xsl:text>&#160;</xsl:text>
                            </xsl:if>
                        </xsl:when>
                        -->
                        <xsl:when test=". = 'uri'">
                            <a class="btn btn-default btn-xs" id="copyBtn" 
                                data-toggle="tooltip" 
                                title="Copy URI to clipboard: {$idno}"
                                data-clipboard-action="copy" data-clipboard-text="{string($idno)}">
                                <span class="glyphicon glyphicon-copy" aria-hidden="true"></span> URI</a>&#160;
                            <script><![CDATA[new Clipboard('#copyBtn');]]></script>
                        </xsl:when>
                        <xsl:when test=". = 'print'">
                            <a href="javascript:window.print();" type="button" class="btn btn-default btn-xs" id="printBtn" data-toggle="tooltip" title="Click to send this page to the printer." >
                                <span class="glyphicon glyphicon-print" aria-hidden="true"></span>&#160;
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <!--
                        <xsl:when test=". = 'rdf'">
                            <a href="{concat($dataPath,'.rdf')}" class="btn btn-default btn-xs" id="rdfBtn" data-toggle="tooltip" title="Click to view the RDF-XML data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> RDF/XML
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        -->
                        <!--
                        <xsl:when test=". = 'tei'">
                            <a href="{concat(tokenize($idno,'/')[last()],'.xml')}" class="btn btn-default btn-xs" id="teiBtn" data-toggle="tooltip" title="Click to view the TEI XML data for this record." >
                                <img src="/resources/images/TEI_Logo.png" height="18px"/>
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        -->
                        <xsl:when test=". = 'ghCode'">
                            <a href="{concat('https://github.com/srophe/britishLibrary-data/blob/main/data/tei/',tokenize($idno,'/')[last()],'.xml')}" target="_blank" class="btn btn-default btn-xs" id="openBtn" data-toggle="tooltip" title="Click to view the TEI XML data for this record.">
                                <img src="/resources/images/github-mark.png" height="18px"/>
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'ghIssue'">
                            <a href="{concat('https://github.com/srophe/britishLibrary-data/issues/new?assignees=&amp;labels=community-submitted&amp;title=',$shelfMark,':',$url)}" target="_blank" id="issueBtn" data-toggle="tooltip" class="btn btn-default btn-xs" title="Click to file a data issue on GitHub (requires login).">
                                <span class="glyphicon glyphicon-record" aria-hidden="true"></span> Open
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <xsl:when test=". = 'email'">
                            <a href="mailto:bl.syriac.uk@gmail.com?subject=Shelf mark:{$shelfMark} Record URI: {$url}" type="button" class="btn btn-default btn-xs" data-toggle="tooltip" title="Click to report a correction via e-mail." >
                                <span class="glyphicon glyphicon-envelope" aria-hidden="true"></span> Corrections
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        <!--
                        <xsl:when test=". = 'text'">
                            <a href="{concat($dataPath,'.txt')}" class="btn btn-default btn-xs" id="txtBtn" data-toggle="tooltip" title="Click to view the plain text data for this record." >
                                <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span> Text
                            </a><xsl:text>&#160;</xsl:text>
                        </xsl:when>
                        -->
                        <xsl:when test=". = 'citations'">
                            <xsl:variable name="zoteroGrp" select="$config/descendant::*:zotero/@group"/>
                            <xsl:if test="$zoteroGrp != ''">
                                (<a href="{concat('https://api.zotero.org/groups/',$zoteroGrp,'/items/',tokenize($idno,'/')[last()])}" class="btn btn-default btn-xs" id="citationsBtn" data-toggle="tooltip" title="Click for additional Citation Styles." >
                                    <span class="glyphicon glyphicon-th-list" aria-hidden="true"></span> Cite
                                </a><xsl:text>&#160;</xsl:text>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="toc">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="self::text()">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="t:div">
                <xsl:call-template name="toc">
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="t:div1">
                <xsl:call-template name="toc">
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="t:div2">
                <span class="toc div2">
                    <xsl:call-template name="toc">
                        <xsl:with-param name="node" select="$node"/>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:when test="t:div3">
                <span class="toc div3">
                    <xsl:call-template name="toc">
                        <xsl:with-param name="node" select="$node"/>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:when test="t:div4">
                <span class="toc div4">
                    <xsl:call-template name="toc">
                        <xsl:with-param name="node" select="$node"/>
                    </xsl:call-template>
                </span>
            </xsl:when>
            <xsl:when test="t:head">
                <xsl:variable name="id">
                    <xsl:choose>
                        <xsl:when test="$node/@xml:id"><xsl:value-of select="$node/@xml:id"/></xsl:when>
                        <xsl:when test="$node/parent::*[1]/@n">
                            <xsl:value-of select="concat('Head-id.',string-join($node/ancestor::*[@n]/@n,'.'))"/>
                        </xsl:when>
                        <xsl:otherwise>'on-parent'</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <a href="#{$id}" class="toc-item"><xsl:value-of select="string-join($node/descendant-or-self::text(),' ')"/></a><xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template> 
    <xsl:template name="toggleOptions">
        <xsl:param name="nodes"/>
        <xsl:variable name="toc">
            <xsl:call-template name="toc">
                <xsl:with-param name="node" select="$nodes/descendant::t:body/child::*"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- Hide toggle functions 
        <xsl:if test="$nodes/descendant::t:body/descendant::*[@n][not(@type='section') and not(@type='part')]">
            <div class="panel panel-default">
                <div class="panel-heading"><a href="#" data-toggle="collapse" data-target="#toggleText">Show  </a>
                    <span class="glyphicon glyphicon-question-sign text-info moreInfo" aria-hidden="true" data-toggle="tooltip" 
                        title="Toggle the text display to show line numbers, section numbers and other structural divisions"></span>
                </div>
                <div class="panel-body collapse in" id="toggleText">
                    <xsl:variable name="types" select="distinct-values($nodes/descendant::t:body/descendant::t:div[@n]/@type)"/>
                    <xsl:for-each select="$types">
                        <xsl:sort select="."/>
                        <xsl:choose>
                            <xsl:when test=". = ('part','text','rubric','heading','title')"></xsl:when>
                            <xsl:otherwise>
                                <div class="toggle-buttons">
                                    <span class="toggle-label"><xsl:value-of select="."/> : </span>
                                    <input class="toggleDisplay" type="checkbox" id="toggle{.}" data-element="{concat('tei-',.)}" checked="if. = 'section') then 'checked' else()"/>
                                    <label for="toggle{.}"><xsl:value-of select="."/></label>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:ab[not(@type) and not(@subtype)][@n]">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> ab : </span>
                            <input class="toggleDisplay" type="checkbox" id="toggleab" data-element="tei-ab"/>
                            <label for="toggleab">ab</label>
                        </div>
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:ab[@type][@n]">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> ab : </span>
                            <input class="toggleDisplay" type="checkbox" id="toggleab" data-element="tei-ab"/>
                            <label for="toggleab">ab</label>
                        </div>
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:l">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> line : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglel" data-element="tei-l" checked="checked"/>
                            <label for="togglel">line</label>
                        </div>
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:lb">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> line break : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglelb" data-element="tei-lb"/>
                            <label for="togglelb">line break</label>
                        </div>
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:lg">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> line group : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglelg" data-element="tei-lg"/>
                            <label for="togglelg">line group</label>
                        </div>    
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:pb">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> page break : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglepb" data-element="tei-pb"/>
                            <label for="togglepb">page break</label>
                        </div>    
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:cb">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> column break : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglecb" data-element="tei-cb"/>
                            <label for="togglecb">column break</label>
                        </div>   
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:milestone[not(@type) and not(@subtype) and not(@unit='SyrChapter')]">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> milestone : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglemilestone" data-element="tei-milestone"/>
                            <label for="togglemilestone">milestone</label>
                        </div>  
                    </xsl:if>
                    <xsl:if test="$nodes/descendant::t:body/descendant::t:note[@place = ('foot','footer','footnote')]">
                        <div class="toggle-buttons">
                            <span class="toggle-label"> footnote : </span>
                            <input class="toggleDisplay" type="checkbox" id="togglemilestone" data-element="tei-footnote" checked="checked"/>
                            <label for="togglemilestone">footnote</label>
                        </div>   
                    </xsl:if>
                </div>
            </div>
        </xsl:if>-->
        <xsl:if test="$toc/child::*[. = '']">
            <div class="panel panel-default">
                <div class="panel-heading"><a href="#" data-toggle="collapse" data-target="#showToc">Table of Contents  </a>
                </div>
                <div class="panel-body collapse in" id="showToc">
                    <xsl:copy-of select="$toc"/>
                </div>
            </div> 
        </xsl:if> 
    </xsl:template>
    <xsl:template name="moreInfo">
        <xsl:param name="nodes"/>
        <div class="panel panel-default">
            <div class="panel-heading"><a href="#" data-toggle="collapse" data-target="#aboutDigitalText">About This Digital Text </a></div>
            <div class="panel-body collapse in" id="aboutDigitalText">
                <xsl:if test="$nodes/descendant::t:publicationStmt/t:idno[@type='URI']">
                    <div>
                        <h5>Corpus Text ID:</h5>
                        <span><xsl:value-of select="$nodes/descendant::t:publicationStmt/t:idno[@type='URI']"/></span>
                    </div>
                </xsl:if>
                <xsl:if test="$nodes/descendant::t:fileDesc/t:titleStmt/t:title[1]/@ref">
                    <div>
                        <h5>NHSL Work ID(s):</h5>
                        <xsl:for-each select="$nodes/descendant::t:fileDesc/t:titleStmt/t:title[@ref]">
                            <span><a href="{string(@ref)}"><xsl:value-of select="@ref"/></a><br/></span>
                        </xsl:for-each>
                    </div>
                </xsl:if>
                <div>
                    <h5>Source: </h5>
                    <xsl:apply-templates select="$nodes/descendant::t:sourceDesc"/>
                    <xsl:if test="$nodes/descendant::t:sourceDesc/descendant::t:idno[starts-with(., 'http://syriaca.org/bibl')]">
                        <span class="footnote-links">
                            <span class="footnote-icon"> 
                                <a href="{$nodes/descendant::t:sourceDesc/descendant::t:idno[starts-with(., 'http://syriaca.org/bibl')][1]/text()}" title="Link to Syriaca.org Bibliographic Record" data-toggle="tooltip" data-placement="top" class="bibl-links">
                                    <img src="/resources/images/icons-syriaca-sm.png" alt="Link to Syriaca.org Bibliographic Record" height="18px"/>
                                </a>
                            </span>
                        </span>
                    </xsl:if>
                </div>
                <div style="margin-top:1em;">
                    <span class="h5-inline">Type of Text: 
                    </span>
                    <span>
                        <xsl:variable name="string" select="$nodes/descendant::t:text[1]/@type"/>
                        <xsl:variable name="title" select="concat(substring($string[1],1,1),replace(substring($string[1],2),'(\p{Lu})',concat(' ', '$1')))"/>
                        <xsl:variable name="title2" select="concat(upper-case(substring($title,1,1)),substring($title,2))"/>
                        <xsl:value-of select="$title2"/>
                    </span>
                    &#160;<a href="/documentation/wiki.html?wiki-page=/Types-of-Text-in-the-Digital-Syriac-Corpus&amp;wiki-uri=https://github.com/srophe/syriac-corpus/wiki"><span class="glyphicon glyphicon-question-sign text-info moreInfo"></span></a>
                </div>
                <div style="margin-top:1em;">
                    <span class="h5-inline">Status: 
                    </span>
                    <span>
                        <xsl:variable name="string" select="$nodes/descendant::t:revisionDesc[1]/@status"/>
                        <xsl:variable name="title" select="concat(substring($string[1],1,1),replace(substring($string[1],2),'(\p{Lu})',concat(' ', '$1')))"/>
                        <xsl:variable name="title2" select="concat(upper-case(substring($title,1,1)),substring($title,2))"/>
                        <xsl:value-of select="$title2"/>
                    </span>
                    &#160;<a href="/documentation/wiki.html?wiki-page=/Status-of-Texts-in-the-Digital-Syriac-Corpus&amp;wiki-uri=https://github.com/srophe/syriac-corpus/wiki"><span class="glyphicon glyphicon-question-sign text-info moreInfo"></span></a>
                </div>
                <div style="margin-top:1em;">
                    <span class="h5-inline">Publication Date: </span>
                    <xsl:value-of select="format-date(xs:date($nodes/descendant::t:revisionDesc/t:change[1]/@when), '[MNn] [D], [Y]')"/>
                </div>
                <div>
                    <h5>Preparation of Electronic Edition:</h5>
                    TEI XML encoding by James E. Walters. <br/>
                    Syriac text transcribed by <xsl:value-of select="$nodes/descendant::t:titleStmt/descendant::t:respStmt[t:resp[. = 'Syriac text transcribed by']]/t:name/text()"/>.
                </div>
                <div>
                    <h5>Open Access and Copyright:</h5>
                    <div class="small">
                        <xsl:apply-templates select="$nodes/descendant::t:teiHeader/t:fileDesc/t:publicationStmt/t:availability/t:ab[1]/t:note[1]/text()"/>
                        <div id="showMoreAccess" class="collapse">
                            <xsl:apply-templates select="$nodes/descendant::t:teiHeader/t:fileDesc/t:publicationStmt/t:availability/t:ab[2]/t:note[1]/text()"/>
                            <xsl:if test="$nodes/descendant::t:teiHeader/t:fileDesc/t:publicationStmt/t:availability/t:licence[contains(@target, 'http://creativecommons.org/licenses/')]">
                                <p>
                                    <a rel="license" href="{$nodes/descendant::t:teiHeader/t:fileDesc/t:publicationStmt/t:availability/t:licence/@target}">
                                        <img alt="Creative Commons License" style="border-width:0;display:inline;" src="/resources/images/cc.png" height="18px"/>
                                    </a>
                                </p>
                            </xsl:if>                  
                        </div>
                        <a href="#" class="togglelink" data-toggle="collapse" data-target="#showMoreAccess" data-text-swap="Hide details">See details...</a>
                    </div>
                </div>
            </div>
        </div>  
        <!-- NOTE: More toggle does not work -->
        <xsl:apply-templates select="$nodes/descendant::t:teiHeader"/>
        <!-- RDF functions-->
        <xsl:if test="$nodes/descendant::*/@ref[contains(.,'http://syriaca.org/') and not(contains(.,'http://syriaca.org/persons.xml'))] or $nodes/descendant::t:idno[@type='URI']">
            <div class="panel panel-default" style="margin-top:1em;" xmlns="http://www.w3.org/1999/xhtml">
                <div class="panel-heading">
                    <a href="#" data-toggle="collapse" data-target="#showLinkedData">Linked Data  </a>
                    <span class="glyphicon glyphicon-question-sign text-info moreInfo" aria-hidden="true" data-toggle="tooltip" title="This sidebar provides links via Syriaca.org to additional resources beyond this record. We welcome your additions, please use the e-mail button on the right to contact Syriaca.org about submitting additional links."></span>
                    <button class="btn btn-default btn-xs pull-right" data-toggle="modal" data-target="#submitLinkedData" style="margin-right:1em;"><span class="glyphicon glyphicon-envelope" aria-hidden="true"></span></button>
                </div>
                <div class="panel-body collapse in" id="showLinkedData">
                    <xsl:variable name="otherResources" select="distinct-values($nodes/descendant::*/@ref[contains(.,'http://syriaca.org/') and not(contains(.,'http://syriaca.org/person.xml'))] | $nodes/descendant::t:idno[@type='URI'])"/>
                    <xsl:variable name="count" select="count($otherResources)"/>
                    <div class="other-resources" xmlns="http://www.w3.org/1999/xhtml">
                        <div class="collapse in" id="getRDF">
                            <form class="form-inline hidden" action="https://sparql.vanderbilt.edu/sparql" method="get" id="lod1">
                                <input type="hidden" name="format" id="format" value="json"/>
                                <textarea id="query" class="span9" rows="15" cols="150" name="query" type="hidden">
                                    <xsl:text disable-output-escaping="yes">
                                                                                prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt;
                                                                                prefix lawd: &lt;http://lawd.info/ontology/&gt;
                                                                                prefix skos: &lt;http://www.w3.org/2004/02/skos/core#&gt;
                                                                                prefix dcterms: &lt;http://purl.org/dc/terms/&gt;
                                                                                SELECT ?uri (SAMPLE(?l) AS ?label) (SAMPLE(?uriSubject) AS ?subjects) (SAMPLE(?uriCitations) AS ?citations)
                                                                                {
                                                                                ?uri rdfs:label ?l
                                                                                FILTER (?uri IN ( </xsl:text><xsl:for-each select="$otherResources"><xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="."/><xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:if test="position() != last()">, </xsl:if></xsl:for-each><xsl:text disable-output-escaping="yes">)).
                                                                                FILTER ( langMatches(lang(?l), 'en')).
                                                                                OPTIONAL{{SELECT ?uri ( count(?s) as ?uriSubject ) { ?s dcterms:relation ?uri } GROUP BY ?uri }  }
                                                                                OPTIONAL{{SELECT ?uri ( count(?o) as ?uriCitations ) { ?uri lawd:hasCitation ?o OPTIONAL{?uri skos:closeMatch ?o.}} GROUP BY ?uri }}           
                                                                                }
                                                                                GROUP BY ?uri 
                                                                            </xsl:text>
                                </textarea>
                            </form>
                            <div id="showRDF"></div>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:if>
        
    </xsl:template>
    <!-- Not practical and overrides all the TEI styles
    <xsl:template match="*">
        <div class="tei-{local-name(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    -->
</xsl:stylesheet>