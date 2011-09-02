using Gee;

namespace Gcp
{

class Diagnostic
{
	public enum Severity
	{
		NONE,
		INFO,
		WARNING,
		ERROR,
		FATAL;

		public string to_string()
		{
			switch (this)
			{
				case NONE:
					return "None";
				case INFO:
					return "Info";
				case WARNING:
					return "Warning";
				case ERROR:
					return "Error";
				default:
					return "Unknown";
			}
		}
	}

	private SourceRange[] d_ranges;
	private Severity d_severity;
	private string d_message;

	public Diagnostic(Severity      severity,
	                  SourceRange[] ranges,
	                  string        message)
	{
		d_severity = severity;
		d_ranges = ranges;
		d_message = message;
	}

	public SourceRange[] ranges
	{
		get
		{
			return d_ranges;
		}
	}

	public Severity severity
	{
		get
		{
			return d_severity;
		}
	}

	public string message
	{
		get
		{
			return d_message;
		}
	}

	public string to_markup()
	{
		string[] r = new string[d_ranges.length];

		for (int i = 0; i < d_ranges.length; ++i)
		{
			r[i] = d_ranges[i].to_string();
		}

		return "<b>%s</b> %s: %s".printf(d_severity.to_string(),
		                                 string.joinv(", ", r),
		                                 Markup.escape_text(d_message));
	}
}

}

/* vi:ex:ts=4 */
