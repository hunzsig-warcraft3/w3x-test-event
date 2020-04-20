-- 加载h-lua
require "h-lua"

-- 禁用迷雾
cj.FogEnable(false)
cj.FogMaskEnable(false)

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
    }
    return hunit.create({
        register = true,
        whichPlayer = hplayer.players[index],
        unitId = ids[index],
        x = 300 * index, y = 0,
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
                            { attr = "lightning_chain", odds = 50, val = 5, effect = nil, qty = 3, reduce = 5 }
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
            elseif (val == "范围测试") then
                local u1 = cru(1)
                local u2 = cru(2)
                hevent.onEnterUnitRange(u1, 150, function(evtData)
                    _ttg(
                        evtData.centerUnit,
                        hColor.purple(hunit.getName(evtData.enterUnit) .. "接近你了")
                    )
                end)
            end
        end
    )
end)
