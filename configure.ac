AC_PREREQ(2.63.2)

m4_define(gedit_code_assistance_major_version, 0)
m4_define(gedit_code_assistance_minor_version, 1)
m4_define(gedit_code_assistance_micro_version, 2)
m4_define(gedit_code_assistance_version, gedit_code_assistance_major_version.gedit_code_assistance_minor_version.gedit_code_assistance_micro_version)

AC_INIT([gedit-code-assistance],[gedit_code_assistance_version],[http://bugzilla.gnome.org/enter_bug.cgi?product=gedit],[gedit-code-assistance],[http://projects.gnome.org/gedit/])

AC_CONFIG_HEADERS(config.h)
AC_CONFIG_MACRO_DIR([m4])

AC_ISC_POSIX
AC_STDC_HEADERS
AC_PROG_CC
AM_PROG_CC_STDC
AC_HEADER_STDC
AM_PROG_LIBTOOL

AM_INIT_AUTOMAKE([1.11 tar-ustar dist-xz no-dist-gzip -Wno-portability])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

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
])

GCP_LIBS="${GCP_LIBS}"

AC_SUBST(GCP_LIBS)
AC_SUBST(GCP_CFLAGS)

AC_PATH_PROG([LLVM_CONFIG], [llvm-config], [])

if test "x$LLVM_CONFIG" = "x"; then
	AC_MSG_ERROR([could not find llvm-config])
fi

dnl find out the libdir of llvm
LLVM_LIBS=$($LLVM_CONFIG --ldflags)
LLVM_CFLAGS=$($LLVM_CONFIG --cflags)

dnl ================================================================
dnl Find clang headers and lib
dnl ================================================================

OLDCFLAGS="$CFLAGS"
OLDLDFLAGS="$LDFLAGS"

CFLAGS="$OLDCFLAGS $LLVM_CFLAGS"
LDFLAGS="$OLDLDFLAGS $LLVM_LIBS"

AC_CHECK_LIB([clang],
             [clang_createIndex],
             [],
             [AC_MSG_ERROR([could not find clang library])])

AC_CHECK_HEADER([clang-c/Index.h],
                [],
                [AC_MSG_ERROR([could not find clang header Index.h])])

LLVM_LIBS="$LLVM_LIBS -lclang"

AC_SUBST(LLVM_CFLAGS)
AC_SUBST(LLVM_LIBS)

CFLAGS="$OLDCFLAGS"
LDFLAGS="$OLDLDFLAGS"

LLVM_VERSION=$($LLVM_CONFIG --version)
AC_DEFINE_UNQUOTED([LLVM_VERSION], "$LLVM_VERSION", [LLVM version])

AC_SUBST(LLVM_VERSION)

AC_ARG_ENABLE([local],
              AS_HELP_STRING([--enable-local],[enable local install (in user directory)]),
              [enable_local=$enableval],
              [enable_local=no])

dnl ================================================================
dnl Find gedit
dnl ================================================================
PKG_CHECK_MODULES([GEDIT], [gedit >= 3.0])

if test "x$enable_local" = "xyes"; then
	geditlibdir="$HOME/.local/share"
	geditdatadir="$HOME/.local/share"
else
	geditlibdir="${libdir}"
	geditdatadir="${datadir}"
fi

GEDIT_PLUGIN_DIR="$geditlibdir/gedit/plugins"
GEDIT_DATA_DIR="$geditdatadir/gedit/plugins"


AC_SUBST(GEDIT_PLUGIN_DIR)
AC_SUBST(GEDIT_DATA_DIR)

AC_SUBST(GEDIT_CFLAGS)
AC_SUBST(GEDIT_LIBS)

AC_CONFIG_FILES([
Makefile
data/Makefile
data/gcp.plugin
src/Makefile
src/gcp-config.vala
vapi/Makefile
])

AC_OUTPUT

echo "

Configuration:

	Prefix:                 ${prefix}
	Source code location:	${srcdir}
	Compiler:		${CC}
	valac:			$VALAC
	gedit plugin dir:       $GEDIT_PLUGIN_DIR
	gedit data dir:         $GEDIT_DATA_DIR
	llvm version:           $LLVM_VERSION
"

