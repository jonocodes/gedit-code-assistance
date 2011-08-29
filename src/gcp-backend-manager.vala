using Gee;

namespace Gcp
{

class BackendManager
{
	private static BackendManager s_instance;

	private HashMap<string, Backend> d_backends;

	private BackendManager()
	{
		d_backends = new HashMap<string, Backend>();

		register_backends();
	}

	private void register_backend(Backend backend)
	{
		foreach (string lang in backend.supported_languages)
		{
			d_backends[lang] = backend;
		}
	}

	private void register_backends()
	{
		register_backend(new C.Backend());
	}

	public Backend? get(string language)
	{
		if (d_backends.has_key(language))
		{
			return d_backends[language];
		}
		else
		{
			return null;
		}
	}

	public static BackendManager instance
	{
		get
		{
			if (s_instance == null)
			{
				s_instance = new BackendManager();
			}

			return s_instance;
		}
	}
}

}

/* vi:ex:ts=4 */
