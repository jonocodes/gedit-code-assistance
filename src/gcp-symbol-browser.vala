namespace Gcp
{

class SymbolBrowser : Gtk.TreeStore
{
	private bool d_tainted;

	public SymbolBrowser()
	{
		d_tainted = false;
	}

	public bool tainted
	{
		get
		{
			return d_tainted;
		}
		set
		{
			d_tainted = value;
		}
	}

	public void begin_update()
	{
	}

	public void end_update()
	{
		d_tainted = false;
	}
}

}

/* vi:ex:ts=4 */
