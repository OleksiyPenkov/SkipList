unit unit_SkipList;

interface

uses
SysUtils, Math;


const
  MaxLevel = 16;    // ~lg(MaxInt)
  p = 0.5;         // 1/4

type

  PNode = ^TNode;

  TNode = record
    Key : integer;
    Next: array of PNode;
    Data: string;
  end;

  TSkipList = class
  private
    FHead, FTail: PNode;
    FLevel : Byte;

    FCurrent: PNode;

    function MakeNode(lvl, Value: Integer):PNode;
    function RandomLevel: Integer;
    procedure DeleteNode(var x: PNode);
    function GetEOF: Boolean;
  published
    constructor Create;
    destructor  Destroy; override;

    procedure Insert(AKey: Integer;const NewValue: string);
    function  Search(Akey: Integer):string;
    procedure Delete(AKey : Integer);
    procedure First;
    procedure Next;
    function  Value: string;

    property EOF: Boolean read GetEOF;
  end;

implementation

{ TSkipList }

constructor TSkipList.Create;
begin
  inherited;
  FHead := MakeNode(1, -MaxInt);
  FTail := MakeNode(1, MaxInt);
  FHead.Next[0] := FTail;
  FLevel  := 1;

  {$IFDEF DEBUG}
    FHead.Data := 'BEGIN';
    FTail.Data := 'END';
  {$ENDIF}
end;

procedure TSkipList.Delete(AKey: Integer);
var
  i: Integer;
  x: PNode;
  Left: array of PNode;
begin
  SetLength(Left, FLevel);
  x := FHead;
  for I := FLevel - 1 downto 0 do
  begin
    while (High(x.Next) >= i) and (x.Next[i].key < AKey) do
      x := x.Next[i];
    Left[i] := x;
  end;

  x := x.Next[0];
  if x.Key = AKey then
  begin
    for I := 0 to FLevel - 1 do
    begin
      if Left[i].Next[i] <> x then Break;
      Left[i].next[i] := x.Next[i];
    end;

    DeleteNode(x);

    while (FLevel > 1) and (FHead.Next[FLevel - 1] = FTail) do
      Dec(FLevel);
    SetLength(FHead.Next, FLevel);
  end;
end;

procedure TSkipList.DeleteNode(var x: PNode);
begin
  SetLength(x.next, 0);
  Dispose(x);
end;

procedure TSkipList.First;
begin
  FCurrent := FHead.Next[0];
end;

destructor TSkipList.Destroy;
var
  x: PNode;
begin
  First;
  while not GetEof do
  begin
    x := FCurrent;
    Next;
    DeleteNode(x);
  end;
  DeleteNode(FCurrent);
  DeleteNode(FHead);

  inherited Destroy;
end;

function TSkipList.GetEOF: Boolean;
begin
  Result := FCurrent.Key = MaxInt;
end;

procedure TSkipList.Insert(AKey: Integer;const NewValue: string);
var
  i, lvl: Integer;
  x: PNode;
  Left: array of PNode;
begin
  SetLength(Left, FLevel);
  x := FHead;
  for I := FLevel - 1 downto 0 do
  begin
    while (High(x.Next) >= i) and (x.Next[i].key < AKey) do
      x := x.Next[i];
    Left[i] := x;
  end;

  x := x.Next[0];
  if x.Key = AKey then
     x.Data := NewValue
  else begin
    lvl := RandomLevel;

    x := MakeNode(lvl, AKey);
    x.Data := NewValue;

    if lvl > FLevel then
    begin
      SetLength(FHead.Next, lvl);
      SetLength(Left, lvl);
      for I := FLevel + 1 to lvl do
      begin
        FHead.Next[i - 1] := FTail;
        Left[i - 1] := FHead;
      end;
      FLevel := lvl;
    end;

    for I := 0 to High(x.Next) do
    begin
      x.Next[i] := Left[i].Next[i];
      Left[i].next[i] := x;
    end;
  end;
end;

function TSkipList.MakeNode(lvl, Value: Integer):PNode;
var
  i: Integer;
begin
  Result := New(PNode);
  SetLength(Result.Next, lvl);
  for i:= 0 to lvl - 1 do
    Result.Next[i] := nil;
  Result.Key := Value;
end;

procedure TSkipList.Next;
begin
  FCurrent := FCurrent.Next[0];
end;

function TSkipList.RandomLevel: Integer;
begin
  Result := 1;
  while (Random(100)/100 < p) and (Result < MaxLevel) do
    Inc(Result);
end;

function TSkipList.Search(Akey: Integer): string;
var
  i: Integer;
  x: PNode;
begin
  x := FHead;
  for I := FLevel - 1 downto 0 do
    while (High(x.Next) >= i) and (x.Next[i].key < AKey) do
      x := x.Next[i];
  x := x.Next[0];
  if x.Key = AKey then
    FCurrent := x
  else
    FCurrent := nil;

  Result := x.Data;
end;

function TSkipList.Value: string;
begin
  if FCurrent <> nil then
    Result := FCurrent.Data
  else
    Result := 'NIL';
end;

end.
