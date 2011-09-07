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

class Plugin : Gedit.Plugin
{
	private HashMap<Gedit.Window, WindowHelper> d_helpers;

	public Plugin()
	{
		GLib.Object();
	}

	construct
	{
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
