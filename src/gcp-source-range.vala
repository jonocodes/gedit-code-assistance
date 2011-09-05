namespace Gcp
{

class SourceRange
{
	private SourceLocation d_start;
	private SourceLocation d_end;

	public SourceRange(SourceLocation start, SourceLocation end)
	{
		d_start = start;
		d_end = end;
	}

	public SourceLocation start
	{
		get { return d_start; }
	}

	public SourceLocation end
	{
		get { return d_end; }
	}

	public bool contains(uint line, uint column)
	{
		return (d_start.line < line || (d_start.line == line && d_start.column <= column)) &&
		       (d_end.line > line || (d_end.line == line && d_end.column >= column));
	}

	public bool contains_line(uint line)
	{
		return d_start.line <= line && d_end.line >= line;
	}

	public string to_string()
	{
		if (d_start.line == d_end.line && d_end.column - d_start.column <= 1)
		{
			return d_start.to_string();
		}

		return "%s-%s".printf(d_start.to_string(), d_end.to_string());
	}
}

}

/* vi:ex:ts=4 */
