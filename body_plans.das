require daslib/media
require daslib/decs_boost

struct PointTransform
    translation: float2 = float2(0.0, 0.0)
    rotation: float = 0.0

struct Posture
    transforms : table<string; PointTransform>

struct PointLink
    from : string
    to : string
    fromAngleOffset : float = 0.0
    toAngleOffset : float = 0.0
    width : float = 1.0

struct BodyPlan
    points : array<string>
    postures : table<string; Posture>
    links : array<PointLink>

let shared BodyPlans <- {{
    "knight" => [[BodyPlan
                    points<-[{auto "chest"; "waist"; "knee_left"; "knee_right"; "heel_left"; "heel_right"; "foot_left"; "foot_right";
                                    "neck"}],
                    links<-[{auto
                        [[PointLink from="neck", to="chest"]];
                        [[PointLink from="chest", to="waist"]];
                        [[PointLink from="waist", to="knee_left"]];
                        [[PointLink from="waist", to="knee_right"]];
                        [[PointLink from="knee_left", to="heel_left"]];
                        [[PointLink from="knee_right", to="heel_right"]];
                        [[PointLink from="heel_left", to="foot_left"]];
                        [[PointLink from="heel_right", to="foot_right"]]
                    }],
                    postures<-{{
                        "idle" => [[Posture transforms<-{{
                            "chest" => [[PointTransform translation=float2(0.0, 1.5)]];
                            "neck" => [[PointTransform translation=float2(0.0, 1.6)]];
                            "waist" => [[PointTransform translation=float2(0.0, 0.9)]];
                            "knee_left" => [[PointTransform translation=float2(-0.3, 0.45)]];
                            "knee_right" => [[PointTransform translation=float2(0.3, 0.45)]];
                            "heel_left" => [[PointTransform translation=float2(-0.25, 0.05)]];
                            "heel_right" => [[PointTransform translation=float2(0.25, 0.05)]];
                            "foot_left" => [[PointTransform translation=float2(-0.35, 0.02)]];
                            "foot_right" => [[PointTransform translation=float2(0.35, 0.02)]]
                        }}]]
                    }}
                ]]
}}


[decs_template]
struct Character
    size: float = 1.0
    flipped: bool = false
    tm: PointTransform
    body: string
    posture: string
    // pointTms: array<PointTransform>

def create_player_knight(pos: float2; size: float)
    var tm <- [[PointTransform translation=pos, rotation=0.0]]
    create_entity <| @ (eid, cmp)
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Character size = size, flipped = false, body="knight", posture="idle", tm=tm]])
    commit()

// def make_particle(pos, vel: float2; radius: float)
//     create_entity <| @ ( eid, cmp )
//         cmp |> set("eid", eid)
//         apply_decs_template(cmp, [[Particle pos = pos, vel = vel, radius = radius]])

// [decs(stage = update)]
// def update_character_animation(var p: Particle)
//     let dt = get_delta_time()
//     let sw = float(get_screen_width())
//     let sh = float(get_screen_height())
//     p.vel.y += dt * 1200.0
//     p.pos += dt * p.vel
//     if p.pos.x < p.radius
//         p.pos.x = p.radius
//         p.vel.x = -p.vel.x
//     if p.pos.x > sw - p.radius
//         p.pos.x = sw - p.radius
//         p.vel.x = -p.vel.x
//     if p.pos.y > sh - p.radius
//         p.pos.y = sh - p.radius
//         p.vel.y = -p.vel.y

[decs(stage = draw)]
def draw_character(var c: Character)
    fill_circle(c.tm.translation.x, c.tm.translation.y, 0.1*c.size, 0xFFFFFF)
