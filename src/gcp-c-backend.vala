namespace Gcp.C
{

class Backend : Gcp.Backend
{
	private static string[] s_langs;
	private CX.Index d_index;

	static construct
	{
		s_langs = {"c", "cpp", "chdr", "objc"};
	}

	public Backend()
	{
		d_index = new CX.Index(true, false);
	}

	public unowned CX.Index index
	{
		get
		{
			return d_index;
		}
	}

	public CX.TranslationUnit ?create_tu_from_cache(File source)
	{
		string[] ?args;

		args = CompileArgs.from_cache(source);

		if (args != null)
		{
			return new CX.TranslationUnit(d_index, source.get_path(), args);
		}
		else
		{
			return null;
		}
	}

	public async CX.TranslationUnit ?create_tu(File source)
	{
		string[] ?args = null;

		yield async_in_thread(() => {
			try
			{
				args = CompileArgs.guess(source);
			}
			catch {}
		});

		if (args != null)
		{
			return new CX.TranslationUnit(d_index,
			                              source.get_path(),
			                              args);
		}
		else
		{
			return null;
		}
	}

	protected override Gcp.Document create_document(Gedit.Document document)
	{
		return new Document(this, document);
	}

	public override string[] supported_languages
	{
		get
		{
			return s_langs;
		}
	}

	
}

}

/* vi:ex:ts=4 */
