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

## Usage: q = compile(this)
##
## returns approximate @QASMseq to @QIASMseq this. Non-QASM operators
## are approximated.  
##

## Author: Logan Mayfield <lmayfield@monmouthcollege.edu>
## Keywords: QIASM
 

function q = compile(this,eta)
	 
  s = cell(length(this.seq));
  for k = 1:length(s)
    s{k} = compile(this.seq{k},eta);
  endfor

  q = @QASMseq(s);		       

endfunction

## testing on all "H" gates as they're not likely to 
##  change and we just need to test for proper traversal
##  and construction. testing for Approximation-based compilation
##  is done in @QIASMsingle/compile.m

%!test
%! c = {@QIASMsingle("H",0),@QIASMsingle("H",1)};
%! C = @QIASMseq(c,@QIASMseq(c));
%! r = {@QASMsingle("H",0),@QASMsingle("H",1)};
%! R = @QASMseq(r,@QASMseq(r));
%! assert(eq(compile(C,1/32),R));


