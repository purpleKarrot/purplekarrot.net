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

include(AddCSS)
include(AddExternal)
include(AddProject)
include(BoostBook)
include(Doxygen)
include(QuickBook)
include(AddQuickBook)
include(XSLTransform)

add_css(purplekarrot.css
  css/pixelGreen.sass
  css/admonition.sass
  css/navigation.sass
  css/disqus.sass
  css/code.sass
  )

file(GLOB BLOG blog/*)
add_quickbook(blog.xml "part Blog"
  ID blog
  DIRNAME blog
  COPYRIGHT "2010 Daniel Pfeifer"
  AUTHORS "[Pfeifer, Daniel]"
  XINCLUDE ${BLOG}
  )

add_project(libMaoni
  REPOSITORY GIT git://github.com/purpleKarrot/libMaoni.git
  DOCUMENTATION maoni-doc.xml
  )

#add_quickbook(projects.xml "part Projects"
#  ID projects
#  DIRNAME projects
#  COPYRIGHT "2010 Daniel Pfeifer"
#  AUTHORS "[Pfeifer, Daniel]"
#  XINCLUDE build/build/external/libMaoni/doc/maoni-doc.xml
#  )

add_quickbook(website.xml "book purpleKarrot Website"
  COPYRIGHT "2010 Daniel Pfeifer"
  AUTHORS "[Pfeifer, Daniel]"
  XINCLUDE
    ${CMAKE_BINARY_DIR}/blog.xml
#   ${CMAKE_BINARY_DIR}/projects.xml
  )

xsl_transform(website.docbook website.xml
  STYLESHEET ${BOOSTBOOK_XSL_DIR}/docbook.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  COMMENT "Generating DocBook from website.xml."
  DEPENDS website.xml
  )

xsl_transform(${CMAKE_CURRENT_BINARY_DIR}/html website.docbook
  STYLESHEET ${CMAKE_SOURCE_DIR}/xsl/chunk.xsl
  CATALOG ${BOOSTBOOK_CATALOG}
  DIRECTORY HTML.manifest
  COMMENT "Generating Website HTML."
  MAKE_ALL_TARGET website-html
  )

add_custom_target(website ALL DEPENDS website.docbook)
