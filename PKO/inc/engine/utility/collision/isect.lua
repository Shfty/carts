require("c_isect_c")
require("b_isect_b")
require("py_isect_py")

--unified collision test
function isect(at,ag,bt,bg)
	if(not c_isect_c(at,ag.cr,bt,bg.cr)) return nil
	if(not b_isect_b(at,ag.be,bt,bg.be)) return nil
	return py_isect_py(at,ag.vs,bt,bg.vs)
end
