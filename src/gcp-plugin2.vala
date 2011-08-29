using Gee;

namespace Gcp
{

class Plugin : Gedit.Plugin
{
	private HashMap<Gedit.Window, WindowHelper> d_helpers;

	public Plugin()
	{
		GLib.Object();

		d_helpers = new HashMap<Gedit.Window, WindowHelper>(direct_hash, direct_equal);
	}

	public override void activate(Gedit.Window window)
	{
		d_helpers[window] = new WindowHelper(window);
	}

	public override void deactivate(Gedit.Window window)
	{
		d_helpers[window].deactivate();
		d_helpers.unset(window);
	}
}

}

[ModuleInit]
public GLib.Type register_gedit_plugin(TypeModule module)
{
	return typeof(Gcp.Plugin);
}

/* vi:ex:ts=4 */
