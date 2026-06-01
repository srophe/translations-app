<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:x="http://www.w3.org/1999/xhtml" xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://syriaca.org/ns" exclude-result-prefixes="xs t x saxon local" version="2.0">

    <!-- =================================================================== -->
    <!--  Custom styles                                                     -->
    <!--  Override the TEI Consortium styles                                -->
    <!-- =================================================================== -->
    
    <!-- Divs, sections etc -->
    <xsl:template match="t:ab">
        <div class="tei-ab-block">
            <xsl:apply-templates/>
        </div>
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('tei-ab',if(@type) then concat(' ab-type-',@type) else (), if(@rend) then concat(' ab-rend-',@rend) else ())"/>
            </xsl:attribute>
            <xsl:if test="@n"><xsl:value-of select="@n"/></xsl:if>
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
    
    <!-- Notes -->
    <!-- noteGrp -->
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
    <!-- Page breaks -->
    <!-- <pb type="vol" n="231"/><pb type="running" rend="brackets" n="231"/> -->
    <xsl:template match="t:pb">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('tei-pb',if(@type) then concat(' pb-type-',@type) else (), if(@rend) then concat(' pb-rend-',@rend) else ())"/>
            </xsl:attribute>
            <xsl:if test="@n"><xsl:value-of select="@n"/></xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>