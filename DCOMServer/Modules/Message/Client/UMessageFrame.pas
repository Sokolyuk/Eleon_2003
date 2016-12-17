unit UMessageFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, UPackMessageTypes;

type
  TFMessage = class(TFrame)
    LabelSender: TLabel;
    EditSender: TEdit;
    LabelReceiver: TLabel;
    EditReceiver: TEdit;
    LabelSubject: TLabel;
    EditSubject: TEdit;
    MemoMessage: TMemo;
    LabelMessage: TLabel;
    ListBoxAttachments: TListBox;
    LabelAttachments: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    LLabelPriority: TLabel;
    LLabelType: TLabel;
    LabelPriority: TLabel;
    LabelType: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure SetPackMessage(aPackMessage:IPackMessage);
    Procedure Clear;
  end;

implementation
  Uses UVarsetTypes, UEMailAttachmentTypes;

{$R *.dfm}

Procedure TFMessage.Clear;
begin
  ListBoxAttachments.Clear;
  LabelSender.Enabled:=False;
  EditSender.Enabled:=False;
  EditSender.Text:='';
  LabelReceiver.Enabled:=False;
  EditReceiver.Enabled:=False;
  EditReceiver.Text:='';
  LabelSubject.Enabled:=False;
  EditSubject.Enabled:=False;
  EditSubject.Text:='';
  LabelMessage.Enabled:=False;
  MemoMessage.Enabled:=False;
  MemoMessage.Text:='';
  LLabelPriority.Color:=clBtnFace;
  LabelPriority.Font.Color:=clWindowText;
  LabelPriority.Caption:='';
  LabelType.Caption:='';
  //..
  LLabelPriority.Enabled:=False;
  LLabelType.Enabled:=False;
  LabelAttachments.Enabled:=False;
end;

Procedure TFMessage.SetPackMessage(aPackMessage:IPackMessage);
  Var tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIntIndex:Integer;
      tmpIEMailAttachment:IEMailAttachment;
begin
  Clear;
  If Not Assigned(aPackMessage) Then Raise Exception.Create('aPackMessage is not assigned.');
  If aPackMessage.Attachments.ITCount=0 Then begin
    ListBoxAttachments.Visible:=False;
    LabelAttachments.Visible:=False;
    EditSender.Width:=Bevel1.Width-8;
    EditReceiver.Width:=Bevel1.Width-8;
    EditSubject.Width:=Bevel1.Width-8;
  end else begin
    ListBoxAttachments.Visible:=True;
    LabelAttachments.Visible:=True;
    EditSender.Width:=161;
    EditReceiver.Width:=161;
    EditSubject.Width:=161;
    tmpIntIndex:=-1;
    While true do begin
      tmpIVarsetDataView:=aPackMessage.Attachments.ITViewNextGetOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then break;
      If Not Assigned(tmpIVarsetDataView) Then raise exception.Create('tmpIVarsetDataView is not assigned.');
      tmpIUnknown:=tmpIVarsetDataView.ITData;
      If (Not Assigned(tmpIUnknown))Or(tmpIUnknown.QueryInterface(IEMailAttachment, tmpIEMailAttachment)<>S_OK)Or(Not Assigned(tmpIEMailAttachment)) Then Raise Exception.Create('IEMailAttachment is not found.');
      ListBoxAttachments.Items.Add(tmpIEMailAttachment.FileName);
    end;
    tmpIVarsetDataView:=Nil;
    tmpIEMailAttachment:=Nil;
    tmpIUnknown:=Nil;
  end;
  //..
  If aPackMessage.Sender<>'' then begin
    LabelSender.Enabled:=True;
    EditSender.Enabled:=True;
    EditSender.Text:=aPackMessage.Sender;
  end;
  //..
  If aPackMessage.Receiver<>'' then begin
    LabelReceiver.Enabled:=True;
    EditReceiver.Enabled:=True;
    EditReceiver.Text:=aPackMessage.Receiver;
  end;
  //..
  If aPackMessage.Subject<>'' then begin
    LabelSubject.Enabled:=True;
    EditSubject.Enabled:=True;
    EditSubject.Text:=aPackMessage.Subject;
  end;
  //..
  If aPackMessage.Msg<>'' then begin
    LabelMessage.Enabled:=True;
    MemoMessage.Enabled:=True;
    MemoMessage.Text:=aPackMessage.Msg;
  end;
  //..
  Case aPackMessage.Priority of
    prtExtreme:begin
      LabelPriority.Caption:='Экстренное';
      LabelPriority.Font.Color:=clRed;
      LLabelPriority.Color:=clRed;
    end;
    prtHigh:begin
      LabelPriority.Caption:='Срочное';
      LabelPriority.Font.Color:=clRed;
    end;
    prtNormal:begin
      LabelPriority.Caption:='Нормальное';
      LabelPriority.Font.Color:=clBlue;
    end;
    prtLow:begin
      LabelPriority.Caption:='Несрочное';
      LabelPriority.Font.Color:=clWindowText;
    end;
  Else
    LabelPriority.Font.Color:=clYellow;
    LabelPriority.Caption:='Unknown';
  End;
  //..
  Case aPackMessage.MsgType of
    mstSystem:begin
      LabelType.Caption:='Системное';
      LabelType.Font.Color:=clRed;
    end;
    mstAdministrative:begin
      LabelType.Caption:='Административное';
      LabelType.Font.Color:=clYellow;
    end;
    mstUser:begin
      LabelType.Caption:='Пользовательское';
      LabelType.Font.Color:=clBlue;
    end;
  Else
    LabelType.Caption:='Unknown';
  End;
  //..
  LLabelPriority.Enabled:=True;
  LLabelType.Enabled:=True;
  LabelAttachments.Enabled:=True;
end;

end.
