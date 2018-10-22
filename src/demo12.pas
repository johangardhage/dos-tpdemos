{
  Retro programming in Borland Turbo Pascal

  Flat shaded cube with real light source demo. Drawn with quads.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      rxst=0.7; ryst=0.7; rzst=0.7;

{$I cube.vec}

procedure mainloop;
var loop1:integer;
begin
  lx:=15; ly:=-15; lz:=15;         { light source coordinates }
  ll:=calclength(lx,ly,lz,lx,ly,lz);
  cls(vaddr);
  repeat
    swapdisplay;
    if border then setborder(50);

    for loop1:=1 to maxpoints do begin
      x:=points[loop1,1]; y:=points[loop1,2]; z:=points[loop1,3];
      rrotate(x,y,z,rphix,rphiy,rphiz,rnewx,rnewy,rnewz);
      rconv3dto2d(rnewx,rnewy,rnewz,xp[loop1],yp[loop1]);
      zp[loop1]:=round(rnewz);
    end;

    rphix:=rphix+rxst; if rphix<0 then rphix:=rphix+359 else if rphix>359 then rphix:=rphix-359;
    rphiy:=rphiy+ryst; if rphiy<0 then rphiy:=rphiy+359 else if rphiy>359 then rphiy:=rphiy-359;
    rphiz:=rphiz+rzst; if rphiz<0 then rphiz:=rphiz+359 else if rphiz>359 then rphiz:=rphiz-359;

    for loop1:=1 to maxpolygons do
      if checkvisible(xp[polygons[loop1,1]],yp[polygons[loop1,1]],
                      xp[polygons[loop1,2]],yp[polygons[loop1,2]],
                      xp[polygons[loop1,3]],yp[polygons[loop1,3]]) then begin

        { calculate lightsource }
        makevector(xp[polygons[loop1,1]],yp[polygons[loop1,1]],
                   zp[polygons[loop1,1]],xp[polygons[loop1,2]],
                   yp[polygons[loop1,2]],zp[polygons[loop1,2]],ux,uy,uz);

        makevector(xp[polygons[loop1,1]],yp[polygons[loop1,1]],
                   zp[polygons[loop1,1]],xp[polygons[loop1,3]],
                   yp[polygons[loop1,3]],zp[polygons[loop1,3]],vx,vy,vz);

        crossproduct(ux,uy,uz,vx,vy,vz,nx,ny,nz);

        nl:=calclength(nx,ny,nz,nx,ny,nz);

        costheta:=(dotproduct(nx,ny,nz,lx,ly,lz))/(ll*nl);
        if costheta>0 then surfcol:=round(63*costheta) else surfcol:=1;

        draw_quad(xp[polygons[loop1,1]],yp[polygons[loop1,1]], { draw plane }
                  xp[polygons[loop1,2]],yp[polygons[loop1,2]],
                  xp[polygons[loop1,3]],yp[polygons[loop1,3]],
                  xp[polygons[loop1,4]],yp[polygons[loop1,4]],surfcol);
      end;

    if border then setborder(0);
  until keypressed;
end;

var loop1:integer;
begin
  setmcga;
  setupvirtual;
  for loop1:=1 to 255 do pal(loop1,loop1,loop1,loop1);
  mainloop;
  shutdownvirtual;
  settext;
end.
