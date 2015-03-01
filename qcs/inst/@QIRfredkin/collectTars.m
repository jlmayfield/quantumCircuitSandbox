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
## @deftypefn {Function File} {@var{t} =} collectTars (@var{g})
##
## Return the targets and control for Fredkin gate @var{g}
##
## @end deftypefn

## Author: Logan Mayfield <lmayfield@monmouthcollege.edu>
## Keywords: QIR

function t = collectTars(this)
  bits = [this.tars,this.ctrl];
  t = sort(bits);
endfunction

%!test
%! assert(isequal([0,1,2],collectTars(@QIRfredkin([2,1],0))));
%! assert(isequal([0,1,2],collectTars(@QIRfredkin([1,2],0))));
%! assert(isequal([0,1,2],collectTars(@QIRfredkin([0,2],1))));
%! assert(isequal([0,1,2],collectTars(@QIRfredkin([2,0],1))));
%! assert(isequal([0,1,2],collectTars(@QIRfredkin([0,1],2))));
%! assert(isequal([0,1,2],collectTars(@QIRfredkin([1,0],2))));
