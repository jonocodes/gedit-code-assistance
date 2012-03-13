plugindir = $(GCP_BACKENDS_LIBS_DIR)

plugin_LTLIBRARIES = libgcpbackendc.la

SOURCES = \
	gcp-c-backend.vala \
	gcp-c-config.vala \
	gcp-c-document.vala \
	gcp-c-compile-args.vala \
	gcp-c-translation-unit.vala \
	gcp-c-semantic-value.vala \
	gcp-c-translator.vala

BUILT_SOURCES = $(vala_sources:.vala=.c)

libgcpbackendc_la_SOURCES = $(SOURCES)

libgcpbackendc_la_CFLAGS = $(GCP_CFLAGS) $(LLVM_CFLAGS) $(GEDIT_CFLAGS) -I$(top_srcdir)/src -w
libgcpbackendc_la_LDFLAGS = -module -shared -avoid-version $(GCP_LIBS) $(LLVM_LIBS)

valapkgs = gio-2.0 gee-1.0 clang gcp gtk+-3.0 gtksourceview-3.0 gedit-3.0 libpeas-1.0

VALAFLAGS = \
	--vapidir $(top_srcdir)/src \
	--vapidir $(top_srcdir)/vapi \
	$(foreach pkg,$(valapkgs),--pkg $(pkg))

plugin_DATA = gcpbackendc.plugin

EXTRA_DIST = \
	gcpbackendc.plugin

CLEANFILES = \
	libgcpbackendc_la_vala.stamp \
	$(BUILT_SOURCES)

install-data-hook:
	rm -f $(GCP_BACKENDS_LIBS_DIR)/libgcpbackendc.la

-include $(top_srcdir)/git.mk
