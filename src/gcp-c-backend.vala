namespace Gcp.C
{

class Backend : Gcp.Backend
{
	private static string[] s_langs;
	private CX.Index d_index;
	private CompileArgs d_compileArgs;

	static construct
	{
		s_langs = {"c", "cpp", "chdr", "objc"};
	}

	public Backend()
	{
		d_index = new CX.Index(true, false);
		d_compileArgs = new CompileArgs();
	}

	public unowned CX.Index index
	{
		get
		{
			return d_index;
		}
	}

	public async CX.TranslationUnit ?create_tu(File source, Cancellable ?cancellable = null)
	{
		string[] ?args = null;
		CX.TranslationUnit ret = null;

		yield async_in_thread(() => {
			try
			{
				args = d_compileArgs.guess(source, cancellable);
			}
			catch {}

			if (args != null)
			{
				ret = new CX.TranslationUnit(d_index,
				                             source.get_path(),
				                             args);
			}
		});

		if (cancellable != null && cancellable.is_cancelled())
		{
			return null;
		}

		return (owned)ret;
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
