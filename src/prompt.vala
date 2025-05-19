
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
        //  stdout.write("created", size_t size)
    }

    public async unowned string password_async(GLib.Cancellable? cancellable) {
        debug("password_async initiated");
        _pass_async_cb = password_async.callback;
        
        warn_if_fail (_pass_async_cb == null);

        mode = Mode.FOR_PASSWORD;
        shown = true;

        show_password ();

        yield;
        
        return password_entry.get_text ();
    }

    public bool complete () {
        debug("complete called");
        if (mode == Mode.NONE) { return false; };
        if (showing == false) { return false; };

        string pass = password_entry.get_text ();
        if (mode == Mode.FOR_PASSWORD) {
            if (password_new) {
                string confirm = confirm_entry.get_text ();
                if (pass != confirm) {
                    set_warning ("Passwords do not match");
                    return false;
                }
                __password_strength = calculate_password_strength (pass);
                notify_property("password-strength");
            }
        }

        Mode last_mode = mode;
        mode = Mode.NONE;

        if (last_mode == Mode.FOR_CONFIRM) {
            // FIXME: asd //  confirm_set = true;
            Idle.add(_confirm_async_cb);

        } else {
            Idle.add (_pass_async_cb);
            //  password_set = true;
        }

        return true;
    }

    public void close() {
        shown = false;
        showing = false;
        prompt_close ();
    }

    public async Gcr.PromptReply confirm_async(GLib.Cancellable? cancellable) {
        warn_if_fail (_confirm_async_cb == null);
        _confirm_async_cb = confirm_async.callback;
        yield;

        return confirmation;
    }

    public void cancel () {
        if (showing == false) {
            return;
        }

        switch (mode) {
            case Mode.NONE:
                close ();
                return;
            case Mode.FOR_CONFIRM:
                confirmation = Gcr.PromptReply.CANCEL;
                //  confirm_set = true
                Idle.add(_confirm_async_cb);
                break;
            default:
                return;
        }
    }

    private static int calculate_password_strength (string password) {
        int upper = 0, lower = 0, digit = 0, misc = 0;
        double pwstrength;
        int length = password.length;

        if (length == 0)
            return 0;
    
        for (int i = 0; i < length; i++) {
            char c = password[i];
            if (c.isdigit())
                digit++;
            else if (c.islower())
                lower++;
            else if (c.isupper())
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
    
        pwstrength = ((length * 1) - 2) +
                     (digit * 1) +
                     (misc * 1.5) +
                     (upper * 1);
    
        // Always return at least 1.0 for non-empty passwords
        if (pwstrength < 1.0)
            pwstrength = 1.0;
        if (pwstrength > 10.0)
            pwstrength = 10.0;
    
        return (int) pwstrength;
    }    
}