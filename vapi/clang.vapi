[CCode (lower_case_cprefix = "clang_", cheader_filename = "Index.h")]
namespace CX
{
	[Compact]
	[CCode (free_function = "clang_disposeIndex", cname = "CXIndex", cprefix = "clang_")]
	public class Index
	{
		[CCode (cname = "clang_createIndex")]
		public Index(bool excludeDeclsFromPCH = false, bool displayDiagnostics = false);
	}

	[Flags]
	[CCode (cname = "CXTranslationUnit_Flags")]
	public enum ParseFlags
	{
		[CCode (cname = "CXTranslationUnit_None")]
		None,

		[CCode (cname = "CXTranslationUnit_DetailedPreprocessingRecord")]
		DetailedPreprocessingRecord,

		[CCode (cname = "CXTranslationUnit_Incomplete")]
		Incomplete,

		[CCode (cname = "CXTranslationUnit_PrecompiledPreamble")]
		PrecompiledPreamble,

		[CCode (cname = "CXTranslationUnit_CacheCompletionResults")]
		CacheCompletionResults,

		[CCode (cname = "CXTranslationUnit_CXXPrecompiledPreamble")]
		CXXPrecompiledPreamble,

		[CCode (cname = "CXTranslationUnit_CXXChainedPCH")]
		CXXChainedPCH;

		[CXCode (cname = "clang_defaultEditingTranslationUnitOptions")]
		public static ParseFlags default();
	}

	[Compact]
	[CCode (free_function = "clang_disposeTranslationUnit", cname = "CXTranslationUnit", cprefix = "clang_")]
	public class TranslationUnit
	{
		[CCode (cname = "CXSaveTranslationUnit_Flags")]
		public enum SaveFlags
		{
			[CCode (cname = "CXSaveTranslationUnit_None")]
			None
		}

		[CCode (ccname = "CXReparse_Flags")]
		public enum ReparseFlags
		{
			[CCode (cname = "CXReparse_None")]
			None
		}

		[CCode (cname = "clang_parseTranslationUnit")]
		public TranslationUnit(Index idx,
		                       string ?source_filename = 0,
		                       [CCode(array_length_pos=3.9, array_null_terminated = false)] string[] ?command_line_args = null,
		                       [CCode(array_length_pos=5.9, array_null_terminated = false)] UnsavedFile[] ?unsaved_files = null,
		                       ParseFlags options = ParseFlags.default());

		[CCode (cname = "clang_createTranslationUnit")]
		public static TranslationUnit create(Index idx, string ast_filename);

		[CCode (cname = "clang_createTranslationUnit")]
		public static TranslationUnit create_from_source_file(Index idx,
		                                                      string ?source_filename = null,
		                                                      [CCode(array_length_pos=2.9,
		                                                             array_null_terminated = false)]
		                                                      string[] ?command_line_args = null,
		                                                      [CCode(array_length_pos=4.9,
		                                                             array_null_terminated = false)]
		                                                      UnsavedFile[] ?unsaved_files = null);

		[CCode (cname = "clang_saveTranslationUnit")]
		public int save(string filename, SaveFlags flags = SaveFlags.None);

		[CCode (cname = "clang_reparseTranslationUnit")]
		public int reparse ([CCode(array_length_pos=0.9, array_null_terminated = false)] UnsavedFile[] ?unsaved_files = null, ReparseFlags flags = ReparseFlags.None);

		public ReparseFlags default_reparse_options
		{
			[CCode (cname = "clang_defaultReparseOptions")]
			get;
		}

		public SaveFlags default_save_options
		{
			[CCode (cname = "clang_defaultSaveOptions")]
			get;
		}

		public String spelling
		{
			[CCode (cname = "clang_getTranslationUnitSpelling")]
			owned get;
		}

		[CCode (cname = "clang_getFile")]
		public File ?get_file(string filename);

		[CCode (cname = "clang_getLocation")]
		public SourceLocation get_location(File file,
		                                   uint line,
		                                   uint column);

