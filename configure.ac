AC_PREREQ(2.63.2)

m4_define(gedit_code_assistance_major_version, 0)
m4_define(gedit_code_assistance_minor_version, 1)
m4_define(gedit_code_assistance_micro_version, 3)
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

AM_PATH_PYTHON

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
	AC_MSG_WARN([could not find llvm-config])
else
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
	             [LLVM_LIBS="$LLVM_LIBS -lclang"
	              clang_enabled="yes"],
	             [AC_MSG_WARN([could not find clang library])
	              clang_enabled="no"])

	if test "x$clang_enabled" = "xyes"; then
		AC_CHECK_HEADER([clang-c/Index.h],
		                [],
		                [AC_MSG_WARN([could not find clang header Index.h])
		                 clang_enabled="no"])
	fi

	if test "x$clang_enabled" = "xyes"; then
		LLVM_LIBS="$LLVM_LIBS -lclang"
	fi

	AC_SUBST(LLVM_CFLAGS)
	AC_SUBST(LLVM_LIBS)

	CFLAGS="$OLDCFLAGS"
	LDFLAGS="$OLDLDFLAGS"

	LLVM_VERSION=$($LLVM_CONFIG --version)
	AC_DEFINE_UNQUOTED([LLVM_VERSION], "$LLVM_VERSION", [LLVM version])

	AC_SUBST(LLVM_VERSION)
fi

AM_CONDITIONAL(CLANG_ENABLED, test "x$clang_enabled" = "xyes")

AC_ARG_ENABLE([local],
              AS_HELP_STRING([--enable-local],[enable local install (in user directory)]),
              [enable_local=$enableval],
              [enable_local=no])

dnl ================================================================
dnl Find gedit
dnl ================================================================
PKG_CHECK_MODULES([GEDIT], [gedit >= 3.0])

GEDIT_GIR_DIR="${datadir}/gedit/gir-1.0"
AC_SUBST(GEDIT_GIR_DIR)

GEDIT_API_VERSION=3.0
AC_SUBST(GEDIT_API_VERSION)

if test "x$enable_local" = "xyes"; then
	geditlibdir="$HOME/.local/share"
	geditdatadir="$HOME/.local/share"
else
	geditlibdir="${libdir}"
	geditdatadir="${datadir}"
fi

GEDIT_PLUGIN_DIR="$geditlibdir/gedit/plugins"
GEDIT_DATA_DIR="$geditdatadir/gedit/plugins"

GCP_BACKENDS_LIBS_DIR="$GEDIT_PLUGIN_DIR/gcp/backends"
GCP_BACKENDS_DATA_DIR="$GEDIT_DATA_DIR/gcp/backends"

GCP_LIBS_DIR="$GEDIT_PLUGIN_DIR/gcp"
AC_SUBST(GCP_LIBS_DIR)

GCP_DATA_DIR="$GEDIT_DATA_DIR/gcp"
AC_SUBST(GCP_DATA_DIR)

AC_SUBST(GEDIT_PLUGIN_DIR)
AC_SUBST(GEDIT_DATA_DIR)

AC_SUBST(GCP_BACKENDS_LIBS_DIR)
AC_SUBST(GCP_BACKENDS_DATA_DIR)

AC_SUBST(GEDIT_CFLAGS)
AC_SUBST(GEDIT_LIBS)

GOBJECT_INTROSPECTION_CHECK([0.9.3])

dnl adl_RECURSIVE_EVAL(VALUE, RESULT)
dnl =================================
dnl Interpolate the VALUE in loop until it doesn't change,
dnl and set the result to $RESULT.
dnl WARNING: It's easy to get an infinite loop with some unsane input.
AC_DEFUN([adl_RECURSIVE_EVAL],
[_lcl_receval="$1"
$2=`(test "x$prefix" = xNONE && prefix="$ac_default_prefix"
     test "x$exec_prefix" = xNONE && exec_prefix="${prefix}"
     _lcl_receval_old=''
     while test "[$]_lcl_receval_old" != "[$]_lcl_receval"; do
       _lcl_receval_old="[$]_lcl_receval"
       eval _lcl_receval="\"[$]_lcl_receval\""
     done
     echo "[$]_lcl_receval")`])

adl_RECURSIVE_EVAL("$GCP_BACKENDS_LIBS_DIR", [GCP_BACKENDS_DIR_EX])
adl_RECURSIVE_EVAL("$GCP_BACKENDS_DATA_DIR", [GCP_BACKENDS_DATA_DIR_EX])

adl_RECURSIVE_EVAL("$GCP_LIBS_DIR", [GCP_LIBS_DIR_EX])
adl_RECURSIVE_EVAL("$GCP_DATA_DIR", [GCP_DATA_DIR_EX])

AC_DEFINE_UNQUOTED([GCP_BACKENDS_DIR], "$GCP_BACKENDS_DIR_EX", [Backends dir])
AC_DEFINE_UNQUOTED([GCP_BACKENDS_DATA_DIR], "$GCP_BACKENDS_DATA_DIR_EX", [Backends data dir])

AC_DEFINE_UNQUOTED([GCP_LIBS_DIR], "$GCP_LIBS_DIR_EX", [Library dir])
AC_DEFINE_UNQUOTED([GCP_DATA_DIR], "$GCP_DATA_DIR_EX", [Data dir])

PYGOBJECT_REQUIRED=3.0.0

AC_ARG_ENABLE([python],
              AS_HELP_STRING([--enable-python[=@<:@no/auto/yes@:>@]],[Build with python support]),
              [enable_python=$enableval],
              [enable_python="auto"])

if test "x$enable_python" = "xauto"; then
	PKG_CHECK_EXISTS([pygobject-3.0 >= $PYGOBJECT_REQUIRED],
	                 [enable_python=yes],[enable_python=no])
fi

if test "x$enable_python" = "xyes"; then
	PKG_CHECK_MODULES(PYTHON, [pygobject-3.0 >= $PYGOBJECT_REQUIRED])

	pyoverridesdir=`$PYTHON -c "import gi; print(gi._overridesdir)"`
	AC_SUBST(pyoverridesdir)
fi

AM_CONDITIONAL(PYTHON_ENABLED, test x"$enable_python" = "xyes")

AC_ARG_ENABLE([xml],
              AS_HELP_STRING([--enable-xml[=@<:@no/auto/yes@:>@]],[Build with XML support]),
              [enable_xml=$enableval],
              [enable_xml="auto"])

if test "x$enable_xml" = "xauto"; then
	PKG_CHECK_EXISTS([pygobject-3.0 >= $PYGOBJECT_REQUIRED],
	                 [enable_xml=yes],[enable_xml=no])
fi

AM_CONDITIONAL(XML_ENABLED, test x"$enable_xml" = "xyes")

AC_CONFIG_FILES([
Makefile
data/Makefile
data/gcp.plugin
src/Makefile
backends/Makefile
backends/c/Makefile
backends/c/gcp-c-config.vala
backends/c/gcpbackendc.plugin
backends/python/Makefile
backends/python/gcpbackendpython/Makefile
backends/python/gcpbackendpython.plugin
backends/xml/Makefile
backends/xml/gcpbackendxml/Makefile
backends/xml/gcpbackendxml.plugin
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

	backends:
		c:		$clang_enabled ($LLVM_VERSION)
		python:		$enable_python
		xml:		$enable_xml
"

