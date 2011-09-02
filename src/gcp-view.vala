using Gtk;
using GtkSource;

namespace Gcp
{

class View
{
	private unowned Gedit.View d_view;

	private Gedit.Document d_buffer;
	private Backend d_backend;
	private Document d_document;

	public View(Gedit.View view)
	{
		d_view = view;

		d_view.notify["buffer"].connect(on_notify_buffer);

		connect_buffer(d_view.buffer as Gedit.Document);
	}

	public void deactivate()
	{
		d_view.notify["buffer"].disconnect(on_notify_buffer);

		disconnect_buffer();

		d_view = null;
	}

	private void disconnect_buffer()
	{
		if (d_buffer == null)
		{
			return;
		}

		d_buffer.notify["language"].disconnect(on_notify_language);
		d_buffer = null;
	}

	private void connect_buffer(Gedit.Document buffer)
	{
		d_buffer = buffer;

		if (d_buffer == null)
		{
			return;
		}

		d_buffer.notify["language"].connect(on_notify_language);
		update_backend();
	}

	private void update_backend()
	{
		/* Update the backend according to the current language on the buffer */
		var lang = d_buffer.language;
		Backend backend = null;

		if (lang != null)
		{
			backend = BackendManager.instance[lang.id];
		}

		unregister_backend();
		register_backend(backend);
	}

	private void unregister_backend()
	{
		if (d_backend == null)
		{
			return;
		}

		if (d_document != null)
		{
			if (d_document is DiagnosticSupport)
			{
				d_view.query_tooltip.disconnect(on_view_query_tooltip);
			}

			d_backend.unregister(d_document);
		}

		d_backend = null;
		d_document = null;
	}

	private string? format_diagnostics(Diagnostic[] diagnostics)
	{
		if (diagnostics.length == 0)
		{
			return null;
		}

		string[] markup = new string[diagnostics.length];

		for (int i = 0; i < diagnostics.length; ++i)
		{
			markup[i] = diagnostics[i].to_markup();
		}

		return string.joinv("\n", markup);
	}

	private string? on_diagnostic_tooltip(MarkAttributes attributes,
	                                      Mark           mark)
	{
		TextIter iter;

		Diagnostic? diagnostic = mark.get_data("Gcp.Document.MarkDiagnostic");

		if (diagnostic == null)
		{
			d_view.buffer.get_iter_at_mark(out iter, mark);
			uint line = iter.get_line() + 1;

			DiagnosticSupport diag = d_document as DiagnosticSupport;

			return format_diagnostics(diag.find_at_line(line));
		}
		else
		{
			return diagnostic.to_markup();
		}
	}

	private bool on_view_query_tooltip(int x, int y, bool keyboard_mode, Tooltip tooltip)
	{
		int bx;
		int by;

		d_view.window_to_buffer_coords(Gtk.TextWindowType.WIDGET, x, y, out bx, out by);

		TextIter iter;
		d_view.get_iter_at_position(out iter, null, bx, by);

		uint line = iter.get_line() + 1;
		uint col = iter.get_line_offset() + 1;

		DiagnosticSupport diag = d_document as DiagnosticSupport;

		string? s = format_diagnostics(diag.find_at(line, col));

		if (s == null)
		{
			return false;
		}

		tooltip.set_markup(s);
		return true;
	}

	private void register_backend(Backend? backend)
	{
		d_backend = backend;

		if (backend == null)
		{
			return;
		}

		if (d_view.buffer != null)
		{
			d_document = d_backend.register(d_view.buffer as Gedit.Document);

			DiagnosticSupport diag = d_document as DiagnosticSupport;

			if (diag != null)
			{
				MarkAttributes attr;

				// Error
				attr = new MarkAttributes();

				attr.set_background({1, 0, 0, 0.2});
				attr.set_stock_id(Gtk.Stock.DIALOG_ERROR);

				attr.query_tooltip_markup.connect(on_diagnostic_tooltip);

				d_view.set_mark_attributes(Document.error_mark_category, attr, 0);

				// Warning
				attr = new MarkAttributes();

				attr.set_background({1, 0.65, 0, 0.2});
				attr.set_stock_id(Gtk.Stock.DIALOG_WARNING);

				attr.query_tooltip_markup.connect(on_diagnostic_tooltip);

				d_view.set_mark_attributes(Document.warning_mark_category, attr, 0);

				// Info
				attr = new MarkAttributes();

				attr.set_background({0, 0, 0.4, 0.2});
				attr.set_stock_id(Gtk.Stock.DIALOG_INFO);

				attr.query_tooltip_markup.connect(on_diagnostic_tooltip);

				d_view.set_mark_attributes(Document.info_mark_category, attr, 0);

				d_view.query_tooltip.connect(on_view_query_tooltip);
			}
		}
		else
		{
			d_document = null;
		}
	}

	private void on_notify_buffer()
	{
		disconnect_buffer();
		connect_buffer(d_view.buffer as Gedit.Document);
	}

	private void on_notify_language()
	{
		update_backend();
	}
}

}

/* vi:ex:ts=4 */