		[CCode (cname = "clang_getLocationForOffset")]
		public SourceLocation get_location_for_offset(File file,
		                                              uint offset);

		public uint num_diagnostics
		{
			[CCode (cname = "clang_getNumDiagnostics")]
			get;
		}

		[CCode(cname = "clang_getDiagnostic")]
		public Diagnostic get_diagnostic(uint idx);

		public Cursor cursor
		{
			[CCode (cname = "clang_getTranslationUnitCursor")]
			get;
		}

		[CCode (cname = "clang_getCursor")]
		public Cursor get_cursor(SourceLocation location);

		[CCode (cname = "clang_getTokenSpelling")]
		public String get_token_spelling(Token token);

		[CCode (cname = "clang_getTokenLocation")]
		public SourceLocation get_token_location(Token token);

		[CCode (cname = "clang_getTokenExtent")]
		public SourceRange get_token_extent(Token token);

		[CCode (cname = "clang_tokenize")]
		private void _tokenize(SourceRange range,
		                       out Token *tokens,
		                       out uint   num_tokens);

		[CCode (cname = "clang_disposeTokens")]
		private void dispose_tokens(Token *tokens);

		public Token[] tokenize(SourceRange range)
		{
			Token* tokens;
			uint num;

			_tokenize(range, out tokens, out num);
			Token[] ret = new Token[num];

			for (uint i = 0; i < num; ++i)
			{
				ret[i] = tokens[i];
			}

			dispose_tokens(tokens);
			return ret;
		}

		[CCode (cname = "clang_annotateTokens")]
		private void _annotate_tokens([CCode (array_length_pos = 1.9)]
		                              Token[] tokens,
		                              ref Cursor[] cursors);

		public Cursor[] annotate_tokens(Token[] tokens)
		{
			Cursor[] cursors = new Cursor[tokens.length];

			_annotate_tokens(tokens, ref cursors);
			return cursors;
		}
	}

	[CCode (cname = "CXUnsavedFile")]
	public struct UnsavedFile
	{
		public unowned string filename;
		public unowned string contents;
		public ulong length;
	}

	[Compact]
	[CCode (cname = "CXString", free_function = "clang_disposeString")]
	public class String
	{
		public unowned string str
		{
			[CCode (cname = "clang_getCString")]
			get;
		}
	}

	[Compact, Immutable]
	[CCode (cname = "CXFile")]
	public class File
	{
		String name
		{
			[CCode (cname = "clang_getFilename")]
			get;
		}

		time_t time
		{
			[CCode (cname = "clang_getFileTime")]
			get;
		}
	}

	[CCode (cname = "CXSourceLocation")]
	public struct SourceLocation
	{
		public static SourceLocation invalid
		{
			[CCode (cname = "clang_getNullLocation")]
			get;
		}

		[CCode (cname = "clang_equalLocations")]
		public bool equal(SourceLocation other);

		[CCode (cname = "clang_getSpellingLocation")]
		public void get_spelling(out File file,
		                         out uint line,
		                         out uint column,
		                         out uint offset);
	}

	[CCode (cname = "CXSourceRange")]
	public struct SourceRange
	{
		[CCode (cname = "clang_getRange")]
		public SourceRange(SourceLocation begin,
		                   SourceLocation end);

		public static SourceRange invalid
		{
			[CCode (cname = "clang_getNullRange")]
			get;
		}

		public SourceLocation range_start
		{
			[CCode (cname = "clang_getRangeStart")]
			get;
		}

		public SourceLocation range_end
		{
			[CCode (cname = "clang_getRangeEnd")]
			get;
		}
	}

	[CCode (cname = "CXLinkageKind")]
	public enum LinkageKind
	{
		[CCode (cname = "CXLinkage_Invalid")]
		INVALID,

		[CCode (cname = "CXLinkage_NoLinkage")]
		NO_LINKAGE,

