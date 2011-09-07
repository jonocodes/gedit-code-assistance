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
