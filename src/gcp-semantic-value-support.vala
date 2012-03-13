namespace Gcp
{

public interface SemanticValueSupport : Gcp.Document
{
	public delegate void WithSemanticValueCallback(SourceIndex<SemanticValue> diagnostics);

	public abstract void with_semantics(WithSemanticValueCallback callback);

	public signal void semantic_values_updated();
}

}

/* vi:ex:ts=4 */
