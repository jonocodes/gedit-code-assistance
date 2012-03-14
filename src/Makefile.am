INCLUDES =				\
	-I$(srcdir)			\
	-I$(top_srcdir)			\
	-DDATADIR=\""$(datadir)"\"

plugindir = $(GEDIT_PLUGIN_DIR)
plugin_LTLIBRARIES = libgcp.la

vala_sources = \
	gcp.vala \
	gcp-plugin.vala \
	gcp-app-activatable.vala \
	gcp-view-activatable.vala \
	gcp-source-location.vala \
	gcp-source-range.vala \
	gcp-expand-range.vala \
	gcp-source-range-support.vala \
	gcp-source-index.vala \
	gcp-view.vala \
	gcp-document.vala \
	gcp-scrollbar-marker.vala \
	gcp-backend.vala \
	gcp-backend-implementation.vala \
	gcp-backend-manager.vala \
	gcp-unsaved-file.vala \
	gcp-semantic-value.vala \
	gcp-semantic-value-support.vala \
	gcp-symbol-browser.vala \
	gcp-symbol-browser-support.vala \
	gcp-diagnostic.vala \
	gcp-diagnostic-colors.vala \
	gcp-diagnostic-tags.vala \
	gcp-diagnostic-support.vala \
	gcp-diagnostic-message.vala \
	gcp-log.vala

SOURCES = \
	$(vala_sources) \
	gcp-utils-c.c

NOINSTHFILES = \
	gcp-utils-c.h

BUILT_SOURCES = $(vala_sources:.vala=.c)

libgcp_la_SOURCES = $(SOURCES)

libgcp_la_CFLAGS = $(GCP_CFLAGS) $(GEDIT_CFLAGS) -I$(top_srcdir) -w
libgcp_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS) $(GEDIT_LIBS)

valapkgs = 				\
	gio-2.0 			\
	gee-1.0 			\
	gcp-utils 			\
	gtk+-3.0 			\
	gtksourceview-3.0 		\
	gedit-3.0 			\
	libpeas-1.0 			\
	gobject-introspection-1.0	\
	posix				\
	config

INTROSPECTION_COMPILER_ARGS = --includedir $(GEDIT_GIR_DIR)

-include $(INTROSPECTION_MAKEFILE)

girdir = $(GCP_DATA_DIR)/gir-1.0
gir_DATA = Gcp-3.0.gir

typelibdir = $(GCP_LIBS_DIR)/girepository-1.0
typelib_DATA = $(gir_DATA:.gir=.typelib)

headerdir = $(prefix)/include/gedit-$(GEDIT_API_VERSION)/gcp
header_DATA = gcp.h

VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	--header gcp.h \
	--vapi gcp.vapi \
	--library libgcp \
	--gir Gcp-3.0.gir \
	$(foreach pkg,$(valapkgs),--pkg $(pkg))

CLEANFILES = \
	libgcp_la_vala.stamp \
	$(BUILT_SOURCES)

MAINTAINERCLEANFILES = $(generated) $(gir_DATA) $(typelib_DATA)

EXTRA_DIST = $(NOINSTHFILES) $(gir_DATA) $(typelib_DATA)

-include $(top_srcdir)/git.mk
