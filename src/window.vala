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

    public Prompt prompt;

    public Window () {
        prompt.password_entry = password_entry;
        prompt.confirm_entry = confirm_password_entry;

        prompt.connect ("show-password", on_show_password);
        prompt.connect ("prompt-close", on_close);
        
        prompt.bind_property ("title", title_label, "label", BindingFlags.SYNC_CREATE, null, null);
        prompt.bind_property ("description", description_label, "label", BindingFlags.SYNC_CREATE, null, null);
        prompt.bind_property ("cancel-label", cancel_btt, "label", BindingFlags.SYNC_CREATE, null, null);

        unlock_btt.connect ("clicked", on_unlock_clicked);
        cancel_btt.connect ("clicked", on_cancel_clicked);

        //  prompt.connect ("show-confirm", on_show_confirm);
    }

    private void set_sensitivity (bool sensitive) {
        password_entry.set_sensitive (sensitive);
        confirm_password_entry.set_sensitive (sensitive);
        unlock_btt.set_sensitive (sensitive);
        cancel_btt.set_sensitive (sensitive);
    }

    private void on_unlock_clicked () {
        set_sensitivity (false);
        prompt.complete ();
    }

    private void on_cancel_clicked () {
        prompt.cancel ();
    }

    private void on_show_password () {
        password_entry.set_text ("");
        password_entry.grab_focus ();
    }

    private void on_close () {
        close ();
    }

    //  private void on_show_confirm () {
    //      confirm_password_rev.set_reveal_child (true);

    //  }
}