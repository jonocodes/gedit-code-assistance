using Gee;

namespace Gcp.C
{

class Document : Gcp.Document, SymbolBrowserSupport, DiagnosticSupport
{
	private TranslationUnit d_tu;
	private SymbolBrowser d_symbols;
	private ArrayList<Diagnostic>? d_diagnostics;

	public Document(Gedit.Document document)
	{
		base(document);

		d_tu = new TranslationUnit();
		d_symbols = new SymbolBrowser();

		d_tu.update.connect(on_tu_update);
	}

	public SymbolBrowser symbol_browser
	{
		get
		{
			return d_symbols;
		}
	}

	public uint num_diagnostics
	{
		get
		{
			return d_diagnostics != null ? d_diagnostics.size : 0;
		}
	}

	public Diagnostic? diagnostic(uint i)
	{
		if (d_diagnostics == null)
		{
			return null;
		}

		if (i >= d_diagnostics.size)
		{
			return null;
		}

		return d_diagnostics[(int)i];
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
			d_diagnostics = new ArrayList<Diagnostic>();

			for (uint i = 0; i < tu.num_diagnostics; ++i)
			{
				CX.Diagnostic d = tu.get_diagnostic(i);

				Diagnostic.Severity severity = translate_severity(d.severity);
				SourceRange[] ranges;

				if (d.num_ranges == 0)
				{
					SourceLocation loc = translate_source_location(d.location);

					SourceRange range = SourceRange() {start = loc, end = loc};
					++range.end.column;

					ranges = new SourceRange[] {range};
				}
				else
				{
					ranges = new SourceRange[d.num_ranges];
				}

				for (uint j = 0; j < d.num_ranges; ++j)
				{
					ranges[j] = translate_source_range(d.get_range(j));
				}

				d_diagnostics.add(new Diagnostic(severity, ranges, d.spelling.str()));
			}

			updated();
		});
	}
}

}

/* vi:ex:ts=4 */
