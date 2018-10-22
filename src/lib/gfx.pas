{
  Retro programming in Borland Turbo Pascal

  Author: Johan Gardhage <johan.gardhage@gmail.com>
}

unit GFX;

INTERFACE

uses crt;

const VGA = $A000;

var vptr : pointer;                       { our virtual screen }
    vaddr : word;                         { segment of our virtual screen}
    screen_offset : array[0..199] of word;

procedure SetMCGA;
procedure SetText;
procedure setborder (col:byte);
procedure cls (where:word);
procedure setupvirtual;
procedure shutdownvirtual;
procedure flip (source,dest:Word);
procedure swapdisplay;
procedure Pal (Col,R,G,B : Byte);
procedure GetPal (Col : Byte; var R,G,B : Byte);
procedure WaitRetrace;
procedure Hline (x1,x2,y:word;col:byte;where:word);
procedure Line (a,b,c,d:integer;col:byte;where:word);
procedure Putpixel (X,Y : Integer; Col : Byte; where:word);
function Getpixel (X,Y : Integer; where:word) :Byte;
Procedure LoadPCX (filename:string;where:word;dopal:Boolean);

IMPLEMENTATION

{****************************************************************************}

procedure setmcga; assembler;
asm
  mov    ax, 0013h
  int    10h
end;

{****************************************************************************}

procedure settext; assembler;
asm
  mov    ax, 0003h
  int    10h
end;

{****************************************************************************}

procedure setborder (col:byte); assembler;
asm
  mov     dx, 3dah;
  in      al, dx
  mov     dx, 3c0h;
  mov     al, 11h+32;
  out     dx, al;
  mov     al, col;
  out     dx, al;
end;

{****************************************************************************}

procedure cls (where:word); assembler;
asm
  mov     es, [where]
	db      $66, $b9, $80, $3e, $00, $00   {mov     ecx, 16000}
  db      $66, $33, $c0                  {xor     eax, eax}
	db      $66, $33, $ff                  {xor     edi, edi}
  db      $f3, $66, $ab                  {rep     stosd}
end;

{****************************************************************************}

procedure setupvirtual;
begin
  getmem (vptr,64000);
  vaddr := seg (vptr^);
end;

{****************************************************************************}

procedure shutdownvirtual;
begin
  freemem (vptr,64000);
end;

{****************************************************************************}

procedure flip(source,dest:Word); assembler;
asm
  push    ds                              {must be here!!}
  mov     es, [Dest]
  mov     ds, [Source]
  db      $66, $b9, $80, $3e, $00, $00    {mov     ecx, 16000}
  db      $66, $33, $f6                   {xor     esi, esi}
  db      $66, $33, $ff                   {xor     edi, edi}
  db      $f3, $66, $a5                   {rep     movsd}
  pop     ds                              {must be here!!}
end;

{****************************************************************************}

procedure swapdisplay;
begin
  waitretrace;
  flip (vaddr,VGA);
  cls (vaddr);
end;

{****************************************************************************}

procedure Pal (Col,R,G,B : Byte); assembler;
asm
  mov     dx, 3c8h
  mov     al, [col]
  out     dx, al
  inc     dx
  mov     al, [r]
  out     dx, al
  mov     al, [g]
  out     dx, al
  mov     al, [b]
  out     dx, al
end;

{****************************************************************************}

procedure GetPal (Col : Byte; var R,G,B : Byte);
var rr,gg,bb : Byte;
begin
  asm
    mov     dx, 3c7h
    mov     al, [col]
    out     dx, al

    add     dx, 2

    in      al, dx
    mov     [rr], al
    in      al, dx
    mov     [gg], al
    in      al, dx
    mov     [bb], al
  end;
  r := rr;
  g := gg;
  b := bb;
end;

{****************************************************************************}

procedure WaitRetrace; assembler;
asm
  mov     dx, 3DAh
@l1:
  in      al, dx
  and     al, 08h
  jnz     @l1
@l2:
  in      al, dx
  and     al, 08h
  jz      @l2
end;

{****************************************************************************}

procedure Hline (x1,x2,y:word;col:byte;where:word); assembler;
asm
  mov     es, [where]
  mov     bx, [y]
  add     bx, bx
  mov     di, word ptr [screen_offset + bx]
  add     di, [x1]
  mov     al, col
  mov     ah, al
  mov     cx, x2
  sub     cx, x1
  shr     cx, 1
  jnc     @start
  stosb
@Start:
  rep     stosw
end;

{****************************************************************************}

procedure Line(a,b,c,d:integer;col:byte;where:word);
  { This draws a solid line from a,b to c,d in colour col }
  function sgn(a:real):integer;
  begin
       if a>0 then sgn:=+1;
       if a<0 then sgn:=-1;
       if a=0 then sgn:=0;
  end;
var i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;
begin
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     begin
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     end;
     s := m shr 1;
     FOR i := 0 TO m DO
     begin
          putpixel(a,b,col,where);
          s := s + n;
          IF not (s<m) THEN
          begin
               s := s - m;
               a:= a + d1x;
               b := b + d1y;
          end
          ELSE
          begin
               a := a + d2x;
               b := b + d2y;
          end;
     end;
end;

{****************************************************************************}

procedure Putpixel (X,Y : Integer; Col : Byte; where:word); assembler;
asm
  mov     es, [where]
  mov     bx, [y]
  add     bx, bx
  mov     di, word ptr [screen_offset + bx]
  add     di, [x]
  mov     al, [col]
  mov     es:[di],al
end;

{****************************************************************************}

Function Getpixel (X,Y : Integer; where:word):byte; assembler;
asm
  mov     es, [where]
  mov     bx, [y]
  add     bx, bx
  mov     di, word ptr [screen_offset + bx]
  add     di, [x]
  mov     al, es:[di]
end;

{****************************************************************************}

Procedure LoadPCX (filename:string;where:word;dopal:Boolean);
VAR f:file;
    res,loop1:word;
    temp:pointer;
    pallette: Array[0..767] Of Byte;
BEGIN
  assign (f,filename);
  reset (f,1);
  if dopal then BEGIN
    Seek(f,FileSize(f)-768);
    BlockRead(f,pallette,768);
    For loop1:=0 To 255 Do
      pal (loop1,pallette[loop1*3] shr 2,pallette[loop1*3+1] shr 2,pallette[loop1*3+2] shr 2);
  END;
  seek (f,128);

  getmem (temp,65535);
  blockread (f,temp^,65535,res);
  asm
    push ds
    mov  ax,where
    mov  es,ax
    xor  di,di
    xor  ch,ch
    lds  si,temp
@Loop1 :
    lodsb
    mov  bl,al
    and  bl,$c0
    cmp  bl,$c0
    jne  @Single

    mov  cl,al
    and  cl,$3f
    lodsb
    rep  stosb
    jmp  @Fin
@Single :
    stosb
@Fin :
    cmp  di,63999
    jbe  @Loop1
    pop  ds
  end;
  freemem (temp,65535);
  close (f);
END;

{****************************************************************************}

var loop1:integer;
begin
  For loop1 := 0 to 199 do
    screen_offset[loop1] := loop1 * 320;
end.
