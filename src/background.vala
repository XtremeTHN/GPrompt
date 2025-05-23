public class GPrompt.Background : Adw.ApplicationWindow {
    public Background () {
        Object ();
        GtkLayerShell.init_for_window (this);
        GtkLayerShell.set_namespace (this, "gprompt-background");
        GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);

        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.TOP, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.RIGHT, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.BOTTOM, true);
        GtkLayerShell.set_anchor (this, GtkLayerShell.Edge.LEFT, true);
    }
}