INCLUDES =				\
	-I$(srcdir)			\
	-I$(top_srcdir)			\
	-DDATADIR=\""$(datadir)"\"

plugindir = $(GEDIT_PLUGIN_DIR)
plugin_LTLIBRARIES = libgcp.la

vala_sources = \
	gcp.vala \
	gcp-source-location.vala \
	gcp-source-range.vala \
	gcp-expand-range.vala \
	gcp-view.vala \
	gcp-document.vala \
	gcp-scrollbar-marker.vala \
	gcp-backend.vala \
	gcp-backend-manager.vala \
	gcp-unsaved-file.vala \
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
	gcp-c-translation-unit.vala

SOURCES = \
	$(vala_sources) \
	gcp-utils-c.c

BUILT_SOURCES = $(vala_sources:.vala=.c)

libgcp_la_SOURCES = $(SOURCES)

libgcp_la_CFLAGS = -Wimplicit-function-declaration -Wno-unused-value -Wno-ignored-qualifiers -Wno-conversion $(GCP_CFLAGS) $(GEDIT_CFLAGS) $(LLVM_CFLAGS)
libgcp_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS) $(LLVM_LIBS) $(GEDIT_LIBS)

valapkgs = gio-2.0 gee-1.0 clang gcp

if WITH_GEDIT2
valapkgs += gedit-2.20
else
valapkgs += gtk+-3.0 gtksourceview-3.0 gedit-3.0 libpeas-1.0
endif

VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	$(foreach pkg,$(valapkgs),--pkg $(pkg))

if WITH_GEDIT2
SOURCES += gcp-window-helper.vala gcp-plugin2.vala
VALAFLAGS += --define=WITH_GEDIT2
else
SOURCES += gcp-view-activatable.vala gcp-plugin3.vala
VALAFLAGS += --define=WITH_GEDIT3
endif


CLEANFILES = \
	libgcp_la_vala.stamp \
	$(BUILT_SOURCES)

MAINTAINERCLEANFILES = $(generated)

-include $(top_srcdir)/git.mk
