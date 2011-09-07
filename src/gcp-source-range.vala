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

class SourceRange
{
	private SourceLocation d_start;
	private SourceLocation d_end;

	public SourceRange(SourceLocation start, SourceLocation end)
	{
		d_start = start;
		d_end = end;
	}

	public SourceLocation start
	{
		get { return d_start; }
	}

	public SourceLocation end
	{
		get { return d_end; }
	}

	public bool contains(uint line, uint column)
	{
		return (d_start.line < line || (d_start.line == line && d_start.column <= column)) &&
		       (d_end.line > line || (d_end.line == line && d_end.column >= column));
	}

	public bool contains_line(uint line)
	{
		return d_start.line <= line && d_end.line >= line;
	}

	public string to_string()
	{
		if (d_start.line == d_end.line && d_end.column - d_start.column <= 1)
		{
			return d_start.to_string();
		}

		return "%s-%s".printf(d_start.to_string(), d_end.to_string());
	}
}

}

/* vi:ex:ts=4 */
