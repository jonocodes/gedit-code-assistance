[ModuleInit]
public void peas_register_types (TypeModule module)
{
	Peas.ObjectModule mod = module as Peas.ObjectModule;

	mod.register_extension_type (typeof (Gedit.ViewActivatable),
	                             typeof (Gcp.ViewActivatable));
}
