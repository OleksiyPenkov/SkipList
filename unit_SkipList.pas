unit unit_SkipList;

interface

uses
SysUtils, Math;


const
  MaxLevel = 16;    // ~lg(MaxInt)
  p = 0.25;

type

  PNode = ^TNode;

  TNode = record
    Key : integer;
    Next: array of PNode;
    Data: string;
  end;

  TSkipList = class
  private
    Header, Tail: PNode;
    Level : Byte;

    Current: PNode;

    function MakeNode(lvl, Value: Integer):PNode;
    function RandomLevel: Integer;
    procedure DeleteNode(var x: PNode);
    function GetEOF: Boolean;
  published
    constructor Create;
    destructor  Free;

    procedure Insert(AKey: Integer; NewValue: string);
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
  Header := MakeNode(1, -MaxInt);

  Tail := MakeNode(1, MaxInt);
  Header.Next[0] := Tail;
  Level  := 1;

  {$IFDEF DEBUG}
    Header.Data := 'BEGIN';
    Tail.Data := 'END';
  {$ENDIF}
end;

procedure TSkipList.Delete(AKey: Integer);
var
  i, lvl: Integer;
  x: PNode;
  Left: array of PNode;
begin
  SetLength(Left, Level);
  x := Header;
  for I := Level - 1 downto 0 do
  begin
    while (High(x.Next) >= i) and (x.Next[i].key < AKey) do
      x := x.Next[i];
    Left[i] := x;
  end;

  x := x.Next[0];
  if x.Key = AKey then
  begin
    for I := 0 to Level - 1 do
    begin
      if Left[i].Next[i] <> x then Break;
      Left[i].next[i] := x.Next[i];
    end;

    DeleteNode(x);

    while (Level > 1) and (Header.Next[Level - 1] = Nil) do
      Dec(Level);
  end;
end;

procedure TSkipList.DeleteNode(var x: PNode);
begin
  SetLength(x.next, 0);
  Dispose(x);
end;

procedure TSkipList.First;
begin
  Current := Header.Next[0];
end;

destructor TSkipList.Free;
var
  x: PNode;
begin
  First;
  while not EOF do
  begin
    x := Current;
    Next;
    DeleteNode(x);
  end;
  DeleteNode(Current);
  DeleteNode(Header);
end;

function TSkipList.GetEOF: Boolean;
begin
  Result := Current.Key = MaxInt;
end;

procedure TSkipList.Insert(AKey: Integer; NewValue: string);
var
  i, lvl: Integer;
  x: PNode;
  Left: array of PNode;
begin
  SetLength(Left, Level);
  x := Header;
  for I := Level - 1 downto 0 do
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

    if lvl > level then
    begin
      SetLength(Header.Next, lvl);
      SetLength(Left, lvl);
      for I := Level + 1 to lvl do
      begin
        Header.Next[i - 1] := Tail;
        Left[i - 1] := Header;
      end;
      Level := lvl;
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
  Current := Current.Next[0];
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
  x := Header;
  for I := Level - 1 downto 0 do
  begin
    while x.Next[i].key < AKey do
      x := x.Next[i];
  end;
  x := x.Next[0];
  if x.Key = AKey then
    Current := x
  else
    Current := nil;

  Result := x.Data;
end;

function TSkipList.Value: string;
begin
  if Current <> nil then
    Result := Current.Data
  else
    Result := 'NIL';
end;

end.
