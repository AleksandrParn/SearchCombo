unit SearchText;

interface

uses SysUtils, Windows, Messages, Classes, VCL.Controls, VCL.StdCtrls;

type
  TSearchTextStyle = (stsStandard, stsOwnerDraw);

  TSearchText = class (TCustomComboBox)
  strict private
    FFilter           : string;
    FBaseHeight       : integer;
    FItemHeight       : integer;
    FSaveStrings      : TStrings;
    FItemsSaved       : boolean;
    FFilteredItems    : TStrings;
    FDefDropDownCount : integer;
    FDrawStyle        : TSearchTextStyle;
    FInFilterMode     : boolean;
    procedure PerformAutoActions(var Key: Char);
    function SelectItem(const AnItem: string): Boolean;
  private
    procedure SetDrawStyle(const Value: TSearchTextStyle);
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure SetDroppedDown(Value: Boolean);
  protected
    FSelectFirstFound : boolean;
    property AutoComplete default False;
    property AutoDropDown default false;
    property AutoCompleteDelay default 500;
    property AutoCloseUp default False;
    procedure AdjustDropDown; override;
    procedure Change; override;
    procedure CreateParams(var Params: TCreateParams); override;
    function GetItemHt: Integer; override;
    function IsItemHeightStored: Boolean; override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure ReturnItems;
    procedure Select; override;
    procedure SetItems(const Value: TStrings); override;
    procedure WndProc(var Message: TMessage); override;
    procedure SetItemHeight(Value: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property BevelEdges;
    property BevelInner;
//    property BevelKind default bkNone;
    property BevelOuter;
    property Anchors;
    property BiDiMode;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
//    property ItemIndex default -1;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Style : TSearchTextStyle read FDrawStyle write SetDrawStyle default stsStandard;
    property SelectFirstFound : boolean read FSelectFirstFound write FSelectFirstFound default false;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Touch;
    property Visible;
    property StyleElements;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
    property Items;
  end;

procedure Register;

implementation

uses VCL.Themes, VCL.Graphics;


procedure Register;
begin
  RegisterComponents('My components', [TSearchText])
end;

{ TSearchText }

procedure TSearchText.AdjustDropDown;
var
  I, L  : Integer;
  H, X  : Integer;
begin
  if FBaseHeight=0 then
    FBaseHeight:=Height;
  I:=ItemCount;
  if FDefDropDownCount=0 then
    FDefDropDownCount:=DropDownCount
  else
    DropDownCount:=FDefDropDownCount;
  if I>DropDownCount then
    I:=DropDownCount
  else if I<DropDownCount then
    DropDownCount:=I;
  if I<1 then
    I:=1;
  FDroppingDown := True;
  try
    if FBaseHeight<>0 then
      Height:=FBaseHeight;
    if FDrawStyle=stsStandard then
      H:=(ItemHeight * (I+1)) + Height + 2
    else begin
      L:=ItemCount;
      H:=Height + 2;
      X:=0;
      for I := 0 to L-1 do begin
        MeasureItem(I, X);
        H:=H+X
      end;
      H:=H+X
    end;
    SetWindowPos(FDropHandle, 0, 0, 0, Width, H, SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOREDRAW or
      SWP_HIDEWINDOW);
  finally
    FDroppingDown := False;
  end;
  SetWindowPos(FDropHandle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
    SWP_NOZORDER or SWP_NOACTIVATE or SWP_SHOWWINDOW)
end;

procedure TSearchText.Change;
begin
  Inherited Change
end;

procedure TSearchText.CNMeasureItem(var Message: TWMMeasureItem);
var
  H : Integer;
  MeasureItemStruct: PMeasureItemStruct;
begin
  MeasureItemStruct := Message.MeasureItemStruct;
  with MeasureItemStruct^ do begin
    itemHeight := FItemHeight;
    if FDrawStyle = stsOwnerDraw then begin
      H := FItemHeight;
      if Integer(ItemID)=-1 then
        H:=Height
      else
        MeasureItem(itemID, H);
      itemHeight := H
    end;
  end;
  Message.MeasureItemStruct := MeasureItemStruct
end;

constructor TSearchText.Create(AOwner: TComponent);
begin
  inherited;
  FInFilterMode:=false;
  FSaveStrings:=TStringList.Create;
  FFilteredItems:=TStringList.Create;
  FItemsSaved:=false;
  FSelectFirstFound:=false;
  FBaseHeight:=0;
  FItemHeight := 20;
  Inherited Style:=csSimple;
  Style:=stsStandard;
  ItemHeight:=Height;
  AutoDropDown:=false;
  AutoComplete:=false;
  AutoCloseUp:=false
end;

procedure TSearchText.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if FDrawStyle=stsOwnerDraw then
    Params.Style := Params.Style OR CBS_OWNERDRAWFIXED
  else
    Params.Style := Params.Style AND NOT CBS_OWNERDRAWFIXED
end;

destructor TSearchText.Destroy;
begin
  FreeAndNil(FSaveStrings);
  FreeAndNil(FFilteredItems);
  inherited
end;

function TSearchText.GetItemHt: Integer;
begin
  if FDrawStyle=stsOwnerDraw then
    Result := FItemHeight
  else
    Result := Perform(CB_GETITEMHEIGHT, 0, 0)
end;

function TSearchText.IsItemHeightStored: Boolean;
begin
   Result := (FDrawStyle=stsOwnerDraw) and (FItemHeight <> 16)
end;

procedure TSearchText.KeyPress(var Key: Char);
var
  LItemIndex: Integer;
begin
  LItemIndex := ItemIndex;
  inherited;
  if AutoComplete then
    Exit;
  PerformAutoActions(Key);
  if ItemIndex <> LItemIndex then begin
    TLinkObservers.ListSelectionChanged(Observers)
  end
end;

procedure TSearchText.Loaded;
begin
  inherited;
  FSaveStrings.Assign(Items);
  FItemsSaved:=true
end;

procedure TSearchText.PerformAutoActions(var Key: Char);
  function HasSelectedText(var StartPos, EndPos: Integer): Boolean;
  begin
    if Inherited Style in [csDropDown, csSimple] then
    begin
      SendGetIntMessage(Handle, CB_GETEDITSEL, StartPos, EndPos);
      Result := EndPos > StartPos;
    end
    else
      Result := False;
  end;

  procedure DeleteSelectedText(const StartPos, EndPos: DWORD);
  var
     OldText: String;
  begin
    OldText := Text;
    Delete(OldText, StartPos + 1, EndPos - StartPos);
    SendMessage(Handle, CB_SETCURSEL, WPARAM(-1), 0);
    Text := OldText;
    FFilter:='';
    SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(StartPos, StartPos));
  end;

