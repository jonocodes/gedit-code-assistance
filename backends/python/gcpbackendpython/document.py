# gcp python backend
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

from gi.repository import GObject, Gcp, GLib, Gio

import ast
import threading

class ParseThread(threading.Thread):
    def __init__(self, doc, finishcb):
        threading.Thread.__init__(self)

        self.source_file = None

        doc = doc.props.document

        if doc.get_location():
            self.source_file = doc.get_location().get_path()

        if not self.source_file:
            self.source_file = '<unknown>'

        bounds = doc.get_bounds()
        self.source_contents = bounds[0].get_text(bounds[1])

        self.clock = threading.Lock()
        self.cancelled = False
        self.finishcb = finishcb

        self.parse_error = None
        self.ast = None

        self.idle_finish = 0

    def cancel(self):
        self.clock.acquire()
        self.cancelled = True

        if self.idle_finish != 0:
            GLib.source_remove(self.idle_finish)

        self.clock.release()

    def finish_in_idle(self):
        self.finishcb(self.ast, self.parse_error)

    def run(self):
        # Here we have the lock, reparse now
        try:
            self.ast = ast.parse(self.source_contents, self.source_file)
        except Exception as e:
            self.parse_error = e

        self.clock.acquire()

        if not self.cancelled:
            self.idle_finish = GLib.idle_add(self.finish_in_idle)

        self.clock.release()

class Document(Gcp.Document, Gcp.DiagnosticSupport):
    def __init__(self, **kwargs):
        Gcp.Document.__init__(self, **kwargs)

        self.reparse_timeout = 0
        self.diagnostics = Gcp.SourceIndex()
        self.reparse_thread = None
        self.tags = None
        self.diagnostics_lock = threading.Lock()

    def do_get_diagnostic_tags(self):
        return self.tags

    def do_set_diagnostic_tags(self, tags):
        self.tags = tags

    def update(self):
        # Need to parse ourselves again
        if self.reparse_timeout != 0:
            GLib.source_remove(self.reparse_timeout)

        if self.reparse_thread != None:
            self.reparse_thread.cancel()
            self.reparse_thread = None

        self.reparse_timeout = GLib.timeout_add(300, self.on_reparse_timeout)

    def on_reparse_timeout(self):
        self.reparse_timeout = 0

        self.reparse_thread = ParseThread(self, self.on_parse_finished)
        self.reparse_thread.run()

        return False

    def on_parse_finished(self, ast, error):
        self.reparse_thread = None

        diags = Gcp.SourceIndex()

        if error:
            loc = Gcp.SourceLocation.new(self.props.document.get_location(),
                                     error.lineno,
                                     error.offset)

            diags.add(Gcp.Diagnostic.new(Gcp.DiagnosticSeverity.ERROR,
                                         loc,
                                         [],
                                         [],
                                         error.msg))

        self.diagnostics_lock.acquire()
        self.diagnostics = diags
        self.diagnostics_lock.release()

        self.emit('diagnostics-updated')

    def do_begin_diagnostics(self):
        self.diagnostics_lock.acquire()
        return self.diagnostics

    def do_end_diagnostics(self):
        self.diagnostics_lock.release()

# vi:ex:ts=4:et

