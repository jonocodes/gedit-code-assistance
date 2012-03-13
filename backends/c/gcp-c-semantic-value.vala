using Gee;

namespace Gcp.C
{

class SemanticValue : Gcp.SemanticValue
{
	public delegate void CursorMappedFunc(CX.Cursor cursor, SemanticValue val);

	private class Translator
	{
		private CursorMappedFunc d_mapped;
		private SemanticValue? d_parent;
		private SemanticValue? d_current;
		private File? d_source;

		public Translator(owned CursorMappedFunc mapped, File? source)
		{
			d_mapped = (owned)mapped;
			d_source = source;
		}

		public void translate(SemanticValue parent)
		{
			d_parent = parent;
			d_current = null;

			parent.get_cursor().visit_children(visit_children);
		}

		private CX.ChildVisitResult visit_children(CX.Cursor child,
		                                           CX.Cursor parent)
		{
			SourceLocation loc = Gcp.C.Translator.source_location(child.location());

			if (d_source != null && (loc.file == null || !d_source.equal(loc.file)))
			{
				return CX.ChildVisitResult.RECURSE;
			}

			SemanticValue val = new SemanticValue(child);

			val.set_up(d_parent);
			val.set_previous(d_current);

			if (d_current != null)
			{
				d_current.set_next(val);
			}
			else
			{
				d_parent.set_down(val);
			}

			d_mapped(child, val);

			// Now we traverse deep, manually
			SemanticValue curparent = d_parent;
			d_parent = val;
			d_current = null;

			child.visit_children(visit_children);

			d_parent = curparent;
			d_current = val;

			return CX.ChildVisitResult.CONTINUE;
		}
	}

	private CX.Cursor d_cursor;
	private Gcp.SemanticValue? d_next;
	private unowned Gcp.SemanticValue? d_previous;
	private unowned Gcp.SemanticValue? d_up;
	private Gcp.SemanticValue? d_down;
	private ArrayList<SemanticValue *> d_references;

	public SemanticValue(CX.Cursor cursor)
	{
		base(Gcp.C.Translator.source_range(cursor.extent()),
		     Gcp.C.Translator.semantic_kind(cursor),
		     Gcp.C.Translator.semantic_reference_type(cursor));

		d_references = new ArrayList<SemanticValue *>();
		d_cursor = cursor;
	}

	public CX.Cursor get_cursor()
	{
		return d_cursor;
	}

	public override Gcp.SemanticValue? definition
	{
		owned get
		{
			foreach (SemanticValue v in d_references)
			{
				if ((v.reference_type & Gcp.SemanticValue.ReferenceType.DEFINITION) != 0)
				{
					return v;
				}
			}

			return null;
		}
	}

	public override Gcp.SemanticValue? declaration
	{
		owned get
		{
			foreach (SemanticValue v in d_references)
			{
				if ((v.reference_type & Gcp.SemanticValue.ReferenceType.DECLARATION) != 0)
				{
					return v;
				}
			}

			return null;
		}
	}

	public override Gcp.SemanticValue? next
	{
		get { return d_next; }
	}

	public override Gcp.SemanticValue? previous
	{
		get { return d_previous; }
	}

	public override Gcp.SemanticValue? up
	{
		get { return d_up; }
	}

	public override Gcp.SemanticValue? down
	{
		get { return d_down; }
	}

	public void set_next(SemanticValue? val)
	{
		d_next = val;
	}

	public void set_previous(SemanticValue? val)
	{
		d_previous = val;
	}

	public void set_up(SemanticValue? val)
	{
		d_up = val;
	}

	public void set_down(SemanticValue? val)
	{
		d_down = val;
	}

	public override int num_references
	{
		get { return d_references.size; }
	}

	public override Gcp.SemanticValue reference(int idx)
	{
		return d_references[idx];
	}

	public void add_reference(SemanticValue val)
	{
		d_references.add(val);
	}

	public static SemanticValue? translate(CX.Cursor cursor,
	                                       File? source,
	                                       owned CursorMappedFunc mapped)
	{
		Translator tr = new Translator((owned)mapped, source);
		SemanticValue ret = new SemanticValue(cursor);

		tr.translate(ret);

		return ret;
	}
}

}

/* vi:ex:ts=4 */
