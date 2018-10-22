{
  Retro programming in Borland Turbo Pascal

  Wireframe cube demo.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I cube.vec}

procedure mainloop;
var loop1:integer;
begin
  cls(vaddr);
  repeat
    swapdisplay;
    if border then setborder(50);

    for loop1:=1 to maxpoints do begin
      x:=points[loop1,1]; y:=points[loop1,2]; z:=points[loop1,3];
      rotate(x,y,z,phix,phiy,phiz,newx,newy,newz);
      conv3dto2d(newx,newy,newz,xp[loop1],yp[loop1]);
    end;

    phix:=(phix+xst) and (maxdegrees-1);
    phiy:=(phiy+yst) and (maxdegrees-1);
    phiz:=(phiz+zst) and (maxdegrees-1);

    for loop1:=1 to maxpolygons do begin
      line(xp[polygons[loop1,1]],yp[polygons[loop1,1]],
           xp[polygons[loop1,2]],yp[polygons[loop1,2]],10,vaddr);
      line(xp[polygons[loop1,2]],yp[polygons[loop1,2]],
           xp[polygons[loop1,3]],yp[polygons[loop1,3]],10,vaddr);
      line(xp[polygons[loop1,3]],yp[polygons[loop1,3]],
           xp[polygons[loop1,4]],yp[polygons[loop1,4]],10,vaddr);
      line(xp[polygons[loop1,4]],yp[polygons[loop1,4]],
           xp[polygons[loop1,1]],yp[polygons[loop1,1]],10,vaddr);
    end;

    if border then setborder(0);
  until keypressed;
end;

begin
  setmcga;
  setupvirtual;
  mainloop;
  shutdownvirtual;
  settext;
end.
