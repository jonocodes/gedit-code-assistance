namespace Gcp
{

class Document : Object
{
	private Gedit.Document d_document;
	private bool d_untitled;

	public Document(Gedit.Document document)
	{
		d_document = document;

		d_document.saved.connect(on_document_saved);
		d_document.loaded.connect(on_document_loaded);

		d_untitled = d_document.is_untitled();
	}

	~Document()
	{
		d_document.saved.disconnect(on_document_saved);
		d_document.loaded.disconnect(on_document_loaded);
	}

	public Gedit.Document document
	{
		get
		{
			return d_document;
		}
	}

	protected virtual void on_document_saved()
	{
	}

	protected virtual void on_document_loaded()
	{
	}
}

}

/* vi:ex:ts=4 */
