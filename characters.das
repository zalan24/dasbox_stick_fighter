require daslib/media
require daslib/decs_boost
require daslib/json

// let editor_mode : bool = true

struct PointTransform
    translation: float2 = float2(0.0, 0.0)
    rotation: float = 0.0

def transformTmPoint(tm; point: float2)
    let sn = sin(tm.rotation)
    let cs = cos(tm.rotation)
    return float2(cs*point.x + sn*point.y + tm.translation.x, cs*point.y - sn*point.x + tm.translation.y)

def getDirection(pointTm)
    return normalize(transformTmPoint(pointTm, float2(0.0, 1.0)) - transformTmPoint(pointTm, float2(0.0, 0.0)))

def fitPolynomialFloat4(a; ad; b; bd)
    var ret : float3[4]
    ret[3] = a
    ret[2] = ad
    ret[1] = 3.0 * b + bd - 2.0*ret[2] - 3.0*ret[3]
    ret[0] = b - ret[3] - ret[2] - ret[1]
    return ret

def fitPolynomialFloat3(a; ad; b; bd)
    var ret : float3[4]
    ret[3] = a
    ret[2] = ad
    ret[1] = 3.0 * b + bd - 2.0*ret[2] - 3.0*ret[3]
    ret[0] = b - ret[3] - ret[2] - ret[1]
    return ret

def fitPolynomialFloat2(a; ad; b; bd)
    var ret : float2[4]
    ret[3] = a
    ret[2] = ad
    ret[1] = 3.0 * b + bd - 2.0*ret[2] - 3.0*ret[3]
    ret[0] = b - ret[3] - ret[2] - ret[1]
    return ret

def fitPolynomialFloat(a; ad; b; bd)
    var ret : float[4]
    ret[3] = a
    ret[2] = ad
    ret[1] = 3.0 * b + bd - 2.0*ret[2] - 3.0*ret[3]
    ret[0] = b - ret[3] - ret[2] - ret[1]
    return ret

def getConnectingPolynomial(a; b; scale: float)
    return fitPolynomialFloat2(a.translation, getDirection(a) * scale, b.translation, getDirection(b) * scale)

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

struct BodyPoint
    animationWeight: table<string; float>

struct BodyPlan
    points : table<string; BodyPoint>
    postures : table<string; Posture>
    links : array<PointLink>

struct BodyState
    pointTransforms: table<string; PointTransform>
    pointTmDerivatives: table<string; PointTransform>

struct AnimationFrame
    time: float
    transformations: table<string; PointTransform>
    tmDerivatives: table<string; PointTransform>

struct Animation
    duration: float
    points: array<string>
    frames: array<AnimationFrame>

var Animations <- {{
    "test" => [[Animation duration=3.0, points<-[{auto "leg_left"; "leg_right"}],
                frames<-[{auto
                        [[AnimationFrame
                            time=0.0,
                            transformations<-{{"leg_left" => [[PointTransform translation=float2(-1.0, 0.0)]]; "leg_right" => [[PointTransform translation=float2(1.0, 0.0)]]}},
                            tmDerivatives<-{{"leg_left" => [[PointTransform translation=float2(0.0, 0.0)]]; "leg_right" => [[PointTransform translation=float2(0.0, 0.0)]]}}
                        ]];
                        [[AnimationFrame
                            time=0.5,
                            transformations<-{{"leg_left" => [[PointTransform translation=float2(1.0, 0.0)]]; "leg_right" => [[PointTransform translation=float2(-1.0, 0.0)]]}},
                            tmDerivatives<-{{"leg_left" => [[PointTransform translation=float2(0.0, 0.0)]]; "leg_right" => [[PointTransform translation=float2(0.0, 0.0)]]}}
                        ]]
                    }]
                ]]
}}

