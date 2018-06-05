// Generated by Haxe 3.4.7
#include <hxcpp.h>

#ifndef INCLUDED_ChildProcess
#include <ChildProcess.h>
#endif
#ifndef INCLUDED_sys_io_Process
#include <sys/io/Process.h>
#endif

HX_DEFINE_STACK_FRAME(_hx_pos_baacac1fce9ae4d9_29_new,"ChildProcess","new",0xd192dec5,"ChildProcess.new","Pzd.hx",29,0x7dac3c04)
HX_LOCAL_STACK_FRAME(_hx_pos_baacac1fce9ae4d9_38_start,"ChildProcess","start",0x6df6a607,"ChildProcess.start","Pzd.hx",38,0x7dac3c04)
HX_LOCAL_STACK_FRAME(_hx_pos_baacac1fce9ae4d9_42_status,"ChildProcess","status",0xc9dc25ed,"ChildProcess.status","Pzd.hx",42,0x7dac3c04)

void ChildProcess_obj::__construct(::String name,::String command,bool vital,int replicas,::String comments){
            	HX_STACKFRAME(&_hx_pos_baacac1fce9ae4d9_29_new)
HXLINE(  31)		this->name = name;
HXLINE(  32)		this->command = command;
HXLINE(  33)		this->vital = vital;
HXLINE(  34)		this->replicas = replicas;
HXLINE(  35)		this->comments = comments;
            	}

Dynamic ChildProcess_obj::__CreateEmpty() { return new ChildProcess_obj; }

void *ChildProcess_obj::_hx_vtable = 0;

Dynamic ChildProcess_obj::__Create(hx::DynamicArray inArgs)
{
	hx::ObjectPtr< ChildProcess_obj > _hx_result = new ChildProcess_obj();
	_hx_result->__construct(inArgs[0],inArgs[1],inArgs[2],inArgs[3],inArgs[4]);
	return _hx_result;
}

bool ChildProcess_obj::_hx_isInstanceOf(int inClassId) {
	return inClassId==(int)0x00000001 || inClassId==(int)0x008b251b;
}

void ChildProcess_obj::start(){
            	HX_STACKFRAME(&_hx_pos_baacac1fce9ae4d9_38_start)
            	}


HX_DEFINE_DYNAMIC_FUNC0(ChildProcess_obj,start,(void))

void ChildProcess_obj::status(){
            	HX_STACKFRAME(&_hx_pos_baacac1fce9ae4d9_42_status)
            	}


HX_DEFINE_DYNAMIC_FUNC0(ChildProcess_obj,status,(void))


ChildProcess_obj::ChildProcess_obj()
{
}

void ChildProcess_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(ChildProcess);
	HX_MARK_MEMBER_NAME(name,"name");
	HX_MARK_MEMBER_NAME(pid,"pid");
	HX_MARK_MEMBER_NAME(command,"command");
	HX_MARK_MEMBER_NAME(vital,"vital");
	HX_MARK_MEMBER_NAME(replicas,"replicas");
	HX_MARK_MEMBER_NAME(comments,"comments");
	HX_MARK_MEMBER_NAME(pidstatus,"pidstatus");
	HX_MARK_MEMBER_NAME(rc,"rc");
	HX_MARK_MEMBER_NAME(p,"p");
	HX_MARK_END_CLASS();
}

void ChildProcess_obj::__Visit(HX_VISIT_PARAMS)
{
	HX_VISIT_MEMBER_NAME(name,"name");
	HX_VISIT_MEMBER_NAME(pid,"pid");
	HX_VISIT_MEMBER_NAME(command,"command");
	HX_VISIT_MEMBER_NAME(vital,"vital");
	HX_VISIT_MEMBER_NAME(replicas,"replicas");
	HX_VISIT_MEMBER_NAME(comments,"comments");
	HX_VISIT_MEMBER_NAME(pidstatus,"pidstatus");
	HX_VISIT_MEMBER_NAME(rc,"rc");
	HX_VISIT_MEMBER_NAME(p,"p");
}

