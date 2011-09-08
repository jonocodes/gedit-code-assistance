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

using Gtk;
using GtkSource;
using Gee;

namespace Gcp
{

class View
{
	private unowned Gedit.View d_view;

	private Gedit.Document d_buffer;
	private Backend d_backend;
	private Document d_document;
	private DiagnosticTags d_tags;
	private ScrollbarMarker d_scrollbarMarker;
	private HashMap<TextMark, Gdk.RGBA?> d_diagnosticsAtEnd;
	private Diagnostic[] d_cursorDiagnostics;
	private DiagnosticMessage? d_cursorDiagnosticMessage;

	public View(Gedit.View view)
	{
		d_view = view;

		d_view.notify["buffer"].connect(on_notify_buffer);
		d_view.draw.connect_after(on_view_draw);

		d_tags = new DiagnosticTags(d_view);
		d_diagnosticsAtEnd = new HashMap<TextMark, Gdk.RGBA?>();

		connect_buffer(d_view.buffer as Gedit.Document);

		ScrolledWindow? sw = d_view.parent as ScrolledWindow;

		if (sw != null)
		{
			d_scrollbarMarker = new ScrollbarMarker(sw.get_vscrollbar() as Scrollbar);
		}
	}

	public void deactivate()
	{
		d_view.notify["buffer"].disconnect(on_notify_buffer);
		d_view.draw.disconnect(on_view_draw);

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
		d_buffer.changed.disconnect(on_buffer_changed);
		d_buffer.mark_set.disconnect(on_buffer_mark_set);

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
		d_buffer.changed.connect(on_buffer_changed);
		d_buffer.mark_set.connect(on_buffer_mark_set);

		update_backend();
	}

	private void on_buffer_changed()
	{
		d_scrollbarMarker.max_line = d_buffer.get_line_count();
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
				d_view.set_show_line_marks(false);

				d_buffer.cursor_moved.disconnect(on_cursor_moved);
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
			markup[i] = diagnostics[i].to_markup(false);
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
			return diagnostic.to_markup(false);
		}
	}

