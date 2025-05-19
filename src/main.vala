public class App : Adw.Application {
    public App () {
        Object (
            application_id: "com.github.XtremeTHN.Exp",
            flags: ApplicationFlags.IS_SERVICE
        );
    }

    private Gcr.Prompt on_new_prompt () {
        var window = new GPrompt.Window ();
        add_window (window);
        return window.prompt;
    }

    protected override void startup () {
        hold ();
        
        var prompter = new Gcr.SystemPrompter (Gcr.SystemPrompterMode.SINGLE, typeof (GPrompt.Prompt));
        prompter.connect ("new-promt", on_new_prompt);

        try {
            var conn = Bus.get_sync (BusType.SESSION, null);
            prompter.register (conn);
            GLib.Bus.own_name_on_connection (conn, "org.gnome.keyring.SystemPrompter", BusNameOwnerFlags.ALLOW_REPLACEMENT, null, null);
        } catch (Error e) {
            critical ("Couldn't register prompter %s", e.message);
            return;
        }
    }

    public static int main(string[] args) {
        var app = new App ();
        return app.run (args);
    }
}