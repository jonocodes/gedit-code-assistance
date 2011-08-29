using Gee;

namespace Gcp.C
{
	public errordomain CompileArgsError
	{
		MISSING_MAKEFILE,
		MISSING_TARGET,
		MISSING_MAKE_OUTPUT
	}

	class CompileArgs : Object
	{
		private class Cache
		{
			private File d_source;
			private File d_makefile;
			private string[] d_args;

			public Cache(File source, File makefile, string[] args)
			{
				d_source = source;
				d_makefile = makefile;
				d_args = args;
			}

			public File makefile
			{
				get
				{
					return d_makefile;
				}
			}

			public File source
			{
				get
				{
					return d_source;
				}
			}

			public string[] args
			{
				get
				{
					return d_args;
				}
			}
		}

		private class Makefile
		{
			private File d_file;
			private ArrayList<File> d_sources;
			private FileMonitor ?d_monitor;
			private uint d_timeoutid;

			public signal void changed();

			public Makefile(File file)
			{
				d_file = file;
				d_timeoutid = 0;
				d_monitor = null;

				try
				{
					d_monitor = file.monitor(FileMonitorFlags.NONE);
				}
				catch (Error error)
				{
					return;
				}

				d_monitor.changed.connect(on_makefile_changed);
			}

			public bool valid
			{
				get
				{
					return d_monitor != null;
				}
			}

			public void add(File source)
			{
				d_sources.add(source);
			}

			public bool remove(File source)
			{
				d_sources.remove(source);

				return (d_sources.size == 0);
			}

			public ArrayList<File> sources
			{
				get
				{
					return d_sources;
				}
			}

			private void on_makefile_changed(File file, File ?other, FileMonitorEvent event_type)
			{
				if (event_type == FileMonitorEvent.CHANGED ||
				    event_type == FileMonitorEvent.CREATED)
				{
					if (d_timeoutid != 0)
					{
						Source.remove(d_timeoutid);
					}

					d_timeoutid = Timeout.add(100, on_makefile_timeout);
				}
			}

			private bool on_makefile_timeout()
			{
				d_timeoutid = 0;

				changed();

				return false;
			}
			
		}

		private HashMap<File, Cache> d_argsCache;
		private HashMap<File, Makefile> d_makefileCache;

		construct
		{
			d_argsCache = new HashMap<File, Cache>(File.hash, (EqualFunc)File.equal);
			d_makefileCache = new HashMap<File, Makefile>(File.hash, (EqualFunc)File.equal);
		}

		private File ?MakefileFor(File file,
		                          Cancellable ?cancellable) throws IOError, Error
		{
			File ?ret = null;

			while (ret == null)
			{
				File par = file.get_parent();

				if (par == null)
				{
					return null;
				}

				File makefile = par.get_child("Makefile");

				if (makefile.query_exists(cancellable))
				{
					ret = makefile;
				}
			}

			return ret;
		}

		private string TargetFromMake(File makefile,
		                              File source) throws SpawnError,
		                                                  RegexError,
		                                                  CompileArgsError
		{
			File wd = source.get_parent();
			string basen = source.get_basename();

			int idx = basen.last_index_of_char('.');
			string noext;

			if (idx >= 0)
			{
				noext = basen.substring(0, idx);
			}
			else
			{
				noext = basen;
			}

			string[] args = new string[] {
				"make",
				"-p",
				null
			};

			string outstr;

			/* Spawn make to find out which target has the source as a
			   dependency */
			Process.spawn_sync(wd.get_path(),
			                   args,
			                   null,
			                   SpawnFlags.SEARCH_PATH |
			                   SpawnFlags.STDERR_TO_DEV_NULL,
			                   null,
			                   out outstr);

			/* Scan the output to find the target */
			string prefreg = "^([^:]*(%s\\.(o|lo)))$".printf(Regex.escape_string(noext));
			string preflessreg = "^[a-z]+$";

			string reg = "^([^:\n]*):.*%s".printf(Regex.escape_string(basen));

			Regex regex = new Regex(reg, RegexCompileFlags.MULTILINE);
			MatchInfo info;

			if (regex.match(outstr, 0, out info))
			{
				Regex preg = new Regex(prefreg);
				Regex lreg = new Regex(preflessreg);
				string ?lastmatch = null;

				while (true)
				{
					string target = info.fetch(1);

					if (preg.match(target))
					{
						return target;
					}
					else if (lreg.match(target))
					{
						lastmatch = target;
					}

					if (!info.next())
					{
						break;
					}
				}

				if (lastmatch != null)
				{
					return lastmatch;
				}
			}

			throw new CompileArgsError.MISSING_TARGET(
				"Could not find make target for %s".printf(basen));
		}

