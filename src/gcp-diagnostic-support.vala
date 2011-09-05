using Gee;

namespace Gcp
{

interface DiagnosticSupport : Document
{
	public abstract DiagnosticTags tags { get; set; }

	public signal void updated();

	public abstract Diagnostic[] diagnostics { get; }

	public Diagnostic[] find_at(uint line, uint column)
	{
		LinkedList<Diagnostic> ret = new LinkedList<Diagnostic>();

		foreach (Diagnostic d in diagnostics)
		{
			bool foundit = false;

			foreach (SourceRange r in d.ranges)
			{
				if (r.contains(line, column))
				{
					ret.add(d);
					foundit = true;
					break;
				}
			}

			if (!foundit && d.location.line == line && d.location.column == column)
			{
				ret.add(d);
			}
		}

		return ret.to_array();
	}

	public Diagnostic[] find_at_line(uint line)
	{
		LinkedList<Diagnostic> ret = new LinkedList<Diagnostic>();

		foreach (Diagnostic d in diagnostics)
		{
			bool foundit = false;

			foreach (SourceRange r in d.ranges)
			{
				if (r.contains_line(line))
				{
					ret.add(d);
					foundit = true;

					break;
				}
			}

			if (!foundit && d.location.line == line)
			{
				ret.add(d);
			}
		}

		return ret.to_array();
	}
}

}

/* vi:ex:ts=4 */
