`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2025 21:46:48
// Design Name: 
// Module Name: gauss_legendre_quadrature
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
The following is notes that I have compiled for my own understanding. The module seeks to implement the Gauss-Kronrod quadrature, which is a means of numerical integration commonly used by calculators. Disclaimer: Because I am not a mathematician, I too am unable to explain fully all the rationale behind this.

Gaussian quadrature:
An n-point Gaussian quadrature is a rule constructed to yield an exact result for polynomials of degree 2n - 1 or less. In our case, being 3 = 2n - 1, n = 2. Starting with bounds [-1, 1], the rule suggests that an integral of \int_{-1}^{1}f(x)dx \approx \sum_{i=1}^{n} w_i f(x_i), that is, the integration can be approximated to a weighted sum.

The question then stands, what are these x_i and w_i?

Gauss-Legendre quadrature
This quadrature makes use of what is known as orthogonal polynomials. Under this quadrature, the polynomials are of the form \int_{-1}^{1}P_m(x)P_n(x)dx = 0, where m and n represent some degrees. It is also the case where P_n(1) = 1. P_2(x) for example, is 1.5x^2 - 0.5.

Recall earlier that for degree 3, our n is 2, that is, we only need 2 points. From Wikipedia, w_i = \frac{2}{(1-x_i^2)(P'_n(x_i))^2}. From a youtube video by Jeffrey Chasnov on Gaussian quadrature, he explains that since the (2 point) integral is exact for up to degree 3, we can let f(x) = 1, x, x^2, x^3. This gives us 4 equations to solve for w_1, w_2, x_1 and x_2. Making use of the symmetry of the problem, w_1 = w_2 = 1, x_1 = \frac{-1}{\sqrt{3}} = -x_2.

While I initially was interested in implementing the Gaussian-Kronrod quadrature, which follows a similar idea, with the latter being exact for polynomials of degree 3n + 1, which is overkill for our case. I could not find the nodes and weights for a smaller use case like ours. Typically, the difference between the Gaussian quadrature and its Kronrod extension is merely used as an estimation of the approximation error, which can honestly be done by hand given the simple nature of the problem.
*/


module gauss_legendre_quadrature(

    );
endmodule