hx::Val ChildProcess_obj::__Field(const ::String &inName,hx::PropertyAccess inCallProp)
{
	switch(inName.length) {
	case 1:
		if (HX_FIELD_EQ(inName,"p") ) { return hx::Val( p ); }
		break;
	case 2:
		if (HX_FIELD_EQ(inName,"rc") ) { return hx::Val( rc ); }
		break;
	case 3:
		if (HX_FIELD_EQ(inName,"pid") ) { return hx::Val( pid ); }
		break;
	case 4:
		if (HX_FIELD_EQ(inName,"name") ) { return hx::Val( name ); }
		break;
	case 5:
		if (HX_FIELD_EQ(inName,"vital") ) { return hx::Val( vital ); }
		if (HX_FIELD_EQ(inName,"start") ) { return hx::Val( start_dyn() ); }
		break;
	case 6:
		if (HX_FIELD_EQ(inName,"status") ) { return hx::Val( status_dyn() ); }
		break;
	case 7:
		if (HX_FIELD_EQ(inName,"command") ) { return hx::Val( command ); }
		break;
	case 8:
		if (HX_FIELD_EQ(inName,"replicas") ) { return hx::Val( replicas ); }
		if (HX_FIELD_EQ(inName,"comments") ) { return hx::Val( comments ); }
		break;
	case 9:
		if (HX_FIELD_EQ(inName,"pidstatus") ) { return hx::Val( pidstatus ); }
	}
	return super::__Field(inName,inCallProp);
}

hx::Val ChildProcess_obj::__SetField(const ::String &inName,const hx::Val &inValue,hx::PropertyAccess inCallProp)
{
	switch(inName.length) {
	case 1:
		if (HX_FIELD_EQ(inName,"p") ) { p=inValue.Cast<  ::sys::io::Process >(); return inValue; }
		break;
	case 2:
		if (HX_FIELD_EQ(inName,"rc") ) { rc=inValue.Cast< int >(); return inValue; }
		break;
	case 3:
		if (HX_FIELD_EQ(inName,"pid") ) { pid=inValue.Cast< int >(); return inValue; }
		break;
	case 4:
		if (HX_FIELD_EQ(inName,"name") ) { name=inValue.Cast< ::String >(); return inValue; }
		break;
	case 5:
		if (HX_FIELD_EQ(inName,"vital") ) { vital=inValue.Cast< bool >(); return inValue; }
		break;
	case 7:
		if (HX_FIELD_EQ(inName,"command") ) { command=inValue.Cast< ::String >(); return inValue; }
		break;
	case 8:
		if (HX_FIELD_EQ(inName,"replicas") ) { replicas=inValue.Cast< int >(); return inValue; }
		if (HX_FIELD_EQ(inName,"comments") ) { comments=inValue.Cast< ::String >(); return inValue; }
		break;
	case 9:
		if (HX_FIELD_EQ(inName,"pidstatus") ) { pidstatus=inValue.Cast< bool >(); return inValue; }
	}
	return super::__SetField(inName,inValue,inCallProp);
}

void ChildProcess_obj::__GetFields(Array< ::String> &outFields)
{
	outFields->push(HX_HCSTRING("name","\x4b","\x72","\xff","\x48"));
	outFields->push(HX_HCSTRING("pid","\x4b","\x58","\x55","\x00"));
	outFields->push(HX_HCSTRING("command","\x4b","\x71","\x6d","\x81"));
	outFields->push(HX_HCSTRING("vital","\x0c","\x35","\x08","\x37"));
	outFields->push(HX_HCSTRING("replicas","\x3b","\x97","\x60","\x1d"));
	outFields->push(HX_HCSTRING("comments","\x34","\x99","\xfa","\xc0"));
	outFields->push(HX_HCSTRING("pidstatus","\xbd","\x09","\xad","\x03"));
	outFields->push(HX_HCSTRING("rc","\xb1","\x63","\x00","\x00"));
	outFields->push(HX_HCSTRING("p","\x70","\x00","\x00","\x00"));
	super::__GetFields(outFields);
};