		[CCode (cname = "CXLinkage_Internal")]
		INTERNAL,

		[CCode (cname = "CXLinkage_UniqueExternal")]
		UNIQUE_EXTERNAL,

		[CCode (cname = "CXLinkage_External")]
		EXTERNAL
	}

	[CCode (cname = "CXAvailabilityKind")]
	public enum AvailablilityKind
	{
		[CCode (cname = "CXAvailability_Available")]
		AVAILABLE,

		[CCode (cname = "CXAvailability_Deprecated")]
		DEPRECATED,

		[CCode (cname = "CXAvailability_NotAvailable")]
		NOT_AVAILABLE
	}

	[CCode (cname = "CXLanguageKind")]
	public enum LanguageKind
	{
		[CCode (cname = "CXLanguage_Invalid")]
		INVALID,

		[CCode (cname = "CXLanguage_C")]
		C,

		[CCode (cname = "CXLanguage_CPlusPlus")]
		C_PLUS_PLUS,

		[CCode (cname = "CXLanguage_ObjC")]
		OBJ_C
	}

	[CCode (cname = "CXCursorKind")]
	public enum CursorKind
	{
		[CCode (cname = "CXCursor_UnexposedDecl")]
		UNEXPOSED_DECL,

		[CCode (cname = "CXCursor_StructDecl")]
		STRUCT_DECL,

		[CCode (cname = "CXCursor_UnionDecl")]
		UNION_DECL,

		[CCode (cname = "CXCursor_ClassDecl")]
		CLASS_DECL,

		[CCode (cname = "CXCursor_EnumDecl")]
		ENUM_DECL,

		[CCode (cname = "CXCursor_FieldDecl")]
		FIELD_DECL,

		[CCode (cname = "CXCursor_EnumConstantDecl")]
		ENUM_CONSTANT_DECL,

		[CCode (cname = "CXCursor_FunctionDecl")]
		FUNCTION_DECL,

		[CCode (cname = "CXCursor_VarDecl")]
		VAR_DECL,

		[CCode (cname = "CXCursor_ParmDecl")]
		PARM_DECL,

		[CCode (cname = "CXCursor_ObjCInterfaceDecl")]
		OBJ_C_INTERFACE_DECL,

		[CCode (cname = "CXCursor_ObjCCategoryDecl")]
		OBJ_C_CATEGORY_DECL,

		[CCode (cname = "CXCursor_ObjCProtocolDecl")]
		OBJ_C_PROTOCOL_DECL,

		[CCode (cname = "CXCursor_ObjCPropertyDecl")]
		OBJ_C_PROPERTY_DECL,

		[CCode (cname = "CXCursor_ObjCIvarDecl")]
		OBJ_C_IVAR_DECL,

		[CCode (cname = "CXCursor_ObjCInstanceMethodDecl")]
		OBJ_C_INSTANCE_METHOD_DECL,

		[CCode (cname = "CXCursor_ObjCClassMethodDecl")]
		OBJ_C_CLASS_METHOD_DECL,

		[CCode (cname = "CXCursor_ObjCImplementationDecl")]
		OBJ_C_IMPLEMENTATION_DECL,

		[CCode (cname = "CXCursor_ObjCCategoryImplDecl")]
		OBJ_C_CATEGORY_IMPL_DECL,

		[CCode (cname = "CXCursor_TypedefDecl")]
		TYPEDEF_DECL,

		[CCode (cname = "CXCursor_CXXMethod")]
		CXXMETHOD,

		[CCode (cname = "CXCursor_Namespace")]
		NAMESPACE,

		[CCode (cname = "CXCursor_LinkageSpec")]
		LINKAGE_SPEC,

		[CCode (cname = "CXCursor_Constructor")]
		CONSTRUCTOR,

		[CCode (cname = "CXCursor_Destructor")]
		DESTRUCTOR,

		[CCode (cname = "CXCursor_ConversionFunction")]
		CONVERSION_FUNCTION,

