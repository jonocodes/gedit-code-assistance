namespace Gcp
{

class SourceLocation
{
	private File? d_file;
	private int d_line;
	private int d_column;

	public SourceLocation(File? file, int line, int column)
	{
		d_file = file;
		d_line = line;
		d_column = column;
	}

	public File? file
	{
		get { return d_file; }
	}

	public int line
	{
		get { return d_line; }
	}

	public int column
	{
		get { return d_column; }
	}

	public string to_string()
	{
		return "(%d.%d)".printf(line, column);
	}
}

}

/* vi:ex:ts=4 */
