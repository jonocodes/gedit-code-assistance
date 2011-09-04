[CCode(lower_case_cprefix = "gcp_", cheader_filename = "gcp-utils-c.h")]
namespace Gcp
{
	[CCode (cname = "GcpUtilsC")]
	class UtilsC
	{
		[CCode (cname = "gcp_utils_c_get_style_property_int")]
		public static int get_style_property_int(Gtk.StyleContext context,
		                                         string           name);
	}
}

/* vi:ex:ts=4 */
