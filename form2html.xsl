<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes"  />
    <xsl:strip-space elements="*" />

    <xsl:variable name="defaultCSSFile" select="'form.css'" />

    <!-- named templates -->
    <xsl:template name="debugNodeNames">
        <xsl:for-each select=".">
            <xsl:value-of select="local-name()" />
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="optAttr">
        <xsl:param name="attr" />
        <xsl:if test="@*[local-name() = $attr]">
            <xsl:attribute name="{$attr}"><xsl:value-of select="@*[local-name() = $attr]" /></xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template name="putClass">
        <xsl:param name="extraClasses" select="''" />
        <xsl:if test="@class or $extraClasses!=''">
            <xsl:attribute name="class">
                <xsl:value-of select="@class" />
                <xsl:value-of select="$extraClasses" />
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template name="baseFields">
        <xsl:param name="extraClasses" select="''" />
        <xsl:call-template name="optAttr"><xsl:with-param name="attr">id</xsl:with-param></xsl:call-template>
        <xsl:call-template name="putClass"><xsl:with-param name="extraClasses"><xsl:value-of select="$extraClasses" /></xsl:with-param></xsl:call-template>
    </xsl:template>

    <xsl:template name="commonFields">
        <xsl:param name="extraClasses" select="''" />
        <xsl:call-template name="baseFields">
            <xsl:with-param name="extraClasses"><xsl:value-of select="$extraClasses" /></xsl:with-param>
        </xsl:call-template>
        <xsl:if test="not(@id) and @name">
            <xsl:attribute name="id"><xsl:value-of select="@name" /></xsl:attribute>
        </xsl:if>
        <xsl:call-template name="optAttr">
            <xsl:with-param name="attr">name</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="copy">
        <xsl:copy-of select="node()|text()" />
    </xsl:template>

    <xsl:template name="stylesheet">
        <xsl:param name="href" />
        <link>
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="$href" />
            </xsl:attribute>
        </link>
    </xsl:template>

    <!-- root template -->
    <xsl:template match="/">
        <html>
            <head>
                <!-- title stuff -->
                <xsl:choose>
                    <xsl:when test="//head/title">
                        <title><xsl:value-of select="//head/title" /></title>
                    </xsl:when>
                    <xsl:when test="/@title">
                        <title><xsl:value-of select="/@title" /></title>
                    </xsl:when>
                    <xsl:otherwise>
                        <title>Untitled form</title>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- stylesheet stuff -->
                <xsl:choose>
                    <xsl:when test="/*[@stylesheet='none']">
                    </xsl:when>
                    <xsl:when test="/*[@stylesheet]">
                        <xsl:call-template name="stylesheet">
                            <xsl:with-param name="href">
                                <xsl:value-of select="/*/@stylesheet" />
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="stylesheet">
                            <xsl:with-param name="href">
                                <xsl:value-of select="$defaultCSSFile" />
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- copy head element (does nothing if absent),
                    exclude title element (see above) -->
                <xsl:copy-of select="//head/*[not(self::title)]" />
            </head>
            <body>
                <xsl:if test="/*/@title">
                    <h1>
                        <xsl:attribute name="id">form-title</xsl:attribute>
                        <xsl:value-of select="/*/@title" />
                    </h1>
                </xsl:if>

                <form>
                    <xsl:for-each select="/*">
                        <xsl:call-template name="baseFields" />
                        <xsl:call-template name="optAttr">
                            <xsl:with-param name="attr">action</xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="optAttr">
                            <xsl:with-param name="attr">method</xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="optAttr">
                            <xsl:with-param name="attr">enctype</xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="/*/*[local-name()!='head']">
                        <xsl:apply-templates select="." />
                    </xsl:for-each>
                </form>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="foot">
        <xsl:comment>foot</xsl:comment>
        <xsl:call-template name="copy" />
        <xsl:comment>/foot</xsl:comment>
    </xsl:template>

    <xsl:template match="label">
        <label>
            <xsl:call-template name="baseFields">
                <xsl:with-param name="extraClasses">
                    <xsl:choose>
                        <xsl:when test="@position[text()='after']"> after</xsl:when>
                        <xsl:otherwise> before</xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="../@id">
                    <xsl:attribute name="for">
                        <xsl:value-of select="../@id" />
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="../@name">
                    <xsl:attribute name="for">
                        <xsl:value-of select="../@name" />
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>

            <xsl:call-template name="copy" />
        </label>
    </xsl:template>

    <xsl:template match="actions">
        <xsl:variable name="nodesWrapper">
            <form>
                <submit />
                <reset />
            </form>
        </xsl:variable>
        <xsl:apply-templates select="$nodesWrapper" />
    </xsl:template>

    <xsl:template match="raw">
        <xsl:call-template name="copy" />
    </xsl:template>

    <xsl:template match="text|email|password|submit|reset|button">
        <xsl:apply-templates select="label[@position='before' or not(@position)]" />

        <input>
            <xsl:attribute name="type"><xsl:value-of select="local-name()" /></xsl:attribute>
            <xsl:call-template name="commonFields" />
        </input>

        <xsl:apply-templates select="label[@position='after']" />
    </xsl:template>

    <xsl:template match="textarea">
        <xsl:apply-templates select="label[@position='before' or not(@position)]" />

        <textarea>
            <xsl:attribute name="type"><xsl:value-of select="local-name()" /></xsl:attribute>
            <xsl:call-template name="commonFields" />
        </textarea>

        <xsl:apply-templates select="label[@position='after']" />
    </xsl:template>
</xsl:stylesheet>