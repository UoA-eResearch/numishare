<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:void="http://rdfs.org/ns/void#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:owl="http://www.w3.org/2002/07/owl#" exclude-result-prefixes="xs" version="2.0">
	<xsl:param name="mode"/>

	<xsl:template match="/config">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="$mode='pelagios'">
					<xsl:call-template name="pelagios"/>
				</xsl:when>
				<xsl:when test="$mode='nomisma'">
					<xsl:call-template name="nomisma"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

	<xsl:template name="pelagios">
		<void:Dataset>
			<dcterms:title>
				<xsl:value-of select="title"/>
			</dcterms:title>
			<foaf:homepage rdf:resource="{url}"/>
			<dcterms:description>
				<xsl:value-of select="description"/>
			</dcterms:description>
			<dcterms:publisher>
				<xsl:value-of select="template/agencyName"/>
			</dcterms:publisher>
			<dcterms:license rdf:resource="{template/license}"/>
			<dcterms:subject rdf:resource="http://dbpedia.org/resource/Annotation"/>
			<void:dataDump rdf:resource="{url}pelagios.rdf"/>
		</void:Dataset>
	</xsl:template>

	<xsl:template name="nomisma">
		<void:Dataset rdf:about="{url}">
			<dcterms:title>
				<xsl:value-of select="title"/>
			</dcterms:title>
			<xsl:if test="string(nomisma_namespace)">
				<rdfs:seeAlso rdf:resource="{nomisma_namespace}"/>
			</xsl:if>
			<dcterms:description>
				<xsl:value-of select="description"/>
			</dcterms:description>
			<dcterms:publisher>
				<xsl:value-of select="template/agencyName"/>
			</dcterms:publisher>
			<dcterms:license rdf:resource="{template/license}"/>
			<void:uriSpace>
				<xsl:value-of select="concat(url, 'id/')"/>
			</void:uriSpace>
			<void:dataDump rdf:resource="{url}nomisma.rdf"/>
		</void:Dataset>
	</xsl:template>
</xsl:stylesheet>
