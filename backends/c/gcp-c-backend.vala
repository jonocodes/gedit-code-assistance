/*
 * This file is part of gedit-code-assistant.
 *
 * Copyright (C) 2011 - Jesse van den Kieboom
 *
 * gedit-code-assistant is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * gedit-code-assistant is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gedit-code-assistant.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;

namespace Gcp.C
{

class Backend : Gcp.BackendImplementation
{
	private CX.Index d_index;
	private CompileArgs d_compileArgs;
	private HashMap<File, LinkedList<Document>> d_documentMap;
	private uint d_changedId;

	construct
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

	private UnsavedFile[] unsaved_files
	{
		owned get
		{
			ArrayList<Gcp.Document> docs = new ArrayList<Gcp.Document>();

			foreach (Gcp.Document doc in this)
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

	private void parse(Document doc, string[] args)
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

		foreach (Gcp.Document doc in this)
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

		if (args == null)
		{
			args = new string[] {};
		}

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

		d_changedId = Timeout.add(500, () => {
			d_changedId = 0;

			reparse();

			return false;
		});
	}
}

}

[ModuleInit]
public void peas_register_types (TypeModule module)
{
	Peas.ObjectModule mod = module as Peas.ObjectModule;

	mod.register_extension_type (typeof (Gcp.Backend),
	                             typeof (Gcp.C.Backend));
}


/* vi:ex:ts=4 */
