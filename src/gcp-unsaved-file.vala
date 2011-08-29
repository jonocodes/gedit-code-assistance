namespace Gcp
{

struct UnsavedFile
{
	public string filename;
	public string contents;
	public ulong length;

	public UnsavedFile(string f, string c)
	{
		filename = f;
		contents = c;

		length = contents.length;
	}
}

}
