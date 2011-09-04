using Gtk;

namespace Gcp
{
	class DiagnosticColors
	{
		private Gdk.RGBA d_errorColor;
		private Gdk.RGBA d_warningColor;
		private Gdk.RGBA d_infoColor;

		public DiagnosticColors(StyleContext context)
		{
			d_errorColor = update_color(context,
			             "error_bg_color",
			             {1, 0, 0, 1},
			             0.4);

			d_warningColor = update_color(context,
			             "warning_bg_color",
			             {1, 0.5, 0, 1},
			             0.4);

			d_infoColor = update_color(context,
			             "info_bg_color",
			             {0, 0, 1, 1},
			             0.4);
		}

		public Gdk.RGBA? get(Diagnostic.Severity severity)
		{
			switch (severity)
			{
				case Diagnostic.Severity.INFO:
					return d_infoColor;
				case Diagnostic.Severity.WARNING:
					return d_warningColor;
				case Diagnostic.Severity.ERROR:
				case Diagnostic.Severity.FATAL:
					return d_errorColor;
				default:
					return null;
			}
		}

		public Gdk.RGBA error_color
		{
			get { return d_errorColor; }
		}

		public Gdk.RGBA warning_color
		{
			get { return d_warningColor; }
		}

		public Gdk.RGBA info_color
		{
			get { return d_infoColor; }
		}

		private Gdk.RGBA update_color(StyleContext context,
		                              string color_name,
		                              Gdk.RGBA defcol,
		                              double alpha)
		{
			Gdk.RGBA col;

			if (!context.lookup_color(color_name, out col))
			{
				col = defcol;
			}

			col.alpha *= alpha;

			return col;
		}
	}
}

/* vi:ex:ts=4 */
