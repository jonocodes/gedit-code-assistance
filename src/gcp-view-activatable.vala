using Gtk;
using GtkSource;

namespace Gcp
{

class ViewActivatable : GLib.Object, Gedit.ViewActivatable
{
	public Gedit.View view {get; set;}

	private Buffer d_buffer;
	private Backend d_backend;
	private Document d_document;

	public void activate()
	{
		view.notify["buffer"].connect(on_notify_buffer);

		connect_buffer(view.buffer as Buffer);
	}

	public void deactivate()
	{
		view.notify["buffer"].disconnect(on_notify_buffer);

		disconnect_buffer();
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

	private void connect_buffer(Buffer buffer)
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
			d_backend.unregister(d_document);
		}

		d_backend = null;
		d_document = null;
	}

	private void register_backend(Backend backend)
	{
		d_backend = backend;

		if (view.buffer != null)
		{
			d_document = d_backend.register(view.buffer as Gedit.Document);
		}
		else
		{
			d_document = null;
		}
	}

	private void on_notify_buffer()
	{
		disconnect_buffer();
		connect_buffer(view.buffer as Gedit.Document);
	}

	private void on_notify_language()
	{
		update_backend();
	}
}

}

/* vi:ex:ts=4 */
