INCLUDES =				\
	-I$(srcdir)			\
	-I$(top_srcdir)			\
	-DDATADIR=\""$(datadir)"\"

plugindir = $(GEDIT_PLUGIN_DIR)
plugin_LTLIBRARIES = libgcp.la

SOURCES = gcp-compile-args.vala

generated = $(SOURCES:.vala=.c)

libgcp_la_SOURCES = $(SOURCES)

libgcp_la_CFLAGS = $(GCP_CFLAGS)
libgcp_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS)

valapkgs = gio-2.0 gee-1.0 clang gtk+-3.0 gtksourceview-3.0 gedit-3.0

VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	$(foreach pkg,$(valapkgs),--pkg $(pkg))

CLEANFILES = \
	libgcp_la_vala.stamp

MAINTAINERCLEANFILES = $(generated)

-include $(top_srcdir)/git.mk
