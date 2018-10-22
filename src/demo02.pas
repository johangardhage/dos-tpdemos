{
  Retro programming in Borland Turbo Pascal

  Dot torus with z light source demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      rxst=3; ryst=3; rzst=5;
      radius=75;
      dotmaxpoints=2020;
      dotmincol=-246;
      dotmaxcol=416;

var dotpoints:array[1..dotmaxpoints,1..3] of integer;
    nofpoints:word;
    dotxp,dotyp,dotzp:integer;
    dotcolor,dotcoloradd:real;
    dotcolortable:array[dotmincol..dotmaxcol] of integer;

procedure dotinitialize;
const step=0.1;
var alpha,beta:real;
    i:word;
    r,x,y,z,loop1:integer;
begin
  i:=1;
  alpha:=2*pi;
  while alpha>0 do begin
    beta:=pi;
    while beta>0 do begin
      { torus }
      r:=round(radius*sin(beta));
      x:=round(r*cos(alpha)*sin(beta));
      y:=-round(0.8333*r*cos(beta));
      z:=-round(r*sin(alpha)*sin(beta));
      dotpoints[i,1]:=x; dotpoints[i,2]:=y; dotpoints[i,3]:=z;
      beta:=beta-step;
      inc(i);
      if i>dotmaxpoints then begin
        writeln('too many points, change step...');
        halt;
      end;
    end;
    alpha:=alpha-step;
  end;
  nofpoints:=pred(i);

  dotcolor:=0;
  dotcoloradd:=(64/(dotmaxcol-dotmincol));
  for loop1:=dotmincol to dotmaxcol do begin
    dotcolortable[loop1]:=round(dotcolor);
    dotcolor:=dotcolor+dotcoloradd;
  end;
end;

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
   repeat
    swapdisplay;
    if border then setborder(5);

    for loop1:=1 to nofpoints do begin
      x:=dotpoints[loop1,1]; y:=dotpoints[loop1,2]; z:=dotpoints[loop1,3];
      rrotate(x,y,z,rphix,rphiy,rphiz,rnewx,rnewy,rnewz);
      rconv3dto2d(rnewx,rnewy,rnewz,dotxp,dotyp);
      dotzp:=round(rnewz);

      if (dotxp>=0) and (dotxp<=319) and (dotyp>=0) and (dotyp<=199) then
        putpixel(dotxp,dotyp,dotcolortable[dotzp],vaddr);
    end;

    rphix:=rphix+rxst; if rphix<0 then rphix:=rphix+359 else if rphix>359 then rphix:=rphix-359;
    rphiy:=rphiy+ryst; if rphiy<0 then rphiy:=rphiy+359 else if rphiy>359 then rphiy:=rphiy-359;
    rphiz:=rphiz+rzst; if rphiz<0 then rphiz:=rphiz+359 else if rphiz>359 then rphiz:=rphiz-359;

    if border then setborder(0);
  until keypressed;
end;

begin
  dotinitialize;
  setmcga;
  setupvirtual;
  mainloop;
  shutdownvirtual;
  settext;
end.
