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

namespace Gcp.C
{

class Document : Gcp.Document,
                 SymbolBrowserSupport,
                 DiagnosticSupport,
                 SemanticValueSupport
{
	private class CursorWrapper
	{
		public CX.Cursor cursor;

		public CursorWrapper(CX.Cursor c)
		{
			cursor = c;
		}

		public bool equal(CursorWrapper other)
		{
			return cursor.equal(other.cursor);
		}

		public uint hash()
		{
			uint sline;
			uint scolumn;

			cursor.extent().start().get_instantiation(null, out sline, out scolumn, null);

			uint eline;
			uint ecolumn;

			cursor.extent().end().get_instantiation(null, out eline, out ecolumn, null);

			uint cmp1 = (uint)(0.5 * (sline + scolumn) * (sline + scolumn + 1) + scolumn);
			uint cmp2 = (uint)(0.5 * (eline + ecolumn) * (eline + ecolumn + 1) + ecolumn);

			return (uint)(0.5 * (cmp1 + cmp2) * (cmp1 + cmp2 + 1) + cmp2);
		}
	}

	private DiagnosticTags d_tags;

	private TranslationUnit d_tu;
	private SymbolBrowser d_symbols;

	private SourceIndex d_diagnostics;
	private Mutex d_diagnosticsLock;

	private SourceIndex d_semantics;
	private Mutex d_semanticsLock;

	public Document(Gedit.Document document)
	{
		Object(document: document);
	}

	public void set_diagnostic_tags(DiagnosticTags tags)
	{
		d_tags = tags;
	}

	public DiagnosticTags get_diagnostic_tags()
	{
		return d_tags;
	}

	construct
	{
		d_tu = new TranslationUnit();
		d_symbols = new SymbolBrowser();

		d_diagnostics = new SourceIndex();
		d_diagnosticsLock = new Mutex();

		d_semantics = new SourceIndex();
		d_semanticsLock = new Mutex();

		d_tu.update.connect(on_tu_update);
	}

	public SymbolBrowser symbol_browser
	{
		get
		{
			return d_symbols;
		}
	}

	public SourceIndex begin_diagnostics()
	{
		d_diagnosticsLock.lock();
		return d_diagnostics;
	}

	public void end_diagnostics()
	{
		d_diagnosticsLock.unlock();
	}

	public SourceIndex begin_semantics()
	{
		d_semanticsLock.lock();
		return d_semantics;
	}

	public void end_semantics()
	{
		d_semanticsLock.unlock();
	}

	public TranslationUnit translation_unit
	{
		get
		{
			return d_tu;
		}
	}

	private void clip_location(SourceLocation location)
	{
		if (location.line > document.get_line_count())
		{
			location.line = document.get_line_count();
		}
	}

	private void update_diagnostics(CX.TranslationUnit tu)
	{
		SourceIndex ndiag = new SourceIndex();

		Log.debug("New diagnostics: %u", tu.num_diagnostics);

		for (uint i = 0; i < tu.num_diagnostics; ++i)
		{
			CX.Diagnostic d = tu.get_diagnostic(i);

			Diagnostic.Severity severity = Translator.severity(d.severity);

			var loc = Translator.source_location(d.location);

			Log.debug("Diagnostic location [%u]: %s", i, loc.file == null ? null : loc.file.get_path());

			if (loc.file == null || !loc.file.equal(location))
			{
				Log.debug("Diagnostic not for this file: %s", d.spelling.str());
				continue;
			}

			clip_location(loc);

			LinkedList<SourceRange> ranges = new LinkedList<SourceRange>();

			for (uint j = 0; j < d.num_ranges; ++j)
			{
				SourceRange range = Translator.source_range(d.get_range(j));

				if (range.start.file != null &&
					range.end.file != null &&
					range.start.file.equal(location) &&
					range.end.file.equal(location))
				{
					clip_location(range.start);
					clip_location(range.end);

					ranges.add(range);
				}
			}

			Diagnostic.Fixit[] fixits = new Diagnostic.Fixit[d.num_fixits];

			for (uint j = 0; j < d.num_fixits; ++j)
			{
				CX.SourceRange range;
				string repl = d.get_fixit(j, out range).str();

				SourceRange r = Translator.source_range(range);

				if (r.start.file != null &&
					r.end.file != null &&
					r.start.file.equal(location) &&
					r.end.file.equal(location))
				{
					clip_location(r.start);
					clip_location(r.end);

					fixits[j] = {r, repl};
				}
			}

			ndiag.add(new Diagnostic(severity,loc,
			                         ranges.to_array(),
			                         fixits,
			                         d.spelling.str()));
		}

		d_diagnosticsLock.lock();
		d_diagnostics = ndiag;
		d_diagnosticsLock.unlock();
	}

	private void update_semantics(CX.TranslationUnit tu)
	{
		SourceIndex sems = new SourceIndex();

		HashMap<CursorWrapper, SemanticValue> semmap;

		semmap = new HashMap<CursorWrapper, SemanticValue>(CursorWrapper.hash,
		                                                  (EqualFunc)CursorWrapper.equal);

		SemanticValue.translate(tu.cursor, location, (cursor, val) => {
			sems.add(val);
			semmap[new CursorWrapper(cursor)] = val;

			if (Translator.is_reference(cursor))
			{
				CursorWrapper wrapper = new CursorWrapper(cursor.referenced());

				if (!semmap.has_key(wrapper))
				{
					var refval = new SemanticValue(cursor.referenced());

					semmap[wrapper] = refval;
					sems.add(refval);
				}

				SemanticValue rr = semmap[wrapper];

				for (int i = 0; i < rr.num_references; ++i)
				{
					SemanticValue mr = (Gcp.C.SemanticValue)rr.reference(i);

					val.add_reference(mr);
					mr.add_reference(val);
				}

				rr.add_reference(val);
				val.add_reference(rr);
			}
		});

		d_semanticsLock.lock();
		d_semantics = sems;
		d_semanticsLock.unlock();
	}

	private void on_tu_update()
	{
		/* Refill the symbol browser */
		d_tu.with_translation_unit.begin((tu) => {
			update_diagnostics(tu);
			update_semantics(tu);
		}, (obj, res) => {
			d_tu.with_translation_unit.end(res);

			diagnostics_updated();
			semantic_values_updated();
		});
	}
}

}

/* vi:ex:ts=4 */
