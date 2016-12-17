unit UClusterChipTypes;
interface
type
  TOnViewEvent=procedure(aChip, aChipOwner:TObject) of object;
  TOnChipEvent=function(aChipType:Integer; aSender:TObject; aParam:Integer):boolean{worked} of object;
  TOnChipEventI=function(aChipType:Integer; aSender:TObject; aParam:IUnknown):boolean{worked} of object;
  TOnChipEventV=function(aChipType:Integer; aSender:TObject; aParam:Variant):boolean{worked} of object;
  TOnGetChipTypeEvent=function:integer of object;
  PChipList=^TChipList;
  TChipList=record
    Chip:TObject{TChip};
    Next:PChipList;
  end;

implementation

end.
