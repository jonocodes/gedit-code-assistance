namespace Gcp.C
{

class Document : Gcp.Document, SymbolBrowserSupport
{
	private TranslationUnit d_tu;
	private SymbolBrowser d_symbols;

	public Document(Gedit.Document document)
	{
		base(document);

		d_tu = new TranslationUnit();
		d_symbols = new SymbolBrowser();

		d_tu.update.connect(on_tu_update);
	}

	public SymbolBrowser symbol_browser
	{
		get
		{
			return d_symbols;
		}
	}

	public TranslationUnit translation_unit
	{
		get
		{
			return d_tu;
		}
	}

	private void visit_cursor(CX.Cursor cursor)
	{
		
	}

	private void on_tu_update()
	{
		/* Refill the symbol browser */
		d_symbols.clear();

		d_tu.with_translation_unit((tu) => {
			visit_cursor(tu.cursor);
		});
	}
}

}

/* vi:ex:ts=4 */
