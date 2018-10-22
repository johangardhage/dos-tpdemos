{
  Retro programming in Borland Turbo Pascal

  Gouraud shaded cube with z light source demo. Drawn with triangles.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I trigerow.vec}

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

    {Sort the polygons by z-value, so I know in which order to draw them}
    numvisible:=0;
    for loop1:=1 to maxpolygons do
      if not checkvisible(xp[polygons[loop1,1]],yp[polygons[loop1,1]],
                          xp[polygons[loop1,2]],yp[polygons[loop1,2]],
                          xp[polygons[loop1,3]],yp[polygons[loop1,3]]) then begin
        inc(numvisible); pind[numvisible]:=loop1;
        polyz[numvisible]:=zp[polygons[loop1,1]]+zp[polygons[loop1,2]]+zp[polygons[loop1,3]];
      end;

    quicksort(numvisible);

    for loop1:=1 to numvisible do begin
      gouraudcol1:=(28+Zp[polygons[pind[loop1],1]] Div 3);
	    gouraudcol2:=(28+Zp[polygons[pind[loop1],2]] Div 3);
	    gouraudcol3:=(28+Zp[polygons[pind[loop1],3]] Div 3);

      draw_tri_gouraud(xp[polygons[pind[loop1],1]],yp[polygons[pind[loop1],1]],
                       xp[polygons[pind[loop1],2]],yp[polygons[pind[loop1],2]],
                       xp[polygons[pind[loop1],3]],yp[polygons[pind[loop1],3]],
                       gouraudcol1,gouraudcol2,gouraudcol3);
    end;

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  setmcga;
  setupvirtual;
  for loop1:=1 to 64 do pal(loop1,loop1,loop1,loop1);
  mainloop;
  shutdownvirtual;
  settext;
end.
