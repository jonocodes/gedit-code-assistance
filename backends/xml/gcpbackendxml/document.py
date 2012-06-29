# gcp xml backend
# Copyright (C) 2012  Jono Finger <jono@foodnotblogs.com>
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

from lxml import etree
import threading, os, sys, traceback


class ParseThread(threading.Thread):

    def __init__(self, doc, finishCallBack):
        threading.Thread.__init__(self)

        self.source_file = None

        doc = doc.props.document

        bounds = doc.get_bounds()
        self.source_contents = bounds[0].get_text(bounds[1])

        if doc.get_location():
            self.source_file = doc.get_location().get_path()
            
        if not self.source_file:
            self.source_file = '<unknown>'

        self.clock = threading.Lock()
        self.cancelled = False
        self.finishCallBack = finishCallBack

        self.parse_errors = []

        self.idle_finish = 0

    def cancel(self):
        self.clock.acquire()
        self.cancelled = True

        if self.idle_finish != 0:
            GLib.source_remove(self.idle_finish)

        self.clock.release()

    def finish_in_idle(self):
        self.finishCallBack(self.parse_errors)

    def getSchema(self, location, schemaText=None):

        schemaType = None
        schemaXml = None

        # get the schema text if needed
        if schemaText == None:

            if location.find('http://') == 0 or location.find('http://') == 0:
                raise Exception("Schema reference must be a local file")
                # TODO: handle location when it is a URL

            # now we assume it is a local file reference
            if not os.path.isabs(location):
                location = os.path.join( os.path.dirname(self.source_file), location)

            with file(location) as f:
                schemaText = f.read()

        # parse the schema XML, exception to be caught outside this function
        schemaXml = etree.fromstring(schemaText)

        # first check the namespace
        if None in schemaXml.nsmap and schemaXml.nsmap[None] == 'http://relaxng.org/ns/structure/1.0':
            schemaType = "RelaxNG"
        elif 'xs' in schemaXml.nsmap and schemaXml.nsmap['xs'] == "http://www.w3.org/2001/XMLSchema":
            schemaType = "XSD"
        else:
        # then check the file extension
            extension = os.path.splitext(self.source_file)[1].lower()

            if extension == '.rng':
                schemaType = "RelaxNG"
            elif extension == '.xsd':
                schemaType = "XSD"
            # TODO: add .rnc support
            # http://infohost.nmt.edu/tcc/help/pubs/pylxml/web/val-mod-RelaxValidator-trang.html

        return {'type':schemaType, 'xml':schemaXml}

    def addError(self, prefix, error, line = 1, column = 1):

        if type(error) is etree._LogEntry:

            # specially handle the case where line is 0 since docs start at line 1
            if error.line != 0:
                line = error.line
            if error.column != 0:
                column = error.column

            self.parse_errors.append((line, column, prefix + ": " + error.message))
            
        else:   # it is probably a string or an Exception
            self.parse_errors.append((line, column, prefix + ": " + str(error)))


    def lookForSchema(self, xml):
        
        """ This function looks through the comment tags for a schema reference
            it returns on the first reference it finds in no particular order """
            
        for pre in (True, False):

            for comment in xml.itersiblings(tag=etree.Comment, preceding=pre):
                
                refLine = comment.text.split(':', 1)

                if refLine[0].strip().lower() == 'schema' and len(refLine) == 2:

                    schemaLocation = refLine[1].strip()
                    schemaRef = self.getSchema(schemaLocation)

                    if schemaRef != None and schemaRef['type'] != None:
                        return (schemaRef, schemaLocation, comment.sourceline)

        return (None, None, None)

        
    def run(self):

        docType = 'XML'

        etree.clear_error_log()

        try:

            # parse the XML for errors

            if self.source_file != '<unknown>':

                docSchema = self.getSchema(self.source_file, self.source_contents)
                xml = docSchema['xml']

                if docSchema['type'] != None:
                    docType = docSchema['type']

            else:
                xml = etree.fromstring(self.source_contents)

            # if the doc is a schema itself, parse it for schema errors

            try:
                if docType == "XSD":
                    etree.XMLSchema(xml)
                elif docType == "RelaxNG":
                    etree.RelaxNG(xml)

            except (etree.RelaxNGError, etree.XMLSchemaParseError) as e:
                for error in e.error_log:
                    self.addError(docType + " parsing error", error)
               
            except Exception as e:
                self.addError(docType + " parsing error", e)


            # parse XML comments in document for a reference to a schema

            try:

                (schemaRef, schemaLocation, commentLine) = self.lookForSchema(xml)
                
                if schemaRef != None:

                    try:
                        if schemaRef['type'] == "XSD":
                            schema = etree.XMLSchema(schemaRef['xml'])
                        elif schemaRef['type'] == "RelaxNG":
                            schema = etree.RelaxNG(schemaRef['xml'])

                        schema.assertValid(xml)

                    except (etree.DocumentInvalid, etree.RelaxNGValidateError, etree.XMLSchemaValidateError):
                        for error in schema.error_log:
                            self.addError(schemaRef['type'] + " validation error", error)

                    except (etree.RelaxNGError, etree.XMLSchemaParseError):
                        self.addError(schemaRef['type'] + " error", "Schema is invalid " + schemaLocation, commentLine)

                    except Exception as e:
                        self.addError(schemaRef['type'] + " error", e)

            except etree.XMLSyntaxError as e:
                self.addError("Schema error", "Unable to parse schema XML " + schemaLocation, commentLine)

            except Exception as e:
                self.addError("Schema error", e, commentLine)


        # handle XML parse errors

        except etree.XMLSyntaxError as e:
            for error in e.error_log:
                self.addError("XML parsing error", error)

        # ignore other exceptions
        
        except:
            pass

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

    def on_parse_finished(self, errors):
        self.reparse_thread = None

        diags = Gcp.SourceIndex()

        for error in errors:
            loc = Gcp.SourceLocation.new(self.props.document.get_location(),
                                     error[0],
                                     error[1])

            diags.add(Gcp.Diagnostic.new(Gcp.DiagnosticSeverity.ERROR,
                                         loc,
                                         [],
                                         [],
                                         error[2]))

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

