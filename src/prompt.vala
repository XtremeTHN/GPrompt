
public class GPrompt.Prompt : Object, Gcr.Prompt {
  public string caller_window { owned get; set construct; }
  public string cancel_label { owned get; set construct; }
  public bool choice_chosen { get; set; }
  public string choice_label { owned get; set construct; }
  public string continue_label { owned get; set construct; }
  public string description { owned get; set construct; }
  public string message { owned get; set construct; }
  public bool password_new { get; set; }

  private int __password_strength = 0;
  public int password_strength {
    get {
      return __password_strength;
    }
  }
  public string title { owned get; set construct; }
  public string warning { owned get; set construct; }

  public Gcr.PromptReply confirmation { get; set; }

  public Gtk.PasswordEntry? password_entry { get; set; }
  public Gtk.PasswordEntry? confirm_entry { get; set; }

  private enum Mode {
    NONE,
    FOR_CONFIRM,
    FOR_PASSWORD
  }

  private Mode mode = Mode.NONE;
  private bool shown = false;
  private bool showing = false;

  private SourceFunc? _pass_async_cb;
  private SourceFunc? _confirm_async_cb;

  public signal void show_password ();
  public signal void show_confirm ();

  public Prompt () {
    Object ();
  }

  public async unowned string password_async (GLib.Cancellable? cancellable) {
    GLib.message ("password_async initiated");
    _pass_async_cb = password_async.callback;

    if (_pass_async_cb != null) {
      critical ("A prompt is already showing");
    }

    mode = Mode.FOR_PASSWORD;
    shown = true;

    show_password ();

    yield; // waits for _pass_async_cb to be called

    return password_entry.get_text ();
  }

  public bool complete () {
    GLib.message ("complete called");
    if (mode == Mode.NONE) { return false; };

    string pass = password_entry.get_text ();

    if (mode == Mode.FOR_PASSWORD) {
      if (password_new) {
        string confirm = confirm_entry.get_text ();
        if (pass != confirm) {
          set_warning ("Passwords do not match");
          show_password ();
          return false;
        }
        __password_strength = calculate_password_strength (pass);
        notify_property ("password-strength");
      }
    }

    Mode last_mode = mode;
    mode = Mode.NONE;

    if (last_mode == Mode.FOR_CONFIRM) {
      _confirm_async_cb (); // resume execution in confirm_async
    } else {
      _pass_async_cb (); // resume execution in password_async
    }

    return true;
  }

  public void close () {
    shown = false;
    showing = false;
    prompt_close ();
  }

  public async Gcr.PromptReply confirm_async (GLib.Cancellable? cancellable) {
    if (_confirm_async_cb != null) {
      critical ("A prompt is already showing");
    }

    GLib.message ("confirm");
    _confirm_async_cb = confirm_async.callback;
    yield; // waits for _confirm_async_cb to be called

    return confirmation;
  }

  public void cancel () {
    GLib.message ("cancel");
    GLib.message ("cancelled");

    switch (mode) {
    case Mode.NONE :
      GLib.message ("Mode is NONE");
      close ();
      return;
    case Mode.FOR_CONFIRM :
      GLib.message ("Mode is confirm");
      confirmation = Gcr.PromptReply.CANCEL;
      close ();
      _confirm_async_cb ();
      break;
    case Mode.FOR_PASSWORD :
      GLib.message ("Mode is password");
      close ();
      break;
    }
    _confirm_async_cb = null;
    _pass_async_cb = null;
  }

  private static int calculate_password_strength (string password) {
    int upper = 0, lower = 0, digit = 0, misc = 0;
    double pwstrength;
    int length = password.length;

    if (length == 0)
      return 0;

    for (int i = 0; i < length; i++) {
      char c = password[i];
      if (c.isdigit ())
        digit++;
      else if (c.islower ())
        lower++;
      else if (c.isupper ())
        upper++;
      else
        misc++;
    }

    // Cap values to limit their weight
    if (length > 5)
      length = 5;
    if (digit > 3)
      digit = 3;
    if (upper > 3)
      upper = 3;
    if (misc > 3)
      misc = 3;

    pwstrength = ((length * 1) - 2)
      + (digit * 1)
      + (misc * 1.5)
      + (upper * 1);

    // Always return at least 1.0 for non-empty passwords
    if (pwstrength < 1.0)
      pwstrength = 1.0;
    if (pwstrength > 10.0)
      pwstrength = 10.0;

    return (int) pwstrength;
  }
}