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

	public signal void diagnostics_updated();

	public delegate void WithDiagnosticsCallback(SourceIndex<Diagnostic> diagnostics);

	public abstract void with_diagnostics(WithDiagnosticsCallback callback);

	public Diagnostic[] find_at(SourceLocation location)
	{
		ArrayList<Diagnostic> ret = new ArrayList<Diagnostic>();

		with_diagnostics((diagnostics) => {
			foreach (Diagnostic d in diagnostics.find_at(location))
			{
				ret.add(d);
			}
		});

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

	public Diagnostic[] find_at_line(int line)
	{
		ArrayList<Diagnostic> ret = new ArrayList<Diagnostic>();

		with_diagnostics((diagnostics) => {
			foreach (Diagnostic d in diagnostics.find_at_line(line))
			{
				ret.add(d);
			}
		});

		ret.sort_with_data<Diagnostic>((CompareDataFunc)sort_on_severity);

		return ret.to_array();
	}
}

}

/* vi:ex:ts=4 */
