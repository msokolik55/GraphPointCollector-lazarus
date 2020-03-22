program project1;
uses wincrt, graph;

var gd, gm: smallint;
    x1, y1, sirka, vyska, volba: integer;
    ch: char;

const okraj: integer = 20;

procedure pozadie(x1, y1, sirka, vyska: integer);
begin
  setfillstyle(1, lightgray);
  bar(x1, y1, x1 + sirka, y1 + vyska);
end;

procedure menu(x1, y1, sirka, vyska, volba: integer);
var moznosti: array [1..3] of string;
    i: integer;
begin
  moznosti[1] := 'LAHKE';
  moznosti[2] := 'TAZKE';
  moznosti[3] := 'KONIEC';

  setcolor(black);
  outtextxy(x1 + sirka div 2 - 20, y1 - vyska div 2, 'HADIK');

  for i := 1 to length(moznosti) do
  begin
    if(i = volba) then setcolor(black)
    else setcolor(white);
    line(x1, y1, x1 + sirka, y1); 
    line(x1, y1, x1, y1 + vyska);

    if(i = volba) then setcolor(white)
    else setcolor(black);
    line(x1, y1 + vyska, x1 + sirka, y1 + vyska);
    line(x1 + sirka, y1, x1 + sirka, y1 + vyska);

    outtextxy(x1 + 10, y1 + vyska div 2, moznosti[i]);

    y1 := y1 + 2 * vyska;
  end;
end;

procedure plocha(x1, y1, sirka, vyska: integer);
begin
  setfillstyle(1, black);
  bar(x1, y1, x1 + sirka, y1 + vyska);
end;

procedure hadik(x1, y1, rozmer, farba: integer);
begin
  setfillstyle(1, farba);
  bar(x1, y1, x1 + rozmer, y1 + rozmer);
end;

procedure vygenerujKruzok(x1, y1, sirka, vyska, rozmer: integer);
var farba, x, y: integer;
begin
  randomize;

  x := random(sirka - 4 * rozmer) + x1 + rozmer;
  y := random(vyska - 4 * rozmer) + y1 + rozmer;

  farba := random(14) + 1;
  setcolor(farba);
  circle(x, y, rozmer div 3);

  setfillstyle(1, farba);
  floodfill(x, y, farba);
end;

procedure ukazSkore(x1, y1, skore: integer; ukazat: boolean);
var s: string;
begin
  str(skore, s);
  s := 'Skore: ' + s;

  if(ukazat) then setcolor(black)
  else setcolor(lightgray);
  outtextxy(x1, y1 - 10, s);
end;

procedure skontrolujOkolie(x1, y1, x, y, rozmer, sirka, vyska: integer; var skore, farba: integer);
var farbaVpravo, farbaVlavo, farbaHore, farbaDole, i: integer;
begin
  for i := 1 to (rozmer + 1) do
  begin
    farbaVpravo := getpixel(x + (rozmer + 1), y + i - 1);
    farbaVlavo := getpixel(x - 1, y + i - 1);
    farbaHore := getpixel(x + i - 1, y + 1);
    farbaDole := getpixel(x + i - 1, y + rozmer + 1);

    if(((farbaVpravo <> 0) or (farbaVlavo <> 0)) and
        (x - 1 > x1) and (x + rozmer + 1 < x1 + sirka)) or
      (((farbaHore <> 0) or (farbaDole <> 0)) and
         (y - 1 > y1) and (y + rozmer + 1 < y1 + vyska))
    then
    begin
      ukazSkore(x1, y1, skore, False);
      skore := skore + 1;
      ukazSkore(x1, y1, skore, True);
      setfillstyle(1, black);
      bar(x - (rozmer + 1), y - rozmer, x + (2 * rozmer + 1), y + 2 * rozmer);

      if (farbaVpravo <> 0) then farba := farbaVpravo;
      if (farbaVlavo <> 0) then farba := farbaVlavo;
      if (farbaHore <> 0) then farba := farbaHore;
      if (farbaDole <> 0) then farba := farbaDole;

      vygenerujKruzok(x1, y1, sirka, vyska, rozmer);
    end;

  end;
end;

procedure hra(x1, y1, sirka, vyska, obtiaznost: integer);
var x, y, rozmer, krok, skore,
      farba: integer;
    koniec, vpravo, vlavo, hore, dole: boolean;
    ch: char;
begin
  plocha(x1, y1, sirka, vyska);

  rozmer := 10;
  vygenerujKruzok(x1, y1, sirka, vyska, rozmer);

  krok := 5;
  vpravo := True;
  vlavo := False;
  hore := False;
  dole := False;

  x := x1 + 10;
  y := y1 + 10;
  farba := 15;

  koniec := False;
  skore := 0;
  ukazSkore(x1, y1, skore, True);

  repeat
    hadik(x, y, rozmer, farba);

    if(keypressed) then
    begin
      ch := readkey;

      case ch of
        #072:
        begin
          vpravo := False;
          vlavo := False;
          hore := True;
          dole := False;
        end;

        #080:
        begin
          vpravo := False;
          vlavo := False;
          hore := False;
          dole := True;
        end;

        #075:
        begin
          vpravo := False;
          vlavo := True;
          hore := False;
          dole := False;
        end;

        #077:
        begin
          vpravo := True;
          vlavo := False;
          hore := False;
          dole := False;
        end;
      end;
    end;

    delay(30 + obtiaznost mod 2 * 50);
    hadik(x, y, rozmer, 0);

    skontrolujOkolie(x1, y1, x, y, rozmer, sirka, vyska, skore, farba);

    if(vpravo) then x := x + krok;
    if(vlavo) then x := x - krok;
    if(hore) then y := y - krok;
    if(dole) then y := y + krok;

    if(x + rozmer > x1 + sirka) or (x < x1) or
      (y < y1) or (y + rozmer > y1 + vyska) then koniec := True;
  until koniec or (skore >= 10);

  setcolor(white);
  if(skore >= 10) then outtextxy(x1 + sirka div 2, y1 + vyska div 2, 'VYHRAL SI')
  else outtextxy(x1 + sirka div 2, y1 + vyska div 2, 'KONIEC HRY');

  delay(3000);
end;

begin
  gd := detect;
  initgraph(gd, gm, '');

  x1 := 100;
  y1 := 100;
  sirka := 800;
  vyska := 500;

  volba := 1;

  repeat
    repeat
      pozadie(x1, y1, sirka, vyska);
      menu(x1 + okraj, y1 + vyska div 7, sirka div 5, vyska div 7, volba);

      ch := readkey;
      if(ch = #072) and (volba > 1) then volba := volba - 1;
      if(ch = #080) and (volba < 3) then volba := volba + 1;
    until ch = chr(13);

    if(volba <> 3) then
      hra(x1 + 2 * okraj + sirka div 5, y1 + okraj,
          sirka - (3 * okraj + sirka div 5), vyska - 2 * okraj, volba);
  until volba = 3;

  settextstyle(1, 2, 3);
  setcolor(black);
  outtextxy(x1 + sirka div 2, y1 + vyska div 2, 'PEKNY DEN');

  delay(5000);
  closegraph();
end.

