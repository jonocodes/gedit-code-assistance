using Gtk;

namespace Gcp
{

class Document : GLib.Object
{
	private Gedit.Document d_document;
	private bool d_untitled;
	private bool d_modified;
	private string? d_text;
	private File? d_location;
	private bool d_tainted;

	public signal void location_changed(File? previous_location);
	public signal void changed();

	public Document(Gedit.Document document)
	{
		d_document = document;

		d_untitled = d_document.is_untitled();
		d_modified = false;
		d_text = null;

		update_modified();

		d_document.modified_changed.connect(on_document_modified_changed);
		d_document.changed.connect(on_document_changed);
		d_document.notify["location"].connect(on_location_changed);

		d_location = null;

		update_location();
	}

	~Document()
	{
		d_document.modified_changed.disconnect(on_document_modified_changed);
		d_document.notify["location"].disconnect(on_location_changed);
	}

	private void set_location(File? location)
	{
		if (location == d_location)
		{
			return;
		}

		File? prev = d_location;
		d_location = location;

		if ((prev == null) != (d_location == null))
		{
			location_changed(prev);
		}
		else if (prev != null && !prev.equal(d_location))
		{
			location_changed(prev);
		}
	}

	private void update_location()
	{
		if (document.is_untitled())
		{
			set_location(null);
			return;
		}

		if (!document.is_local())
		{
			set_location(null);
			return;
		}

#if WITH_GEDIT3
		File ?location = document.location;
#else
		File? location = File.new_for_uri(document.get_uri());
#endif

		set_location(location);
	}

	private void update_modified()
	{
		if (d_modified == d_document.get_modified())
		{
			return;
		}

		d_text = null;
		d_modified = !d_modified;

		if (d_modified)
		{
			update_text();
		}
		else
		{
			changed();
		}
	}

	public virtual bool tainted
	{
		get
		{
			return d_tainted;
		}
		set
		{
			d_tainted = false;
		}
	}

	protected void emit_changed()
	{
		d_tainted = true;

		changed();
	}

	private void update_text()
	{
		TextIter start;
		TextIter end;

		d_document.get_bounds(out start, out end);
		d_text = d_document.get_text(start, end, true);

		emit_changed();
	}

	public File? location
	{
		get
		{
			return d_location;
		}
	}

	public unowned string text
	{
		get
		{
			return d_text;
		}
	}

	public bool is_modified
	{
		get
		{
			return d_modified;
		}
	}

	public Gedit.Document document
	{
		get
		{
			return d_document;
		}
	}

	private void on_document_changed()
	{
		if (d_modified)
		{
			update_text();
		}
	}

	private void on_document_modified_changed()
	{
		update_modified();
	}

	private void on_location_changed()
	{
		update_location();
	}
}

}

/* vi:ex:ts=4 */
