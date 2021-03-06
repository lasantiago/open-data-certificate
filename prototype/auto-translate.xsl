<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="#local"
	exclude-result-prefixes="xs local">

<xsl:output method="xml" indent="yes" />

<xsl:variable name="translationFile" as="xs:string" select="'jurisdictions/temp/certificate.RO.ro.txt'" />
<xsl:variable name="translationDoc" as="document-node()">
	<xsl:document>
		<xsl:analyze-string select="unparsed-text($translationFile)" regex="^.+$" flags="m">
			<xsl:matching-substring>
				<xsl:variable name="key" select="substring-before(., ':')" />
				<t key="{$key}">
					<xsl:value-of select="normalize-space(substring-after(., ':'))" />
				</t>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:document>
</xsl:variable> 

<xsl:key name="translation" match="t" use="@key" />
	
<xsl:template match="/">
	<xsl:apply-templates select="*">
		<xsl:with-param name="path" select="''" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="*">
	<xsl:param name="path" required="yes" />
	<xsl:variable name="path" select="concat($path, '/', position())" />
	<xsl:variable name="translation" select="key('translation', $path, $translationDoc)" />
	<xsl:copy>
		<xsl:apply-templates select="@*">
			<xsl:with-param name="path" select="$path" />
		</xsl:apply-templates>
		<xsl:choose>
			<xsl:when test="$translation">
				<xsl:sequence select="local:markup($translation)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*">
					<xsl:with-param name="path" select="$path" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<xsl:template match="@*">
	<xsl:param name="path" required="yes" />
	<xsl:variable name="translation" select="key('translation', concat($path, '/@', local-name()), $translationDoc)" />
	<xsl:choose>
		<xsl:when test="exists($translation)">
			<xsl:attribute name="{local-name()}" select="$translation" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="." />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:function name="local:markup">
	<xsl:param name="string" />
	<xsl:analyze-string select="$string" regex="&lt;\s*([^&gt;]+)\s*&gt;\s*([^&lt;]+)\s*&lt;\s*/\s*([^&gt;]+)\s*&gt;">
		<xsl:matching-substring>
			<xsl:variable name="element" as="xs:string" select="if (contains(regex-group(1), ' ')) then substring-before(regex-group(1), ' ') else regex-group(1)" />
			<xsl:element name="{$element}">
				<xsl:if test="contains(regex-group(1), ' ')">
					<xsl:analyze-string select="substring-after(regex-group(1), ' ')" regex="([^ =]+)=&quot;([^&quot;]+)&quot;">
						<xsl:matching-substring>
							<xsl:attribute name="{regex-group(1)}" select="regex-group(2)" />
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:if>
				<xsl:value-of select="regex-group(2)" />
			</xsl:element>
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:value-of select="." />
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:function>

</xsl:stylesheet>