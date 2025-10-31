
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
      command_line.printerr ("Couldn't parse arguments: %s\n", e.message);
      return 1;
    }

    if (opacity > 1 || opacity < 0) {
      command_line.printerr_literal ("Only values between 0 and 1 are allowed. Ignoring opacity…\n");
      opacity = 0.5;
    }

    if (command_line.is_remote) {
      command_line.printerr_literal ("GPrompt is already running\n");
      return 2;
    }

    init ();
    return 0;
  }

  private Gcr.Prompt on_new_prompt () {
    info ("New prompt requested");
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
      message ("Prompter registered.");

      prompter.new_prompt.connect (on_new_prompt);
      message ("Running...");
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