		[CCode (cname = "CXCursor_TemplateTypeParameter")]
		TEMPLATE_TYPE_PARAMETER,

		[CCode (cname = "CXCursor_NonTypeTemplateParameter")]
		NON_TYPE_TEMPLATE_PARAMETER,

		[CCode (cname = "CXCursor_TemplateTemplateParameter")]
		TEMPLATE_TEMPLATE_PARAMETER,

		[CCode (cname = "CXCursor_FunctionTemplate")]
		FUNCTION_TEMPLATE,

		[CCode (cname = "CXCursor_ClassTemplate")]
		CLASS_TEMPLATE,

		[CCode (cname = "CXCursor_ClassTemplatePartialSpecialization")]
		CLASS_TEMPLATE_PARTIAL_SPECIALIZATION,

		[CCode (cname = "CXCursor_NamespaceAlias")]
		NAMESPACE_ALIAS,

		[CCode (cname = "CXCursor_UsingDirective")]
		USING_DIRECTIVE,

		[CCode (cname = "CXCursor_UsingDeclaration")]
		USING_DECLARATION,

		[CCode (cname = "CXCursor_FirstDecl")]
		FIRST_DECL,

		[CCode (cname = "CXCursor_LastDecl")]
		LAST_DECL,

		[CCode (cname = "CXCursor_FirstRef")]
		FIRST_REF,

		[CCode (cname = "CXCursor_ObjCProtocolRef")]
		OBJ_C_PROTOCOL_REF,

		[CCode (cname = "CXCursor_ObjCClassRef")]
		OBJ_C_CLASS_REF,

		[CCode (cname = "CXCursor_TypeRef")]
		TYPE_REF,

		[CCode (cname = "CXCursor_CXXBaseSpecifier")]
		CXXBASE_SPECIFIER,

		[CCode (cname = "CXCursor_TemplateRef")]
		TEMPLATE_REF,

		[CCode (cname = "CXCursor_NamespaceRef")]
		NAMESPACE_REF,

		[CCode (cname = "CXCursor_MemberRef")]
		MEMBER_REF,

		[CCode (cname = "CXCursor_LabelRef")]
		LABEL_REF,

		[CCode (cname = "CXCursor_OverloadedDeclRef")]
		OVERLOADED_DECL_REF,

		[CCode (cname = "CXCursor_LastRef")]
		LAST_REF,

		[CCode (cname = "CXCursor_FirstInvalid")]
		FIRST_INVALID,

		[CCode (cname = "CXCursor_InvalidFile")]
		INVALID_FILE,

		[CCode (cname = "CXCursor_NoDeclFound")]
		NO_DECL_FOUND,

		[CCode (cname = "CXCursor_NotImplemented")]
		NOT_IMPLEMENTED,

		[CCode (cname = "CXCursor_InvalidCode")]
		INVALID_CODE,

		[CCode (cname = "CXCursor_LastInvalid")]
		LAST_INVALID,

		[CCode (cname = "CXCursor_FirstExpr")]
		FIRST_EXPR,

		[CCode (cname = "CXCursor_UnexposedExpr")]
		UNEXPOSED_EXPR,

		[CCode (cname = "CXCursor_DeclRefExpr")]
		DECL_REF_EXPR,

		[CCode (cname = "CXCursor_MemberRefExpr")]
		MEMBER_REF_EXPR,

		[CCode (cname = "CXCursor_CallExpr")]
		CALL_EXPR,

		[CCode (cname = "CXCursor_ObjCMessageExpr")]
		OBJ_C_MESSAGE_EXPR,

		[CCode (cname = "CXCursor_BlockExpr")]
		BLOCK_EXPR,

		[CCode (cname = "CXCursor_LastExpr")]
		LAST_EXPR,

		[CCode (cname = "CXCursor_FirstStmt")]
		FIRST_STMT,

		[CCode (cname = "CXCursor_UnexposedStmt")]
		UNEXPOSED_STMT,

