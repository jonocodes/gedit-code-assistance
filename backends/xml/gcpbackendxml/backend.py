# gcp xml backend
# Copyright (C) 2012  Jesse van den Kieboom <jessevdk@gnome.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

from gi.repository import GObject, Gcp
from document import Document

class Backend(GObject.Object, Gcp.Backend):
    size = GObject.property(type=int, flags = GObject.PARAM_READABLE)

    def __init__(self):
        GObject.Object.__init__(self)

        self.documents = []

    def do_get_property(self, spec):
        if spec.name == 'size':
            return len(self.documents)

        GObject.Object.do_get_property(self, spec)

    def do_register_document(self, doc):
        d = Document(document=doc)
        self.documents.append(d)

        d.connect('changed', self.on_document_changed)
        return d

    def do_unregister_document(self, doc):
        doc.disconnect_by_func(self.on_document_changed)
        self.documents.remove(doc)

    def do_get(self, idx):
        return self.documents[idx]

    def on_document_changed(self, doc):
        doc.update()

# ex:ts=4:et:
