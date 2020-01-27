class Converter
	constructor : (inp,outp) -> @arr = @solve inp,outp

	convert : (x,y) ->
		[a,b,c,d,e,f] = @arr
		[a*x+b*y+c, d*x+e*y+f]

	solve : (inp,outp) ->
		[a,b,c,d,e,f] = inp
		eqns = []
		eqns.push [a, b, 1, 0, 0, 0]
		eqns.push [0, 0, 0, a, b, 1]
		eqns.push [c, d, 1, 0, 0, 0]
		eqns.push [0, 0, 0, c, d, 1]
		eqns.push [e, f, 1, 0, 0, 0]
		eqns.push [0, 0, 0, e, f, 1]
		@csgauss eqns,outp

	# https://github.com/itsravenous/gaussian-elimination/blob/master/gauss.js
	csgauss : (A, x) ->
		n = A.length
		for i in range n
			A[i].push x[i]

		for i in range n 
			maxEl = Math.abs A[i][i]
			maxRow = i
			for k in range i+1, n
				if maxEl < Math.abs A[k][i]
					maxEl = Math.abs A[k][i]
					maxRow = k

			for k in range i,n+1
				[A[maxRow][k], A[i][k]] = [A[i][k], A[maxRow][k]]

			for k in range i+1, n
				c = -A[k][i] / A[i][i]
				for j in range i,n+1
					A[k][j] = if i==j then 0 else A[k][j] + c * A[i][j]

		res = range(n).map -> 0
		for i in range n-1, -1, -1
			res[i] = A[i][n] / A[i][i]
			for k in range i-1, -1, -1
				A[k][n] -= A[k][i] * res[i]

		res

# `
# var abs = Math.abs;

# function array_fill(i, n, v) {
#     var a = [];
#     for (; i < n; i++) {
#         a.push(v);
#     }
#     return a;
# }

# /**
#  * Gaussian elimination
#  * @param  array A matrix
#  * @param  array x vector
#  * @return array x solution vector
#  */
# function gauss(A, x) {

#     var i, k, j;

#     // Just make a single matrix
#     for (i=0; i < A.length; i++) { 
#         A[i].push(x[i]);
#     }
#     var n = A.length;

#     for (i=0; i < n; i++) { 
#         // Search for maximum in this column
#         var maxEl = abs(A[i][i]),
#             maxRow = i;
#         for (k=i+1; k < n; k++) { 
#             if (abs(A[k][i]) > maxEl) {
#                 maxEl = abs(A[k][i]);
#                 maxRow = k;
#             }
#         }


#         // Swap maximum row with current row (column by column)
#         for (k=i; k < n+1; k++) { 
#             var tmp = A[maxRow][k];
#             A[maxRow][k] = A[i][k];
#             A[i][k] = tmp;
#         }

#         // Make all rows below this one 0 in current column
#         for (k=i+1; k < n; k++) { 
#             var c = -A[k][i]/A[i][i];
#             for (j=i; j < n+1; j++) { 
#                 if (i===j) {
#                     A[k][j] = 0;
#                 } else {
#                     A[k][j] += c * A[i][j];
#                 }
#             }
#         }
#     }

#     // Solve equation Ax=b for an upper triangular matrix A
#     x = array_fill(0, n, 0);
#     for (i=n-1; i > -1; i--) { 
#         x[i] = A[i][n]/A[i][i];
#         for (k=i-1; k > -1; k--) { 
#             A[k][n] -= A[k][i] * x[i];
#         }
#     }

#     return x;
# }

# // module.exports = gauss;
# `

bmp = [338,1491, 4299,1948, 2963,5596] # x1,y1, x2,y2, x3,y3
wgs = [18.150709,59.285624, 18.179902,59.283048, 18.168739,59.269496] # lng1,lat1, lng2,lat2, lng3,lat3

b2w = new Converter bmp,wgs
assert [18.150709, 59.28562399999999], b2w.convert bmp[0],bmp[1]
assert [18.179902, 59.283048], b2w.convert bmp[2],bmp[3]
assert [18.168739, 59.269496], b2w.convert bmp[4],bmp[5]

w2b = new Converter wgs,bmp
assert [338.00000000023283, 1491], w2b.convert wgs[0],wgs[1]
assert [4299, 1948],  w2b.convert wgs[2],wgs[3]
assert [2963, 5595.999999998137], w2b.convert wgs[4],wgs[5]
