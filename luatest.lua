
local oopclass = require("oopclass")

local class = oopclass.class
local instanceof = oopclass.instanceof


local superTab =  class()
superTab.test = function ( self )
    print("superTab test")
end

superTab:freeze()

superTab.test2 = function ( self )
    print("superTab test2")
end

local tab = class(superTab)

local tabObj = tab()
tabObj:test()


print( instanceof(tabObj, tab) )

print( instanceof(tabObj, superTab) )


