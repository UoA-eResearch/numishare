<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: August 2020
	Function: HTML view for NUDS. It involves conditionals for conceptual vs. physical specimens, 
		including SPARQL queries for associated specimens and annoations.
		July 2018: added type-examples.xpl into this XPL in order to avoid xsl:document() function call to /api pipeline within the XSLT
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:saxon="http://saxon.sf.net/">
	<p:param type="input" name="data"/>
	<!--<p:param type="output" name="data"/>-->
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:template match="/">
					<recordType>
						<xsl:choose>							
							<xsl:when test="*/@recordType='conceptual'">conceptual</xsl:when>
							<xsl:when test="*/@recordType='physical'">physical</xsl:when>
						</xsl:choose>
					</recordType>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="recordType"/>
	</p:processor>
	
	<p:choose href="#recordType">		
		<!-- if it is a coin type record, then execute an ASK query -->
		<p:when test="recordType='conceptual'">
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/specimen-count.xpl"/>
				<p:output name="data" id="specimenCount"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-findspots.xpl"/>
				<p:output name="data" id="hasFindspots"/>
			</p:processor>
			
			<p:processor name="oxf:pipeline">						
				<p:input name="data" href="#config"/>
				<p:input name="config" href="../../../models/sparql/ask-iiif.xpl"/>
				<p:output name="data" id="hasIIIF"/>
			</p:processor>
			
			<!-- load SPARQL query from disk -->
			<p:processor name="oxf:url-generator">
				<p:input name="config">
					<config>
						<url>oxf:/apps/numishare/ui/sparql/type-examples.sparql</url>
						<content-type>text/plain</content-type>
						<encoding>utf-8</encoding>
					</config>
				</p:input>
				<p:output name="data" id="type-examples-query"/>
			</p:processor>
			
			<p:processor name="oxf:text-converter">
				<p:input name="data" href="#type-examples-query"/>
				<p:input name="config">
					<config/>
				</p:input>
				<p:output name="data" id="type-examples-query-document"/>
			</p:processor>
			
			<p:choose href="#config">
				<p:when test="matches(/config/annotation_sparql_endpoint, 'https?://')">
					
					<!-- perform ASK query for annotations related to this URI -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#config"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
								<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>								
								
								<!-- config variables -->
								<xsl:variable name="sparql_endpoint" select="/config/annotation_sparql_endpoint"/>
								
								<xsl:variable name="query">
									<![CDATA[PREFIX oa:	<http://www.w3.org/ns/oa#>
ASK {?s oa:hasBody <URI>}]]>
								</xsl:variable>
								
								<xsl:variable name="service">
									<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>					
								</xsl:variable>
								
								<xsl:template match="/">
									<config>
										<url>
											<xsl:value-of select="$service"/>
										</url>
										<content-type>application/xml</content-type>
										<encoding>utf-8</encoding>
									</config>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="ask-url-generator-config"/>
					</p:processor>
					
					<!-- get a SPARQL response from the endpoint -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#ask-url-generator-config"/>
						<p:output name="data" id="url-data"/>
					</p:processor>
					
					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#url-data"/>
						<p:output name="data" id="url-data-checked"/>
					</p:processor>
					
					<!-- Check whether we had an exception -->
					<p:choose href="#url-data-checked">
						<p:when test="/exceptions">
							<!-- if there is a problem with the SPARQL endpoint, then simply generate the HTML page -->
							
							<p:choose href="#specimenCount">
								<p:when test="//res:binding[@name='count']/res:literal = 0">
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:when>
								<p:otherwise>	
									<p:processor name="oxf:pipeline">						
										<p:input name="data" href="#config"/>
										<p:input name="config" href="../../../models/sparql/type-examples.xpl"/>
										<p:output name="data" id="specimens"/>
									</p:processor>
									
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="specimens" href="#specimens"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:otherwise>
							</p:choose>							
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:pipeline">
								<p:input name="config" href="../../../models/sparql/annotations.xpl"/>		
								<p:output name="data" id="annotations"/>
							</p:processor>
							
							<p:choose href="#specimenCount">
								<p:when test="//res:binding[@name='count']/res:literal = 0">
									<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="annotations" href="#annotations"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:when>
								<p:otherwise>
									<p:processor name="oxf:pipeline">						
										<p:input name="data" href="#config"/>
										<p:input name="config" href="../../../models/sparql/type-examples.xpl"/>
										<p:output name="data" id="specimens"/>
									</p:processor>
									
									<p:processor name="oxf:unsafe-xslt">
										<p:input name="request" href="#request"/>
										<p:input name="hasIIIF" href="#hasIIIF"/>
										<p:input name="annotations" href="#annotations"/>
										<p:input name="specimens" href="#specimens"/>
										<p:input name="query" href="#type-examples-query-document"/>
										<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
										<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
										<p:output name="data" id="model"/>
									</p:processor>
								</p:otherwise>
							</p:choose>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<p:choose href="#specimenCount">
						<p:when test="//res:binding[@name='count']/res:literal = 0">
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hasIIIF" href="#hasIIIF"/>
								<p:input name="query" href="#type-examples-query-document"/>
								<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<p:processor name="oxf:pipeline">						
								<p:input name="data" href="#config"/>
								<p:input name="config" href="../../../models/sparql/type-examples.xpl"/>
								<p:output name="data" id="specimens"/>
							</p:processor>
							
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="hasIIIF" href="#hasIIIF"/>
								<p:input name="specimens" href="#specimens"/>
								<p:input name="query" href="#type-examples-query-document"/>
								<p:input name="data" href="aggregate('content', #data, #specimenCount, #hasFindspots, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>	
			<p:choose href="#config">
				<p:when test="matches(/config/annotation_sparql_endpoint, 'https?://')">
					
					<!-- perform ASK query for annotations related to this URI -->
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#config"/>
						<p:input name="config">
							<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
								<xsl:param name="uri" select="concat(/config/uri_space, tokenize(doc('input:request')/request/request-url, '/')[last()])"/>								
								
								<!-- config variables -->
								<xsl:variable name="sparql_endpoint" select="/config/annotation_sparql_endpoint"/>
								
								<xsl:variable name="query">
									<![CDATA[PREFIX oa:	<http://www.w3.org/ns/oa#>
ASK {?s oa:hasBody <URI>}]]>
								</xsl:variable>
								
								<xsl:variable name="service">
									<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>					
								</xsl:variable>
								
								<xsl:template match="/">
									<config>
										<url>
											<xsl:value-of select="$service"/>
										</url>
										<content-type>application/xml</content-type>
										<encoding>utf-8</encoding>
									</config>
								</xsl:template>
							</xsl:stylesheet>
						</p:input>
						<p:output name="data" id="ask-url-generator-config"/>
					</p:processor>
					
					<!-- get a SPARQL response from the endpoint -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#ask-url-generator-config"/>
						<p:output name="data" id="url-data"/>
					</p:processor>
					
					<p:processor name="oxf:exception-catcher">
						<p:input name="data" href="#url-data"/>
						<p:output name="data" id="url-data-checked"/>
					</p:processor>
					
					<!-- Check whether we had an exception -->
					<p:choose href="#url-data-checked">
						<p:when test="/exceptions">
							<!-- if there is a problem with the SPARQL endpoint, then simply generate the HTML page -->
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:when>
						<p:otherwise>
							<!-- otherwise, combine the XML model with the annotations SPARQL response and execute transformation into HTML -->
							<p:processor name="oxf:pipeline">
								<p:input name="config" href="../../../models/sparql/annotations.xpl"/>		
								<p:output name="data" id="annotations"/>
							</p:processor>
							
							<p:processor name="oxf:unsafe-xslt">
								<p:input name="request" href="#request"/>
								<p:input name="annotations" href="#annotations"/>
								<p:input name="data" href="aggregate('content', #data, #config)"/>
								<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
								<p:output name="data" id="model"/>
							</p:processor>
						</p:otherwise>
					</p:choose>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="aggregate('content', #data, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/nuds/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:otherwise>
	</p:choose>
	
	<!-- prepare the HTML model to be piped through the HTTP serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output name="html" encoding="UTF-8" method="html" indent="yes" omit-xml-declaration="yes" doctype-system="HTML"/>
				
				<xsl:template match="/">
					<xml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						content-type="text/html">
						<xsl:value-of select="saxon:serialize(/html, 'html')"/>
					</xml>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="converted"/>
	</p:processor>
	
	<!-- generate config for http-serializer -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#config"/>
		<p:input name="request" href="#request"/>
		<p:input name="config" href="../../../../ui/xslt/controllers/http-headers.xsl"/>
		<p:output name="data" id="serializer-config"/>
	</p:processor>
	
	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#converted"/>
		<p:input name="config" href="#serializer-config"/>
	</p:processor>
	
	<!--<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>-->
</p:config>
