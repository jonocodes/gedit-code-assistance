namespace Gcp
{

public delegate void AsyncInThreadCallback();

public async bool async_in_thread(AsyncInThreadCallback cb)
{
	/* Start new thread to get the args */
	SourceFunc callback = async_in_thread.callback;

	ThreadFunc<void *> run = () => {
		cb();

		Idle.add((owned)callback);
		return null;
	};

	try
	{
		Thread.create<void *>(run, false);
		yield;

		return true;
	}
	catch
	{
		return false;
	}
}

}
