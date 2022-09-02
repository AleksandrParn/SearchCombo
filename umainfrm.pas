unit umainfrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, SearchText, System.Actions, Vcl.ActnList;

type
  TMainForm = class(TForm)
    ST: TSearchText;
    bAdd: TButton;
    AL: TActionList;
    eAdd: TEdit;
    lbAdded: TListBox;
    aAdd: TAction;
    aClear: TAction;
    bClear: TButton;
    STO: TSearchText;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure aAddUpdate(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aClearUpdate(Sender: TObject);
    procedure aClearExecute(Sender: TObject);
    procedure STDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure STOMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses UITypes;

{$R *.dfm}

procedure TMainForm.aAddExecute(Sender: TObject);
var
  s : string;
begin
  s:=Trim(eAdd.Text);
  lbAdded.ItemIndex:=lbAdded.Items.Add(s);
  ST.Items.Add(s);
  STO.Items.Add(s);
  eAdd.Text:='';
  if eAdd.CanFocus then
    eAdd.SetFocus
end;

procedure TMainForm.aAddUpdate(Sender: TObject);
var
  s : string;
begin
  s:=Trim(eAdd.Text);
  TAction(Sender).Enabled:=(s<>'') AND (lbAdded.Items.IndexOf(s)<0)
end;

procedure TMainForm.aClearExecute(Sender: TObject);
begin
  lbAdded.Clear;
  ST.Clear;
  STO.Clear;
  if eAdd.CanFocus then
    eAdd.SetFocus
end;

procedure TMainForm.aClearUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:=lbAdded.Count>0
end;

const
  Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

procedure TMainForm.FormCreate(Sender: TObject);
var
  R : integer;
  s : string;
  C : Char;
begin
  while ST.Items.Count<20 do begin
    C:=Chars[Random(Length(Chars))+1];
    R:=Random(3)+3;
    s:=StringOfChar(C,R);
    C:=Chars[Random(Length(Chars))+1];
    R:=Random(3)+3;
    s:=s+StringOfChar(C,R);
    if ST.Items.IndexOf(s)<0 then begin
      ST.Items.Add(s);
      lbAdded.Items.Add(s);
      STO.Items.Add(s)
    end;
  end
end;


procedure TMainForm.STDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  s : string;
  C : TSearchText;
  R : TRect;
  d : integer;
begin
  C:=TSearchText(Control);
  C.Canvas.FillRect(Rect);
  CopyRect(R, Rect);
  C.Canvas.Font.Style:=C.Canvas.Font.Style+[fsBold];
  d:=((R.Bottom-R.Top) div 2);
  R.Bottom:=R.Top+d;
  s:='Found text: ';
  C.Canvas.TextRect(R, s, [tfEndEllipsis, tfPathEllipsis, tfExternalLeading, tfLeft, tfSingleLine, tfVerticalCenter]);
  C.Canvas.Font.Style:=C.Canvas.Font.Style-[fsBold];
  CopyRect(R, Rect);
  R.Top:=R.Top+d;
  s:=C.Items[Index];
  C.Canvas.TextRect(R, s, [tfEndEllipsis, tfPathEllipsis, tfExternalLeading, tfLeft, tfSingleLine, tfVerticalCenter]);
  if odSelected IN State then
  C.Canvas.DrawFocusRect(Rect)
end;

procedure TMainForm.STOMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  if Index>-1 then
    Height:=40
end;

initialization
  Randomize;

end.
