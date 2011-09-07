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

namespace Gcp
{

class SourceLocation
{
	private File? d_file;
	private int d_line;
	private int d_column;

	public SourceLocation(File? file, int line, int column)
	{
		d_file = file;
		d_line = line;
		d_column = column;
	}

	public File? file
	{
		get { return d_file; }
	}

	public int line
	{
		get { return d_line; }
		set { d_line = value; }
	}

	public int column
	{
		get { return d_column; }
	}

	public string to_string()
	{
		return "(%d.%d)".printf(line, column);
	}
}

}

/* vi:ex:ts=4 */