var BodyPlans <- {{
    "knight" => [[BodyPlan
                    points<-{{
                        "chest" => [[BodyPoint]];
                        "waist" => [[BodyPoint]];
                        "knee_left" => [[BodyPoint animationWeight<-{{"leg_left" => 0.3}}]];
                        "knee_right" => [[BodyPoint animationWeight<-{{"leg_right" => 0.3}}]];
                        "heel_left" => [[BodyPoint animationWeight<-{{"leg_left" => 0.9}}]];
                        "heel_right" => [[BodyPoint animationWeight<-{{"leg_right" => 0.9}}]];
                        "foot_left" => [[BodyPoint animationWeight<-{{"leg_left" => 0.9}}]];
                        "foot_right" => [[BodyPoint animationWeight<-{{"leg_right" => 0.9}}]];
                        "neck" => [[BodyPoint ]];
                        "elbow_left" => [[BodyPoint ]];
                        "elbow_right" => [[BodyPoint ]];
                        "hand_left" => [[BodyPoint ]];
                        "hand_right" => [[BodyPoint ]]
                    }},
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
    for name in keys(bodyPlanP.points)
        let tm = find(deref(postureP).transforms, name)
        assert(tm != null, "Point transform from body plan not found in posture")
        ret.pointTransforms[name] = deref(tm)
        ret.pointTmDerivatives[name] = [[PointTransform translation=float2(0.0), rotation=0.0]]
    return ret

def get_target_body_state(body: string implicit; starting_posture: string implicit; animation : Animation const?; animationState: float)
    var ret = new BodyState
    let bodyPlanP = find(BodyPlans, body)
    assert(bodyPlanP != null, "Unknown body plan")
    let postureP = find(deref(bodyPlanP).postures, starting_posture)
    assert(postureP != null, "Posture not found")

    var a = 0
    var b = 0
    var localPhase = 0.0
    if animation != null
        a = 0
        b = length(animation.frames)
        while a+1 < b
            let m = (a+b)/2
            if animation.frames[m].time <= animationState
                a = m
            else
                b = m
        b = (a+1) % length(animation.frames)
        // a = 0
        // b = 1
        localPhase = (animationState - animation.frames[a].time)
        if localPhase < 0.0
            localPhase += 1.0
        if animation.frames[b].time > animation.frames[a].time
            localPhase /= animation.frames[b].time - animation.frames[a].time
        else
            localPhase /= animation.frames[b].time + 1.0 - animation.frames[a].time
        // localPhase = animationState

    for name, data in keys(bodyPlanP.points), values(bodyPlanP.points)
        let tm = find(deref(postureP).transforms, name)
        assert(tm != null, "Point transform from body plan not found in posture")
        ret.pointTransforms[name] = deref(tm)
        ret.pointTmDerivatives[name] = [[PointTransform translation=float2(0.0), rotation=0.0]]
        if animation != null
            // ret.pointTransforms[name].translation += float2(1.0, 1.0)
            var sumWeight = 0.0
            for animPoint, weight in keys(data.animationWeight), values(data.animationWeight)
                let startTmP = find(animation.frames[a].transformations, animPoint)
                let startTmDP = find(animation.frames[a].tmDerivatives, animPoint)
                let endTmP = find(animation.frames[b].transformations, animPoint)
                let endTmDP = find(animation.frames[b].tmDerivatives, animPoint)
                assert(startTmP != null)
                assert(startTmDP != null)
                assert(endTmP != null)
                assert(endTmDP != null)
                let polynomial = fitPolynomialFloat3(
                        float3(startTmP.translation,  startTmP.rotation),
                        float3(startTmDP.translation, startTmDP.rotation),
                        float3(endTmP.translation,  endTmP.rotation),
                        float3(endTmDP.translation, endTmDP.rotation))
                let posAngleOffest = polynomial[0] * localPhase*localPhase*localPhase + polynomial[1] * localPhase*localPhase + polynomial[2] * localPhase + polynomial[3]
                let derivatevePosAngleOffset = 3.0 * polynomial[0] * localPhase*localPhase + 2.0 * polynomial[1] * localPhase + polynomial[2]
                sumWeight += weight
                ret.pointTransforms[name].translation += weight * posAngleOffest.xy
                ret.pointTransforms[name].rotation = normalize_angle(ret.pointTransforms[name].rotation + weight * posAngleOffest.z)
                ret.pointTmDerivatives[name].translation += weight * derivatevePosAngleOffset.xy
                ret.pointTmDerivatives[name].rotation = normalize_angle(ret.pointTmDerivatives[name].rotation + weight * derivatevePosAngleOffset.z)
            assert(sumWeight <= 1.0, "Sum of animation weights exceeded 1")
    return ret

[decs_template]
struct Character
    size: float = 1.0
    flipped: bool = false
    tm: PointTransform
    body: string
    posture: string
    bodyState: BodyState?
    currentAnimation: string
    animationTime: float


[decs(stage = update)]
def update_character_animation(var c: Character&)
    let dt = get_delta_time()
    var animation : Animation const? = null
    if c.currentAnimation != ""
        let animationP = find(Animations, c.currentAnimation)
        assert(animationP != null, "Animation not found")
        animation = animationP
        c.animationTime += dt / animationP.duration
        if c.animationTime >= 1.0
            c.animationTime -= 1.0
    let targetState = get_target_body_state(c.body, c.posture, animation, c.animationTime)
    c.bodyState = targetState

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
        for i in range(100)
            let t = float(i) / 100.0
            let pos = polynomial[0] * t*t*t + polynomial[1] * t*t + polynomial[2] * t + polynomial[3]
            fill_circle(pos.x, -pos.y, 0.02*c.size, 0xFFFFFF)

def create_character_entity(body: string; starting_posture: string; pos: float2; size: float)
    var tm <- [[PointTransform translation=pos, rotation=0.0]]
    create_entity <| @ (eid, cmp)
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Character size = size, flipped = false, body=body, posture=starting_posture, tm=tm, bodyState=initialize_body_state(body, starting_posture), animationTime=0.0, currentAnimation="test"]])
    commit()

def exportCharacters()
    pass

def importCharacters()
    pass