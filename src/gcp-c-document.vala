using Gee;

namespace Gcp.C
{

class Document : Gcp.Document, SymbolBrowserSupport, DiagnosticSupport
{
	public DiagnosticTags tags {get; set;}

	private TranslationUnit d_tu;
	private SymbolBrowser d_symbols;
	private Diagnostic[] d_diagnostics;

	public Document(Gedit.Document document)
	{
		base(document);

		d_tu = new TranslationUnit();
		d_symbols = new SymbolBrowser();
		d_diagnostics = new Diagnostic[] {};

		d_tu.update.connect(on_tu_update);
	}

	public SymbolBrowser symbol_browser
	{
		get
		{
			return d_symbols;
		}
	}

	public Diagnostic[] diagnostics
	{
		get { return d_diagnostics; }
	}

	public TranslationUnit translation_unit
	{
		get
		{
			return d_tu;
		}
	}

	private Diagnostic.Severity translate_severity(CX.DiagnosticSeverity severity)
	{
		switch (severity)
		{
			case CX.DiagnosticSeverity.NOTE:
				return Diagnostic.Severity.INFO;
			case CX.DiagnosticSeverity.WARNING:
				return Diagnostic.Severity.WARNING;
			case CX.DiagnosticSeverity.ERROR:
				return Diagnostic.Severity.ERROR;
			case CX.DiagnosticSeverity.FATAL:
				return Diagnostic.Severity.FATAL;
			default:
				return Diagnostic.Severity.NONE;
		}
	}

	private SourceLocation translate_source_location(CX.SourceLocation location)
	{
		unowned CX.File file;
		uint line;
		uint column;
		uint offset;

		location.get_instantiation(out file, out line, out column, out offset);

		string? filename = file.name.str();

		File? sfile = filename != null ? File.new_for_path(filename) : null;

		return new SourceLocation(sfile, (int)line, (int)column);
	}

	private SourceRange translate_source_range(CX.SourceRange range)
	{
		return new SourceRange(translate_source_location(range.start()),
		                       translate_source_location(range.end()));
	}

	private void clip_location(SourceLocation location)
	{
		if (location.line > document.get_line_count())
		{
			location.line = document.get_line_count();
		}
	}

	private void on_tu_update()
	{
		/* Refill the symbol browser */
		d_tu.with_translation_unit((tu) => {
			ArrayList<Diagnostic> diags = new ArrayList<Diagnostic>();

			for (uint i = 0; i < tu.num_diagnostics; ++i)
			{
				CX.Diagnostic d = tu.get_diagnostic(i);

				Diagnostic.Severity severity = translate_severity(d.severity);

				var loc = translate_source_location(d.location);

				if (loc.file == null || !loc.file.equal(location))
				{
					continue;
				}

				clip_location(loc);

				LinkedList<SourceRange> ranges = new LinkedList<SourceRange>();

				for (uint j = 0; j < d.num_ranges; ++j)
				{
					SourceRange range = translate_source_range(d.get_range(j));

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

					SourceRange r = translate_source_range(range);

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

				diags.add(new Diagnostic(severity,
				                         loc,
				                         ranges.to_array(),
				                         fixits,
				                         d.spelling.str()));
			}

			diags.sort_with_data<Diagnostic>((CompareDataFunc)sort_on_severity);
			d_diagnostics = diags.to_array();

			updated();
		});
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
}

}

/* vi:ex:ts=4 */
