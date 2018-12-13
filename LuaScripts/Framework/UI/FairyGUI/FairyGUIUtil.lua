---@class FairyGUIUtil
local FairyGUIUtil = {}

function FairyGUIUtil.window_class(base)

    return Class(base, FairyGUIUtil.LuaWindow)
end

--[[
注册组件扩展，例如
FairyGUIUtil.register_extension(UIPackage.GetItemURL("包名","组件名"), my_extension)
my_extension的定义方式见fgui.extension_class
]]
function FairyGUIUtil.register_extension(url, extension)
	local base = extension.base
	if base==FairyGUI.GComponent then base=FairyGUI.GLuaComponent
		elseif base==FairyGUI.GLabel then base=FairyGUIUtil.GLuaLabel
			elseif base==FairyGUI.GButton then base=FairyGUI.GLuaButton
				elseif base==FairyGUI.GSlider then base=FairyGUI.GLuaSlider
					elseif base==FairyGUI.GProgressBar then base=FairyGUI.GLuaProgressBar
						elseif base==FairyGUI.GComboBox then base=FairyGUI.GLuaComboBox
						else
							print("invalid extension base: "..base)
							return
						end
	FairyGUI.LuaUIHelper.SetExtension(url, typeof(base), extension.Extend)
end

--[[
用于继承CS.FairyGUI原来的组件类，例如
MyComponent = FairyGUIUtil.extension_class(GComponent)
function MyComponent:ctor() --当组件构建完成时此方法被调用
	print(self:GetChild("n1"))
end
]]
function FairyGUIUtil.extension_class(base,gcom)
	local o = Class(base)
	o.base = gcom or FairyGUI.GComponent
	o.Extend = function(ins)
		local t = o.new(ins)
	    return t
	end

	return o
end

---以下是内部使用的代码---
local fgui_internal = {}





--这里建立一个c# delegate到lua函数的映射，是为了支持self参数，和方便地进行remove操作
fgui_internal.EventDelegates = {}
setmetatable(fgui_internal.EventDelegates, {__mode = "k"})
function fgui_internal.GetDelegate(func, obj, createIfNone, delegateType)
	local mapping
	if obj~=nil then
		mapping = obj.EventDelegates
		if mapping==nil then
			mapping = {}
			setmetatable(mapping, {__mode = "k"})
			obj.EventDelegates = mapping
		end
	else
		mapping = fgui_internal.EventDelegates
	end

    local delegate = mapping[func]

    if createIfNone and delegate == nil then
        local realFunc
        if obj ~= nil then
            realFunc = function(context)
                return func(obj, context)
            end
        else
            realFunc = func
        end
        delegateType = delegateType or FairyGUI.EventCallback1
        delegate = delegateType(realFunc)
        mapping[func] = delegate
    end

	return delegate
end


return FairyGUIUtil;
