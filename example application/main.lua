
@include sheets
@include sheets.elements.UIButton

local document = SMLDocument()

local app, err = document:loadSMLApplicationFile "test/main.sml"

if not app then
	return error( err, 0 )
end

app:run()
