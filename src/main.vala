
public class App : Adw.Application {
    public Gcr.SystemPrompter prompter;
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
        base.startup ();

        prompter = new Gcr.SystemPrompter (Gcr.SystemPrompterMode.MULTIPLE, 0);

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