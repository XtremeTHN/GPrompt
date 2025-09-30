
public class App : Adw.Application {
  public Gcr.SystemPrompter prompter;
  double opacity = 0.5;
  public App () {
    Object (
            application_id: "com.github.XtremeTHN.GPrompt",
            flags: ApplicationFlags.HANDLES_COMMAND_LINE
    );
  }

  protected override int command_line (GLib.ApplicationCommandLine command_line) {
    var args = command_line.get_arguments ();
    var ctx = new OptionContext ();

    OptionEntry[] entries = {
      { "opacity", 'o', OptionFlags.NONE, OptionArg.DOUBLE, ref opacity, "Sets the background opacity. Range from 0 to 1", "OPACITY" }
    };

    ctx.add_main_entries (entries, null);

    try {
      ctx.parse_strv (ref args);
    } catch (Error e) {
      error ("Couldn't parse arguments: %s", e.message);
    }

    if (opacity > 1 || opacity < 0) {
      warning ("Only values between 0 and 1 are allowed. Ignoring opacity…");
      opacity = 0.5;
    }

    init ();
    return 0;
  }

  private Gcr.Prompt on_new_prompt () {
    var window = new GPrompt.Window (opacity);
    add_window (window);
    return window.prompt;
  }

  void init () {
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

  public static int main (string[] args) {
    var app = new App ();
    return app.run (args);
  }
}
