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

	[Compact]
	[CCode (free_function = "clang_disposeTranslationUnit", cname = "CXTranslationUnit", cprefix = "clang_")]
	public class TranslationUnit
	{
		[CCode (cname = "CXTranslationUnit_Flags")]
		public enum Flags
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
			CXXChainedPCH
		}

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
		                       Flags options = Flags.None);

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

		public static Flags default_editing_options
		{
			[CCode (cname = "clang_defaultEditingTranslationUnitOptions")]
			get;
		}

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
			[CCode (cname = "clang_getNumDiagnostics")];
			get;
		}

		[CCode(cname = "clang_getDiagnostic")]
		public Diagnostic get_diagnostic(uint idx);

		public 
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
}