		[CCode (cname = "CXCursor_LabelStmt")]
		LABEL_STMT,

		[CCode (cname = "CXCursor_LastStmt")]
		LAST_STMT,

		[CCode (cname = "CXCursor_TranslationUnit")]
		TRANSLATION_UNIT,

		[CCode (cname = "CXCursor_FirstAttr")]
		FIRST_ATTR,

		[CCode (cname = "CXCursor_UnexposedAttr")]
		UNEXPOSED_ATTR,

		[CCode (cname = "CXCursor_IBActionAttr")]
		IBACTION_ATTR,

		[CCode (cname = "CXCursor_IBOutletAttr")]
		IBOUTLET_ATTR,

		[CCode (cname = "CXCursor_IBOutletCollectionAttr")]
		IBOUTLET_COLLECTION_ATTR,

		[CCode (cname = "CXCursor_LastAttr")]
		LAST_ATTR,

		[CCode (cname = "CXCursor_PreprocessingDirective")]
		PREPROCESSING_DIRECTIVE,

		[CCode (cname = "CXCursor_MacroDefinition")]
		MACRO_DEFINITION,

		[CCode (cname = "CXCursor_MacroInstantiation")]
		MACRO_INSTANTIATION,

		[CCode (cname = "CXCursor_InclusionDirective")]
		INCLUSION_DIRECTIVE,

		[CCode (cname = "CXCursor_FirstPreprocessing")]
		FIRST_PREPROCESSING,

		[CCode (cname = "CXCursor_LastPreprocessing")]
		LAST_PREPROCESSING;

		[CCode (cname = "clang_isDeclaration")]
		public bool is_declaration();

		[CCode (cname = "clang_isReference")]
		public bool is_reference();

		[CCode (cname = "clang_isExpression")]
		public bool is_expression();

		[CCode (cname = "clang_isStatement")]
		public bool is_statement();

		[CCode (cname = "clang_isInvalid")]
		public bool is_invalid();

		[CCode (cname = "clang_isTranslationUnit")]
		public bool is_translation_unit();

		[CCode (cname = "clang_isPreprocessing")]
		public bool is_preprocessing();

		[CCode (cname = "clang_isUnexposed")]
		public bool is_unexposed();

		[CCode (cname = "clang_getCursorKindSpelling")]
		public String spelling();
	}

	public delegate void VisitorCallback(Cursor cursor, Cursor parent);

	[CCode (cname = "CXCursor")]
	public struct Cursor
	{
		public CursorKind kind
		{
			[CCode (cname = "clang_getCursorKind")]
			get;
		}

		public Cursor invalid
		{
			[CCode (cname = "clang_getNullCursor")]
			get;
		}

		[CCode (cname = "clang_equalCursors")]
		public bool equal(Cursor other);

		public uint hash
		{
			[CCode (cname = "clang_hashCursor")]
			get;
		}

		public LinkageKind linkage
		{
			[CCode (cname = "clang_getCursorLinkage")]
			get;
		}

		public AvailablilityKind availability
		{
			[CCode (cname = "clang_getCursorAvailability")]
			get;
		}

		public LanguageKind language
		{
			[CCode (cname = "clang_getCursorLanguage")]
			get;
		}

		public Cursor semantic_parent
		{
			[CCode (cname = "clang_getCursorSemanticParent")]
			get;
		}

		public Cursor lexical_parent
		{
			[CCode (cname = "clang_getCursorLexicalParent")]
			get;
		}

		[CCode (cname = "clang_getOverriddenCursors")]
		private void get_overridden_cursors(out Cursor* overridden, out uint num);

		[CCode (cname = "clang_disposeOverriddenCursors")]
		private static void dispose_overridden(Cursor *overridden);

		public Cursor[] overridden_cursors
		{
			owned get
			{
				Cursor* overridden;
				uint num;

				get_overridden_cursors(out overridden, out num);

				Cursor[] ret = new Cursor[num];

				for (uint i = 0; i < num; ++i)
				{
					ret[i] = overridden[i];
				}

				dispose_overridden(overridden);
				return ret;
			}
		}