var
  StartPos, EndPos: Integer;
  OldText: string;
  SaveText: string;
  LastByte: Integer;
  Msg : TMSG;
begin
  FFilter := Text;
  case Ord(Key) of
    VK_ESCAPE: exit;
    VK_TAB:
      if DroppedDown then
        DroppedDown := False;
    VK_BACK:
      begin
        if HasSelectedText(StartPos, EndPos) then
          DeleteSelectedText(StartPos, EndPos)
        else
          if (Inherited Style in [csDropDown, csSimple]) and (Length(Text) > 0) then
          begin
            SaveText := Text;
            LastByte := StartPos;
            while ByteType(SaveText, LastByte) = mbTrailByte do Dec(LastByte);
            OldText := Copy(SaveText, 1, LastByte - 1);
            SendMessage(Handle, CB_SETCURSEL, WPARAM(-1), 0);
            Text := OldText + Copy(SaveText, EndPos + 1, MaxInt);
            SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(LastByte - 1, LastByte - 1));
            FFilter := Text;
          end
          else
          begin
            while ByteType(FFilter, Length(FFilter)) = mbTrailByte do
              Delete(FFilter, Length(FFilter), 1);
            Delete(FFilter, Length(FFilter), 1);
          end;
        Key := #0;
        SelectItem(FFilter);
        Change;
      end;
  else // case
    HasSelectedText(StartPos, EndPos); // This call sets StartPos and EndPos
    if (Inherited Style < csDropDownList) and (StartPos < Length(FFilter))  then
      SaveText := Copy(FFilter, 1, StartPos) + Key + Copy(FFilter, EndPos+1, Length(FFilter))
    else
      SaveText := FFilter + Key;
    if AutoDropDown and not DroppedDown then
      DroppedDown := True;

    if IsLeadChar(Key) then
    begin
      if PeekMessage(Msg, Handle, 0, 0, PM_NOREMOVE) and (Msg.Message = WM_CHAR) then
      begin
        if SelectItem(SaveText + Char(Msg.wParam)) then
        begin
          PeekMessage(Msg, Handle, 0, 0, PM_REMOVE);
          Key := #0
        end;
      end;
    end
    else begin
      Key:=#0;
      if NOT SelectItem(SaveText) then
        SelStart:=Length(SaveText)
    end
  end // case