#if HXCPP_SCRIPTABLE
static hx::StorageInfo ChildProcess_obj_sMemberStorageInfo[] = {
	{hx::fsString,(int)offsetof(ChildProcess_obj,name),HX_HCSTRING("name","\x4b","\x72","\xff","\x48")},
	{hx::fsInt,(int)offsetof(ChildProcess_obj,pid),HX_HCSTRING("pid","\x4b","\x58","\x55","\x00")},
	{hx::fsString,(int)offsetof(ChildProcess_obj,command),HX_HCSTRING("command","\x4b","\x71","\x6d","\x81")},
	{hx::fsBool,(int)offsetof(ChildProcess_obj,vital),HX_HCSTRING("vital","\x0c","\x35","\x08","\x37")},
	{hx::fsInt,(int)offsetof(ChildProcess_obj,replicas),HX_HCSTRING("replicas","\x3b","\x97","\x60","\x1d")},
	{hx::fsString,(int)offsetof(ChildProcess_obj,comments),HX_HCSTRING("comments","\x34","\x99","\xfa","\xc0")},
	{hx::fsBool,(int)offsetof(ChildProcess_obj,pidstatus),HX_HCSTRING("pidstatus","\xbd","\x09","\xad","\x03")},
	{hx::fsInt,(int)offsetof(ChildProcess_obj,rc),HX_HCSTRING("rc","\xb1","\x63","\x00","\x00")},
	{hx::fsObject /*::sys::io::Process*/ ,(int)offsetof(ChildProcess_obj,p),HX_HCSTRING("p","\x70","\x00","\x00","\x00")},
	{ hx::fsUnknown, 0, null()}
};
static hx::StaticInfo *ChildProcess_obj_sStaticStorageInfo = 0;
#endif

static ::String ChildProcess_obj_sMemberFields[] = {
	HX_HCSTRING("name","\x4b","\x72","\xff","\x48"),
	HX_HCSTRING("pid","\x4b","\x58","\x55","\x00"),
	HX_HCSTRING("command","\x4b","\x71","\x6d","\x81"),
	HX_HCSTRING("vital","\x0c","\x35","\x08","\x37"),
	HX_HCSTRING("replicas","\x3b","\x97","\x60","\x1d"),
	HX_HCSTRING("comments","\x34","\x99","\xfa","\xc0"),
	HX_HCSTRING("pidstatus","\xbd","\x09","\xad","\x03"),
	HX_HCSTRING("rc","\xb1","\x63","\x00","\x00"),
	HX_HCSTRING("p","\x70","\x00","\x00","\x00"),
	HX_HCSTRING("start","\x62","\x74","\x0b","\x84"),
	HX_HCSTRING("status","\x32","\xe7","\xfb","\x05"),
	::String(null()) };

static void ChildProcess_obj_sMarkStatics(HX_MARK_PARAMS) {
	HX_MARK_MEMBER_NAME(ChildProcess_obj::__mClass,"__mClass");
};

#ifdef HXCPP_VISIT_ALLOCS
static void ChildProcess_obj_sVisitStatics(HX_VISIT_PARAMS) {
	HX_VISIT_MEMBER_NAME(ChildProcess_obj::__mClass,"__mClass");
};

#endif

hx::Class ChildProcess_obj::__mClass;

void ChildProcess_obj::__register()
{
	hx::Object *dummy = new ChildProcess_obj;
	ChildProcess_obj::_hx_vtable = *(void **)dummy;
	hx::Static(__mClass) = new hx::Class_obj();
	__mClass->mName = HX_HCSTRING("ChildProcess","\x53","\x18","\x29","\x82");
	__mClass->mSuper = &super::__SGetClass();
	__mClass->mConstructEmpty = &__CreateEmpty;
	__mClass->mConstructArgs = &__Create;
	__mClass->mGetStaticField = &hx::Class_obj::GetNoStaticField;
	__mClass->mSetStaticField = &hx::Class_obj::SetNoStaticField;
	__mClass->mMarkFunc = ChildProcess_obj_sMarkStatics;
	__mClass->mStatics = hx::Class_obj::dupFunctions(0 /* sStaticFields */);
	__mClass->mMembers = hx::Class_obj::dupFunctions(ChildProcess_obj_sMemberFields);
	__mClass->mCanCast = hx::TCanCast< ChildProcess_obj >;
#ifdef HXCPP_VISIT_ALLOCS
	__mClass->mVisitFunc = ChildProcess_obj_sVisitStatics;
#endif
#ifdef HXCPP_SCRIPTABLE
	__mClass->mMemberStorageInfo = ChildProcess_obj_sMemberStorageInfo;
#endif
#ifdef HXCPP_SCRIPTABLE
	__mClass->mStaticStorageInfo = ChildProcess_obj_sStaticStorageInfo;
#endif
	hx::_hx_RegisterClass(__mClass->mName, __mClass);
}

