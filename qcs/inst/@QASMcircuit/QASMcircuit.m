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
## @deftypefn {Function File} {@var{C} =} QASMcircuit (@var{s},@var{n})
##
## Construct an @var{n} qubit circuit from sequence object @var{s}.
## Users should not construct circuits directly but instead use
## some combination of QIR, horzcat, and qcc
##
##
## @seealso{QIR,qcc, @@QIRcircuit/horzcat }
##
## @end deftypefn
##

## Author: Logan Mayfield <lmayfield@monmouthcollege.edu>
## Keywords: QASM

function c = QASMcircuit(cNode,n)

  if(nargin == 0 )
    c.cir = @circuit(@QASMseq({}),0,0,[],[]);
  elseif(nargin == 1 || nargin == 2)
    bits = 0;
    seq = cNode;
    maxndepth = maxndepth(seq);
    tars = collecttars(seq);
    stps = zeros(maxndepth,1);

    for d = 1:maxndepth
      stps(d) = stepsat(seq,d);
    endfor

    if( nargin == 2 )
      bits = n;
    else
      bits = 1+max(tars);
    endif

    c.cir = @circuit(seq,bits,maxndepth,stps,tars);

  endif

  c = class(c,"QASMcircuit");

endfunction
