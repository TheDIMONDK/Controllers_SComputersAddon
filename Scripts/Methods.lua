---------------------------------
--        By TheDIMONDK        --
---------------------------------
-- 2024-2025 Copyrighted code. Scrap Mechanic API.


function checkArg(v3, v2, ...)
	v2 = type(v2)
	local v4 = {...}
	for _, t in ipairs(v4) do
		if v2 == t then
			return
		end
	end
	error(string_format("bad argument #%d (%s expected, got %s)", v3, table_concat(v4, " or "), v2), 3)
end