<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name = "disqus.thread">
	<div id="disqus_thread"></div>
	<script type="text/javascript" src="http://disqus.com/forums/purplekarrot/embed.js"></script>
</xsl:template>

<xsl:template name = "disqus.script">
	<script type="text/javascript">
	//<![CDATA[
	(function() {
		var links = document.getElementsByTagName('a');
		var query = '?';
		for(var i = 0; i < links.length; i++) {
		if(links[i].href.indexOf('#disqus_thread') >= 0) {
			query += 'url' + i + '=' + encodeURIComponent(links[i].href) + '&';
		}
		}
		document.write('<script charset="utf-8" type="text/javascript" src="http://disqus.com/forums/purplekarrot/get_num_replies.js' + query + '"></' + 'script>');
	})();
	//]]>
	</script>
</xsl:template>

</xsl:stylesheet>
