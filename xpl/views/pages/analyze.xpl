<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date modified: April 2020
	Function: Get a list of hoards that have been published in Solr to populate the compare multi-select box
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>				
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/solr/get_hoards.xpl"/>
		<p:output name="data" id="get_hoards-model"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#get_hoards-model"/>		
		<p:input name="config" href="../../../ui/xslt/ajax/get_hoards.xsl"/>
		<p:output name="data" id="hoards-list"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="hoards-list" href="#hoards-list"/>
		<p:input name="data" href="#data"/>		
		<p:input name="config" href="../../../ui/xslt/pages/analyze.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
