/*
 * This file is part of gedit-code-assistant.
 *
 * Copyright (C) 2011 - Jesse van den Kieboom
 *
 * gedit-code-assistant is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * gedit-code-assistant is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gedit-code-assistant.  If not, see <http://www.gnu.org/licenses/>.
 */

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
