require daslib/media
require daslib/decs_boost

[decs_template]
struct Platform
    pos: float2
    size: float2

def create_platform_entity(pos: float2; size: float2)
    create_entity <| @ (eid, cmp)
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Platform pos = pos, size = size]])
    commit()