		public File included_file
		{
			[CCode (cname = "clang_getIncludedFile")]
			get;
		}

		public SourceLocation location
		{
			[CCode (cname = "clang_getCursorLocation")]
			get;
		}

		public SourceRange extent
		{
			[CCode (cname = "clang_getCursorExtent")]
			get;
		}

		public Type type
		{
			[CCode (cname = "clang_getCursorType")]
			get;
		}

		public Type result_type
		{
			[CCode (cname = "clang_getCursorResultType")]
			get;
		}

		public bool is_virtual_base
		{
			[CCode (cname = "clang_isVirtualBase")]
			get;
		}

		public CXXAccessSpecifier cxx_access_specifier
		{
			[CCode (cname = "clang_getCXXAccessSpecifier")]
			get;
		}

		public uint num_overloaded_decls
		{
			[CCode (cname = "clang_getNumOverloadedDecls")]
			get;
		}

		[CCode (cname = "clang_getOverloadedDecl")]
		public Cursor get_overloaded_decl(uint idx);

		public Type ib_outlet_collection_type
		{
			[CCode (cname = "clang_getIBOutletCollectionType")]
			get;
		}

		public String usr
		{
			[CCode (cname = "clang_getCursorUSR")]
			get;
		}

		public String spelling
		{
			[CCode (cname = "clang_getCursorSpelling")]
			get;
		}

		public String display_name
		{
			[CCode (cname = "clang_getCursorDisplayName")]
			get;
		}

		public Cursor cursor_referenced
		{
			[CCode (cname = "clang_getCursorReferenced")]
			get;
		}

		public Cursor definition
		{
			[CCode (cname = "clang_getCursorDefinition")]
			get;
		}

		public bool is_definition
		{
			[CCode (cname = "clang_isCursorDefinition")]
			get;
		}

		public Cursor canonical_cursor
		{
			[CCode (cname = "clang_getCanonicalCursor")]
			get;
		}

		public bool cxx_method_is_static
		{
			[CCode (cname = "clang_CXXMethod_isStatic")]
			get;
		}

		public CursorKind template_cursor_kind
		{
			[CCode (cname = "clang_getTemplateCursorKind")]
			get;
		}

		public Cursor specialized_cursor_template
		{
			[CCode (cname = "clang_getSpecializedCursorTemplate")]
			get;
		}

		[CCode (cname = "clang_visitChildren")]
		public bool visit_children(VisitorCallback callback);
	}

	[Compact]
	[CCode (cname = "CXCursorSet", free_function = "clang_disposeCXCursorSet")]
	public class CursorSet
	{
		[CCode (cname = "clang_createCXCursorSet")]
		public CursorSet();

		[CCode (cname = "clang_CXCursorSet_contains")]
		public bool contains(Cursor cursor);

		[CCode (cname = "clang_CXCursorSet_insert")]
		public bool insert(Cursor cursor);
	}

	[CCode (cname = "CXDiagnosticSeverity")]
	public enum DiagnosticSeverity
	{
		[CCode(cname = "CXDiagnostic_Ignored")]
		IGNORED,

		[CCode(cname = "CXDiagnostic_Note")]
		NOTE,

		[CCode(cname = "CXDiagnostic_Warning")]
		WARNING,

		[CCode(cname = "CXDiagnostic_Error")]
		ERROR,

		[CCode(cname = "CXDiagnostic_Fatal")]
		FATAL
	}

	[Flags]
	[CCode (cname = "CXDiagnosticDisplayOptionst")]
	public enum DiagnosticDisplayOptions
	{
		[CCode (cname = "CXDiagnostic_DisplaySourceLocation")]
		LOCATION,

		[CCode (cname = "CXDiagnostic_DisplayColumn")]
		COLUMN,

		[CCode (cname = "CXDiagnostic_DisplaySourceRanges")]
		RANGES,

