<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="stub" select="substring-after(doc('input:request')/request/request-url, 'pages/')"/>	
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>

	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path">../../</xsl:variable>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="//page[@stub = $stub]/title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}ui/images/favicon.png"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				
				<link type="text/css" href="{$include_path}ui/css/style.css" rel="stylesheet"/>
				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="pages"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="pages">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<xsl:copy-of select="//page[@stub = $stub]/text"/>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
