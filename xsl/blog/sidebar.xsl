<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="purple.sidebar">

    <aside>

      <div class="sidebox">
        <h1 class="clear">Sidebar Menu</h1>
        <ul class="sidemenu">
          <li>
            <a href="/doc/Boost.CMake/">Boost.CMake</a>
          </li>
          <li>
            <a href="http://www.equalizergraphics.com/">Equalizer</a>
          </li>
          <li>
            <a href="/doc/libMaoni/">libMaoni</a>
          </li>
        </ul>
      </div>

      <div class="sidebox">
        <h1 class="clear">twitter</h1>
        <ul class="sidemenu" id="twitter_update_list"></ul>
        <script type="text/javascript" src="http://twitter.com/statuses/user_timeline/danielpfeifer.json?callback=twitter_callback&amp;count=5">;</script>
      </div>

      <a id="getubuntu" href="http://www.ubuntu.com/">Get Ubuntu</a>

      <canvas class="sidebox tagcanvas" width="231" height="231">
        <h1 class="clear">Useful Links</h1>
        <ul class="sidemenu">
          <li>
            <a href="/doc/libMaoni/">libMaoni</a>
          </li>
          <li>
            <a href="http://sourceforge.net/projects/equalizer/">Equalizer</a>
          </li>
          <li>
            <a href="http://cmake.org/cmake/help/cmake-2-8-docs.html">CMake</a>
          </li>
          <li>
            <a href="http://www.revergestudios.com/boost-la/">Boost LA</a>
          </li>
          <li>
            <a href="/index.html">Home</a>
          </li>
          <li>
            <a href="/index.html">Home</a>
          </li>
          <li>
            <a href="/index.html">Home</a>
          </li>
        </ul>
      </canvas>

    </aside>

  </xsl:template>
</xsl:stylesheet>
