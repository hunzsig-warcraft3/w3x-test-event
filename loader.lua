-- 加载h-lua
require "h-lua"

-- 禁用迷雾
cj.FogEnable(false)
cj.FogMaskEnable(false)

-- 监察内存
htime.setInterval(5.00, function()
    collectgarbage("collect")
    print_mb("========内存回收->" .. collectgarbage("count"))
    print_r(hRuntime.event)
end)

-- 聊天测试，兼代测试入口
hevent.onChat(hplayer.players[1], '##', false, function(evtData)
    print_r(evtData)
end)

-- 聊天测试，对话框点击测试
hevent.onChat(hplayer.players[1], 'dialog', true, function(evtData)
    print_r(evtData)
    hdialog.create(hplayer.players[1],
        {
            title = "h-lua对话框协助测试",
            buttons = {
                { value = "Q", label = "第1个" },
                { value = "W", label = "第2个" },
                { value = "E", label = "第3个" },
            }
        },
        function(val)
            print("hdialog.click", val)
        end
    )
end)
