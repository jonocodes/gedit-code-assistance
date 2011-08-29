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

	protected abstract Document create_document(Gedit.Document document);

	public Document ?register(Gedit.Document ?document)
	{
		if (document == null)
		{
			return null;
		}

		Document ret = create_document(document);

		d_documents.add(ret);
		return ret;
	}

	public virtual void unregister(Document ?document)
	{
		if (document == null)
		{
			return;
		}

		d_documents.remove(document);
	}
}

}

/* vi:ex:ts=4 */
