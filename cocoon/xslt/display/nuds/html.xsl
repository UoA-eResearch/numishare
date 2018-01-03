<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:nuds="http://nomisma.org/nuds"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="q"/>
	<xsl:param name="weightQuery"/>
	<xsl:variable name="tokenized_weightQuery" select="tokenize($weightQuery, ' AND ')"/>
	<xsl:param name="start"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>
	<xsl:param name="type"/>

	<xsl:variable name="recordType" select="/content/nuds:nuds/@recordType"/>

	<xsl:variable name="typeDesc_resource" select="descendant::nuds:typeDesc/@xlink:href"/>

	<xsl:template name="nuds">
		<xsl:apply-templates select="/content/nuds:nuds"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<xsl:if test="$mode = 'compare'">
			<div class="compare_options">
				<a
					href="compare_results?q={$q}&amp;start={$start}&amp;image={$image}&amp;side={$side}&amp;mode=compare{if (string($lang)) then concat('&amp;lang=', $lang) else ''}"
					class="back_results">« Search results</a>
				<xsl:text> | </xsl:text>
				<a href="id/{$id}">Full record »</a>
			</div>
		</xsl:if>
		<!-- below is a series of conditionals for forming the image boxes and displaying obverse and reverse images, iconography, and legends if they are available within the EAD document -->
		<xsl:choose>
			<xsl:when test="not($mode = 'compare')">
				<div class="yui3-u-1">
					<xsl:call-template name="icons"/>
				</div>
				<xsl:choose>
					<xsl:when test="$recordType = 'conceptual'">
						<div class="yui3-u-1">
							<div class="content">
								<h1 id="object_title">
									<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
								</h1>
								<xsl:call-template name="nuds_content"/>

								<!-- show associated objects, preferencing those from Metis first -->
								<xsl:if test="string($sparql_endpoint)">
									<cinclude:include src="cocoon:/widget?uri={concat('http://numismatics.org/ocre/', 'id/', $id)}&amp;template=display"/>
								</xsl:if>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="$recordType = 'physical'">
						<xsl:choose>
							<xsl:when test="$orientation = 'vertical'">
								<div class="yui3-u-1">
									<div class="content">
										<h1 id="object_title">
											<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
										</h1>
									</div>
								</div>

								<xsl:choose>
									<xsl:when test="$image_location = 'left'">
										<div class="yui3-u-5-12">
											<div class="content">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'right'">
										<div class="yui3-u-7-12">
											<div class="content">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="$image_location = 'left'">
										<div class="yui3-u-7-12">
											<div class="content">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'right'">
										<div class="yui3-u-5-12">
											<div class="content">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$orientation = 'horizontal'">
								<div class="yui3-u-1">
									<div class="content">
										<h1 id="object_title">
											<xsl:value-of select="normalize-space(nuds:descMeta/nuds:title)"/>
										</h1>
									</div>
								</div>

								<xsl:choose>
									<xsl:when test="$image_location = 'top'">
										<div class="yui3-u-1-2">
											<div class="content">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
										<div class="yui3-u-1-2">
											<div class="content">
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
										<div class="yui3-u-1">
											<div class="content">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
									</xsl:when>
									<xsl:when test="$image_location = 'bottom'">
										<div class="yui3-u-1">
											<div class="content">
												<xsl:call-template name="nuds_content"/>
											</div>
										</div>
										<div class="yui3-u-1-2">
											<div class="content">
												<xsl:call-template name="image">
													<xsl:with-param name="side">obverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
										<div class="yui3-u-1-2">
											<div class="content">
												<xsl:call-template name="image">
													<xsl:with-param name="side">reverse</xsl:with-param>
												</xsl:call-template>
											</div>
										</div>
									</xsl:when>
								</xsl:choose>

							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
				<div class="yui3-u-1">
					<xsl:call-template name="icons"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="image">
					<xsl:with-param name="side">obverse</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="image">
					<xsl:with-param name="side">reverse</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="nuds_content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="nuds_content">
		<!--********************************* MENU ******************************************* -->
		<xsl:choose>
			<xsl:when test="$mode = 'compare'">
				<!-- process nuds:typeDesc differently -->
				<div>
					<xsl:if test="nuds:descMeta/nuds:physDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
						</div>
					</xsl:if>
					<!-- process nuds:typeDesc differently -->
					<div class="metadata_section">
						<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
							<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
						</xsl:apply-templates>
					</div>
					<xsl:if test="nuds:descMeta/nuds:undertypeDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:refDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:findspotDesc">
						<div class="metadata_section">
							<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
						</div>
					</xsl:if>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div id="tabs">
					<ul>
						<li>
							<a href="#summary">
								<xsl:value-of select="numishare:normalizeLabel('display_summary', $lang)"/>
							</a>
						</li>
						<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
							<li>
								<a href="#mapTab">
									<xsl:value-of select="numishare:normalizeLabel('display_map', $lang)"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="$recordType = 'conceptual' and (count(//nuds:associatedObject) &gt; 0 or string($sparql_endpoint))">
							<li>
								<a href="#charts">
									<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="nuds:descMeta/nuds:adminDesc/*">
							<li>
								<a href="#administrative">
									<xsl:value-of select="numishare:normalizeLabel('display_administrative', $lang)"/>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="nuds:description">
							<li>
								<a href="#commentary">
									<xsl:value-of select="numishare:normalizeLabel('display_commentary', $lang)"/>
								</a>
							</li>
						</xsl:if>

					</ul>
					<div id="summary">
						<xsl:if test="nuds:descMeta/nuds:physDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:physDesc"/>
							</div>
						</xsl:if>
						<!-- process nuds:typeDesc differently -->
						<div class="metadata_section">
							<xsl:apply-templates select="$nudsGroup//nuds:typeDesc">
								<xsl:with-param name="typeDesc_resource" select="$typeDesc_resource"/>
							</xsl:apply-templates>
						</div>
						<xsl:if test="nuds:descMeta/nuds:undertypeDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:undertypeDesc"/>
							</div>
						</xsl:if>
						<xsl:if test="nuds:descMeta/nuds:refDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:refDesc"/>
							</div>
						</xsl:if>
						<xsl:if test="nuds:descMeta/nuds:subjectSet">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:subjectSet"/>
							</div>
						</xsl:if>
						<xsl:if test="nuds:descMeta/nuds:findspotDesc">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:findspotDesc"/>
							</div>
						</xsl:if>
					</div>
					<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
						<div id="mapTab">
							<h2>Map This Object</h2>
							<p>Use the layer control along the right edge of the map (the "plus" symbol) to toggle map layers.</p>
							<div id="mapcontainer"/>
							<div class="legend">
								<table>
									<tbody>
										<tr>
											<th style="width:100px;background:none">
												<xsl:value-of select="numishare:regularize_node('legend', $lang)"/>
											</th>
											<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
											<td style="width:100px">
												<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
											</td>
											<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
											<td style="width:100px">
												<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
							<ul id="term-list" style="display:none">
								<xsl:for-each select="document(concat($solr-url, 'select?q=id:&#x022;', $id, '&#x022;'))//arr">
									<xsl:if
										test="contains(@name, '_facet') and not(contains(@name, 'institution')) and not(contains(@name, 'collection')) and not(contains(@name, 'department'))">
										<xsl:variable name="name" select="@name"/>
										<xsl:for-each select="str">
											<li class="{$name}">
												<xsl:value-of select="."/>
											</li>
										</xsl:for-each>

									</xsl:if>
								</xsl:for-each>
							</ul>
						</div>
					</xsl:if>
					<xsl:if test="$recordType = 'conceptual' and (count(//nuds:associatedObject) &gt; 0 or string($sparql_endpoint))">
						<div id="charts">
							<xsl:call-template name="charts"/>
						</div>
					</xsl:if>
					<xsl:if test="nuds:descMeta/nuds:adminDesc/*">
						<div id="administrative">
							<div class="metadata_section">
								<xsl:apply-templates select="nuds:descMeta/nuds:adminDesc"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="nuds:description">
						<div id="commentary">
							<xsl:apply-templates select="nuds:description"/>
						</div>
					</xsl:if>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:undertypeDesc">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:findspotDesc">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<xsl:choose>
			<xsl:when test="string(@xlink:href)">
				<xsl:choose>
					<xsl:when test="contains(@xlink:href, 'nomisma.org')">
						<xsl:variable name="elem" as="element()*">
							<findspot xlink:href="{@xlink:href}"/>
						</xsl:variable>
						<ul>
							<xsl:apply-templates select="$elem" mode="descMeta"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<p>Source: <a href="{@xlink:href}"><xsl:value-of select="@xlink:href"/></a></p>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<ul>
					<xsl:apply-templates mode="descMeta"/>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:adminDesc">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates mode="descMeta"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subjectSet">
		<h2>
			<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
		</h2>
		<ul>
			<xsl:apply-templates select="subject"/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:subject">
		<li>
			<xsl:choose>
				<xsl:when test="string(@type)">
					<b><xsl:value-of select="@type"/>: </b>
					<a
						href="{$display_path}results?q={@type}_facet:&#x022;{normalize-space(.)}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="."/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<b><xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>: </b>
					<a
						href="{$display_path}results?q=subject_facet:&#x022;{normalize-space(.)}&#x022;{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="."/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</li>
	</xsl:template>

	<!--<xsl:template match="nuds:provenance" mode="descMeta">
		<li>
			<h4>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
			</h4>
			<ul>
				<xsl:for-each select="descendant::nuds:chronItem">
					<li>
						<xsl:apply-templates select="*" mode="descMeta"/>
					</li>
				</xsl:for-each>
			</ul>
		</li>
		</xsl:template>-->

	

	<!-- *********** IMAGE TEMPLATES FOR PHYSICAL OBJECTS ********** -->
	<xsl:template name="image">
		<xsl:param name="side"/>
		<xsl:variable name="reference-image" select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'reference']/mets:FLocat/@xlink:href"/>
		<xsl:variable name="iiif-service" select="//mets:fileGrp[@USE = $side]/mets:file[@USE = 'iiif']/mets:FLocat/@xlink:href"/>
		
		<div class="image-container">
			<xsl:choose>
				<xsl:when test="string($reference-image)">
					<xsl:variable name="image_url"
						select="
						if (matches($reference-image, 'https?://')) then
						$reference-image
						else
						concat($display_path, $reference-image)"/>
					
					<xsl:choose>
						<xsl:when test="string($iiif-service)">
							<div id="{substring($side, 1, 3)}-iiif-container" class="iiif-container"/>
							<span class="hidden" id="{substring($side, 1, 3)}-iiif-service">
								<xsl:value-of select="$iiif-service"/>
							</span>
							<noscript>
								<img src="{$image_url}" property="foaf:depiction" alt="{$side}"/>
							</noscript>
						</xsl:when>
						<xsl:otherwise>
							<img src="{$image_url}" property="foaf:depiction" alt="{$side}"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:apply-templates select="$nudsGroup//nuds:typeDesc/*[local-name() = $side]" mode="physical"/>
					<!-- add link to high resolution image -->
					<xsl:if test="string($iiif-service)">
						<div>
							<a href="{$iiif-service}/full/full/0/default.jpg" title="Full resolution image" rel="nofollow"><span
								class="glyphicon glyphicon-download-alt"/> Download full resolution image</a>
						</div>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$nudsGroup//nuds:typeDesc/*[local-name() = $side]" mode="physical"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse" mode="physical">
		<div>
			<strong>
				<xsl:value-of select="numishare:regularize_node(local-name(), $lang)"/>
				<xsl:if test="string(nuds:legend) or string(nuds:type)">
					<xsl:text>: </xsl:text>
				</xsl:if>
			</strong>
			<xsl:apply-templates select="nuds:legend" mode="physical"/>
			<xsl:if test="string(nuds:legend) and string(nuds:type)">
				<xsl:text> - </xsl:text>
			</xsl:if>
			<!-- apply language-specific type description templates -->
			<xsl:choose>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = $lang]">
					<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = $lang]" mode="physical"/>
				</xsl:when>
				<xsl:when test="nuds:type/nuds:description[@xml:lang = 'en']">
					<xsl:apply-templates select="nuds:type/nuds:description[@xml:lang = 'en']" mode="physical"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="nuds:type/nuds:description[1]" mode="physical"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<!-- charts template -->
	<xsl:template name="charts">
		<h2>
			<xsl:value-of select="numishare:normalizeLabel('display_quantitative', $lang)"/>
		</h2>
		<p>Average weight for this coin-type: <cinclude:include src="cocoon:/get_avg_weight?q=id:&#x022;{$id}&#x022;"/> grams</p>
		<xsl:if test="string($weightQuery)">
			<div id="{@name}-container" style="min-width: 400px; height: 400px; margin: 20px auto"/>
			<!-- class="calculate" -->
			<table class="calculate">
				<caption>Average Weight for Coin-Type: <xsl:value-of select="$id"/></caption>
				<thead>
					<tr>
						<th/>
						<th>Average Weight</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<th>
							<xsl:value-of select="$id"/>
						</th>
						<td>
							<cinclude:include src="cocoon:/get_avg_weight?q=id:&#x022;{$id}&#x022;"/>
						</td>
					</tr>
					<xsl:for-each select="$tokenized_weightQuery">
						<tr>
							<th>
								<xsl:value-of select="substring-after(translate(., '&#x022;', ''), ':')"/>
							</th>
							<td>
								<cinclude:include src="cocoon:/get_avg_weight?q={.}"/>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>

		<form id="charts-form" action="./{$id}#charts" style="margin:20px">
			<h3>Compare weights in related categories</h3>
			<!-- create checkboxes for available facets -->
			<xsl:for-each
				select="//nuds:material | //nuds:denomination | //nuds:department | //nuds:manufacture | //nuds:persname | //nuds:corpname | //nuds:famname | //nuds:geogname">
				<xsl:sort select="local-name()"/>
				<xsl:variable name="href" select="@xlink:href"/>
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="string($lang) and contains($href, 'nomisma.org')">
							<xsl:choose>
								<xsl:when test="string($rdf//*[@rdf:about = $href]/skos:prefLabel[@xml:lang = $lang])">
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel[@xml:lang = $lang]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel[@xml:lang = 'en']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="string($lang) and contains($href, 'geonames.org')">
							<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
							<xsl:variable name="geonames_data"
								select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
							<xsl:choose>
								<xsl:when test="count($geonames_data//alternateName[@lang = $lang]) &gt; 0">
									<xsl:for-each select="$geonames_data//alternateName[@lang = $lang]">
										<xsl:value-of select="."/>
										<xsl:if test="not(position() = last())">
											<xsl:text>/</xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$geonames_data//name"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<!-- if there is no text value and it points to nomisma.org, grab the prefLabel -->
							<xsl:choose>
								<xsl:when test="not(string(normalize-space(.))) and contains($href, 'nomisma.org')">
									<xsl:value-of select="$rdf//*[@rdf:about = $href]/skos:prefLabel[@xml:lang = 'en']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="name">
					<xsl:choose>
						<xsl:when test="string(@xlink:role)">
							<xsl:value-of select="@xlink:role"/>
						</xsl:when>
						<xsl:when test="string(@type)">
							<xsl:value-of select="@type"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local-name()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="query_fragment" select="concat($name, '_facet:&#x022;', ., '&#x022;')"/>

				<xsl:choose>
					<xsl:when test="contains($weightQuery, $query_fragment)">
						<input type="checkbox" id="{$name}-checkbox" checked="checked" value="{$query_fragment}" class="weight-checkbox"/>
					</xsl:when>
					<xsl:otherwise>
						<input type="checkbox" id="{$name}-checkbox" value="{$query_fragment}" class="weight-checkbox"/>
					</xsl:otherwise>
				</xsl:choose>

				<label for="{$name}-checkbox">
					<xsl:value-of select="numishare:regularize_node($name, $lang)"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="$value"/>
				</label>
				<br/>
			</xsl:for-each>
			<div>
				<label>
					<xsl:text>Chart Type</xsl:text>
					<select name="type">
						<xsl:variable name="types">column,line,spline,area,areaspline,scatter</xsl:variable>
						<xsl:for-each select="tokenize($types, ',')">
							<option>
								<xsl:if test="$type = .">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</option>
						</xsl:for-each>
					</select>
				</label>
			</div>
			<input type="hidden" name="weightQuery" id="weights-q" value=""/>
			<br/>
			<input type="submit" value="Modify Chart" id="submit-weights"/>
		</form>
	</xsl:template>

	<!--<xsl:when test="$field = 'category_facet'">
		<xsl:variable name="tokenized-category" select="tokenize(normalize-space(.), '-/-')"/>
		
		<xsl:for-each select="$tokenized-category">
			<xsl:variable name="category-query">
				<xsl:call-template name="assemble_category_query">
					<xsl:with-param name="level" as="xs:integer" select="position()"/>
					<xsl:with-param name="tokenized-category" select="$tokenized-category"/>
				</xsl:call-template>
			</xsl:variable>
			<a href="{$display_path}results?q=category_facet:({$category-query})">
				<xsl:value-of select="."/>
			</a>
			<xsl:if test="not(position() = last())">
				<xsl:text>-/-</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:when>-->

	<xsl:template match="nuds:chronList | nuds:list">
		<ul class="list">
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="nuds:chronItem | nuds:item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<xsl:template match="nuds:date">
		<xsl:choose>
			<xsl:when test="parent::nuds:chronItem">
				<i>
					<xsl:value-of select="."/>
				</i>
				<xsl:text>:  </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="nuds:event">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="nuds:eventgrp">
		<xsl:for-each select="nuds:event">
			<xsl:apply-templates select="."/>
			<xsl:if test="not(position() = last())">
				<xsl:text>; </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>