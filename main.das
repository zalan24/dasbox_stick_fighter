require daslib/media
require daslib/decs_boost
require characters

var frameTime : float = 0.0

def create_player_knight(pos: float2; size: float)
    create_character_entity("knight", "default", pos, size)

[export]
def initialize(is_hard_reload: bool)
    set_window_title("Stick Fight")

    // exportCharacters()

    if is_hard_reload
        // create_player_knight(float2(0.0, 0.0), 1.0)
        create_character_entity("knight", "default", float2(-2.0, -1.0), 1.0)
        create_character_entity("bug", "default", float2(-0.66, 0.7), 1.0)
        create_character_entity("knight", "default", float2(0.66, -1.0), 1.0)
        create_character_entity("knight", "default", float2(2.0, 0.7), 1.0)

[export]
def act(dt: float)
    // if get_key(VK_ESCAPE)
    //     schedule_quit_game()
    frameTime = dt

    decs_stage("update")
    return

[export]
def draw
    setup_2d_camera(float2(0.0, -0.7), 200.0)
    decs_stage("draw")
    setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)

    let fps = 1.0 / frameTime
    text_out(10, 10, "fps: {fps}", 0xF0F0F0)

    let mousePos = get_mouse_position()
    fill_circle(int(mousePos.x), int(mousePos.y), 5, 0xFFFF80)

    // if editor_mode

    return
