[CCode(lower_case_cprefix = "gcp_utils_c", cheader_filename = "gcp-utils-c.h")]
namespace GcpUtilsC
{
	[CCode (cname = "gcp_utils_c_get_style_property_int")]
	public static int get_style_property_int(Gtk.StyleContext context,
	                                         string           name);
}

/* vi:ex:ts=4 */
