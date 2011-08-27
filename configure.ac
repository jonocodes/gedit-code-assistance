AC_INIT(gedit-code-plugin, 1.0)

AC_PREREQ(2.62)
AM_INIT_AUTOMAKE([-Wno-portability])

AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])

AC_ISC_POSIX
AC_STDC_HEADERS
AC_PROG_CC
AM_PROG_CC_STDC
AC_HEADER_STDC
AM_PROG_LIBTOOL

AM_MAINTAINER_MODE
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

AC_PROG_INSTALL
AC_PROG_MAKE_SET

AM_PROG_VALAC

if test "x$VALAC" = "x" ; then
	AC_MSG_ERROR([Cannot find the "valac" compiler])
fi

PKG_PROG_PKG_CONFIG

dnl ================================================================
dnl Start of pkg-config checks
dnl ================================================================

PKG_CHECK_MODULES(GCP, [
	glib-2.0
	gio-2.0
	gee-1.0
	gedit
])

GCP_LIBS="${GCP_LIBS}"

AC_SUBST(GCP_LIBS)
AC_SUBST(GCP_CFLAGS)


dnl ================================================================
dnl Check for gedit
dnl ================================================================
GEDIT_PLUGIN_DIR="$libdir/gedit/plugins"
AC_SUBST(GEDIT_PLUGIN_DIR)

AC_CONFIG_FILES([
Makefile
src/Makefile
])

AC_OUTPUT

echo "

Configuration:

	Prefix:                 ${prefix}
	Source code location:	${srcdir}
	Compiler:		${CC}
	valac:			$VALAC
"

