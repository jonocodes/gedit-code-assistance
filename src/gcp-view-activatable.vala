using Gtk;

namespace Gcp
{

class ViewActivatable : GLib.Object, Gedit.ViewActivatable
{
	public Gedit.View view {get; set;}

	private Gcp.View d_view;

	public void activate()
	{
		d_view = new Gcp.View(view);
	}

	public void deactivate()
	{
		d_view.deactivate();
		d_view = null;
	}
}

}

/* vi:ex:ts=4 */
