namespace Gcp
{

struct SourceLocation
{
	public File file;
	public uint line;
	public uint column;

	public string to_string()
	{
		return "(%u.%u)".printf(line, column);
	}
}

}

/* vi:ex:ts=4 */
