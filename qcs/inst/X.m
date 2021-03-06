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
## @deftypefn {Function File} {@var{U} =} X (@var{n})
##
## Compute the Pauli X matrix.
##
## Given no inputs @code{X} returns the single qubit Pauli X matrix. For any @math{@var{n}>1} it returns the @var{N}th tensor power of @code{X}.
##
## @seealso{Iop,H,Y,Z,S,T,Rx,Ry,Rz,Rn,Ph}
## @end deftypefn

## Author: Logan Mayfield <lmayfield@monmouthcollege.edu>
## Keywords: Operators

function U = X(n=1)

  ## error check number of qubits
  if( n < 0 )
    error("Number of qubits must be 0 or greater. Given n=%d",n);
  endif

  U = fliplr(eye(2^n));

endfunction


%!test
%! X1 = [0,1;1,0];
%! assert(X,X1);
%! assert(kron(X1,X1),X(2));
%! assert(kron(X1,kron(X1,X1)),X(3));
