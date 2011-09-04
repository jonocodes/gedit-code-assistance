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

		File sfile = File.new_for_path(file.name.str());

		return SourceLocation() {
			file = sfile,
			line = line,
			column = column
		};
	}

	private SourceRange translate_source_range(CX.SourceRange range)
	{
		return SourceRange() {
			start = translate_source_location(range.start()),
			end = translate_source_location(range.end())
		};
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
				SourceRange[] ranges = new SourceRange[d.num_ranges];

				var location = translate_source_location(d.location);

				for (uint j = 0; j < d.num_ranges; ++j)
				{
					ranges[j] = translate_source_range(d.get_range(j));
				}

				Diagnostic.Fixit[] fixits = new Diagnostic.Fixit[d.num_fixits];

				for (uint j = 0; j < d.num_fixits; ++j)
				{
					CX.SourceRange range;
					string repl = d.get_fixit(j, out range).str();

					fixits[j] = {translate_source_range(range), repl};
				}

				diags.add(new Diagnostic(severity,
				                         location,
				                         ranges,
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
