[GtkTemplate (ui = "/com/github/XtremeTHN/GPrompt/ui/window.ui")]
public class GPrompt.Window : Adw.ApplicationWindow {
  [GtkChild]
  public unowned Gtk.Label title_label;

  [GtkChild]
  public unowned Gtk.Label description_label;

  [GtkChild]
  public unowned Gtk.PasswordEntry password_entry;

  [GtkChild]
  public unowned Gtk.Revealer confirm_password_rev;

  [GtkChild]
  public unowned Gtk.PasswordEntry confirm_password_entry;

  [GtkChild]
  public unowned Gtk.LevelBar password_strength_level;

  [GtkChild]
  public unowned Gtk.Button unlock_btt;

  [GtkChild]
  public unowned Gtk.Button cancel_btt;

  [GtkChild]
  public unowned Gtk.Revealer warn_rev;

  [GtkChild]
  public unowned Gtk.Label warn_label;

  public Prompt prompt;
  private Background back;

  public Window (double background_opacity) {
    back = new Background ();
    back.set_opacity (background_opacity);
    back.present ();

    GtkLayerShell.init_for_window (this);
    GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);
    GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.ON_DEMAND);

    prompt = new Prompt ();
    prompt.password_entry = password_entry;
    prompt.confirm_entry = confirm_password_entry;

    prompt.show_password.connect (on_show_password);
    prompt.prompt_close.connect (on_close);

    prompt.bind_property ("title", title_label, "label", BindingFlags.SYNC_CREATE, null, null);
    prompt.bind_property ("description", description_label, "label", BindingFlags.SYNC_CREATE, null, null);
    prompt.bind_property ("cancel-label", cancel_btt, "label", BindingFlags.SYNC_CREATE, null, null);

    // TODO: Implement this
    // prompt.bind_property ("confirm-visible", confirm_password_rev, "visible", BindingFlags.SYNC_CREATE, null, null);
    // prompt.bind_property ("warning", warn_rev, "reveal-child", BindingFlags.SYNC_CREATE, show_revealer, null);
    prompt.notify.connect (show_revealer);

    unlock_btt.clicked.connect (on_unlock_clicked);
    cancel_btt.clicked.connect (on_cancel_clicked);

    close_request.connect (on_window_close);

    password_strength_level.add_offset_value ("low", 2);
    password_strength_level.add_offset_value ("high", 5);
    password_strength_level.add_offset_value ("full", 7);
  }

  private void show_revealer () {
    info (prompt.warning);
    info ("%b", prompt.warning != "");
  }

  private void set_sensitivity (bool sensitive) {
    password_entry.set_sensitive (sensitive);
    confirm_password_entry.set_sensitive (sensitive);
    unlock_btt.set_sensitive (sensitive);
    cancel_btt.set_sensitive (sensitive);
  }

  private void on_unlock_clicked (Gtk.Button _) {
    set_sensitivity (false);
    prompt.complete ();
  }

  private void on_cancel_clicked (Gtk.Button _) {
    prompt.cancel ();
  }

  private void on_show_password () {
    present ();

    set_sensitivity (true);
    if (prompt.warning != "") {
      warn_rev.set_reveal_child (true);
      warn_label.set_label (prompt.warning);
    } else {
      warn_rev.set_reveal_child (false);
    }
    password_entry.grab_focus ();

    if (prompt.password_new) {
      message ("New password");
      confirm_password_entry.set_text ("");
      confirm_password_rev.set_reveal_child (true);

      password_entry.notify["text"].connect (on_confirm_pass_text_change);
      unlock_btt.set_child (new Gtk.Label ("Confirm"));
    } else {
      password_entry.set_text ("");
    }
  }

  private void on_confirm_pass_text_change () {
    var strength = calculate_password_strength (password_entry.get_text ());

    password_strength_level.set_value (strength);
    // message ("%i", calculate_password_strength (password_entry.get_text ()));
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

  private void on_close () {
    back.close ();
    close ();
  }

  private bool on_window_close () {
    prompt.cancel ();
    return false;
  }
}