#include "gcp-utils-c.h"


#define GCP_UTILS_C_GET_PRIVATE(object)(G_TYPE_INSTANCE_GET_PRIVATE((object), GCP_TYPE_UTILS_C, GcpUtilsCPrivate))

struct _GcpUtilsCPrivate
{
};

G_DEFINE_TYPE (GcpUtilsC, gcp_utils_c, G_TYPE_OBJECT)

static void
gcp_utils_c_finalize (GObject *object)
{
	G_OBJECT_CLASS (gcp_utils_c_parent_class)->finalize (object);
}

static void
gcp_utils_c_class_init (GcpUtilsCClass *klass)
{
	GObjectClass *object_class = G_OBJECT_CLASS (klass);

	object_class->finalize = gcp_utils_c_finalize;

	g_type_class_add_private (object_class, sizeof (GcpUtilsCPrivate));
}

static void
gcp_utils_c_init (GcpUtilsC *self)
{
	self->priv = GCP_UTILS_C_GET_PRIVATE (self);
}

gint
gcp_utils_c_get_style_property_int (GtkStyleContext *context,
                                    gchar const     *name)
{
	GValue ret = {0,};
	gint val = 0;

	g_return_val_if_fail (context != NULL, 0);
	g_return_val_if_fail (name != NULL, 0);

	g_value_init (&ret, G_TYPE_INT);
	gtk_style_context_get_style_property (context, name, &ret);

	val = g_value_get_int (&ret);

	g_value_unset (&ret);
	return val;
}
