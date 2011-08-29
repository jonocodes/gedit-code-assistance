using Gtk;

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
			d_backend.unregister(d_document);
		}

		d_backend = null;
		d_document = null;
	}

	private void register_backend(Backend backend)
	{
		d_backend = backend;

		if (d_view.buffer != null)
		{
			d_document = d_backend.register(d_view.buffer as Gedit.Document);
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
