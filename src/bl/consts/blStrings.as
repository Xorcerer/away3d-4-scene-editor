package bl.consts
{
	public class blStrings
	{
		public static var BUILD_VERSION : int = 36;		// 编译号
		public static var VERSION:String = blMessageController.VERSION_MAJOR+"."+blMessageController.VERSION_MINOR+"."+blMessageController.VERSION_REVISION+"."+BUILD_VERSION;
		public static var WEB_ADDRESS:String = "http://172.16.8.106/";
		
		public static var SOCKET_ADDRESS : String = "172.16.8.106";
		public static var SESSION_KEY : String = "TEST OK";
		public static var MAP_NAME : String = "";
		public static var MAP_REGULAR : int;
		public static var MAP_RULE : String = "";
		public static var ACCOUNT_NAME : String = "acount name";//账号名
		public static var ACCOUNT_KEY : String = "";//账号密码
		public static var POSITION_NAME : String = "";
		public static var USER_NAME : String = "user name";
		
		public static const ChooseRoleMapName:String = "editor";
		
		public static var ONLINE_ASSETS_URL :String = "../res/";
		public static var ASSETS_MESH_URL : String = ONLINE_ASSETS_URL + "character/";
		public static var ASSETS_ANIM_URL : String = ONLINE_ASSETS_URL + "character/";
		public static var ASSETS_TEXT_URL : String = ONLINE_ASSETS_URL + "character/";
		
		// 场景目录
		public static var ASSETS_SCENE_URL : String = ONLINE_ASSETS_URL + "scene/";
		public static var ASSETS_CHOOSE : String = ASSETS_SCENE_URL + "editor/map.xml";						// 选人场景
		
		// 角色目录
		public static var ASSETS_AVATAR_URL : String = ONLINE_ASSETS_URL +"character/";
		// 特效目录
		public static var ASSETS_EFFECT_URL : String = ONLINE_ASSETS_URL +"effect/";
		// 装备目录
		public static var ASSETS_EQUIPMENT_URL : String = ONLINE_ASSETS_URL + "equipment/";
		// 场景物体目录
		public static var ASSETS_ITEM_URL : String = ONLINE_ASSETS_URL + "items/";
		// UI目录
		public static var ASSETS_UI_URL : String = ONLINE_ASSETS_URL + "ui/";
		// 音效目录
		public static var ASSETS_SOUND_URL : String = ONLINE_ASSETS_URL + "sound/";
		// 音乐目录
		public static var ASSETS_MUSIC_URL : String = ONLINE_ASSETS_URL + "music/";

		//File Type Consts
		public static const FILE_TYPE_TEXTURE : String = ".dds";
		public static const FILE_TYPE_AVATAR_MESH    	: String = ".blm";
		public static const FILE_TYPE_AVATAR_TAG		: String = ".blt";
		public static const FILE_TYPE_AVATAR   		: String = ".bla";
		public static const FILE_TYPE_AVATAR_SEQ		: String = ".blq";		// avatar的动画文件
		public static const FILE_TYPE_XML     : String = "xml";
		
		
		// 角色的通用挂接点名字
		public static const BONETAG_HEAD : String = "Dm_head";						// 头顶的挂接点(眩晕特效等)
		public static const BONETAG_LEFTHAND : String = "Dm_hand_L";				// 左手的挂接点
		public static const BONETAG_RIGHTHAND : String = "Dm_hand_R";				// 右手的挂接点
		public static const BONETAG_LEFTFOOT : String = "Dm_foot_L";				// 左脚的挂接点
		public static const BONETAG_RIGHTFOOT : String = "Dm_foot_R";				// 右脚的挂接点
		public static const BONETAG_CHEST : String = "Dm_chest";						// 胸口的挂接点
		public static const BONETAG_LEFTSHOULDER : String = "Dm_shoulder_L";		// 左肩的挂接点
		public static const BONETAG_RIGHTSHOULDER : String = "Dm_shoulder_R";		// 右肩的挂接点
		public static const BONETAG_1 : String = "Dm_1";								// 附加的挂接点1
		public static const BONETAG_2 : String = "Dm_2";								// 附加的挂接点2
		public static const BONETAG_3 : String = "Dm_3";								// 附加的挂接点3
		public static const BONETAG_4 : String = "Dm_4";								// 附加的挂接点4
		
		
		//career name cn
		public static const NameWarriorCH : String = "zhanshi";
		public static const NameWizardCH : String = "fashi";
		public static const NamePriestCH : String = "mushi";
		
		public static const NameWarriorEN : String = "warrior";
		public static const NameWizardEN : String = "wizard";
		public static const NamePriestEN : String = "priest";
		
		
		
		//程序入口的地方会调用一次重新设置该数据。
		public static function SetConstData(rootUrl : String, webUrl : String) : void
		{
			
			WEB_ADDRESS = webUrl;
			
			// 网络目录调整
			if(rootUrl.indexOf("static") >= 0)
			{
				var pos:int = rootUrl.indexOf("res/");
				rootUrl = rootUrl.substr(0, pos);
				rootUrl += "res_"+blMessageController.VERSION_MAJOR+"_"+blMessageController.VERSION_MINOR+"_"+blMessageController.VERSION_REVISION+"_"+BUILD_VERSION+"/res/";
			}
			
			ONLINE_ASSETS_URL = rootUrl;
			
			ASSETS_MESH_URL = rootUrl + "character/";
			ASSETS_ANIM_URL = rootUrl + "character/";
			ASSETS_TEXT_URL = rootUrl + "character/";
			
			// 场景目录
			ASSETS_SCENE_URL = rootUrl + "scene/";
			ASSETS_CHOOSE = ASSETS_SCENE_URL + "editor/map.xml";						// 选人场景
			
			// 角色目录
			ASSETS_AVATAR_URL = rootUrl +"character/";
			// 特效目录
			ASSETS_EFFECT_URL = rootUrl + "effect/";
			// 装备目录
			ASSETS_EQUIPMENT_URL = rootUrl + "equipment/";
			// 场景物体目录
			ASSETS_ITEM_URL = rootUrl + "items/";
			// UI目录
			ASSETS_UI_URL = rootUrl + "ui/";
			// 音效目录
			ASSETS_SOUND_URL = rootUrl + "sound/";
			// 音乐目录
			ASSETS_MUSIC_URL = rootUrl + "music/";
			
			
		}
		// 该地图是否是村庄
		public static function isCityName(mapName : String) : Boolean
		{
			return mapName.indexOf("city") >= 0;
		}
		
		
		
		
	}
	
}
