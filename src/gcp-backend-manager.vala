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
