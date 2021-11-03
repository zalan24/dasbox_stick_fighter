require daslib/media
require daslib/decs_boost
require daslib/json
require platform

let gravity = -9.8

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
    fromSizeMul : float = 1.0
    toSizeMul : float = 1.0

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
    // "knight" => [[BodyPlan
    //                 points<-{{
    //                     "chest" => [[BodyPoint]];
    //                     "waist" => [[BodyPoint]];
    //                     "knee_left" => [[BodyPoint animationWeight<-{{"leg_left" => 0.3}}]];
    //                     "knee_right" => [[BodyPoint animationWeight<-{{"leg_right" => 0.3}}]];
    //                     "heel_left" => [[BodyPoint animationWeight<-{{"leg_left" => 0.9}}]];
    //                     "heel_right" => [[BodyPoint animationWeight<-{{"leg_right" => 0.9}}]];
    //                     "foot_left" => [[BodyPoint animationWeight<-{{"leg_left" => 0.9}}]];
    //                     "foot_right" => [[BodyPoint animationWeight<-{{"leg_right" => 0.9}}]];
    //                     "neck" => [[BodyPoint ]];
    //                     "elbow_left" => [[BodyPoint ]];
    //                     "elbow_right" => [[BodyPoint ]];
    //                     "hand_left" => [[BodyPoint ]];
    //                     "hand_right" => [[BodyPoint ]]
    //                 }},
    //                 links<-[{auto
    //                     [[PointLink from="neck", to="chest"]];
    //                     [[PointLink from="chest", to="waist"]];
    //                     [[PointLink from="chest", to="elbow_left", curveStrength=0.5, fromAngleOffset=-PI/2.0]];
    //                     [[PointLink from="chest", to="elbow_right", curveStrength=0.5, fromAngleOffset=PI/2.0]];
    //                     [[PointLink from="elbow_left", to="hand_left"]];
    //                     [[PointLink from="elbow_right", to="hand_right"]];
    //                     [[PointLink from="waist", to="knee_left", curveStrength=0.3]];
    //                     [[PointLink from="waist", to="knee_right", curveStrength=0.3]];
    //                     [[PointLink from="knee_left", to="heel_left", curveStrength=0.5, fromAngleOffset=PI]];
    //                     [[PointLink from="knee_right", to="heel_right", curveStrength=0.5, fromAngleOffset=PI]];
    //                     [[PointLink from="heel_left", to="foot_left", curveStrength=0.1, fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0]];
    //                     [[PointLink from="heel_right", to="foot_right", curveStrength=0.1, fromAngleOffset=-PI/2.0, toAngleOffset=PI/2.0]]
    //                 }],
    //                 postures<-{{
    //                     "default" => [[Posture transforms<-{{
    //                         "chest" => [[PointTransform translation=float2(0.0, 1.5)]];
    //                         "neck" => [[PointTransform translation=float2(0.0, 1.6)]];
    //                         "waist" => [[PointTransform translation=float2(0.0, 0.9)]];
    //                         "knee_left" => [[PointTransform translation=float2(-0.3, 0.45)]];
    //                         "knee_right" => [[PointTransform translation=float2(0.3, 0.45)]];
    //                         "heel_left" => [[PointTransform translation=float2(-0.25, 0.05)]];
    //                         "heel_right" => [[PointTransform translation=float2(0.25, 0.05)]];
    //                         "foot_left" => [[PointTransform translation=float2(-0.35, 0.02)]];
    //                         "foot_right" => [[PointTransform translation=float2(0.35, 0.02)]];
    //                         "elbow_left" => [[PointTransform translation=float2(-0.3, 1.1)]];
    //                         "elbow_right" => [[PointTransform translation=float2(0.3, 1.1)]];
    //                         "hand_left" => [[PointTransform translation=float2(-0.27, 0.75)]];
    //                         "hand_right" => [[PointTransform translation=float2(0.27, 0.75)]]
    //                     }}]]
    //                 }}
    //             ]]
    "knight" => [[BodyPlan
                    points<-{{
                        "chest" => [[BodyPoint]];
                        "waist" => [[BodyPoint]];
                        "leg_left" => [[BodyPoint]];
                        "leg_right" => [[BodyPoint]];
                        "hand_left" => [[BodyPoint]];
                        "hand_right" => [[BodyPoint]];
                        "sword_top" => [[BodyPoint]];
                        "chin" => [[BodyPoint]];
                        "head_side_left" => [[BodyPoint]];
                        "head_side_right" => [[BodyPoint]];
                        "head_top_left" => [[BodyPoint]];
                        "head_top_right" => [[BodyPoint]];
                        "ear_inner_left" => [[BodyPoint]];
                        "ear_inner_right" => [[BodyPoint]];
                        "ear_outter_left" => [[BodyPoint]];
                        "ear_outter_right" => [[BodyPoint]];
                        "eye_left" => [[BodyPoint]];
                        "eye_right" => [[BodyPoint]]
                    }},
                    links<-[{auto
                        [[PointLink from="chin", to="chest", fromAngleOffset=-PI, curveStrength=0.3, fromSizeMul=0.5, toSizeMul=2.0]];
                        [[PointLink from="chest", to="waist", fromAngleOffset=-PI, curveStrength=0.3, fromSizeMul=2.0, toSizeMul=2.0]];
                        [[PointLink from="waist", to="leg_left", fromAngleOffset=-PI/2.0, curveStrength=0.3, fromSizeMul=2.0, toSizeMul=0.5]];
                        [[PointLink from="waist", to="leg_right", fromAngleOffset=PI/2.0, curveStrength=0.3, fromSizeMul=2.0, toSizeMul=0.5]];
                        [[PointLink from="chest", to="hand_left", fromAngleOffset=-PI/2.0, curveStrength=0.5, fromSizeMul=2.0, toSizeMul=0.5]];
                        [[PointLink from="chest", to="hand_right", fromAngleOffset=PI/2.0, curveStrength=0.5, fromSizeMul=2.0, toSizeMul=0.5]];
                        [[PointLink from="hand_right", to="sword_top", fromAngleOffset=PI/4.0, toAngleOffset=PI/4.0, curveStrength=0.5, fromSizeMul=2.0, toSizeMul=0.05]];
                        [[PointLink from="head_side_left", to="chin", fromAngleOffset=PI, toAngleOffset=-PI/2.0, curveStrength=0.55, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head_side_right", to="chin", fromAngleOffset=PI, toAngleOffset=PI/2.0, curveStrength=0.55, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head_top_left", to="head_top_right", fromAngleOffset=PI/2.0-0.4, toAngleOffset=-PI/2.0+0.4, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="ear_outter_left", to="ear_inner_left", fromAngleOffset=0.0, toAngleOffset=-PI/2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="ear_outter_right", to="ear_inner_right", fromAngleOffset=0.0, toAngleOffset=PI/2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head_side_right", to="ear_outter_right", fromAngleOffset=1.0, toAngleOffset=0.7, curveStrength=0.35, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head_side_left", to="ear_outter_left", fromAngleOffset=-1.0, toAngleOffset=-0.7, curveStrength=0.35, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head_top_right", to="ear_inner_right", fromAngleOffset=1.0, toAngleOffset=2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head_top_left", to="ear_inner_left", fromAngleOffset=-1.0, toAngleOffset=-2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="eye_left", to="eye_left", fromSizeMul=2.5, toSizeMul=2.5]];
                        [[PointLink from="eye_right", to="eye_right", fromSizeMul=2.5, toSizeMul=2.5]]
                    }],
                    postures<-{{
                        "default" => [[Posture transforms<-{{
                            "chest" => [[PointTransform translation=float2(0.0, 0.57)]];
                            "waist" => [[PointTransform translation=float2(0.0, 0.25)]];
                            "leg_left" => [[PointTransform translation=float2(-0.2, 0.0)]];
                            "leg_right" => [[PointTransform translation=float2(0.2, 0.0)]];
                            "hand_left" => [[PointTransform translation=float2(-0.3, 0.4)]];
                            "hand_right" => [[PointTransform translation=float2(0.3, 0.4)]];
                            "sword_top" => [[PointTransform translation=float2(0.5, 0.6)]];
                            "chin" => [[PointTransform translation=float2(0.0, 0.64)]];
                            "head_side_left" => [[PointTransform translation=float2(-0.2, 0.85)]];
                            "head_side_right" => [[PointTransform translation=float2(0.2, 0.85)]];
                            "head_top_left" => [[PointTransform translation=float2(-0.13, 0.92)]];
                            "head_top_right" => [[PointTransform translation=float2(0.13, 0.92)]];
                            "ear_inner_left" => [[PointTransform translation=float2(-0.14, 1.16)]];
                            "ear_inner_right" => [[PointTransform translation=float2(0.14, 1.16)]];
                            "ear_outter_left" => [[PointTransform translation=float2(-0.18, 1.19)]];
                            "ear_outter_right" => [[PointTransform translation=float2(0.18, 1.19)]];
                            "eye_left" => [[PointTransform translation=float2(-0.08, 0.765)]];
                            "eye_right" => [[PointTransform translation=float2(0.08, 0.765)]]
                        }}]]
                    }}
                ]];
    "bug" => [[BodyPlan
                    points<-{{
                        "head" => [[BodyPoint]];
                        "butt" => [[BodyPoint]];
                        "leg_source1" => [[BodyPoint]];
                        "leg_source2" => [[BodyPoint]];
                        "leg_source3" => [[BodyPoint]];
                        "leg1" => [[BodyPoint]];
                        "leg2" => [[BodyPoint]];
                        "leg3" => [[BodyPoint]];
                        "back" => [[BodyPoint]];
                        "antenna_left" => [[BodyPoint]];
                        "antenna_right" => [[BodyPoint]]
                    }},
                    links<-[{auto
                        [[PointLink from="head", to="back", fromAngleOffset=0.0, toAngleOffset=PI/2.0, curveStrength=0.4, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head", to="back", fromAngleOffset=-PI/2.0, toAngleOffset=PI, curveStrength=0.4, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="back", to="butt", fromAngleOffset=-PI/2.0, toAngleOffset=PI/3.5, curveStrength=0.3, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="back", to="butt", fromAngleOffset=PI, toAngleOffset=PI/2.0, curveStrength=0.5, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="butt", to="leg_source3", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.5, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source3", to="leg_source2", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.5, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source2", to="leg_source1", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.5, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source1", to="head", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.5, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source1", to="leg1", fromAngleOffset=PI+0.1, toAngleOffset=-0.2, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source2", to="leg2", fromAngleOffset=PI-0.1, toAngleOffset=0.2, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source3", to="leg3", fromAngleOffset=PI+0.1, toAngleOffset=-0.2, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head", to="antenna_left", fromAngleOffset=-0.5, toAngleOffset=-PI/2.0, curveStrength=0.3, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head", to="antenna_right", fromAngleOffset=-0.5, toAngleOffset=-PI/2.0, curveStrength=0.3, fromSizeMul=0.5, toSizeMul=0.5]]
                    }],
                    postures<-{{
                        "default" => [[Posture transforms<-{{
                            "head" => [[PointTransform translation=float2(0.3, 0.1)]];
                            "butt" => [[PointTransform translation=float2(-0.4, 0.1)]];
                            "leg_source1" => [[PointTransform translation=float2(0.1, 0.1)]];
                            "leg_source2" => [[PointTransform translation=float2(-0.05, 0.1)]];
                            "leg_source3" => [[PointTransform translation=float2(-0.2, 0.1)]];
                            "leg1" => [[PointTransform translation=float2(0.1, 0.0)]];
                            "leg2" => [[PointTransform translation=float2(-0.05, 0.0)]];
                            "leg3" => [[PointTransform translation=float2(-0.2, 0.0)]];
                            "back" => [[PointTransform translation=float2(0.1, 0.3)]];
                            "antenna_left" => [[PointTransform translation=float2(0.32, 0.4)]];
                            "antenna_right" => [[PointTransform translation=float2(0.34, 0.35)]]
                        }}]]
                    }}
                ]];
    "mosquito" => [[BodyPlan
                    points<-{{
                        "head" => [[BodyPoint]];
                        "butt" => [[BodyPoint]];
                        "leg_source1" => [[BodyPoint]];
                        "leg_source2" => [[BodyPoint]];
                        "leg_source3" => [[BodyPoint]];
                        "leg1" => [[BodyPoint]];
                        "leg2" => [[BodyPoint]];
                        "leg3" => [[BodyPoint]];
                        "back" => [[BodyPoint]];
                        "spike" => [[BodyPoint]];
                        "wing_left" => [[BodyPoint]];
                        "wing_right" => [[BodyPoint]]
                    }},
                    links<-[{auto
                        [[PointLink from="head", to="back", fromAngleOffset=0.0, toAngleOffset=PI/2.0+0.3, curveStrength=0.4, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="back", to="butt", fromAngleOffset=-PI/2.0+0.3, toAngleOffset=PI/3.5, curveStrength=0.3, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="butt", to="leg_source3", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source3", to="leg_source2", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source2", to="leg_source1", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source1", to="head", fromAngleOffset=PI/2.0, toAngleOffset=-PI/2.0, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source1", to="leg1", fromAngleOffset=PI+0.1, toAngleOffset=-0.2, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source2", to="leg2", fromAngleOffset=PI-0.1, toAngleOffset=0.2, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="leg_source3", to="leg3", fromAngleOffset=PI+0.1, toAngleOffset=-0.2, curveStrength=0.2, fromSizeMul=0.5, toSizeMul=0.5]];
                        [[PointLink from="head", to="spike", fromAngleOffset=-0.5, toAngleOffset=-PI/4.0, curveStrength=0.3, fromSizeMul=0.5, toSizeMul=0.1]];
                        [[PointLink from="back", to="wing_left", fromAngleOffset=-0.3, toAngleOffset=PI/2.0, curveStrength=0.3, fromSizeMul=0.3, toSizeMul=0.3]];
                        [[PointLink from="back", to="wing_left", fromAngleOffset=-0.7, toAngleOffset=-PI/2.0, curveStrength=0.3, fromSizeMul=0.3, toSizeMul=0.3]];
                        [[PointLink from="back", to="wing_right", fromAngleOffset=-0.3, toAngleOffset=PI/2.0, curveStrength=0.3, fromSizeMul=0.3, toSizeMul=0.3]];
                        [[PointLink from="back", to="wing_right", fromAngleOffset=-0.7, toAngleOffset=-PI/2.0, curveStrength=0.3, fromSizeMul=0.3, toSizeMul=0.3]]
                    }],
                    postures<-{{
                        "default" => [[Posture transforms<-{{
                            "head" => [[PointTransform translation=float2(0.3, 0.1)]];
                            "butt" => [[PointTransform translation=float2(-0.4, 0.3)]];
                            "leg_source1" => [[PointTransform translation=float2(0.1, 0.15), rotation=0.3]];
                            "leg_source2" => [[PointTransform translation=float2(-0.05, 0.2), rotation=0.3]];
                            "leg_source3" => [[PointTransform translation=float2(-0.2, 0.25), rotation=0.3]];
                            "leg1" => [[PointTransform translation=float2(0.1, 0.05)]];
                            "leg2" => [[PointTransform translation=float2(-0.05, 0.10)]];
                            "leg3" => [[PointTransform translation=float2(-0.2, 0.15)]];
                            "back" => [[PointTransform translation=float2(0.1, 0.3), rotation=0.1]];
                            "spike" => [[PointTransform translation=float2(0.4, 0.0)]];
                            "wing_left" => [[PointTransform translation=float2(-0.2, 0.6), rotation=-0.2]];
                            "wing_right" => [[PointTransform translation=float2(-0.3, 0.5), rotation=-0.2]]
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

def get_target_body_state(body: string implicit; starting_posture: string implicit; animationStates : AnimationStates const? implicit)
    var ret = new BodyState
    let bodyPlanP = find(BodyPlans, body)
    assert(bodyPlanP != null, "Unknown body plan")
    let postureP = find(deref(bodyPlanP).postures, starting_posture)
    assert(postureP != null, "Posture not found")

    for name, data in keys(bodyPlanP.points), values(bodyPlanP.points)
        let tm = find(deref(postureP).transforms, name)
        assert(tm != null, "Point transform from body plan not found in posture")
        ret.pointTransforms[name] = deref(tm)
        ret.pointTmDerivatives[name] = [[PointTransform translation=float2(0.0), rotation=0.0]]

    for animState in animationStates.states
        let animationP = find(Animations, animState.name)
        assert(animationP != null, "Animation not found")
        var a = 0
        var b = length(animationP.frames)
        while a+1 < b
            let m = (a+b)/2
            if animationP.frames[m].time <= animState.phase
                a = m
            else
                b = m
        b = (a+1) % length(animationP.frames)
        var localPhase = (animState.phase - animationP.frames[a].time)
        if localPhase < 0.0
            localPhase += 1.0
        if animationP.frames[b].time > animationP.frames[a].time
            localPhase /= animationP.frames[b].time - animationP.frames[a].time
        else
            localPhase /= animationP.frames[b].time + 1.0 - animationP.frames[a].time

        for name, data in keys(bodyPlanP.points), values(bodyPlanP.points)
            var sumWeight = 0.0
            for animPoint, weight in keys(data.animationWeight), values(data.animationWeight)
                let startTmP = find(animationP.frames[a].transformations, animPoint)
                let startTmDP = find(animationP.frames[a].tmDerivatives, animPoint)
                let endTmP = find(animationP.frames[b].transformations, animPoint)
                let endTmDP = find(animationP.frames[b].tmDerivatives, animPoint)
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

struct AnimationState
    name: string
    phase: float
    repeating: bool

struct AnimationStates
    states: array<AnimationState>

enum ControllerType
    User
    Bug
    Mosquito

[decs_template]
struct Character
    gravity: bool
    speed: float2
    size: float = 1.0
    flipped: bool = false
    tm: PointTransform
    body: string
    posture: string
    controller: ControllerType
    bodyState: BodyState?
    animationState: AnimationStates?

[decs(stage = update)]
def update_character_animation(var c: Character&)
    let dt = get_delta_time()

    if c.gravity
        c.speed.y += dt*gravity
    if c.speed.y < 0.0
        query() <| $(platform: Platform; eid: EntityId)
            let top = platform.pos.y + platform.size.y/2.0
            if c.tm.translation.x + c.size*0.2 > platform.pos.x-platform.size.x/2.0 && c.tm.translation.x - c.size*0.2 < platform.pos.x+platform.size.x/2.0
                if c.tm.translation.y >= top && c.tm.translation.y + dt*c.speed.y < top
                    c.tm.translation.y = top+0.0001
                    c.speed.y = 0.0
    c.tm.translation += c.speed * dt

    for state in c.animationState.states
        let animationP = find(Animations, state.name)
        assert(animationP != null, "Animation not found")
        state.phase += dt / animationP.duration
        if state.phase >= 1.0
            if state.repeating
                state.phase -= 1.0
    var i = 0
    while i < length(c.animationState.states)
        if c.animationState.states[i].phase >= 1.0
            unsafe
                var goodArray = reinterpret<AnimationStates?> c.animationState
                goodArray.states |> erase(i)
            break
    let targetState = get_target_body_state(c.body, c.posture, c.animationState)
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
        // fill_circle(transformedFromTm.translation.x, -transformedFromTm.translation.y, 0.02*c.size, 0xFFFFFF)
        // fill_circle(transformedToTm.translation.x, -transformedToTm.translation.y, 0.02*c.size, 0xFFFFFF)

        transformedFromTm.rotation += link.fromAngleOffset
        transformedToTm.rotation += link.toAngleOffset
        let polynomial = getConnectingPolynomial(transformedFromTm, transformedToTm, c.size*link.curveStrength)
        for i in range(100)
            let t = float(i) / 100.0
            let pos = polynomial[0] * t*t*t + polynomial[1] * t*t + polynomial[2] * t + polynomial[3]
            let size = 0.02 * c.size * lerp(link.fromSizeMul,link.toSizeMul,t)
            fill_circle(pos.x, -pos.y, size, 0xFFFFFF)

def create_character_entity(body: string; starting_posture: string; pos: float2; size: float; controller: ControllerType; gravity: bool)
    var tm <- [[PointTransform translation=pos, rotation=0.0]]
    create_entity <| @ (eid, cmp)
        cmp |> set("eid", eid)
        apply_decs_template(cmp, [[Character size = size, flipped = false, body=body, posture=starting_posture, tm=tm, bodyState=initialize_body_state(body, starting_posture), animationState=new AnimationStates, controller = controller, gravity=gravity]])
    commit()

def create_player(pos: float2; size: float)
    create_character_entity("knight", "default", pos, size, ControllerType User, true)

def create_bug(pos: float2; size: float)
    create_character_entity("bug", "default", pos, size, ControllerType Bug, true)

def create_mosquito(pos: float2; size: float)
    create_character_entity("mosquito", "default", pos, size, ControllerType Mosquito, false)

def addAnimation(var c: Character&; animation: string; repeated: bool)
    c.animationState.states |> push([[AnimationState name=animation, repeating=repeated, phase=0.0]])

// def removeAnimation(var c: Character&; animation: string)
//     let nameMatch <- @ <| (state : AnimationState)
//         return state.name == animation
//     let toRemove = find_index_if(c.animationState.states, nameMatch)
//     if toRemove > -1
//         erase(c.animationState.states, toRemove)

def exportCharacters()
    pass

def importCharacters()
    pass