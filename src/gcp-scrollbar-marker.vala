using Gtk;
using Gee;

namespace Gcp
{

class ScrollbarMarker
{
	public class Marker
	{
		private Gdk.RGBA d_color;
		private SourceRange d_range;

		public Marker(SourceRange range, Gdk.RGBA color)
		{
			d_color = color;
			d_range = range;
		}

		public SourceRange range
		{
			get
			{
				return d_range;
			}
		}

		public Gdk.RGBA color
		{
			get
			{
				return d_color;
			}
		}
	}

	private unowned Scrollbar? d_scrollbar;
	private LinkedList<Marker> d_markers;
	private int d_spacing;
	private int d_maxline;
	private int d_border;
	private int d_width;

	public ScrollbarMarker(Scrollbar scrollbar)
	{
		d_scrollbar = scrollbar;
		d_scrollbar.draw.connect_after(on_scrollbar_draw);

		d_markers = new LinkedList<Marker>();
		d_maxline = 0;

		d_scrollbar.style_updated.connect(on_style_updated);
		update_spacing();
	}

	public int max_line
	{
		get { return d_maxline; }

		set
		{
			d_maxline = value;
			d_scrollbar.queue_draw();
		}
	}

	public Scrollbar? scrollbar
	{
		get { return d_scrollbar; }
	}

	private void update_spacing()
	{
		StyleContext ctx = d_scrollbar.get_style_context();

		int stepper_size = UtilsC.get_style_property_int(ctx,
		                                                 "stepper-size");

		int stepper_spacing = UtilsC.get_style_property_int(ctx,
		                                                    "stepper-spacing");

		d_border = UtilsC.get_style_property_int(ctx, "trough-border");
		d_width = UtilsC.get_style_property_int(ctx, "slider-width");

		d_spacing = stepper_size + stepper_spacing;
	}

	private void on_style_updated()
	{
		update_spacing();
	}

	public void add(SourceRange range, Gdk.RGBA color)
	{
		d_markers.add(new Marker(range, color));

		d_scrollbar.queue_draw();
	}

	public void clear()
	{
		d_markers.clear();
	}

	~ScrollbarMarker()
	{
		if (d_scrollbar == null)
		{
			return;
		}

		d_scrollbar.draw.disconnect(on_scrollbar_draw);
	}

	private void draw_marker(Cairo.Context ctx,
	                         Gdk.Rectangle rect,
	                         Marker        marker)
	{
		// rect scales from line 1 to d_maxline
		SourceRange range = marker.range;
		uint height = range.end.line - range.start.line + 1;

		double scale = (double)rect.height / (double)d_maxline;

		double y = Math.round(rect.y + range.start.line * scale - 0.5) + 0.5;
		double dy = Math.fmax(1, Math.round(height * scale));

		Gdk.cairo_set_source_rgba(ctx, marker.color);
		ctx.set_line_width(1);

		if (dy > 1.5)
		{
			ctx.rectangle(rect.x + 0.5, y, rect.width - 1, dy);
			ctx.fill();
		}
		else
		{
			ctx.move_to(rect.x + 0.5, y);
			ctx.line_to(rect.x + 0.5 + rect.width - 1, y);
			ctx.stroke();
		}
	}

	private bool on_scrollbar_draw(Cairo.Context ctx)
	{
		Gdk.Rectangle range;

		d_scrollbar.get_range_rect(out range);

		// Remove stepper button sizes
		range.x += d_border;
		range.width = d_width;
		range.y += d_spacing;
		range.height -= 2 * d_spacing;

		foreach (Marker marker in d_markers)
		{
			draw_marker(ctx, range, marker);
		}

		return false;
	}
}

}

/* vi:ex:ts=4 */
