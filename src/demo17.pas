{
  Retro programming in Borland Turbo Pascal

  Glenzvector object demo. Drawn with triangles.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I triglenz.vec}

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  repeat
    swapdisplay;
    if border then setborder(5);

    for loop1:=1 to maxpoints do begin
      x:=points[loop1,1]; y:=points[loop1,2]; z:=points[loop1,3];
      rotate(x,y,z,phix,phiy,phiz,newx,newy,newz);
      conv3dto2d(newx,newy,newz,xp[loop1],yp[loop1]);
      zp[loop1]:=newz;
    end;

    phix:=(phix+xst) and (maxdegrees-1);
    phiy:=(phiy+yst) and (maxdegrees-1);
    phiz:=(phiz+zst) and (maxdegrees-1);

    for loop1:=1 to maxpolygons do begin
      polyz[loop1]:=(zp[polygons[loop1,1]]+zp[polygons[loop1,2]]+zp[polygons[loop1,3]]) div 3;
      pind[loop1]:=loop1;
    end;

    quicksort(maxpolygons);

    for loop1:=maxpolygons-maxvisible to maxpolygons do
      draw_tri_glenz(xp[polygons[pind[loop1],1]],yp[polygons[pind[loop1],1]],
                     xp[polygons[pind[loop1],2]],yp[polygons[pind[loop1],2]],
                     xp[polygons[pind[loop1],3]],yp[polygons[pind[loop1],3]],polycols[pind[loop1]]);

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  setmcga;
  setupvirtual;
  pal(0,0,0,0);
  pal(1,0,0,0);
  pal(2,60,15,15); { dark red }
  pal(3,60,24,24); { light red }
  pal(4,0,0,0);
  pal(5,60,60,60); { light white }
  pal(6,63,63,63); { dark white }
  pal(7,0,0,0);
  mainloop;
  shutdownvirtual;
  settext;
end.
