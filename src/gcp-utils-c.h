#ifndef __GCP_UTILS_C_H__
#define __GCP_UTILS_C_H__

#include <glib-object.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define GCP_TYPE_UTILS_C		(gcp_utils_c_get_type ())
#define GCP_UTILS_C(obj)		(G_TYPE_CHECK_INSTANCE_CAST ((obj), GCP_TYPE_UTILS_C, GcpUtilsC))
#define GCP_UTILS_C_CONST(obj)		(G_TYPE_CHECK_INSTANCE_CAST ((obj), GCP_TYPE_UTILS_C, GcpUtilsC const))
#define GCP_UTILS_C_CLASS(klass)	(G_TYPE_CHECK_CLASS_CAST ((klass), GCP_TYPE_UTILS_C, GcpUtilsCClass))
#define GCP_IS_UTILS_C(obj)		(G_TYPE_CHECK_INSTANCE_TYPE ((obj), GCP_TYPE_UTILS_C))
#define GCP_IS_UTILS_C_CLASS(klass)	(G_TYPE_CHECK_CLASS_TYPE ((klass), GCP_TYPE_UTILS_C))
#define GCP_UTILS_C_GET_CLASS(obj)	(G_TYPE_INSTANCE_GET_CLASS ((obj), GCP_TYPE_UTILS_C, GcpUtilsCClass))

typedef struct _GcpUtilsC		GcpUtilsC;
typedef struct _GcpUtilsCClass		GcpUtilsCClass;
typedef struct _GcpUtilsCPrivate	GcpUtilsCPrivate;

struct _GcpUtilsC
{
	GObject parent;

	GcpUtilsCPrivate *priv;
};

struct _GcpUtilsCClass
{
	GObjectClass parent_class;
};

GType gcp_utils_c_get_type (void) G_GNUC_CONST;

gint gcp_utils_c_get_style_property_int (GtkStyleContext *context,
                                         gchar const     *name);

G_END_DECLS

#endif /* __GCP_UTILS_C_H__ */