end;

procedure TSearchText.ReturnItems;
var
  Idx : integer;
  s   : string;
begin
  if FBaseHeight<>0 then
    Height:=FBaseHeight;
  FBaseHeight:=0;
  Idx:=ItemIndex;
  if Idx>-1 then
    s:=Items[Idx]
  else
    s:=Text;
  FFilteredItems.Clear;
  if FItemsSaved then begin
    FInFilterMode:=true;
    try
      Items.Assign(FSaveStrings)
    finally
      FInFilterMode:=false
    end;
    FItemsSaved:=false
  end;
  if Idx>-1 then
    ItemIndex:=Items.IndexOf(s);
  Text:=s;
  SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Length(s), Length(s)))
end;

procedure TSearchText.Select;
begin
  inherited;
  if ItemIndex>-1 then
    DroppedDown:=false
end;

function TSearchText.SelectItem(const AnItem: string): Boolean;
var
  I, Idx: Integer;
  ValueChange: Boolean;
//  s, t  : string;
begin
  ValueChange:=false;
  if Length(AnItem) = 0 then begin
    Result := False;
    ItemIndex := -1;
    FFilteredItems.Clear;
    Change;
    if DroppedDown then
      DroppedDown:=false;
    Exit
  end;
  FFilteredItems.BeginUpdate;
  FInFilterMode:=true;
  try
    if FItemsSaved then
      Items.Assign(FSaveStrings)
    else if NOT FItemsSaved then begin
      FSaveStrings.Assign(Items);
      FItemsSaved:=true
    end;
    Idx:=-1;
    FFilteredItems.Clear;
    repeat
      I := SendTextMessage(Handle, CB_FINDSTRING, WPARAM(Idx), AnItem);
      if I<=Idx then
        Break;
      if I<>CB_ERR then begin
        FFilteredItems.Add(Items[I]);
        Idx:=I
      end
    until I=CB_ERR;
    Items.Assign(FFilteredItems);
    Result := FFilteredItems.Count>0;
    Text := AnItem;// + Copy(Items[Idx], Length(AnItem) + 1, MaxInt);
    SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Length(AnItem), Length(Text)));
    if not Result then
      Exit;

    if FSelectFirstFound then begin
      Idx := SendTextMessage(Handle, CB_FINDSTRINGEXACT, WPARAM(-1), AnItem);

      if Idx=CB_ERR then
        Exit;
      Text := AnItem+Copy(Items[Idx], Length(AnItem) + 1, MaxInt);
      SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Length(AnItem), Length(Text)));
      ValueChange := Idx <> ItemIndex;
      ItemIndex := Idx;
      if ValueChange then
        SendMessage(Handle, CB_SETCURSEL, Idx, 0)
    end
  finally
    FFilteredItems.EndUpdate;
    SetDroppedDown(ItemCount>0);
    FInFilterMode:=false
  end;
  if ValueChange AND FSelectFirstFound then begin
    Click;
    Select
  end
end;

procedure TSearchText.SetDrawStyle(const Value: TSearchTextStyle);
begin
  if FDrawStyle <> Value then begin
    FDrawStyle := Value;
    if Value = stsStandard then
      ControlStyle := ControlStyle - [csFixedHeight]
    else
      ControlStyle := ControlStyle + [csFixedHeight];
    RecreateWnd
  end
end;

procedure TSearchText.SetDroppedDown(Value: Boolean);
begin
  SendMessage(Handle, CB_SHOWDROPDOWN, WPARAM(Value), 0)
end;

procedure TSearchText.SetItemHeight(Value: Integer);
begin
  if Value > 0 then begin
    FItemHeight := Value;
    Inherited
  end
end;

procedure TSearchText.SetItems(const Value: TStrings);
begin
  inherited;
   FSaveStrings.Assign(Value);
   FItemsSaved:=true
end;

procedure TSearchText.WndProc(var Message: TMessage);
begin
  if Message.Msg=CB_SHOWDROPDOWN then begin
    if Message.WParam=0 then begin
      ReturnItems
    end
    else
      AdjustDropDown
  end
  else if (Message.Msg=CBN_KillFocus) OR (Message.Msg=CM_EXIT) then begin
    ReturnItems
  end
  else if FItemsSaved AND NOT FInFilterMode then
    case Message.Msg of
      CB_ADDSTRING,
      CB_INSERTSTRING,
      CB_DELETESTRING,
      CB_RESETCONTENT : FItemsSaved:=false;
    end;
  inherited
end;

end.


