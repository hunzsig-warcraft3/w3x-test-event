-- 加载h-lua
require "h-lua"

-- 禁用迷雾
cj.FogEnable(false)
cj.FogMaskEnable(false)

types = {
    var = "变量清空",
    unit = "创建单位",
    texttag = "创建飘浮字",
    ttgstyle = "创建带缩放漂浮字",
    effect = "创建特效",
    timer = "创建计时器",
}

var_text = {}

henemy.setPlayers({
    hplayer.players[2],
    hplayer.players[3],
    hplayer.players[4],
    hplayer.players[5],
    hplayer.players[6],
    hplayer.players[7],
    hplayer.players[8],
    hplayer.players[9],
    hplayer.players[10],
    hplayer.players[11],
    hplayer.players[12],
})

--[[
    测试例子，进入游戏，敲入聊天信息
    -var [concurrent] [frequency] [number]
    -unit [concurrent] [frequency] [number] [during]
    -texttag [concurrent] [frequency] [number] [during]
    -ttgstyle [concurrent] [frequency] [number] [during]
    -effect [concurrent] [frequency] [number] [during]
    -timer [concurrent] [frequency] [number] [during]
]]
hevent.onChat(hplayer.players[1], '-', false, function(evtData)
    local chatString = evtData.chatString
    local chatOptions = string.explode(' ', chatString)
    local type = string.gsub(chatOptions[1] or "", "-", "")
    local concurrent = tonumber(chatOptions[2]) or 1
    local frequency = tonumber(chatOptions[3]) or 0.01
    local number = tonumber(chatOptions[4]) or 10000
    local during = tonumber(chatOptions[5]) or 3
    if (type == "" or table.includes(type, {
        "var",
        "unit",
        "texttag",
        "ttgstyle",
        "effect",
        "timer",
    }) == false) then
        return
    end
    print_mb("========测试开始"
        .. "\n->type:" .. types[type]
        .. "\n->concurrent:" .. concurrent
        .. "\n->frequency:" .. frequency
        .. "\n->number:" .. number
        .. "\n->during:" .. during
        .. "\n->内存:" .. collectgarbage("count")
        .. "\n========")
    for _ = 1, concurrent do
        local n = 0
        local cache = {}
        local t = cj.CreateTimer()
        cj.TimerStart(
            t,
            frequency,
            true,
            function()
                n = n + 1
                if (n % 1000 == 0) then
                    print_mb("====== = >" .. types[type] .. n .. "次")
                end
                if (n > number) then
                    htime.delTimer(t)
                    print_mb("========" .. types[type] .. "测试结束，内存" .. collectgarbage("count") .. "========")
                    cache = {}
                    return
                end
                local x = math.random(0, 1000)
                local y = math.random(0, 1000)
                if (type == "var") then
                    --测试全局/局部变量清空，成绩：100万 clear
                    cache[n] = x + y
                    var_text[n] = x + y
                    var_text[n] = nil
                elseif (type == "unit") then
                    --测试创建单位，成绩：83万
                    --local u = cj.CreateUnit(
                    --    henemy.getPlayer(),
                    --    string.char2id("hfoo"),
                    --    x,
                    --    y,
                    --    0
                    --)
                    --hunit.del(u, during)
                    --测试创建单位2，成绩：83万
                    henemy.create({
                        register = true,
                        unitId = "hfoo",
                        x = x,
                        y = y,
                        during = during,
                    })
                elseif (type == "texttag") then
                    --测试飘浮字，成绩：100万 clear
                    htextTag.create2XY(
                        x, y,
                        math.random(0, 100),
                        math.random(5, 10),
                        nil,
                        1,
                        during,
                        math.random(0, 50)
                    )
                elseif (type == "ttgstyle") then
                    --测试飘浮字，成绩：100万 clear
                    htextTag.style(
                        htextTag.create2XY(
                            x, y,
                            math.random(0, 100),
                            math.random(5, 10),
                            nil,
                            1,
                            during,
                            math.random(0, 50)
                        ),
                        'toggle',
                        10,
                        10
                    )
                elseif (type == "effect") then
                    --测试特效，成绩：100万 clear
                    heffect.toXY(
                        "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl",
                        x, y,
                        during
                    )
                elseif (type == "timer") then
                    --测试计时器，成绩：150万 clear
                    --每个占用 0.1764KB 左右，上限不变则不再增加
                    htime.setTimeout(math.random(1, 50), function(tt)
                        htime.delTimer(tt)
                    end)
                end
            end
        )
    end
end)

htime.setInterval(5.00, function()
    collectgarbage("collect")
    print_mb("========内存回收->" .. collectgarbage("count"))
    print_mb("========hRuntime.unit->" .. table.len(hRuntime.unit))
    print_mb("========hRuntime.attr->" .. table.len(hRuntime.attribute))
    print_mb("========hRuntime.item->" .. table.len(hRuntime.item))
end)