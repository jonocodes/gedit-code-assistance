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

interface DiagnosticSupport : Document
{
	public abstract DiagnosticTags tags { get; set; }

	public signal void updated();

	public abstract Diagnostic[] diagnostics { get; }

	public Diagnostic[] find_at(uint line, uint column)
	{
		ArrayList<Diagnostic> ret = new ArrayList<Diagnostic>();

		foreach (Diagnostic d in diagnostics)
		{
			bool foundit = false;

			foreach (SourceRange r in d.ranges)
			{
				if (r.contains(line, column))
				{
					ret.add(d);
					foundit = true;
					break;
				}
			}

			if (!foundit && d.location.line == line && (d.location.column == column || d.location.column == column - 1))
			{
				ret.add(d);
			}
		}

		ret.sort_with_data<Diagnostic>((CompareDataFunc)sort_on_severity);

		return ret.to_array();
	}

	private int sort_on_severity(Diagnostic? a, Diagnostic? b)
	{
		if (a.severity == b.severity)
		{
			return 0;
		}

		// Higer priorities last
		return a.severity < b.severity ? -1 : 1;
	}

	public Diagnostic[] find_at_line(uint line)
	{
		ArrayList<Diagnostic> ret = new ArrayList<Diagnostic>();

		foreach (Diagnostic d in diagnostics)
		{
			bool foundit = false;

			foreach (SourceRange r in d.ranges)
			{
				if (r.contains_line(line))
				{
					ret.add(d);
					foundit = true;

					break;
				}
			}

			if (!foundit && d.location.line == line)
			{
				ret.add(d);
			}
		}

		ret.sort_with_data<Diagnostic>((CompareDataFunc)sort_on_severity);

		return ret.to_array();
	}
}

}

/* vi:ex:ts=4 */
