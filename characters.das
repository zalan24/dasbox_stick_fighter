require daslib/media
require daslib/decs_boost

struct PointTransform
    translation: float2 = float2(0.0, 0.0)
    rotation: float = 0.0

def transformTmPoint(tm; point: float2)
    let sn = sin(tm.rotation)
    let cs = cos(tm.rotation)
    return float2(cs*point.x + sn*point.y + tm.translation.x, cs*point.y - sn*point.x + tm.translation.y)

def getDirection(pointTm)
    return normalize(transformTmPoint(pointTm, float2(0.0, 1.0)) - transformTmPoint(pointTm, float2(0.0, 0.0)))

def getConnectingPolynomial(a; b; scale: float)
    // t : [0, 1]
    // p(t) = a*t^3 + b*t^2 + c*t + d
    // p(0) = a.translation
    // p(1) = b.translation
    // p'(0) = a.dir * scale
    // p'(1) = b.dir * scale
    // d = a.translation
    // a + b + c + d = b.translation
    // c = a.dir * scale
    // 3*a + 2*b + c = b.dir * scale

    // d = a.translation
    // c = a.dir * scale

    // a + b = b.translation - d - c
    // 3*a + 2*b = b.dir * scale - c

    // a = b.translation - d - c - b
    // 3*a + 2*b = b.dir * scale - c

    // 3*(b.translation - d - c - b) + 2*b = b.dir * scale - c
    // 3*b.translation - 3*d - 3*c - 3*b + 2*b = b.dir * scale - c
    // - b = b.dir*scale + 2*c + 3*d - 3*b.translation
    // b = 3*b.translation - b.dir*scale - 2*c - 3*d
    var ret : float2[4]
    ret[3] = a.translation
    ret[2] = getDirection(a) * scale
    ret[1] = 3.0 * b.translation + getDirection(b) * scale - 2.0*ret[2] - 3.0*ret[3]
    ret[0] = b.translation - ret[3] - ret[2] - ret[1]
    return ret

// lhs * (rhs * pos) = (lhs * rhs) * pos
def transformTmTm(lhs; rhs)
    return [[PointTransform
        translation=transformTmPoint(lhs, rhs.translation),
        rotation=lhs.rotation+rhs.rotation]]

struct Posture
    transforms : table<string; PointTransform>

struct PointLink
    from : string
    to : string
    fromAngleOffset : float = 0.0
    toAngleOffset : float = 0.0
    width : float = 1.0
    curveStrength : float = 1.0

struct BodyPlan
    points : array<string>
    postures : table<string; Posture>
    links : array<PointLink>

struct BodyState
    pointTransforms: table<string; PointTransform>

let shared BodyPlans <- {{
    "knight" => [[BodyPlan
                    points<-[{auto "chest"; "waist"; "knee_left"; "knee_right"; "heel_left"; "heel_right"; "foot_left"; "foot_right";
                                    "neck"; "elbow_left"; "elbow_right"; "hand_left"; "hand_right"}],
                    links<-[{auto
                        [[PointLink from="neck", to="chest"]];
                        [[PointLink from="chest", to="waist"]];
                        [[PointLink from="chest", to="elbow_left", curveStrength=0.5, fromAngleOffset=-PI/2.0]];
                        [[PointLink from="chest", to="elbow_right", curveStrength=0.5, fromAngleOffset=PI/2.0]];
                        [[PointLink from="elbow_left", to="hand_left"]];
                        [[PointLink from="elbow_right", to="hand_right"]];
                        [[PointLink from="waist", to="knee_left", curveStrength=0.3]];
                        [[PointLink from="waist", to="knee_right", curveStrength=0.3]];
                        [[PointLink from="knee_left", to="heel_left", curveStrength=0.3]];
                        [[PointLink from="knee_right", to="heel_right", curveStrength=0.3]];
                        [[PointLink from="heel_left", to="foot_left", curveStrength=0.1, fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0]];
                        [[PointLink from="heel_right", to="foot_right", curveStrength=0.1, fromAngleOffset=-PI/2.0, toAngleOffset=PI/2.0]]
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
                            "foot_right" => [[PointTransform translation=float2(0.35, 0.02)]];
                            "elbow_left" => [[PointTransform translation=float2(-0.3, 1.1)]];
                            "elbow_right" => [[PointTransform translation=float2(0.3, 1.1)]];
                            "hand_left" => [[PointTransform translation=float2(-0.27, 0.75)]];
                            "hand_right" => [[PointTransform translation=float2(0.27, 0.75)]]
                        }}]]
                    }}
                ]]
}}

