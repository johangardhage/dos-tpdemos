{
  Retro programming in Borland Turbo Pascal

  Flat shaded object with z light source demo. Drawn with triangles.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I tricube.vec}

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
      draw_triangle(xp[polygons[pind[loop1],1]],yp[polygons[pind[loop1],1]],
                    xp[polygons[pind[loop1],2]],yp[polygons[pind[loop1],2]],
                    xp[polygons[pind[loop1],3]],yp[polygons[pind[loop1],3]],polyz[loop1]);

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  setmcga;
  setupvirtual;
  for loop1:=1 to 256 do pal(loop1,loop1 div 2,loop1 div 2,loop1 div 4);
  mainloop;
  shutdownvirtual;
  settext;
end.
