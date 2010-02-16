##############################################################
# Copyright (c) 2010 Daniel Pfeifer                          #
##############################################################

cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(purplekarrot.net)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)

if(MSVC)
  set(Boost_USE_STATIC_LIBS ON)
  add_definitions(-DBOOST_ALL_NO_LIB)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_SCL_SECURE_NO_WARNINGS)
endif(MSVC)

include(BoostBook)
include(QuickBook)
include(AddCSS)
include(AddExternal)
include(AddProject)
include(AddReference)
include(AddXSLTdoc)
include(AddQuickBook)
include(XSLTransform)

add_css(purplekarrot.css
  css/pixelGreen.sass
  css/admonition.sass
  css/navigation.sass
  css/disqus.sass
  css/code.sass
  )

add_subdirectory(doc)

file(GLOB BLOG blog/*)
add_quickbook(blog.xml "part Blog"
  ID blog
  DIRNAME blog
  COPYRIGHT "2010 Daniel Pfeifer"
  AUTHORS "[Pfeifer, Daniel]"
  XINCLUDE ${BLOG}
  )

set(MAONI_BUILD_DOCUMENTATION ON)
add_projects(projects.xml
  PROJECT libMaoni GIT git://github.com/purpleKarrot/libMaoni.git
  )

add_quickbook(website.xml "book purpleKarrot Website"
  COPYRIGHT "2010 Daniel Pfeifer"
  AUTHORS "[Pfeifer, Daniel]"
  XINCLUDE
    ${CMAKE_BINARY_DIR}/blog.xml
    ${CMAKE_BINARY_DIR}/projects.xml
  )

xsl_transform(website.docbook website.xml
  STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  COMMENT "Generating DocBook from website.xml."
  DEPENDS website.xml
  )

xsl_transform(website.manifest website.docbook
  STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/manifest.xslt
  CATALOG ${BOOSTBOOK_CATALOG}
  COMMENT "Generating Manifest."
  DEPENDS website.docbook ${CMAKE_SOURCE_DIR}/xsl/manifest.xslt
  )

xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/html website.docbook
  STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  DIRECTORY index.html
  COMMENT "Generating Website HTML."
  MAKE_ALL_TARGET website-html
  )

add_custom_target(website ALL DEPENDS
  website.manifest
  )
