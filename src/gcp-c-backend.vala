using Gee;

namespace Gcp.C
{

class Backend : Gcp.Backend
{
	private static string[] s_langs;
	private CX.Index d_index;
	private CompileArgs d_compileArgs;
	private HashMap<File, LinkedList<Document>> d_documentMap;
	private uint d_changedId;

	static construct
	{
		s_langs = {"c", "cpp", "chdr", "objc"};
	}

	public Backend()
	{
		d_index = new CX.Index(true, false);
		d_compileArgs = new CompileArgs();

		d_compileArgs.arguments_changed.connect(on_arguments_changed);
		d_documentMap = new HashMap<File, LinkedList<Document>>(File.hash, (EqualFunc)File.equal);

		d_changedId = 0;
	}

	public unowned CX.Index index
	{
		get
		{
			return d_index;
		}
	}

	private void map_document(File file, Document doc)
	{
		if (!d_documentMap.has_key(file))
		{
			LinkedList<Document> r = new LinkedList<Document>();
			r.add(doc);

			d_documentMap[file] = r;
		}
		else
		{
			LinkedList<Document> r = d_documentMap[file];
			r.add(doc);
		}
	}

	private void unmap_document(File file, Document doc)
	{
		if (d_documentMap.has_key(file))
		{
			LinkedList<Document> r = d_documentMap[file];
			r.remove(doc);

			if (r.size == 0)
			{
				d_documentMap.unset(file);
			}
		}
	}

	protected override Gcp.Document create_document(Gedit.Document document)
	{
		Document doc = new Document(document);

		if (doc.location != null)
		{
			map_document(doc.location, doc);
			d_compileArgs.monitor(doc.location);
		}

		doc.location_changed.connect(on_location_changed);

		return doc;
	}

	public override void destroy_document(Gcp.Document document)
	{
		if (document.location != null)
		{
			unmap_document(document.location, document as Document);
			d_compileArgs.remove_monitor(document.location);
		}

		base.destroy_document(document);
	}

	private void on_location_changed(Gcp.Document document, File? previous_location)
	{
		if (previous_location != null)
		{
			unmap_document(previous_location, document as Document);
			d_compileArgs.remove_monitor(previous_location);
		}

		if (document.location != null)
		{
			map_document(document.location, document as Document);
			d_compileArgs.monitor(document.location);
		}
	}

	public override string[] supported_languages
	{
		get
		{
			return s_langs;
		}
	}

	private UnsavedFile[] unsaved_files
	{
		owned get
		{
			ArrayList<Gcp.Document> docs = new ArrayList<Gcp.Document>();

			foreach (Gcp.Document doc in documents)
			{
				if (doc.location != null && doc.text != null)
				{
					docs.add(doc);
				}
			}

			UnsavedFile[] ret = new UnsavedFile[docs.size];

			for (int i = 0; i < ret.length; ++i)
			{
				ret[i] = UnsavedFile(docs[i].location.get_path(), docs[i].text);
			}

			return ret;
		}
	}

	private void parse(Document doc, string[]? args)
	{
		doc.translation_unit.parse(d_index,
		                           doc.location.get_path(),
		                           args,
		                           unsaved_files);

		doc.tainted = false;
	}

	private void reparse()
	{
		UnsavedFile[] uf = unsaved_files;

		foreach (Gcp.Document doc in documents)
		{
			if (!doc.tainted)
			{
				continue;
			}

			Document d = doc as Document;
			d.translation_unit.reparse(uf);

			d.tainted = false;
		}
	}

	private void on_arguments_changed(File file)
	{
		if (!d_documentMap.has_key(file))
		{
			return;
		}

		string[] ?args = d_compileArgs[file];

		foreach (Document doc in d_documentMap[file])
		{
			parse(doc, args);
		}
	}

	protected override void on_document_changed(Gcp.Document doc)
	{
		base.on_document_changed(doc);

		Document d = doc as Document;

		d.translation_unit.tainted = true;

		if (d_changedId != 0)
		{
			Source.remove(d_changedId);
		}

		d_changedId = Timeout.add(200, () => {
			d_changedId = 0;

			reparse();

			return false;
		});
	}
}

}

/* vi:ex:ts=4 */
