//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackPDTypes;

interface
  Uses UPackPDPlacesTypes, UPackPDErrorTypes, UPackTypes;
Type
  TPackPDOption=(pdoNoTransform, pdoWithNotificationOfError, pdoWithNotificationOfDelivery, pdoWithCheckOfPassing,
              pdoNoResult, pdoReturnDataIfError, pdoNoPutOnReSending, pdoReserver8, pdoReserver9, pdoReserver10,
              pdoReserver11, pdoReserver12, pdoReserver13, pdoReserver14, pdoReserver15, pdoReserver16, pdoReserver17,
              pdoReserver18, pdoReserver19, pdoReserver20, pdoReserver21, pdoReserver22, pdoReserver23, pdoReserver24,
              pdoReserver25, pdoReserver26, pdoReserver27, pdoReserver28, pdoReserver29, pdoReserver30, pdoReserver31, pdoReserver32);

  TPackPDOptions={Integer}Set of TPackPDOption;

  IPackPD=Interface(IPack)
  ['{C1FAD7A0-A85C-47AB-B438-BA33374FCED0}']
    function Get_PDOptions:TPackPDOptions;
    procedure Set_PDOptions(Value:TPackPDOptions);
    function Get_Places:IPackPDPlaces;
    procedure Set_Places(Value:IPackPDPlaces);
    function Get_DataAsVariant:Variant;
    procedure Set_DataAsVariant(Const Value:Variant);
    function Get_DataAsIPack:IPack;
    procedure Set_DataAsIPack(Value:IPack);
    function Get_PDID:Variant;
    procedure Set_PDID(Const Value:Variant);
    function Get_PDError:IPackPDError;
    procedure Set_PDError(Value:IPackPDError);
    //..
    procedure Clear;
    function ClonePackPD:IPackPD;
    property PDOptions:TPackPDOptions read Get_PDOptions write Set_PDOptions;
    property Places:IPackPDPlaces read Get_Places write Set_Places;
    property DataAsVariant:Variant read Get_DataAsVariant write Set_DataAsVariant;
    property DataAsIPack:IPack read Get_DataAsIPack write Set_DataAsIPack;
    property PDID:Variant read Get_PDID write Set_PDID;
    property PDError:IPackPDError read Get_PDError write Set_PDError;
    //Для версии 2
    //LifeTime
  End;

implementation

end.

