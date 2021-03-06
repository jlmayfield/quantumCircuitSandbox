## Copyright (C) 2014  James Logan Mayfield
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{C} =} compile (@var{g},@var{e})
##
##  Computes a @@QASMsingle that approximates @@QIASMsingle @var{g}
##  to within @var{e}.
##  Users should use qcc for all circuit/gate compilation.
##
## @seealso{qcc}
## @end deftypefn

## Author: Logan Mayfield <lmayfield@monmouthcollege.edu>
## Keywords: QIASM


function q = compile(this,eta)
  global UZERO;

  if(QASMsingleOp(get(this,"name")))
    q = @QASMsingle(get(this,"name"),get(this,"tar"));
  else
    ignore_function_time_stamp("all");


    ## these numbers werechoosen without any real attention to contents
    ## of UZERO...
    ## the larger |capp - sqrt(1/eta0)| the shallower the recrusion ndepth,
    ## the faster this gets done.  eta0 comes form dawson et. al.
    ## capprox was mostly choosen at random... these need attention
    eta0 = 0.16;
    capprox = 1.9;

    ## get the SU(2) variant of this
    [SU,ph] = QIASMop(get(this,"name"),get(this,"params"));
    ## get eta_0 approximation
    [idx,mat] = findclosest(SU);

    ## distance from SU to eta_0 approximation mat
    dist = norm(SU-mat);
    if( dist <= eta ) # good enough. why work more!

      qstrseq = idx2seq(idx);

    else # need a better approximation. more work!

      ## initial ndepth of SK algo
      skdep = uint32(ceil(log( (log(1/(eta*capprox^2))) / ...
			       (log(1/(eta0*capprox^2))) ) / ...
			  log(3/2)));

      ## compile with Solovay-Kiteav
      [idxseq,SUapprox] = skalgo(SU,skdep);

      qstrseq = idx2seq(idxseq);
      ##qstrseq = simpseq(qstrseq);
    endif

    ## convert strings to QASMsingle with correct target
    ## pack into a QASMseq. reverse for circuit order vs. Maths order

    qseq = cell(length(qstrseq),1);
    len = length(qseq);
    t = get(this,"tar");
    nps = idivide(nproc("current"),2,"floor");
    if( nps <= 1 || !exist("parcellfun") )
      for k = 1:len
        qseq{k} = @QASMsingle(qstrseq{len+1-k},t);
      endfor
    else
      build = @(op) @QASMsingle(op,t);
      qseq = parcellfun(nps,build,fliplr(qstrseq), ...
                        "VerboseLevel",0,"ChunksPerProc",15,...
                        "UniformOutput", false);
    endif

    ## package approximating sequence as @QASMseq
    q = @QASMseq(qseq);

    ignore_function_time_stamp("none");
  endif

endfunction

## turns vector of indexs to UZERO to the operator
## sequence
function strs = idx2seq(idxs)
  global UZERO;

  nseqs = length(idxs);
  ## length of each cell of strs in UZERO
  lens = zeros(1,nseqs);
  for k = 1:nseqs
    lens(k) = length(UZERO{idxs(k),1});
  endfor

  ## last indexs in flattened sequence
  lsts = cumsum(lens);
  ## first index in flattened sequence
  fsts = lsts-lens+1;

  ## flattened seq
  strs = cell(1,lsts(nseqs));

  ## copy copy
  for k = 1:nseqs
    strs(fsts(k):lsts(k)) = UZERO{idxs(k),1};
  endfor

endfunction

## computes the 2x2 unitary given operator name and parameters
function [SU,ph] = QIASMop(name,params)

  switch (name)
    case "PhAmp"

      SU = zeros(2);
      SU(1,1) = e^(i*(-params(2)-params(3))/2)*cos(params(1));
      SU(2,2) = SU(1,1)';
      SU(2,1) = e^(i*(params(3)-params(2))/2)*sin(params(1));
      SU(1,2) = -SU(2,1)';

      if(length(params) == 3)
	ph = 0;
      else
	ph = params(4);
      endif

    case "Rn"
      X = [0,1;1,0]; Y = [0,-i;i,0]; Z=[1,0;0,-1];
      A = params(2)*X + params(3)*Y + params(4)*Z;
      SU = e^(-i*params(1)/2*A);

      if(length(params) == 4)
	ph = 0;
      else
	ph = params(5);
      endif
    case "ZYZ"
      Y = [0,-i;i,0]; Z=[1,0;0,-1];
      SU = e^(-i/2*((params(1)+params(3))*Z + params(2)*Y));
      if(length(params) == 3)
	ph = 0;
      else
	ph = params(4);
      endif
  endswitch

endfunction

function b = QASMsingleOp(OpStr)

  switch (OpStr)
    case {"I","X","Z","Y","H","T","S","I'",...
	  "X'","Z'","Y'","H'","T'","S'" }
      b = true;
    otherwise
      b = false;
  endswitch

endfunction


## no sk-algo needed
%!test
%! load("./@QIASMcircuit/private/uzero.mat");
%! assert(eq(compile(@QIASMsingle("H",0),1/32),@QASMsingle("H",0)));
%! assert(eq(compile(@QIASMsingle("X",0),1/32),@QASMsingle("X",0)));
%! assert(eq(compile(@QIASMsingle("Y",1),1/32),@QASMsingle("Y",1)));
%! assert(eq(compile(@QIASMsingle("Z",2),1/32),@QASMsingle("Z",2)));
%! assert(eq(compile(@QIASMsingle("S",0),1/32),@QASMsingle("S",0)));
%! assert(eq(compile(@QIASMsingle("S'",0),1/32),@QASMsingle("S'",0)));
%! assert(eq(compile(@QIASMsingle("T",0),1/32),@QASMsingle("T",0)));
%! assert(eq(compile(@QIASMsingle("T'",0),1/32),@QASMsingle("T'",0)));

## testing SK-based compilation
##  skalgo is independently tested. Here we just ensure that the different
##  operator types get handled properly. S is the table and should get picked
##  up right away
%!test
%! load("./@QIASMcircuit/private/uzero.mat");
%! eta = 2^(-3);
%! ## Phase Amp
%! params = [0,0,pi/2,pi/2]; #S
%! assert(eq(compile(@QIASMsingle("PhAmp",0,params),eta), ...
%!           @QASMseq({@QASMsingle("S",0)})));
%! ## Rotation about n
%! params = [pi/2,0,0,1,pi/4]; #S
%! assert(eq(compile(@QIASMsingle("Rn",0,params),eta), ...
%!           @QASMseq({@QASMsingle("S",0)})));
%! ## Z-Y-Z Rotation
%! params = [pi/2,0,0,pi/2]; #S
%! assert(eq(compile(@QIASMsingle("ZYZ",0,params),eta), ...
%!        @QASMseq({@QASMsingle("S",0)})));
%!
%! clear -g UZERO

## now we just choose a random U and see if the it passes
## the internal check.
%!test
%! load("./@QIASMcircuit/private/uzero.mat");
%! eta = 2^(-3);
%! ## Phase Amp
%! params = [pi/3,pi/3,pi/2,pi/2];
%! compile(@QIASMsingle("PhAmp",0,params),eta);
%! ## Rotation about n
%! params = [pi/2,sqrt(1/3),sqrt(1/3),sqrt(1/3),pi/4];
%! compile(@QIASMsingle("Rn",0,params),eta);
%! ## Z-Y-Z Rotation
%! params = [pi/3,pi/5,2*pi/3,pi/2];
%! compile(@QIASMsingle("ZYZ",0,params),eta);
%! clear -g all
