unit TiScriptApi;

interface

uses
  Windows;

type
  ptiscript_native_interface = ^tiscript_native_interface;
  HVM = ^tiscript_vm;

  { TIScript value }
  tiscript_value = type Int64;
  ptiscript_value = ^tiscript_value;

  { TIScript pinned value }
  tiscript_pvalue = record
    val: tiscript_value;
    vm: HVM;
    {$WARN UNSAFE_CODE OFF}
    d1: Pointer;
    d2: Pointer;
    {$WARN UNSAFE_CODE ON}
  end;
  ptiscript_pvalue = ^tiscript_pvalue;

  { Sciter VM handle }
  tiscript_VM = record
  end;

  { TIScript method callback }
  tiscript_method = function(c: HVM): tiscript_value; cdecl;
  ptiscript_method = ^tiscript_method;

  { non-documented }
  tiscript_tagged_method = function(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
  ptiscript_tagged_method = ^tiscript_tagged_method;

  { TIScript method definition }
  tiscript_method_def = record
    dispatch: Pointer;
    name: PAnsiChar;
    handler: Pointer; // can be either tiscript_method or tiscript_tagged_method
    tag: Pointer;
  end;
  ptiscript_method_def = ^tiscript_method_def;

  tiscript_method_def_array = array[0..0] of tiscript_method_def;
  ptiscript_method_def_array = ^tiscript_method_def_array;

  tiscript_get_prop = function(c: HVM; obj: tiscript_value): tiscript_value; cdecl;
  ptiscript_get_prop = ^tiscript_get_prop;

  tiscript_set_prop = procedure(c: tiscript_VM; obj: tiscript_value; value: tiscript_value ); cdecl;
  ptiscript_set_prop = ^tiscript_set_prop;

  tiscript_finalizer = procedure(c: tiscript_VM; obj: tiscript_value); cdecl;
  ptiscript_finalizer = ^tiscript_finalizer;

  { TIScript property definition }
  tiscript_prop_def = record
    dispatch: Pointer;
    name: PAnsiChar;
    getter: ptiscript_get_prop;
    setter: ptiscript_set_prop;
    tag: Pointer;
  end;
  ptiscript_prop_def = ^tiscript_prop_def;

  { TOScript class definition }
  tiscript_class_def = record
    name: PAnsiChar;
    methods:    ptiscript_method_def;
    props:      ptiscript_prop_def;
    consts:     Pointer; // ptiscript_const_def;
    get_item:   Pointer; // ptiscript_get_item;
    set_item:   Pointer; // ptiscript_set_item;
    finalizer:  ptiscript_finalizer;
    iterator:   Pointer; // ptiscript_iterator;
    on_gc_copy: Pointer; // ptiscript_on_gc_copy;
    prototype:  tiscript_value;
  end;
  ptiscript_class_def = ^tiscript_class_def;

  tiscript_native_interface = record
    create_vm: function(features: UINT; heap_size: UINT): HVM; cdecl;     // 1
    destroy_vm: procedure(pvm: HVM); cdecl;
    invoke_gc: procedure(pvm: HVM); cdecl;
    set_std_streams: procedure; cdecl;
    get_current_vm: function: HVM; cdecl;                                 // 5
    get_global_ns: function(pvm: HVM): tiscript_value; cdecl;
    get_current_ns: function(pvm: HVM): tiscript_value; cdecl;
    is_int: function(v: tiscript_value): Boolean; cdecl;
    is_float: function(v: tiscript_value): Boolean; cdecl;
    is_symbol: function(v: tiscript_value): Boolean; cdecl;               // 10
    is_string: function(v: tiscript_value): Boolean; cdecl;
    is_array: function(v: tiscript_value): Boolean; cdecl;
    is_object: function(v: tiscript_value): BOOL; cdecl;
    is_native_object: function(v: tiscript_value): Boolean; cdecl;
    is_function: function(v: tiscript_value): Boolean; cdecl;             // 15
    is_native_function: function(v: tiscript_value): Boolean; cdecl;
    is_instance_of : function(v: tiscript_value; cls: tiscript_value): Boolean; cdecl;
    is_undefined : function(v: tiscript_value): Boolean; cdecl;
    is_nothing : function(v: tiscript_value): Boolean; cdecl;
    is_null : function(v: tiscript_value): Boolean; cdecl;                // 20
    is_true : function(v: tiscript_value): Boolean; cdecl;
    is_false : function(v: tiscript_value): Boolean; cdecl;
    is_class : function(pvm: HVM; v: tiscript_value): Boolean; cdecl;
    is_error : function(v: tiscript_value): Boolean; cdecl;
    is_bytes : function(v: tiscript_value): Boolean; cdecl;               // 25
    is_datetime : function(pvm: HVM; v: tiscript_value): bool; cdecl;
    get_int_value : function(v: tiscript_value; var pi: Integer): bool; cdecl;
    get_float_value : function(v: tiscript_value; var pd: double): bool; cdecl;
    get_bool_value : function(v: tiscript_value; var pb: bool): bool; cdecl;
    get_symbol_value : function(v: tiscript_value; var psz: PWideChar): bool; cdecl; // 30
    get_string_value : function(v: tiscript_value; var pdata: PWideChar; var pLength: UINT): bool; cdecl;
    get_bytes : function(v: tiscript_value; var pb: PByte {* unsigned char** }; var pblen: UINT): BOOL; cdecl;
    get_datetime : function(pvm: HVM; v: tiscript_value; var dt: FILETIME): BOOL; cdecl;
    nothing_value : function: tiscript_value; cdecl;
    undefined_value : function: tiscript_value; cdecl;                    // 35
    null_value : function: tiscript_value; cdecl;
    bool_value : function(v: bool): tiscript_value; cdecl;
    int_value : function (v: integer): tiscript_value; cdecl;
    float_value : function(v: double): tiscript_value; cdecl;
    string_value : function (pvm: HVM; text: PWideChar; text_length: UINT): tiscript_value; cdecl; // 40
    symbol_value : function(zstr: PAnsiChar): tiscript_value; cdecl;
    bytes_value : function(pvm: HVM; data: PByte; data_length: UINT): tiscript_value; cdecl;
    datetime_value : function(pvm: HVM; ft: FILETIME): tiscript_value; cdecl;

    to_string : function(pvm: HVM; v: tiscript_value): tiscript_value; cdecl;

    define_class : function(pvm: HVM; cls: ptiscript_class_def; zns: tiscript_value): tiscript_value; cdecl; // 45
    create_object : function(pvm: HVM; cls: tiscript_value): tiscript_value; cdecl;
    set_prop : function(pvm: HVM; obj: tiscript_value; key: tiscript_value; value: tiscript_value): WordBool; cdecl;
    get_prop : function(pvm: HVM; obj: tiscript_value; key: tiscript_value): tiscript_value; cdecl;
    for_each_prop : function(pvm: HVM; obj: tiscript_value; cb: {tiscript_object_enum* cb} Pointer; tag: Pointer): BOOL; cdecl;
    get_instance_data : function(obj: tiscript_value): Pointer; cdecl;    // 50
    set_instance_data : procedure(obj: tiscript_value; data: Pointer); cdecl;

    create_array : procedure; cdecl;
    set_elem : procedure; cdecl;
    get_elem : function(vm: HVM; arr: tiscript_value; idx: UINT): tiscript_value; cdecl;
    set_array_size : procedure; cdecl;  // 55
    get_array_size : function(vm: HVM; arr: tiscript_value): UINT; cdecl;

    // eval
    eval : procedure; cdecl;
    eval_string : function(vm: HVM; ns: tiscript_value; script: PWideChar; script_length: UINT; var pretval: tiscript_value): boolean; cdecl;
    // call function (method)
    call : function(pvm: HVM; obj: tiscript_value; func: tiscript_value; argv: ptiscript_value; argn: UINT; var pretval: tiscript_value): BOOL; cdecl;

    // compiled bytecodes
    compile: procedure; cdecl; // 60
    loadbc: procedure; cdecl;

    throw_error: procedure(pvm: HVM; error: PWideChar); cdecl;

    get_arg_count: function(pvm: HVM): UINT; cdecl;
    get_arg_n: function(pvm: HVM; n: UINT): tiscript_value; cdecl;

    get_value_by_path: function(pvm: HVM; v: ptiscript_value; path: PAnsiChar): Boolean; cdecl;  /// 65

    // pins
    pin: procedure(vm: HVM; value: ptiscript_pvalue); cdecl;
    unpin: procedure(value: ptiscript_pvalue); cdecl;

    native_function_value: function(pvm: HVM; method: ptiscript_method_def): tiscript_value; cdecl;
    native_property_value: function(pvm: HVM; prop: ptiscript_prop_def): tiscript_value; cdecl;

    post: procedure; cdecl;   // 70

    set_remote_std_streams: procedure; cdecl;
    set_nth_retval: procedure; cdecl;
    get_length: procedure; cdecl;
    get_next: procedure; cdecl;
    get_next_key_value: procedure; cdecl; // 75

    set_extra_data: procedure; cdecl;
    get_extra_data: procedure; cdecl;      // 77
  end;

implementation

end.
