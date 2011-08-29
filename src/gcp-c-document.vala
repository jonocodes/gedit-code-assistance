namespace Gcp.C
{

class Document : Gcp.Document
{
	private unowned Backend d_backend;
	private CX.TranslationUnit d_tu;
	private File d_location;

	public Document(Backend backend, Gedit.Document document)
	{
		base(document);

		d_backend = backend;

		create_tu();
	}

	private void create_tu()
	{
		if (document.is_untitled())
		{
			d_tu = null;
			return;
		}

		File ?location = document.location;

		if (location == null)
		{
			d_tu = null;
			return;
		}

		if (!document.is_local())
		{
			d_tu = null;
			return;
		}

		if (!location.equal(d_location))
		{
			d_backend.create_tu(location);
			d_location = location;
		}
	}

	protected override void on_document_saved()
	{
		create_tu();
	}

	protected override void on_document_loaded()
	{
		create_tu();
	}
}

}

/* vi:ex:ts=4 */
