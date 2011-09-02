using Gee;

namespace Gcp
{

interface DiagnosticSupport : Document
{
	public signal void updated();

	public abstract uint num_diagnostics { get; }
	public abstract Diagnostic? diagnostic(uint i);

	public Diagnostic[] find_at(uint line, uint column)
	{
		LinkedList<Diagnostic> ret = new LinkedList<Diagnostic>();

		for (uint i = 0; i < num_diagnostics; ++i)
		{
			Diagnostic? d = diagnostic(i);

			foreach (SourceRange r in d.ranges)
			{
				if (r.contains(line, column))
				{
					ret.add(d);
					break;
				}
			}
		}

		return ret.to_array();
	}

	public Diagnostic[] find_at_line(uint line)
	{
		LinkedList<Diagnostic> ret = new LinkedList<Diagnostic>();

		for (uint i = 0; i < num_diagnostics; ++i)
		{
			Diagnostic? d = diagnostic(i);

			foreach (SourceRange r in d.ranges)
			{
				if (r.contains_line(line))
				{
					ret.add(d);
					break;
				}
			}
		}

		return ret.to_array();
	}
}

}

/* vi:ex:ts=4 */
