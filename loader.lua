-- 加载h-lua
require "h-lua"

-- 禁用迷雾
henv.setFogStatus(false, false)

-- 监察内存
htime.setInterval(5.00, function()
    collectgarbage("collect")
    print_mb("========内存回收->" .. collectgarbage("count"))
    --print_r(hRuntime.event, print, false)
end)

local cru = function(index)
    local ids = {
        "hkni",
        "hfoo",
        "hsor",
        "hspt",
        "otau",
    }
    return hunit.create({
        register = true,
        whichPlayer = hplayer.players[index],
        unitId = ids[index],
        x = 98, y = 126,
        life = 60,
    })
end

local _ttg = function(u, txt)
    local t = httg.create2Unit(u, txt, 16, nil, 1, 3, 50)
    httg.style(t, 'scale', 0, .3)
end

-- 聊天测试，兼代测试入口
hevent.onChat(hplayer.players[1], '##', false, function(evtData)
    print_r(evtData)
end)

-- 聊天测试，对话框点击测试
hevent.onChat(hplayer.players[1], 'test', true, function(ed)
    print_r(ed)
    hdialog.create(hplayer.players[1],
        {
            title = "h-lua对话框协助测试",
            buttons = {
                "单位对打",
                "特殊效果",
                "范围测试",
            }
        },
        function(val)
            if (val == "单位对打") then
                -- 创建单位
                local u1 = cru(1)
                local u2 = cru(2)
                local u3 = cru(3)
                local u4 = cru(4)
                hevent.onAttackDetect(u1, function(evtData)
                    _ttg(
                        evtData.targetUnit,
                        hColor.red(hunit.getName(evtData.triggerUnit) .. "注意你了")
                    )
                end)
                hevent.onAttackGetTarget(u2, function(evtData)
                    _ttg(
                        evtData.targetUnit,
                        hColor.green(hunit.getName(evtData.triggerUnit) .. "目标你了")
                    )
                end)
                hevent.onAttack(u3, function(evtData)
                    _ttg(
                        evtData.targetUnit,
                        hColor.sky(hunit.getName(evtData.triggerUnit) .. "攻击到你了")
                    )
                end)
                hevent.onBeAttackReady(u4, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.yellow(hunit.getName(evtData.attacker) .. "发起攻击")
                    )
                end)
                hevent.onBeAttack(u4, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.purple("被" .. hunit.getName(evtData.attacker) .. "攻击了")
                    )
                end)
            elseif (val == "特殊效果") then
                local u1 = cru(1)
                local u2 = cru(2)
                local u3 = cru(3)
                local u4 = cru(4)
                local u5 = cru(5)
                hattr.set(u1, 0, {
                    avoid = "=50",
                    attack_damage_type = "+physical",
                    attack_effect = {
                        add = {
                            { attr = "knocking", odds = 75, percent = 100, effect = nil }
                        }
                    }
                })
                hattr.set(u2, 0, {
                    hemophagia = "=25",
                    attack_effect = {
                        add = {
                            { attr = "swim", odds = 50.0, val = 5.0, during = 2.0, effect = nil },
                        }
                    }
                })
                hattr.set(u3, 0, {
                    invincible = "=20",
                    attack_effect = {
                        add = {
                            { attr = "crack_fly", odds = 50, val = 5, during = 1.5, effect = nil, distance = 300, high = 300 }
                        }
                    }
                })
                hattr.set(u4, 0, {
                    damage_rebound = "=10",
                    attack_effect = {
                        add = {
                            { attr = "lightning_chain", odds = 75, val = 5, effect = nil, qty = 5, reduce = 5 }
                        }
                    }
                })
                hevent.onBeSwim(u1, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.green("你被" .. hunit.getName(evtData.sourceUnit) .. "眩晕了")
                    )
                end)
                hevent.onBeCrackFly(u2, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.sky("你被" .. hunit.getName(evtData.sourceUnit) .. "击飞了")
                    )
                end)
                hevent.onBeLightningChain(u3, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.yellow("你被" .. hunit.getName(evtData.sourceUnit) .. "闪电链")
                    )
                end)
                hevent.onBeRebound(u1, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.yellow("你被" .. hunit.getName(evtData.sourceUnit) .. "反弹伤害")
                    )
                end)
                hevent.onAttack(u5, function(evtData)
                    local rand = math.random(1, 3)
                    if (rand == 1) then
                        _ttg(evtData.attacker, hColor.orange(hunit.getName(evtData.attacker) .. "发动扇面冲击"))
                        hskill.leapPow({
                            qty = 6, --数量
                            deg = 20, --角度
                            arrowUnit = nil, -- 前冲的单位（有就是自身冲击，没有就是马甲特效冲击）
                            sourceUnit = evtData.attacker, --伤害来源（必须有！不管有没有伤害）
                            x = cj.GetUnitX(evtData.targetUnit), --冲击的x坐标（可选的，对点冲击，与某目标无关）
                            y = cj.GetUnitY(evtData.targetUnit), --冲击的y坐标（可选的，对点冲击，与某目标无关）
                            speed = 10, --冲击的速度（可选的，默认10，0.02秒的移动距离,大概1秒500px)
                            acceleration = 1, --冲击加速度（可选的，每个周期都会增加0.02秒一次)
                            filter = function(filterUnit)
                                return his.enemy(filterUnit, u5) and his.alive(filterUnit)
                            end,
                            tokenArrow = "Abilities\\Spells\\Orc\\Shockwave\\ShockwaveMissile.mdl",
                            tokenArrowScale = 1.00, --前冲的特效作为马甲冲击时的模型缩放
                            tokenArrowOpacity = 1.00, --前冲的特效作为马甲冲击时的模型透明度[0-1]
                            tokenArrowHeight = 0.00, --前冲的特效作为马甲冲击时的离地高度
                            effectMovement = nil, --移动过程，每个间距的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
                            effectEnd = nil, --到达最后位置时的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
                            damageMovement = 3, --移动过程中的伤害（可选的，默认为0）
                            damageMovementRange = 100, --移动过程中的伤害（可选的，默认为0，易知0范围是无效的所以有伤害也无法体现）
                            damageMovementRepeat = true, --移动过程中伤害是否可以重复造成（可选的，默认为不能）
                            damageMovementDrag = true, --移动过程是否拖拽敌人（可选的，默认为不能）
                            damageEnd = 0, --移动结束时对目标的伤害（可选的，默认为0）
                            damageEndRange = 0, --移动结束时对目标的伤害范围（可选的，默认为0，此处0范围是有效的，会只对targetUnit生效，除非unit不存在）
                            damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
                        })
                    elseif (rand == 2) then
                        _ttg(evtData.attacker, hColor.orange(hunit.getName(evtData.attacker) .. "发动弹跳冲击"))
                        hskill.leapReflex({
                            qty = 5, --（跳跃次数，默认1）
                            range = 1000, --（选目标范围，默认0无效）
                            arrowUnit = nil, -- 前冲的单位（有就是自身冲击，没有就是马甲特效冲击）
                            sourceUnit = evtData.attacker, --伤害来源（必须有！不管有没有伤害）
                            targetUnit = evtData.targetUnit,
                            speed = 10, --冲击的速度（可选的，默认10，0.02秒的移动距离,大概1秒500px)
                            acceleration = 1, --冲击加速度（可选的，每个周期都会增加0.02秒一次)
                            filter = function(filterUnit)
                                return his.enemy(filterUnit, u5) and his.alive(filterUnit)
                            end,
                            tokenArrow = "Abilities\\Spells\\Orc\\Shockwave\\ShockwaveMissile.mdl",
                            tokenArrowScale = 1.00, --前冲的特效作为马甲冲击时的模型缩放
                            tokenArrowOpacity = 1.00, --前冲的特效作为马甲冲击时的模型透明度[0-1]
                            tokenArrowHeight = 0.00, --前冲的特效作为马甲冲击时的离地高度
                            effectMovement = nil, --移动过程，每个间距的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
                            effectEnd = nil, --到达最后位置时的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
                            damageMovement = 3, --移动过程中的伤害（可选的，默认为0）
                            damageMovementRange = 100, --移动过程中的伤害（可选的，默认为0，易知0范围是无效的所以有伤害也无法体现）
                            damageMovementRepeat = true, --移动过程中伤害是否可以重复造成（可选的，默认为不能）
                            damageMovementDrag = true, --移动过程是否拖拽敌人（可选的，默认为不能）
                            damageEnd = 0, --移动结束时对目标的伤害（可选的，默认为0）
                            damageEndRange = 0, --移动结束时对目标的伤害范围（可选的，默认为0，此处0范围是有效的，会只对targetUnit生效，除非unit不存在）
                            damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
                        })
                    elseif (rand == 3) then
                        _ttg(evtData.attacker, hColor.orange(hunit.getName(evtData.attacker) .. "发动普通冲击"))
                        local polar = math.polarProjection(
                            cj.GetUnitX(evtData.attacker),
                            cj.GetUnitY(evtData.attacker),
                            2000, hunit.getFacing(evtData.attacker)
                        )
                        hskill.leap({
                            arrowUnit = nil, -- 前冲的单位（有就是自身冲击，没有就是马甲特效冲击）
                            sourceUnit = evtData.attacker, --伤害来源（必须有！不管有没有伤害）
                            x = polar.x, --冲击的x坐标（可选的，对点冲击，与某目标无关）
                            y = polar.y, --冲击的y坐标（可选的，对点冲击，与某目标无关）
                            speed = 10, --冲击的速度（可选的，默认10，0.02秒的移动距离,大概1秒500px)
                            acceleration = 1, --冲击加速度（可选的，每个周期都会增加0.02秒一次)
                            filter = function(filterUnit)
                                return his.enemy(filterUnit, u5) and his.alive(filterUnit)
                            end,
                            tokenArrow = "Abilities\\Spells\\Orc\\Shockwave\\ShockwaveMissile.mdl",
                            tokenArrowScale = 1.00, --前冲的特效作为马甲冲击时的模型缩放
                            tokenArrowOpacity = 1.00, --前冲的特效作为马甲冲击时的模型透明度[0-1]
                            tokenArrowHeight = 0.00, --前冲的特效作为马甲冲击时的离地高度
                            effectMovement = nil, --移动过程，每个间距的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
                            effectEnd = nil, --到达最后位置时的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
                            damageMovement = 0, --移动过程中的伤害（可选的，默认为0）
                            damageMovementRange = 100, --移动过程中的伤害（可选的，默认为0，易知0范围是无效的所以有伤害也无法体现）
                            damageMovementRepeat = true, --移动过程中伤害是否可以重复造成（可选的，默认为不能）
                            damageMovementDrag = true, --移动过程是否拖拽敌人（可选的，默认为不能）
                            damageEnd = 0, --移动结束时对目标的伤害（可选的，默认为0）
                            damageEndRange = 0, --移动结束时对目标的伤害范围（可选的，默认为0，此处0范围是有效的，会只对targetUnit生效，除非unit不存在）
                            damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
                        })
                    end
                end)
            elseif (val == "范围测试") then
                local u1 = cru(1)
                local u2 = cru(2)
                heffect.toXY("Abilities\\Spells\\Items\\AIso\\BIsvTarget.mdl", 0, 0, 60)
                local rect = hrect.create(0, 0, 300, 300, "神秘空间")
                hrect.lock({
                    type = "square",
                    during = 30,
                    whichRect = rect,
                })
                hrect.del(rect, 60)
                hevent.onEnterUnitRange(u1, 150, function(evtData)
                    _ttg(
                        evtData.centerUnit,
                        hColor.purple(hunit.getName(evtData.enterUnit) .. "接近你了")
                    )
                end)
                hevent.onEnterUnitRange(u2, 300, function(evtData)
                    hattr.set(evtData.enterUnit, 1, { move = "+100" })
                    _ttg(
                        evtData.enterUnit,
                        hColor.sky("加速！")
                    )
                end)
                hevent.onEnterRect(rect, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.yellow(hunit.getName(evtData.triggerUnit)
                            .. "进入了"
                            .. hrect.getName(evtData.triggerRect))
                    )
                end)
                hevent.onLeaveRect(rect, function(evtData)
                    _ttg(
                        evtData.triggerUnit,
                        hColor.yellowLight(hunit.getName(evtData.triggerUnit)
                            .. "离开了"
                            .. hrect.getName(evtData.triggerRect)
                        )
                    )
                end)
            end
        end
    )
end)
