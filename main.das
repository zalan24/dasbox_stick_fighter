require daslib/media
require daslib/decs_boost
require body_plans

// var image1: Image
// var frameTime: float

[export]
def initialize(is_hard_reload: bool)
    set_window_title("Stick Fight")

    if is_hard_reload
        create_player_knight(float2(0.0, 0.0), 1.0)
        create_player_knight(float2(1.0, 0.0), 1.0)
        create_player_knight(float2(1.0, -1.0), 1.0)
    setup_2d_camera(float2(0.0, -0.7), 200.0)

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    // frameTime = dt

    decs_stage("update")
    return

[export]
def draw
    decs_stage("draw")

    // let fps = 1.0 / frameTime
    // text_out(100, 10, "fps: {fps}", 0xF0F0F0)

    // let mousePos = get_mouse_position()
    // fill_circle(int(mousePos.x), int(mousePos.y), 5, 0xFFFF80)

    // draw_image(image1, 0, 0)
    return
