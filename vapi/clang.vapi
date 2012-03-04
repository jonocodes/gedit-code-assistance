[CCode (lower_case_cprefix = "clang_", cheader_filename = "clang-c/Index.h")]
namespace CX
{
	[Immutable, Compact]
	[CCode (free_function = "clang_disposeIndex", cname = "void", cprefix = "clang_")]
	public class Index
	{
		[CCode (cname = "clang_createIndex")]
		public Index(bool excludeDeclsFromPCH = false, bool displayDiagnostics = false);
	}

	[Flags]
	[CCode (cname = "enum CXTranslationUnit_Flags")]
	public enum ParseFlags
	{
		[CCode (cname = "CXTranslationUnit_None")]
		NONE,

		[CCode (cname = "CXTranslationUnit_DetailedPreprocessingRecord")]
		DETAILED_PREPROCESSING_RECORD,

		[CCode (cname = "CXTranslationUnit_Incomplete")]
		INCOMPLETE,

		[CCode (cname = "CXTranslationUnit_PrecompiledPreamble")]
		PRECOMPILED_PREAMBLE,

		[CCode (cname = "CXTranslationUnit_CacheCompletionResults")]
		CACHE_COMPLETION_RESULTS,

		[CCode (cname = "CXTranslationUnit_CXXPrecompiledPreamble")]
		CXX_PRECOMPLIED_PREAMBLE,

		[CCode (cname = "CXTranslationUnit_CXXChainedPCH")]
		CXX_CHAINED_PCH;

		[CCode (cname = "clang_defaultEditingTranslationUnitOptions")]
		public static ParseFlags default();
	}

	public delegate void InclusionVisitorCallback(File file,
	                                              [CCode (array_length_pos = 2.9)]
	                                              SourceLocation[] inclusion_stack);

	[Compact]
	[CCode (free_function = "clang_disposeTranslationUnit", cname = "void", cprefix = "clang_")]
	public class TranslationUnit
	{
		[CCode (cname = "enum CXSaveTranslationUnit_Flags")]
		public enum SaveFlags
		{
			[CCode (cname = "CXSaveTranslationUnit_None")]
			NONE
		}

		[CCode (ccname = "enum CXReparse_Flags")]
		public enum ReparseFlags
		{
			[CCode (cname = "CXReparse_None")]
			NONE
		}

		[CCode (cname = "clang_parseTranslationUnit")]
		public TranslationUnit(Index idx,
		                       string ?source_filename = null,
		                       [CCode(array_length_pos=3.9, array_null_terminated = false, type = "char const * const *")] string[] ?command_line_args = null,
		                       [CCode(array_length_pos=4.9, array_null_terminated = false)] UnsavedFile[] ?unsaved_files = null,
		                       ParseFlags options = ParseFlags.default());

		[CCode (cname = "clang_createTranslationUnit")]
		public static TranslationUnit create(Index idx, string ast_filename);

		[CCode (cname = "clang_saveTranslationUnit")]
		public int save(string filename, SaveFlags flags = SaveFlags.NONE);

		[CCode (cname = "clang_reparseTranslationUnit")]
		public int reparse([CCode(array_length_pos=0.9, array_null_terminated = false)] UnsavedFile[] ?unsaved_files = null, ReparseFlags flags = ReparseFlags.NONE);

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

		public CodeCompleteResults code_complete_at(string filename,
		                                            uint complete_line,
		                                            uint complete_column,
		                                            [CCode (array_length_pos = 4.9)]
		                                            UnsavedFile[] ?unsaved_files,
		                                            CodeCompleteFlags options);

		[CCode (cname = "clang_getInclusions")]
		public void get_inclusions(InclusionVisitorCallback callback);
	}

	[SimpleType]
	[CCode (cname = "struct CXUnsavedFile")]
	public struct UnsavedFile
	{
		public unowned string filename;
		public unowned string contents;
		public ulong length;
	}

	[SimpleType]
	[CCode (cname = "CXString", destroy_function = "clang_disposeString")]
	public struct String
	{
		[CCode (cname = "clang_getCString")]
		public unowned string str();
	}

	[Compact, Immutable]
	[CCode (cname = "void")]
	public class File
	{
		public String name
		{
			[CCode (cname = "clang_getFileName")]
			get;
		}

		public time_t time
		{
			[CCode (cname = "clang_getFileTime")]
			get;
		}
	}

	[SimpleType]
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

