namespace Gcp
{

interface SemanticValueSupport : Gcp.Document
{
	public abstract SourceIndex<SemanticValue> semantics
	{
		get;
	}

	public signal void semantic_values_updated();
}

}

/* vi:ex:ts=4 */
