
public class App : Adw.Application {
    public Gcr.SystemPrompter prompter;
    double opacity = 0.5;
    public App () {
        Object (
            application_id: "com.github.XtremeTHN.GPrompt",
            flags: ApplicationFlags.IS_SERVICE
        );
    }

    private Gcr.Prompt on_new_prompt () {
        var window = new GPrompt.Window (opacity);
        add_window (window);
        return window.prompt;
    }

    protected override void startup () {
        base.startup ();
        var op_var = GLib.Environment.get_variable ("XTREME_BACKGROUND_OPACITY");
        if (op_var != null) {
            opacity = double.parse (op_var);
        }

        prompter = new Gcr.SystemPrompter (Gcr.SystemPrompterMode.MULTIPLE, 0);

        var provider = new Gtk.CssProvider ();
        // this fixes the window not having borders
        provider.load_from_string (".fullscreen { outline: 1px solid rgb(255 255 255 / 7%); outline-offset: -1px; border-radius: 14px; }");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

        try {
            var conn = Bus.get_sync (BusType.SESSION, null);
            prompter.register (conn);
            GLib.Bus.own_name_on_connection (conn, "org.gnome.keyring.SystemPrompter", BusNameOwnerFlags.ALLOW_REPLACEMENT, null, null);

            prompter.new_prompt.connect (on_new_prompt);            
        } catch (Error e) {
            critical ("Couldn't register prompter %s", e.message);
            return;
        }

        hold ();
    }

    public static int main(string[] args) {
        var app = new App ();
        return app.run (args);
    }
}
