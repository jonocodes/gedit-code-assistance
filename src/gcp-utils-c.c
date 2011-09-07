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