def initialize_body_state(body: string; starting_posture: string)
    var ret = new BodyState
    let bodyPlanP = find(BodyPlans, body)
    assert(bodyPlanP != null, "Unknown body plan")
    let postureP = find(deref(bodyPlanP).postures, starting_posture)
    assert(postureP != null, "Posture not found")
    for p in deref(bodyPlanP).points
        let tm = find(deref(postureP).transforms, p)
        assert(tm != null, "Point transform from body plan not found in posture")
        ret.pointTransforms[p] = deref(tm)
    return ret

// TODO animation
def get_target_body_state(body: string; starting_posture: string)
    var ret = new BodyState
    let bodyPlanP = find(BodyPlans, body)
    assert(bodyPlanP != null, "Unknown body plan")
    let postureP = find(deref(bodyPlanP).postures, starting_posture)
    assert(postureP != null, "Posture not found")
    for p in deref(bodyPlanP).points
        let tm = find(deref(postureP).transforms, p)
        assert(tm != null, "Point transform from body plan not found in posture")
        ret.pointTransforms[p] = deref(tm)
    return ret

[decs_template]
struct Character
    size: float = 1.0
    flipped: bool = false
    tm: PointTransform
    body: string
    posture: string
    bodyState: BodyState?

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
    assert(c.bodyState != null, "bodyState is null on character")
    let bodyPlanP = find(BodyPlans, c.body)
    assert(bodyPlanP != null, "Unknown body plan")
    for link in bodyPlanP.links
        let fromTm = find(c.bodyState.pointTransforms, link.from)
        let toTm = find(c.bodyState.pointTransforms, link.to)
        assert(fromTm != null)
        assert(toTm != null)
        var transformedFromTm = transformTmTm(c.tm, deref(fromTm))
        var transformedToTm = transformTmTm(c.tm, deref(toTm))
        fill_circle(transformedFromTm.translation.x, -transformedFromTm.translation.y, 0.02*c.size, 0xFFFFFF)
        fill_circle(transformedToTm.translation.x, -transformedToTm.translation.y, 0.02*c.size, 0xFFFFFF)

        transformedFromTm.rotation += link.fromAngleOffset
        transformedToTm.rotation += link.toAngleOffset
        let polynomial = getConnectingPolynomial(transformedFromTm, transformedToTm, c.size*link.curveStrength)
        // let da = polynomial[2]
        // let db = 3.0*polynomial[0] + 2.0*polynomial[1] + polynomial[2]
        for i in range(100)
            let t = float(i) / 100.0
            let pos = polynomial[0] * t*t*t + polynomial[1] * t*t + polynomial[2] * t + polynomial[3]
            fill_circle(pos.x, -pos.y, 0.01*c.size, 0xFF0000)
        // setup_2d_camera(float2(get_screen_width() / 2, get_screen_height() / 2), 1.0)
        // text_out(10, 30, "da: {da} db: {db}    sin({link.fromAngleOffset}) = {sin(link.fromAngleOffset)}  sin({link.toAngleOffset})={sin(link.toAngleOffset)}", 0xF0F0F0)

def create_character_entity(body: string; starting_posture: string; pos: float2; size: float)
    var tm <- [[PointTransform translation=pos, rotation=0.0]]
    create_entity <| @ (eid, cmp)
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Character size = size, flipped = false, body=body, posture=starting_posture, tm=tm, bodyState=initialize_body_state(body, starting_posture)]])
    commit()