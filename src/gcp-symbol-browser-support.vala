namespace Gcp
{

/**
 * Interface for documents supporting symbol browsing
 *
 * This interface is implemented on a Gcp.Document when it supports symbol
 * browsing.
 *
 */
interface SymbolBrowserSupport : Document
{
	/**
	 * Get symbol browser
	 *
	 * Get the symbol browser for the document
	 *
	 */
	public abstract SymbolBrowser symbol_browser { get; }
}

}

/* vi:ex:ts=4 */