		private string[] FilterFlags(string[] args)
		{
			bool inexpand = false;
			int i = 0;
			ArrayList<string> ret = new ArrayList<string>();

			/* Keep only those flags that are interesting:
			 * -I...: include directories
			 * -D...: defines
			 * -W...: warnings
			 * -f...: compiler flags
			 */

			while (i < args.length)
			{
				string a = args[i];
				++i;

				if (a.index_of_char('`') != -1)
				{
					inexpand = !inexpand;
					continue;
				}

				if (inexpand)
				{
					continue;
				}

				// Check if it's some kind of flag
				if (a[0] != '-')
				{
					continue;
				}

				// Then see if it's a flag we understand
				switch (a[1])
				{
					case 'I':
					case 'D':
					case 'f':
					case 'W':
						// Append the flag
						ret.add(a);

						// If it has no embedded argument, then also add the argument
						if (a[2] != '\0' && i < args.length)
						{
							ret.add(args[i]);
							++i;
						}
					break;
				}
			}

			return ret.to_array();
		}

		private string[] ?FlagsFromTarget(File   makefile,
		                                  File   source,
		                                  string target) throws SpawnError,
		                                                        CompileArgsError,
		                                                        ShellError
		{
			/* Fake make to build the target and extract the flags */
			string relsource = makefile.get_parent().get_relative_path(source);

			string fakecc = "__GCP_COMPILE_ARGS__";

			string[] args = new string[] {
				"make",
				"-s",
				"-i",
				"-n",
				"-W",
				relsource,
				"V=1",
				"CC=" + fakecc,
				"CXX=" + fakecc,
				target,
				null
			};

			string outstr;

			Process.spawn_sync(makefile.get_parent().get_path(),
			                   args,
			                   null,
			                   SpawnFlags.SEARCH_PATH |
			                   SpawnFlags.STDERR_TO_DEV_NULL,
			                   null,
			                   out outstr);

			/* Extract args */
			int idx = outstr.last_index_of(fakecc);

			if (idx < 0)
			{
				throw new CompileArgsError.MISSING_MAKE_OUTPUT("Make output did not contain flags");
			}

			string[] retargs;

			Shell.parse_argv(outstr.substring(idx + fakecc.length), out retargs);

			/* Copy only some of the flags that we are actually interested in */
			return FilterFlags(retargs);
		}

		public void remove_cache(File file)
		{
			if (d_argsCache.has_key(file))
			{
				d_argsCache.unset(file);
			}
		}

		public void remove(File file)
		{
			if (!d_argsCache.has_key(file))
			{
				return;
			}

			File makefile = d_argsCache[file].makefile;

			if (d_makefileCache.has_key(makefile))
			{
				if (d_makefileCache[makefile].remove(file))
				{
					d_makefileCache.unset(makefile);
				}
			}

			d_argsCache.unset(file);
		}

		public string[] ?
		guess(File file,
		      Cancellable ?cancellable = null) throws IOError,
		                                              RegexError,
		                                              CompileArgsError,
		                                              SpawnError,
		                                              ShellError,
		                                              Error
		{
			if (d_argsCache.has_key(file))
			{
				return d_argsCache[file].args;
			}

			File ?makefile = null;

			try
			{
				makefile = MakefileFor(file, cancellable);
			}
			catch (IOError.CANCELLED error)
			{
				return null;
			}

			if (makefile == null)
			{
				throw new CompileArgsError.MISSING_MAKEFILE(
					"Makefile could not be found");
			}

			string target = TargetFromMake(makefile, file);

			if (cancellable != null && cancellable.is_cancelled())
			{
				return null;
			}

			string[] args = FlagsFromTarget(makefile, file, target);

			if (cancellable != null && cancellable.is_cancelled())
			{
				return null;
			}

			if (args != null)
			{
				d_argsCache[file] = new Cache(file, makefile, args);

				if (!d_makefileCache.has_key(makefile))
				{
					Makefile m = new Makefile(makefile);

					m.changed.connect((mm) => {
						foreach (File source in mm.sources)
						{
							remove_cache(source);
						}
					});

					d_makefileCache[makefile] = m;
				}

				d_makefileCache[makefile].add(file);
			}

			return args;
		}
	}
}

/* vi:ex:ts=4 */
