#!/usr/bin/python

from gi.repository import Gtk
from os import popen
g_font=''

def on_exit():
    popen("RogueOS set_font '"+g_font+"'")
    popen('i3-msg reload')
    Gtk.main_quit()

class TextViewWindow:
    def __init__(self):
        self.window = Gtk.Window()
        self.window.set_default_size(400, 100)

        main_vbox = Gtk.VBox(homogeneous=False, spacing=0)
        self.window.add(main_vbox)

        self.tview = Gtk.ScrolledWindow()
        main_vbox.add(self.tview)

        #self.textview = Gtk.TextView()
        #self.textbuffer = self.textview.get_buffer()
        #self.textbuffer.set_text("Here is a text view.")
        #self.textview.set_wrap_mode(Gtk.WrapMode.WORD)

        #self.tview.add(self.textview)

        self.font_button = Gtk.FontButton()
        self.font_button.connect('font-set', self.on_font_set)
        main_vbox.pack_start(self.font_button, False, False, 0)

        self.window.show_all()
        self.window.connect('destroy', on_exit)

    def on_font_set(self, widget):
        font_description = widget.get_font_desc()
        print "You chose: " + widget.get_font()
        self.textview.modify_font(font_description)

def main():
    app = TextViewWindow()
    Gtk.main()