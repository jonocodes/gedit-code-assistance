using Gee;

namespace Gcp
{

abstract class Backend : Object
{
	private ArrayList<Document> d_documents;

	public Backend()
	{
		d_documents = new ArrayList<Document>();
	}

	public abstract string[] supported_languages
	{
		get;
	}

	public Gee.List<Document> documents
	{
		owned get
		{
			return d_documents.read_only_view;
		}
	}

	protected abstract Document create_document(Gedit.Document document);

	public Document ?register(Gedit.Document ?document)
	{
		if (document == null)
		{
			return null;
		}

		Document ret = create_document(document);
		d_documents.add(ret);

		ret.changed.connect(on_document_changed);

		return ret;
	}

	protected virtual void destroy_document(Document document)
	{
		document.changed.disconnect(on_document_changed);
	}

	public virtual void unregister(Document ?document)
	{
		if (document == null)
		{
			return;
		}

		destroy_document(document);

		d_documents.remove(document);
	}

	protected virtual void on_document_changed(Document doc)
	{
	}
}

}

/* vi:ex:ts=4 */
