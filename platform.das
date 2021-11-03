require daslib/media
require daslib/decs_boost

[decs_template]
struct Platform
    pos: float2
    size: float2

// [decs(stage = update)]
// def update_platform(var p: Platform&)

[decs(stage = draw)]
def draw_platform(p: Platform)
    fill_rect(p.pos.x-p.size.x/2.0, -(p.pos.y-p.size.y/2.0), p.size.x, p.size.y, 0xF0F0F0)

def create_platform_entity(pos: float2; size: float2)
    create_entity <| @ (eid, cmp)
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Platform pos = pos, size = size]])
    commit()