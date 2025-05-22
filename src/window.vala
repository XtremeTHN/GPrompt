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

    public Window () {
        back = new Background ();
        back.present ();

        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);
        GtkLayerShell.set_keyboard_mode (this, GtkLayerShell.KeyboardMode.ON_DEMAND);

        prompt = new Prompt ();
        prompt.password_entry = password_entry;
        prompt.confirm_entry = confirm_password_entry;

        prompt.show_password.connect(on_show_password);
        prompt.prompt_close.connect (on_close);

        prompt.bind_property ("title", title_label, "label", BindingFlags.SYNC_CREATE, null, null);
        prompt.bind_property ("description", description_label, "label", BindingFlags.SYNC_CREATE, null, null);
        prompt.bind_property ("cancel-label", cancel_btt, "label", BindingFlags.SYNC_CREATE, null, null);

        // TODO: Implement this
        //  prompt.bind_property ("confirm-visible", confirm_password_rev, "visible", BindingFlags.SYNC_CREATE, null, null);
        //  prompt.bind_property ("warning", warn_rev, "reveal-child", BindingFlags.SYNC_CREATE, show_revealer, null);
        prompt.notify.connect (show_revealer);

        unlock_btt.clicked.connect ( on_unlock_clicked);
        cancel_btt.clicked.connect (on_cancel_clicked);

        close_request.connect (on_window_close);
    }

    private void show_revealer () {
        info(prompt.warning);
        info("%b", prompt.warning != "");
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
        password_entry.set_text ("");
        password_entry.grab_focus ();
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