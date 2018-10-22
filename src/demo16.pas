{
  Retro programming in Borland Turbo Pascal

  Gouraud shaded cube with real light source demo. Drawn with triangles.

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

program demonstration;

uses crt,gfx,vector;

const border:boolean=false;
      xst=1; yst=1; zst=1;

{$I trigerow.vec}

procedure initialize;
begin
  lx:=0; ly:=0; lz:=15;         { light source coordinates }
  ll:=calclength(lx,ly,lz,lx,ly,lz);
end;

procedure calcvertexnormal(point:integer;var color:byte);
var loop1,faces:integer;
    relx,rely,relz,vl:real;
begin
  {In which face is each point used, and average these face-normals}
  relx:=0; Rely:=0; Relz:=0; faces:=0;
  for loop1:=1 to maxpolygons do begin
    if (polygons[loop1,1]=point) or (polygons[loop1,2]=point) or (polygons[loop1,3]=point) then begin
      relx:=relx+gnx[loop1]; rely:=rely+gny[loop1]; relz:=relz+gnz[loop1];
      inc(faces);
    end;
  end;
  relx:=relx/faces; rely:=rely/faces; relz:=relz/faces;
  vl:=calclength(relx,rely,relz,relx,rely,relz);

  costheta:=(dotproduct(relx,rely,relz,lx,ly,lz))/(ll*vl);
  if costheta>0 then color:=round(31*costheta) else color:=1;
end;

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
      makevector(xp[polygons[loop1,3]],yp[polygons[loop1,3]],
                 zp[polygons[loop1,3]],xp[polygons[loop1,1]],
                 yp[polygons[loop1,1]],zp[polygons[loop1,1]],ux,uy,uz);

      makevector(xp[polygons[loop1,2]],yp[polygons[loop1,2]],
                 zp[polygons[loop1,2]],xp[polygons[loop1,1]],
                 yp[polygons[loop1,1]],zp[polygons[loop1,1]],vx,vy,vz);

      crossproduct(ux,uy,uz,vx,vy,vz,gnx[loop1],gny[loop1],gnz[loop1]);
    end;

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
      calcvertexnormal(polygons[pind[loop1],1],gouraudcol1);
      calcvertexnormal(polygons[pind[loop1],2],gouraudcol2);
      calcvertexnormal(polygons[pind[loop1],3],gouraudcol3);

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
  initialize;
  setmcga;
  setupvirtual;
  for loop1:=1 to 255 do pal(loop1,loop1-32,loop1-32,loop1-32);
  mainloop;
  shutdownvirtual;
  settext;
end.