		[CCode (cname = "clang_getInstantiationLocation")]
		public void get_instantiation(out unowned File file,
		                              out uint line,
		                              out uint column,
		                              out uint offset);
	}

	[SimpleType]
	[CCode (cname = "CXSourceRange")]
	public struct SourceRange
	{
		[CCode (cname = "clang_getNullRange")]
		public static SourceRange invalid();

		[CCode (cname = "clang_getRangeStart")]
		public SourceLocation start();

		[CCode (cname = "clang_getRangeEnd")]
		public SourceLocation end();
	}

	[CCode (cname = "enum CXLinkageKind")]
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

	[CCode (cname = "enum CXAvailabilityKind")]
	public enum AvailablilityKind
	{
		[CCode (cname = "CXAvailability_Available")]
		AVAILABLE,

		[CCode (cname = "CXAvailability_Deprecated")]
		DEPRECATED,

		[CCode (cname = "CXAvailability_NotAvailable")]
		NOT_AVAILABLE
	}

	[CCode (cname = "enum CXLanguageKind")]
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

	[CCode (cname = "enum CXCursorKind")]
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

	[CCode (cname = "enum CXChildVisitResult")]
	public enum ChildVisitResult
	{
		[CCode (cname = "CXChildVisit_Break")]
		BREAK,

		[CCode (cname = "CXChildVisit_Continue")]
		CONTINUE,

		[CCode (cname = "CXChildVisit_Recurse")]
		RECURSE,
	}

	public delegate ChildVisitResult ChildrenVisitorCallback(Cursor cursor, Cursor parent);

	[SimpleType]
	[Immutable]
	[CCode (cname = "CXCursor")]
	public struct Cursor
	{
		[CCode (cname = "clang_getCursorKind")]
		public CursorKind kind();

		[CCode (cname = "clang_getNullCursor")]
		public Cursor invalid();

		[CCode (cname = "clang_equalCursors")]
		public bool equal(Cursor other);

		/*[CCode (cname = "clang_hashCursor")]
		public uint hash();*/

		[CCode (cname = "clang_getCursorLinkage")]
		public LinkageKind linkage();

		[CCode (cname = "clang_getCursorAvailability")]
		public AvailablilityKind availability();

		[CCode (cname = "clang_getCursorLanguage")]
		public LanguageKind language();

		[CCode (cname = "clang_getCursorSemanticParent")]
		public Cursor semantic_parent();

		[CCode (cname = "clang_getCursorLexicalParent")]
		public Cursor lexical_parent();

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

		[CCode (cname = "clang_getIncludedFile")]
		public File included_file();

		[CCode (cname = "clang_getCursorLocation")]
		public SourceLocation location();

		[CCode (cname = "clang_getCursorExtent")]
		public SourceRange extent();

		[CCode (cname = "clang_getCursorType")]
		public Type type();

		[CCode (cname = "clang_getCursorResultType")]
		public Type result_type();

		[CCode (cname = "clang_isVirtualBase")]
		public bool is_virtual_base();

		[CCode (cname = "clang_getCXXAccessSpecifier")]
		public CXXAccessSpecifier cxx_access_specifier();

		[CCode (cname = "clang_getNumOverloadedDecls")]
		public uint num_overloaded_decls();

		[CCode (cname = "clang_getOverloadedDecl")]
		public Cursor get_overloaded_decl(uint idx);

		[CCode (cname = "clang_getIBOutletCollectionType")]
		public Type ib_outlet_collection_type();

		[CCode (cname = "clang_getCursorUSR")]
		public String usr();

		[CCode (cname = "clang_getCursorSpelling")]
		public String spelling();

		[CCode (cname = "clang_getCursorReferenced")]
		public Cursor referenced();

		[CCode (cname = "clang_getCursorDefinition")]
		public Cursor definition();

		[CCode (cname = "clang_isCursorDefinition")]
		public bool is_definition();

		[CCode (cname = "clang_getCanonicalCursor")]
		public Cursor canonical_cursor();

		[CCode (cname = "clang_CXXMethod_isStatic")]
		public bool cxx_method_is_static();

		[CCode (cname = "clang_getTemplateCursorKind")]
		public CursorKind template_cursor_kind();

		[CCode (cname = "clang_getSpecializedCursorTemplate")]
		public Cursor specialized_cursor_template();

		[CCode (cname = "clang_getCursorDisplayName")]
		public String display_name();

		[CCode (cname = "clang_visitChildren")]
		public bool visit_children(ChildrenVisitorCallback callback);
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

	[CCode (cname = "enum CXDiagnosticSeverity")]
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
	[CCode (cname = "enum CXDiagnosticDisplayOptions")]
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
		public String format(DiagnosticDisplayOptions options = DiagnosticDisplayOptions.default());

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

		public uint num_ranges
		{
			[CCode (cname = "clang_getDiagnosticNumRanges")]
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

	[CCode (cname = "enum CXTypeKind")]
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

	[CCode (cname = "enum CX_CXXAccessSpecifier")]
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

	[CCode (cname = "enum CXTokenKind")]
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

	[CCode (cname = "CXCompletionChunkKind")]
	public enum CompletionChunkKind
	{
		[CCode (cname = "CXCompletionChunk_Optional")]
		OPTIONAL,

		[CCode (cname = "CXCompletionChunk_TypedText")]
		TYPED_TEXT,

		[CCode (cname = "CXCompletionChunk_Text")]
		TEXT,

		[CCode (cname = "CXCompletionChunk_Placeholder")]
		PLACEHOLDER,

		[CCode (cname = "CXCompletionChunk_Informative")]
		INFORMATIVE,

		[CCode (cname = "CXCompletionChunk_CurrentParameter")]
		CURRENT_PARAMETER,

		[CCode (cname = "CXCompletionChunk_LeftParen")]
		LEFT_PAREN,

		[CCode (cname = "CXCompletionChunk_RightParen")]
		RIGHT_PAREN,

		[CCode (cname = "CXCompletionChunk_LeftBracket")]
		LEFT_BRACKET,

		[CCode (cname = "CXCompletionChunk_RightBracket")]
		RIGHT_BRACKET,

		[CCode (cname = "CXCompletionChunk_LeftBrace")]
		LEFT_BRACE,

		[CCode (cname = "CXCompletionChunk_RightBrace")]
		RIGHT_BRACE,

		[CCode (cname = "CXCompletionChunk_LeftAngle")]
		LEFT_ANGLE,

		[CCode (cname = "CXCompletionChunk_RightAngle")]
		RIGHT_ANGLE,

		[CCode (cname = "CXCompletionChunk_Comma")]
		COMMA,

		[CCode (cname = "CXCompletionChunk_ResultType")]
		RESULT_TYPE,

		[CCode (cname = "CXCompletionChunk_Colon")]
		COLON,

		[CCode (cname = "CXCompletionChunk_SemiColon")]
		SEMI_COLON,

		[CCode (cname = "CXCompletionChunk_Equal")]
		EQUAL,

		[CCode (cname = "CXCompletionChunk_HorizontalSpace")]
		HORIZONTAL_SPACE,

		[CCode (cname = "CXCompletionChunk_VerticalSpace")]
		VERTICAL_SPACE
	}

	[Flags]
	[CCode (cname = "enum CXCodeComplete_Flags")]
	public enum CodeCompleteFlags
	{
		[CCode (cname = "CXCodeComplete_IncludeMacros")]
		INCLUDE_MACROS,

		[CCode (cname = "CXCodeComplete_IncludeCodePatterns")]
		INCLUDE_CODE_PATTERNS;

		[CCode (cname = "clang_defaultCodeCompleteOptions")]
		public static CodeCompleteFlags default();
	}

	[Compact, Immutable]
	public class CompletionString
	{
		public AvailablilityKind availability
		{
			[CCode (cname = "clang_getCompletionAvailability")]
			get;
		}

		public uint priority
		{
			[CCode (cname = "clang_getCompletionPriority")]
			get;
		}

		public uint chunks
		{
			[CCode (cname = "clang_getCompletionChunkCompletionString")]
			get;
		}

		[CCode (cname = "clang_getCompletionChunkCompletionString")]
		public string completion_chunk_string(uint chunk_number);

		[CCode (cname = "clang_getCompletionChunkText")]
		public string completion_chunk_text(uint chunk_number);

		[CCode (cname = "clang_getCompletionChunkText")]
		public CompletionChunkKind completion_chunk_kind(uint chunk_number);
	}

	public struct CompletionResult
	{
		[CCode (cname = "CursorKind")]
		public CursorKind cursor_kind;

		[CCode (cname = "CompletionString")]
		public CompletionString completion_string;
	}

	[Compact]
	[CCode (cname = "CXCodeCompleteResults", free_function = "clang_disposeCodeCompleteResults")]
	public class CodeCompleteResults
	{
		[CCode (cname = "Results", array_length_cname = "NumResults")]
		CompletionResult[] results;

		public uint num_diagnostics
		{
			[CCode (cname = "clang_codeCompleteGetNumDiagnostics")]
			get;
		}

		[CCode (cname = "clang_codeCompleteGetDiagnostic")]
		public Diagnostic get_diagnostic(uint idx);
	}
}

/* vi:ex:ts=4 */
