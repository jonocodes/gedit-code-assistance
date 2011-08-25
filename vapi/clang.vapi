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
}
