using Gee;

namespace Gcp
{

class WindowHelper
{
	private unowned Gedit.Window d_window;
	private HashMap<Gedit.View, Gcp.View> d_views;

	public WindowHelper(Gedit.Window window)
	{
		d_window = window;

		d_views = new HashMap<Gedit.View, Gcp.View>(direct_hash, direct_equal);

		d_window.tab_added.connect(on_tab_added);
		d_window.tab_removed.connect(on_tab_removed);

		foreach (Gedit.View view in d_window.get_views())
		{
			register_view(view);
		}
	}

	public void deactivate()
	{
		d_window.tab_added.disconnect(on_tab_added);
		d_window.tab_removed.disconnect(on_tab_removed);

		foreach (var key in d_views.keys)
		{
			d_views[key].deactivate();
		}

		d_views = null;
		d_window = null;
	}

	private void register_view(Gedit.View view)
	{
		d_views[view] = new Gcp.View(view);
	}

	private void unregister_view(Gedit.View view)
	{
		d_views[view].deactivate();
		d_views.unset(view);
	}

	private void on_tab_added(Gedit.Tab tab)
	{
		register_view(tab.get_view());
	}

	private void on_tab_removed(Gedit.Tab tab)
	{
		unregister_view(tab.get_view());
	}
}

}

/* vi:ex:ts=4 */
