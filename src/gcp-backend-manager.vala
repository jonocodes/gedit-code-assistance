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

using Gee;

namespace Gcp
{

class BackendManager
{
	private static BackendManager s_instance;

	class BackendInfo : Object
	{
		public Backend ?backend { get; set; }
		public Peas.PluginInfo info { get; set; }

		public BackendInfo(Peas.PluginInfo info)
		{
			Object(info: info);
		}
	}

	private HashMap<string, BackendInfo> d_backends;
	private Peas.Engine d_engine;

	private BackendManager()
	{
		d_backends = new HashMap<string, BackendInfo>();

		d_engine = new Peas.Engine();

		d_engine.add_search_path(Gcp.Config.GCP_BACKENDS_DIR,
		                         Gcp.Config.GCP_BACKENDS_DATA_DIR);

		d_engine.enable_loader("python");

		// require the gcp gir
		string tpdir = Path.build_filename(Gcp.Config.GCP_LIBS_DIR,
		                                   "girepository-1.0");

		var repo = Introspection.Repository.get_default();

		try
		{
			repo.require_private(tpdir, "Gcp", "3.0");
		}
		catch (Introspection.RepositoryError error)
		{
			warning("Could not load Gcp typelib: %s", error.message);
		}

		register_backends();
	}

	private void register_backends()
	{
		foreach (Peas.PluginInfo info in d_engine.get_plugin_list())
		{
			string? langs = info.get_external_data("Languages");

			if (langs == null)
			{
				continue;
			}

			BackendInfo binfo = new BackendInfo(info);

			foreach (string lang in langs.split(","))
			{
				d_backends[lang] = binfo;
			}
		}
	}

	public Backend? get(string language)
	{
		if (!d_backends.has_key(language))
		{
			return null;
		}

		BackendInfo info = d_backends[language];

		if (info.backend == null)
		{
			d_engine.load_plugin(info.info);
			info.backend = (Gcp.Backend)d_engine.create_extension(info.info, typeof(Gcp.Backend));
		}

		return info.backend;
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
