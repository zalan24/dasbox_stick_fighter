require daslib/media
require daslib/decs_boost
require characters
require platform
require drawplatform

var frameTime : float = 0.0

def initialize_level()
    create_platform_entity(float2(0.0, -1.0), float2(10.0, 0.1))
    create_platform_entity(float2(-4.5, 1.0), float2(2.0, 0.1))
    create_platform_entity(float2(4.5, 1.0), float2(2.0, 0.1))
    create_platform_entity(float2(0.0, 3.0), float2(2.0, 0.1))

[export]
def initialize(is_hard_reload: bool)
    set_window_title("Stick Fight")

    // exportCharacters()

    if is_hard_reload
        initialize_level()
        create_player(float2(-2.0, 1.0), 1.0)
        create_bug(float2(-0.66, 0.7), 1.0)
        create_mosquito(float2(0.66, -1.0), 1.0)
        // create_character_entity("knight", "default", float2(2.0, 0.7), 1.0)

[export]
def act(dt: float)
    // if get_key(VK_ESCAPE)
    //     schedule_quit_game()
    frameTime = dt

    decs_stage("update")
    return

[export]
def draw
    setup_2d_camera(float2(0.0, -2.5), 100.0)
    decs_stage("draw")
    setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)

    let fps = 1.0 / frameTime
    text_out(10, 10, "fps: {fps}", 0xF0F0F0)

    let mousePos = get_mouse_position()
    fill_circle(int(mousePos.x), int(mousePos.y), 5, 0xFFFF80)

    // if editor_mode

    return
