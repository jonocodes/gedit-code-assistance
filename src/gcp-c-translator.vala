namespace Gcp.C
{

class Translator
{
	public static SourceLocation source_location(CX.SourceLocation location)
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

	public static SourceRange source_range(CX.SourceRange range)
	{
		return new SourceRange(source_location(range.start()),
		                       source_location(range.end()));
	}

	public static Gcp.SemanticValue.Kind semantic_kind(CX.Cursor cursor)
	{
		if (is_reference(cursor))
		{
			return semantic_kind(cursor.referenced());
		}

		switch (cursor.kind())
		{
			case CX.CursorKind.STRUCT_DECL:
				return Gcp.SemanticValue.Kind.STRUCT;
			case CX.CursorKind.UNION_DECL:
				return Gcp.SemanticValue.Kind.UNION;
			case CX.CursorKind.CLASS_DECL:
				return Gcp.SemanticValue.Kind.CLASS;
			case CX.CursorKind.ENUM_DECL:
				return Gcp.SemanticValue.Kind.ENUM;
			case CX.CursorKind.FIELD_DECL:
				return Gcp.SemanticValue.Kind.FIELD;
			case CX.CursorKind.ENUM_CONSTANT_DECL:
				return Gcp.SemanticValue.Kind.ENUM_VALUE;
			case CX.CursorKind.FUNCTION_DECL:
				return Gcp.SemanticValue.Kind.FUNCTION;
			case CX.CursorKind.CXXMETHOD:
			case CX.CursorKind.CONVERSION_FUNCTION:
				return Gcp.SemanticValue.Kind.MEMBER_FUNCTION;
			case CX.CursorKind.CONSTRUCTOR:
				return Gcp.SemanticValue.Kind.CONSTRUCTOR;
			case CX.CursorKind.DESTRUCTOR:
				return Gcp.SemanticValue.Kind.DESTRUCTOR;
			case CX.CursorKind.VAR_DECL:
				return Gcp.SemanticValue.Kind.VARIABLE;
			case CX.CursorKind.PARM_DECL:
				return Gcp.SemanticValue.Kind.PARAMETER;
			case CX.CursorKind.TYPEDEF_DECL:
				return Gcp.SemanticValue.Kind.TYPEDEF;
			case CX.CursorKind.NAMESPACE:
			case CX.CursorKind.NAMESPACE_REF:
				return Gcp.SemanticValue.Kind.NAMESPACE;
			case CX.CursorKind.BLOCK_EXPR:
				return Gcp.SemanticValue.Kind.BLOCK;
			default:
				return Gcp.SemanticValue.Kind.NONE;
		}
	}

	public static Gcp.SemanticValue.ReferenceType semantic_reference_type(CX.Cursor cursor)
	{
		Gcp.SemanticValue.ReferenceType rtype;

		rtype = Gcp.SemanticValue.ReferenceType.NONE;

		if (cursor.kind().is_reference())
		{
			rtype |= Gcp.SemanticValue.ReferenceType.REFERENCE;
		}

		if (cursor.kind().is_declaration())
		{
			rtype |= Gcp.SemanticValue.ReferenceType.DECLARATION;
		}

		if (cursor.is_definition())
		{
			rtype |= Gcp.SemanticValue.ReferenceType.DEFINITION;
		}

		return rtype;
	}

	public static Diagnostic.Severity severity(CX.DiagnosticSeverity severity)
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

	public static bool is_reference(CX.Cursor cursor)
	{
		if (cursor.kind().is_reference())
		{
			return true;
		}

		switch (cursor.kind())
		{
			case CX.CursorKind.DECL_REF_EXPR:
			case CX.CursorKind.MEMBER_REF_EXPR:
				return true;
			default:
				return false;
		}
	}
}

}

/* vi:ex:ts=4 */
