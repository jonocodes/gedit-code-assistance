using Gee;

namespace Gcp
{
	public errordomain CompileArgsError
	{
		MISSING_MAKEFILE,
		MISSING_TARGET,
		MISSING_MAKE_OUTPUT
	}

	class CompileArgs
	{

		private static File ?MakefileFor(File file)
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

				if (makefile.query_exists())
				{
					ret = makefile;
				}
			}

			return ret;
		}

		private static string TargetFromMake(File makefile,
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

		private static string[] FilterFlags(string[] args)
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

		private static string[] ?FlagsFromTarget(File   makefile,
		                                         File   source,
		                                         string target) throws SpawnError,
		                                                             CompileArgsError,
		                                                             ShellError
		{
			/* Fake make to build the target and extract the flags */
			string relsource = makefile.get_relative_path(source);

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

		public static string[] ?Guess(File file) throws IOError,
		                                                RegexError,
		                                                CompileArgsError,
		                                                SpawnError,
		                                                ShellError
		{
			File ?makefile = MakefileFor(file);

			if (makefile == null)
			{
				throw new CompileArgsError.MISSING_MAKEFILE(
					"Makefile could not be found");
			}

			string target = TargetFromMake(makefile, file);
			return FlagsFromTarget(makefile, file, target);
		}
	}
}

/* vi:ex:ts=2 */
