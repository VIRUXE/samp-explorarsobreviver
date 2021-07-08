#include <YSI_Coding\y_hooks>

hook OnDefenceMove(Item:itemid)
{
	new pose;
	GetItemArrayDataAtCell(itemid, pose, def_pose);
	if(pose == 0) // DEFENCE_POSE_HORIZONTAL
	{
		new objectid, Float:rx, Float:ry, Float:rz;
		GetItemObjectID(itemid, objectid);
		GetItemRot(itemid, rx, ry, rz);
		SetDynamicObjectRot(objectid, rx - 90, ry, rz - 90);
	}
}