		[CCode (cname = "CXDiagnostic_DisplayOption")]
		OPTION,

		[CCode (cname = "CXDiagnostic_DisplayCategoryId")]
		CATEGORY_ID,

		[CCode (cname = "CXDiagnostic_DisplayCategoryName")]
		CATEGORY_NAME;

		[CCode (cname = "clang_defaultDiagnosticDisplayOptions")]
		public static DiagnosticDisplayOptions default();
	}

	[Compact]
	[CCode (cname = "CXDiagnostic", free_function = "clang_disposeDiagnostic")]
	public class Diagnostic
	{
		[CCode (cname = "clang_formatDiagnostic")]
		public String format(DiagnosticDisplayOptions options = DiagnosticDisplayOptions.default);

		public DiagnosticSeverity severity
		{
			[CCode (cname = "clang_getDiagnosticSeverity")]
			get;
		}

		public SourceLocation location
		{
			[CCode (cname = "clang_getDiagnosticLocation")]
			get;
		}

		public String spelling
		{
			[CCode (cname = "clang_getDiagnosticSpelling")]
			get;
		}

		[CCode (cname = "clang_getDiagnosticRange")]
		public SourceRange get_range(uint range);

		[CCode (cname = "clang_getDiagnosticOption")]
		public String get_diagnostic_option(out string disable);

		public uint category
		{
			[CCode (cname = "clang_getDiagnosticCategory")]
			get;
		}

		[CCode (cname = "clang_getDiagnosticCategoryName")]
		public static String category_name(uint category);

		public uint num_fixits
		{
			[CCode (cname = "clang_getDiagnosticNumFixIts")]
			get;
		}

		[CCode (cname = "clang_getDiagnosticFixIt")]
		public String get_fixit(uint fixit, out SourceRange range);
	}

	[CCode (cname = "CXTypeKind")]
	public enum TypeKind
	{
		[CCode (cname = "CXType_Invalid")]
		INVALID,

		[CCode (cname = "CXType_Unexposed")]
		UNEXPOSED,

		[CCode (cname = "CXType_Void")]
		VOID,

		[CCode (cname = "CXType_Bool")]
		BOOL,

		[CCode (cname = "CXType_Char_U")]
		CHAR_U,

		[CCode (cname = "CXType_UChar")]
		UCHAR,

		[CCode (cname = "CXType_Char16")]
		CHAR_16,

		[CCode (cname = "CXType_Char32")]
		CHAR_32,

		[CCode (cname = "CXType_UShort")]
		USHORT,

		[CCode (cname = "CXType_UInt")]
		UINT,

		[CCode (cname = "CXType_ULong")]
		ULONG,

		[CCode (cname = "CXType_ULongLong")]
		ULONG_LONG,

		[CCode (cname = "CXType_UInt128")]
		UINT_128,

		[CCode (cname = "CXType_Char_S")]
		CHAR_S,

		[CCode (cname = "CXType_SChar")]
		SCHAR,

		[CCode (cname = "CXType_WChar")]
		WCHAR,

		[CCode (cname = "CXType_Short")]
		SHORT,

		[CCode (cname = "CXType_Int")]
		INT,

		[CCode (cname = "CXType_Long")]
		LONG,

		[CCode (cname = "CXType_LongLong")]
		LONG_LONG,

		[CCode (cname = "CXType_Int128")]
		INT_128,

		[CCode (cname = "CXType_Float")]
		FLOAT,

		[CCode (cname = "CXType_Double")]
		DOUBLE,

		[CCode (cname = "CXType_LongDouble")]
		LONG_DOUBLE,

		[CCode (cname = "CXType_NullPtr")]
		NULL_PTR,

		[CCode (cname = "CXType_Overload")]
		OVERLOAD,

		[CCode (cname = "CXType_Dependent")]
		DEPENDENT,

		[CCode (cname = "CXType_ObjCId")]
		OBJ_C_ID,

