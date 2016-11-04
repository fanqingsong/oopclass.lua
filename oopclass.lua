

local _M = {}

-- Instantiates a class
local function _instantiate(class, ...)
    -- 抽象类不能实例化
    if rawget(class, "__abstract") then
        error("asbtract class cannot be instantiated.")
    end

    -- 单例模式，如果实例已经生成，则直接返回
    if rawget(class, "__singleton") then
        -- _G[class]值为本class的实例
        if _G[class] then
            return _G[class]
        end
    end

    local inst = setmetatable({__class=class}, {__index=class})
    if inst.__init__ then
        inst:__init__(...)
    end

    --单例模式，如果实例未生成，则将实例记录到类中
    if rawget(class, "__singleton") then
        if not _G[class] then
            _G[class] = inst

            -- 对类对象增加实例获取接口
            class.getInstance = function ( self )
                return _G[class]
            end

            -- 销毁单例，为后续建立新单例准备
            class.destroyInstance = function ( self )
                _G[class] = nil
            end
        end
    end

    return inst
end

-- LUA类构造函数
function _M.class(base)
    local metatable = {
        __call = _instantiate,
    }

    -- 先查原型表，然后查父亲类
    metatable.__index=function(t, k)
        local v = t.__prototype[k]
        if v then
            return v
        end

        local parent = t.__parent
        if parent then
            return parent[k]
        end

        return nil
    end

    -- 缓存类的field
    metatable.__newindex=function (t,k,v)
        rawset(t.__prototype, k, v)
    end

    local _class = {}
    -- __parent 属性缓存父类
    _class.__parent = base or {}
    -- 存储此类的所有field
    _class.__prototype = {}

    -- 在class对象中记录 metatable ，以便重载 metatable.__index
    _class.__metatable = metatable

    -- 将类冷冻，不允许新建删除修改
    _class.freeze = function ( self )
        local mt = getmetatable(self)

        mt.__newindex=function (t,k,v)
            error("class is frozen, cannot revise")
        end
    end

    return setmetatable(_class, metatable)
end

--- Test whether the given object is an instance of the given class.
-- @param object Object instance
-- @param class Class object to test against
-- @return Boolean indicating whether the object is an instance
-- @see class
-- @see clone
function _M.instanceof(object, class)
    local objClass = object.__class
    if not objClass then
        return false
    end

    while objClass do
        if objClass == class then
            return true
        end
        objClass = objClass.__parent
    end

    return false
end

return _M

