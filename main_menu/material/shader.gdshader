shader_type canvas_item;

// Variabile per controllare l'intensità della sfocatura.
// Un valore maggiore produce una sfocatura maggiore.
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0; 

// La texture dello schermo. In Godot 4, di solito si usa 'hint_screen_texture'.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Utilizza la funzione 'textureLod' per campionare un mipmap specifico 
    // della texture dello schermo.
    // L'indice del mipmap è determinato da 'blur_amount'.
    vec4 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    
    // Assegna il colore sfocato al pixel.
    COLOR = screen_color;
    
    // Se vuoi anche un controllo sulla trasparenza:
    COLOR = vec4(screen_color.rgb, 1.0); // Imposta l'alfa a 1.0
}