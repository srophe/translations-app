<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:x="http://www.w3.org/1999/xhtml" xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://syriaca.org/ns" exclude-result-prefixes="xs t x saxon local" version="2.0">

    <!-- =================================================================== -->
    <!--  Custom styles                                                     -->
    <!--  Override the TEI Consortium styles                                -->
    <!-- =================================================================== -->
    
    <!-- Divs, sections etc -->
    <xsl:template match="t:ab">
        <div class="row tei-p tei-ab">
            <div class="col-md-1"><xsl:if test="@xml:id"><xsl:attribute name="id"><xsl:value-of select="concat('ab',@xml:id)"/></xsl:attribute></xsl:if>
                <span class="ab-number inline"><xsl:if test="@n"><xsl:value-of select="@n"/></xsl:if></span>
            </div>
            <div class="col-md-11">
                <div class="tei-ab">
                    <xsl:apply-templates/>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="t:div">
        <xsl:choose>
            <xsl:when test="@n">
                <div class="row">
                    <div class="col-md-1"><xsl:if test="@xml:id"><xsl:attribute name="id"><xsl:value-of select="concat('ab',@xml:id)"/></xsl:attribute></xsl:if>
                        <span class="ab-number inline"><xsl:if test="@n"><xsl:value-of select="@n"/></xsl:if></span>
                    </div>
                    <div class="col-md-11">
                        <div class="tei-div {if(@type) then @type else()}">
                            <xsl:apply-templates/>
                        </div>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="tei-div {if(@type) then @type else()}">
                    <xsl:if test="@xml:id"><xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute></xsl:if>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Page breaks -->
    <!-- <pb type="vol" n="231"/><pb type="running" rend="brackets" n="231"/> -->
    <xsl:template match="t:pb">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('tei-pb',if(@type) then concat(' pb-type-',@type) else (), if(@rend) then concat(' pb-rend-',@rend) else ())"/>
            </xsl:attribute>
            <xsl:if test="@xml:id"><xsl:attribute name="id"><xsl:value-of select="concat('pb',@xml:id)"/></xsl:attribute></xsl:if>
            <xsl:if test="@n"><xsl:value-of select="@n"/></xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Entities -->
    <xsl:template match="t:placeName | t:persName">
        <span class="tei_{local-name()}">
            <xsl:choose>
                <xsl:when test="@ref">
                    <a href="{@ref}"><xsl:apply-templates/></a>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <xsl:template match="t:ptr">
        <xsl:choose>
            <xsl:when test="@type='noteAnchor'">
                <a id="{@xml:id}" href="{@target}" class="link_ptr noteAnchor"><xsl:value-of select="@n"/></a>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates select="self::*"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Notes -->
    <!-- Notes as popups 
    <xsl:template match="t:noteGrp">
        <xsl:for-each select="t:note">
            <div class="footnoteDisplay" id="{@xml:id}">
                <xsl:apply-templates select="."/>
            </div>
        </xsl:for-each>
    </xsl:template>
    -->
    <!-- Notes at bottom of page -->
    <xsl:template match="t:noteGrp">
        <h3>Notes</h3>
        <xsl:choose>
            <xsl:when test="t:note/@n">
                <ol class="noteGrp">
                    <xsl:for-each select="t:note">
                        <li><xsl:apply-templates select="."/></li>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <ul class="noteGrp">
                    <xsl:for-each select="t:note">
                        <li><xsl:apply-templates select="."/></li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>