namespace Gcp
{

struct SourceRange
{
	public SourceLocation start;
	public SourceLocation end;

	public bool contains(uint line, uint column)
	{
		return (start.line < line || (start.line == line && start.column <= column)) &&
		       (end.line > line || (end.line == line && end.column >= column));
	}

	public bool contains_line(uint line)
	{
		return start.line <= line && end.line >= line;
	}

	public string to_string()
	{
		if (start.line == end.line && end.column - start.column <= 1)
		{
			return start.to_string();
		}

		return "%s-%s".printf(start.to_string(), end.to_string());
	}
}

}

/* vi:ex:ts=4 */
