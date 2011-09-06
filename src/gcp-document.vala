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

	public static string error_mark_category
	{
		get
		{
			return "Gcp.Document.ErrorCategory";
		}
	}

	public static string warning_mark_category
	{
		get
		{
			return "Gcp.Document.WarningCategory";
		}
	}

	public static string info_mark_category
	{
		get
		{
			return "Gcp.Document.InfoCategory";
		}
	}

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
		d_document.saved.connect(on_document_saved);

		d_location = null;

		update_location();

		DiagnosticSupport diag = this as DiagnosticSupport;

		if (diag != null)
		{
			diag.updated.connect(on_diagnostic_updated);
		}
	}

	private void remove_marks()
	{
		TextIter start;
		TextIter end;

		d_document.get_bounds(out start, out end);
		d_document.remove_source_marks(start, end, info_mark_category);

		d_document.get_bounds(out start, out end);
		d_document.remove_source_marks(start, end, warning_mark_category);

		d_document.get_bounds(out start, out end);
		d_document.remove_source_marks(start, end, error_mark_category);
	}

	~Document()
	{
		d_document.modified_changed.disconnect(on_document_modified_changed);
		d_document.notify["location"].disconnect(on_location_changed);

		d_document.changed.disconnect(on_document_changed);
		d_document.saved.disconnect(on_document_saved);

		DiagnosticSupport diag = this as DiagnosticSupport;

		if (diag != null)
		{
			diag.updated.disconnect(on_diagnostic_updated);

			remove_marks();
		}
	}

	private bool source_location(SourceLocation location, out TextIter iter)
	{
		d_document.get_iter_at_line(out iter, location.line - 1);

		if (iter.get_line() != location.line - 1)
		{
			return false;
		}

		if (location.column > 1)
		{
			if (!iter.forward_chars(location.column - 1))
			{
				return false;
			}

			return iter.get_line() == location.line - 1;
		}
		else
		{
			return true;
		}
	}

	public bool source_range(SourceRange range, out TextIter start, out TextIter end)
	{
		return source_location(range.start, out start) &&
		       source_location(range.end, out end);
	}

	public static string? mark_category_for_severity(Diagnostic.Severity severity)
	{
		switch (severity)
		{
			case Diagnostic.Severity.WARNING:
				return warning_mark_category;
			case Diagnostic.Severity.ERROR:
			case Diagnostic.Severity.FATAL:
				return error_mark_category;
			case Diagnostic.Severity.INFO:
				return info_mark_category;
			default:
				return null;
		}
	}

	private void mark_diagnostic_range(Diagnostic diagnostic,
	                                   TextIter   start,
	                                   TextIter   end)
	{
		DiagnosticSupport sup = this as DiagnosticSupport;

		TextTag? tag = sup.tags[diagnostic.severity];
		string? category = mark_category_for_severity(diagnostic.severity);

		d_document.apply_tag(tag, start, end);

		TextIter m = start;

		if (!m.starts_line())
		{
			m.set_line_offset(0);
		}

		while (category != null && m.compare(end) <= 0)
		{
			bool alreadyhas = false;

			foreach (GtkSource.Mark mark in d_document.get_source_marks_at_iter(m, category))
			{
				if (mark.get_data<Diagnostic>("Gcp.Document.MarkDiagnostic") == diagnostic)
				{
					alreadyhas = true;
					break;
				}
			}

			if (!alreadyhas)
			{
				GtkSource.Mark mark = d_document.create_source_mark(null,
				                                                    category,
				                                                    m);

				mark.set_data("Gcp.Document.MarkDiagnostic", diagnostic);
			}

			if (!m.forward_line())
			{
				break;
			}
		}
	}

	private void mark_diagnostic(Diagnostic diagnostic)
	{
		TextIter start;
		TextIter end;

		DiagnosticSupport sup = this as DiagnosticSupport;
		TextTag? tag = sup.tags[diagnostic.severity];
		string? category = mark_category_for_severity(diagnostic.severity);

		for (uint i = 0; i < diagnostic.ranges.length; ++i)
		{
			if (!source_range(diagnostic.ranges[i], out start, out end))
			{
				continue;
			}

			mark_diagnostic_range(diagnostic, start, end);
		}

		if (source_location(diagnostic.location, out start))
		{
			end = start;

			if (!start.ends_line())
			{
				end.forward_char();
			}

			mark_diagnostic_range(diagnostic, start, end);

			d_document.apply_tag(sup.tags.location_tag, start, end);
		}

		for (uint i = 0; i < diagnostic.fixits.length; ++i)
		{
			SourceRange r = diagnostic.fixits[i].range;

			if (source_range(r, out start, out end))
			{
				d_document.apply_tag(sup.tags.fixit_tag, start, end);
			}
		}
	}

	private void on_diagnostic_updated(DiagnosticSupport diagnostic)
	{
		TextIter start;
		TextIter end;

		d_document.get_bounds(out start, out end);

		d_document.remove_tag(diagnostic.tags.error_tag, start, end);
		d_document.remove_tag(diagnostic.tags.warning_tag, start, end);
		d_document.remove_tag(diagnostic.tags.info_tag, start, end);
		d_document.remove_tag(diagnostic.tags.location_tag, start, end);
		d_document.remove_tag(diagnostic.tags.fixit_tag, start, end);

		remove_marks();

		foreach (Diagnostic diag in diagnostic.diagnostics)
		{
			mark_diagnostic(diag);
		}
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
			emit_changed();
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

	private void on_document_saved()
	{
		emit_changed();
	}
}

}

/* vi:ex:ts=4 */