	private bool on_view_query_tooltip(int x,
	                                   int y,
	                                   bool keyboard_mode,
	                                   Tooltip tooltip)
	{
		int bx;
		int by;

		d_view.window_to_buffer_coords(Gtk.TextWindowType.WIDGET,
		                               x,
		                               y,
		                               out bx,
		                               out by);

		TextIter iter;
	
		d_view.get_iter_at_location(out iter, bx, by);

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

				diag.tags = d_tags;
				diag.updated.connect(on_diagnostic_updated);

				// Error
				attr = new MarkAttributes();
				attr.set_gicon(new ThemedIcon.with_default_fallbacks("dialog-error-symbolic"));
				attr.query_tooltip_markup.connect(on_diagnostic_tooltip);
				d_view.set_mark_attributes(Document.error_mark_category,
				                           attr,
				                           0);

				// Warning
				attr = new MarkAttributes();
				attr.set_gicon(new ThemedIcon.with_default_fallbacks("dialog-warning-symbolic"));
				attr.query_tooltip_markup.connect(on_diagnostic_tooltip);
				d_view.set_mark_attributes(Document.warning_mark_category,
				                           attr,
				                           0);

				// Info
				attr = new MarkAttributes();
				attr.set_gicon(new ThemedIcon.with_default_fallbacks("dialog-information-symbolic"));
				attr.query_tooltip_markup.connect(on_diagnostic_tooltip);
				d_view.set_mark_attributes(Document.info_mark_category,
				                           attr,
				                           0);

				d_view.query_tooltip.connect(on_view_query_tooltip);

				d_view.set_show_line_marks(true);

				d_buffer.cursor_moved.connect(on_cursor_moved);
			}
		}
		else
		{
			d_document = null;
		}
	}

	private bool diagnostic_is_at_end(SourceLocation location)
	{
		TextIter iter;

		d_buffer.get_iter_at_line(out iter, location.line - 1);
		iter.forward_chars(location.column - 1);

		if (iter.get_line() != location.line - 1)
		{
			return false;
		}

		return iter.ends_line();
	}

	private void add_diagnostic_at_end(SourceLocation location,
	                                   Gdk.RGBA       color)
	{
		TextIter iter;

		d_buffer.get_iter_at_line(out iter, location.line - 1);

		TextMark mark = d_buffer.create_mark(null, iter, false);
		d_diagnosticsAtEnd[mark] = color;
	}

	private void on_diagnostic_updated(DiagnosticSupport diagnostics)
	{
		d_scrollbarMarker.clear();

		DiagnosticColors colors;

		colors = new DiagnosticColors(d_scrollbarMarker.scrollbar.get_style_context());

		DiagnosticColors mixed;

		mixed = new DiagnosticColors(d_scrollbarMarker.scrollbar.get_style_context());
		mixed.mix_in_widget(d_view);

		MapIterator<TextMark, Gdk.RGBA?> it = d_diagnosticsAtEnd.map_iterator();

		while (it.next())
		{
			d_buffer.delete_mark(it.get_key());
		}

		d_diagnosticsAtEnd.clear();

		foreach (Diagnostic d in diagnostics.diagnostics)
		{
			Gdk.RGBA color = colors[d.severity];
			Gdk.RGBA mix = mixed[d.severity];

			foreach (SourceRange range in d.ranges)
			{
				d_scrollbarMarker.add(range, color);

				if (range.start.line == range.end.line &&
				    range.start.column == range.end.column)
				{
					if (diagnostic_is_at_end(range.start))
					{
						add_diagnostic_at_end(range.start, mix);
					}
				}
			}

			d_scrollbarMarker.add(new SourceRange(d.location, d.location), color);

			if (diagnostic_is_at_end(d.location))
			{
				add_diagnostic_at_end(d.location, mix);
			}
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

	private bool on_view_draw(Cairo.Context ctx)
	{
		if (d_diagnosticsAtEnd.size == 0)
		{
			return false;
		}

		var window = d_view.get_window(Gtk.TextWindowType.TEXT);

		if (!Gtk.cairo_should_draw_window(ctx, window))
		{
			return false;
		}

		MapIterator<TextMark, Gdk.RGBA?> it = d_diagnosticsAtEnd.map_iterator();

		Gtk.cairo_transform_to_window(ctx, d_view, window);
		Gdk.Rectangle rect;
		TextIter start;
		TextIter end;

		d_view.get_visible_rect(out rect);
		d_view.get_line_at_y(out start, rect.y, null);
		start.backward_line();

		d_view.get_line_at_y(out end, rect.y + rect.height, null);
		end.forward_line();

		int window_width = window.get_width();

		while (it.next())
		{
			TextIter iter;

			d_view.buffer.get_iter_at_mark(out iter, it.get_key());

			if (!iter.in_range(start, end) && !iter.equal(end))
			{
				continue;
			}

			if (!iter.ends_line())
			{
				if (iter.forward_visible_line())
				{
					iter.backward_char();
				}
			}

			int y;
			int height;

			int wy;
			int wx;

			Gdk.Rectangle irect;

			d_view.get_line_yrange(iter, out y, out height);
			d_view.get_iter_location(iter, out irect);

			d_view.buffer_to_window_coords(Gtk.TextWindowType.TEXT,
			                               irect.x + irect.width,
			                               y,
			                               out wx,
			                               out wy);

			ctx.rectangle(wx,
			              wy,
			              window_width - wx,
			              height);

			Gdk.cairo_set_source_rgba(ctx, it.get_value());
			ctx.fill();
		}

		return false;
	}

	private void on_buffer_mark_set(TextIter location, TextMark mark)
	{
		if (d_diagnosticsAtEnd.has_key(mark) && !location.starts_line())
		{
			location.set_line_offset(0);
			d_buffer.move_mark(mark, location);
		}
	}

	private bool same_diagnostics(Diagnostic[]? first, Diagnostic[]? second)
	{
		if (first == second)
		{
			return true;
		}

		if (first == null || second == null)
		{
			return false;
		}

		if (first.length != second.length)
		{
			return false;
		}

		for (int i = 0; i < first.length; ++i)
		{
			if (first[i] != second[i])
			{
				return false;
			}
		}

		return true;
	}

	private void on_cursor_moved()
	{
		// Check if we moved in or out of a diagnostic
		DiagnosticSupport? diag = d_document as DiagnosticSupport;

		if (diag == null)
		{
			return;
		}

		TextIter iter;

		d_buffer.get_iter_at_mark(out iter, d_buffer.get_insert());

		uint line = (uint)iter.get_line();
		uint column = (uint)iter.get_line_offset();

		Diagnostic[] diagnostics = diag.find_at(line + 1, column + 1);

		if (same_diagnostics(diagnostics, d_cursorDiagnostics))
		{
			return;
		}

		if (d_cursorDiagnosticMessage != null)
		{
			d_cursorDiagnosticMessage.destroy();
		}

		d_cursorDiagnosticMessage = new DiagnosticMessage(d_view, diagnostics);

		d_cursorDiagnosticMessage.destroy.connect(() => {
			d_cursorDiagnosticMessage = null;
		});

		d_cursorDiagnosticMessage.show();
		d_cursorDiagnostics = diagnostics;
	}
}

}

/* vi:ex:ts=4 */
