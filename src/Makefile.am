INCLUDES =				\
	-I$(srcdir)			\
	-I$(top_srcdir)			\
	-DDATADIR=\""$(datadir)"\"

plugindir = $(GEDIT_PLUGIN_DIR)
plugin_LTLIBRARIES = libgcp.la

SOURCES = gcp-compile-args.vala
BUILT_SOURCES = $(SOURCES:.vala=.c)

libgcp_la_SOURCES = $(SOURCES)

libgcp_la_CFLAGS = $(GCP_CFLAGS)
libgcp_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS)

VALAFLAGS = --vapidir $(top_srcdir)/vapi --pkg gio-2.0 --pkg gee-1.0 --pkg clang

CLEANFILES = libgcp_la_vala.stamp

-include $(top_srcdir)/git.mk
