static
	inst_EntButtonID[MAX_INTERIOR_INSTANCE],
	inst_IntButtonID[MAX_INTERIOR_INSTANCE],
	inst_EntButtonInst[BTN_MAX],
	inst_IntButtonInst[BTN_MAX],
	inst_Total;


stock CreateInteriorInstanceLink(Float:entx, Float:enty, Float:entz, Float:intx, Float:inty, Float:intz, text = "Press "KEYTEXT_INTERACT" to enter", world = 0, labeltext = "", labelcolour = 0xFFFF00FF, streamdist = BTN_DEFAULT_STREAMDIST)
{
	inst_EntButtonID[inst_Total] = CreateButton(entx, enty, entz, text, world, 0, _, 1, labeltext, labelcolour, streamdist);
	inst_IntButtonID[inst_Total] = CreateButton(intx, inty, intz, text, world, 0, _, 1, labeltext, labelcolour, streamdist);

	inst_EntButtonInst[inst_EntButtonID[inst_Total]] = inst_Total;
	inst_IntButtonInst[inst_IntButtonID[inst_Total]] = inst_Total;

	return inst_Total++;
}