		[CCode (cname = "CXType_ObjCClass")]
		OBJ_C_CLASS,

		[CCode (cname = "CXType_ObjCSel")]
		OBJ_C_SEL,

		[CCode (cname = "CXType_FirstBuiltin")]
		FIRST_BUILTIN,

		[CCode (cname = "CXType_LastBuiltin")]
		LAST_BUILTIN,

		[CCode (cname = "CXType_Complex")]
		COMPLEX,

		[CCode (cname = "CXType_Pointer")]
		POINTER,

		[CCode (cname = "CXType_BlockPointer")]
		BLOCK_POINTER,

		[CCode (cname = "CXType_LValueReference")]
		LVALUE_REFERENCE,

		[CCode (cname = "CXType_RValueReference")]
		RVALUE_REFERENCE,

		[CCode (cname = "CXType_Record")]
		RECORD,

		[CCode (cname = "CXType_Enum")]
		ENUM,

		[CCode (cname = "CXType_Typedef")]
		TYPEDEF,

		[CCode (cname = "CXType_ObjCInterface")]
		OBJ_C_INTERFACE,

		[CCode (cname = "CXType_ObjCObjectPointer")]
		OBJ_C_OBJECT_POINTER,

		[CCode (cname = "CXType_FunctionNoProto")]
		FUNCTION_NO_PROTO,

		[CCode (cname = "CXType_FunctionProto")]
		FUNCTION_PROTO;

		[CCode (cname = "clang_getTypeKindSpelling")]
		public String spelling();
	}

	[CCode (cname = "CXType")]
	public struct Type
	{
		[CCode (cname = "kind")]
		public TypeKind kind;

		[CCode (cname = "clang_equalTypes")]
		public bool equal(Type other);

		public Type canonical_type
		{
			[CCode (cname = "clang_getCanonicalType")]
			get;
		}

		public bool is_const_qualified_type
		{
			[CCode (cname = "clang_isConstQualifiedType")]
			get;
		}

		public bool is_volatile_qualified_type
		{
			[CCode (cname = "clang_isVolatileQualifiedType")]
			get;
		}

		public bool is_restrict_qualified_type
		{
			[CCode (cname = "clang_isRestrictQualifiedType")]
			get;
		}

		public Type pointee_type
		{
			[CCode (cname = "clang_getPointeeType")]
			get;
		}

		public Cursor type_declaration
		{
			[CCode (cname = "clang_getTypeDeclaration")]
			get;
		}

		public String decl_objc_type_encoding
		{
			[CCode (cname = "clang_getDeclObjCTypeEncoding")]
			get;
		}

		public Type result_type
		{
			[CCode (cname = "clang_getResultType")]
			get;
		}

		public bool is_pod_type
		{
			[CCode (cname = "clang_isPODType")]
			get;
		}
	}

	[CCode (cname = "CX_CXXAccessSpecifier")]
	public enum CXXAccessSpecifier
	{
		[CCode (cname = "CX_CXXInvalidAccessSpecifier")]
		INVALID,

		[CCode (cname = "CX_CXXPublic")]
		PUBLIC,

		[CCode (cname = "CX_CXXProtected")]
		PROTECTED,

		[CCode (cname = "CX_CXXPrivate")]
		PRIVATE
	}

	[CCode (cname = "CXTokenKind")]
	public enum TokenKind
	{
		[CCode (cname = "CXToken_Punctuation")]
		PUNCTUATION,

		[CCode (cname = "CXToken_Keyword")]
		KEYWORD,

		[CCode (cname = "CXToken_Identifier")]
		IDENTIFIER,

		[CCode (cname = "CXToken_Literal")]
		LITERAL,

		[CCode (cname = "CXToken_Comment")]
		COMMENT
	}

	[CCode (cname = "CXToken")]
	public struct Token
	{
		public TokenKind kind
		{
			[CCode (cname = "clang_getTokenKind")]
			get;
		}
	}
}
