require daslib/media
require daslib/decs_boost
require platform

// [decs(stage = update)]
// def update_platform(var p: Platform&)

[decs(stage = draw)]
def draw_platform(p: Platform)
    fill_rect(p.pos.x-p.size.x/2.0, -(p.pos.y-p.size.y/2.0), p.size.x, p.size.y, 0xF0F0F0)