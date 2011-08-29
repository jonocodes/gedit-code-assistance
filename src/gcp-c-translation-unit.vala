namespace Gcp.C
{

class TranslationUnit
{
	private Mutex d_lock;
	private Mutex d_slock;
	private Cond d_cond;
	private bool d_exit;
	private unowned Thread<void *> d_thread;

	private CX.TranslationUnit d_tu;

	private UnsavedFile[] d_unsaved;

	private bool d_parsing;

	public signal void update();

	public delegate void WithTranslationUnitCallback(CX.TranslationUnit tu);

	public TranslationUnit()
	{
		d_lock = new Mutex();
		d_slock = new Mutex();
		d_cond = new Cond();

		d_unsaved = null;
		d_parsing = false;
		d_exit = false;

		try
		{
			d_thread = Thread.create<void *>(reparse_thread, true);
		}
		catch
		{
			d_thread = null;
		}
	}

	~TranslationUnit()
	{
		if (d_thread == null)
		{
			return;
		}

		d_slock.lock();
		d_exit = true;
		d_cond.signal();
		d_slock.unlock();

		d_thread.join();
	}

	public void with_translation_unit(WithTranslationUnitCallback callback)
	{
		d_lock.lock();

		callback(d_tu);

		d_lock.unlock();
	}

	public void *reparse_thread()
	{
		while (true)
		{
			d_slock.lock();
			d_cond.wait(d_slock);

			if (d_exit)
			{
				d_slock.unlock();
				break;
			}

			UnsavedFile[] uf = (owned)d_unsaved;
			d_unsaved = null;
			d_slock.unlock();

			d_lock.lock();
			d_tu.reparse((CX.UnsavedFile[])uf);
			d_lock.unlock();

			Idle.add(() => {
				update();
				return false;
			});
		}

		return null;
	}

	public void parse(CX.Index idx,
	                  string source,
	                  string[] args,
	                  owned UnsavedFile[]? unsaved = null)
	{
		ThreadFunc<void *> run = () => {
			d_lock.lock();

			d_tu = new CX.TranslationUnit(idx,
			                              source,
			                              args,
			                              (CX.UnsavedFile[])unsaved);

			d_lock.unlock();

			Idle.add(() => {
				update();
				return false;
			});

			return null;
		};

		try
		{
			Thread.create<void *>(run, false);
		}
		catch
		{
		}
	}

	public void reparse(owned UnsavedFile[] ?unsaved = null)
	{
		d_slock.lock();
		d_unsaved = (owned)unsaved;
		d_cond.signal();
		d_slock.unlock();
	}
}

}

/* vi:ex:ts=4 */
