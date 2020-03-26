program skiplist;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  unit_SkipList in 'unit_SkipList.pas';

var
  List: TSkipList;
  i, key, stored1, stored2: Integer;

  procedure PrintList;
  begin
    List.First;
    while not List.EOF do
    begin
      write(List.Value, ', ');
      List.Next;
    end;
    Writeln;
  end;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    Randomize;

    List := TSkipList.Create;
    try

      for I := 1 to 10 do
      begin
        key := Random(98) + 1;
        List.Insert(key, 'Data ' + IntToStr(Key));
        write(key, ' ');
        if i = 5 then stored1 := key;
        if i = 3 then stored2 := key;
      end;
      Writeln;

      PrintList;

      List.Insert(stored1, 'Updated value ' + IntToStr(stored1));  // update value

      PrintList;

      Writeln(List.Search(stored1));

      List.Delete(stored2);

      PrintList;

      Readln;
    finally
      List.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
