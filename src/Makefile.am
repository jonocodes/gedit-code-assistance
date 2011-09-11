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
	gcp-c-backend.vala \
	gcp-c-document.vala \
	gcp-c-compile-args.vala \
	gcp-c-translation-unit.vala \
	gcp-c-semantic-value.vala \
	gcp-c-translator.vala

SOURCES = \
	$(vala_sources) \
	gcp-utils-c.c

BUILT_SOURCES = $(vala_sources:.vala=.c)

libgcp_la_SOURCES = $(SOURCES)

libgcp_la_CFLAGS = $(GCP_CFLAGS) $(GEDIT_CFLAGS) $(LLVM_CFLAGS) -Wimplicit-function-declaration -Wno-unused-value -Wno-ignored-qualifiers -Wno-conversion -Wno-unused-but-set-variable -Wno-unused-label
libgcp_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS) $(LLVM_LIBS) $(GEDIT_LIBS)

valapkgs = gio-2.0 gee-1.0 clang gcp gtk+-3.0 gtksourceview-3.0 gedit-3.0 libpeas-1.0

VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	$(foreach pkg,$(valapkgs),--pkg $(pkg))

CLEANFILES = \
	libgcp_la_vala.stamp \
	$(BUILT_SOURCES)

MAINTAINERCLEANFILES = $(generated)

-include $(top_srcdir)/git.mk
