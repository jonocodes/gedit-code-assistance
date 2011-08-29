INCLUDES =				\
	-I$(srcdir)			\
	-I$(top_srcdir)			\
	-DDATADIR=\""$(datadir)"\"

plugindir = $(GEDIT_PLUGIN_DIR)
plugin_LTLIBRARIES = libgcp.la

SOURCES = \
	gcp.vala \
	gcp-view.vala \
	gcp-document.vala \
	gcp-backend.vala \
	gcp-backend-manager.vala \
	gcp-symbol-browser.vala \
	gcp-symbol-browser-support.vala \
	gcp-c-backend.vala \
	gcp-c-document.vala \
	gcp-c-compile-args.vala

if WITH_GEDIT2
SOURCES += gcp-window-helper.vala gcp-plugin2.vala
else
SOURCES += gcp-view-activatable.vala gcp-plugin3.vala
endif

generated = $(SOURCES:.vala=.c)

libgcp_la_SOURCES = $(SOURCES)

libgcp_la_CFLAGS = $(GCP_CFLAGS) $(GEDIT_CFLAGS)
libgcp_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS) $(CLANG_LIBS) $(GEDIT_LIBS)

valapkgs = gio-2.0 gee-1.0 clang

if WITH_GEDIT2
valapkgs += gedit-2.20
else
valapkgs += gtk+-3.0 gtksourceview-3.0 gedit-3.0 libpeas-1.0
endif

VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	$(foreach pkg,$(valapkgs),--pkg $(pkg))

CLEANFILES = \
	libgcp_la_vala.stamp

MAINTAINERCLEANFILES = $(generated)

-include $(top_srcdir)/git.mk
